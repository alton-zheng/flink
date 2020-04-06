# RabbitMQ 连接器

## RabbitMQ 连接器的许可证

Flink 的 RabbitMQ 连接器依赖了 "RabbitMQ AMQP Java Client"，它基于三种协议下发行：Mozilla Public License 1.1 ("MPL")、GNU General Public License version 2 ("GPL") 和 Apache License version 2 ("ASL")。

Flink 自身既没有复用 "RabbitMQ AMQP Java Client" 的代码，也没有将 "RabbitMQ AMQP Java Client" 打二进制包。

如果用户发布的内容是基于 Flink 的 RabbitMQ 连接器的（进而重新发布了 "RabbitMQ AMQP Java Client" ），那么一定要注意这可能会受到 Mozilla Public License 1.1 ("MPL")、GNU General Public License version 2 ("GPL")、Apache License version 2 ("ASL") 协议的限制.

## RabbitMQ 连接器

这个连接器可以访问 [RabbitMQ](http://www.rabbitmq.com/) 的数据流。使用这个连接器，需要在工程里添加下面的依赖：

```xml
<dependency>
  <groupId>org.apache.flink</groupId>
  <artifactId>flink-connector-rabbitmq_2.11</artifactId>
  <version>1.10.0</version>
</dependency>
```

注意连接器现在没有包含在二进制发行版中。集群执行的相关信息请参考 [这里](../projectsetup/dependencies.html).

### 安装 RabbitMQ
安装 RabbitMQ 请参考 [RabbitMQ 下载页面](http://www.rabbitmq.com/download.html)。安装完成之后，服务会自动拉起，应用程序就可以尝试连接到 RabbitMQ 了。

### RabbitMQ Source

`RMQSource` 负责从 RabbitMQ 中消费数据，可以配置三种不同级别的保证：

1. **精确一次**: 保证精确一次需要以下条件 -
 - *开启 checkpointing*: 开启 checkpointing 之后，消息在 checkpoints 
 完成之后才会被确认（然后从 RabbitMQ 队列中删除）.
 - *使用关联标识（Correlation ids）*: 关联标识是 RabbitMQ 的一个特性，消息写入 RabbitMQ 时在消息属性中设置。
 从 checkpoint 恢复时有些消息可能会被重复处理，source 可以利用关联标识对消息进行去重。
 - *非并发 source*: 为了保证精确一次的数据投递，source 必须是非并发的（并行度设置为1）。
  这主要是由于 RabbitMQ 分发数据时是从单队列向多个消费者投递消息的。

2. **至少一次**:  在 checkpointing 开启的条件下，如果没有使用关联标识或者 source 是并发的，
那么 source 就只能提供至少一次的保证。

3. **无任何保证**: 如果没有开启 checkpointing，source 就不能提供任何的数据投递保证。
使用这种设置时，source 一旦接收到并处理消息，消息就会被自动确认。

下面是一个保证 exactly-once 的 RabbitMQ source 示例。 注释部分展示了更加宽松的保证应该如何配置。

```java
final StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
// checkpointing is required for exactly-once or at-least-once guarantees
env.enableCheckpointing(...);

final RMQConnectionConfig connectionConfig = new RMQConnectionConfig.Builder()
    .setHost("localhost")
    .setPort(5000)
    ...
    .build();
    
final DataStream<String> stream = env
    .addSource(new RMQSource<String>(
        connectionConfig,            // config for the RabbitMQ connection
        "queueName",                 // name of the RabbitMQ queue to consume
        true,                        // use correlation ids; can be false if only at-least-once is required
        new SimpleStringSchema()))   // deserialization schema to turn messages into Java objects
    .setParallelism(1);              // non-parallel source is only required for exactly-once
```

```scala
val env = StreamExecutionEnvironment.getExecutionEnvironment
// checkpointing is required for exactly-once or at-least-once guarantees
env.enableCheckpointing(...)

val connectionConfig = new RMQConnectionConfig.Builder()
    .setHost("localhost")
    .setPort(5000)
    ...
    .build
    
val stream = env
    .addSource(new RMQSource[String](
        connectionConfig,            // config for the RabbitMQ connection
        "queueName",                 // name of the RabbitMQ queue to consume
        true,                        // use correlation ids; can be false if only at-least-once is required
        new SimpleStringSchema))     // deserialization schema to turn messages into Java objects
    .setParallelism(1)               // non-parallel source is only required for exactly-once
```

### RabbitMQ Sink
该连接器提供了一个 `RMQSink` 类，用来向 RabbitMQ 队列发送数据。下面是设置 RabbitMQ sink 的代码示例：

```java
final DataStream<String> stream = ...

final RMQConnectionConfig connectionConfig = new RMQConnectionConfig.Builder()
    .setHost("localhost")
    .setPort(5000)
    ...
    .build();
    
stream.addSink(new RMQSink<String>(
    connectionConfig,            // config for the RabbitMQ connection
    "queueName",                 // name of the RabbitMQ queue to send messages to
    new SimpleStringSchema()));  // serialization schema to turn Java objects to messages
```

```scala
val stream: DataStream[String] = ...

val connectionConfig = new RMQConnectionConfig.Builder()
    .setHost("localhost")
    .setPort(5000)
    ...
    .build
    
stream.addSink(new RMQSink[String](
    connectionConfig,         // config for the RabbitMQ connection
    "queueName",              // name of the RabbitMQ queue to send messages to
    new SimpleStringSchema))  // serialization schema to turn Java objects to messages
```

更多关于 RabbitMQ 的信息请参考 [这里](http://www.rabbitmq.com/).

