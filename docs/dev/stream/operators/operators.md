# 算子

`operator` 将一个或多个 `DataStream` 转换为新的`DataStream`。程序可以将多种转换组合成复杂的数据流拓扑。

本节描述了基本转换，应用这些转换后的有效物理分区以及对Flink运算符链接的见解。

# DataStream Transformations

- **Map** 
  - DataStream → DataStream      
  - 取一个元素并产生一个元素。一个映射函数，将输入流的值加倍：
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


- **FlatMap**  
  - DataStream → DataStream
  - 取一个元素并产生零个，一个或多个元素。平面图功能可将句子拆分为单词：
  - `Java`
```java
dataStream.flatMap(new FlatMapFunction<String, String>() {
    @Override
    public void flatMap(String value, Collector<String> out)
        throws Exception {
        for(String word: value.split(" ")){
            out.collect(word);
        }
    }
});
```
  - **`Scala`**
```scala
dataStream.flatMap { str => str.split(" ") }
```

- **Filter**  
  - DataStream → DataStream
  - 为每个元素评估一个布尔函数，并保留该函数返回true的布尔函数。筛选出零值的筛选器：
  - `Java`
```java
dataStream.filter(new FilterFunction<Integer>() {
    @Override
    public boolean filter(Integer value) throws Exception {
        return value != 0;
    }
});
```
  - `Scala`
```scala
dataStream.filter { _ != 0 }
```

- **KeyBy**  
  - DataStream → KeyedStream
  - **Java**
    - 从逻辑上将流划分为不相交的分区。具有相同键的所有记录都分配给同一分区。在内部，keyBy（）是通过哈希分区实现的。有多种指定密钥的方法。
    - 此转换返回一个KeyedStream，除其他事项外，还需要使用keyed state。
    - 注意： 在以下情况下，类型不能为键：
      - 它是POJO类型，但不覆盖 hashCode() 方法，而是依赖于Object.hashCode（）实现。
      - 它是任何类型的数组。
```java
dataStream.keyBy("someKey") // Key by field "someKey"
dataStream.keyBy(0) // Key by the first element of a Tuple
```
  - **`scala`**
    - 从逻辑上将流划分为不相交的分区，每个分区都包含同一键的元素。在内部，这是通过哈希分区实现的。见键如何指定键。此转换返回KeyedStream。
```scala
dataStream.keyBy("someKey") // Key by field "someKey"
dataStream.keyBy(0) // Key by the first element of a Tuple
```

**Reduce**  
KeyedStream → DataStream

A "rolling" reduce on a keyed data stream. Combines the current element with the last reduced value and emits the new value.

A reduce function that creates a stream of partial sums:

    keyedStream.reduce(new ReduceFunction<Integer>() {
        @Override
        public Integer reduce(Integer value1, Integer value2)
        throws Exception {
            return value1 + value2;
        }
    });


**Fold**  
KeyedStream → DataStream

A "rolling" fold on a keyed data stream with an initial value. Combines the current element with the last folded value and emits the new value.

A fold function that, when applied on the sequence (1,2,3,4,5), emits the sequence "start-1", "start-1-2", "start-1-2-3", ...

    DataStream<String> result =
      keyedStream.fold("start", new FoldFunction<Integer, String>() {
        @Override
        public String fold(String current, Integer value) {
            return current + "-" + value;
        }
      });


**Aggregations**  
KeyedStream → DataStream

Rolling aggregations on a keyed data stream. The difference between min and minBy is that min returns the minimum value, whereas minBy returns the element that has the minimum value in this field (same for max and maxBy).

    keyedStream.sum(0);
    keyedStream.sum("key");
    keyedStream.min(0);
    keyedStream.min("key");
    keyedStream.max(0);
    keyedStream.max("key");
    keyedStream.minBy(0);
    keyedStream.minBy("key");
    keyedStream.maxBy(0);
    keyedStream.maxBy("key");


