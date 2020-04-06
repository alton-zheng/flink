# 可查询状态 Beta

- [建筑](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/state/queryable_state.html#architecture)
- [激活可查询状态](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/state/queryable_state.html#activating-queryable-state)
- [使状态可查询](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/state/queryable_state.html#making-state-queryable)
  - [可查询状态流](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/state/queryable_state.html#queryable-state-stream)
  - [受管键控状态](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/state/queryable_state.html#managed-keyed-state)
- [查询状态](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/state/queryable_state.html#querying-state)
  - [例](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/state/queryable_state.html#example)
- [组态](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/state/queryable_state.html#configuration)
  - [状态服务器](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/state/queryable_state.html#state-server)
  - [代理](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/state/queryable_state.html#proxy)
- [局限性](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/state/queryable_state.html#limitations)

**注意：**用于可查询状态的客户端 API 当前处于不断发展的状态，并且**不能保证**所提供接口的稳定性。在即将发布的 Flink 版本中，客户端上的 API 更改可能会发生重大变化。

简而言之，此功能将 Flink 的托管键控（分区）状态（请参阅[使用状态](https://ci.apache.org/projects/flink/flink-docs-release-1.10/dev/stream/state/state.html)）向外界公开，并允许用户从 Flink 外部查询作业的状态。在某些情况下，可查询状态消除了与外部系统（例如，键值存储）的分布式操作/事务的需要，而分布式系统通常是实际的瓶颈。此外，此功能对于调试目的可能特别有用。

**注意：**查询状态对象时，将从并发线程访问该对象，而无需任何同步或复制。这是一种设计选择，因为以上任何一种都会导致工作延迟增加，我们希望避免这种情况。由于使用 Java 堆空间的任何状态后端（ *例如* `MemoryStateBackend`或）`FsStateBackend`在检索值时均不能使用副本，而是直接引用存储的值，因此读-修改-写模式是不安全的，并且可能由于并发修改而导致可查询状态服务器失败。该`RocksDBStateBackend`从这些问题的安全。

## 建筑

在显示如何使用可查询状态之前，简要描述组成它的实体很有用。可查询状态功能由三个主要实体组成：

1.  的`QueryableStateClient`，其中（可能）运行外的弗林克簇并提交用户查询，
2.  的`QueryableStateClientProxy`，其中每个运行`TaskManager`（*即*在弗林克集群内），并负责接收客户的疑问，代表他取出由负责任务管理器所请求的状态，并返回给客户端，
3.  在`QueryableStateServer`它运行在每个`TaskManager`并负责提供本地存储的状态。

客户端连接到代理之一，并发送对与特定密钥关联的状态的请求`k`。如[使用状态中所述](https://ci.apache.org/projects/flink/flink-docs-release-1.10/dev/stream/state/state.html)，密钥状态在*密钥组中进行*组织，并且每个密钥状态  `TaskManager`都分配有多个这些密钥组。为了发现哪个`TaskManager`负责密钥组的持有`k`，代理会询问`JobManager`。根据答案，代理将查询与之相关的`QueryableStateServer`运行`TaskManager`状态`k`，并将响应转发回客户端。

## 激活可查询状态

要在 Flink 群集上启用可查询状态，您需要执行以下操作：

1.  将“复制” `flink-queryable-state-runtime_2.11-1.10.0.jar`  从[Flink 发行版](https://flink.apache.org/downloads.html "Apache Flink：下载")的`opt/`文件夹复制到该文件夹。`lib/`
2.  将该属性设置`queryable-state.enable`为`true`。有关详细信息和其他参数，请参阅[配置](https://ci.apache.org/projects/flink/flink-docs-release-1.10/ops/config.html#queryable-state)文档。

要验证集群是否在启用可查询状态的情况下运行，请检查任何任务管理器的日志中的行：`"Started the Queryable State Proxy Server @ ..."`。

## 使状态可查询

现在您已经在集群上激活了可查询状态，现在该看看如何使用它了。为了使状态对外界可见，需要使用以下命令显式地使其可查询：

- 或者是`QueryableStateStream`，一个方便对象充当信宿，并提供其输入的值作为可查询状态，或
- 的`stateDescriptor.setQueryable(String queryableStateName)`方法，这使得由所述状态描述符，可查询所表示的键合状态。

以下各节说明了这两种方法的用法。

### 可查询状态流

调用`.asQueryableState(stateName, stateDescriptor)`a 会`KeyedStream`返回 a `QueryableStateStream`，该 a  提供其值作为可查询状态。根据状态的类型，方法有以下变体`asQueryableState()` ：

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

**注意：**没有可查询的接收`ListState`器，因为它会导致列表不断增长，可能无法清除，最终将占用过多内存。

返回的内容`QueryableStateStream`可以看作是一个接收器，**无法**进行进一步转换。在内部，将 a `QueryableStateStream`转换为使用所有传入记录来更新可查询状态实例的运算符。调用中`StateDescriptor`提供的类型隐含了更新逻辑`asQueryableState`。在类似以下的程序中，密钥流的所有记录将用于通过来更新状态实例  `ValueState.update(value)`：

    stream.keyBy(0).asQueryableState("query-name")

这就像 Scala API 的一样`flatMapWithState`。

### 受管键控状态

通过使可通过查询适当的状态描述符，可以使运算符的托管键状态（请参阅[使用托管键状态](https://ci.apache.org/projects/flink/flink-docs-release-1.10/dev/stream/state/state.html#using-managed-keyed-state)）变为可查询状态  `StateDescriptor.setQueryable(String queryableStateName)`，如下例所示：

    ValueStateDescriptor<Tuple2<Long, Long>> descriptor =
            new ValueStateDescriptor<>(
                    "average", // the state name
                    TypeInformation.of(new TypeHint<Tuple2<Long, Long>>() {})); // type information
    descriptor.setQueryable("query-name"); // queryable state name

**注意：**该`queryableStateName`参数可以任意选择，仅用于查询。它不必与该州自己的名字相同。

此变体对于可以查询哪种状态没有限制。这可以用于任何这意味着`ValueState`，`ReduceState`，`ListState`，`MapState`，`AggregatingState`，和当前已过时`FoldingState`。

## 查询状态

到目前为止，您已经将集群设置为以可查询状态运行，并且已声明（某些状态）为可查询状态。现在该看看如何查询此状态了。

为此，您可以使用`QueryableStateClient`助手类。可以在`flink-queryable-state-client` jar 中找到它，必须将其`pom.xml`与一起作为依赖项显式地包含在您的项目中`flink-core`，如下所示：

    <dependency>
      <groupId>org.apache.flink</groupId>
      <artifactId>flink-core</artifactId>
      <version>1.10.0</version>
    </dependency>
    <dependency>
      <groupId>org.apache.flink</groupId>
      <artifactId>flink-queryable-state-client-java</artifactId>
      <version>1.10.0</version>
    </dependency>

有关更多信息，您可以检查如何[设置 Flink 程序](https://ci.apache.org/projects/flink/flink-docs-release-1.10/dev/projectsetup/dependencies.html)。

在`QueryableStateClient`将提交查询到内部代理，然后将处理您的查询并返回最终结果。初始化客户端的唯一要求是提供一个有效的`TaskManager`主机名（请记住，每个任务管理器上都在运行一个可查询的状态代理）和该代理侦听的端口。更多关于如何在配置代理服务器和状态服务器端口[配置部分](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/state/queryable_state.html#configuration)。

    QueryableStateClient client = new QueryableStateClient(tmHostname, proxyPort);

准备好客户端后，要查询 type 的状态和与 type `V`的键相关联`K`，可以使用以下方法：

    CompletableFuture<S> getKvState(
        JobID jobId,
        String queryableStateName,
        K key,
        TypeInformation<K> keyTypeInfo,
        StateDescriptor<S, V> stateDescriptor)

上面的代码返回`CompletableFuture`最终保存的`queryableStateName`ID 为的作业所标识的可查询状态实例的状态值`jobID`。的`key`是，其状态你有兴趣和重点  `keyTypeInfo`会告诉弗林克如何序列化/反序列化。最后，`stateDescriptor`包含了请求的状态，即它的类型（必要的信息`Value`，`Reduce`等等），并就如何序列化/反序列化的必要信息。

细心的读者会注意到，返回的 future 包含一个 type 的值`S`，*即*一个`State`包含实际值的对象。这可以通过任何支持弗林克状态类型：`ValueState`，`ReduceState`，`ListState`，`MapState`， `AggregatingState`，和当前已过时`FoldingState`。

**注意：**这些状态对象不允许修改包含的状态。您可以使用它们来获取状态的实际值（*例如*使用）`valueState.get()`，或迭代所包含的`<K, V>`条目（*例如*使用）`mapState.entries()`，但是您不能修改它们。例如，`add()`在返回的列表状态上调用该方法将抛出  `UnsupportedOperationException`。

**注意：**客户端是异步的，可以由多个线程共享。需要`QueryableStateClient.shutdown()`在不使用时关闭它，以释放资源。

### 例

以下示例通过使其可查询来扩展该`CountWindowAverage`示例（请参阅[使用托管密钥状态](https://ci.apache.org/projects/flink/flink-docs-release-1.10/dev/stream/state/state.html#using-managed-keyed-state)），并显示了如何查询该值：

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

在作业中使用后，您可以检索该作业 ID，然后从此运算符查询任何键的当前状态：

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

## 组态

以下配置参数影响可查询状态服务器和客户端的行为。它们在中定义`QueryableStateOptions`。

### 状态服务器

- `queryable-state.server.ports`：可查询状态服务器的服务器端口范围。如果在同一台计算机上运行多个任务管理器，这对于避免端口冲突很有用。指定的范围可以是：端口：“ 9123”，端口范围：“ 50100-50200”，或范围和/或点的列表：“ 50100-50200,50300-50400,51234”。默认端口是 9067。
- `queryable-state.server.network-threads`：接收状态服务器传入请求的网络（事件循环）线程的数量（0 => #slots）
- `queryable-state.server.query-threads`：处理/处理状态服务器传入请求的线程数（0 => #slots）。

### 代理

- `queryable-state.proxy.ports`：可查询状态代理的服务器端口范围。如果在同一台计算机上运行多个任务管理器，这对于避免端口冲突很有用。指定的范围可以是：端口：“ 9123”，端口范围：“ 50100-50200”，或范围和/或点的列表：“ 50100-50200,50300-50400,51234”。默认端口是 9069。
- `queryable-state.proxy.network-threads`：接收客户端代理的传入请求的网络（事件循环）线程的数量（0 => #slots）
- `queryable-state.proxy.query-threads`：处理/服务于客户端代理的传入请求的线程数（0 => #slots）。

## 局限性

- 可查询状态生命周期绑定到作业的生命周期，*例如，*任务在启动时注册可查询状态，而在处置时注销它。在将来的版本中，希望将其解耦以允许任务完成后进行查询，并通过状态复制加快恢复速度。
- 关于可用 KvState 的通知通过一个简单的 tell 发生。将来应对此进行改进，使其在询问和确认时更加可靠。
- 服务器和客户端跟踪查询的统计信息。这些默认情况下当前处于禁用状态，因为它们不会在任何地方公开。只要有更好的支持通过 Metrics 系统发布这些数字，我们就应该启用统计信息。
