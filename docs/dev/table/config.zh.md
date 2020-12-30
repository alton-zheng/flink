# 配置

Table 和 SQL API 的默认配置能够确保结果准确，同时也提供可接受的性能。

根据 Table 程序的需求，可能需要调整特定的参数用于优化。例如，无界流程序可能需要保证所需的状态是有限的(请参阅 [流式概念](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/query_configuration.html)).

- [概览](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/config.html#概览)
- [执行配置](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/config.html#执行配置)
- [优化器配置](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/config.html#优化器配置)
- [Planner 配置](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/config.html#planner-配置)

### 概览

在每个 TableEnvironment 中，`TableConfig` 提供用于当前会话的配置项。

对于常见或者重要的配置项，`TableConfig` 提供带有详细注释的 `getters` 和 `setters` 方法。

对于更加高级的配置，用户可以直接访问底层的 key-value 配置项。以下章节列举了所有可用于调整 Flink Table 和 SQL API 程序的配置项。

**注意** 因为配置项会在执行操作的不同时间点被读取，所以推荐在实例化 TableEnvironment 后尽早地设置配置项。

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/config.html#tab_Java_0)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/config.html#tab_Scala_0)
- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/config.html#tab_Python_0)

```
// instantiate table environment
TableEnvironment tEnv = ...

// access flink configuration
Configuration configuration = tEnv.getConfig().getConfiguration();
// set low-level key-value options
configuration.setString("table.exec.mini-batch.enabled", "true");
configuration.setString("table.exec.mini-batch.allow-latency", "5 s");
configuration.setString("table.exec.mini-batch.size", "5000");
```

**注意** 目前，key-value 配置项仅被 Blink planner 支持。

### 执行配置

以下选项可用于优化查询执行的性能。

| Key                                                          | Default              | Type                               | Description                                                  |
| :----------------------------------------------------------- | :------------------- | :--------------------------------- | :----------------------------------------------------------- |
| table.exec.async-lookup.buffer-capacity **Batch** **Streaming** | 100                  | Integer                            | The max number of async i/o operation that the async lookup join can trigger. |
| table.exec.async-lookup.timeout **Batch** **Streaming**      | 3 min                | Duration                           | The async timeout for the asynchronous operation to complete. |
| table.exec.disabled-operators **Batch**                      | (none)               | String                             | Mainly for testing. A comma-separated list of operator names, each name represents a kind of disabled operator. Operators that can be disabled include "NestedLoopJoin", "ShuffleHashJoin", "BroadcastHashJoin", "SortMergeJoin", "HashAgg", "SortAgg". By default no operator is disabled. |
| table.exec.mini-batch.allow-latency **Streaming**            | 0 ms                 | Duration                           | The maximum latency can be used for MiniBatch to buffer input records. MiniBatch is an optimization to buffer input records to reduce state access. MiniBatch is triggered with the allowed latency interval and when the maximum number of buffered records reached. NOTE: If table.exec.mini-batch.enabled is set true, its value must be greater than zero. |
| table.exec.mini-batch.enabled **Streaming**                  | false                | Boolean                            | Specifies whether to enable MiniBatch optimization. MiniBatch is an optimization to buffer input records to reduce state access. This is disabled by default. To enable this, users should set this config to true. NOTE: If mini-batch is enabled, 'table.exec.mini-batch.allow-latency' and 'table.exec.mini-batch.size' must be set. |
| table.exec.mini-batch.size **Streaming**                     | -1                   | Long                               | The maximum number of input records can be buffered for MiniBatch. MiniBatch is an optimization to buffer input records to reduce state access. MiniBatch is triggered with the allowed latency interval and when the maximum number of buffered records reached. NOTE: MiniBatch only works for non-windowed aggregations currently. If table.exec.mini-batch.enabled is set true, its value must be positive. |
| table.exec.resource.default-parallelism **Batch** **Streaming** | -1                   | Integer                            | Sets default parallelism for all operators (such as aggregate, join, filter) to run with parallel instances. This config has a higher priority than parallelism of StreamExecutionEnvironment (actually, this config overrides the parallelism of StreamExecutionEnvironment). A value of -1 indicates that no default parallelism is set, then it will fallback to use the parallelism of StreamExecutionEnvironment. |
| table.exec.shuffle-mode **Batch**                            | "ALL_EDGES_BLOCKING" | String                             | Sets exec shuffle mode. Accepted values are:`ALL_EDGES_BLOCKING`: All edges will use blocking shuffle.`FORWARD_EDGES_PIPELINED`: Forward edges will use pipelined shuffle, others blocking.`POINTWISE_EDGES_PIPELINED`: Pointwise edges will use pipelined shuffle, others blocking. Pointwise edges include forward and rescale edges.`ALL_EDGES_PIPELINED`: All edges will use pipelined shuffle.`batch`: the same as `ALL_EDGES_BLOCKING`. Deprecated.`pipelined`: the same as `ALL_EDGES_PIPELINED`. Deprecated.Note: Blocking shuffle means data will be fully produced before sent to consumer tasks. Pipelined shuffle means data will be sent to consumer tasks once produced. |
| table.exec.sink.not-null-enforcer **Batch** **Streaming**    | ERROR                | EnumPossible values: [ERROR, DROP] | The NOT NULL column constraint on a table enforces that null values can't be inserted into the table. Flink supports 'error' (default) and 'drop' enforcement behavior. By default, Flink will check values and throw runtime exception when null values writing into NOT NULL columns. Users can change the behavior to 'drop' to silently drop such records without throwing exception. |
| table.exec.sort.async-merge-enabled **Batch**                | true                 | Boolean                            | Whether to asynchronously merge sorted spill files.          |
| table.exec.sort.default-limit **Batch**                      | -1                   | Integer                            | Default limit when user don't set a limit after order by. -1 indicates that this configuration is ignored. |
| table.exec.sort.max-num-file-handles **Batch**               | 128                  | Integer                            | The maximal fan-in for external merge sort. It limits the number of file handles per operator. If it is too small, may cause intermediate merging. But if it is too large, it will cause too many files opened at the same time, consume memory and lead to random reading. |
| table.exec.source.cdc-events-duplicate **Streaming**         | false                | Boolean                            | Indicates whether the CDC (Change Data Capture) sources in the job will produce duplicate change events that requires the framework to deduplicate and get consistent result. CDC source refers to the source that produces full change events, including INSERT/UPDATE_BEFORE/UPDATE_AFTER/DELETE, for example Kafka source with Debezium format. The value of this configuration is false by default.  However, it's a common case that there are duplicate change events. Because usually the CDC tools (e.g. Debezium) work in at-least-once delivery when failover happens. Thus, in the abnormal situations Debezium may deliver duplicate change events to Kafka and Flink will get the duplicate events. This may cause Flink query to get wrong results or unexpected exceptions.  Therefore, it is recommended to turn on this configuration if your CDC tool is at-least-once delivery. Enabling this configuration requires to define PRIMARY KEY on the CDC sources. The primary key will be used to deduplicate change events and generate normalized changelog stream at the cost of an additional stateful operator. |
| table.exec.source.idle-timeout **Streaming**                 | 0 ms                 | Duration                           | When a source do not receive any elements for the timeout time, it will be marked as temporarily idle. This allows downstream tasks to advance their watermarks without the need to wait for watermarks from this source while it is idle. Default value is 0, which means detecting source idleness is not enabled. |
| table.exec.spill-compression.block-size **Batch**            | "64 kb"              | String                             | The memory size used to do compress when spilling data. The larger the memory, the higher the compression ratio, but more memory resource will be consumed by the job. |
| table.exec.spill-compression.enabled **Batch**               | true                 | Boolean                            | Whether to compress spilled data. Currently we only support compress spilled data for sort and hash-agg and hash-join operators. |
| table.exec.state.ttl **Streaming**                           | 0 ms                 | Duration                           | Specifies a minimum time interval for how long idle state (i.e. state which was not updated), will be retained. State will never be cleared until it was idle for less than the minimum time, and will be cleared at some time after it was idle. Default is never clean-up the state. NOTE: Cleaning up state requires additional overhead for bookkeeping. Default value is 0, which means that it will never clean up state. |
| table.exec.window-agg.buffer-size-limit **Batch**            | 100000               | Integer                            | Sets the window elements buffer size limit used in group window agg operator. |

### 优化器配置

以下配置可以用于调整查询优化器的行为以获得更好的执行计划。

| Key                                                          | Default | Type    | Description                                                  |
| :----------------------------------------------------------- | :------ | :------ | :----------------------------------------------------------- |
| table.optimizer.agg-phase-strategy **Batch** **Streaming**   | "AUTO"  | String  | Strategy for aggregate phase. Only AUTO, TWO_PHASE or ONE_PHASE can be set. AUTO: No special enforcer for aggregate stage. Whether to choose two stage aggregate or one stage aggregate depends on cost. TWO_PHASE: Enforce to use two stage aggregate which has localAggregate and globalAggregate. Note that if aggregate call does not support optimize into two phase, we will still use one stage aggregate. ONE_PHASE: Enforce to use one stage aggregate which only has CompleteGlobalAggregate. |
| table.optimizer.distinct-agg.split.bucket-num **Streaming**  | 1024    | Integer | Configure the number of buckets when splitting distinct aggregation. The number is used in the first level aggregation to calculate a bucket key 'hash_code(distinct_key) % BUCKET_NUM' which is used as an additional group key after splitting. |
| table.optimizer.distinct-agg.split.enabled **Streaming**     | false   | Boolean | Tells the optimizer whether to split distinct aggregation (e.g. COUNT(DISTINCT col), SUM(DISTINCT col)) into two level. The first aggregation is shuffled by an additional key which is calculated using the hashcode of distinct_key and number of buckets. This optimization is very useful when there is data skew in distinct aggregation and gives the ability to scale-up the job. Default is false. |
| table.optimizer.join-reorder-enabled **Batch** **Streaming** | false   | Boolean | Enables join reorder in optimizer. Default is disabled.      |
| table.optimizer.join.broadcast-threshold **Batch**           | 1048576 | Long    | Configures the maximum size in bytes for a table that will be broadcast to all worker nodes when performing a join. By setting this value to -1 to disable broadcasting. |
| table.optimizer.multiple-input-enabled **Batch**             | true    | Boolean | When it is true, the optimizer will merge the operators with pipelined shuffling into a multiple input operator to reduce shuffling and improve performance. Default value is true. |
| table.optimizer.reuse-source-enabled **Batch** **Streaming** | true    | Boolean | When it is true, the optimizer will try to find out duplicated table sources and reuse them. This works only when table.optimizer.reuse-sub-plan-enabled is true. |
| table.optimizer.reuse-sub-plan-enabled **Batch** **Streaming** | true    | Boolean | When it is true, the optimizer will try to find out duplicated sub-plans and reuse them. |
| table.optimizer.source.predicate-pushdown-enabled **Batch** **Streaming** | true    | Boolean | When it is true, the optimizer will push down predicates into the FilterableTableSource. Default value is true. |

### Planner 配置

以下配置可以用于调整 planner 的行为。

| Key                                                         | Default   | Type    | Description                                                  |
| :---------------------------------------------------------- | :-------- | :------ | :----------------------------------------------------------- |
| table.dynamic-table-options.enabled **Batch** **Streaming** | false     | Boolean | Enable or disable the OPTIONS hint used to specify table options dynamically, if disabled, an exception would be thrown if any OPTIONS hint is specified |
| table.generated-code.max-length **Batch** **Streaming**     | 64000     | Integer | Specifies a threshold where generated code will be split into sub-function calls. Java has a maximum method length of 64 KB. This setting allows for finer granularity if necessary. |
| table.local-time-zone **Batch** **Streaming**               | "default" | String  | The local time zone defines current session time zone id. It is used when converting to/from <code>TIMESTAMP WITH LOCAL TIME ZONE</code>. Internally, timestamps with local time zone are always represented in the UTC time zone. However, when converting to data types that don't include a time zone (e.g. TIMESTAMP, TIME, or simply STRING), the session time zone is used during conversion. The input of option is either an abbreviation such as "PST", a full name such as "America/Los_Angeles", or a custom timezone id such as "GMT-8:00". |
| table.sql-dialect **Batch** **Streaming**                   | "default" | String  | The SQL dialect defines how to parse a SQL query. A different SQL dialect may support different SQL grammar. Currently supported dialects are: default and hive |