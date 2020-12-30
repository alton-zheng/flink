# Data Source 和 Sink 的容错保证

当程序出现错误的时候，Flink 的容错机制能恢复并继续运行程序。这种错误包括机器硬件故障、网络故障、瞬态程序故障等等。

只有当 source 参与了快照机制的时候，Flink 才能保证对自定义状态的精确一次更新。下表列举了 Flink 与其自带连接器的状态更新的保证。

请阅读各个连接器的文档来了解容错保证的细节。

| Source                | Guarantees                           | Notes                             |
| :-------------------- | :----------------------------------- | :-------------------------------- |
| Apache Kafka          | 精确一次                             | 根据你的版本用恰当的 Kafka 连接器 |
| AWS Kinesis Streams   | 精确一次                             |                                   |
| RabbitMQ              | 至多一次 (v 0.10) / 精确一次 (v 1.0) |                                   |
| Twitter Streaming API | 至多一次                             |                                   |
| Google PubSub         | 至少一次                             |                                   |
| Collections           | 精确一次                             |                                   |
| Files                 | 精确一次                             |                                   |
| Sockets               | 至多一次                             |                                   |

为了保证端到端精确一次的数据交付（在精确一次的状态语义上更进一步），sink需要参与 checkpointing 机制。下表列举了 Flink 与其自带 sink 的交付保证（假设精确一次状态更新）。



| Sink                | Guarantees          | Notes                                      |
| :------------------ | :------------------ | :----------------------------------------- |
| Elasticsearch       | 至少一次            |                                            |
| Kafka producer      | 至少一次 / 精确一次 | 当使用事务生产者时，保证精确一次 (v 0.11+) |
| Cassandra sink      | 至少一次 / 精确一次 | 只有当更新是幂等时，保证精确一次           |
| AWS Kinesis Streams | 至少一次            |                                            |
| File sinks          | 精确一次            |                                            |
| Socket sinks        | 至少一次            |                                            |
| Standard output     | 至少一次            |                                            |
| Redis sink          | 至少一次            |                                            |