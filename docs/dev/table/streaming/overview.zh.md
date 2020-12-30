# 流式概念

Flink 的 [Table API](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/tableApi.html) 和 [SQL](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/) 是流批统一的 API。 这意味着 Table API & SQL 在无论有限的批式输入还是无限的流式输入下，都具有相同的语义。 因为传统的关系代数以及 SQL 最开始都是为了批式处理而设计的， 关系型查询在流式场景下不如在批式场景下容易懂。

下面这些页面包含了概念、实际的限制，以及流式数据处理中的一些特定的配置。

## 接下来？

- [动态表](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/dynamic_tables.html): 描述了动态表的概念。
- [时间属性](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/time_attributes.html): 解释了时间属性以及它是如何在 Table API & SQL 中使用的。
- [流上的 Join](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/joins.html): 支持的几种流上的 Join。
- [时态（temporal）表](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/versioned_tables.html): 描述了时态表的概念。
- [查询配置](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/query_configuration.html): Table API & SQL 特定的配置。

[ Back to top](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/#top)