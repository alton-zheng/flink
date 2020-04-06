# State Backends

Flink 提供了多种 state backends，它用于指定状态的存储方式和位置。

状态可以位于 Java 的堆或堆外内存。取决于你的 state backend，Flink 也可以自己管理应用程序的状态。 为了让应用程序可以维护非常大的状态，Flink 可以自己管理内存（如果有必要可以溢写到磁盘）。 默认情况下，所有 Flink Job 会使用配置文件  *flink-conf.yaml*  中指定的 state backend。

但是，配置文件中指定的默认 state backend 会被 Job 中指定的 state backend 覆盖，如下所示。

关于可用的 state backend 更多详细信息，包括其优点、限制和配置参数等，请参阅[部署和运维](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/ops/state/state_backends.html)的相应部分。

```java
StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
    env.setStateBackend(...);
```