**Window**  
KeyedStream → WindowedStream

Windows can be defined on already partitioned KeyedStreams. Windows group the data in each key according to some characteristic (e.g., the data that arrived within the last 5 seconds). See [windows](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html) for a complete description of windows.

    dataStream.keyBy(0).window(TumblingEventTimeWindows.of(Time.seconds(5))); // Last 5 seconds of data


**WindowAll**  
DataStream → AllWindowedStream

Windows can be defined on regular DataStreams. Windows group all the stream events according to some characteristic (e.g., the data that arrived within the last 5 seconds). See [windows](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/windows.html) for a complete description of windows.

**WARNING:** This is in many cases a **non-parallel** transformation. All records will be gathered in one task for the windowAll operator.

    dataStream.windowAll(TumblingEventTimeWindows.of(Time.seconds(5))); // Last 5 seconds of data


**Window Apply**  
WindowedStream → DataStream  
AllWindowedStream → DataStream

Applies a general function to the window as a whole. Below is a function that manually sums the elements of a window.

**Note:** If you are using a windowAll transformation, you need to use an AllWindowFunction instead.

    windowedStream.apply (new WindowFunction<Tuple2<String,Integer>, Integer, Tuple, Window>() {
        public void apply (Tuple tuple,
                Window window,
                Iterable<Tuple2<String, Integer>> values,
                Collector<Integer> out) throws Exception {
            int sum = 0;
            for (value t: values) {
                sum += t.f1;
            }
            out.collect (new Integer(sum));
        }
    });

    // applying an AllWindowFunction on non-keyed window stream
    allWindowedStream.apply (new AllWindowFunction<Tuple2<String,Integer>, Integer, Window>() {
        public void apply (Window window,
                Iterable<Tuple2<String, Integer>> values,
                Collector<Integer> out) throws Exception {
            int sum = 0;
            for (value t: values) {
                sum += t.f1;
            }
            out.collect (new Integer(sum));
        }
    });


**Window Reduce**  
WindowedStream → DataStream

Applies a functional reduce function to the window and returns the reduced value.

    windowedStream.reduce (new ReduceFunction<Tuple2<String,Integer>>() {
        public Tuple2<String, Integer> reduce(Tuple2<String, Integer> value1, Tuple2<String, Integer> value2) throws Exception {
            return new Tuple2<String,Integer>(value1.f0, value1.f1 + value2.f1);
        }
    });


**Window Fold**  
WindowedStream → DataStream

Applies a functional fold function to the window and returns the folded value. The example function, when applied on the sequence (1,2,3,4,5), folds the sequence into the string "start-1-2-3-4-5":

    windowedStream.fold("start", new FoldFunction<Integer, String>() {
        public String fold(String current, Integer value) {
            return current + "-" + value;
        }
    });


**Aggregations on windows**  
WindowedStream → DataStream

Aggregates the contents of a window. The difference between min and minBy is that min returns the minimum value, whereas minBy returns the element that has the minimum value in this field (same for max and maxBy).

    windowedStream.sum(0);
    windowedStream.sum("key");
    windowedStream.min(0);
    windowedStream.min("key");
    windowedStream.max(0);
    windowedStream.max("key");
    windowedStream.minBy(0);
    windowedStream.minBy("key");
    windowedStream.maxBy(0);
    windowedStream.maxBy("key");


**Union**  
DataStream\* → DataStream

Union of two or more data streams creating a new stream containing all the elements from all the streams. Note: If you union a data stream with itself you will get each element twice in the resulting stream.

    dataStream.union(otherStream1, otherStream2, ...);


**Window Join**  
DataStream,DataStream → DataStream

Join two data streams on a given key and a common window.

    dataStream.join(otherStream)
        .where(<key selector>).equalTo(<key selector>)
        .window(TumblingEventTimeWindows.of(Time.seconds(3)))
        .apply (new JoinFunction () {...});


**Interval Join**  
KeyedStream,KeyedStream → DataStream

