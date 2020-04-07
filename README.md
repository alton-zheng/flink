# Flink

本文档基于本人学习Flink 过程中，对官文加上个人心得整理得出， 如有不好的地方请指教。 

由于其核心代码主要由`Java`编写(所有功能都可以使用`scala`实现)。文档代码部分主要贴`Java`, 仅会包含部分`Scala`。如需要`Scala`相关的文档，请查阅官方文档！  

Email: alton_z@outlook.com

- [Apache Flink](docs/apache-flink.md)

## 翻译进度

- [开始](docs/getting-started/getting-started.md)
  - [x] 代码走读
    - [x] [DataStream API](docs/getting-started/walkthroughs/datastream_api.md)
    - [x] [Table API](docs/getting-started/walkthroughs/table_api.md)
  - [x] docker-playgrounds
    - [ ] [flink-operations-playground](docs/getting-started/docker-playgrounds/flink-operations-playground.md)
  - [x] 教程
    - [x] [Python API](docs/getting-started/tutorials/python_table_api.md)
    - [ ] [本地安装](docs/getting-started/tutorials/local_setup.md)
    - [ ] [在Windows 上运行Flink](docs/getting-started/tutorials/flink_on_windows.md)
      - [x] [Batch 示例- java](docs/dev/batch/examples-java.md)
      - [x] [Batch 示例- scala](docs/dev/batch/examples-scala.md)
      
- 概念
  - [ ] [编程模型](docs/concepts/programming-model.md)
  - [x] [分布式运行时](docs/concepts/runtime.md)
  - [x] [词汇表](docs/concepts/glossary.md)
  
