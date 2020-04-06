# 窗

Windows 是处理无限流的核心。Windows 将流分成有限大小的“存储桶”，我们可以在其上应用计算。本文档重点介绍如何在 Flink 中执行窗口化，以及程序员如何从其提供的功能中获得最大收益。

窗口式 Flink 程序的一般结构如下所示。第一个片段指的是*键控*流，第二个片段指的*是非\_\_键控*流。正如人们所看到的，唯一的区别是`keyBy(...)`呼吁密钥流和`window(...)`成为`windowAll(...)`非键控流。这还将用作本页面其余部分的路线图。

**键控视窗**

    stream
           .keyBy(...)               <-  keyed versus non-keyed windows
           .window(...)              <-  required: "assigner"
          [.trigger(...)]            <-  optional: "trigger" (else default trigger)
          [.evictor(...)]            <-  optional: "evictor" (else no evictor)
          [.allowedLateness(...)]    <-  optional: "lateness" (else zero)
          [.sideOutputLateData(...)] <-  optional: "output tag" (else no side output for late data)
           .reduce/aggregate/fold/apply()      <-  required: "function"
          [.getSideOutput(...)]      <-  optional: "output tag"

**非键 Windows**

    stream
           .windowAll(...)           <-  required: "assigner"
          [.trigger(...)]            <-  optional: "trigger" (else default trigger)
          [.evictor(...)]            <-  optional: "evictor" (else no evictor)
          [.allowedLateness(...)]    <-  optional: "lateness" (else zero)
          [.sideOutputLateData(...)] <-  optional: "output tag" (else no side output for late data)
           .reduce/aggregate/fold/apply()      <-  required: "function"
          [.getSideOutput(...)]      <-  optional: "output tag"

在上面，方括号（\[…\]）中的命令是可选的。这表明 Flink 允许您以多种不同方式自定义窗口逻辑，从而使其最适合您的需求。

