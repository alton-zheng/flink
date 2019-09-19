# 算子
操作符将一个或多个数据流转换为一个新的数据流。程序可以将多个转换组合成复杂的数据流拓扑。

本节将描述基本转换、应用这些转换之后的有效物理分区以及对Flink操作符链接的理解。

## DataStream Transformations

### Transformation
- Map
  - DataStream → DataStream
  - 获取一个元素并生成一个元素。一个map函数，使输入流的值加倍:
```java
DataStream<Integer> dataStream = //...
dataStream.map(new MapFunction<Integer, Integer>() {
    @Override
    public Integer map(Integer value) throws Exception {
        return 2 * value;
    }
});
```

```scala
dataStream.map { x => x * 2 }
```

- FlatMap
  - DataStream → DataStream
  - 获取一个元素并生成零个、一个或多个元素。一种将句子分割成单词的平面映射函数:
  
- Filter
  - DataStream → DataStream
  - 为每个元素计算布尔函数，并保留函数返回true的元素。过滤掉零值的过滤器:
  
- KeyBy
  - DataStream → KeyedStream
  - 逻辑上将流划分为不相交的分区。所有具有相同密钥的记录都被分配到同一个分区。在内部，keyBy()是通过哈希分区实现的。有不同的方法来指定键。
  
- Reduce
  - KeyedStream → DataStream
- Fold
  - KeyedStream → DataStream
- Aggregations
  - KeyedStream → DataStream
- Window
  - KeyedStream → WindowedStream
- WindowAll
  - DataStream → AllWindowedStream
- Window Apply
  - WindowedStream → DataStream
  - AllWindowedStream → DataStream
  
- Window Reduce
  - WindowedStream → DataStream
- Window Fold
  - WindowedStream → DataStream
- Aggregations on windows
  - WindowedStream → DataStream
- Union
  - DataStream* → DataStream
- Window Join
  - DataStream,DataStream → DataStream
- Window CoGroup
  - DataStream,DataStream → DataStream
- Connect
  - DataStream,DataStream → ConnectedStreams
- CoMap, CoFlatMap
  - ConnectedStreams → DataStream
- Split
  - DataStream → SplitStream
- Select
  - SplitStream → DataStream
- Iterate
  - DataStream → IterativeStream → DataStream
- Extract Timestamps
  - DataStream → DataStream

- 这个转换返回一个KeyedStream，它是使用键控状态所必需的。
- 键控数据流上的“滚动”缩减。将当前元素与最后一个缩减值组合并发出新值。
- 一个生成部分和流的reduce函数:
- 具有初始值的键控数据流上的“滚动”折叠。将当前元素与最后一个折叠值组合并发出新值。
- 一个折叠函数，当应用于序列(1,2,3,4,5)时，发出序列“start-1”，“start-1-2”，“start-1-2-3”，…
- 在键控数据流上滚动聚合。min和minBy的区别在于，min返回最小值，而minBy返回该字段中具有最小值的元素(max和maxBy也是如此)。
- Windows可以在已经分区的KeyedStreams上定义。Windows根据某些特性(例如，最近5秒内到达的数据)对每个键中的数据进行分组。有关windows的完整描述，请参见windows。
- Windows可以在常规数据流上定义。Windows根据一些特性(例如，最近5秒内到达的数据)对所有流事件进行分组。有关windows的完整描述，请参见windows。
- 警告:在许多情况下，这是一个非并行转换。所有记录将在windowAll操作符的一个任务中收集。
- 将一个通用函数应用于整个窗口。下面是一个手动汇总窗口元素的函数。
- 注意:如果正在使用windowAll转换，则需要使用AllWindowFunction。
- 将函数折叠函数应用于窗口并返回折叠值。将示例函数应用于序列(1,2,3,4,5)时，将序列折叠成字符串“start 1-2-3-4-5”:
- 聚合窗口的内容。min和minBy的区别在于，min返回最小值，而minBy返回该字段中具有最小值的元素(max和maxBy也是如此)。
- 两个或多个数据流的联合，创建一个包含来自所有流的所有元素的新流。注意:如果您将一个数据流与它自己相结合，您将得到结果流中的每个元素两次。
- 连接给定键和公共窗口上的两个数据流。
- 将两个键流的两个元素e1和e2用一个公共键在给定的时间间隔内连接起来，这样e1。时间戳+下界<= e2。时间戳< = e1。时间戳+ upperBound
- 将给定键和公共窗口上的两个数据流组合在一起。
- “连接”两个保留其类型的数据流。允许两个流之间共享状态的连接。
- 类似于连接数据流上的映射和平面映射
- 根据某些标准将流分成两个或多个流。
- 从拆分流中选择一个或多个流。
- 通过将一个操作符的输出重定向到前面的某个操作符，在流中创建一个“反馈”循环。这对于定义不断更新模型的算法特别有用。下面的代码从一个流开始，并持续地应用迭代体。大于0的元素被发送回反馈通道，其余的元素被转发到下游。有关完整描述，请参见迭代。
- 从记录中提取时间戳，以便使用使用事件时间语义的窗口。看到事件时间。