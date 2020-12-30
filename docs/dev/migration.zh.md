# API 迁移指南

- 从 Flink 1.3+ 迁移到 Flink 1.7
  - [Serializer snapshots 的 API 变更](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/migration.html#serializer-snapshots-的-api-变更)

有关从 Flink 1.3 之前版本迁移的信息，请参阅[旧版本迁移指南](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/migration.html)。



## 从 Flink 1.3+ 迁移到 Flink 1.7



### Serializer snapshots 的 API 变更

这主要和用户为其状态实现的自定义 `TypeSerializer` 有关。

目前旧接口 `TypeSerializerConfigSnapshot` 已弃用，请使用新的 `TypeSerializerSnapshot` 接口取而代之。有关如何迁移的详细信息和指南，请参阅[如何从 Flink 1.7 之前的 serializer snapshot 接口进行迁移](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/state/custom_serialization.html#migrating-from-deprecated-serializer-snapshot-apis-before-flink-17).

[ Back to top](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/migration.html#top)