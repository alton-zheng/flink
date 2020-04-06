# 广播状态模式

- [提供的 API](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/state/broadcast_state.html#provided-apis)
  - [BroadcastProcessFunction 和 KeyedBroadcastProcessFunction](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/state/broadcast_state.html#broadcastprocessfunction-and-keyedbroadcastprocessfunction)
- [重要注意事项](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/state/broadcast_state.html#important-considerations)

[与状态一起使用](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/state/state.html)描述了操作员状态，该操作员状态在还原时要么均匀地分布在操作员的并行任务中，要么联合在一起，整个状态用于初始化恢复的并行任务。

支持的*运营商状态的*第三种类型是*广播状态*。引入了广播状态以支持用例，在该用例中，需要将来自一个流的某些数据广播到所有下游任务，这些数据在本地存储并用于处理另一流上的所有传入元素。举一个自然而然的广播状态示例，可以想象一个低吞吐量流，其中包含一组规则，我们希望针对来自另一个流的所有元素进行评估。考虑到上述用例类型，广播状态与其他运营商状态的不同之处在于：

1.  它具有地图格式，
2.  它仅适用于具有*广播*流和*非\_\_广播*流作为输入的特定运营商，并且
3.  这样的操作员可以具有名称不同的*多个广播状态*。

## 提供的 API

为了显示提供的 API，我们将以一个示例开始，然后介绍其完整功能。作为正在运行的示例，我们将使用这样的情况，其中有一系列不同颜色和形状的对象，并且我们希望找到遵循某种模式的相同颜色的对象对，*例如*矩形后跟三角形。我们假设这组有趣的模式会随着时间而演变。

在此示例中，第一个流将包含`Item`带有`Color`和`Shape`属性的 type 元素。另一个流将包含`Rules`。

从流开始`Items`，我们只需要*键入它*的`Color`，因为我们要对相同颜色的。这将确保相同颜色的元素最终出现在同一台物理计算机上。

    // key the items by color
    KeyedStream<Item, Color> colorPartitionedStream = itemStream
                            .keyBy(new KeySelector<Item, Color>(){...});

转到`Rules`，应该将包含它们的流广播到所有下游任务，并且这些任务应该将它们存储在本地，以便它们可以针对所有传入的进行评估`Items`。下面的代码段将 i）广播规则流，并且 ii）使用提供的`MapStateDescriptor`，将创建将存储规则的广播状态。

    // a map descriptor to store the name of the rule (string) and the rule itself.
    MapStateDescriptor<String, Rule> ruleStateDescriptor = new MapStateDescriptor<>(
    			"RulesBroadcastState",
    			BasicTypeInfo.STRING_TYPE_INFO,
    			TypeInformation.of(new TypeHint<Rule>() {}));

    // broadcast the rules and create the broadcast state
    BroadcastStream<Rule> ruleBroadcastStream = ruleStream
                            .broadcast(ruleStateDescriptor);

最后，为了`Rules`根据`Item`流中的传入元素评估，我们需要：

1.  连接两个流，并且
2.  指定我们的匹配检测逻辑。

`BroadcastStream`可以通过调用`connect()`非广播流（以键`BroadcastStream`为参数）来将流（键控或非键控）与进行连接。这将返回一个`BroadcastConnectedStream`，我们可以在其中调用`process()`特殊类型的`CoProcessFunction`。该函数将包含我们的匹配逻辑。函数的确切类型取决于非广播流的类型：

- 如果输入了**密码**，则该函数为`KeyedBroadcastProcessFunction`。
- 如果它**是非键**，则该函数为`BroadcastProcessFunction`。

鉴于我们的非广播流已设置密钥，以下代码段包括上述调用：

**注意：**应该在非广播流上调用 connect，并以 BroadcastStream 作为参数。

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

### BroadcastProcessFunction 和 KeyedBroadcastProcessFunction

与 a 一样`CoProcessFunction`，这些函数有两种实现的处理方法；在`processBroadcastElement()`  它负责处理广播流在进入元件和`processElement()`其用于非广播的一个。这些方法的完整签名如下所示：

    public abstract class BroadcastProcessFunction<IN1, IN2, OUT> extends BaseBroadcastProcessFunction {

        public abstract void processElement(IN1 value, ReadOnlyContext ctx, Collector<OUT> out) throws Exception;

        public abstract void processBroadcastElement(IN2 value, Context ctx, Collector<OUT> out) throws Exception;
    }

    public abstract class KeyedBroadcastProcessFunction<KS, IN1, IN2, OUT> {

        public abstract void processElement(IN1 value, ReadOnlyContext ctx, Collector<OUT> out) throws Exception;

        public abstract void processBroadcastElement(IN2 value, Context ctx, Collector<OUT> out) throws Exception;

        public void onTimer(long timestamp, OnTimerContext ctx, Collector<OUT> out) throws Exception;
    }

首先要注意的是，这两个功能都需要实现`processBroadcastElement()`用于处理广播端中的`processElement()`元素和用于非广播端中的 for 元素的方法的实现。

两种方法在提供上下文方面有所不同。非广播方有`ReadOnlyContext`，而广播方有`Context`。

这两个上下文（`ctx`在下面的枚举中）：

1.  允许访问广播状态： `ctx.getBroadcastState(MapStateDescriptor<K, V> stateDescriptor)`
2.  允许查询元素的时间戳：`ctx.timestamp()`，
3.  得到当前的水印： `ctx.currentWatermark()`
4.  获得当前处理时间：`ctx.currentProcessingTime()`，和
5.  将元素发射到侧面输出：`ctx.output(OutputTag<X> outputTag, X value)`。

的`stateDescriptor`在`getBroadcastState()`应该是相同的所述一个在`.broadcast(ruleStateDescriptor)`  上方。

不同之处在于每个人对广播状态的访问类型。广播方对其具有  **读写访问权限**，而非广播方具有**只读访问权限**（因此具有名称）。原因是在 Flink 中没有跨任务通信。因此，为确保在我们的操作员的所有并行实例中，广播状态中的内容相同，我们仅对广播端提供读写访问权限，广播端在所有任务中看到的元素相同，因此我们需要对每个任务进行计算该端的传入元素在所有任务中都相同。忽略该规则将破坏状态的一致性保证，从而导致结果不一致，并且常常难以调试结果。

**注意：**在所有并行实例中，在 processBroadcast（）中实现的逻辑必须具有相同的确定性行为！

最后，由于的事实`KeyedBroadcastProcessFunction`是，它在键控流上运行，因此它公开了某些功能，这些功能不适用于`BroadcastProcessFunction`。那是：

1.  所述`ReadOnlyContext`的`processElement()`方法可以访问弗林克的底层定时器服务，其允许注册事件和/或处理时间的定时器。触发计时器时，将使用`onTimer()`调用（如上所示）， `OnTimerContext`该公开与`ReadOnlyContext`加号   相同的功能
    - 询问触发计时器是事件还是处理时间的能力，并且
    - 查询与计时器关联的键。
2.  所述`Context`的`processBroadcastElement()`方法包含方法  `applyToKeyedState(StateDescriptor<S, VS> stateDescriptor, KeyedStateFunction<KS, S> function)`。这允许一个注册`KeyedStateFunction`将被**施加到所有键的所有状态**与所提供的相关联`stateDescriptor`。

**注意：**仅在“ KeyedBroadcastProcessFunction”的“ processElement（）”处才可以注册计时器。在 processBroadcastElement（）方法中是不可能的，因为没有与广播元素关联的键。

回到我们的原始示例，我们`KeyedBroadcastProcessFunction`可能如下所示：

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

## 重要注意事项

描述了提供的 API 之后，本节重点介绍使用广播状态时要记住的重要事项。这些是：

- **没有跨任务通信：**如前所述，这就是为什么仅 a 的广播方  `(Keyed)-BroadcastProcessFunction`可以修改广播状态的内容的原因。另外，用户必须确保所有任务对于每个传入元素都以相同的方式修改广播状态的内容。否则，不同的任务可能具有不同的内容，从而导致结果不一致。

- **广播状态中事件的顺序在各个任务之间可能有所不同：**尽管广播流的元素保证了所有元素（最终）将进入所有下游任务，但是元素对于每个任务的到达顺序可能不同。因此，每个传入元素的状态更新*必须不取决于*传入事件*的顺序*。

- **所有任务都会检查其广播状态：**尽管发生检查点时，所有任务在其广播状态中具有相同的元素（检查点屏障不会越过元素），但所有任务都将指向其广播状态，而不仅仅是其中一个。这是一项设计决策，要避免在还原过程中从同一文件读取所有任务（从而避免出现热点），尽管这样做的代价是将检查点状态的大小增加了 p 倍（=并行度）。Flink 保证在恢复/缩放后**不会重复**，也**不会丢失数据**。在使用相同或更小的并行度进行恢复的情况下，每个任务都会读取其检查点状态。扩展后，每个任务都会读取自己的状态，其余任务（`p_new`-`p_old`）以循环方式读取先前任务的检查点。

- **没有 RocksDB 状态后端：**在运行时将广播状态保留在内存中，并且应该相应地进行内存配置。这适用于所有操作员状态。
