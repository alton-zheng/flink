# Flink

本文档基于本人学习Flink 1.12 过程中，对官文加上个人心得整理得出， 如有不好的地方请指教。 

由于其核心代码主要由`Java`编写(所有功能都可以使用`scala`实现)。文档代码部分主要贴`Java`, 仅会包含部分`Scala`。如需要`Scala`相关的文档，请查阅官方文档！  

Email: alton_z@outlook.com

- [x] [Apache Flink](docs/apache-flink.md)

&nbsp;

## 进度

-  Try Flink
  - [x] [本地模式安装](docs/try-flink/local_installation.zh.md)
  - [x] [基于 DataStream API 实现欺诈检测](docs/try-flink/datastream_api.zh.md)
  - [ ] [基于 Table API 实现实时报表](docs/try-flink/table_api.zh.md)
  - [x] [Flink 操作场景](docs/try-flink/flink-operations-playground.zh.md)

&nbsp;

-  实践练习
  - [x] [概览](docs/learn-flink/overview.zh.md)
  - [x] [DataStream API 简介](docs/learn-flink/datastream_api.zh.md)
  - [x] [数据管道 & ETL](docs/learn-flink/etl.zh.md)
  - [x] [流式分析](docs/learn-flink/streaming_analytics.zh.md)
  - [x] [事件驱动应用](docs/learn-flink/event_driven.zh.md)
  - [x] [容错处理](docs/learn-flink/fault_tolerance.zh.md)

&nbsp;

-  概念透析
  - [x] [概览](docs/concepts/index.zh.md)
  - [ ] [有状态流处理](docs/concepts/stateful-stream-processing.zh.md)
  - [ ] [及时流处理](docs/concepts/timely-stream-processing.zh.md)
  - [x] [Flink 架构](docs/concepts/flink-architecture.zh.md)
  - [x] [词汇表](docs/concepts/glossary.zh.md)

&nbsp;

