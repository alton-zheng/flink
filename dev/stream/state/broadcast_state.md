# The Broadcast State Pattern
使用状态描述操作符状态，该状态在恢复时均匀地分布于操作符的并行任务之间，或者统一使用整个状态初始化恢复后的并行任务。

第三种受支持的操作符状态是广播状态。引入Broadcast state是为了支持这样的用例:来自一个流的一些数据需要广播到所有下游任务，这些数据存储在本地，并用于处理另一个流上的所有传入元素。作为广播状态可以自然出现的一个例子，可以想象一个低吞吐量流包含一组规则，我们希望根据来自另一个流的所有元素对这些规则进行评估。考虑到上面的用例类型，广播状态与其他操作符状态的区别在于:

1. 它有地图格式，
2. 它只适用于输入广播流和非广播流的特定操作符，以及
3. 这样的操作符可以具有多个具有不同名称的广播状态。

## Provided APIs

为了展示所提供的api，在展示它们的全部功能之前，我们将从一个示例开始。在我们的运行示例中，我们将使用这样一种情况:我们有一个不同颜色和形状的对象流，并且我们希望找到遵循特定模式的相同颜色的对象对，例如一个矩形后面跟着一个三角形。我们假设一组有趣的模式会随着时间的推移而发展。

在本例中，第一个流将包含带有颜色和形状属性的Item类型的元素。另一个流将包含规则。

从项目流开始，我们只需要按颜色来键入它，因为我们想要相同颜色的对。这将确保相同颜色的元素最终出现在相同的物理机器上。

```java
// key the shapes by color
KeyedStream<Item, Color> colorPartitionedStream = shapeStream
                        .keyBy(new KeySelector<Shape, Color>(){...});
```

继续讨论规则，应该向所有下游任务广播包含规则的流，这些任务应该将规则存储在本地，以便根据所有传入的条目对规则进行评估。下面的代码片段将i)广播规则流，ii)使用提供的MapStateDescriptor，它将创建规则存储的广播状态。

```java
// a map descriptor to store the name of the rule (string) and the rule itself.
MapStateDescriptor<String, Rule> ruleStateDescriptor = new MapStateDescriptor<>(
			"RulesBroadcastState",
			BasicTypeInfo.STRING_TYPE_INFO,
			TypeInformation.of(new TypeHint<Rule>() {}));
		
// broadcast the rules and create the broadcast state
BroadcastStream<Rule> ruleBroadcastStream = ruleStream
                        .broadcast(ruleStateDescriptor);
```

最后，为了针对项目流中的传入元素评估规则，我们需要:

连接两个流，并且
指定匹配检测逻辑。
通过调用非广播流上的connect()来连接流(键控或非键控)和BroadcastStream，并将BroadcastStream作为参数。这将返回BroadcastConnectedStream，我们可以使用特殊类型的CoProcessFunction在其上调用process()。该函数将包含我们的匹配逻辑。函数的确切类型取决于非广播流的类型:

如果它是键控的，那么这个函数就是一个KeyedBroadcastProcessFunction。
如果它是非键控的，则该函数是BroadcastProcessFunction。
鉴于我们的非广播流是键控的，以下片段包括上述调用:

注意:连接应该在非广播流上调用，以BroadcastStream作为参数。

```java
DataStream<String> output = colorPartitionedStream
                 .connect(ruleBroadcastStream)
                 .process(
                     
                     // type arguments in our KeyedBroadcastProcessFunction represent: 
                     //   1. the key of the keyed stream
                     //   2. the type of elements in the non-broadcast side
                     //   3. the type of elements in the broadcast side
                     //   4. the type of the result, here a string
                     
                     new KeyedBroadcastProcessFunction<Color, Item, Rule, String>() {
                         // my matching logic
                     }
                 );
```

## BroadcastProcessFunction and KeyedBroadcastProcessFunction

对于CoProcessFunction，这些函数有两种实现过程方法;processBroadcastElement()负责处理广播流中的传入元素，而processElement()用于非广播流。方法的完整签名如下:

```java
public abstract class BroadcastProcessFunction<IN1, IN2, OUT> extends BaseBroadcastProcessFunction {

    public abstract void processElement(IN1 value, ReadOnlyContext ctx, Collector<OUT> out) throws Exception;

    public abstract void processBroadcastElement(IN2 value, Context ctx, Collector<OUT> out) throws Exception;
}

public abstract class KeyedBroadcastProcessFunction<KS, IN1, IN2, OUT> {

    public abstract void processElement(IN1 value, ReadOnlyContext ctx, Collector<OUT> out) throws Exception;

    public abstract void processBroadcastElement(IN2 value, Context ctx, Collector<OUT> out) throws Exception;

    public void onTimer(long timestamp, OnTimerContext ctx, Collector<OUT> out) throws Exception;
}
```

首先要注意的是，这两个函数都需要实现processBroadcastElement()方法来处理广播端中的元素，以及processElement()来处理非广播端中的元素。

这两种方法在它们所提供的上下文中是不同的。非广播端具有只读上下文，而广播端具有上下文。

这两种上下文(下面列举的ctx):

- 允许访问广播状态:ctx。getBroadcastState (MapStateDescriptor < K、V > stateDescriptor)
- 允许查询元素的时间戳:ctx.timestamp()，
- 获取当前水印:ctx.currentWatermark()
- 获取当前处理时间:ctx.currentProcessingTime()和
- 向侧输出发出元素:ctx。输出(OutputTag<X> OutputTag, X值)。

