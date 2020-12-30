# 事件时间

在本节中，你将学习编写可感知时间变化（time-aware）的 Flink 程序。可以参阅[实时流处理](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/concepts/timely-stream-processing.html)小节以了解实时流处理的概念。

有关如何在 Flink 程序中使用时间特性，请参阅[窗口](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/operators/windows.html)和 [ProcessFunction](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/operators/process_function.html) 小节。

使用*事件时间*处理数据之前需要在程序中设置正确的*时间语义*。此项设置会定义源数据的处理方式（例如：程序是否会对数据分配时间戳），以及程序应使用什么时间语义执行 `KeyedStream.window(TumblingEventTimeWindows.of(Time.seconds(30)))` 之类的窗口操作。

可以通过 `StreamExecutionEnvironment.setStreamTimeCharacteristic()` 设置程序的时间语义，示例如下：

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/event_time.html#tab_Java_0)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/event_time.html#tab_Scala_0)
- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/event_time.html#tab_Python_0)

```
final StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

env.setStreamTimeCharacteristic(TimeCharacteristic.EventTime);

DataStream<MyEvent> stream = env.addSource(new FlinkKafkaConsumer<MyEvent>(topic, schema, props));

stream
    .keyBy( (event) -> event.getUser() )
    .window(TumblingEventTimeWindows.of(Time.hours(1)))
    .reduce( (a, b) -> a.add(b) )
    .addSink(...);
```

注意：为了以*事件时间*的语义运行上述示例，程序需要满足下列其中一种条件，要么其消费的数据源直接为其数据定义了事件时间并且可以发出 watermark，要么程序必须在数据源之后显示声明*时间戳分配器和 Watermark 生成器*（*Timestamp Assigner＆Watermark Generator*）。这些函数可以定义 Flink 程序如何获取到事件时间戳以及定义事件流的乱序程度。

## 接下来学习的内容？

- [生成 Watermark](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/event_timestamps_watermarks.html)：展示如何编写 Flink 应用程序感知事件时间所必需的时间戳分配器和 watermark 生成器。
- [内置 Watermark 生成器](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/event_timestamp_extractors.html)：概述了 Flink 框架内置的 watermark 生成器。
- [调试窗口和事件时间](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/ops/debugging/debugging_event_time.html)：展示如何在含有事件时间语义的 Flink 应用程序中调试 watermark 和时间戳相关的问题。