-  应用开发
  - DataStream API
    - [ ] [概览](docs/dev/datastream_api.zh.md)
    
    - [ ] [Execution Mode (Batch/Streaming)](docs/dev/datastream_execution_mode.zh.md)
    
    - 事件时间
      - [x] [概览](docs/dev/event_time.zh.md)
      - [x] [生成 Watermark](docs/dev/event_timestamps_watermarks.zh.md)
      - [x] [内置 Watermark 生成器](docs/dev/event_timestamp_extractors.zh.md)
      
    - 状态与容错
      - [x] [概览](docs/dev/stream/state/overview.zh.md)
      - [ ] [Working with State](docs/dev/stream/state/state.zh.md)
      - [x] [Broadcast State 模式](docs/dev/stream/state/broadcast_state.zh.md)
      - [x] [Checkpointing](docs/dev/stream/state/checkpointing.zh.md)
      - [x] [Queryable State](docs/dev/stream/state/queryable_state.zh.md)
      - [x] [State Backends](docs/dev/stream/state/state_backends.zh.md)
      - [x] [状态数据结构升级](docs/dev/stream/state/schema_evolution.zh.md)
      - [ ] [自定义状态序列化](docs/dev/stream/state/custom_serialization.zh.md)
      
    - [x] [用户自定义 Functions](docs/dev/user_defined_functions.zh.md)
    
      &nbsp;
    
    - 算子
      - [x] [概览](docs/dev/stream/operators/overview.zh.md)
      - [x] [窗口](docs/dev/stream/operators/windows.zh.md)
      - [ ] [Joining](docs/dev/stream/operators/joining.zh.md)
      - [ ] [Process Function](docs/dev/stream/operators/process_function.zh.md)
      - [x] [异步 I/O](docs/dev/stream/operators/asyncio.zh.md)
    - [ ] [Data Sources](docs/dev/stream/sources.zh.md)
    - [x] [旁路输出](docs/dev/stream/side_output.zh.md)
    - [ ] [Handling Application Parameters](docs/dev/application_parameters.zh.md)
    - [ ] [测试](docs/dev/stream/testing.zh.md)
    - [ ] [实验功能](docs/dev/stream/experimental.zh.md)
    - [ ] [Scala API Extensions](docs/dev/scala_api_extensions.zh.md)
    - [x] [Java Lambda 表达式](docs/dev/java_lambdas.zh.md)
    - [ ] [Project Configuration](docs/dev/project-configuration.zh.md)
    
    &nbsp;
    
  - DataSet API
    - [ ] [概览](docs/dev/batch/overview.zh.md)
    - [ ] [Transformations](docs/dev/batch/dataset_transformations.zh.md)
    - [ ] [迭代](docs/dev/batch/iterations.zh.md)
    - [ ] [Zipping Elements](docs/dev/batch/zip_elements_guide.zh.md)
    - [ ] [Hadoop 兼容](docs/dev/batch/hadoop_compatibility.zh.md)
    - [ ] [本地执行](docs/dev/local_execution.zh.md)
    - [x] [集群执行](docs/dev/cluster_execution.zh.md)
    - [x] [Batch 示例](docs/dev/batch/examples.zh.md)
  
  &nbsp;
  
  - Table API & SQL
    - [x] [概览](docs/dev/table/overview.zh.md)
    - [x] [概念与通用 API](docs/dev/table/common.zh.md)
    - 流式概念
      - [x] [概览](docs/dev/table/streaming/overview.zh.md)
      - [x] [动态表 (Dynamic Table)](docs/dev/table/streaming/dynamic_tables.zh.md)
      - [x] [时间属性](docs/dev/table/streaming/time_attributes.zh.md)
      - [x] [时态表（Temporal Tables）](docs/dev/table/streaming/temporal_tables.zh.md)
      - [x] [流上的 Join](docs/dev/table/streaming/joins.zh.md)
      - [x] [模式检测](docs/dev/table/streaming/match_recognize.zh.md)
      - [ ] [Query Configuration](docs/dev/table/streaming/query_configuration.zh.md)
      - [ ] [Legacy Features](docs/dev/table/streaming/legacy.zh.md)
    - [x] [数据类型](docs/dev/table/types.zh.md)
    - [x] [Table API](docs/dev/table/tableApi.zh.md)
    
    &nbsp;
    
    - SQL
      - [x] [概览](docs/dev/table/sql/index.zh.md)
      - [x] [查询语句](docs/dev/table/sql/queries.zh.md)
      - [x] [CREATE 语句](docs/dev/table/sql/create.zh.md)
      - [x] [DROP 语句](docs/dev/table/sql/drop.zh.md)
      - [x] [ALTER 语句](docs/dev/table/sql/alter.zh.md)
      - [x] [INSERT 语句](docs/dev/table/sql/insert.zh.md)
      - [ ] [SQL Hints](docs/dev/table/sql/hints.zh.md)
      - [x] [DESCRIBE 语句](docs/dev/table/sql/describe.zh.md)
      - [x] [EXPLAIN 语句](docs/dev/table/sql/explain.zh.md)
      - [x] [USE 语句](docs/dev/table/sql/use.zh.md)
      - [x] [SHOW 语句](docs/dev/table/sql/show.zh.md)
    
      &nbsp;
    
    - 函数
      - [x] [概览](docs/dev/table/functions/index.zh.md)
      - [ ] [系统（内置）函数](docs/dev/table/functions/systemFunctions.zh.md)
      - [x] [自定义函数](docs/dev/table/functions/udfs.zh.md)
    
    - [ ] [模块](docs/dev/table/modules.zh.md)
    
    - [x] [Catalogs](docs/dev/table/catalogs.zh.md)
    
    - [x] [SQL 客户端](docs/dev/table/sqlClient.zh.md)
    
    - [x] [配置](docs/dev/table/config.zh.md)
    
    &nbsp;
    
    - Performance Tuning
      - [x] [流式聚合](docs/dev/table/tuning/streaming_aggregation_optimization.zh.md)
    - [ ] [User-defined Sources & Sinks](docs/dev/table/sourceSinks.zh.md)
    
  - Python API
    - [ ] [概览](docs/dev/pytzh.md)
    
    - [x] [环境安装](docs/dev/python/installation.zh.md)
    
    - [x] [Table API 教程](docs/dev/python/table_api_tutorial.zh.md)
    
    - [x] [DataStream API 教程](docs/dev/python/datastream_tutorial.zh.md)
    
    - Table API用户指南
      - [x] [Python Table API 简介](docs/dev/python/table-api-users-guide/intro_to_table_api.zh.md)
      - [x] [TableEnvironment](docs/dev/python/table-api-users-guide/table_environment.zh.md)
      - [ ] [Operations](docs/dev/python/table-api-users-guide/operations.zh.md)
      - [x] [数据类型](docs/dev/python/table-api-users-guide/python_types.zh.md)
      - [ ] [系统（内置）函数](docs/dev/python/table-api-users-guide/built_in_functions.zh.md)
      - 自定义函数
        - [ ] [普通自定义函数（UDF）](docs/dev/python/table-api-users-guide/udfs/python_udfs.zh.md)
        - [x] [向量化自定义函数](docs/dev/python/table-api-users-guide/udfs/vectorized_python_udfs.zh.md)
      - [x] [PyFlink Table 和 Pandas DataFrame 互转](docs/dev/python/table-api-users-guide/conversion_of_pandas.zh.md)
      - [x] [依赖管理](docs/dev/python/table-api-users-guide/dependency_management.zh.md)
      - [x] [SQL](docs/dev/python/table-api-users-guide/sql.zh.md)
      - [x] [Catalogs](docs/dev/python/table-api-users-guide/catalogs.zh.md)
      - [x] [指标](docs/dev/python/table-api-users-guide/metrics.zh.md)
      - [x] [连接器](docs/dev/python/table-api-users-guide/python_table_api_connectors.zh.md)
      
      &nbsp;
      
    - DataStream API用户指南
      - [x] [数据类型](docs/dev/python/datastream-api-users-guide/data_types.zh.md)
      - [x] [算子](docs/dev/python/datastream-api-users-guide/operators.zh.md)
      - [x] [依赖管理](docs/dev/python/datastream-api-users-guide/dependency_management.zh.md)
      
    - [ ] [配置](docs/dev/python/python_config.zh.md)
    
    - [ ] [环境变量](docs/dev/python/environment_variables.zh.md)
    
    - [x] [常见问题](docs/dev/python/faq.zh.md)
  
  &nbsp;
  
  - 数据类型以及序列化
    - [x] [概览](docs/dev/types_serialization.zh.md)
    - [x] [自定义序列化器](docs/dev/custom_serializers.zh.md)
  
    &nbsp;
  
  - 管理执行
    - [ ] [执行配置](docs/dev/execution_configuration.zh.md)
    - [x] [程序打包](docs/dev/packaging.zh.md)
    - [x] [并行执行](docs/dev/parallel.zh.md)
    - [x] [执行计划](docs/dev/execution_plans.zh.md)
    - [x] [Task 故障恢复](docs/dev/task_failure_recovery.zh.md)
  - [x] [API 迁移指南](docs/dev/migration.zh.md)
  
