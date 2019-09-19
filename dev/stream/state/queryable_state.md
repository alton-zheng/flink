# Queryable State State Beta
注意:用于可查询状态的客户机api目前处于不断发展的状态，不能保证所提供的接口的稳定性。在即将到来的Flink版本中，很可能会在客户端破坏API更改。
简而言之，该特性向外部公开了Flink的托管键控(分区)状态(请参阅使用状态)，并允许用户从外部Flink查询作业的状态。对于某些场景，可查询状态消除了与外部系统(如键值存储)进行分布式操作/事务的需要，而这些系统通常是实践中的瓶颈。此外，该特性对于调试目的可能特别有用。

注意:在查询状态对象时，从并发线程访问该对象而不进行任何同步或复制。这是一种设计选择，因为上面的任何一种都会导致作业延迟的增加，我们希望避免这种情况。因为任何国家使用的后端Java堆空间,例如MemoryStateBackend或FsStateBackend,不使用副本时检索值,而是直接引用存储值,读-修改-写模式是不安全,可能导致可查询状态服务器失败由于并发修改。rocksdbstateback后端不会出现这些问题。


## Architecture
在展示如何使用可查询状态之前，有必要简要描述组成该状态的实体。可查询状态特性由三个主要实体组成:

QueryableStateClient(可能)运行在Flink集群之外并提交用户查询，
QueryableStateClientProxy运行在每个任务管理器上(即在Flink集群中)，负责接收客户机的查询，代表客户机从负责的任务管理器获取请求的状态，并将其返回给客户机
QueryableStateServer运行在每个任务管理器上，负责为本地存储的状态提供服务。
客户机连接到其中一个代理，并发送与特定密钥k关联的状态的请求。要发现哪个TaskManager负责持有k的密钥组，代理将询问JobManager。根据答案，代理将查询运行在任务管理器上的QueryableStateServer，以获得与k关联的状态，并将响应转发回客户机。

## Activating Queryable State
要在Flink集群上启用可查询状态，需要执行以下操作:

将Flink -queryable-state-runtime_2.11-1.9.0.jar从Flink发行版的opt/文件夹复制到lib/文件夹。
设置属性query -state。使为true。有关详细信息和其他参数，请参阅配置文档。
要验证您的集群在启用了可查询状态的情况下运行，请检查任何任务管理器的日志:“启动可查询状态代理服务器@…”。

## Making State Queryable
现在您已经激活了集群上的可查询状态，现在是时候看看如何使用它了。为了使一个状态对外界可见，需要显式地使用以下方法使其可查询:

QueryableStateStream是一个方便的对象，它充当一个接收器，并提供其传入值作为可查询状态，或者
stateDescriptor。方法，该方法使状态描述符表示的键态可查询。
下面几节解释这两种方法的使用。

### Queryable State Stream
在KeyedStream上调用. asqueryablestate (stateName, stateDescriptor)将返回一个QueryableStateStream，它将其值提供为可查询状态。根据状态的类型，asQueryableState()方法有以下几种变体:

```java
// ValueState
QueryableStateStream asQueryableState(
    String queryableStateName,
    ValueStateDescriptor stateDescriptor)

// Shortcut for explicit ValueStateDescriptor variant
QueryableStateStream asQueryableState(String queryableStateName)

// FoldingState
QueryableStateStream asQueryableState(
    String queryableStateName,
    FoldingStateDescriptor stateDescriptor)

// ReducingState
QueryableStateStream asQueryableState(
    String queryableStateName,
    ReducingStateDescriptor stateDescriptor)
```

注意:没有可查询的ListState接收器，因为它会导致一个不断增长的列表，而这个列表可能不会被清除，因此最终会消耗太多内存。
返回的QueryableStateStream可以看作是一个接收器，不能进一步转换。在内部，QueryableStateStream被转换为一个操作符，该操作符使用所有传入的记录来更新可查询状态实例。更新逻辑由asQueryableState调用中提供的状态描述符类型暗示。在如下程序中，键控流的所有记录都将通过ValueState.update(value)来更新状态实例:

```java
stream.keyBy(0).asQueryableState("query-name")
```

这类似于Scala API的flatMapWithState。

### Managed Keyed State
通过使适当的状态描述符可通过状态描述符查询，可以使操作符的托管键控状态(请参阅使用托管键控状态)可查询。setquerizable (String queryableStateName)，如下面的例子所示:

```java
ValueStateDescriptor<Tuple2<Long, Long>> descriptor =
        new ValueStateDescriptor<>(
                "average", // the state name
                TypeInformation.of(new TypeHint<Tuple2<Long, Long>>() {})); // type information
descriptor.setQueryable("query-name"); // queryable state name
```

注意:queryableStateName参数可以任意选择，只用于查询。它不必与州名相同。
对于哪种状态类型可以查询，此变体没有限制。这意味着它可以用于任何ValueState、ReduceState、ListState、MapState、AggregatingState和当前不推荐的FoldingState。

## Querying State
到目前为止，您已经将集群设置为使用可查询状态运行，并且已经将(一些)状态声明为可查询状态。现在是查看如何查询此状态的时候了。

为此，您可以使用QueryableStateClient helper类。这在flink-queryable-state-client jar中是可用的，它必须与flink-core一起作为依赖项显式地包含在项目的pom.xml中，如下所示:

```xml
<dependency>
  <groupId>org.apache.flink</groupId>
  <artifactId>flink-core</artifactId>
  <version>1.9.0</version>
</dependency>
<dependency>
  <groupId>org.apache.flink</groupId>
  <artifactId>flink-queryable-state-client-java</artifactId>
  <version>1.9.0</version>
</dependency>
```

有关更多信息，您可以查看如何设置Flink程序。

