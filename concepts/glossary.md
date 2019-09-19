# Glossary

## Flink Application Cluster

Flink应用程序集群是一个专用的Flink集群，它只执行一个Flink作业。Flink集群的生存期与Flink作业的生存期绑定在一起。以前，Flink应用程序集群也称为作业模式下的Flink集群。与Flink会话集群相比。

## Flink Cluster
一个分布式系统，通常由一个Flink Master和一个或多个Flink TaskManager进程组成。

## Event
事件是关于由应用程序建模的域的状态更改的语句。事件可以是流或批处理应用程序的输入和/或输出。事件是特殊类型的记录。

## ExecutionGraph

看[`Physical graph`](./glossary.md#physical-graph)

## Function

函数由用户实现，封装了Flink程序的应用逻辑。大多数函数都由相应的运算符包装。

## Instance

术语实例用于描述运行时特定类型(通常是操作符或函数)的特定实例。由于Apache Flink主要是用Java编写的，所以它对应于Java中实例或对象的定义。在Apache Flink上下文中，术语parallel instance也经常用于强调相同操作符或函数类型的多个实例是并行运行的。

## Flink Job

Flink作业是Flink程序的运行时表示。Flink作业可以提交给长期运行的Flink会话集群，也可以作为自包含的Flink应用程序集群启动。

## JobGraph

看[`Logical Graph`](./concepts/glossary.html#physical-graph)

## Flink JobManager

作业管理器是在Flink Master中运行的组件之一。作业管理器负责监督单个作业任务的执行。历史上，整个Flink Master被称为JobManager。

## Logical Graph

逻辑图是描述流处理程序高级逻辑的有向图。节点是操作符，边缘表示输入/输出关系或数据流或数据集。

## Managed State

托管状态描述已在框架中注册的应用程序状态。对于托管状态，Apache Flink将处理持久性和重新缩放等问题。

## Flink Master

Flink Master是Flink集群的主人。它包含三个不同的组件:Flink资源管理器、Flink调度程序和每个运行的Flink作业一个Flink作业管理器。

## Operator

逻辑图的节点。操作符执行某种操作，该操作通常由函数执行。源和汇是数据摄取和数据导出的特殊操作符。

## Operator Chain

操作符链由两个或多个连续操作符组成，中间没有任何重新分区。同一操作符中的操作符直接将记录链向前传递到彼此，而不需要经过序列化或Flink的网络堆栈。

## Partition

分区是整个数据流或数据集的一个独立子集。通过将每个记录分配给一个或多个分区，可以将数据流或数据集划分为多个分区。数据流或数据集的分区在运行时由任务使用。改变数据流或数据集分区方式的转换通常称为重新分区。

## Physical Graph

物理图是将逻辑图转换为分布式运行时中执行的结果。节点是任务，边缘表示输入/输出关系或数据流或数据集的分区。

## Record

记录是数据集或数据流的组成元素。操作符和函数接收记录作为输入，发出记录作为输出。

## Flink Session Cluster

一个长时间运行的Flink集群，它接受多个Flink作业来执行。此Flink集群的生存期不绑定到任何Flink作业的生存期。以前，Flink会话集群也称为会话模式下的Flink集群。与Flink应用程序集群相比。

## State Backend

对于流处理程序，Flink作业的状态后端决定它的状态如何存储在每个任务管理器(TaskManager的Java堆或(嵌入式)RocksDB)上，以及在检查点(Flink主文件系统的Java堆或文件系统)上。

## Sub-Task

子任务是负责处理数据流分区的任务。“子任务”一词强调同一操作符或操作符链有多个并行任务。

## Task

物理图的节点。任务是基本的工作单元，由Flink的运行时执行。任务恰好封装一个操作或[操作链](./concepts/glossary.html#operator-chain)的一个并行实例。

## Flink TaskManager

任务管理器是Flink集群的工作进程。任务被安排给taskmanager执行。它们彼此通信，以便在后续任务之间交换数据。

## Transformation

转换应用于一个或多个数据流或数据集，并产生一个或多个输出数据流或数据集。转换可能基于每个记录更改数据流或数据集，但也可能只更改其分区或执行聚合。虽然操作符和函数)是Flink API的“物理”部分，但转换只是一个API概念。具体地说，大多数(但不是所有)转换是由某些操作符实现的。