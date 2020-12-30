# Google Cloud PubSub

这个连接器可向 [Google Cloud PubSub](https://cloud.google.com/pubsub) 读取与写入数据。添加下面的依赖来使用此连接器:

```
<dependency>
  <groupId>org.apache.flink</groupId>
  <artifactId>flink-connector-gcp-pubsub_2.11</artifactId>
  <version>1.12.0</version>
</dependency>
```

**注意**：此连接器最近才加到 Flink 里，还未接受广泛测试。

注意连接器目前还不是二进制发行版的一部分，添加依赖、打包配置以及集群运行信息请参考[这里](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/project-configuration.html)

## Consuming or Producing PubSubMessages

连接器可以接收和发送 Google PubSub 的信息。和 Google PubSub 一样，这个连接器能够保证`至少一次`的语义。

### PubSub SourceFunction

```
PubSubSource` 类的对象由构建类来构建: `PubSubSource.newBuilder(...)
```

有多种可选的方法来创建 PubSubSource，但最低要求是要提供 Google Project、Pubsub 订阅和反序列化 PubSubMessages 的方法。

Example:

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/connectors/pubsub.html#tab_Java_0)

```
StreamExecutionEnvironment streamExecEnv = StreamExecutionEnvironment.getExecutionEnvironment();

DeserializationSchema<SomeObject> deserializer = (...);
SourceFunction<SomeObject> pubsubSource = PubSubSource.newBuilder()
                                                      .withDeserializationSchema(deserializer)
                                                      .withProjectName("project")
                                                      .withSubscriptionName("subscription")
                                                      .build();

streamExecEnv.addSource(source);
```

当前还不支持 PubSub 的 source functions [pulls](https://cloud.google.com/pubsub/docs/pull) messages 和 [push endpoints](https://cloud.google.com/pubsub/docs/push)。

### PubSub Sink

```
PubSubSink` 类的对象由构建类来构建: `PubSubSink.newBuilder(...)
```

构建类的使用方式与 PubSubSource 类似。

Example:

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/connectors/pubsub.html#tab_Java_1)

```
DataStream<SomeObject> dataStream = (...);

SerializationSchema<SomeObject> serializationSchema = (...);
SinkFunction<SomeObject> pubsubSink = PubSubSink.newBuilder()
                                                .withSerializationSchema(serializationSchema)
                                                .withProjectName("project")
                                                .withSubscriptionName("subscription")
                                                .build()

dataStream.addSink(pubsubSink);
```

### Google Credentials

应用程序需要使用 [Credentials](https://cloud.google.com/docs/authentication/production) 来通过认证和授权才能使用 Google Cloud Platform 的资源，例如 PubSub。

上述的两个构建类都允许你提供 Credentials, 但是连接器默认会通过环境变量: [GOOGLE_APPLICATION_CREDENTIALS](https://cloud.google.com/docs/authentication/production#obtaining_and_providing_service_account_credentials_manually) 来获取 Credentials 的路径。

如果你想手动提供 Credentials，例如你想从外部系统读取 Credentials，你可以使用 `PubSubSource.newBuilder(...).withCredentials(...)`。

### 集成测试

在集成测试的时候，如果你不想直接连 PubSub 而是想读取和写入一个 docker container，可以参照 [PubSub testing locally](https://cloud.google.com/pubsub/docs/emulator)。

下面的例子展示了如何使用 source 来从仿真器读取信息并发送回去：

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/connectors/pubsub.html#tab_Java_2)

```
String hostAndPort = "localhost:1234";
DeserializationSchema<SomeObject> deserializationSchema = (...);
SourceFunction<SomeObject> pubsubSource = PubSubSource.newBuilder()
                                                      .withDeserializationSchema(deserializationSchema)
                                                      .withProjectName("my-fake-project")
                                                      .withSubscriptionName("subscription")
                                                      .withPubSubSubscriberFactory(new PubSubSubscriberFactoryForEmulator(hostAndPort, "my-fake-project", "subscription", 10, Duration.ofSeconds(15), 100))
                                                      .build();
SerializationSchema<SomeObject> serializationSchema = (...);
SinkFunction<SomeObject> pubsubSink = PubSubSink.newBuilder()
                                                .withSerializationSchema(serializationSchema)
                                                .withProjectName("my-fake-project")
                                                .withSubscriptionName("subscription")
                                                .withHostAndPortForEmulator(hostAndPort)
                                                .build();

StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
env.addSource(pubsubSource)
   .addSink(pubsubSink);
```

### 至少一次语义保证

#### SourceFunction

有很多原因导致会一个信息会被多次发出，例如 Google PubSub 的故障。

另一个可能的原因是超过了确认的截止时间，即收到与确认信息之间的时间间隔。PubSubSource 只有在信息被成功快照之后才会确认以保证至少一次的语义。这意味着，如果你的快照间隔大于信息确认的截止时间，那么你订阅的信息很有可能会被多次处理。

因此，我们建议把快照的间隔设置得比信息确认截止时间更短。

参照 [PubSub](https://cloud.google.com/pubsub/docs/subscriber) 来增加信息确认截止时间。

注意: `PubSubMessagesProcessedNotAcked` 显示了有多少信息正在等待下一个 checkpoint 还没被确认。

#### SinkFunction

Sink function 会把准备发到 PubSub 的信息短暂地缓存以提高性能。每次 checkpoint 前，它会刷新缓冲区，并且只有当所有信息成功发送到 PubSub 之后，checkpoint 才会成功完成。