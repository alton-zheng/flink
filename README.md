# Flink

本文档基于本人学习Flink 过程中，对官文加上个人心得整理得出， 如有不好的地方请指教。 

由于其核心代码主要由`Java`编写(所有功能都可以使用`scala`实现)。文档代码部分主要贴`Java`, 仅会包含部分`Scala`。如需要`Scala`相关的文档，请查阅官方文档！  

Email: alton_z@outlook.com

- [Apache Flink](docs/apache-flink.md)
---
- [flink-docs-release-1.9](docs/flink-docs-release-1.9.md)
---

## Getting Started
- API 教程
  - 教程
    - API 教程
      - [DataStream API](getting-started/tutorials/datastream_api.md)
      - [Python API](getting-started/tutorials/python_table_api.md)
    - 安装教程
      - [本地安装](getting-started/tutorials/local_setup.md)
      - [在windows 上运行Flink](getting-started/tutorials/flink_on_windows.md) 不提供windows安装文档，如有需要请查阅官方。
  - 示例
    - [概览](getting-started/example.md#示例)
    - [Batch 示例](getting-started/example.md#Batch示例)
  - Docker Playgrounds
    - [Flink Operations Playground](getting-started/docker-playgrounds/flink-operations-playground.md) 
    
## 概念
- [编程模型](concepts/programming-model.md)
- [分布式运行](concepts/runtime.md)
- [术语表](concepts/glossary.md)

## 应用开发
- 项目构建设置
  -   [Java 项目模板](dev/projectsetup/java_api_quickstart.md) 
  -   [Scala 项目模板](dev/projectsetup/scala_api_quickstart.md)
  -   [配置依赖、连接器、类库](dev/projectsetup/dependencies.md)
- Basic API Concepts
  -   [概览](dev/api_concepts.md)
  -   [Scala API Extensions](dev/scala_api_extensions.md)
  -   [Java Lambda 表达式](dev/java_lambdas.md)

- Streaming (DataStream API)
  - [概览](dev/datastream_api.md)
  - Event Time
    - [概览](dev/event_time.md)
    - [Generating Timestamps / Watermarks](dev/event_timestamps_watermarks.md)
    - [Pre-defined Timestamp Extractors / Watermark Emitters](dev/event_timestamp_extractors.md)
  - 状态与容错
    - [概览](dev/stream/state/overview.md)
    - [Working with State](dev/stream/state/state.md)
    - [Broadcast State 模式](dev/stream/state/broadcast_state.md)
    - [Checkpointing](dev/stream/state/checkpointing.md)
    - [可查询状态](dev/stream/state/queryable_state.md)
    - [State Backends](dev/stream/state/state_backends.md)
    - [状态数据结构升级](dev/stream/state/schema_evolution.md)
    - [自定义状态序列化](dev/stream/state/custom_serialization.md)
  - 算子
    - [概览](dev/stream/operators/overview.md)
    - [窗口](dev/stream/operators/windows.md)
    - [Joining](dev/stream/operators/joining.md)
    - [Process Function](dev/stream/operators/process_function.md)
    - [异步 I/O](dev/stream/operators/asyncio.md)
  - Connectors
    - [概览](dev/connectors/)
    - [容错保证](dev/connectors/guarantees.md)
    - [Kafka](dev/connectors/kafka.md)
    - [Cassandra](dev/connectors/cassandra.md)
    - [Kinesis](dev/connectors/kinesis.md)
    - [Elasticsearch](dev/connectors/elasticsearch.md)
    - [Hadoop FileSystem](dev/connectors/filesystem_sink.md)
    - [Streaming File Sink](dev/connectors/streamfile_sink.md)
    - [RabbitMQ](dev/connectors/rabbitmq.md)
    - [NiFi](dev/connectors/nifi.md)
    - [Google Cloud PubSub](dev/connectors/pubsub.md)
    - [Twitter](dev/connectors/twitter.md)
  - [Side Outputs](dev/stream/side_output.md)
  - [测试](dev/stream/testing.md)
  - [实验功能](dev/stream/experimental.md)

*   [Batch (DataSet API) ](dev/table/sqlClient.md#collapse-72)
*   [Table API &amp; SQL](dev/table/sqlClient.md#collapse-82)

    *   [概览](dev/table/)
    *   [概念与通用 API](dev/table/common.md)
    *   [Data Types](dev/table/types.md)
    *   [Streaming Concepts ](dev/table/sqlClient.md#collapse-85)
    *   [Connect to External Systems](dev/table/connect.md)
    *   [Table API](dev/table/tableApi.md)
    *   [SQL](dev/table/sql.md)
    *   [内置函数](dev/table/functions.md)
    *   [User-defined Sources &amp; Sinks](dev/table/sourceSinks.md)
    *   [自定义函数](dev/table/udfs.md)
    *   [Catalogs](dev/table/catalogs.md)
    *   [Hive ](dev/table/sqlClient.md#collapse-100)
        *   [概览](dev/table/hive/)
        *   [Reading &amp; Writing Hive Tables](dev/table/hive/read_write_hive.md)
        *   [Hive Functions](dev/table/hive/hive_functions.md)
        *   [Use Hive connector in scala shell](dev/table/hive/scala_shell_hive.md)
        *   [SQL 客户端](dev/table/sqlClient.md)
    *   [配置](dev/table/config.md)

*   [数据类型以及序列化 ](dev/table/sqlClient.md#collapse-108)

    *   [概览](dev/types_serialization.md)
    *   [自定义序列化器](dev/custom_serializers.md)

*   [管理执行 ](dev/table/sqlClient.md#collapse-111)

    *   [执行配置](dev/execution_configuration.md)
    *   [程序打包](dev/packaging.md)
    *   [并行执行](dev/parallel.md)
    *   [执行计划](dev/execution_plans.md)
    *   [Task 故障恢复](dev/task_failure_recovery.md)

*   [类库 ](dev/table/sqlClient.md#collapse-118)

    *   [事件处理 (CEP)](dev/libs/cep.md)
    *   [State Processor API](dev/libs/state_processor_api.md)
    *   [图计算: Gelly ](dev/table/sqlClient.md#collapse-121)

*   [最佳实践](dev/best_practices.md)

## 运维和部署
## 部署与运维
## Flink 开发
## 内幕