QueryableStateClient将您的查询提交给内部代理，然后该代理将处理您的查询并返回最终结果。初始化客户机的唯一要求是提供一个有效的TaskManager主机名(请记住，每个任务管理器上都运行着一个可查询的状态代理)和代理侦听的端口。有关如何配置代理和状态服务器端口的更多信息，请参见配置部分。

```java
QueryableStateClient client = new QueryableStateClient(tmHostname, proxyPort);
```

在客户端就绪后，要查询V类型的状态，与K类型的键相关联，可以使用以下方法:

```java
CompletableFuture<S> getKvState(
    JobID jobId,
    String queryableStateName,
    K key,
    TypeInformation<K> keyTypeInfo,
    StateDescriptor<S, V> stateDescriptor)
```

上面返回一个完整的future，最终包含可查询状态实例的状态值，该实例由ID jobID的作业的queryableStateName标识。键是您感兴趣的状态的键，keyTypeInfo将告诉Flink如何序列化/反序列化它。最后，状态描述符包含关于请求状态的必要信息，即它的类型(值、Reduce等)和关于如何序列化/反序列化它的必要信息。

细心的读者会注意到返回的future包含一个类型S的值，即一个包含实际值的状态对象。这可以是Flink支持的任何状态类型:ValueState、ReduceState、ListState、MapState、AggregatingState和当前不推荐的FoldingState。

注意:这些状态对象不允许修改所包含的状态。您可以使用它们来获取状态的实际值，例如使用valueState.get()，或者迭代包含的<K, V>条目，例如使用mapState.entries()，但是您不能修改它们。例如，在返回的列表状态上调用add()方法将引发UnsupportedOperationException。
注意:客户机是异步的，可以由多个线程共享。在未使用时，需要通过QueryableStateClient.shutdown()关闭它，以便释放资源。

### Example
下面的示例扩展了CountWindowAverage示例(参见使用托管键控状态)，使其可查询，并展示了如何查询这个值:

```java
public class CountWindowAverage extends RichFlatMapFunction<Tuple2<Long, Long>, Tuple2<Long, Long>> {

    private transient ValueState<Tuple2<Long, Long>> sum; // a tuple containing the count and the sum

    @Override
    public void flatMap(Tuple2<Long, Long> input, Collector<Tuple2<Long, Long>> out) throws Exception {
        Tuple2<Long, Long> currentSum = sum.value();
        currentSum.f0 += 1;
        currentSum.f1 += input.f1;
        sum.update(currentSum);

        if (currentSum.f0 >= 2) {
            out.collect(new Tuple2<>(input.f0, currentSum.f1 / currentSum.f0));
            sum.clear();
        }
    }

    @Override
    public void open(Configuration config) {
        ValueStateDescriptor<Tuple2<Long, Long>> descriptor =
                new ValueStateDescriptor<>(
                        "average", // the state name
                        TypeInformation.of(new TypeHint<Tuple2<Long, Long>>() {})); // type information
        descriptor.setQueryable("query-name");
        sum = getRuntimeContext().getState(descriptor);
    }
}
```
一旦在作业中使用，您可以检索作业ID，然后从该操作符查询任何键的当前状态:
```java
QueryableStateClient client = new QueryableStateClient(tmHostname, proxyPort);

// the state descriptor of the state to be fetched.
ValueStateDescriptor<Tuple2<Long, Long>> descriptor =
        new ValueStateDescriptor<>(
          "average",
          TypeInformation.of(new TypeHint<Tuple2<Long, Long>>() {}));

CompletableFuture<ValueState<Tuple2<Long, Long>>> resultFuture =
        client.getKvState(jobId, "query-name", key, BasicTypeInfo.LONG_TYPE_INFO, descriptor);

// now handle the returned value
resultFuture.thenAccept(response -> {
        try {
            Tuple2<Long, Long> res = response.get();
        } catch (Exception e) {
            e.printStackTrace();
        }
});
```


## Config
以下配置参数影响可查询状态服务器和客户机的行为。它们在QueryableStateOptions中定义。

### State Server

queryable-state.server。端口:可查询状态服务器的服务器端口范围。如果同一台机器上运行多个任务管理器，这对于避免端口冲突非常有用。指定的范围可以是:一个端口:“9123”，一个端口范围:“50100-50200”，或者一个范围和点列表:“50100-50200,50300-50400,51234”。默认端口是9067。
网络线程:接收状态服务器传入请求的网络(事件循环)线程的数量(0 => #插槽)
queryable-state.server。查询线程:处理/服务状态服务器传入请求的线程数(0 => #插槽)。

### Proxy

queryable-state.proxy。端口:可查询状态代理的服务器端口范围。如果同一台机器上运行多个任务管理器，这对于避免端口冲突非常有用。指定的范围可以是:一个端口:“9123”，一个端口范围:“50100-50200”，或者一个范围和点列表:“50100-50200,50300-50400,51234”。默认端口是9069。
网络线程:接收客户机代理传入请求的网络(事件循环)线程的数量(0 => #插槽)
queryable-state.proxy。查询线程:为客户机代理处理/服务传入请求的线程数(0 => #插槽)。


### Limitations

- 可查询状态生命周期绑定到作业的生命周期，例如，任务在启动时注册可查询状态，在处理时注销可查询状态。在未来的版本中，最好将其解耦，以便允许在任务完成后进行查询，并通过状态复制加速恢复。
- 关于可用KvState的通知通过一个简单的tell发生。在未来，这一点应该得到改进，使其在提出要求和表示感谢方面更加有力。
- 服务器和客户机跟踪查询的统计信息。由于它们不会在任何地方公开，因此默认情况下它们是禁用的。一旦有更好的支持通过度量系统发布这些数字，我们就应该启用统计数据。