-  Libraries
  - [x] [事件处理 (CEP)](docs/dev/libs/cep.zh.md)
  - [x] [State Processor API](docs/dev/libs/state_processor_api.zh.md)
  - 图计算: Gelly
    - [ ] [概览](docs/dev/libs/gezh.md)
    - [ ] [Graph API](docs/dev/libs/gelly/graph_api.zh.md)
    - [ ] [Iterative Graph Processing](docs/dev/libs/gelly/iterative_graph_processing.zh.md)
    - [ ] [Library Methods](docs/dev/libs/gelly/library_methods.zh.md)
    - [ ] [Graph Algorithms](docs/dev/libs/gelly/graph_algorithms.zh.md)
    - [ ] [Graph Generators](docs/dev/libs/gelly/graph_generators.zh.md)
    - [ ] [Bipartite Graph](docs/dev/libs/gelly/bipartite_graph.zh.md)

&nbsp;

-  Connectors
  - DataStream Connectors
    - [x] [概览](docs/dev/connectors/index.zh.md)
    - [x] [容错保证](docs/dev/connectors/guarantees.zh.md)
    - [x] [Kafka](docs/dev/connectors/kafka.zh.md)
    - [x] [Cassandra](docs/dev/connectors/cassandra.zh.md)
    - [ ] [Kinesis](docs/dev/connectors/kinesis.zh.md)
    - [ ] [Elasticsearch](docs/dev/connectors/elasticsearch.zh.md)
    - [x] [File Sink](docs/dev/connectors/file_sink.zh.md)
    - [x] [Streaming File Sink](docs/dev/connectors/streamfile_sink.zh.md)
    - [x] [RabbitMQ](docs/dev/connectors/rabbitmq.zh.md)
    - [x] [NiFi](docs/dev/connectors/nifi.zh.md)
    - [x] [Google Cloud PubSub](docs/dev/connectors/pubsub.zh.md)
    - [x] [Twitter](docs/dev/connectors/twitter.zh.md)
    - [x] [JDBC](docs/dev/connectors/jdbc.zh.md)
    
    &nbsp;
    
  - Table & SQL Connectors
    - [ ] [概览](docs/dev/table/connectzh.md)
    - Formats
      - [x] [概览](docs/dev/table/connectors/formats/index.zh.md)
      - [x] [CSV](docs/dev/table/connectors/formats/csv.zh.md)
      - [x] [JSON](docs/dev/table/connectors/formats/json.zh.md)
      - [x] [Confluent Avro](docs/dev/table/connectors/formats/avro-confluent.zh.md)
      - [x] [Avro](docs/dev/table/connectors/formats/avro.zh.md)
      - [x] [Debezium](docs/dev/table/connectors/formats/debezium.zh.md)
      - [x] [Canal](docs/dev/table/connectors/formats/canal.zh.md)
      - [ ] [Maxwell](docs/dev/table/connectors/formats/maxwell.zh.md)
      - [x] [Parquet](docs/dev/table/connectors/formats/parquet.zh.md)
      - [x] [Orc](docs/dev/table/connectors/formats/orc.zh.md)
      - [x] [Raw](docs/dev/table/connectors/formats/raw.zh.md)
    - [ ] [Kafka](docs/dev/table/connectors/kafka.zh.md)
    - [x] [Upsert Kafka](docs/dev/table/connectors/upsert-kafka.zh.md)
    - [ ] [Kinesis](docs/dev/table/connectors/kinesis.zh.md)
    - [ ] [JDBC](docs/dev/table/connectors/jdbc.zh.md)
    - [ ] [Elasticsearch](docs/dev/table/connectors/elasticsearch.zh.md)
    - [ ] [FileSystem](docs/dev/table/connectors/filesystem.zh.md)
    - [x] [HBase](docs/dev/table/connectors/hbase.zh.md)
    - [x] [DataGen](docs/dev/table/connectors/datagen.zh.md)
    - [x] [Print](docs/dev/table/connectors/print.zh.md)
    - [x] [BlackHole](docs/dev/table/connectors/blackhole.zh.md)
    - Hive
      - [x] [概览](docs/dev/table/connectors/hive/index.zh.md)
      - [ ] [Hive Catalog](docs/dev/table/connectors/hive/hive_catalog.zh.md)
      - [x] [Hive 方言](docs/dev/table/connectors/hive/hive_dialect.zh.md)
      - [ ] [Hive Read & Write](docs/dev/table/connectors/hive/hive_read_write.zh.md)
      - [x] [Hive 函数](docs/dev/table/connectors/hive/hive_functions.zh.md)
    - [x] [下载](docs/dev/table/connectors/downloads.zh.md)
    
  - [x] [DataSet Connectors](docs/dev/batch/connectors.zh.md)