- 应用开发
  - 项目构建设置
    - [x] [Java 项目模板](docs/dev/projectsetup/java_api_quickstart.md)
    - [x] [Scala 项目模板](docs/dev/projectsetup/scala_api_quickstart.md)
    - [x] [配置依赖、连接器、类库](docs/dev/projectsetup/dependencies.md)
  - 基础 API 概念
    - [x] [概览](docs/dev/api_concepts.md)
    - [ ] [Scala API Extensions](docs/dev/scala_api_extensions.md)
    - [x] [Java Lambda 表达式](docs/dev/java_lambdas.md)
    - 
  - Streaming (DataStream API)
    - [ ] [概览](docs/dev/datastream_api.md)
    - Event Time
      - [ ] [概览](docs/dev/event_time.md)
      - [ ] [生成时间戳/水印](docs/dev/event_timestamps_watermarks.md)
      - [ ] [预先定义的时间戳提取器/水印发射器](docs/dev/event_timestamp_extractors.md)
      
    - 状态与容错
      - [ ] [概览](docs/dev/stream/state/index.md)
      - [x] [Working with State](docs/dev/stream/state/state.md)
      - [ ] [Broadcast State 模式](docs/dev/stream/state/broadcast_state.md)
      - [x] [Checkpointing](docs/dev/stream/state/checkpointing.md)
      - [ ] [可查询状态](docs/dev/stream/state/queryable_state.md)
      - [x] [State Backends](docs/dev/stream/state/state_backends.md)
      - [x] [状态数据结构升级](docs/dev/stream/state/schema_evolution.md)
      - [ ] [自定义状态序列化](docs/dev/stream/state/custom_serialization.md)

    - 算子
      - [ ] [概览](docs/dev/stream/operators/operators.md)
      - [ ] [窗口](docs/dev/stream/operators/windows.md)
      - [ ] [Joining](docs/dev/stream/operators/joining.md)
      - [ ] [Process Function](docs/dev/stream/operators/process_function.md)
      - [x] [异步 I/O](docs/dev/stream/operators/asyncio.md)

    - Connectors
      - [x] [概览](docs/dev/connectors/connectors.md)
      - [x] [容错保证](docs/dev/connectors/guarantees.md)
      - [x] [Kafka](docs/dev/connectors/kafka.md)
      - [ ] [Cassandra](docs/dev/connectors/cassandra.md)
      - [ ] [Kinesis](docs/dev/connectors/kinesis.md)
      - [ ] [Elasticsearch](docs/dev/connectors/elasticsearch.md)
      - [x] [Hadoop FileSystem](docs/dev/connectors/filesystem_sink.md)
      - [x] [Streaming File Sink](docs/dev/connectors/streamfile_sink.md)
      - [x] [RabbitMQ](docs/dev/connectors/rabbitmq.md)
      - [x] [NiFi](docs/dev/connectors/nifi.md)
      - [ ] [Google Cloud PubSub](docs/dev/connectors/pubsub.md)
      - [x] [Twitter](docs/dev/connectors/twitter.md)

    - [ ] [Side Outputs](docs/dev/stream/side_output.md)
    - [ ] [测试](docs/dev/stream/testing.md)
    - [ ] [实验功能](docs/dev/stream/experimental.md)

  - Batch (DataSet API)

    - [ ] [概览](docs/dev/batch/)
    - [ ] [Transformations](docs/dev/batch/dataset_transformations.md)
    - [ ] [迭代](docs/dev/batch/iterations.md)
    - [ ] [Zipping Elements](docs/dev/batch/zip_elements_guide.md)
    - [ ] [连接器](docs/dev/batch/connectors.md)
    - [ ] [Hadoop 兼容](docs/dev/batch/hadoop_compatibility.md)
    - [ ] [本地执行](docs/dev/local_execution.md)
    - [ ] [集群执行](docs/dev/cluster_execution.md)

  - Table API & SQL

    - [ ] [概览](docs/dev/table/)
    - [ ] [Concepts & Common API](docs/dev/table/common.md)
    - [ ] [Streaming Concepts](docs/dev/stream/state/state.md#collapse-86)

      - [ ] [概览](docs/dev/table/streaming/)
      - [ ] [动态表 (Dynamic Table)](docs/dev/table/streaming/dynamic_tables.md)
      - [ ] [Time Attributes](docs/dev/table/streaming/time_attributes.md)
      - [ ] [Joins in Continuous Queries](docs/dev/table/streaming/joins.md)
      - [ ] [Temporal Tables](docs/dev/table/streaming/temporal_tables.md)
      - [ ] [Detecting Patterns](docs/dev/table/streaming/match_recognize.md)
      - [ ] [Query Configuration](docs/dev/table/streaming/query_configuration.md)

    - [ ] [Data Types](docs/dev/table/types.md)
    - [ ] [Table API](docs/dev/table/tableApi.md)
    
    - SQL

      - [x] [概览](docs/dev/table/sql/index.md)
      - [x] [查询语句](docs/dev/table/sql/queries.md)
      - [x] [CREATE 语句](docs/dev/table/sql/create.md)
      - [x] [DROP 语句](docs/dev/table/sql/drop.md)
      - [x] [ALTER 语句](docs/dev/table/sql/alter.md)
      - [x] [INSERT 语句](docs/dev/table/sql/insert.md)

    - [ ] [Connect to External Systems](docs/dev/table/connect.md)
    - [ ] [Functions](docs/dev/stream/state/state.md#collapse-104)

      - [ ] [概览](docs/dev/table/functions/)
      - [ ] [系统（内置）函数](docs/dev/table/functions/systemFunctions.md)
      - [ ] [自定义函数](docs/dev/table/functions/udfs.md)

    - [ ] [模块](docs/dev/table/modules.md)
    - [ ] [Catalogs](docs/dev/table/catalogs.md)
    - [ ] [SQL 客户端](docs/dev/table/sqlClient.md)
    - [ ] [Python Table API](docs/dev/stream/state/state.md#collapse-111)

      - [ ] [概览](docs/dev/table/python/)
      - [ ] [环境安装](docs/dev/table/python/installation.md)
      - [ ] [自定义函数](docs/dev/table/python/python_udfs.md)
      - [ ] [依赖管理](docs/dev/table/python/dependency_management.md)
      - [ ] [配置](docs/dev/table/python/python_config.md)

    - Hive Integration

      - [ ] [概览](docs/dev/table/hive/)
      - [ ] [HiveCatalog](docs/dev/table/hive/hive_catalog.md)
      - [ ] [Reading & Writing Hive Tables](docs/dev/table/hive/read_write_hive.md)
      - [ ] [Hive functions](docs/dev/table/hive/hive_functions.md)
      - [ ] [Use Hive connector in scala shell](docs/dev/table/hive/scala_shell_hive.md)

    - [ ] [配置](docs/dev/table/config.md)
    - [ ] [Performance Tuning](docs/dev/stream/state/state.md#collapse-124)

      - [ ] [Streaming Aggregation](docs/dev/table/tuning/streaming_aggregation_optimization.md)

    - [ ] [User-defined Sources & Sinks](docs/dev/table/sourceSinks.md)

  - 数据类型以及序列化

    - [x] [概览](docs/dev/types_serialization.md)
    - [x] [自定义序列化器](docs/dev/custom_serializers.md)

  - 管理执行

    - [ ] [执行配置](docs/dev/execution_configuration.md)
    - [ ] [程序打包](docs/dev/packaging.md)
    - [x] [并行执行](docs/dev/parallel.md)
    - [ ] [Execution Plans](docs/dev/execution_plans.md)
    - [x] [Task 故障恢复](docs/dev/task_failure_recovery.md)

  - 类库
    - [ ] [事件处理 (CEP)](docs/dev/libs/cep.md)
    - [ ] [State Processor API](docs/dev/libs/state_processor_api.md)
    
    - 图计算: Gelly
      - [ ] [概览](docs/dev/libs/gelly/)
      - [ ] [Graph API](docs/dev/libs/gelly/graph_api.md)
      - [ ] [Iterative Graph Processing](docs/dev/libs/gelly/iterative_graph_processing.md)
      - [ ] [Library Methods](docs/dev/libs/gelly/library_methods.md)
      - [ ] [Graph Algorithms](docs/dev/libs/gelly/graph_algorithms.md)
      - [ ] [Graph Generators](docs/dev/libs/gelly/graph_generators.md)
      - [ ] [Bipartite Graph](docs/dev/libs/gelly/bipartite_graph.md)

  - [ ] [API 迁移指南](docs/dev/migration.md)

- 部署与运维

  - 集群与部署
    - [ ] [独立集群](docs/ops/deployment/cluster_setup.md)
    - [ ] [YARN](docs/ops/deployment/yarn_setup.md)
    - [ ] [Mesos](docs/ops/deployment/mesos.md)
    - [ ] [Docker](docs/ops/deployment/docker.md)
    - [ ] [Kubernetes](docs/ops/deployment/kubernetes.md)
    - [ ] [Native Kubernetes](docs/ops/deployment/native_kubernetes.md)
    - [ ] [Hadoop 集成](docs/ops/deployment/hadoop.md)

  - [ ] [高可用 (HA)](docs/ops/jobmanager_high_availability.md)
  - 状态与容错
    - [x] [Checkpoints](docs/ops/state/checkpoints.md)
    - [x] [Savepoints](docs/ops/state/savepoints.md)
    - [x] [State Backends](docs/ops/state/state_backends.md)
    - [ ] [大状态与 Checkpoint 调优](docs/ops/state/large_state_tuning.md)

  - [配置参数](docs/ops/config.md)
  - 内存配置
    - [x] [配置 TaskExecutor 内存](docs/ops/memory/mem_setup.md)
    - [x] [内存模型详解](docs/ops/memory/mem_detail.md)
    - [x] [调优指南](docs/ops/memory/mem_tuning.md)
    - [x] [常见问题](docs/ops/memory/mem_trouble.md)
    - [x] [升级指南](docs/ops/memory/mem_migration.md)

  - [ ] [生产就绪情况核对清单](docs/ops/production_ready.md)
  - [ ] [CLI](docs/ops/cli.md)
  - [x] [Python REPL](docs/ops/python_shell.md)
  - [ ] [Scala REPL](docs/ops/scala_shell.md)
  - [ ] [Kerberos](docs/ops/security-kerberos.md)
  - [ ] [SSL 配置](docs/ops/security-ssl.md)
  - [ ] [File Systems](docs/dev/stream/state/state.md#collapse-184)

    - [ ] [概览](docs/ops/filesystems/)
    - [ ] [Common Configurations](docs/ops/filesystems/common.md)
    - [x] [Amazon S3](docs/ops/filesystems/s3.md)
    - [ ] [Aliyun OSS](docs/ops/filesystems/oss.md)
    - [ ] [Azure Blob Storage](docs/ops/filesystems/azure.md)

  - [ ] [升级应用程序和 Flink 版本](docs/ops/upgrading.md)
  - [ ] [Plugins](docs/ops/plugins.md)

- 调试和监控

  - [ ] [指标](docs/monitoring/metrics.md)
  - [ ] [日志](docs/monitoring/logging.md)
  - [ ] [History Server](docs/monitoring/historyserver.md)
  - [ ] [监控 Checkpoint](docs/monitoring/checkpoint_monitoring.md)
  - [x] [监控反压](docs/monitoring/back_pressure.md)
  - [ ] [监控 REST API](docs/monitoring/rest_api.md)
  - [ ] [调试窗口与事件时间](docs/monitoring/debugging_event_time.md)
  - [ ] [调试类加载](docs/monitoring/debugging_classloading.md)
  - [ ] [应用程序分析](docs/monitoring/application_profiling.md)

---

- Flink 开发

  - [ ] [导入 Flink 到 IDE 中](docs/flinkDev/ide_setup.md)
  - [ ] [从源码构建 Flink](docs/flinkDev/building.md)

- 内幕

  - [ ] [组件堆栈](docs/internals/components.md)
  - [ ] [数据流容错](docs/internals/stream_checkpointing.md)
  - [x] [作业调度](docs/internals/job_scheduling.md)
  - [ ] [Task 生命周期](docs/internals/task_lifecycle.md)
  - [ ] [文件系统](docs/internals/filesystems.md)


