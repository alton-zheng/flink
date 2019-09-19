# Flink DataStream API 编程指南

通常，这些问题可以通过多种方式解决:Flink中的DataStream程序是对数据流实现转换的常规程序(例如，过滤、更新状态、定义窗口、聚合)。数据流最初是由不同的源创建的(例如，消息队列、套接字流、文件)。结果通过接收器返回，例如，接收器可以将数据写入文件或标准输出(例如命令行终端)。Flink程序在各种上下文中运行，独立运行或嵌入到其他程序中。执行可以在本地JVM中进行，也可以在许多机器的集群上进行。

有关Flink API的基本概念的介绍，请参阅[基本概念](api_concepts.md)。

为了创建您自己的Flink DataStream程序，我们鼓励您从[剖析Flink程序](api_concepts.md#anatomy-of-a-flink-program)开始，并逐步添加您自己的[stream transformations](../dev/stream/operators/index.md)。其余部分作为其他操作和高级特性的参考。

## Example Program

下面的程序是一个完整的、可工作的流窗口单词计数应用程序示例，它在5秒内计算来自web套接字的单词。您可以复制并粘贴代码以在本地运行它。

- Java
```java
import org.apache.flink.api.common.functions.FlatMapFunction;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.windowing.time.Time;
import org.apache.flink.util.Collector;

public class WindowWordCount {

    public static void main(String[] args) throws Exception {

        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

        DataStream<Tuple2<String, Integer>> dataStream = env
                .socketTextStream("localhost", 9999)
                .flatMap(new Splitter())
                .keyBy(0)
                .timeWindow(Time.seconds(5))
                .sum(1);

        dataStream.print();

        env.execute("Window WordCount");
    }

    public static class Splitter implements FlatMapFunction<String, Tuple2<String, Integer>> {
        @Override
        public void flatMap(String sentence, Collector<Tuple2<String, Integer>> out) throws Exception {
            for (String word: sentence.split(" ")) {
                out.collect(new Tuple2<String, Integer>(word, 1));
            }
        }
    }

}
```

- Scala
```scala
import org.apache.flink.streaming.api.scala._
import org.apache.flink.streaming.api.windowing.time.Time

object WindowWordCount {
  def main(args: Array[String]) {

    val env = StreamExecutionEnvironment.getExecutionEnvironment
    val text = env.socketTextStream("localhost", 9999)

    val counts = text.flatMap { _.toLowerCase.split("\\W+") filter { _.nonEmpty } }
      .map { (_, 1) }
      .keyBy(0)
      .timeWindow(Time.seconds(5))
      .sum(1)

    counts.print()

    env.execute("Window Stream WordCount")
  }
}
```

要运行示例程序，首先从终端用netcat启动输入流:

```bash
nc -lk 9999
```

只要输入一些单词，按回车键输入一个新单词。这些将作为单词计数程序的输入。如果你想看到数大于1,输入相同的单词一遍又一遍地在5秒(增加窗口大小的5秒快速☺)如果你不能类型。

## Data Sources

- Java

`Source` 是程序读取输入的地方。可以使用 `StreamExecutionEnvironment.addSource(sourceFunction)` 将源代码附加到程序中。Flink附带了许多预实现的源函数，但是您可以通过为 `non-parallel` 源实现`SourceFunction`，或者通过为并行源实现 `ParallelSourceFunction` 接口或扩展`RichParallelSourceFunction`来编写自己的定制源。

有几个预定义的流资源可以从`StreamExecutionEnvironment`访问:

`File-based`:

- 读取文本文件(路径)，即按照TextInputFormat规范逐行读取并以字符串形式返回的文件。

- readFile(fileInputFormat, path)——按照指定的文件输入格式读取(一次)文件。

- readFile(fileInputFormat, path, watchType, interval, pathFilter, typeInfo)——这是前两个方法在内部调用的方法。它根据给定的fileInputFormat读取路径中的文件。根据所提供的watchType，此源可以定期(每隔一段时间)监视新数据的路径(fileprocessingmode . process_continuous)，或者一次性处理当前路径中的数据并退出(FileProcessingMode.PROCESS_ONCE)。使用路径过滤器，用户可以进一步排除正在处理的文件。

*实现*:

在底层，Flink将文件读取过程分成两个子任务，即目录监视和数据读取。每个子任务都由一个单独的实体实现。监视由单个非并行(parallelism = 1)任务实现，而读取由多个并行运行的任务执行。后者的并行性等于作业并行性。单个监视任务的作用是扫描目录(定期或仅扫描一次，这取决于watchType)，找到要处理的文件，将它们分成几部分，并将这些部分分配给下游的读取器。读取器将读取实际数据。每个拆分只能由一个读取器读取，而一个读取器可以逐个读取多个拆分。

*重要提示*:

1. 如果watchType设置为FileProcessingMode。process_continuous，当一个文件被修改时，它的内容被完全重新处理。这可能会打破“精确一次”语义，因为在文件末尾附加数据将导致重新处理所有内容。

2. 如果watchType设置为FileProcessingMode。PROCESS_ONCE，源程序扫描路径一次并退出，而不等待读取器完成文件内容的读取。当然，读者将继续阅读，直到所有的文件内容被读取。关闭源将导致在该点之后不再有检查点。这可能导致节点故障后恢复较慢，因为作业将从最后一个检查点恢复读取。

`Socket-based`:
- socketTextStream—从套接字读取数据。元素可以用分隔符分隔。

`Collection-based`:

- 从Java Java.util.Collection创建一个数据流。集合中的所有元素必须具有相同的类型。

- 从一个迭代器创建一个数据流。该类指定迭代器返回的元素的数据类型。

- 从给定的对象序列创建一个数据流。所有对象必须具有相同的类型。

- fromParallelCollection(SplittableIterator, Class)——并行地从迭代器创建数据流。该类指定迭代器返回的元素的数据类型。

- generateSequence(from, to)——并行地生成给定区间内的数字序列。

`Custom`:

- 附加一个新的源函数。例如，要从Apache Kafka读取数据，可以使用addSource(new FlinkKafkaConsumer08<>(…))。有关详细信息，请参见连接器。

## DataStream Transformations

有关可用`stream transformation`的概述，请参见[`operator`](../dev/stream/operators/index.md)。

## Data Sinks

数据接收器使用数据流并将它们转发到文件、套接字、外部系统或打印它们。Flink自带多种内置输出格式，这些格式被封装在数据流操作的后面:

writeAsText() / TextOutputFormat——将元素按行写入字符串。通过调用每个元素的toString()方法获得字符串。

writeAsCsv(…)/ CsvOutputFormat——将元组作为逗号分隔的值文件写入。行和字段分隔符是可配置的。每个字段的值来自对象的toString()方法。

print() / printToErr()——在标准输出/标准错误流上打印每个元素的toString()值。此外，还可以提供前缀(msg)作为输出的前缀。这有助于区分不同的打印调用。如果并行度大于1，输出也将以生成输出的任务的标识符作为前缀。

writeUsingOutputFormat() / FileOutputFormat——用于自定义文件输出的方法和基类。支持自定义对象到字节的转换。

writeToSocket——根据SerializationSchema将元素写入套接字

调用自定义接收器函数。Flink与其他系统(如Apache Kafka)的连接器捆绑在一起，这些连接器作为接收器函数实现。

注意，DataStream上的write*()方法主要用于调试。它们不参与Flink的检查点，这意味着这些函数通常至少具有一次语义。将数据刷新到目标系统取决于OutputFormat的实现。这意味着并非所有发送到OutputFormat的元素都立即出现在目标系统中。此外，在失败的情况下，这些记录可能会丢失。

为了可靠、准确地将流交付到文件系统，请使用flink-connector-filesystem。此外，通过. addsink(…)方法的自定义实现可以参与Flink的检查点，以获得精确的一次语义。

## Iterations
迭代流程序实现了一个step函数并将其嵌入到IterativeStream中。由于DataStream程序可能永远不会完成，所以没有最大迭代次数。相反，您需要指定流的哪一部分被反馈回迭代，以及哪一部分使用拆分转换或过滤器被转发到下游。这里，我们展示一个使用过滤器的例子。首先，我们定义一个IterativeStream

```java
IterativeStream<Integer> iteration = input.iterate();
```

然后，我们指定将在循环中使用一系列转换执行的逻辑(这里是一个简单的映射转换)

```java
DataStream<Integer> iterationBody = iteration.map(/* this is executed many times */);
```
要关闭迭代并定义迭代尾部，请调用IterativeStream的closeWith(feedbackStream)方法。给closeWith函数的数据流将反馈给迭代头。一种常见的模式是使用过滤器来分离返回的流的一部分和转发的流的一部分。例如，这些过滤器可以定义“终止”逻辑，其中允许元素向下传播而不是返回。

```java
iteration.closeWith(iterationBody.filter(/* one part of the stream */));
DataStream<Integer> output = iterationBody.filter(/* some other part of the stream */);
```

例如，这里有一个程序，它不断地从一系列整数中减去1，直到它们达到零:

```java
DataStream<Long> someIntegers = env.generateSequence(0, 1000);

IterativeStream<Long> iteration = someIntegers.iterate();

DataStream<Long> minusOne = iteration.map(new MapFunction<Long, Long>() {
  @Override
  public Long map(Long value) throws Exception {
    return value - 1 ;
  }
});

DataStream<Long> stillGreaterThanZero = minusOne.filter(new FilterFunction<Long>() {
  @Override
  public boolean filter(Long value) throws Exception {
    return (value > 0);
  }
});

iteration.closeWith(stillGreaterThanZero);

DataStream<Long> lessThanZero = minusOne.filter(new FilterFunction<Long>() {
  @Override
  public boolean filter(Long value) throws Exception {
    return (value <= 0);
  }
});
```

## Execution Parameters

StreamExecutionEnvironment包含ExecutionConfig，它允许为运行时设置特定于作业的配置值。

有关大多数参数的说明，请参阅执行配置。这些参数专门属于DataStream API:

- setAutoWatermarkInterval(长毫秒):设置自动水印发射的时间间隔。可以使用长getAutoWatermarkInterval()获取当前值


### Fault Tolerance
状态和检查点描述如何启用和配置Flink的检查点机制。

### Controlling Latency

默认情况下，元素不会在网络上逐个传输(这会导致不必要的网络流量)，而是进行缓冲。缓冲区的大小(实际上是在机器之间传输的)可以在Flink配置文件中设置。虽然这种方法很适合优化吞吐量，但是当传入流不够快时，它可能会导致延迟问题。要控制吞吐量和延迟，可以在执行环境(或单个操作符)上使用env.setBufferTimeout(timeoutMillis)设置缓冲区填充的最大等待时间。在此之后，即使缓冲区没有满，也会自动发送缓冲区。此超时的默认值为100 ms。

用法:

```java
LocalStreamEnvironment env = StreamExecutionEnvironment.createLocalEnvironment();
env.setBufferTimeout(timeoutMillis);

env.generateSequence(1,10).map(new MyMapper()).setBufferTimeout(timeoutMillis);
```

env.generateSequence (10)。地图(新关联()).setBufferTimeout (timeoutMillis);
为了最大限度地提高吞吐量，设置setBufferTimeout(-1)，它将删除超时，并且只有当缓冲区已满时才会刷新缓冲区。为了最小化延迟，将超时设置为接近0的值(例如5或10 ms)。应该避免缓冲区超时为0，因为这会导致严重的性能下降。



## Debugging

在分布式集群中运行流程序之前，最好确保所实现的算法按预期工作。因此，实现数据分析程序通常是一个检查结果、调试和改进的增量过程。

通过支持IDE中的本地调试、测试数据的注入和结果数据的收集，Flink提供了一些特性，可以显著简化数据分析程序的开发过程。本节给出了一些如何简化Flink程序开发的提示。

### Local Execution Environment

LocalStreamEnvironment在创建Flink系统的JVM进程中启动Flink系统。如果从IDE启动LocalEnvironment，可以在代码中设置断点并轻松调试程序。

本地环境的创建和使用如下:

```java
final StreamExecutionEnvironment env = StreamExecutionEnvironment.createLocalEnvironment();

DataStream<String> lines = env.addSource(/* some source */);
// build your program

env.execute();
```

### Collection Data Sources

Flink提供了由Java集合支持的特殊数据源，以简化测试。一旦程序经过测试，源和接收器就可以很容易地替换为从外部系统读写的源和接收器。

采集数据源的使用方法如下:

```java
final StreamExecutionEnvironment env = StreamExecutionEnvironment.createLocalEnvironment();

// Create a DataStream from a list of elements
DataStream<Integer> myInts = env.fromElements(1, 2, 3, 4, 5);

// Create a DataStream from any Java collection
List<Tuple2<String, Integer>> data = ...
DataStream<Tuple2<String, Integer>> myTuples = env.fromCollection(data);

// Create a DataStream from an Iterator
Iterator<Long> longIt = ...
DataStream<Long> myLongs = env.fromCollection(longIt, Long.class);
```

注意:目前，集合数据源要求数据类型和迭代器实现Serializable。此外，收集数据源不能并行执行(parallelism = 1)。

### 迭代器数据接收器
Flink还提供了一个接收器来收集数据流结果，用于测试和调试。它的用途如下:

```java
import org.apache.flink.streaming.experimental.DataStreamUtils

DataStream<Tuple2<String, Integer>> myResult = ...
Iterator<Tuple2<String, Integer>> myOutput = DataStreamUtils.collect(myResult)
```

注意:从Flink 1.5.0中删除了Flink -stream -contrib模块。它的类已经迁移到flink-streaming-java和flink-streaming-scala中。

## Where to go next?
操作:可用流操作符的规范。
事件时间:介绍Flink的时间概念。
状态和容错:说明如何开发有状态应用程序。
连接器:描述可用的输入和输出连接器。