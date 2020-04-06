# 配置 TaskExecutor 内存

本文接下来介绍的内存配置方法适用于 *1.10* 及以上版本。
Flink 在 1.10 版本中对内存配置部分进行了较大幅度的改动，从早期版本升级的用户请参考[升级指南](mem_migration.md)。

- **提示：**
  - 本篇内存配置文档<strong>仅针对 TaskExecutor</strong>！关于 JobManager 的内存配置请参考 [JobManager 相关配置参数](../config.md#jobmanager-heap-size)。

## 配置总内存

Flink JVM 进程的*进程总内存（Total Process Memory）*包含了由 Flink 应用使用的内存（*Flink 总内存*）以及由运行 Flink 的 JVM 使用的内存。
其中，*Flink 总内存（Total Flink Memory）*包括 JVM 堆内存（Heap Memory）、*托管内存（Managed Memory）*以及其他直接内存（Direct Memory）或本地内存（Native Memory）。

![simple_mem_model](../../fig/simple_mem_model.svg)

如果你是在本地运行 Flink（例如在 IDE 中）而非创建一个集群，那么本文介绍的配置并非所有都是适用的，详情请参考[本地执行](mem_detail.md#本地执行)。

其他情况下，配置 Flink 内存最简单的方法就是配置下列两个参数中的任意一个。
* Flink 总内存（[`taskmanager.memory.flink.size`](../config.md#taskmanager-memory-flink-size)）
* 进程总内存（[`taskmanager.memory.process.size`](../config.md#taskmanager-memory-process-size)）

Flink 会根据默认值或其他配置参数自动调整剩余内存部分的大小。关于各内存部分的更多细节，请参考[相关文档](mem_detail.md)。

对于独立部署模式（Standalone Deployment），如果你希望指定由 Flink 应用本身使用的内存大小，最好选择配置 *Flink 总内存*。
*Flink 总内存*会进一步划分为 JVM 堆内存、[托管内存](#托管内存)和*直接内存*。

通过配置*进程总内存*可以指定由 Flink *JVM 进程*使用的总内存大小。
对于容器化部署模式（Containerized Deployment），这相当于申请的容器（Container）大小，详情请参考[如何配置容器内存](mem_tuning.md#容器container的内存配置)（[Kubernetes](../deployment/kubernetes.md)、[Yarn](../deployment/yarn_setup.md) 或 [Mesos](../deployment/mesos.md)）。

此外，还可以通过设置[任务堆内存（Task Heap Memory）](#任务算子堆内存)和[托管内存](#托管内存)的方式进行内存配置（[`taskmanager.memory.task.heap.size`](../config.md#taskmanager-memory-task-heap-size) 和 [`taskmanager.memory.managed.size`](../config.md#taskmanager-memory-managed-size)）。
这是一种更细粒度的配置方式，更多细节请参考[相关文档](#配置堆内存和托管内存)。

- **提示：**
  - 以上三种方式中，用户需要至少选择其中一种进行配置（本地运行除外），否则 Flink 将无法启动。
这意味着，用户需要从以下无默认值的配置参数（或参数组合）中选择一个给出明确的配置：
* [`taskmanager.memory.flink.size`](../config.md#taskmanager-memory-flink-size)
* [`taskmanager.memory.process.size`](../config.md#taskmanager-memory-process-size)
* [`taskmanager.memory.task.heap.size`](../config.md#taskmanager-memory-task-heap-size) 和 [`taskmanager.memory.managed.size`](../config.md#taskmanager-memory-managed-size)

- **提示：**
  - 不建议同时设置*进程总内存*和 *Flink 总内存*。
这可能会造成内存配置冲突，从而导致部署失败。
额外配置其他内存部分时，同样需要注意可能产生的配置冲突。

## 配置堆内存和托管内存

如[配置总内存](#配置总内存)中所述，另一种配置 Flink 内存的方式是同时设置[任务堆内存](#任务算子堆内存)和[托管内存](#托管内存)。
通过这种方式，用户可以更好地掌控用于 Flink 任务的 JVM 堆内存及 Flink 的[托管内存](#托管内存)大小。

Flink 会根据默认值或其他配置参数自动调整剩余内存部分的大小。关于各内存部分的更多细节，请参考[相关文档](mem_detail.md)。

- **提示：**
  - 如果已经明确设置了任务堆内存和托管内存，建议不要再设置*进程总内存*或 *Flink 总内存*，否则可能会造成内存配置冲突。

### 任务（算子）堆内存

如果希望确保指定大小的 JVM 堆内存给用户代码使用，可以明确指定*任务堆内存*（[`taskmanager.memory.task.heap.size`](../config.md#taskmanager-memory-task-heap-size)）。
指定的内存将被包含在总的 JVM 堆空间中，专门用于 Flink 算子及用户代码的执行。

### 托管内存

*托管内存*是由 Flink 负责分配和管理的本地（堆外）内存。
以下场景需要使用*托管内存*：
* 流处理作业中用于 [RocksDB State Backend](../state/state_backends.md#the-rocksdbstatebackend)。
* [批处理作业](../../dev/batch)中用于排序、哈希表及缓存中间结果。

可以通过以下两种范式指定*托管内存*的大小：
* 通过 [`taskmanager.memory.managed.size`](../config.md#taskmanager-memory-managed-size) 明确指定其大小。
* 通过 [`taskmanager.memory.managed.fraction`](../config.md#taskmanager-memory-managed-fraction) 指定在*Flink 总内存*中的占比。

当同时指定二者时，会优先采用指定的大小（Size）。
若二者均未指定，会根据[默认占比](../config.md#taskmanager-memory-managed-fraction)进行计算。

请同时参考[如何配置 State Backend 内存](mem_tuning.md#state-backend-的内存配置)以及[如何配置批处理作业内存](mem_tuning.md#批处理作业的内存配置)。

## 配置堆外内存（直接内存或本地内存）

用户代码中分配的堆外内存被归为*任务堆外内存（Task Off-Heap Memory），可以通过 [`taskmanager.memory.task.off-heap.size`](../config.md#taskmanager-memory-task-off-heap-size) 指定。

- **提示：**
  - 你也可以调整[框架推外内存（Framework Off-Heap Memory）](mem_detail.md#框架内存)。
这是一个进阶配置，建议仅在确定 Flink 框架需要更多的内存时调整该配置。

Flink 将*框架堆外内存*和*任务堆外内存*都计算在 JVM 的*直接内存*限制中，请参考 [JVM 参数](mem_detail.md#jvm-参数)。

- **提示：**
  - 本地内存（非直接内存）也可以被归在*框架堆外内存*或*任务推外内存*中，在这种情况下 JVM 的*直接内存*限制可能会高于实际需求。

- **提示：**
  - *网络内存（Network Memory）*同样被计算在 JVM *直接内存*中。
Flink 会负责管理网络内存，保证其实际用量不会超过配置大小。
因此，调整*网络内存*的大小不会对其他堆外内存有实质上的影响。

请参考[内存模型详解](mem_detail.md)。
