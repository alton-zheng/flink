# Flink

### Flink实时计算时落磁盘吗

**不落，是内存计算**

&nbsp;

### 日活DAU的统计需要注意什么

&nbsp;

### Flink调优

##  

### Flink的容错是怎么做的

**定期 checkpoint 存储 oprator state 及 keyedstate 到 stateBackend **

## 

### 5.Parquet格式的好处？什么时候读的快什么时候读的慢

在各种列存储中，我们最终选择parquet的原因有许多。除了parquet自身的优点，还有以下因素

A、公司当时已经上线spark 集群，而spark天然支持parquet，并为其推荐的存储格式(默认存储为parquet)。

B、hive 支持parquet格式存储，如果以后使用hiveql 进行查询，也完全兼容。



### 6.flink中checkPoint为什么状态有保存在内存中这样的机制？为什么要开启checkPoint?

开启checkpoint可以容错，程序自动重启的时候可以从checkpoint中恢复数据

##  

### 7.flink保证Exactly_Once的原理？

1.开启checkpoint

2.source支持数据重发

3.sink支持事务，可以分2次提交，如kafka；或者sink支持幂等，可以覆盖之前写入的数据，如redis

满足以上三点，可以保证Exactly_Once

##  

### 8.flink的时间形式和窗口形式有几种？有什么区别，你们用在什么场景下的？

Global Window 和 Keyed Window

在运用窗口计算时，Flink 根据上游数据集是否为 KeyedStream 类型，对应的Windows 也会有所不同。

-  Keyed Window：上游数据集如果是 KeyedStream 类型，则调用 DataStream API 的 window()方法，数据会根据 Key 在不同的 Task 实例中并行分别计算，最后得出针对每个 Key 统计的结果。
-  Global Window：如果是 Non-Keyed 类型，则调用 WindowsAll()方法，所有的数据都会71在窗口算子中由到一个 Task 中计算，并得到全局统计结果。

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
//读取文件数据
val data = streamEnv.readTextFile(getClass.getResource("/station.log").getPath)
.map(line=>{
var arr =line.split(",")
new
StationLog(arr(0).trim,arr(1).trim,arr(2).trim,arr(3).trim,arr(4).trim.toLong,arr(5).trim.to
Long)
})
//Global Window
data.windowAll(自定义的WindowAssigner)
//Keyed Window
data.keyBy(_.sid)
.window(自定义的WindowAssigner)
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

Time Window 和 Count Window

基于业务数据的方面考虑，Flink 又支持两种类型的窗口，一种是基于时间的窗口叫Time Window。还有一种基于输入数据数量的窗口叫 Count Window

Time Window（时间窗口）

根据不同的业务场景，Time Window 也可以分为三种类型，分别是滚动窗口(Tumbling Window)、滑动窗口（Sliding Window）和会话窗口（Session Window）

滚动窗口(Tumbling Window)

滚动窗口是根据固定时间进行切分，且窗口和窗口之间的元素互不重叠。这种类型的窗口的最大特点是比较简单。只需要指定一个窗口长度（window size）。