getBroadcastState()中的状态描述符应该与上面.broadcast(ruleStateDescriptor)中的状态描述符相同。

不同之处在于它们各自对广播状态的访问类型。广播端具有对它的读写访问权，而非广播端具有只读访问权(因此名称)。原因是在Flink中没有跨任务通信。所以,为了保证内容的播出状态是相同的所有平行的实例我们的运营商,我们给广播方面,读写访问只看到相同的元素在所有任务,我们需要计算每个传入的元素,是相同的所有任务。忽略这条规则将破坏状态的一致性保证，导致不一致且常常难以调试结果。

注意:在“processBroadcast()”中实现的逻辑必须在所有并行实例中具有相同的确定性行为!
最后，由于KeyedBroadcastProcessFunction是在键控流上运行的，因此它公开了BroadcastProcessFunction不可用的一些功能。那就是:

processElement()方法中的ReadOnlyContext允许访问Flink的底层计时器服务，该服务允许注册事件和/或处理时间计时器。当计时器触发时，使用OnTimerContext调用onTimer()(如上所示)，OnTimerContext公开了与ReadOnlyContext plus相同的功能
能够询问触发的计时器是事件还是处理时间1和
查询与计时器关联的键。
processBroadcastElement()方法中的上下文包含方法applyToKeyedState(状态描述符<S, VS . >状态描述符，KeyedStateFunction<KS, S>函数)。这允许注册一个KeyedStateFunction，应用于与所提供的状态描述符关联的所有键的所有状态。
注意:注册定时器只能在' processElement() '的' KeyedBroadcastProcessFunction '和只有那里。在“processBroadcastElement()”方法中是不可能的，因为没有与广播元素关联的键。
回到我们最初的例子，我们的KeyedBroadcastProcessFunction看起来像这样:

```java
new KeyedBroadcastProcessFunction<Color, Item, Rule, String>() {

    // store partial matches, i.e. first elements of the pair waiting for their second element
    // we keep a list as we may have many first elements waiting
    private final MapStateDescriptor<String, List<Item>> mapStateDesc =
        new MapStateDescriptor<>(
            "items",
            BasicTypeInfo.STRING_TYPE_INFO,
            new ListTypeInfo<>(Item.class));

    // identical to our ruleStateDescriptor above
    private final MapStateDescriptor<String, Rule> ruleStateDescriptor = 
        new MapStateDescriptor<>(
            "RulesBroadcastState",
            BasicTypeInfo.STRING_TYPE_INFO,
            TypeInformation.of(new TypeHint<Rule>() {}));

    @Override
    public void processBroadcastElement(Rule value,
                                        Context ctx,
                                        Collector<String> out) throws Exception {
        ctx.getBroadcastState(ruleStateDescriptor).put(value.name, value);
    }

    @Override
    public void processElement(Item value,
                               ReadOnlyContext ctx,
                               Collector<String> out) throws Exception {

        final MapState<String, List<Item>> state = getRuntimeContext().getMapState(mapStateDesc);
        final Shape shape = value.getShape();
    
        for (Map.Entry<String, Rule> entry :
                ctx.getBroadcastState(ruleStateDescriptor).immutableEntries()) {
            final String ruleName = entry.getKey();
            final Rule rule = entry.getValue();
    
            List<Item> stored = state.get(ruleName);
            if (stored == null) {
                stored = new ArrayList<>();
            }
    
            if (shape == rule.second && !stored.isEmpty()) {
                for (Item i : stored) {
                    out.collect("MATCH: " + i + " - " + value);
                }
                stored.clear();
            }
    
            // there is no else{} to cover if rule.first == rule.second
            if (shape.equals(rule.first)) {
                stored.add(value);
            }
    
            if (stored.isEmpty()) {
                state.remove(ruleName);
            } else {
                state.put(ruleName, stored);
            }
        }
    }
}
```

## Important Considerations
在描述了提供的api之后，本节将重点介绍在使用广播状态时要记住的重要事项。它们是：

- 不存在跨任务通信:如前所述，这就是为什么只有(key -) broadcastprocessfunction的广播端才能修改广播状态的内容的原因。此外，用户必须确保所有任务以相同的方式修改每个传入元素的广播状态的内容。否则，不同的任务可能有不同的内容，导致结果不一致。
- 广播状态下事件的顺序可能会因任务而异:尽管广播流的元素可以保证所有元素(最终)到达所有下游任务，但是元素到达每个任务的顺序可能不同。因此，每个传入元素的状态更新不能依赖于传入事件的顺序。
- 所有任务都检查它们的广播状态:尽管所有任务在发生检查点时的广播状态中都有相同的元素(检查点屏障不会跳过元素)，但是所有任务都检查它们的广播状态，而不只是其中一个。这是一个设计决策，以避免在恢复期间从同一文件读取所有任务(从而避免热点)，尽管这是以将检查点状态的大小增加p(=并行度)为代价的。Flink保证在恢复/重新缩放时不会出现重复和丢失数据。在并行度相同或更小的恢复情况下，每个任务读取其检查点状态。扩展后，每个任务读取自己的状态，其余的任务(p_new-p_old)以循环方式读取以前任务的检查点。
- 没有RocksDB状态后端:广播状态在运行时保存在内存中，应该相应地执行内存供应。这适用于所有操作符状态。