Join two elements e1 and e2 of two keyed streams with a common key over a given time interval, so that e1.timestamp + lowerBound <= e2.timestamp <= e1.timestamp + upperBound

    // this will join the two streams so that
    // key1 == key2 && leftTs - 2 < rightTs < leftTs + 2
    keyedStream.intervalJoin(otherKeyedStream)
        .between(Time.milliseconds(-2), Time.milliseconds(2)) // lower and upper bound
        .upperBoundExclusive(true) // optional
        .lowerBoundExclusive(true) // optional
        .process(new IntervalJoinFunction() {...});


**Window CoGroup**  
DataStream,DataStream → DataStream

Cogroups two data streams on a given key and a common window.

    dataStream.coGroup(otherStream)
        .where(0).equalTo(1)
        .window(TumblingEventTimeWindows.of(Time.seconds(3)))
        .apply (new CoGroupFunction () {...});


**Connect**  
DataStream,DataStream → ConnectedStreams

"Connects" two data streams retaining their types. Connect allowing for shared state between the two streams.

    DataStream<Integer> someStream = //...
    DataStream<String> otherStream = //...

    ConnectedStreams<Integer, String> connectedStreams = someStream.connect(otherStream);


**CoMap, CoFlatMap**  
ConnectedStreams → DataStream

Similar to map and flatMap on a connected data stream

    connectedStreams.map(new CoMapFunction<Integer, String, Boolean>() {
        @Override
        public Boolean map1(Integer value) {
            return true;
        }

        @Override
        public Boolean map2(String value) {
            return false;
        }
    });
    connectedStreams.flatMap(new CoFlatMapFunction<Integer, String, String>() {

       @Override
       public void flatMap1(Integer value, Collector<String> out) {
           out.collect(value.toString());
       }

       @Override
       public void flatMap2(String value, Collector<String> out) {
           for (String word: value.split(" ")) {
             out.collect(word);
           }
       }
    });


**Split**  
DataStream → SplitStream

Split the stream into two or more streams according to some criterion.

    SplitStream<Integer> split = someDataStream.split(new OutputSelector<Integer>() {
        @Override
        public Iterable<String> select(Integer value) {
            List<String> output = new ArrayList<String>();
            if (value % 2 == 0) {
                output.add("even");
            }
            else {
                output.add("odd");
            }
            return output;
        }
    });


**Select**  
SplitStream → DataStream

Select one or more streams from a split stream.

    SplitStream<Integer> split;
    DataStream<Integer> even = split.select("even");
    DataStream<Integer> odd = split.select("odd");
    DataStream<Integer> all = split.select("even","odd");


**Iterate**  
DataStream → IterativeStream → DataStream

