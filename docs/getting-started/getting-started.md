# 入门指南
上手使用 `Apache Flink` 有很多方式，哪一个最适合你取决于你的目标和以前的经验。

## 初识 Flink
通过 `Docker Playgrounds` 提供沙箱的 `Flink` 环境，你只需花几分钟做些简单设置，就可以开始探索和使用 `Flink`。
- [Operations Playground](docker-playgrounds/flink-operations-playground.md) 向你展示如何使用 `Flink` 编写数据流应用程序。你可以体验 `Flink` 如何从故障中恢复应用程序，升级、提高并行度、降低并行度和监控运行的状态指标等特性。

## Flink API 入门
**代码练习**是入门的最佳方式，通过代码练习可以逐步深入理解 `Flink API`。 下边的例子演示了如何使用 `Flink` 的代码框架开始构建一个基础的 `Flink` 项目，和如何逐步将其扩展为一个简单的应用程序。
- [DataStream API](walkthroughs/datastream_api.md) 示例 展示了如何编写一个基本的 `DataStream` 应用程序。 `DataStream API` 是 `Flink` 的主要抽象，用于通过 `Java` 或 `Scala` 实现具有复杂时间语义的有状态数据流处理的应用程序。
- [Table API](walkthroughs/table_api.md) 示例 演示了如何在批处中使用简单的 `Table API` 进行查询，以及如何将其扩展为流处理中的查询。`Table API` 是 `Flink` 的语言嵌入式关系 `API`，用于在 `Java` 或 `Scala` 中编写类 `SQL` 的查询，这些查询会自动进行优化。`Table API` 查询可以使用一致的语法和语义同时在批处理或流数据上运行。