# 状态与容错

你将在本节中了解到 Flink 提供的用于编写有状态程序的 API，想了解更多有状态流处理的概念，请查看[有状态的流处理](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/concepts/stateful-stream-processing.html)[ Back to top](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/state/#top)

## 接下来看什么?

- [Working with State](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/state/state.html): 描述了如何在 Flink 应用程序中使用状态，以及不同类型的状态。
- [The Broadcast State 模式](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/state/broadcast_state.html): 描述了如何将广播流和非广播流进行连接从而交换数据。
- [Checkpointing](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/state/checkpointing.html): 介绍了如何开启和配置 checkpoint，以实现状态容错。
- [Queryable State](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/state/queryable_state.html): 介绍了如何从外围访问 Flink 的状态。
- [状态数据结构升级](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/state/schema_evolution.html): 介绍了状态数据结构升级相关的内容。
- [Managed State 的自定义序列化器](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/state/custom_serialization.html): 介绍了如何实现自定义的序列化器，尤其是如何支持状态数据结构升级