&nbsp;

-  Deployment
  - [ ] [概览](docs/deploymzh.md)
  - Resource Providers
    - Standalone
      - [x] [概览](docs/deployment/resource-providers/standalone/index.zh.md)
      - [ ] [Docker](docs/deployment/resource-providers/standalone/docker.zh.md)
      - [ ] [Kubernetes](docs/deployment/resource-providers/standalone/kubernetes.zh.md)
    - [ ] [Native Kubernetes](docs/deployment/resource-providers/native_kubernetes.zh.md)
    - [ ] [YARN](docs/deployment/resource-providers/yarn.zh.md)
    - [ ] [Mesos](docs/deployment/resource-providers/mesos.zh.md)
  - [ ] [配置参数](docs/deployment/config.zh.md)
  
  &nbsp;
  
  - 内存配置
    - [x] [配置 Flink 进程的内存](docs/deployment/memory/mem_setup.zh.md)
    - [x] [配置 TaskManager 内存](docs/deployment/memory/mem_setup_tm.zh.md)
    - [x] [配置 JobManager 内存](docs/deployment/memory/mem_setup_jobmanager.zh.md)
    - [x] [调优指南](docs/deployment/memory/mem_tuning.zh.md)
    - [x] [常见问题](docs/deployment/memory/mem_trouble.zh.md)
    - [x] [升级指南](docs/deployment/memory/mem_migration.zh.md)
  - [ ] [命令行界面](docs/deployment/cli.zh.md)
  
  &nbsp;
  
  - 文件系统
    - [x] [概览](docs/deployment/filesystems/index.zh.md)
    - [x] [通用配置](docs/deployment/filesystems/common.zh.md)
    - [x] [Amazon S3](docs/deployment/filesystems/s3.zh.md)
    - [x] [阿里云 OSS](docs/deployment/filesystems/oss.zh.md)
    - [x] [Azure Blob 存储](docs/deployment/filesystems/azure.zh.md)
    - [ ] [Plugins](docs/deployment/filesystems/plugins.zh.md)
  - High Availability (HA)
    - [ ] [概览](docs/deploymentzh.md)
    - [ ] [ZooKeeper HA Services](docs/deployment/ha/zookeeper_ha.zh.md)
    - [ ] [Kubernetes HA Services](docs/deployment/ha/kubernetes_ha.zh.md)
  - [ ] [Metric Reporters](docs/deployment/metric_reporters.zh.md)
  - Security
    - [ ] [SSL 设置](docs/deployment/security/security-ssl.zh.md)
    - [ ] [Kerberos](docs/deployment/security/security-kerberos.zh.md)
  - REPLs
    - [x] [Python REPL](docs/deployment/repls/python_shell.zh.md)
    - [ ] [Scala REPL](docs/deployment/repls/scala_shell.zh.md)
  - Advanced
    - [x] [扩展资源](docs/deployment/advanced/external_resources.zh.md)
    - [ ] [History Server](docs/deployment/advanced/historyserver.zh.md)
    - [ ] [日志](docs/deployment/advanced/logging.zh.md)
  
