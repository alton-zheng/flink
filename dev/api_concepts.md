# Basic API Concepts
Flink程序是在分布式集合上实现转换的常规程序(例如，过滤、映射、更新状态、连接、分组、定义窗口、聚合)。集合最初是从源创建的(例如，从文件、kafka主题或本地内存集合中读取)。结果通过接收器返回，例如，接收器可以将数据写入(分布式)文件，或者写入标准输出(例如，命令行终端)。Flink程序在各种上下文中运行，独立运行或嵌入到其他程序中。执行可以在本地JVM中进行，也可以在许多机器的集群上进行。

根据数据源的类型，即有界或无界数据源，您可以编写一个批处理程序或流处理程序，其中DataSet API用于批处理，DataStream API用于流处理。本指南将介绍这两种API所共有的基本概念，但有关使用每种API编写程序的具体信息，请参阅我们的流媒体指南和批处理指南。

注意:在展示如何使用这些API的实际示例时，我们将使用StreamingExecutionEnvironment和DataStream API。DataSet API中的概念完全相同，只是替换为ExecutionEnvironment和DataSet。

## DataSet and DataStream
Flink有特殊的类DataSet和DataStream来表示程序中的数据。您可以将它们看作是不可变的数据集合，可以包含重复的数据。在DataSet的情况下，数据是有限的，而对于DataStream，元素的数量可以是无界的。

这些集合在某些关键方面与常规Java集合不同。首先，它们是不可变的，这意味着一旦创建了它们，就不能添加或删除元素。您也不能简单地检查其中的元素。

集合最初是通过在Flink程序中添加一个源创建的，通过使用map、filter等API方法对这些源进行转换，可以派生出新的集合。

## Anatomy of a Flink Program

Flink程序看起来像转换数据集合的常规程序。每个程序都由相同的基本部分组成:

1.  获得一个`execution envoronment`，
2.  加载/创建初始数据，
3.指定对该数据的转换，
4.  指定将计算结果放在何处，
5.  触发程序执行


