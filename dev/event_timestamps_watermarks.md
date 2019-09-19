# Generating Timestamps / Watermarks
本节与在事件时间运行的程序相关。有关事件时间、处理时间和摄入时间的介绍，请参阅事件时间介绍。

为了处理事件时间，流媒体程序需要相应地设置时间特性。

```java
final StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
env.setStreamTimeCharacteristic(TimeCharacteristic.EventTime);
```

## Assigning Timestamps

为了处理事件时间，Flink需要知道事件的时间戳，这意味着流中的每个元素都需要分配其事件时间戳。这通常通过访问/从元素中的某个字段中提取时间戳来实现。

时间戳分配与生成水印密切相关，后者告诉系统事件时间的进展情况。

有两种方法来分配时间戳和生成水印:

1. 直接在数据流源中
2. 通过时间戳分配程序/水印生成器:在Flink中，时间戳分配程序还定义要发出的水印

注意，从1970-01-01T00:00:00Z的Java纪元开始，时间戳和水印都指定为毫秒。

### Source Functions with Timestamps and Watermarks
流源可以直接为它们生成的元素分配时间戳，还可以发出水印。完成此操作后，不需要时间戳分配程序。注意，如果使用时间戳转让者，则会覆盖源提供的任何时间戳和水印。

要直接向源中的元素分配时间戳，源必须在SourceContext上使用collectWithTimestamp(…)方法。要生成水印，源程序必须调用emit水印(水印)函数。

下面是一个分配时间戳和生成水印的(非检查点)源的简单示例:

```java
@Override
public void run(SourceContext<MyType> ctx) throws Exception {
	while (/* condition */) {
		MyType next = getNext();
		ctx.collectWithTimestamp(next, next.getEventTimestamp());

		if (next.hasWatermarkTime()) {
			ctx.emitWatermark(new Watermark(next.getWatermarkTime()));
		}
	}
}
```

### Timestamp Assigners / Watermark Generators

时间戳分配程序获取一个流并生成一个带有时间戳元素和水印的新流。如果原始流已经具有时间戳和/或水印，则时间戳分配者将覆盖它们。

时间戳分配程序通常在数据源之后立即指定，但并不严格要求这样做。例如，一个常见的模式是在时间戳分配程序之前解析(MapFunction)和筛选(FilterFunction)。在任何情况下，需要在事件时间的第一个操作之前指定时间戳分配程序(例如第一个窗口操作)。作为一种特殊情况，当使用Kafka作为流作业的源时，Flink允许在源(或消费者)内部指定时间戳分配者/水印发射器。有关如何做到这一点的更多信息可以在Kafka连接器文档中找到。

注意:本节的其余部分介绍了程序员必须实现的主要接口，以便创建自己的时间戳提取器/水印发射器。要查看附带Flink的预实现提取器，请参阅预定义时间戳提取器/水印发射器页面。

```java
final StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
env.setStreamTimeCharacteristic(TimeCharacteristic.EventTime);

DataStream<MyEvent> stream = env.readFile(
        myFormat, myFilePath, FileProcessingMode.PROCESS_CONTINUOUSLY, 100,
        FilePathFilter.createDefaultFilter(), typeInfo);

DataStream<MyEvent> withTimestampsAndWatermarks = stream
        .filter( event -> event.severity() == WARNING )
        .assignTimestampsAndWatermarks(new MyTimestampsAndWatermarks());

withTimestampsAndWatermarks
        .keyBy( (event) -> event.getGroup() )
        .timeWindow(Time.seconds(10))
        .reduce( (a, b) -> a.add(b) )
        .addSink(...);
```


#### With Periodic Watermarks

使用periodic水印的assignerwithperiodic水印分配时间戳并定期生成水印(可能取决于流元素，或者纯粹基于处理时间)。

水印生成的间隔(每n毫秒)由ExecutionConfig.setAutoWatermarkInterval(…)定义。每次都会调用转让者的getCurrentWatermark()方法，如果返回的水印是非空的且比前一个水印大，则会发出一个新的水印。

这里我们展示了两个使用周期性水印生成的时间戳分配程序的简单示例。注意，Flink附带了一个BoundedOutOfOrdernessTimestampExtractor，类似于下面所示的BoundedOutOfOrdernessGenerator，您可以在这里阅读相关内容。