Creates a "feedback" loop in the flow, by redirecting the output of one operator to some previous operator. This is especially useful for defining algorithms that continuously update a model. The following code starts with a stream and applies the iteration body continuously. Elements that are greater than 0 are sent back to the feedback channel, and the rest of the elements are forwarded downstream. See [iterations](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/#iterations) for a complete description.

    IterativeStream<Long> iteration = initialStream.iterate();
    DataStream<Long> iterationBody = iteration.map (/*do something*/);
    DataStream<Long> feedback = iterationBody.filter(new FilterFunction<Long>(){
        @Override
        public boolean filter(Long value) throws Exception {
            return value > 0;
        }
    });
    iteration.closeWith(feedback);
    DataStream<Long> output = iterationBody.filter(new FilterFunction<Long>(){
        @Override
        public boolean filter(Long value) throws Exception {
            return value <= 0;
        }
    });


**Extract Timestamps**  
DataStream → DataStream

Extracts timestamps from records in order to work with windows that use event time semantics. See [Event Time](https://ci.apache.org/projects/flink/flink-docs-release-1.10/dev/event_time.html).

    stream.assignTimestamps (new TimeStampExtractor() {...});


The following transformations are available on data streams of Tuples:

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/#tab_java_1)

Transformation

Description

**Project**  
DataStream → DataStream

Selects a subset of fields from the tuples

    DataStream<Tuple3<Integer, Double, String>> in = // [...]
    DataStream<Tuple2<String, Integer>> out = in.project(2,0);

# Physical partitioning

Flink also gives low-level control (if desired) on the exact stream partitioning after a transformation, via the following functions.

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/#tab_java_2)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/#tab_scala_2)

Transformation

Description

**Custom partitioning**  
DataStream → DataStream

Uses a user-defined Partitioner to select the target task for each element.

    dataStream.partitionCustom(partitioner, "someKey");
    dataStream.partitionCustom(partitioner, 0);


**Random partitioning**  
DataStream → DataStream

Partitions elements randomly according to a uniform distribution.

    dataStream.shuffle();


**Rebalancing (Round-robin partitioning)**  
DataStream → DataStream

Partitions elements round-robin, creating equal load per partition. Useful for performance optimization in the presence of data skew.

    dataStream.rebalance();


**Rescaling**  
DataStream → DataStream

Partitions elements, round-robin, to a subset of downstream operations. This is useful if you want to have pipelines where you, for example, fan out from each parallel instance of a source to a subset of several mappers to distribute load but don't want the full rebalance that rebalance() would incur. This would require only local data transfers instead of transferring data over network, depending on other configuration values such as the number of slots of TaskManagers.

The subset of downstream operations to which the upstream operation sends elements depends on the degree of parallelism of both the upstream and downstream operation. For example, if the upstream operation has parallelism 2 and the downstream operation has parallelism 6, then one upstream operation would distribute elements to three downstream operations while the other upstream operation would distribute to the other three downstream operations. If, on the other hand, the downstream operation has parallelism 2 while the upstream operation has parallelism 6 then three upstream operations would distribute to one downstream operation while the other three upstream operations would distribute to the other downstream operation.

In cases where the different parallelisms are not multiples of each other one or several downstream operations will have a differing number of inputs from upstream operations.

Please see this figure for a visualization of the connection pattern in the above example:

![Checkpoint barriers in data streams](https://ci.apache.org/projects/flink/flink-docs-release-1.10/fig/rescale.svg)

    dataStream.rescale();


**Broadcasting**  
DataStream → DataStream

Broadcasts elements to every partition.

    dataStream.broadcast();


# Task chaining and resource groups

Chaining two subsequent transformations means co-locating them within the same thread for better performance. Flink by default chains operators if this is possible (e.g., two subsequent map transformations). The API gives fine-grained control over chaining if desired:

Use `StreamExecutionEnvironment.disableOperatorChaining()` if you want to disable chaining in the whole job. For more fine grained control, the following functions are available. Note that these functions can only be used right after a DataStream transformation as they refer to the previous transformation. For example, you can use `someStream.map(...).startNewChain()`, but you cannot use `someStream.startNewChain()`.

A resource group is a slot in Flink, see [slots](https://ci.apache.org/projects/flink/flink-docs-release-1.10/ops/config.html#configuring-taskmanager-processing-slots). You can manually isolate operators in separate slots if desired.

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/#tab_java_3)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/operators/#tab_scala_3)

Transformation

Description

Start new chain

Begin a new chain, starting with this operator. The two mappers will be chained, and filter will not be chained to the first mapper.

    someStream.filter(...).map(...).startNewChain().map(...);

Disable chaining

Do not chain the map operator

    someStream.map(...).disableChaining();

Set slot sharing group

Set the slot sharing group of an operation. Flink will put operations with the same slot sharing group into the same slot while keeping operations that don't have the slot sharing group in other slots. This can be used to isolate slots. The slot sharing group is inherited from input operations if all input operations are in the same slot sharing group. The name of the default slot sharing group is "default", operations can explicitly be put into this group by calling slotSharingGroup("default").

    someStream.filter(...).slotSharingGroup("name");