- [窗口生命周期](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#window-lifecycle)
- [键控与非键控 Windows](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#keyed-vs-non-keyed-windows)
- [窗口分配器](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#window-assigners)
  - [翻滚视窗](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tumbling-windows)
  - [滑动窗](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#sliding-windows)
  - [会话窗口](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#session-windows)
  - [全球视窗](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#global-windows)
- [视窗功能](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#window-functions)
  - [Reduce 功能](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#reducefunction)
  - [聚合函数](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#aggregatefunction)
  - [折叠功能](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#foldfunction)
  - [ProcessWindowFunction](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#processwindowfunction)
  - [具有增量聚合的 ProcessWindowFunction](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#processwindowfunction-with-incremental-aggregation)
  - [在 ProcessWindowFunction 中使用每个窗口状态](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#using-per-window-state-in-processwindowfunction)
  - [WindowFunction（旧版）](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#windowfunction-legacy)
- [扳机](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#triggers)
  - [火与净化](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#fire-and-purge)
  - [WindowAssigners 的默认触发器](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#default-triggers-of-windowassigners)
  - [内置和自定义触发器](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#built-in-and-custom-triggers)
- [驱逐者](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#evictors)
- [允许延迟](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#allowed-lateness)
  - [获取最新数据作为侧面输出](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#getting-late-data-as-a-side-output)
  - [后期元素注意事项](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#late-elements-considerations)
- [处理窗口结果](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#working-with-window-results)
  - [水印和窗户的相互作用](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#interaction-of-watermarks-and-windows)
  - [连续窗口操作](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#consecutive-windowed-operations)
- [有用的州规模考虑](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#useful-state-size-considerations)

## 窗口生命周期

简而言之，一旦应属于该窗口的第一个元素到达，就会**创建**一个窗口，并且当时间（事件或处理时间）超过其结束时间戳加上用户指定的时间（请参阅“ [允许](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#allowed-lateness)延迟”）后，该窗口将被**完全删除**。 ）。Flink 保证只删除基于时间的窗口，而不能删除其他类型的窗口，*例如*全局窗口（请参阅[窗口分配器](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#window-assigners)）。例如，采用基于事件时间的开窗策略，该策略每 5 分钟创建一次不重叠（或翻滚）的窗口，并允许延迟 1 分钟，因此 Flink 将为和之间的间隔创建一个新窗口。` allowed lateness``12:00``12:05 `当带有时间戳的第一个元素落入此间隔时，当水印通过`12:06`  时间戳时，它将删除它。

此外，每个窗口将具有`Trigger`（参见[触发器](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#triggers)）和一个函数（`ProcessWindowFunction`，`ReduceFunction`， `AggregateFunction`或`FoldFunction`）（见[窗口功能](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#window-functions)）连接到它。该函数将包含要应用于窗口内容的计算，而则`Trigger`指定了在什么条件下可以将窗口视为要应用该函数的条件。触发策略可能类似于“当窗口中的元素数大于 4 时”或“当水印通过窗口末尾时”。触发器还可以决定在创建和删除窗口之间的任何时间清除窗口的内容。在这种情况下，清除仅是指窗口中的元素，而*不是*窗口元数据。这意味着仍可以将新数据添加到该窗口。

除上述内容外，您还可以指定一个`Evictor`（请参阅[Evictors](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#evictors)），该触发器将在触发触发器后以及应用此功能之前和/或之后从窗口中删除元素。

在下文中，我们将对上述每个组件进行更详细的介绍。我们先从上面的代码片段中的必需部分开始（请参见[Keyed ](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#window-assigner)[vs Non- ](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#keyed-vs-non-keyed-windows)[Keyed ](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#window-assigner)[Windows](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#keyed-vs-non-keyed-windows)，[Window Assigner](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#window-assigner)和  [Window Function](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#window-function)），然后再转到可选部分。

## 键控与非键控 Windows

要指定的第一件事是您的流是否应该设置密钥。这必须在定义窗口之前完成。使用`keyBy(...)`会将您的无限流分割成逻辑键流。如果`keyBy(...)`未调用，则不会为您的流设置密钥。

在密钥流的情况下，你的传入事件的任何属性可以作为一个按键（详情[点击这里](https://ci.apache.org/projects/flink/flink-docs-release-1.10/dev/api_concepts.html#specifying-keys)）。拥有键控流将允许您的窗口化计算由多个任务并行执行，因为每个逻辑键控流都可以独立于其余逻辑流进行处理。引用同一键的所有元素将被发送到同一并行任务。

对于非键控流，您的原始流将不会拆分为多个逻辑流，并且所有窗口逻辑将由单个任务执行，*即*并行度为 1。

## 窗口分配器

在指定您的流是否为键控之后，下一步是定义*窗口分配器*。窗口分配器定义了如何将元素分配给窗口。这是通过`WindowAssigner`  在`window(...)`（针对*键控*流）或`windowAll()`（针对*非键控*流）调用中指定您选择的选项来完成的。

A `WindowAssigner`负责将每个传入元素分配给一个或多个窗口。Flink 带有针对最常见用例的预定义窗口分配器，即*滚动窗口*， *滑动窗口*，*会话窗口*和*全局窗口*。您还可以通过扩展`WindowAssigner`类来实现自定义窗口分配器。所有内置窗口分配器（全局窗口除外）均根据时间将元素分配给窗口，时间可以是处理时间，也可以是事件时间。请查看[事件时间](https://ci.apache.org/projects/flink/flink-docs-release-1.10/dev/event_time.html)部分，以了解处理时间和事件时间之间的差异以及时间戳和水印的生成方式。

基于时间的窗口具有*开始时间戳*（包括端点）和*结束\_\_时间戳*（包括端点），它们共同描述了窗口的大小。在代码中，Flink 在使用`TimeWindow`基于时间的窗口时使用，该方法具有查询开始和结束时间戳记的方法`maxTimestamp()`，还具有返回给定窗口允许的最大时间戳的附加方法。

下面，我们展示 Flink 的预定义窗口分配器如何工作以及如何在 DataStream 程序中使用它们。下图显示了每个分配器的工作情况。紫色圆圈表示流的元素，这些元素被某个键（在这种情况下为*用户 1*，*用户 2*和*用户 3*）划分。x 轴显示时间进度。

### 翻滚视窗

甲*翻滚窗口*分配器受让人的每个元素到指定的窗口*的窗口大小*。滚动窗口具有固定的大小，并且不重叠。例如，如果您指定大小为 5 分钟的翻滚窗口，则将评估当前窗口，并且每五分钟将启动一个新窗口，如下图所示。

![](https://ci.apache.org/projects/flink/flink-docs-release-1.10/fig/tumbling-windows.svg)

以下代码段显示了如何使用滚动窗口。

- [**爪哇**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_java_0)
- [**斯卡拉**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_scala_0)

  DataStream<T> input = ...;

  // tumbling event-time windows
  input
  .keyBy(<key selector>)
  .window(TumblingEventTimeWindows.of(Time.seconds(5)))
  .<windowed transformation>(<window function>);

  // tumbling processing-time windows
  input
  .keyBy(<key selector>)
  .window(TumblingProcessingTimeWindows.of(Time.seconds(5)))
  .<windowed transformation>(<window function>);

  // daily tumbling event-time windows offset by -8 hours.
  input
  .keyBy(<key selector>)
  .window(TumblingEventTimeWindows.of(Time.days(1), Time.hours(-8)))
  .<windowed transformation>(<window function>);

时间间隔可以通过使用一个指定`Time.milliseconds(x)`，`Time.seconds(x)`， `Time.minutes(x)`，等等。

如最后一个示例所示，滚动窗口分配器还采用一个可选`offset`  参数，该参数可用于更改窗口的对齐方式。例如，如果没有偏移，则每小时滚动窗口与 epoch 对齐，即您将获得诸如的窗口  `1:00:00.000 - 1:59:59.999`，`2:00:00.000 - 2:59:59.999`依此类推。如果要更改，可以提供一个偏移量。随着 15 分钟的偏移量，你会，例如，拿  `1:15:00.000 - 2:14:59.999`，`2:15:00.000 - 3:14:59.999`等一个重要的用例的偏移是窗口调整到比 UTC-0 时区等。例如，在中国，您必须指定的偏移量`Time.hours(-8)`。

### 滑动窗

该*滑动窗口*分配器受让人元件以固定长度的窗口。类似于滚动窗口分配器，*窗口的大小*由*窗口大小*参数配置。附加的*窗口滑动*参数控制滑动窗口启动的频率。因此，如果幻灯片小于窗口大小，则滑动窗口可能会重叠。在这种情况下，元素被分配给多个窗口。

例如，您可以将大小为 10 分钟的窗口滑动 5 分钟。这样，您每隔 5 分钟就会得到一个窗口，其中包含最近 10 分钟内到达的事件，如下图所示。

![](https://ci.apache.org/projects/flink/flink-docs-release-1.10/fig/sliding-windows.svg)

以下代码段显示了如何使用滑动窗口。

- [**爪哇**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_java_1)
- [**斯卡拉**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_scala_1)

  DataStream<T> input = ...;

  // sliding event-time windows
  input
  .keyBy(<key selector>)
  .window(SlidingEventTimeWindows.of(Time.seconds(10), Time.seconds(5)))
  .<windowed transformation>(<window function>);

  // sliding processing-time windows
  input
  .keyBy(<key selector>)
  .window(SlidingProcessingTimeWindows.of(Time.seconds(10), Time.seconds(5)))
  .<windowed transformation>(<window function>);

  // sliding processing-time windows offset by -8 hours
  input
  .keyBy(<key selector>)
  .window(SlidingProcessingTimeWindows.of(Time.hours(12), Time.hours(1), Time.hours(-8)))
  .<windowed transformation>(<window function>);

时间间隔可以通过使用一个指定`Time.milliseconds(x)`，`Time.seconds(x)`， `Time.minutes(x)`，等等。

如最后一个示例所示，滑动窗口分配器还带有一个可选`offset`参数，可用于更改窗口的对齐方式。例如，如果没有偏移，则每小时滑动 30 分钟的窗口将与 epoch 对齐，即您将获得诸如的窗口  `1:00:00.000 - 1:59:59.999`，`1:30:00.000 - 2:29:59.999`依此类推。如果要更改，可以提供一个偏移量。随着 15 分钟的偏移量，你会，例如，拿  `1:15:00.000 - 2:14:59.999`，`1:45:00.000 - 2:44:59.999`等一个重要的用例的偏移是窗口调整到比 UTC-0 时区等。例如，在中国，您必须指定的偏移量`Time.hours(-8)`。

### 会话窗口

在*会话窗口*出让方按活动的会话组中的元素。与*滚动窗口*和*滑动窗口*相比，会话窗口不重叠且没有固定的开始和结束时间。相反，当会话窗口在一定时间段内未收到元素时（_即_，发生不活动间隙时），它将关闭。会话窗口分配器可与静态配置*会话间隙*或与  *会话间隙提取*功能，其限定不活动周期有多长。当该时间段到期时，当前会话关闭，随后的元素被分配给新的会话窗口。

![](https://ci.apache.org/projects/flink/flink-docs-release-1.10/fig/session-windows.svg)

以下代码段显示了如何使用会话窗口。

- [**爪哇**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_java_2)
- [**斯卡拉**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_scala_2)

  DataStream<T> input = ...;

  // event-time session windows with static gap
  input
  .keyBy(<key selector>)
  .window(EventTimeSessionWindows.withGap(Time.minutes(10)))
  .<windowed transformation>(<window function>);
    
  // event-time session windows with dynamic gap
  input
  .keyBy(<key selector>)
  .window(EventTimeSessionWindows.withDynamicGap((element) -> {
  // determine and return session gap
  }))
  .<windowed transformation>(<window function>);

  // processing-time session windows with static gap
  input
  .keyBy(<key selector>)
  .window(ProcessingTimeSessionWindows.withGap(Time.minutes(10)))
  .<windowed transformation>(<window function>);
    
  // processing-time session windows with dynamic gap
  input
  .keyBy(<key selector>)
  .window(ProcessingTimeSessionWindows.withDynamicGap((element) -> {
  // determine and return session gap
  }))
  .<windowed transformation>(<window function>);

静态间隙可以通过使用中的一个来指定`Time.milliseconds(x)`，`Time.seconds(x)`， `Time.minutes(x)`，等。

动态间隙是通过实现`SessionWindowTimeGapExtractor`接口指定的。

注意由于会话窗口没有固定的开始和结束，因此对它们的评估方式不同于滚动窗口和滑动窗口。在内部，会话窗口运算符会为每个到达的记录创建一个新窗口，如果窗口彼此之间的距离比已定义的间隔小，则将它们合并在一起。为了可合并的，会话窗口操作者需要一个合并[触发器](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#triggers)以及合并  [的窗函数](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#window-functions)，如`ReduceFunction`，`AggregateFunction`，或`ProcessWindowFunction` （`FoldFunction`不能合并。）

### 全球视窗

一个*全球性的窗口*分配器分配使用相同的密钥相同的单个的所有元素*全局窗口*。仅当您还指定自定义[触发器时，](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#triggers)此窗口方案才有用。否则，将不会执行任何计算，因为全局窗口没有可以处理聚合元素的自然终点。

![](https://ci.apache.org/projects/flink/flink-docs-release-1.10/fig/non-windowed.svg)

以下代码段显示了如何使用全局窗口。

- [**爪哇**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_java_3)
- [**斯卡拉**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_scala_3)

  DataStream<T> input = ...;

  input
  .keyBy(<key selector>)
  .window(GlobalWindows.create())
  .<windowed transformation>(<window function>);

## 视窗功能

定义窗口分配器后，我们需要指定要在每个窗口上执行的计算。这是*窗口函数*的职责，一旦系统确定某个窗口已准备好进行处理，就可以使用该*窗口函数*来处理每个（可能是键控）窗口的元素（请参阅 Flink 如何确定窗口准备就绪的[触发器](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#triggers)）。

的窗函数可以是一个`ReduceFunction`，`AggregateFunction`，`FoldFunction`或`ProcessWindowFunction`。前两个可以更有效地执行（请参阅“ [状态大小”](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#state%20size)部分），因为 Flink 可以在每个窗口到达时以递增方式聚合它们。A `ProcessWindowFunction`获取`Iterable`窗口中包含的所有元素的，以及有关元素所属窗口的其他元信息。

带 a 的窗口转换`ProcessWindowFunction`不能像其他情况一样有效地执行，因为 Flink 必须在调用函数之前在内部缓冲窗口的*所有*元素。这可以通过组合来减轻`ProcessWindowFunction`与`ReduceFunction`，`AggregateFunction`或`FoldFunction`以获得窗口元件的两个增量聚集和该附加元数据窗口  `ProcessWindowFunction`接收。我们将看每个变体的示例。

### Reduce 功能

A `ReduceFunction`指定如何将输入中的两个元素组合在一起以产生相同类型的输出元素。Flink 使用 a `ReduceFunction`来逐步聚合窗口的元素。

阿`ReduceFunction`可以定义像这样使用：

- [**爪哇**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_java_4)
- [**斯卡拉**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_scala_4)

  DataStream<Tuple2<String, Long>> input = ...;

  input
  .keyBy(<key selector>)
  .window(<window assigner>)
  .reduce(new ReduceFunction<Tuple2<String, Long>> {
  public Tuple2<String, Long> reduce(Tuple2<String, Long> v1, Tuple2<String, Long> v2) {
  return new Tuple2<>(v1.f0, v1.f1 + v2.f1);
  }
  });

上面的示例汇总了窗口中所有元素的元组的第二个字段。

### 聚合函数

一个`AggregateFunction`是一个一般化版本`ReduceFunction`，其具有三种类型：输入类型（`IN`），蓄压式（`ACC`），和一个输出类型（`OUT`）。输入类型是输入流中元素的类型，并且`AggregateFunction`具有将一个输入元素添加到累加器的方法。该接口还具有创建初始累加器，将两个累加器合并为一个累加器以及`OUT`从累加器提取输出（类型）的方法。我们将在下面的示例中看到它的工作原理。

与一样`ReduceFunction`，Flink 将在窗口输入元素到达时增量地聚合它们。

一个`AggregateFunction`可以被定义并这样使用：

- [**爪哇**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_java_5)
- [**斯卡拉**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_scala_5)

  /\*\*

  - The accumulator is used to keep a running sum and a count. The {@code getResult} method
  - computes the average.
    \*/
    private static class AverageAggregate
    implements AggregateFunction<Tuple2<String, Long>, Tuple2<Long, Long>, Double> {
    @Override
    public Tuple2<Long, Long> createAccumulator() {
    return new Tuple2<>(0L, 0L);
    }

  @Override
  public Tuple2<Long, Long> add(Tuple2<String, Long> value, Tuple2<Long, Long> accumulator) {
  return new Tuple2<>(accumulator.f0 + value.f1, accumulator.f1 + 1L);
  }

  @Override
  public Double getResult(Tuple2<Long, Long> accumulator) {
  return ((double) accumulator.f0) / accumulator.f1;
  }

  @Override
  public Tuple2<Long, Long> merge(Tuple2<Long, Long> a, Tuple2<Long, Long> b) {
  return new Tuple2<>(a.f0 + b.f0, a.f1 + b.f1);
  }
  }

  DataStream<Tuple2<String, Long>> input = ...;

  input
  .keyBy(<key selector>)
  .window(<window assigner>)
  .aggregate(new AverageAggregate());

上面的示例计算窗口中元素的第二个字段的平均值。

### 折叠功能

A `FoldFunction`指定如何将窗口的输入元素与输出类型的元素组合。所述`FoldFunction`递增称为该被添加到窗口和电流输出值的每个元素。第一个元素与输出类型的预定义初始值组合。

阿`FoldFunction`可以定义像这样使用：

- [**爪哇**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_java_6)
- [**斯卡拉**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_scala_6)

  DataStream<Tuple2<String, Long>> input = ...;

  input
  .keyBy(<key selector>)
  .window(<window assigner>)
  .fold("", new FoldFunction<Tuple2<String, Long>, String>> {
  public String fold(String acc, Tuple2<String, Long> value) {
  return acc + value.f1;
  }
  });

上面的示例将所有输入`Long`值附加到最初为空的`String`。

注意  `fold()`不能与会话窗口或其他可合并窗口一起使用。

### ProcessWindowFunction

ProcessWindowFunction 获取一个 Iterable，该 Iterable 包含窗口的所有元素，以及一个 Context 对象，该对象可以访问时间和状态信息，从而使其比其他窗口函数更具灵活性。这是以性能和资源消耗为代价的，因为不能增量聚合元素，而是需要在内部对其进行缓冲，直到认为该窗口已准备好进行处理为止。

`ProcessWindowFunction`look  的签名如下：

- [**爪哇**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_java_7)
- [**斯卡拉**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_scala_7)

  public abstract class ProcessWindowFunction<IN, OUT, KEY, W extends Window> implements Function {

      /**
       * Evaluates the window and outputs none or several elements.
       *
       * @param key The key for which this window is evaluated.
       * @param context The context in which the window is being evaluated.
       * @param elements The elements in the window being evaluated.
       * @param out A collector for emitting elements.
       *
       * @throws Exception The function may throw exceptions to fail the program and trigger recovery.
       */
      public abstract void process(
              KEY key,
              Context context,
              Iterable<IN> elements,
              Collector<OUT> out) throws Exception;

  /**
  _ The context holding window metadata.
  _/
  public abstract class Context implements java.io.Serializable {
  /**
  _ Returns the window that is being evaluated.
  _/
  public abstract W window();

  /\*_ Returns the current processing time. _/
  public abstract long currentProcessingTime();

  /\*_ Returns the current event-time watermark. _/
  public abstract long currentWatermark();

  /\*\*
  _ State accessor for per-key and per-window state.
  _
  _ <p><b>NOTE:</b>If you use per-window state you have to ensure that you clean it up
  _ by implementing {@link ProcessWindowFunction#clear(Context)}.
  \*/
  public abstract KeyedStateStore windowState();

  /\*\*
  _ State accessor for per-key global state.
  _/
  public abstract KeyedStateStore globalState();
  }

  }

注意：该`key`参数是通过提取的关键`KeySelector`是被指定的`keyBy()`调用。如果是元组索引键或字符串字段引用，则始终使用此键类型，`Tuple`并且必须手动将其强制转换为正确大小的元组以提取键字段。

阿`ProcessWindowFunction`可以定义像这样使用：

- [**爪哇**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_java_8)
- [**斯卡拉**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_scala_8)

  DataStream<Tuple2<String, Long>> input = ...;

  input
  .keyBy(t -> t.f0)
  .timeWindow(Time.minutes(5))
  .process(new MyProcessWindowFunction());

  /_ ... _/

  public class MyProcessWindowFunction
  extends ProcessWindowFunction<Tuple2<String, Long>, String, String, TimeWindow> {

  @Override
  public void process(String key, Context context, Iterable<Tuple2<String, Long>> input, Collector<String> out) {
  long count = 0;
  for (Tuple2<String, Long> in: input) {
  count++;
  }
  out.collect("Window: " + context.window() + "count: " + count);
  }
  }

该示例显示了一个`ProcessWindowFunction`计算窗口中元素的方法。另外，窗口功能将有关窗口的信息添加到输出中。

注意请注意，`ProcessWindowFunction`用于简单的聚合（例如 count）效率很低。下一部分说明如何将`ReduceFunction`或`AggregateFunction`与或结合使用，以`ProcessWindowFunction`同时获得增量聚合和的附加信息`ProcessWindowFunction`。

### 具有增量聚合的 ProcessWindowFunction

`ProcessWindowFunction`可以将 A  与 a `ReduceFunction`，an `AggregateFunction`或 a  组合以在`FoldFunction`元素到达窗口时对其进行递增聚合。当窗口关闭时，`ProcessWindowFunction`将提供汇总结果。这样一来，它就可以增量计算窗口，同时可以访问的其他窗口元信息`ProcessWindowFunction`。

注意您也可以使用旧版`WindowFunction`而不是  `ProcessWindowFunction`用于增量窗口聚合。

#### 具有 ReduceFunction 的增量窗口聚合

以下示例显示了如何将增量`ReduceFunction`与 a 组合`ProcessWindowFunction`以返回窗口中的最小事件以及该窗口的开始时间。

- [**爪哇**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_java_9)
- [**斯卡拉**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_scala_9)

  DataStream<SensorReading> input = ...;

  input
  .keyBy(<key selector>)
  .timeWindow(<duration>)
  .reduce(new MyReduceFunction(), new MyProcessWindowFunction());

  // Function definitions

  private static class MyReduceFunction implements ReduceFunction<SensorReading> {

  public SensorReading reduce(SensorReading r1, SensorReading r2) {
  return r1.value() > r2.value() ? r2 : r1;
  }
  }

  private static class MyProcessWindowFunction
  extends ProcessWindowFunction<SensorReading, Tuple2<Long, SensorReading>, String, TimeWindow> {

  public void process(String key,
  Context context,
  Iterable<SensorReading> minReadings,
  Collector<Tuple2<Long, SensorReading>> out) {
  SensorReading min = minReadings.iterator().next();
  out.collect(new Tuple2<Long, SensorReading>(context.window().getStart(), min));
  }
  }

#### 具有 AggregateFunction 的增量窗口聚合

以下示例显示了如何将增量`AggregateFunction`与 a 组合`ProcessWindowFunction`以计算平均值，并与平均值一起发出键和窗口。

- [**爪哇**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_java_10)
- [**斯卡拉**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_scala_10)

  DataStream<Tuple2<String, Long>> input = ...;

  input
  .keyBy(<key selector>)
  .timeWindow(<duration>)
  .aggregate(new AverageAggregate(), new MyProcessWindowFunction());

  // Function definitions

  /\*\*

  - The accumulator is used to keep a running sum and a count. The {@code getResult} method
  - computes the average.
    \*/
    private static class AverageAggregate
    implements AggregateFunction<Tuple2<String, Long>, Tuple2<Long, Long>, Double> {
    @Override
    public Tuple2<Long, Long> createAccumulator() {
    return new Tuple2<>(0L, 0L);
    }

  @Override
  public Tuple2<Long, Long> add(Tuple2<String, Long> value, Tuple2<Long, Long> accumulator) {
  return new Tuple2<>(accumulator.f0 + value.f1, accumulator.f1 + 1L);
  }

  @Override
  public Double getResult(Tuple2<Long, Long> accumulator) {
  return ((double) accumulator.f0) / accumulator.f1;
  }

  @Override
  public Tuple2<Long, Long> merge(Tuple2<Long, Long> a, Tuple2<Long, Long> b) {
  return new Tuple2<>(a.f0 + b.f0, a.f1 + b.f1);
  }
  }

  private static class MyProcessWindowFunction
  extends ProcessWindowFunction<Double, Tuple2<String, Double>, String, TimeWindow> {

  public void process(String key,
  Context context,
  Iterable<Double> averages,
  Collector<Tuple2<String, Double>> out) {
  Double average = averages.iterator().next();
  out.collect(new Tuple2<>(key, average));
  }
  }

#### 具有 FoldFunction 的增量窗口聚合

以下示例显示了如何将增量`FoldFunction`与组合`ProcessWindowFunction`以提取窗口中的事件数，并还返回窗口的键和结束时间。

- [**爪哇**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_java_11)
- [**斯卡拉**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_scala_11)

  DataStream<SensorReading> input = ...;

  input
  .keyBy(<key selector>)
  .timeWindow(<duration>)
  .fold(new Tuple3<String, Long, Integer>("",0L, 0), new MyFoldFunction(), new MyProcessWindowFunction())

  // Function definitions

  private static class MyFoldFunction
  implements FoldFunction<SensorReading, Tuple3<String, Long, Integer> > {

  public Tuple3<String, Long, Integer> fold(Tuple3<String, Long, Integer> acc, SensorReading s) {
  Integer cur = acc.getField(2);
  acc.setField(cur + 1, 2);
  return acc;
  }
  }

  private static class MyProcessWindowFunction
  extends ProcessWindowFunction<Tuple3<String, Long, Integer>, Tuple3<String, Long, Integer>, String, TimeWindow> {

  public void process(String key,
  Context context,
  Iterable<Tuple3<String, Long, Integer>> counts,
  Collector<Tuple3<String, Long, Integer>> out) {
  Integer count = counts.iterator().next().getField(2);
  out.collect(new Tuple3<String, Long, Integer>(key, context.window().getEnd(),count));
  }
  }

### 在 ProcessWindowFunction 中使用每个窗口状态

除了访问键控状态（如任何丰富功能所允许的那样），a `ProcessWindowFunction`还可以使用键控状态，该键控状态的范围仅限于该函数当前正在处理的窗口。在这种情况下，重要的是要了解*每个窗口*状态所指*的窗口*是什么。涉及不同的“窗口”：

- 指定窗口操作时定义的窗口：这可能是*1 小时的翻滚窗口*或*2 小时的滑动窗口滑动 1 小时*。
- 给定键的已定义窗口的实际实例：*对于用户 ID xyz，*这可能是*从 12:00 到 13:00 的时间窗口*。这是基于窗口定义的，并且基于作业当前正在处理的键的数量以及事件属于哪个时隙，将有许多窗口。

每个窗口的状态与这两个中的后者相关。这意味着，如果我们处理 1000 个不同键的事件，并且当前所有事件的事件都落在*\[12:00，13:00）*时间窗口中，那么将有 1000 个窗口实例，每个实例具有各自的每个窗口状态。

调用收到的`Context`对象上有两种方法`process()`可以访问两种状态：

- `globalState()`，它允许访问不在窗口范围内的键状态
- `windowState()`，它允许访问也作用于窗口的键控状态

如果您预期同一窗口会多次触发，则此功能很有用，例如，对于迟到的数据有较晚的触发，或者您有进行推测性较早触发的自定义触发器时，可能会发生这种情况。在这种情况下，您将存储有关先前触发或每个窗口状态中触发次数的信息。

使用窗口状态时，清除窗口时也要清除该状态，这一点很重要。这应该在`clear()`方法中发生。

### WindowFunction（旧版）

在某些`ProcessWindowFunction`可以使用 a 的地方，您也可以使用 a `WindowFunction`。这是旧版本`ProcessWindowFunction`，提供较少的上下文信息，并且没有某些高级功能，例如每个窗口的键状态。该接口将在某个时候被弃用。

a 的签名`WindowFunction`如下：

- [**爪哇**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_java_12)
- [**斯卡拉**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_scala_12)

  public interface WindowFunction<IN, OUT, KEY, W extends Window> extends Function, Serializable {

  /\*\*

  - Evaluates the window and outputs none or several elements.
  -
  - @param key The key for which this window is evaluated.
  - @param window The window that is being evaluated.
  - @param input The elements in the window being evaluated.
  - @param out A collector for emitting elements.
  -
  - @throws Exception The function may throw exceptions to fail the program and trigger recovery.
    \*/
    void apply(KEY key, W window, Iterable<IN> input, Collector<OUT> out) throws Exception;
    }

可以这样使用：

- [**爪哇**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_java_13)
- [**斯卡拉**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_scala_13)

  DataStream<Tuple2<String, Long>> input = ...;

  input
  .keyBy(<key selector>)
  .window(<window assigner>)
  .apply(new MyWindowFunction());

## 扳机

A `Trigger`确定窗口（由*窗口分配器*形成）何时准备好由*窗口函数处理*。每个`WindowAssigner`都有一个默认值`Trigger`。如果默认触发器不符合您的需求，则可以使用指定自定义触发器`trigger(...)`。

触发器接口具有五种方法，它们允许 a `Trigger`对不同事件做出反应：

- `onElement()`对于添加到窗口中的每个元素，都会调用该方法。
- `onEventTime()`当注册的事件时间计时器触发时，将调用该方法。
- `onProcessingTime()`当注册的处理时间计时器触发时，将调用该方法。
- 该`onMerge()`方法与有状态触发器相关，并且在两个触发器的相应窗口合并时（*例如，*在使用会话窗口时）合并两个触发器的状态。
- 最终，该`clear()`方法执行删除相应窗口后所需的任何操作。

关于上述方法，需要注意两件事：

1）前三个通过返回 a 来决定如何对调用事件采取行动`TriggerResult`。该动作可以是以下之一：

- `CONTINUE`： 没做什么，
- `FIRE`：触发计算，
- `PURGE`：清除窗口中的元素，然后
- `FIRE_AND_PURGE`：触发计算并随后清除窗口中的元素。

2）这些方法中的任何一种都可以用于注册处理或事件时间计时器以用于将来的操作。

### 火与净化

一旦触发器确定窗口已准备好进行处理，它将触发，*即*返回`FIRE`或`FIRE_AND_PURGE`。这是窗口运算符发出当前窗口结果的信号。给定一个包含`ProcessWindowFunction`  所有元素的窗口，则将其传递给`ProcessWindowFunction`（可能是在将它们传递给逐出者之后）。带有`ReduceFunction`，`AggregateFunction`或的 Windows `FoldFunction`只会发出热切的汇总结果。

当触发器触发时，它可以是`FIRE`或`FIRE_AND_PURGE`。在`FIRE`保留窗口内容的同时，`FIRE_AND_PURGE`删除其内容。默认情况下，预先实现的触发器仅在`FIRE`不清除窗口状态的情况下触发。

注意清除将仅删除窗口的内容，并将保留有关该窗口的任何潜在元信息和任何触发状态。

### WindowAssigners 的默认触发器

默认`Trigger`的`WindowAssigner`是适用于许多使用情况。例如，所有事件时间窗口分配器都有`EventTimeTrigger`默认触发器。一旦水印通过窗口的末端，此触发器便会触发。

注意的默认触发器`GlobalWindow`是`NeverTrigger`永不触发的。因此，使用时，您始终必须定义一个自定义触发器`GlobalWindow`。

注意通过使用指定触发器，`trigger()`您将覆盖的默认触发器`WindowAssigner`。例如，如果您指定为  `CountTrigger`，则`TumblingEventTimeWindows`您将不再基于时间进度而是仅通过计数获得窗口触发。现在，如果要基于时间和计数做出反应，则必须编写自己的自定义触发器。

### 内置和自定义触发器

Flink 带有一些内置触发器。

- （已经提到）`EventTimeTrigger`根据事件时间（由水印测量）的进度触发。
- 在`ProcessingTimeTrigger`基于处理时间的火灾。
- `CountTrigger`一旦窗口中的元素数量超过给定的限制，就会触发。
- 在`PurgingTrigger`采用作为参数另一触发并将其转换为一个吹扫之一。

如果需要实现自定义触发器，则应签出抽象的  [Trigger](https://github.com/apache/flink/blob/master//flink-streaming-java/src/main/java/org/apache/flink/streaming/api/windowing/triggers/Trigger.java)类。请注意，API 仍在不断发展，并可能在 Flink 的未来版本中更改。

## 驱逐者

Flink 的窗口模型允许`Evictor`除了`WindowAssigner`和之外还指定一个可选内容`Trigger`。可以使用`evictor(...)`方法完成（如本文档开头所示）。所述逐出器必须从一个窗口中删除元素的能力*之后*触发器触发和*之前和/或之后*被施加的窗口函数。为此，该`Evictor`接口有两种方法：

    /**
     * Optionally evicts elements. Called before windowing function.
     *
     * @param elements The elements currently in the pane.
     * @param size The current number of elements in the pane.
     * @param window The {@link Window}
     * @param evictorContext The context for the Evictor
     */
    void evictBefore(Iterable<TimestampedValue<T>> elements, int size, W window, EvictorContext evictorContext);

    /**
     * Optionally evicts elements. Called after windowing function.
     *
     * @param elements The elements currently in the pane.
     * @param size The current number of elements in the pane.
     * @param window The {@link Window}
     * @param evictorContext The context for the Evictor
     */
    void evictAfter(Iterable<TimestampedValue<T>> elements, int size, W window, EvictorContext evictorContext);

在`evictBefore()`包含窗口函数之前被施加驱逐逻辑，而`evictAfter()`  包含窗口函数之后要施加的一个。应用窗口功能之前逐出的元素将不会被其处理。

Flink 附带了三个预先实施的驱逐程序。这些是：

- `CountEvictor`：从窗口中保留用户指定数量的元素，并从窗口缓冲区的开头丢弃其余的元素。
- `DeltaEvictor`：使用 a `DeltaFunction`和 a `threshold`，计算窗口缓冲区中最后一个元素与其余每个元素之间的差值，并删除差值大于或等于阈值的那些值。
- `TimeEvictor`：以`interval`毫秒为单位作为参数，对于给定的窗口，它将`max_ts`在其元素中找到最大时间戳，并删除所有时间戳小于的元素`max_ts - interval`。

默认默认情况下，所有预先实现的驱逐程序均在窗口函数之前应用其逻辑。

注意指定退出者可防止任何预聚合，因为在应用计算之前必须将窗口的所有元素传递给退出者。

注意  Flink 不保证窗口中元素的顺序。这意味着，尽管退出者可以从窗口的开头删除元素，但是这些元素不一定是第一个或最后一个到达的元素。

## 允许延迟

在使用*事件时间*窗口时，可能会发生元素到达较晚的情况，*即* Flink 用于跟踪事件时间进度的水印已经超过了元素所属窗口的结束时间戳。请参阅  [事件时间](https://ci.apache.org/projects/flink/flink-docs-release-1.10/dev/event_time.html)，尤其是[后期元素](https://ci.apache.org/projects/flink/flink-docs-release-1.10/dev/event_time.html#late-elements)，以更全面地讨论 Flink 如何处理事件时间。

默认情况下，当水印超过窗口结尾时，将删除晚期元素。但是，Flink 允许为窗口运算符指定最大*允许延迟*。允许延迟指定元素删除之前可以延迟的时间，其默认值为 0。在水印通过窗口末端之后但在通过窗口末端之前到达的元素加上允许延迟，仍添加到窗口中。根据使用的触发器，延迟但未掉落的元素可能会导致窗口再次触发。的情况就是这样`EventTimeTrigger`。

为了使此工作正常进行，Flink 保持窗口的状态，直到允许的延迟过期为止。一旦发生这种情况，Flink 将删除该窗口并删除其状态，如“ [窗口生命周期”](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#window-lifecycle)部分中所述。

默认默认情况下，允许的延迟设置为  `0`。也就是说，到达水印后的元素将被丢弃。

您可以这样指定允许的延迟：

- [**爪哇**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_java_14)
- [**斯卡拉**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_scala_14)

  DataStream<T> input = ...;

  input
  .keyBy(<key selector>)
  .window(<window assigner>)
  .allowedLateness(<time>)
  .<windowed transformation>(<window function>);

注意使用`GlobalWindows`窗口分配器时，永远不会考虑任何数据，因为全局窗口的结束时间戳为`Long.MAX_VALUE`。

### 获取最新数据作为侧面输出

使用 Flink 的[侧面输出](https://ci.apache.org/projects/flink/flink-docs-release-1.10/dev/stream/side_output.html)功能，您可以获取最近被丢弃的数据流。

首先，您需要指定要`sideOutputLateData(OutputTag)`在窗口流上使用的较晚数据。然后，您可以根据窗口化操作的结果获取侧面输出流：

- [**爪哇**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_java_15)
- [**斯卡拉**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_scala_15)

  final OutputTag<T> lateOutputTag = new OutputTag<T>("late-data"){};

  DataStream<T> input = ...;

  SingleOutputStreamOperator<T> result = input
  .keyBy(<key selector>)
  .window(<window assigner>)
  .allowedLateness(<time>)
  .sideOutputLateData(lateOutputTag)
  .<windowed transformation>(<window function>);

  DataStream<T> lateStream = result.getSideOutput(lateOutputTag);

### 后期元素注意事项

当指定的允许延迟大于 0 时，在水印通过窗口末尾之后，将保留窗口及其内容。在这些情况下，当延迟但未丢弃的元素到达时，可能会触发该窗口的另一次触发。这些触发称为`late firings`，因为它们是由较晚的事件触发的，与之相反的`main firing`  是窗口的第一次触发。对于会话窗口，后期触发会进一步导致窗口合并，因为它们可能“弥合”两个预先存在的未合并窗口之间的间隙。

注意您应注意，后期触发发射的元素应被视为先前计算的更新结果，即，您的数据流将包含同一计算的多个结果。根据您的应用程序，您需要考虑这些重复的结果或对它们进行重复数据删除。

## 处理窗口结果

窗口化操作的结果再次是 a `DataStream`，结果元素中没有保留任何有关窗口化操作的信息，因此，如果要保留有关窗口的元信息，则必须在的结果元素中手动编码该信息  `ProcessWindowFunction`。在结果元素上设置的唯一相关信息是元素*timestamp*。设置为已处理窗口的最大允许时间戳，即*结束时间戳-1*，因为窗口结束时间戳是唯一的。请注意，对于事件时间窗口和处理时间窗口都是如此。也就是说，在窗口操作元素之后始终具有时间戳，但这可以是事件时间时间戳或处理时间时间戳。对于处理时间窗口，这没有特殊的含义，但是对于事件时间窗口，这连同水印与窗口的交互方式一起，可以以相同的窗口大小进行  [连续的窗口操作](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#consecutive-windowed-operations)。在查看水印如何与窗口交互之后，我们将进行介绍。

### 水印和窗户的相互作用

在继续本节之前，您可能需要看一下有关  [事件时间和水印的部分](https://ci.apache.org/projects/flink/flink-docs-release-1.10/dev/event_time.html)。

当水印到达窗口运算符时，将触发两件事：

- 水印会触发所有最大时间戳（即*end-stamp-1*）小于新水印的所有窗口的计算
- 水印被（按原样）转发给下游操作

直观地，一旦下游操作收到水印后，水印就会“溢出”所有在下游操作中被认为是后期的窗口。

### 连续窗口操作

如前所述，计算窗口结果时间戳的方式以及水印与窗口的交互方式可将连续的窗口操作串在一起。当您要执行两个连续的窗口化操作时，如果要使用不同的键，但仍希望来自同一上游窗口的元素最终位于同一下游窗口中，此功能将非常有用。考虑以下示例：

- [**爪哇**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_java_16)
- [**斯卡拉**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#tab_scala_16)

  DataStream<Integer> input = ...;

  DataStream<Integer> resultsPerKey = input
  .keyBy(<key selector>)
  .window(TumblingEventTimeWindows.of(Time.seconds(5)))
  .reduce(new Summer());

  DataStream<Integer> globalResults = resultsPerKey
  .windowAll(TumblingEventTimeWindows.of(Time.seconds(5)))
  .process(new TopKWindowFunction());

在此示例中，`[0, 5)`第一个操作的时间窗口结果也将`[0, 5)`在随后的窗口化操作的时间窗口中结束。这允许计算每个键的总和，然后在第二个操作中计算同一窗口内的前 k 个元素。

## 有用的州规模考虑

Windows 可以定义很长时间（例如几天，几周或几个月），因此会累积很大的状态。在估算窗口计算的存储需求时，需要牢记一些规则：

1.  Flink 为每个元素所属的窗口创建一个副本。鉴于此，滚动窗口保留每个元素的一个副本（一个元素恰好属于一个窗口，除非它被延迟放置）。相反，滑动窗口会为每个元素创建多个元素，如“ [窗口分配器”](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#window-assigners)部分所述。因此，大小为 1 天的滑动窗口和滑动 1 秒的滑动窗口可能不是一个好主意。

2.  `ReduceFunction`，，`AggregateFunction`和`FoldFunction`可以大大减少存储需求，因为它们热切地聚合元素并且每个窗口仅存储一个值。相反，仅使用 a `ProcessWindowFunction`需要累积所有元素。

3.  使用`Evictor`防止了任何预聚合，作为窗口的所有元件必须通过逐出器施加的计算（参见前通过[逐出器](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html#evictors)）。