![img](https://img2020.cnblogs.com/blog/2181007/202011/2181007-20201129212235383-1142456097.png)

 

 

```
//每隔5秒统计每个基站的日志数量
data.map(stationLog=>((stationLog.sid,1)))
.keyBy(_._1)
.timeWindow(Time.seconds(5))
//.window(TumblingEventTimeWindows.of(Time.seconds(5)))
.sum(1) //聚合
```

其中时间间隔可以是 Time.milliseconds(x)、Time.seconds(x)或 Time.minutes(x)。

滑动窗口（Sliding Window）

滑动窗口也是一种比较常见的窗口类型，其特点是在滚动窗口基础之上增加了窗口滑动时间（Slide Time），且允许窗口数据发生重叠。当 Windows size 固定之后，窗口并不像滚动窗口按照 Windows Size 向前移动，而是根据设定的 Slide Time 向前滑动。窗口之间的数据重叠大小根据 Windows size 和 Slide time 决定，当 Slide time 小于 Windows size便会发生窗口重叠，Slide size 大于 Windows size 就会出现窗口不连续，数据可能不能在任何一个窗口内计算，Slide size 和 Windows size 相等时，Sliding Windows 其实就是Tumbling Windows。

![img](https://img2020.cnblogs.com/blog/2181007/202011/2181007-20201129212514617-1384743773.png)

 

```
//每隔3秒计算最近5秒内，每个基站的日志数量
data.map(stationLog=>((stationLog.sid,1)))
.keyBy(_._1)
.timeWindow(Time.seconds(5),Time.seconds(3))
//.window(SlidingEventTimeWindows.of(Time.seconds(5),Time.seconds(3)))
.sum(1)
```

会话窗口（Session Window）

会话窗口（Session Windows）主要是将某段时间内活跃度较高的数据聚合成一个窗口进行计算，窗口的触发的条件是 Session Gap，是指在规定的时间内如果没有数据活跃接入，则认为窗口结束，然后触发窗口计算结果。需要注意的是如果数据一直不间断地进入窗口，也会导致窗口始终不触发的情况。与滑动窗口、滚动窗口不同的是，Session Windows 不需要有固定 windows size 和 slide time，只需要定义 session gap，来规定不活跃数据的时间上限即可。

![img](https://img2020.cnblogs.com/blog/2181007/202011/2181007-20201129212711999-949674822.png)

 

```
//3秒内如果没有数据进入，则计算每个基站的日志数量
data.map(stationLog=>((stationLog.sid,1)))
.keyBy(_._1)
.window(EventTimeSessionWindows.withGap(Time.seconds(3)))
.sum(1)
```

##  

Count Window（数量窗口）

 Count Window 也有滚动窗口、滑动窗口等。由于使用比较少，不再赘述。



### flink的背压说下？

**Flink中的背压**

![在这里插入图片描述](https://img-blog.csdnimg.cn/20190901201717761.png)
Flink 没有使用任何复杂的机制来解决背压问题，因为根本不需要那样的方案！它利用自身作为纯数据流引擎的优势来优雅地响应背压问题。

Flink 在运行时主要由 operators 和 streams 两大组件构成。每个 operator 会消费中间态的流，并在流上进行转换，然后生成新的流。对于 Flink 的网络机制一种形象的类比是，Flink 使用了高效有界的分布式阻塞队列，就像 Java 通用的阻塞队列（BlockingQueue）一样。使用 BlockingQueue 的话，一个较慢的接受者会降低发送者的发送速率，因为一旦队列满了（有界队列）发送者会被阻塞。Flink 解决背压的方案就是这种感觉。

在 Flink 中，这些分布式阻塞队列就是这些逻辑流，而队列容量是通过缓冲池来（LocalBufferPool）实现的。每个被生产和被消费的流都会被分配一个缓冲池。缓冲池管理着一组缓冲(Buffer)，缓冲在被消费后可以被回收循环利用。这很好理解：你从池子中拿走一个缓冲，填上数据，在数据消费完之后，又把缓冲还给池子，之后你可以再次使用它。

举例说明Flink背压的过程：
下图有一个简单的flow，它由两个task组成
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190901200743121.png)
1、记录A进入Flink，然后Task1处理
2、Task1处理后的结果被序列化进缓存区
3、Task2从缓存区内读取一些数据，缓存区内将有更多的空间
4、如果哦Task2处理的较慢，Task1的缓存区很快填满，发送速度随之下降。
注意：记录能被Flink处理的前提是：必须有空闲可用的缓存区（Buffer）。

##  

### 10.flink的watermark机制说下，以及怎么解决数据乱序的问题？

watermark的作用

watermark是用于处理乱序事件的，而正确的处理乱序事件，通常用watermark机制结合window来实现。

我们知道，流处理从事件产生，到流经source，再到operator，中间是有一个过程和时间的。虽然大部分情况下，流到operator的数据都是按照事件产生的时间顺序来的，但是也不排除由于网络、背压等原因，导致乱序的产生（out-of-order或者说late element）。

但是对于late element，我们又不能无限期的等下去，必须要有个机制来保证一个特定的时间后，必须触发window去进行计算了。这个特别的机制，就是watermark。

watermark解决迟到的数据

out-of-order/late element

实时系统中，由于各种原因造成的延时，造成某些消息发到flink的时间延时于事件产生的时间。如果基于event time构建window，但是对于late element，我们又不能无限期的等下去，必须要有个机制来保证一个特定的时间后，必须触发window去进行计算了。这个特别的机制，就是watermark。

Watermarks(水位线)就是来处理这种问题的机制

1.参考google的DataFlow。

2.是event time处理进度的标志。

3.表示比watermark更早(更老)的事件都已经到达(没有比水位线更低的数据 )。

4.基于watermark来进行窗口触发计算的判断。



### 11.flink on yarn执行流程

![img](https://obs-emcsapp-public.obs.cn-north-4.myhwclouds.com/wechatSpider/modb_ba447cae-006b-11eb-a419-5254001c05fe.png)

​    Flink任务提交后，Client向HDFS上传Flink的Jar包和配置，之后向Yarn ResourceManager提交任务，ResourceManager分配Container资源并通知对应的NodeManager启动ApplicationMaster，ApplicationMaster启动后加载Flink的Jar包和配置构建环境，然后启动JobManager，之后ApplicationMaster向ResourceManager申请资源启动TaskManager，ResourceManager分配Container资源后，由ApplicationMaster通知资源所在节点的NodeManager启动TaskManager，NodeManager加载Flink的Jar包和配置构建环境并启动TaskManager，TaskManager启动后向JobManager发送心跳包，并等待JobManager向其分配任务。

##  

### 12.说一说spark 和flink 的区别 

- 技术理念不同

Spark的技术理念是使用微批来模拟流的计算,基于Micro-batch,数据流以时间为单位被切分为一个个批次,通过分布式数据集RDD进行批量处理,是一种伪实时。
 而Flink是基于事件驱动的，它是一个面向流的处理框架, Flink基于每个事件一行一行地流式处理，是真正的流式计算. 另外他也可以基于流来模拟批进行计算实现批处理,所以他在技术上具有更好的扩展性,未来可能会成为一个统一的大数据处理引擎

- 吞吐量(throughputs)& 延时(latency)- 性能相关的指标，高吞吐和低延迟某种意义上是不可兼得的，但好的流引擎应能兼顾高吞吐&低延时

因为他们技术理念的不同,也就导致了性能相关的指标的差别,spark是基于微批的,而且流水线优化做的很好,所以说他的吞入量是最大的,但是付出了延迟的代价,它的延迟是秒级;而Flink是基于事件的,消息逐条处理,而且他的容错机制很轻量级,所以他能在兼顾高吞吐量的同时又有很低的延迟,它的延迟能够达到毫秒级;

- 时间机制

SparkStreaming只支持处理时间, 折中地使用processing time来近似地实现event time相关的业务。显然，使用processing time模拟event time必然会产生一些误差， 特别是在产生数据堆积的时候，误差则更明显，甚至导致计算结果不可用
 Structured streaming 支持处理时间和事件时间，同时支持 watermark 机制处理滞后数据
 Flink 支持三种时间机制：事件时间，注入时间，处理时间，同时支持 watermark 机制处理迟到的数据,说明Flink在处理乱序大实时数据的时候,优势比较大

- 编程模型,和kafka的结合

其实和Kafka结合的区别还是跟他们的设计理念有关,SparkStreaming是基于微批处理的,所以他采用DirectDstream的方式根据计算出的每个partition要取数据的Offset范围,拉取一批数据形成Rdd进行批量处理,而且该Rdd和kafka的分区是一一对应的;
 Flink是真正的流处理,他是基于事件触发机制进行处理,在KafkaConsumer拉取一批数据以后,Flink将其经过处理之后变成,逐个Record发送的事件触发式的流处理
 另外,Flink支持动态发现新增topic或者新增partition,而SparkStreaming和0.8版本的kafka结合是不支持的,后来跟0.10版本的kafka结合的时候,支持了,看了源码;