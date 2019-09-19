# Pre-defined Timestamp Extractors / Watermark Emitters
正如在时间戳和水印处理中描述的，Flink提供了抽象，允许程序员分配自己的时间戳并发出自己的水印。更具体地说，可以通过实现一个assignerwithperiodic水印和assignerwith标点水印接口来实现，这取决于用例。简而言之，第一种方法会周期性地发出水印，而第二种方法则会根据传入记录的某些属性来发出水印，例如当流中遇到特殊元素时。

为了进一步简化此类任务的编程工作，Flink附带了一些预先实现的时间戳分配程序。本节提供了它们的列表。除了它们的开箱即用功能之外，它们的实现还可以作为定制实现的示例。

## Assigners with ascending timestamps

周期水印生成最简单的特殊情况是给定源任务看到的时间戳按升序出现。在这种情况下，当前时间戳始终可以作为水印，因为不会到达更早的时间戳。

注意，只需要对每个并行数据源任务升序执行时间戳。例如，如果在特定的设置中，一个并行数据源实例读取一个Kafka分区，那么只需要在每个Kafka分区中升序执行时间戳。Flink的水印合并机制将生成正确的水印时，并行流洗牌，统一，连接，或合并。

```java
DataStream<MyEvent> stream = ...

DataStream<MyEvent> withTimestampsAndWatermarks =
    stream.assignTimestampsAndWatermarks(new AscendingTimestampExtractor<MyEvent>() {

        @Override
        public long extractAscendingTimestamp(MyEvent element) {
            return element.getCreationTime();
        }
});
```

## Assigners allowing a fixed amount of lateness

周期水印生成的另一个例子是，当水印滞后于流中看到的最大(事件时间)时间戳一定时间时。这种情况包括这样的场景:流中可能遇到的最大延迟是预先知道的，例如，当创建一个包含元素的自定义源时，这些元素的时间戳在固定的测试时间内展开。对于这些情况，Flink提供了BoundedOutOfOrdernessTimestampExtractor，它将maxoutofor细比作为参数，也就是说，当计算给定窗口的最终结果时，一个元素在被忽略之前允许延迟的最大时间量。延迟对应于t- t_w的结果，其中t是一个元素的(事件时间)时间戳，t_w是前一个水印的时间戳。如果延迟为>，则该元素被认为是延迟，并且在计算对应窗口的作业结果时，默认忽略该元素。有关处理延迟元素的更多信息，请参阅有关允许延迟的文档。

```java
DataStream<MyEvent> stream = ...

DataStream<MyEvent> withTimestampsAndWatermarks =
    stream.assignTimestampsAndWatermarks(new BoundedOutOfOrdernessTimestampExtractor<MyEvent>(Time.seconds(10)) {

        @Override
        public long extractTimestamp(MyEvent element) {
            return element.getCreationTime();
        }
});
```