-  Operations
  - 状态与容错
    - [x] [Checkpoints](docs/ops/state/checkpoints.zh.md)
    - [x] [Savepoints](docs/ops/state/savepoints.zh.md)
    - [x] [State Backends](docs/ops/state/state_backends.zh.md)
    - [ ] [大状态与 Checkpoint 调优](docs/ops/state/large_state_tuning.zh.md)
  - [ ] [指标](docs/ops/metrics.zh.md)
  - [ ] [REST API](docs/ops/rest_api.zh.md)
  - Debugging
    - [x] [调试窗口与事件时间](docs/ops/debugging/debugging_event_time.zh.md)
    - [ ] [调试类加载](docs/ops/debugging/debugging_classloading.zh.md)
    - [x] [应用程序分析](docs/ops/debugging/application_profiling.zh.md)
  - Monitoring
    - [ ] [监控 Checkpoint](docs/ops/monitoring/checkpoint_monitoring.zh.md)
    - [ ] [监控反压](docs/ops/monitoring/back_pressure.zh.md)
  - [ ] [升级应用程序和 Flink 版本](docs/ops/upgrading.zh.md)
  - [ ] [生产就绪情况核对清单](docs/ops/production_ready.zh.md)
  
-  Flink 开发
  - [ ] [导入 Flink 到 IDE 中](docs/flinkDev/ide_setup.zh.md)
  - [x] [从源码构建 Flink](docs/flinkDev/building.zh.md)

&nbsp;

-  内幕
  - [x] [作业调度](docs/internals/job_scheduling.zh.md)
  - [ ] [Task 生命周期](docs/internals/task_lifecycle.zh.md)
  - [ ] [文件系统](docs/internals/filesystems.zh.md)