```java
/**
 * This generator generates watermarks assuming that elements arrive out of order,
 * but only to a certain degree. The latest elements for a certain timestamp t will arrive
 * at most n milliseconds after the earliest elements for timestamp t.
 */
public class BoundedOutOfOrdernessGenerator implements AssignerWithPeriodicWatermarks<MyEvent> {

    private final long maxOutOfOrderness = 3500; // 3.5 seconds

    private long currentMaxTimestamp;

    @Override
    public long extractTimestamp(MyEvent element, long previousElementTimestamp) {
        long timestamp = element.getCreationTime();
        currentMaxTimestamp = Math.max(timestamp, currentMaxTimestamp);
        return timestamp;
    }

    @Override
    public Watermark getCurrentWatermark() {
        // return the watermark as current highest timestamp minus the out-of-orderness bound
        return new Watermark(currentMaxTimestamp - maxOutOfOrderness);
    }
}

/**
 * This generator generates watermarks that are lagging behind processing time by a fixed amount.
 * It assumes that elements arrive in Flink after a bounded delay.
 */
public class TimeLagWatermarkGenerator implements AssignerWithPeriodicWatermarks<MyEvent> {

	private final long maxTimeLag = 5000; // 5 seconds

	@Override
	public long extractTimestamp(MyEvent element, long previousElementTimestamp) {
		return element.getCreationTime();
	}

	@Override
	public Watermark getCurrentWatermark() {
		// return the watermark as current time minus the maximum time lag
		return new Watermark(System.currentTimeMillis() - maxTimeLag);
	}
}

```

#### With Punctuated Watermarks

当某个事件表明可能生成新水印时，要生成水印，请使用assignerwith标点水印。对于这个类，Flink将首先调用extractTimestamp(…)方法来为元素分配一个时间戳，然后立即调用该元素上的checkAndGetNextWatermark(…)方法。

checkAndGetNextWatermark(…)方法传递extractTimestamp(…)方法中分配的时间戳，并可以决定是否要生成水印。每当checkAndGetNextWatermark(…)方法返回一个非空水印，并且该水印大于最新的前一个水印时，就会发出该新水印。

```java
public class PunctuatedAssigner implements AssignerWithPunctuatedWatermarks<MyEvent> {

	@Override
	public long extractTimestamp(MyEvent element, long previousElementTimestamp) {
		return element.getCreationTime();
	}

	@Override
	public Watermark checkAndGetNextWatermark(MyEvent lastElement, long extractedTimestamp) {
		return lastElement.hasWatermarkMarker() ? new Watermark(extractedTimestamp) : null;
	}
}
```

注意:可以在每个事件上生成水印。然而，由于每个水印都会导致下游的一些计算，过多的水印会降低性能。

## Timestamps per Kafka Partition
当使用Apache Kafka作为数据源时，每个Kafka分区可能有一个简单的事件时间模式(升序时间戳或有界外长细)。然而，当使用Kafka的流时，多个分区经常被并行地使用，交叉使用分区中的事件并破坏每个分区的模式(这是Kafka的消费者客户端工作的固有方式)。

在这种情况下，您可以使用Flink的kafka - partii感知水印生成。使用该特性，每个Kafka分区都会在Kafka使用者内部生成水印，每个分区的水印会以与流变换中合并水印相同的方式合并。

例如，如果事件时间戳严格按照Kafka分区升序，那么使用升序时间戳水印生成器生成每个分区的水印将得到完美的整体水印。

下面的插图展示了如何使用每卡夫卡分区生成水印，以及在这种情况下，水印如何通过流数据流传播。

```java
FlinkKafkaConsumer09<MyType> kafkaSource = new FlinkKafkaConsumer09<>("myTopic", schema, props);
kafkaSource.assignTimestampsAndWatermarks(new AscendingTimestampExtractor<MyType>() {

    @Override
    public long extractAscendingTimestamp(MyType element) {
        return element.eventTimestamp();
    }
});

DataStream<MyType> stream = env.addSource(kafkaSource);
```

![parallel_kafka_watermarks](../images/parallel_kafka_watermarks.svg)

