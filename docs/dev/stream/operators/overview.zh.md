# 算子

用户通过算子能将一个或多个 DataStream 转换成新的 DataStream，在应用程序中可以将多个数据转换算子合并成一个复杂的数据流拓扑。

这部分内容将描述 Flink DataStream API 中基本的数据转换API，数据转换后各种数据分区方式，以及算子的链接策略。

- [数据流转换](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/operators/#数据流转换)
- [物理分区](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/operators/#物理分区)
- [算子链和资源组](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/operators/#算子链和资源组)



# 数据流转换

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/operators/#tab_Java_0)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/operators/#tab_Scala_0)
- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/operators/#tab_Python_0)



| Transformation                                               |                         Description                          |
| :----------------------------------------------------------- | :----------------------------------------------------------: |
| **Map** DataStream → DataStream                              | Takes one element and produces one element. A map function that doubles the values of the input stream:`DataStream<Integer> dataStream = //... dataStream.map(new MapFunction<Integer, Integer>() {    @Override    public Integer map(Integer value) throws Exception {        return 2 * value;    } });` |
| **FlatMap** DataStream → DataStream                          | Takes one element and produces zero, one, or more elements. A flatmap function that splits sentences to words:`dataStream.flatMap(new FlatMapFunction<String, String>() {    @Override    public void flatMap(String value, Collector<String> out)        throws Exception {        for(String word: value.split(" ")){            out.collect(word);        }    } });` |
| **Filter** DataStream → DataStream                           | Evaluates a boolean function for each element and retains those for which the function returns true. A filter that filters out zero values:`dataStream.filter(new FilterFunction<Integer>() {    @Override    public boolean filter(Integer value) throws Exception {        return value != 0;    } });` |
| **KeyBy** DataStream → KeyedStream                           | Logically partitions a stream into disjoint partitions. All records with the same key are assigned to the same partition. Internally, *keyBy()* is implemented with hash partitioning. There are different ways to [specify keys](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/state/state.html#keyed-datastream).This transformation returns a *KeyedStream*, which is, among other things, required to use [keyed state](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/state/state.html#keyed-state).`dataStream.keyBy(value -> value.getSomeKey()) // Key by field "someKey" dataStream.keyBy(value -> value.f0) // Key by the first element of a Tuple`**Attention** A type **cannot be a key** if:it is a POJO type but does not override the *hashCode()* method and relies on the *Object.hashCode()* implementation.it is an array of any type. |
| **Reduce** KeyedStream → DataStream                          | A "rolling" reduce on a keyed data stream. Combines the current element with the last reduced value and emits the new value.  A reduce function that creates a stream of partial sums:`keyedStream.reduce(new ReduceFunction<Integer>() {    @Override    public Integer reduce(Integer value1, Integer value2)    throws Exception {        return value1 + value2;    } });` |
| **Aggregations** KeyedStream → DataStream                    | Rolling aggregations on a keyed data stream. The difference between min and minBy is that min returns the minimum value, whereas minBy returns the element that has the minimum value in this field (same for max and maxBy).`keyedStream.sum(0); keyedStream.sum("key"); keyedStream.min(0); keyedStream.min("key"); keyedStream.max(0); keyedStream.max("key"); keyedStream.minBy(0); keyedStream.minBy("key"); keyedStream.maxBy(0); keyedStream.maxBy("key");` |
| **Window** KeyedStream → WindowedStream                      | Windows can be defined on already partitioned KeyedStreams. Windows group the data in each key according to some characteristic (e.g., the data that arrived within the last 5 seconds). See [windows](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/operators/windows.html) for a complete description of windows.`dataStream.keyBy(value -> value.f0).window(TumblingEventTimeWindows.of(Time.seconds(5))); // Last 5 seconds of data` |
| **WindowAll** DataStream → AllWindowedStream                 | Windows can be defined on regular DataStreams. Windows group all the stream events according to some characteristic (e.g., the data that arrived within the last 5 seconds). See [windows](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/operators/windows.html) for a complete description of windows.**WARNING:** This is in many cases a **non-parallel** transformation. All records will be gathered in one task for the windowAll operator.`dataStream.windowAll(TumblingEventTimeWindows.of(Time.seconds(5))); // Last 5 seconds of data` |
| **Window Apply** WindowedStream → DataStream AllWindowedStream → DataStream | Applies a general function to the window as a whole. Below is a function that manually sums the elements of a window.**Note:** If you are using a windowAll transformation, you need to use an AllWindowFunction instead.`windowedStream.apply (new WindowFunction<Tuple2<String,Integer>, Integer, Tuple, Window>() {    public void apply (Tuple tuple,            Window window,            Iterable<Tuple2<String, Integer>> values,            Collector<Integer> out) throws Exception {        int sum = 0;        for (value t: values) {            sum += t.f1;        }        out.collect (new Integer(sum));    } }); // applying an AllWindowFunction on non-keyed window stream allWindowedStream.apply (new AllWindowFunction<Tuple2<String,Integer>, Integer, Window>() {    public void apply (Window window,            Iterable<Tuple2<String, Integer>> values,            Collector<Integer> out) throws Exception {        int sum = 0;        for (value t: values) {            sum += t.f1;        }        out.collect (new Integer(sum));    } });` |
| **Window Reduce** WindowedStream → DataStream                | Applies a functional reduce function to the window and returns the reduced value.`windowedStream.reduce (new ReduceFunction<Tuple2<String,Integer>>() {    public Tuple2<String, Integer> reduce(Tuple2<String, Integer> value1, Tuple2<String, Integer> value2) throws Exception {        return new Tuple2<String,Integer>(value1.f0, value1.f1 + value2.f1);    } });` |
| **Aggregations on windows** WindowedStream → DataStream      | Aggregates the contents of a window. The difference between min and minBy is that min returns the minimum value, whereas minBy returns the element that has the minimum value in this field (same for max and maxBy).`windowedStream.sum(0); windowedStream.sum("key"); windowedStream.min(0); windowedStream.min("key"); windowedStream.max(0); windowedStream.max("key"); windowedStream.minBy(0); windowedStream.minBy("key"); windowedStream.maxBy(0); windowedStream.maxBy("key");` |
| **Union** DataStream* → DataStream                           | Union of two or more data streams creating a new stream containing all the elements from all the streams. Note: If you union a data stream with itself you will get each element twice in the resulting stream.`dataStream.union(otherStream1, otherStream2, ...);` |
| **Window Join** DataStream,DataStream → DataStream           | Join two data streams on a given key and a common window.`dataStream.join(otherStream)    .where(<key selector>).equalTo(<key selector>)    .window(TumblingEventTimeWindows.of(Time.seconds(3)))    .apply (new JoinFunction () {...});` |
| **Interval Join** KeyedStream,KeyedStream → DataStream       | Join two elements e1 and e2 of two keyed streams with a common key over a given time interval, so that e1.timestamp + lowerBound <= e2.timestamp <= e1.timestamp + upperBound`// this will join the two streams so that // key1 == key2 && leftTs - 2 < rightTs < leftTs + 2 keyedStream.intervalJoin(otherKeyedStream)    .between(Time.milliseconds(-2), Time.milliseconds(2)) // lower and upper bound    .upperBoundExclusive(true) // optional    .lowerBoundExclusive(true) // optional    .process(new IntervalJoinFunction() {...});` |
| **Window CoGroup** DataStream,DataStream → DataStream        | Cogroups two data streams on a given key and a common window.`dataStream.coGroup(otherStream)    .where(0).equalTo(1)    .window(TumblingEventTimeWindows.of(Time.seconds(3)))    .apply (new CoGroupFunction () {...});` |
| **Connect** DataStream,DataStream → ConnectedStreams         | "Connects" two data streams retaining their types. Connect allowing for shared state between the two streams.`DataStream<Integer> someStream = //... DataStream<String> otherStream = //... ConnectedStreams<Integer, String> connectedStreams = someStream.connect(otherStream);` |
| **CoMap, CoFlatMap** ConnectedStreams → DataStream           | Similar to map and flatMap on a connected data stream`connectedStreams.map(new CoMapFunction<Integer, String, Boolean>() {    @Override    public Boolean map1(Integer value) {        return true;    }     @Override    public Boolean map2(String value) {        return false;    } }); connectedStreams.flatMap(new CoFlatMapFunction<Integer, String, String>() {    @Override   public void flatMap1(Integer value, Collector<String> out) {       out.collect(value.toString());   }    @Override   public void flatMap2(String value, Collector<String> out) {       for (String word: value.split(" ")) {         out.collect(word);       }   } });` |
| **Iterate** DataStream → IterativeStream → DataStream        | Creates a "feedback" loop in the flow, by redirecting the output of one operator to some previous operator. This is especially useful for defining algorithms that continuously update a model. The following code starts with a stream and applies the iteration body continuously. Elements that are greater than 0 are sent back to the feedback channel, and the rest of the elements are forwarded downstream. See [iterations](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/operators/#iterations) for a complete description.`IterativeStream<Long> iteration = initialStream.iterate(); DataStream<Long> iterationBody = iteration.map (/*do something*/); DataStream<Long> feedback = iterationBody.filter(new FilterFunction<Long>(){    @Override    public boolean filter(Long value) throws Exception {        return value > 0;    } }); iteration.closeWith(feedback); DataStream<Long> output = iterationBody.filter(new FilterFunction<Long>(){    @Override    public boolean filter(Long value) throws Exception {        return value <= 0;    } });` |

下面的数据转换 API 支持对元组类型的 DataStream 进行转换：

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/operators/#tab_Java_1)
- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/operators/#tab_Python_1)



| Transformation                      |                         Description                          |
| :---------------------------------- | :----------------------------------------------------------: |
| **Project** DataStream → DataStream | 从元组类型的数据流中抽取元组中部分元素`DataStream<Tuple3<Integer, Double, String>> in = // [...] DataStream<Tuple2<String, Integer>> out = in.project(2,0);` |



# 物理分区

Flink 也提供以下方法让用户根据需要在数据转换完成后对数据分区进行更细粒度的配置。

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/operators/#tab_Java_2)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/operators/#tab_Scala_2)
- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/operators/#tab_Python_2)



| Transformation                                               |                         Description                          |
| :----------------------------------------------------------- | :----------------------------------------------------------: |
| **Custom partitioning** DataStream → DataStream              | Uses a user-defined Partitioner to select the target task for each element.`dataStream.partitionCustom(partitioner, "someKey"); dataStream.partitionCustom(partitioner, 0);` |
| **Random partitioning** DataStream → DataStream              | Partitions elements randomly according to a uniform distribution.`dataStream.shuffle();` |
| **Rebalancing (Round-robin partitioning)** DataStream → DataStream | Partitions elements round-robin, creating equal load per partition. Useful for performance optimization in the presence of data skew.`dataStream.rebalance();` |
| **Rescaling** DataStream → DataStream                        | Partitions elements, round-robin, to a subset of downstream operations. This is useful if you want to have pipelines where you, for example, fan out from each parallel instance of a source to a subset of several mappers to distribute load but don't want the full rebalance that rebalance() would incur. This would require only local data transfers instead of transferring data over network, depending on other configuration values such as the number of slots of TaskManagers.The subset of downstream operations to which the upstream operation sends elements depends on the degree of parallelism of both the upstream and downstream operation. For example, if the upstream operation has parallelism 2 and the downstream operation has parallelism 6, then one upstream operation would distribute elements to three downstream operations while the other upstream operation would distribute to the other three downstream operations. If, on the other hand, the downstream operation has parallelism 2 while the upstream operation has parallelism 6 then three upstream operations would distribute to one downstream operation while the other three upstream operations would distribute to the other downstream operation.In cases where the different parallelisms are not multiples of each other one or several downstream operations will have a differing number of inputs from upstream operations.Please see this figure for a visualization of the connection pattern in the above example:![Checkpoint barriers in data streams](https://ci.apache.org/projects/flink/flink-docs-release-1.12/fig/rescale.svg)`dataStream.rescale();` |
| **Broadcasting** DataStream → DataStream                     | Broadcasts elements to every partition.`dataStream.broadcast();` |



# 算子链和资源组

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/operators/#tab_Java_3)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/operators/#tab_Scala_3)
- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/operators/#tab_Python_3)

将两个算子链接在一起能使得它们在同一个线程中执行，从而提升性能。Flink 默认会将能链接的算子尽可能地进行链接(例如， 两个 map 转换操作)。此外， Flink 还提供了对链接更细粒度控制的 API 以满足更多需求：

如果想对整个作业禁用算子链，可以调用 `StreamExecutionEnvironment.disableOperatorChaining()`。下列方法还提供了更细粒度的控制。需要注 意的是， 这些方法只能在 DataStream 转换操作后才能被调用，因为它们只对前一次数据转换生效。例如，可以 `someStream.map(...).startNewChain()` 这样调用，而不能 `someStream.startNewChain()`这样。

一个资源组对应着 Flink 中的一个 slot 槽，更多细节请看[slots 槽](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#configuring-taskmanager-processing-slots)。 你可以根据需要手动地将各个算子隔离到不同的 slot 中。

| Transformation         |                         Description                          |
| :--------------------- | :----------------------------------------------------------: |
| Start new chain        | 以当前 operator 为起点开始新的连接。如下的两个 mapper 算子会链接在一起而 filter 算子则不会和第一个 mapper 算子进行链接。`someStream.filter(...).map(...).startNewChain().map(...);` |
| Disable chaining       | 任何算子不能和当前算子进行链接`someStream.map(...).disableChaining();` |
| Set slot sharing group | 配置算子的资源组。Flink 会将相同资源组的算子放置到同一个 slot 槽中执行，并将不同资源组的算子分配到不同的 slot 槽中，从而实现 slot 槽隔离。资源组将从输入算子开始继承如果所有输入操作都在同一个资源组。 Flink 默认的资源组名称为 "default"，算子可以显式调用 slotSharingGroup("default") 加入到这个资源组中。`someStream.filter(...).slotSharingGroup("name");` |