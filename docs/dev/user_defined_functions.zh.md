# 用户自定义 Functions

大多数操作都需要用户自定义 function。本节列出了实现用户自定义 function 的不同方式。还会介绍 `Accumulators`（累加器），可用于深入了解你的 Flink 应用程序。

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/user_defined_functions.html#tab_Java_0)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/user_defined_functions.html#tab_Scala_0)



## 实现接口

最基本的方法是实现提供的接口：

```
class MyMapFunction implements MapFunction<String, Integer> {
  public Integer map(String value) { return Integer.parseInt(value); }
};
data.map(new MyMapFunction());
```



## 匿名类

你可以将 function 当做匿名类传递：

```
data.map(new MapFunction<String, Integer> () {
  public Integer map(String value) { return Integer.parseInt(value); }
});
```



## Java 8 Lambdas

Flink 在 Java API 中还支持 Java 8 Lambdas 表达式。

```
data.filter(s -> s.startsWith("http://"));
data.reduce((i1,i2) -> i1 + i2);
```



## Rich functions

所有需要用户自定义 function 的转化操作都可以将 *rich* function 作为参数。例如，你可以将下面代码

```
class MyMapFunction implements MapFunction<String, Integer> {
  public Integer map(String value) { return Integer.parseInt(value); }
};
```

替换成

```
class MyMapFunction extends RichMapFunction<String, Integer> {
  public Integer map(String value) { return Integer.parseInt(value); }
};
```

并将 function 照常传递给 `map` transformation:

```
data.map(new MyMapFunction());
```

Rich functions 也可以定义成匿名类：

```
data.map (new RichMapFunction<String, Integer>() {
  public Integer map(String value) { return Integer.parseInt(value); }
});
```

除了用户自定义的 function（map，reduce 等），Rich functions 还提供了四个方法：`open`、`close`、`getRuntimeContext` 和 `setRuntimeContext`。这些方法对于参数化 function （参阅 [给 function 传递参数](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/batch/#passing-parameters-to-functions)）， 创建和最终确定本地状态，访问广播变量（参阅 [广播变量](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/batch/#broadcast-variables)），以及访问运行时信息，例如累加器和计数器（参阅 [累加器和计数器](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/user_defined_functions.html#accumulators--counters)），以及迭代器的相关信息（参阅 [迭代器](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/batch/iterations.html)） 有很大作用。

[ Back to top](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/user_defined_functions.html#top)



## 累加器和计数器

累加器是具有**加法运算**和**最终累加结果**的一种简单结构，可在作业结束后使用。

最简单的累加器就是**计数器**: 你可以使用 `Accumulator.add(V value)` 方法将其递增。在作业结束时，Flink 会汇总（合并）所有部分的结果并将其发送给客户端。 在调试过程中或在你想快速了解有关数据更多信息时,累加器作用很大。

Flink 目前有如下**内置累加器**。每个都实现了 [累加器](https://github.com/apache/flink/blob/master//flink-core/src/main/java/org/apache/flink/api/common/accumulators/Accumulator.java) 接口。

- [**IntCounter**](https://github.com/apache/flink/blob/master//flink-core/src/main/java/org/apache/flink/api/common/accumulators/IntCounter.java), [**LongCounter**](https://github.com/apache/flink/blob/master//flink-core/src/main/java/org/apache/flink/api/common/accumulators/LongCounter.java) 和 [**DoubleCounter**](https://github.com/apache/flink/blob/master//flink-core/src/main/java/org/apache/flink/api/common/accumulators/DoubleCounter.java): 有关使用计数器的示例，请参见下文。
- [**直方图**](https://github.com/apache/flink/blob/master//flink-core/src/main/java/org/apache/flink/api/common/accumulators/Histogram.java): 离散数量的柱状直方图实现。在内部，它只是整形到整形的映射。你可以使用它来计算值的分布，例如，单词计数程序的每行单词的分布情况。

**如何使用累加器：**

首先，在需要使用累加器的用户自定义的转换 function 中创建一个累加器对象（此处是计数器）。

```
private IntCounter numLines = new IntCounter();
```

其次，你必须在 *rich* function 的 `open()` 方法中注册累加器对象。也可以在此处定义名称。

```
getRuntimeContext().addAccumulator("num-lines", this.numLines);
```

现在你可以在操作 function 中的任何位置（包括 `open()` 和 `close()` 方法中）使用累加器。

```
this.numLines.add(1);
```

最终整体结果会存储在由执行环境的 `execute()` 方法返回的 `JobExecutionResult` 对象中（当前只有等待作业完成后执行才起作用）。

```
myJobExecutionResult.getAccumulatorResult("num-lines")
```

单个作业的所有累加器共享一个命名空间。因此你可以在不同的操作 function 里面使用同一个累加器。Flink 会在内部将所有具有相同名称的累加器合并起来。

关于累加器和迭代的注意事项：当前累加器的结果只有在整个作业结束后才可用。我们还计划在下一次迭代中提供上一次的迭代结果。你可以使用 [聚合器](https://github.com/apache/flink/blob/master//flink-java/src/main/java/org/apache/flink/api/java/operators/IterativeDataSet.java#L98) 来计算每次迭代的统计信息，并基于此类统计信息来终止迭代。

**定制累加器：**

要实现自己的累加器，你只需要实现累加器接口即可。如果你认为自定义累加器应随 Flink 一起提供，请尽管创建 pull request。

你可以选择实现 [Accumulator](https://github.com/apache/flink/blob/master//flink-core/src/main/java/org/apache/flink/api/common/accumulators/Accumulator.java) 或 [SimpleAccumulator](https://github.com/apache/flink/blob/master//flink-core/src/main/java/org/apache/flink/api/common/accumulators/SimpleAccumulator.java)。

`Accumulator<V,R>` 的实现十分灵活: 它定义了将要添加的值类型 `V`，并定义了最终的结果类型 `R`。例如，对于直方图，`V` 是一个数字且 `R` 是一个直方图。 `SimpleAccumulator` 适用于两种类型都相同的情况，例如计数器。