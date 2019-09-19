# Checkpointing
Flink中的每个函数和操作符都可以是有状态的(有关详细信息，请参阅使用状态)。有状态函数在各个元素/事件的处理过程中存储数据，使状态成为任何类型的更精细操作的关键构建块。

为了使状态容错，Flink需要对状态进行检查点。检查点允许Flink恢复流中的状态和位置，从而为应用程序提供与无故障执行相同的语义。

关于流容错的文档详细描述了Flink流容错机制背后的技术。

先决条件
Flink的检查点机制与流和状态的持久存储交互。一般来说，它要求:

一种持久性(或持久性)数据源，可以在一定时间内重放记录。此类源的例子有持久消息队列(例如Apache Kafka、RabbitMQ、Amazon Kinesis、谷歌PubSub)或文件系统(例如HDFS、S3、GFS、NFS、Ceph，……)。
状态的持久存储，通常是分布式文件系统(例如，HDFS、S3、GFS、NFS、Ceph，…)
启用和配置检查点
默认情况下，检查点是禁用的。要启用检查点，可以在StreamExecutionEnvironment上调用enablecheckpoint (n)，其中n是检查点间隔(以毫秒为单位)。

检查点的其他参数包括:

一次与至少一次:您可以选择将模式传递给enablecheckpoint (n)方法，以在两个保证级别之间进行选择。对大多数应用程序来说，一次是最好的。至少一次可能与某些超低延迟(始终只有几毫秒)应用程序相关。

检查点超时:在此之后中止正在进行的检查点的时间，如果到那时还没有完成的话。

检查点之间的最短时间:为了确保流应用程序在检查点之间取得一定的进展，可以定义检查点之间需要多少时间。例如，如果将此值设置为5000，则无论检查点持续时间和检查点间隔如何，下一个检查点将在前一个检查点完成后5秒内启动。注意，这意味着检查点间隔永远不会小于这个参数。

通过定义“检查点之间的时间”比检查点间隔更容易配置应用程序，因为“检查点之间的时间”不受检查点有时可能比平均时间更长这一事实的影响(例如，如果目标存储系统暂时变慢)。

注意，这个值还意味着并发检查点的数量为1。

并发检查点数量:默认情况下，当一个检查点仍在进行时，系统不会触发另一个检查点。这确保拓扑不会在检查点上花费太多时间，也不会在处理流方面取得进展。可以允许多个重叠的检查站,这很有趣的管道有一定处理延迟(例如,因为函数调用外部服务,需要一些时间来回应),但仍然想做的非常频繁的检查点(100毫秒)处理文档很少失败。

当定义检查点之间的最小时间间隔时，不能使用此选项。

外部检查点:您可以配置定期检查点，使其在外部持久。外部检查点将其元数据写到持久存储中，并且在作业失败时不会自动清理。这样，如果你的工作失败了，你就会有一个检查点来重新开始工作。关于外部化检查点的部署说明中有更多细节。

检查点错误上的失败/继续任务:这决定了如果在执行任务的检查点过程中发生错误，任务是否会失败。这是默认行为。或者，当禁用此选项时，任务将简单地将检查点拒绝给检查点协调器并继续运行。

优先选择检查点进行恢复:这将确定一个作业是否回退到最新的检查点，即使有更多最近的保存点可用来潜在地减少恢复时间。

```java
StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

// start a checkpoint every 1000 ms
env.enableCheckpointing(1000);

// advanced options:

// set mode to exactly-once (this is the default)
env.getCheckpointConfig().setCheckpointingMode(CheckpointingMode.EXACTLY_ONCE);

// make sure 500 ms of progress happen between checkpoints
env.getCheckpointConfig().setMinPauseBetweenCheckpoints(500);

// checkpoints have to complete within one minute, or are discarded
env.getCheckpointConfig().setCheckpointTimeout(60000);

// allow only one checkpoint to be in progress at the same time
env.getCheckpointConfig().setMaxConcurrentCheckpoints(1);

// enable externalized checkpoints which are retained after job cancellation
env.getCheckpointConfig().enableExternalizedCheckpoints(ExternalizedCheckpointCleanup.RETAIN_ON_CANCELLATION);

// allow job recovery fallback to checkpoint when there is a more recent savepoint
env.getCheckpointConfig().setPreferCheckpointForRecovery(true);
```

## Related Config Options
可以通过conf/flink-conf设置更多的参数和/或默认值。yaml(参见配置获得完整的指南):
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

## Selecting a State Backend

Flink的检查点机制将所有状态的一致快照存储在定时器和有状态操作符中，包括连接器、窗口和任何用户定义的状态。检查点存储在哪里(例如，JobManager内存、文件系统、数据库)取决于配置的状态后端。

默认情况下，状态保存在任务管理器的内存中，检查点存储在JobManager的内存中。对于大状态的适当持久性，Flink支持在其他状态后端存储和检查点状态的各种方法。状态后端选择可以通过streamexecutionenvironment . setstate后端(…)配置。

有关可用状态后端以及作业范围和集群范围配置的选项的详细信息，请参阅状态后端。

## State Checkpoints in Iterative Jobs
Flink目前仅为没有迭代的作业提供处理保证。在迭代作业上启用检查点会导致异常。为了在迭代程序上强制检查点，用户需要在启用检查点时设置一个特殊的标志:env。enableCheckpointing(间隔,CheckpointingMode。完全正确，force = true)。

请注意，循环边中的飞行记录(以及与之相关的状态更改)将在故障期间丢失。


## Restart Strategies
Flink支持不同的重启策略，这些策略控制在发生故障时如何重启作业。有关更多信息，请参见重启策略。