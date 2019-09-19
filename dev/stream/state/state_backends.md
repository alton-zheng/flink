## State Backends
Flink提供了不同的状态后端，用于指定状态存储的方式和位置。

状态可以位于Java的堆上，也可以位于堆外。根据您的状态后端，Flink还可以管理应用程序的状态，这意味着Flink处理内存管理(如果必要的话可能溢出到磁盘)，以允许应用程序保存非常大的状态。默认情况下，配置文件会退出conf。yaml确定所有Flink作业的状态后端。

但是，可以根据每个作业重写缺省状态后端，如下所示。

有关可用状态后端、它们的优点、限制和配置参数的更多信息，请参见部署和操作中的相应部分。

```java
StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
env.setStateBackend(...);
```