# 作业调度

这篇文档简要描述了 Flink 怎样调度作业, 怎样在 JobManager 里描述和追踪作业状态

- [调度](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/internals/job_scheduling.html#调度)
- [JobManager 数据结构](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/internals/job_scheduling.html#jobmanager-数据结构)

## 调度

Flink 通过 *Task Slots* 来定义执行资源。每个 TaskManager 有一到多个 task slot，每个 task slot 可以运行一条由多个并行 task 组成的流水线。 这样一条流水线由多个连续的 task 组成，比如并行度为 *n* 的 MapFunction 和 并行度为 *n* 的 ReduceFunction。需要注意的是 Flink 经常并发执行连续的 task，不仅在流式作业中到处都是，在批量作业中也很常见。

下图很好的阐释了这一点，一个由数据源、*MapFunction* 和 *ReduceFunction* 组成的 Flink 作业，其中数据源和 MapFunction 的并行度为 4 ，ReduceFunction 的并行度为 3 。流水线由一系列的 Source - Map - Reduce 组成，运行在 2 个 TaskManager 组成的集群上，每个 TaskManager 包含 3 个 slot，整个作业的运行如下图所示。

![Assigning Pipelines of Tasks to Slots](https://ci.apache.org/projects/flink/flink-docs-release-1.12/fig/slots.svg)

Flink 内部通过 [SlotSharingGroup](https://github.com/apache/flink/blob/master//flink-runtime/src/main/java/org/apache/flink/runtime/jobmanager/scheduler/SlotSharingGroup.java) 和 [CoLocationGroup](https://github.com/apache/flink/blob/master//flink-runtime/src/main/java/org/apache/flink/runtime/jobmanager/scheduler/CoLocationGroup.java) 来定义哪些 task 可以共享一个 slot， 哪些 task 必须严格放到同一个 slot。

## JobManager 数据结构

在作业执行期间，JobManager 会持续跟踪各个 task，决定何时调度下一个或一组 task，处理已完成的 task 或执行失败的情况。

JobManager 会接收到一个 [JobGraph](https://github.com/apache/flink/blob/master//flink-runtime/src/main/java/org/apache/flink/runtime/jobgraph/)，用来描述由多个算子顶点 ([JobVertex](https://github.com/apache/flink/blob/master//flink-runtime/src/main/java/org/apache/flink/runtime/jobgraph/JobVertex.java)) 组成的数据流图，以及中间结果数据 ([IntermediateDataSet](https://github.com/apache/flink/blob/master//flink-runtime/src/main/java/org/apache/flink/runtime/jobgraph/IntermediateDataSet.java))。每个算子都有自己的可配置属性，比如并行度和运行的代码。除此之外，JobGraph 还包含算子代码执行所必须的依赖库。

JobManager 会将 JobGraph 转换成 [ExecutionGraph](https://github.com/apache/flink/blob/master//flink-runtime/src/main/java/org/apache/flink/runtime/executiongraph/)。可以将 ExecutionGraph 理解为并行版本的 JobGraph，对于每一个顶点 JobVertex，它的每个并行子 task 都有一个 [ExecutionVertex](https://github.com/apache/flink/blob/master//flink-runtime/src/main/java/org/apache/flink/runtime/executiongraph/ExecutionVertex.java)。一个并行度为 100 的算子会有 1 个 JobVertext 和 100 个 ExecutionVertex。ExecutionVertex 会跟踪子 task 的执行状态。 同一个 JobVertext 的所有 ExecutionVertex 都通过 [ExecutionJobVertex](https://github.com/apache/flink/blob/master//flink-runtime/src/main/java/org/apache/flink/runtime/executiongraph/ExecutionJobVertex.java) 来持有，并跟踪整个算子的运行状态。ExecutionGraph 除了这些顶点，还包含中间数据结果和分片情况 [IntermediateResult](https://github.com/apache/flink/blob/master//flink-runtime/src/main/java/org/apache/flink/runtime/executiongraph/IntermediateResult.java) 和 [IntermediateResultPartition](https://github.com/apache/flink/blob/master//flink-runtime/src/main/java/org/apache/flink/runtime/executiongraph/IntermediateResultPartition.java)。前者跟踪中间结果的状态，后者跟踪每个分片的状态。

![JobGraph and ExecutionGraph](https://ci.apache.org/projects/flink/flink-docs-release-1.12/fig/job_and_execution_graph.svg)

每个 ExecutionGraph 都有一个与之相关的作业状态信息，用来描述当前的作业执行状态。

Flink 作业刚开始会处于 *created* 状态，然后切换到 *running* 状态，当所有任务都执行完之后会切换到 *finished* 状态。如果遇到失败的话，作业首先切换到 *failing* 状态以便取消所有正在运行的 task。如果所有 job 节点都到达最终状态并且 job 无法重启， 那么 job 进入 *failed* 状态。如果作业可以重启，那么就会进入到 *restarting* 状态，当作业彻底重启之后会进入到 *created* 状态。

如果用户取消了 job 话，它会进入到 *cancelling* 状态，并取消所有正在运行的 task。当所有正在运行的 task 进入到最终状态的时候，job 进入 *cancelled* 状态。

*Finished*、*canceled* 和 *failed* 会导致全局的终结状态，并且触发作业的清理。跟这些状态不同，*suspended* 状态只是一个局部的终结。局部的终结意味着作业的执行已经被对应的 JobManager 终结，但是集群中另外的 JobManager 依然可以从高可用存储里获取作业信息并重启。因此一个处于 *suspended* 状态的作业不会被彻底清理掉。

![States and Transitions of Flink job](../fig/job_status.svg)

在整个 ExecutionGraph 执行期间，每个并行 task 都会经历多个阶段，从 *created* 状态到 *finished* 或 *failed*。下图展示了各种状态以及他们之间的转换关系。由于一个 task 可能会被执行多次(比如在异常恢复时)，ExecutionVertex 的执行是由 [Execution](https://github.com/apache/flink/blob/master//flink-runtime/src/main/java/org/apache/flink/runtime/executiongraph/Execution.java) 来跟踪的，每个 ExecutionVertex 会记录当前的执行，以及之前的执行。

![States and Transitions of Task Executions](../fig/state_machine.svg)