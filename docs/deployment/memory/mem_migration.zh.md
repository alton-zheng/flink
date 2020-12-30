# 升级指南

在 *1.10* 和 *1.11* 版本中，Flink 分别对 [TaskManager](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_setup_tm.html) 和 [JobManager](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_setup_jobmanager.html) 的内存配置方法做出了较大的改变。 部分配置参数被移除了，或是语义上发生了变化。 本篇升级指南将介绍如何将 [*Flink 1.9 及以前版本*](https://ci.apache.org/projects/flink/flink-docs-release-1.9/ops/mem_setup.html)的 TaskManager 内存配置升级到 *Flink 1.10 及以后版本*， 以及如何将 *Flink 1.10 及以前版本*的 JobManager 内存配置升级到 *Flink 1.11 及以后版本*。

- 升级 TaskManager 内存配置
  - [配置参数变化](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_migration.html#配置参数变化)
  - [总内存（原堆内存）](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_migration.html#总内存原堆内存)
  - [JVM 堆内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_migration.html#jvm-堆内存)
  - [托管内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_migration.html#托管内存)
- [升级 JobManager 内存配置](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_migration.html#升级-jobmanager-内存配置)
- [Flink JVM 进程内存限制](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_migration.html#flink-jvm-进程内存限制)
- 容器切除（Cut-Off）内存
  - [TaskManager](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_migration.html#taskmanager)
  - [JobManager](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_migration.html#jobmanager)
- [flink-conf.yaml 中的默认配置](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_migration.html#flink-confyaml-中的默认配置)

**注意：** 请仔细阅读本篇升级指南。 使用原本的和新的内存配制方法可能会使内存组成部分具有截然不同的大小。 未经调整直接沿用 Flink 1.10 以前版本的 TaskManager 配置文件或 Flink 1.11 以前版本的 JobManager 配置文件，可能导致应用的行为、性能发生变化，甚至造成应用执行失败。

**提示** 在 *1.10/1.11* 版本之前，Flink 不要求用户一定要配置 TaskManager/JobManager 内存相关的参数，因为这些参数都具有默认值。 [新的内存配置](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_setup.html#configure-total-memory)要求用户至少指定下列配置参数（或参数组合）的其中之一，否则 Flink 将无法启动。

| **TaskManager:**                                             | **JobManager:**                                              |
| :----------------------------------------------------------- | :----------------------------------------------------------- |
| [`taskmanager.memory.flink.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#taskmanager-memory-flink-size) | [`jobmanager.memory.flink.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#jobmanager-memory-flink-size) |
| [`taskmanager.memory.process.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#taskmanager-memory-process-size) | [`jobmanager.memory.process.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#jobmanager-memory-process-size) |
| [`taskmanager.memory.task.heap.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#taskmanager-memory-task-heap-size) 和 [`taskmanager.memory.managed.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#taskmanager-memory-managed-size) | [`jobmanager.memory.heap.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#jobmanager-memory-heap-size) |



Flink 自带的[默认 flink-conf.yaml](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_migration.html#default-configuration-in-flink-confyaml) 文件指定了 [`taskmanager.memory.process.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#taskmanager-memory-process-size)（*>= 1.10*）和 [`jobmanager.memory.process.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#jobmanager-memory-process-size) (*>= 1.11*)，以便与此前的行为保持一致。

可以使用这张[电子表格](https://docs.google.com/spreadsheets/d/1mJaMkMPfDJJ-w6nMXALYmTc4XxiV30P5U7DzgwLkSoE)来估算和比较原本的和新的内存配置下的计算结果。



## 升级 TaskManager 内存配置



### 配置参数变化

本节简要列出了 *Flink 1.10* 引入的配置参数变化，并援引其他章节中关于如何升级到新配置参数的相关描述。

下列配置参数已被彻底移除，配置它们将不会产生任何效果。

| 移除的配置参数                 | 备注                                                         |
| :----------------------------- | :----------------------------------------------------------- |
| taskmanager.memory.fraction    | 请参考新配置参数 [taskmanager.memory.managed.fraction](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#taskmanager-memory-managed-fraction) 的相关描述。 新的配置参数与被移除的配置参数在语义上有所差别，因此其配置值通常也需要做出适当调整。 请参考[如何升级托管内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_migration.html#managed-memory)。 |
| taskmanager.memory.off-heap    | Flink 不再支持堆上的（On-Heap）*托管内存*。请参考[如何升级托管内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_migration.html#managed-memory)。 |
| taskmanager.memory.preallocate | Flink 不再支持内存预分配，今后*托管内存*将都是惰性分配的。请参考[如何升级托管内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_migration.html#managed-memory)。 |

下列配置参数将被弃用，出于向后兼容性考虑，配置它们将被解读成对应的新配置参数。

| 弃用的配置参数                      | 对应的新配置参数                                             |
| :---------------------------------- | :----------------------------------------------------------- |
| taskmanager.heap.size               | [独立部署模式（Standalone Deployment）](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/resource-providers/standalone/)下：[taskmanager.memory.flink.size](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#taskmanager-memory-flink-size)容器化部署模式（Containerized Deployement）下：[taskmanager.memory.process.size](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#taskmanager-memory-process-size)请参考[如何升级总内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_migration.html#total-memory-previously-heap-memory)。 |
| taskmanager.memory.size             | [taskmanager.memory.managed.size](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#taskmanager-memory-managed-size)。请参考[如何升级托管内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_migration.html#managed-memory)。 |
| taskmanager.network.memory.min      | [taskmanager.memory.network.min](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#taskmanager-memory-network-min) |
| taskmanager.network.memory.max      | [taskmanager.memory.network.max](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#taskmanager-memory-network-max) |
| taskmanager.network.memory.fraction | [taskmanager.memory.network.fraction](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#taskmanager-memory-network-fraction) |

尽管网络内存的配置参数没有发生太多变化，我们仍建议您检查其配置结果。 网络内存的大小可能会受到其他内存部分大小变化的影响，例如总内存变化时，根据占比计算出的网络内存也可能发生变化。 请参考[内存模型详解](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_setup_tm.html#detailed-memory-model)。

容器切除（Cut-Off）内存相关的配置参数（`containerized.heap-cutoff-ratio` 和 `containerized.heap-cutoff-min`）将不再对 TaskManager 进程生效。 请参考[如何升级容器切除内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_migration.html#container-cut-off-memory)。



### 总内存（原堆内存）

在原本的内存配置方法中，用于指定用于 Flink 的总内存的配置参数是 `taskmanager.heap.size` 或 `taskmanager.heap.mb`。 尽管这两个参数以“堆（Heap）”命名，实际上它们指定的内存既包含了 JVM 堆内存，也包含了其他堆外内存部分。 这两个配置参数目前已被弃用。

Flink 在 Mesos 上还有另一个具有同样语义的配置参数 `mesos.resourcemanager.tasks.mem`，目前也已经被弃用。

如果配置了上述弃用的参数，同时又没有配置与之对应的新配置参数，那它们将按如下规则对应到新的配置参数。

- 独立部署模式（Standalone Deployment）下：Flink 总内存（[`taskmanager.memory.flink.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#taskmanager-memory-flink-size)）
- 容器化部署模式（Containerized Deployement）下（Yarn、Mesos）：进程总内存（[`taskmanager.memory.process.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#taskmanager-memory-process-size)）

建议您尽早使用新的配置参数取代启用的配置参数，它们在今后的版本中可能会被彻底移除。

请参考[如何配置总内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_setup.html#configure-total-memory).



### JVM 堆内存

此前，JVM 堆空间由托管内存（仅在配置为堆上时）及 Flink 用到的所有其他堆内存组成。 这里的其他堆内存是由总内存减去所有其他非堆内存得到的。 请参考[如何升级托管内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_migration.html#managed-memory)。

现在，如果仅配置了*Flink总内存*或*进程总内存*，JVM 的堆空间依然是根据总内存减去所有其他非堆内存得到的。 请参考[如何配置总内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_setup.html#configure-total-memory)。

此外，你现在可以更直接地控制用于任务和算子的 JVM 的堆内存（[`taskmanager.memory.task.heap.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#taskmanager-memory-task-heap-size)），详见[任务堆内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_setup_tm.html#task-operator-heap-memory)。 如果流处理作业选择使用 Heap State Backend（[MemoryStateBackend](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/ops/state/state_backends.html#memorystatebackend) 或 [FsStateBackend](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/ops/state/state_backends.html#fsstatebackend)），那么它同样需要使用 JVM 堆内存。

Flink 现在总是会预留一部分 JVM 堆内存供框架使用（[`taskmanager.memory.framework.heap.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#taskmanager-memory-framework-heap-size)）。 请参考[框架内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_setup_tm.html#framework-memory)。



### 托管内存

请参考[如何配置托管内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_setup_tm.html#managed-memory)。



#### 明确的大小

原本用于指定明确的托管内存大小的配置参数（`taskmanager.memory.size`）已被弃用，与它具有相同语义的新配置参数为 [`taskmanager.memory.managed.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#taskmanager-memory-managed-size)。 建议使用新的配置参数，原本的配置参数在今后的版本中可能会被彻底移除。



#### 占比

此前，如果不指定明确的大小，也可以将托管内存配置为占用总内存减去网络内存和容器切除内存（仅在 [Yarn](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/resource-providers/yarn.html) 和 [Mesos](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/resource-providers/mesos.html) 上）之后剩余部分的固定比例（`taskmanager.memory.fraction`）。 该配置参数已经被彻底移除，配置它不会产生任何效果。 请使用新的配置参数 [`taskmanager.memory.managed.fraction`](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#taskmanager-memory-managed-fraction)。 在未通过 [`taskmanager.memory.managed.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#taskmanager-memory-managed-size) 指定明确大小的情况下，新的配置参数将指定[托管内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_setup_tm.html#managed-memory)在 [Flink 总内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_setup.html#configure-total-memory)中的所占比例。



#### RocksDB State Backend

流处理作业如果选择使用 [RocksDBStateBackend](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/ops/state/state_backends.html#rocksdbstatebackend)，它使用的本地内存现在也被归为[托管内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_setup_tm.html#managed-memory)。 默认情况下，RocksDB 将限制其内存用量不超过[托管内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_setup_tm.html#managed-memory)大小，以避免在 [Yarn](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/resource-providers/yarn.html) 或 [Mesos](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/resource-providers/mesos.html) 上容器被杀。你也可以通过设置 [state.backend.rocksdb.memory.managed](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#state-backend-rocksdb-memory-managed) 来关闭 RocksDB 的内存控制。 请参考[如何升级容器切除内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_migration.html#container-cut-off-memory)。



#### 其他变化

此外，Flink 1.10 对托管内存还引入了下列变化：

- [托管内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_setup_tm.html#managed-memory)现在总是在堆外。配置参数 `taskmanager.memory.off-heap` 已被彻底移除，配置它不会产生任何效果。
- [托管内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_setup_tm.html#managed-memory)现在使用本地内存而非直接内存。这意味着托管内存将不在 JVM 直接内存限制的范围内。
- [托管内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_setup_tm.html#managed-memory)现在总是惰性分配的。配置参数 `taskmanager.memory.preallocate` 已被彻底移除，配置它不会产生任何效果。



## 升级 JobManager 内存配置

在原本的内存配置方法中，用于指定 *JVM 堆内存* 的配置参数是:

- `jobmanager.heap.size`
- `jobmanager.heap.mb`

尽管这两个参数以“堆（Heap）”命名，在此之前它们实际上只有在[独立部署模式](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/resource-providers/standalone/)才完全对应于 *JVM 堆内存*。 在容器化部署模式下（[Kubernetes](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/resource-providers/standalone/kubernetes.html) 和 [Yarn](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/resource-providers/yarn.html)），它们指定的内存还包含了其他堆外内存部分。 *JVM 堆空间*的实际大小，是参数指定的大小减去容器切除（Cut-Off）内存后剩余的部分。 容器切除内存在 *1.11* 及以上版本中已被彻底移除。

上述两个参数此前对 [Mesos](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/resource-providers/mesos.html) 部署模式并不生效。 Flink 在 Mesos 上启动 JobManager 进程时并未设置任何 JVM 内存参数。 从 *1.11* 版本开始，Flink 将采用与[独立部署模式](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/resource-providers/standalone/)相同的方式设置这些参数。

这两个配置参数目前已被弃用。 如果配置了上述弃用的参数，同时又没有配置与之对应的新配置参数，那它们将按如下规则对应到新的配置参数。

- 独立部署模式（Standalone Deployment）、Mesos 部署模式下：JVM 堆内存（[`jobmanager.memory.heap.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#jobmanager-memory-heap-size)）
- 容器化部署模式（Containerized Deployement）下（Kubernetes、Yarn）：进程总内存（[`jobmanager.memory.process.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#jobmanager-memory-process-size)）

建议您尽早使用新的配置参数取代启用的配置参数，它们在今后的版本中可能会被彻底移除。

如果仅配置了 *Flink 总内存*或*进程总内存*，那么 [JVM 堆内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_setup_jobmanager.html#configure-jvm-heap)将是总内存减去其他内存部分后剩余的部分。 请参考[如何配置总内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_setup.html#configure-total-memory)。 此外，也可以通过配置 [`jobmanager.memory.heap.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#jobmanager-memory-heap-size) 的方式直接指定 [JVM 堆内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_setup_jobmanager.html#configure-jvm-heap)。



## Flink JVM 进程内存限制

从 *1.10* 版本开始，Flink 通过设置相应的 JVM 参数，对 TaskManager 进程使用的 *JVM Metaspace* 和 *JVM 直接内存*进行限制。 从 *1.11* 版本开始，Flink 同样对 JobManager 进程使用的 *JVM Metaspace* 进行限制。 此外，还可以通过设置 [`jobmanager.memory.enable-jvm-direct-memory-limit`](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#jobmanager-memory-enable-jvm-direct-memory-limit) 对 JobManager 进程的 *JVM 直接内存*进行限制。 请参考 [JVM 参数](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_setup.html#jvm-parameters)。

Flink 通过设置上述 JVM 内存限制降低内存泄漏问题的排查难度，以避免出现[容器内存溢出](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_trouble.html#container-memory-exceeded)等问题。 请参考常见问题中关于 [JVM Metaspace](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_trouble.html#outofmemoryerror-metaspace) 和 [JVM 直接内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_trouble.html#outofmemoryerror-direct-buffer-memory) *OutOfMemoryError* 异常的描述。



## 容器切除（Cut-Off）内存

在容器化部署模式（Containerized Deployment）下，此前你可以指定切除内存。 这部分内存将预留给所有未被 Flink 计算在内的内存开销。 其主要来源是不受 Flink 直接管理的依赖使用的内存，例如 RocksDB、JVM 内部开销等。 相应的配置参数（`containerized.heap-cutoff-ratio` 和 `containerized.heap-cutoff-min`）不再生效。 新的内存配置方法引入了新的内存组成部分来具体描述这些内存用量。



### TaskManager

流处理作业如果使用了 [RocksDBStateBackend](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/ops/state/state_backends.html#the-rocksdbstatebackend)，RocksDB 使用的本地内存现在将被归为[托管内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_setup_tm.html#managed-memory)。 默认情况下，RocksDB 将限制其内存用量不超过[托管内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_setup_tm.html#managed-memory)大小。 请同时参考[如何升级托管内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_migration.html#managed-memory)以及[如何配置托管内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_setup_tm.html#managed-memory)。

其他堆外（直接或本地）内存开销，现在可以通过下列配置参数进行设置：

- 任务堆外内存（[`taskmanager.memory.task.off-heap.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#taskmanager-memory-task-off-heap-size)）
- 框架堆外内存（[`taskmanager.memory.framework.off-heap.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#taskmanager-memory-framework-off-heap-size)）
- JVM Metaspace（[`taskmanager.memory.jvm-metaspace.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#taskmanager-memory-jvm-metaspace-size)）
- [JVM 开销](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_setup_tm.html#detailed-memory-model)



### JobManager

可以通过下列配置参数设置堆外（直接或本地）内存开销：

- 堆外内存 ([`jobmanager.memory.off-heap.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#jobmanager-memory-off-heap-size))
- JVM Metaspace ([`jobmanager.memory.jvm-metaspace.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#jobmanager-memory-jvm-metaspace-size))
- [JVM 开销](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_setup_jobmanager.html#detailed-configuration)



## flink-conf.yaml 中的默认配置

本节描述 Flink 自带的默认 `flink-conf.yaml` 文件中的变化。

原本的 TaskManager 总内存（`taskmanager.heap.size`）被新的配置项 [`taskmanager.memory.process.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#taskmanager-memory-process-size) 所取代。 默认值从 1024Mb 增加到了 1728Mb。

原本的 JobManager 总内存（`jobmanager.heap.size`）被新的配置项 [`jobmanager.memory.process.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#taskmanager-memory-process-size) 所取代。 默认值从 1024Mb 增加到了 1600Mb。

请参考[如何配置总内存](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_setup.html#configure-total-memory)。

**注意：** 使用新的默认 `flink-conf.yaml` 可能会造成各内存部分的大小发生变化，从而产生性能变化。