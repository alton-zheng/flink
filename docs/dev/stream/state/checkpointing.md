# Checkpointing

- [前提条件](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/state/checkpointing.html#%E5%89%8D%E6%8F%90%E6%9D%A1%E4%BB%B6)
- [开启与配置 Checkpoint](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/state/checkpointing.html#%E5%BC%80%E5%90%AF%E4%B8%8E%E9%85%8D%E7%BD%AE-checkpoint)
  - [相关的配置选项](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/state/checkpointing.html#%E7%9B%B8%E5%85%B3%E7%9A%84%E9%85%8D%E7%BD%AE%E9%80%89%E9%A1%B9)
- [选择一个 State Backend](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/state/checkpointing.html#%E9%80%89%E6%8B%A9%E4%B8%80%E4%B8%AA-state-backend)
- [迭代作业中的状态和 checkpoint](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/state/checkpointing.html#%E8%BF%AD%E4%BB%A3%E4%BD%9C%E4%B8%9A%E4%B8%AD%E7%9A%84%E7%8A%B6%E6%80%81%E5%92%8C-checkpoint)
- [重启策略](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/state/checkpointing.html#%E9%87%8D%E5%90%AF%E7%AD%96%E7%95%A5)

Flink 中的每个方法或算子都能够是**有状态的**（阅读  [working with state](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/state/state.html)  了解更多）。 状态化的方法在处理单个 元素/事件 的时候存储数据，让状态成为使各个类型的算子更加精细的重要部分。 为了让状态容错，Flink 需要为状态添加  **checkpoint（检查点）**。Checkpoint 使得 Flink 能够恢复状态和在流中的位置，从而向应用提供和无故障执行时一样的语义。

[容错文档](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/internals/stream_checkpointing.html)  中介绍了 Flink 流计算容错机制内部的技术原理。

## 前提条件

Flink 的 checkpoint 机制会和持久化存储进行交互，读写流与状态。一般需要：

- 一个能够回放一段时间内数据的持久化数据源，例如持久化消息队列（例如 Apache Kafka、RabbitMQ、 Amazon Kinesis、 Google PubSub 等）或文件系统（例如 HDFS、 S3、 GFS、 NFS、 Ceph 等）。
- 存放状态的持久化存储，通常为分布式文件系统（比如 HDFS、 S3、 GFS、 NFS、 Ceph 等）。

## 开启与配置 Checkpoint

默认情况下 checkpoint 是禁用的。通过调用  `StreamExecutionEnvironment`  的  `enableCheckpointing(n)`  来启用 checkpoint，里面的  *n*  是进行 checkpoint 的间隔，单位毫秒。

Checkpoint 其他的属性包括：

- _精确一次（exactly-once）对比至少一次（at-least-once）_：你可以选择向  `enableCheckpointing(long interval, CheckpointingMode mode)`  方法中传入一个模式来选择使用两种保证等级中的哪一种。 对于大多数应用来说，精确一次是较好的选择。至少一次可能与某些延迟超低（始终只有几毫秒）的应用的关联较大。

- _checkpoint 超时_：如果 checkpoint 执行的时间超过了该配置的阈值，还在进行中的 checkpoint 操作就会被抛弃。

- _checkpoints 之间的最小时间_：该属性定义在 checkpoint 之间需要多久的时间，以确保流应用在 checkpoint 之间有足够的进展。如果值设置为了  *5000*， 无论 checkpoint 持续时间与间隔是多久，在前一个 checkpoint 完成时的至少五秒后会才开始下一个 checkpoint。

  往往使用“checkpoints 之间的最小时间”来配置应用会比 checkpoint 间隔容易很多，因为“checkpoints 之间的最小时间”在 checkpoint 的执行时间超过平均值时不会受到影响（例如如果目标的存储系统忽然变得很慢）。

  注意这个值也意味着并发 checkpoint 的数目是*一*。

- _并发 checkpoint 的数目_: 默认情况下，在上一个 checkpoint 未完成（失败或者成功）的情况下，系统不会触发另一个 checkpoint。这确保了拓扑不会在 checkpoint 上花费太多时间，从而影响正常的处理流程。 不过允许多个 checkpoint 并行进行是可行的，对于有确定的处理延迟（例如某方法所调用比较耗时的外部服务），但是仍然想进行频繁的 checkpoint 去最小化故障后重跑的 pipelines 来说，是有意义的。

  该选项不能和 “checkpoints 间的最小时间”同时使用。

- _externalized checkpoints_: 你可以配置周期存储 checkpoint 到外部系统中。Externalized checkpoints 将他们的元数据写到持久化存储上并且在 job 失败的时候*不会*被自动删除。 这种方式下，如果你的 job 失败，你将会有一个现有的 checkpoint 去恢复。更多的细节请看  [Externalized checkpoints 的部署文档](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/ops/state/checkpoints.html#externalized-checkpoints)。

- _在 checkpoint 出错时使 task 失败或者继续进行 task_：他决定了在 task checkpoint 的过程中发生错误时，是否使 task 也失败，使失败是默认的行为。 或者禁用它时，这个任务将会简单的把 checkpoint 错误信息报告给 checkpoint coordinator 并继续运行。

- _优先从 checkpoint 恢复（prefer checkpoint for recovery）_：该属性确定 job 是否在最新的 checkpoint 回退，即使有更近的 savepoint 可用，这可以潜在地减少恢复时间（checkpoint 恢复比 savepoint 恢复更快）。

* [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/state/checkpointing.html#tab_java_0)
* [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/state/checkpointing.html#tab_scala_0)
* [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/state/checkpointing.html#tab_python_0)

  StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

  // 每 1000ms 开始一次 checkpoint
  env.enableCheckpointing(1000);

  // 高级选项：

  // 设置模式为精确一次 (这是默认值)
  env.getCheckpointConfig().setCheckpointingMode(CheckpointingMode.EXACTLY_ONCE);

  // 确认 checkpoints 之间的时间会进行 500 ms
  env.getCheckpointConfig().setMinPauseBetweenCheckpoints(500);

  // Checkpoint 必须在一分钟内完成，否则就会被抛弃
  env.getCheckpointConfig().setCheckpointTimeout(60000);

  // 同一时间只允许一个 checkpoint 进行
  env.getCheckpointConfig().setMaxConcurrentCheckpoints(1);

  // 开启在 job 中止后仍然保留的 externalized checkpoints
  env.getCheckpointConfig().enableExternalizedCheckpoints(ExternalizedCheckpointCleanup.RETAIN_ON_CANCELLATION);

  // 允许在有更近 savepoint 时回退到 checkpoint
  env.getCheckpointConfig().setPreferCheckpointForRecovery(true);

### 相关的配置选项

更多的属性与默认值能在  `conf/flink-conf.yaml`  中设置（完整教程请阅读  [配置](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/ops/config.html)）。

```
Key	                                |   Default	     |  Description
state.backend	                    |   (none)	     |  用于存储和检查点状态的状态后端。
state.backend.async	                |   TRUE	     |  选项状态后端是否应在可能且可配置的情况下使用异步快照方法。一些状态后端可能不支持异步快照，或者只支持异步快照，并忽略此选项。
state.backend.fs.memory-threshold	|   1024	     |  状态数据文件的最小大小。所有小于该值的状态块都内联存储在根检查点元数据文件中。
state.backend.fs.write-buffer-size	|   4096	     |  写入文件系统的检查点流的写缓冲区的默认大小。实际写缓冲区大小被确定为此选项和选项'state.backend.fs.memory-threshold'的值的最大值。
state.backend.incremental	        |   FALSE	     |  如果可能，选择状态后端是否应该创建增量检查点。对于增量检查点，只存储前一个检查点的差异，而不存储完整的检查点状态。一些状态后端可能不支持增量检查点并忽略此选项。
state.backend.local-recovery	    |   FALSE	     |  此选项为此状态后端配置本地恢复。默认情况下，本地恢复被禁用。本地恢复目前只覆盖键控状态后端。目前，memorystateback不支持本地恢复，因此忽略该选项。
state.checkpoints.dir	            |   (none)	     |  用于在Flink支持的文件系统中存储检查点的数据文件和元数据的默认目录。存储路径必须可从所有参与的进程/节点(即所有任务管理器和作业管理器)。
state.checkpoints.num-retained	    |   1	         |  要保留的已完成检查点的最大数量。
state.savepoints.dir	            |   (none)	     |  保存点的默认目录。用于将保存点写入文件系统的状态后端(memorystate后端、fsstate后端、rocksdbstate后端)。
taskmanager.state.local.root-dirs	|   (none)	     |  定义根目录的配置参数，用于存储用于本地恢复的基于文件的状态。本地恢复目前只覆盖键控状态后端。目前，memorystateback不支持本地恢复，因此忽略该选项
```

[ Back to top](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/state/checkpointing.html#top)

## 选择一个 State Backend

Flink 的  [checkpointing 机制](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/internals/stream_checkpointing.html)  会将 timer 以及 stateful 的 operator 进行快照，然后存储下来， 包括连接器（connectors），窗口（windows）以及任何用户[自定义的状态](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/state/state.html)。 Checkpoint 存储在哪里取决于所配置的  **State Backend**（比如 JobManager memory、 file system、 database）。

默认情况下，状态是保持在 TaskManagers 的内存中，checkpoint 保存在 JobManager 的内存中。为了合适地持久化大体量状态， Flink 支持各种各样的途径去存储 checkpoint 状态到其他的 state backends 上。通过  `StreamExecutionEnvironment.setStateBackend(…)`  来配置所选的 state backends。

阅读  [state backends](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/ops/state/state_backends.html)  来查看在 job 范围和集群范围上可用的 state backends 与选项的更多细节。

## 迭代作业中的状态和 checkpoint

Flink 现在为没有迭代（iterations）的作业提供一致性的处理保证。在迭代作业上开启 checkpoint 会导致异常。为了在迭代程序中强制进行 checkpoint，用户需要在开启 checkpoint 时设置一个特殊的标志： `env.enableCheckpointing(interval, CheckpointingMode.EXACTLY_ONCE, force = true)`。

请注意在环形边上游走的记录（以及与之相关的状态变化）在故障时会丢失。

[ Back to top](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/stream/state/checkpointing.html#top)

## 重启策略

Flink 支持不同的重启策略，来控制 job 万一故障时该如何重启。更多信息请阅读  [重启策略](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/restart_strategies.html)。