现在，我们将对每一个步骤进行概述，请参阅相关章节了解更多细节。注意,Scala数据集的所有核心类API在包[org.apache.flink.api.scala](https://github.com/apache/flink/blob/master//flink-scala/src/main/scala/org/apache/flink/api/scala),而类的Scala DataStream数据API可以在[org.apache.flink.streaming.api.scala](https://github.com/apache/flink/blob/master//flink-streaming-scala/src/main/scala/org/apache/flink/streaming/api/scala)。

`StreamExecutionEnvironment`是所有Flink程序的基础。你可以使用这些静态方法在`StreamExecutionEnvironment`上获得一个:

```scala
getExecutionEnvironment()

createLocalEnvironment()

createRemoteEnvironment(host: String, port: Int, jarFiles: String*)
```

通常,您只需要使用`getExecutionEnvironment()`,因为这将根据上下文:做正确的事如果你执行程序在IDE或普通Java程序将创建一个本地环境,将执行程序在本地机器上。如果您创建了一个JAR文件从您的程序,并通过[command line](https://ci.apache.org/projects/flink/flink-docs-release-1.9/ops/cli.html)调用它, Flink集群管理器将执行你的`main`方法和`getExecutionEnvironment()`将返回一个集群上执行程序的执行环境。

为了指定数据源，执行环境有几个方法可以使用各种方法从文件中读取数据:您可以将它们作为CSV文件逐行读取，或者使用完全定制的数据输入格式读取。要将文本文件作为行序列读取，可以使用:

```scala
val env = StreamExecutionEnvironment.getExecutionEnvironment()

val text: DataStream[String] = env.readTextFile("file:///path/to/file")
```

这将为您提供一个数据流，您可以在该数据流上应用转换来创建新的派生数据流。

您可以通过调用具有转换函数的`DataSet`上的方法来应用转换。例如，映射转换看起来是这样的:

```scala
val input: DataSet[String] = ...

val mapped = input.map { x => x.toInt }
```

这将通过将原始集合中的每个字符串转换为整数来创建一个新的DataStream。

一旦有了包含最终结果的DataStream，就可以通过创建接收器将其写入外部系统。下面是一些创建接收器的例子:

```scala
writeAsText(path: String)

print()
```

一旦您指定了完整的程序，您需要通过在`StreamExecutionEnvironment`上调用`execute()`来**触发程序执行**。根据`ExecutionEnvironment`的类型，执行将在本地机器上触发，或者将程序提交到集群上执行。

`execute()`方法返回一个`JobExecutionResult`，它包含执行时间和累加器结果。

有关流媒体数据源和sink的信息，以及关于DataStream上支持的转换的更深入的信息，请参见[流媒体指南](https://ci.apache.org/projects/flink/flink-docs-release-1.9/dev/datastream_api.html)。

查看[Batch Guide](https://ci.apache.org/projects/flink/flink-docs-release-1.9/dev/batch/index.html)了解关于批处理数据源和sink的信息，以及关于DataSet上支持的转换的更深入的信息。

## Lazy Evaluation

所有Flink程序都是延迟执行的:当程序的主方法执行时，数据加载和转换不会直接发生。相反，每个操作都被创建并添加到程序的计划中。当对执行环境的`execute()`调用显式地触发执行时，实际上执行操作。程序是在本地执行还是在集群上执行取决于执行环境的类型

延迟计算允许您构建复杂的程序，Flink将这些程序作为一个整体规划的单元执行。



## Specifying Keys

一些转换(`join`、`coGroup`、`keyBy`、`groupBy`)要求在元素集合上定义一个键。其他转换(`Reduce`、`GroupReduce`、`Aggregate`、`Windows`)允许在应用数据之前根据`key`对数据进行分组。


`DataSet` 被分组为：

```java
DataSet<...> input = // [...]
DataSet<...> reduced = input
  .groupBy(/*define key here*/)
  .reduceGroup(/*do something*/);
```

而密钥可以在`DataStream`上使用

```java
DataSet<...> input = // [...]
DataSet<...> reduced = input
  .groupBy(/*define key here*/)
  .reduceGroup(/*do something*/);
```

Flink的数据模型不是基于键值对的。因此，您不需要将数据集类型物理地打包到键和值中。键是`virtual`:它们被定义为实际数据之上的函数，用于指导分组操作符。

**注意:** 在接下来的讨论中，我们将使用`DataStream` API和`keyBy`。对于`DataSet` API，您只需替换为`DataSet`和`groupBy`。

### Define keys for Tuples

最简单的情况是对元组的一个或多个字段进行分组。
```java
DataStream<Tuple3<Integer,String,Long>> input = // [...]
KeyedStream<Tuple3<Integer,String,Long>,Tuple> keyed = input.keyBy(0)
```

```scala
val input: DataStream[(Int, String, Long)] = // [...]
val keyed = input.keyBy(0)
```

元组按第一个字段(整数类型的字段)分组。

```java
DataStream<Tuple3<Integer,String,Long>> input = // [...]
KeyedStream<Tuple3<Integer,String,Long>,Tuple> keyed = input.keyBy(0,1)
```

```scala
val input: DataSet[(Int, String, Long)] = // [...]
val grouped = input.groupBy(0,1)
```

在这里，我们在一个由第一个和第二个字段组成的组合键上对元组进行分组。

关于嵌套元组的说明:如果您有一个嵌套元组的DataStream，例如:

```java
DataStream<Tuple3<Tuple2<Integer, Float>,String,Long>> ds;
```

指定`keyBy(0)`将导致系统使用完整的`Tuple2`作为键(整数和浮点数作为键)。如果你想`navigate`在嵌套的`Tuple2`中，必须使用下面解释的字段表达式键。

### Define keys using Field Expressions

您可以使用基于字符串的字段表达式引用嵌套字段，并定义用于分组、排序、连接或协分组的键。

`Field`表达式使它很容易选择等(嵌套)复合类型字段[Tuple](../dev/api_concepts.md#tuples-and-case-classes)和[POJO](../dev/api_concepts.md#pojos)类型。

在下面的示例中，我们有一个带有两个字段`word`和`count` 的 `WC POJO`。要按字段`word`进行分组，只需将其名称传递给`keyBy()`函数。

```scala
// some ordinary POJO (Plain old Java Object)
class WC(var word: String, var count: Int) {
  def this() { this("", 0L) }
}
val words: DataStream[WC] = // [...]
val wordCounts = words.keyBy("word").window(/*window specification*/)

// or, as a case class, which is less typing
case class WC(word: String, count: Int)
val words: DataStream[WC] = // [...]
val wordCounts = words.keyBy("word").window(/*window specification*/)
```

**Field Expression Syntax**

- 根据字段名选择`POJO`字段。例如，"user" 指的是 "user" POJO类型的字段。

- 根据元组字段的`1`偏移量字段名称或`0`偏移量字段索引选择元组字段。例如，`_1`和`5`分别引用Scala元组类型的第一个和第六个字段。

- 您可以选择`POJO`和`Tuples`中的嵌套字段。例如`user.zip`指的是`zip`存储在`user`中的`POJO`字段`POJO`类型的字段。支持任意嵌套和混合`POJO`和`Tuple`，比如`_2.user.zip` 或 `user._4.1.zip`

- 您可以使用`_`通配符表达式选择完整类型。这也适用于非元组或`POJO`类型的类型。


**Field Expression 例子**:
```java
class WC(var complex: ComplexNestedClass, var count: Int) {
  def this() { this(null, 0) }
}

class ComplexNestedClass(
    var someNumber: Int,
    someFloat: Float,
    word: (Long, Long, String),
    hadoopCitizen: IntWritable) {
  def this() { this(0, 0, (0, 0, ""), new IntWritable(0)) }
}
```

这些是上面示例代码的有效`Field Expression`:

- **`count`**:`WC`类中的count字段。
- **`complex`**:递归地选择POJO类型`ComplexNestedClass`的字段`complex`的所有字段。
- **`complex.word._3`**:选择嵌套的`Tuple3`的最后一个字段。 
- **`complex.hadoopCitizen`**:选择Hadoop `IntWritable`类型。


### Define keys using Key Selector Functions

定义键的另一种方法是`键选择器`功能。键选择器函数接受单个元素作为输入，并返回该元素的键。密钥可以是任何类型的，并且可以从确定性计算中得到。

下面的例子显示了一个键选择器函数，它只返回对象的字段:

```scala
// some ordinary case class
case class WC(word: String, count: Int)
val words: DataStream[WC] = // [...]
val keyed = words.keyBy( _.word )
```
## Specifying Transformation Functions

大多数转换都需要用户定义的函数。本节列出了指定它们的不同方法

#### Lambda Functions

正如在前面的例子中已经看到的，所有的操作都接受lambda函数来描述操作:

```scala
val data: DataSet[String] = // [...]
data.filter { _.startsWith("http://") }
```

```scala
val data: DataSet[Int] = // [...]
data.reduce { (i1,i2) => i1 + i2 }
// or
data.reduce { _ + _ }
```

#### Rich functions

所有以lambda函数为参数的转换都可以以富函数为参数。例如，代替
```scala
data.map { x => x.toInt }
```

你可以写成：

```scala
class MyMapFunction extends RichMapFunction[String, Int] {
  def map(in: String):Int = { in.toInt }
};
```

并将函数传递给`map`转换:

```scala
data.map(new MyMapFunction())
```

`Rich`函数也可以定义为一个匿名类:

```scala
data.map (new RichMapFunction[String, Int] {
  def map(in: String):Int = { in.toInt }
})
```

除了用户定义的函数(`map`、`reduce`等)外，`Rich`函数还提供了四种方法:`open`、`close`、`getRuntimeContext`和`setRuntimeContext`。这些是用于参数化函数([见向函数传递参数](https://ci.apache.org/projects/flink/flink-docs-release-1.9/dev/batch/index.html#passing-parameters-to-functions)),创建并最终确定本地状态,访问广播变量(参见[Broadcast Variables](https://ci.apache.org/projects/flink/flink-docs-release-1.9/dev/batch/index.html#broadcast-variables)),和访问运行时信息,如蓄电池和计数器(见[蓄能器和计数器](https://ci.apache.org/projects/flink/flink-docs-release-1.9/zh/dev/api_concepts.html#accumulators--counters)),和信息迭代(见[迭代](https://ci.apache.org/projects/flink/flink-docs-release-1.9/dev/batch/iterations.html))。


## Supported Data Types

Flink对数据集或数据流中的元素类型进行了一些限制。原因是系统分析类型以确定有效的执行策略。

数据类型有六种:

1.  **Java Tuples** 和 **Scala Case Classes**
2.  **Java POJOs**
3.  **Primitive Types**
4.  **Regular Classes**
5.  **Values**
6.  **Hadoop Writables**
7.  **Special Types**

#### Tuples and Case Classes

Scala case类(和Scala元组，它们是case类的特殊情况)是复合类型，包含固定数量的具有各种类型的字段。元组字段由其1偏移的名称来寻址，比如第一个字段的`_1`。Case类字段按其名称访问。

```scala
case class WordCount(word: String, count: Int)
val input = env.fromElements(
    WordCount("hello", 1),
    WordCount("world", 2)) // Case Class Data Set

input.keyBy("word")// key by field expression "word"

val input2 = env.fromElements(("hello", 1), ("world", 2)) // Tuple2 Data Set

input2.keyBy(0, 1) // key by field positions 0 and 1
```

#### POJOs

如果Java和Scala类满足以下要求，Flink将它们视为特殊的POJO数据类型:

- 类必须是公共的。

- 它必须有一个没有参数的公共构造函数(默认构造函数)。

- 所有字段要么是公共的，要么必须通过`getter`和`setter`函数访问。对于名为`foo`的字段，`getter`和`setter`方法必须分别命名为`getFoo()`和`setFoo()`。

- 字段的类型必须由已注册的序列化器支持。

`POJOs`通常用`PojoTypeInfo`表示，并使用`PojoSerializer`进行序列化(使用[Kryo](https://github.com/EsotericSoftware/kryo)作为可配置的回退)。例外情况是，当`pojo`实际上是`Avro`类型(`Avro`特定记录)或作为`Avro`反射类型生成时。在这种情况下，`POJO`由`AvroTypeInfo`表示，并用`AvroSerializer`序列化。如果需要，还可以注册自己的自定义序列化器;有关更多信息，请参见[Serialization](https://ci.apache.org/projects/flink/flink-docs-stable/dev/types_serialization.html#serialization-of-pojo-types)。

`Flink`分析`POJO`类型的结构，即，它学习`POJO`的领域。因此，`POJO`类型比一般类型更容易使用。此外，`Flink`可以比一般类型更有效地处理`POJO`。

下面的示例显示了一个简单的POJO，它有两个公共字段。
```scala
class WordWithCount(var word: String, var count: Int) {
    def this() {
      this(null, -1)
    }
}

val input = env.fromElements(
    new WordWithCount("hello", 1),
    new WordWithCount("world", 2)) // Case Class Data Set

input.keyBy("word")// key by field expression "word"
```

#### Primitive Types

Flink支持所有Java和Scala基本类型， 例如 `Integer`, `String`, 和 `Double`.

#### General Class Types

Flink支持所有Java和Scala基本类型，如`Integer`、`String`和`Double`。Flink支持大多数Java和Scala类(API和定制)。限制适用于包含不能序列化字段的类，如文件指针、I/O流或其他本机资源。通常，遵循Java bean约定的类工作得很好。

所有未标识为POJO类型的类(请参阅上面的POJO需求)都由Flink作为通用类类型处理。Flink将这些数据类型视为黑盒，无法访问它们的内容(例如，，以提高排序效率)。一般类型使用序列化框架[Kryo](https://github.com/EsotericSoftware/kryo)反序列化。

#### Values

_Value_类型手动描述它们的序列化和反序列化。他们没有使用通用的序列化框架，而是通过实现`org.apache.flinktypes.CopyableValue`接口和`read`,`write`方法为这些操作提供定制代码。当通用序列化效率非常低时，使用值类型是合理的。例如，数据类型将实现元素的稀疏向量作为数组。知道数组大部分为零，就可以对非零元素使用特殊的编码，而通用串行化只需编写所有数组元素。

`org.apache.flinktypes.CopyableValue`接口以类似的方式支持手动内部克隆逻辑。

Flink附带与基本数据类型对应的预定义值类型。(`ByteValue`、`ShortValue`、`IntValue`、`LongValue`、`FloatValue`、`DoubleValue`、`StringValue`、`CharValue`、`BooleanValue`)。这些值类型充当基本数据类型的可变变体:可以更改它们的值，从而允许程序员重用对象并减轻垃圾收集器的压力。


#### Hadoop Writables

你可以使用实现了 `org.apache.hadoop.Writable` 接口的类型. 在`write()`和 `readFields()` 方法中定义的序列化逻辑将用于序列化。

#### Special Types

您可以使用特殊类型，包括Scala的`Either`、`Option`和`Try`。Java API有自己的`Either`自定义实现。与Scala的`Either`类似，它表示两个可能类型的值，_Left_或_Right_。`Either`对于错误处理或需要输出两种不同类型记录的操作符非常有用。

#### Type Erasure & Type Inference

注意:本节只与Java相关

Java编译器在编译之后会丢弃很多泛型类型信息。这在Java中称为 *type erasure*。这意味着在运行时，对象的实例不再知道它的泛型类型。例如，`DataStream<String>`和`DataStream<Long>`的实例在JVM中看起来是一样的。

Flink在准备执行程序时(调用程序的`main`方法时)需要类型信息。Flink Java API尝试重构以各种方式丢弃的类型信息，并显式地将其存储在数据集和操作符中。您可以通过`DataStream.getType()`检索类型。该方法返回一个`TypeInformation`实例，这是Flink表示类型的内部方法。

类型推断有其局限性，需要`cooperation`在某些情况下，程序员。例如，从集合创建数据集的方法，如`ExecutionEnvironment.fromCollection()`，您可以在其中传递描述类型的参数。但是像`MapFunction<I, O>`这样的泛型函数可能需要额外的类型信息。

可以通过输入格式和函数实现[ResultTypeQueryable](https://github.com/apache/flink/blob/master//flink-core/src/main/java/org/apache/flink/api/java/typeutils/ResultTypeQueryable.java)接口，从而显式地告诉API它们的返回类型。通常可以通过前面操作的结果类型推断调用函数的_input类型。


## Accumulators & Counters

`Accumulators`是简单的构造，具有 **add operation** 和**final accumulated result**，在作业结束后可用。

最直接的累加器是**counter**:您可以使用`accumulator`递增它。添加(`V value`)的方法。作业结束时，Flink将汇总(合并)所有部分结果，并将结果发送给客户机。累加器在调试期间非常有用，如果您想快速了解更多有关数据的信息，也可以使用累加器。

Flink目前有以下**built-in accumulators**。它们都实现了[Accumulator](https://github.com/apache/flink/blob/master//flink-core/src/main/java/org/apache/flink/api/common/accumulators/Accumulator.java)接口。

- [**`IntCounter`**](https://github.com/apache/flink/blob/master//flink-core/src/main/java/org/apache/flink/api/common/accumulators/IntCounter.java)、[**`LongCounter`**](https://github.com/apache/flink/blob/master//flink-core/src/main/java/org/apache/flink/api/common/accumulators/LongCounter.java)和[**`DoubleCounter`**](https://github.com/apache/flink/blob/master//flink-core/src/main/java/org/apache/flink/api/common/accumulators/DoubleCounter.java):下面是使用`counter`的示例。
- [**`Histogram`**](https://github.com/apache/flink/blob/master//flink-core/src/main/java/org/apache/flink/api/common/accumulators/Histogram.java):针对离散数量的箱子的直方图实现。在内部，它只是一个从整数到整数的映射。您可以使用它来计算值的分布，例如单词计数程序的每行单词的分布。

**如何使用 accumulators:**

首先，您必须在需要使用它的用户定义转换函数中创建一个`accumulator`对象(这里是一个计数器)。
```java
private IntCounter numLines = new IntCounter();
```

其次，必须注册`accumulator`对象，通常是在_rich_函数的' open() '方法中。这里还定义了名称。
```java
getRuntimeContext().addAccumulator("num-lines", this.numLines);
```

现在可以在操作符函数的任何位置使用累加器，包括在“open()”和“close()”方法中。
```java
this.numLines.add(1);
```

整个结果将存储在“JobExecutionResult”对象中，该对象是从执行环境的“execute()”方法返回的(目前，只有在执行等待作业完成时才有效)。

```java
myJobExecutionResult.getAccumulatorResult("num-lines")
```

所有累加器对每个作业共享一个名称空间。因此，您可以在作业的不同操作符函数中使用相同的累加器。Flink将在内部合并所有具有相同名称的累加器。

关于累加器和迭代的说明:当前，累加器的结果只有在整个作业结束后才可用。我们还计划让上一个迭代的结果在下一个迭代中可用。您可以使用[Aggregators](https://github.com/apache/flink/blob/master//flink-java/src/main/java/org/apache/flink/api/java/operators/IterativeDataSet.java#L98)来计算每次迭代的统计数据，并根据这些统计数据终止迭代。

**Custom accumulators**

要实现自己的`accumulator`，只需编写`accumulator`接口的实现即可。如果您认为您的自定义累加器应该与Flink一起提供，请随意创建一个`pull`请求。

你可以选择来实现[Accumulator](https://github.com/apache/flink/blob/master//flink-core/src/main/java/org/apache/flink/api/common/accumulators/Accumulator.java)或[SimpleAccumulator](https://github.com/apache/flink/blob/master//flink-core/src/main/java/org/apache/flink/api/common/accumulators/SimpleAccumulator.java)。

`Accumulator<V,R>`是最灵活的:它为要添加的值定义了一个类型`V`，为最终结果定义了一个结果类型`R`。例如，对于`histogram`，“V”是一个数字，“R”是一个直方图。`SimpleAccumulator`用于两种类型相同的情况，例如`counters`。
