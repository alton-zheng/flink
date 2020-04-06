# Task 故障恢复

## Restart Strategies

Flink 作业如果没有定义重启策略，则会遵循集群启动时加载的默认重启策略。
如果提交作业时设置了重启策略，该策略将覆盖掉集群的默认策略。

通过 Flink 的配置文件 `flink-conf.yaml` 来设置默认的重启策略。配置参数 *restart-strategy* 定义了采取何种策略。
如果没有启用 checkpoint，就采用“不重启”策略。如果启用了 checkpoint 且没有配置重启策略，那么就采用固定延时重启策略，
此时最大尝试重启次数由 `Integer.MAX_VALUE` 参数设置。下表列出了可用的重启策略和与其对应的配置值。

每个重启策略都有自己的一组配置参数来控制其行为。
这些参数也在配置文件中设置。
后文的描述中会详细介绍每种重启策略的配置项。

<table class="table table-bordered">
<thead>
<tr>
<th class="text-left">Key</th>
<th class="text-left">Default</th>
<th class="text-left">Type</th>
<th class="text-left">Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<h5 id="restart-strategy">restart-strategy</h5>
</td>
<td>(none)</td>
<td>String</td>
<td>Defines the restart strategy to use in case of job failures.<br />Accepted values are:
<ul>
<li><code class="highlighter-rouge">none</code>,&nbsp;<code class="highlighter-rouge">off</code>,&nbsp;<code class="highlighter-rouge">disable</code>: No restart strategy.</li>
<li><code class="highlighter-rouge">fixeddelay</code>,&nbsp;<code class="highlighter-rouge">fixed-delay</code>: Fixed delay restart strategy. More details can be found&nbsp;<a href="task_failure_recovery.md#fixed-delay-restart-strategy">here</a>.</li>
<li><code class="highlighter-rouge">failurerate</code>,&nbsp;<code class="highlighter-rouge">failure-rate</code>: Failure rate restart strategy. More details can be found&nbsp;<a href="task_failure_recovery.md#failure-rate-restart-strategy">here</a>.</li>
</ul>
If checkpointing is disabled, the default value is&nbsp;<code class="highlighter-rouge">none</code>. If checkpointing is enabled, the default value is&nbsp;<code class="highlighter-rouge">fixed-delay</code>&nbsp;with&nbsp;<code class="highlighter-rouge">Integer.MAX_VALUE</code>&nbsp;restart attempts and '<code class="highlighter-rouge">1 s</code>' delay.</td>
</tr>
</tbody>
</table>

除了定义默认的重启策略以外，还可以为每个 Flink 作业单独定义重启策略。
这个重启策略通过在程序中的 `ExecutionEnvironment` 对象上调用 `setRestartStrategy` 方法来设置。
当然，对于 `StreamExecutionEnvironment` 也同样适用。

下例展示了如何给我们的作业设置固定延时重启策略。
如果发生故障，系统会重启作业 3 次，每两次连续的重启尝试之间等待 10 秒钟。

```java
ExecutionEnvironment env = ExecutionEnvironment.getExecutionEnvironment();
env.setRestartStrategy(RestartStrategies.fixedDelayRestart(
  3, // 尝试重启的次数
  Time.of(10, TimeUnit.SECONDS) // 延时
));```

```scala
val env = ExecutionEnvironment.getExecutionEnvironment()
env.setRestartStrategy(RestartStrategies.fixedDelayRestart(
  3, // 尝试重启的次数
  Time.of(10, TimeUnit.SECONDS) // 延时
))
```

以下部分详细描述重启策略的配置项。

### Fixed Delay Restart Strategy

固定延时重启策略按照给定的次数尝试重启作业。
如果尝试超过了给定的最大次数，作业将最终失败。
在连续的两次重启尝试之间，重启策略等待一段固定长度的时间。

通过在 `flink-conf.yaml` 中设置如下配置参数，默认启用此策略。

```properties
restart-strategy: fixed-delay
```

<table class="table table-bordered">
<thead>
<tr>
<th class="text-left">Key</th>
<th class="text-left">Default</th>
<th class="text-left">Type</th>
<th class="text-left">Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<h5 id="restart-strategy-fixed-delay-attempts">restart-strategy.fixed-delay.attempts</h5>
</td>
<td>1</td>
<td>Integer</td>
<td>The number of times that Flink retries the execution before the job is declared as failed if&nbsp;<code class="highlighter-rouge">restart-strategy</code>&nbsp;has been set to&nbsp;<code class="highlighter-rouge">fixed-delay</code>.</td>
</tr>
<tr>
<td>
<h5 id="restart-strategy-fixed-delay-delay">restart-strategy.fixed-delay.delay</h5>
</td>
<td>1 s</td>
<td>Duration</td>
<td>Delay between two consecutive restart attempts if&nbsp;<code class="highlighter-rouge">restart-strategy</code>&nbsp;has been set to&nbsp;<code class="highlighter-rouge">fixed-delay</code>. Delaying the retries can be helpful when the program interacts with external systems where for example connections or pending transactions should reach a timeout before re-execution is attempted. It can be specified using notation: "1 min", "20 s"</td>
</tr>
</tbody>
</table>

例如：

```yaml
restart-strategy.fixed-delay.attempts: 3
restart-strategy.fixed-delay.delay: 10 s
```

固定延迟重启策略也可以在程序中设置：

```java
ExecutionEnvironment env = ExecutionEnvironment.getExecutionEnvironment();
env.setRestartStrategy(RestartStrategies.fixedDelayRestart(
  3, // 尝试重启的次数
  Time.of(10, TimeUnit.SECONDS) // 延时
));
```

```scala
val env = ExecutionEnvironment.getExecutionEnvironment()
env.setRestartStrategy(RestartStrategies.fixedDelayRestart(
  3, // 尝试重启的次数
  Time.of(10, TimeUnit.SECONDS) // 延时
))
```

### Failure Rate Restart Strategy

故障率重启策略在故障发生之后重启作业，但是当**故障率**（每个时间间隔发生故障的次数）超过设定的限制时，作业会最终失败。
在连续的两次重启尝试之间，重启策略等待一段固定长度的时间。

通过在 `flink-conf.yaml` 中设置如下配置参数，默认启用此策略。

```yaml
restart-strategy: failure-rate
```

<table class="table table-bordered">
<thead>
<tr>
<th class="text-left">Key</th>
<th class="text-left">Default</th>
<th class="text-left">Type</th>
<th class="text-left">Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<h5 id="restart-strategy-failure-rate-delay">restart-strategy.failure-rate.delay</h5>
</td>
<td>1 s</td>
<td>Duration</td>
<td>Delay between two consecutive restart attempts if&nbsp;<code class="highlighter-rouge">restart-strategy</code>&nbsp;has been set to&nbsp;<code class="highlighter-rouge">failure-rate</code>. It can be specified using notation: "1 min", "20 s"</td>
</tr>
<tr>
<td>
<h5 id="restart-strategy-failure-rate-failure-rate-interval">restart-strategy.failure-rate.failure-rate-interval</h5>
</td>
<td>1 min</td>
<td>Duration</td>
<td>Time interval for measuring failure rate if&nbsp;<code class="highlighter-rouge">restart-strategy</code>&nbsp;has been set to&nbsp;<code class="highlighter-rouge">failure-rate</code>. It can be specified using notation: "1 min", "20 s"</td>
</tr>
<tr>
<td>
<h5 id="restart-strategy-failure-rate-max-failures-per-interval">restart-strategy.failure-rate.max-failures-per-interval</h5>
</td>
<td>1</td>
<td>Integer</td>
<td>Maximum number of restarts in given time interval before failing a job if&nbsp;<code class="highlighter-rouge">restart-strategy</code>&nbsp;has been set to&nbsp;<code class="highlighter-rouge">failure-rate</code>.</td>
</tr>
</tbody>
</table>
<p>&nbsp;</p>

例如：

```yaml
restart-strategy.failure-rate.max-failures-per-interval: 3
restart-strategy.failure-rate.failure-rate-interval: 5 min
restart-strategy.failure-rate.delay: 10 s
```

故障率重启策略也可以在程序中设置：

```java
ExecutionEnvironment env = ExecutionEnvironment.getExecutionEnvironment();
env.setRestartStrategy(RestartStrategies.failureRateRestart(
  3, // 每个时间间隔的最大故障次数
  Time.of(5, TimeUnit.MINUTES), // 测量故障率的时间间隔
  Time.of(10, TimeUnit.SECONDS) // 延时
));
```

```scala
val env = ExecutionEnvironment.getExecutionEnvironment()
env.setRestartStrategy(RestartStrategies.failureRateRestart(
  3, // 每个时间间隔的最大故障次数
  Time.of(5, TimeUnit.MINUTES), // 测量故障率的时间间隔
  Time.of(10, TimeUnit.SECONDS) // 延时
))
```


### No Restart Strategy

作业直接失败，不尝试重启。

```yaml
restart-strategy: none
```

不重启策略也可以在程序中设置：

```java
ExecutionEnvironment env = ExecutionEnvironment.getExecutionEnvironment();
env.setRestartStrategy(RestartStrategies.noRestart());
```

```scala
val env = ExecutionEnvironment.getExecutionEnvironment()
env.setRestartStrategy(RestartStrategies.noRestart())
```

### Fallback Restart Strategy

使用群集定义的重启策略。
这对于启用了 checkpoint 的流处理程序很有帮助。
如果没有定义其他重启策略，默认选择固定延时重启策略。

## Failover Strategies

Flink 支持多种不同的故障恢复策略，该策略需要通过 Flink 配置文件 `flink-conf.yaml` 中的 *jobmanager.execution.failover-strategy*
配置项进行配置。

<table class="table table-bordered">
<thead>
<tr>
<th class="text-left">故障恢复策略</th>
<th class="text-left">jobmanager.execution.failover-strategy 配置值</th>
</tr>
</thead>
<tbody>
<tr>
<td>全图重启</td>
<td>full</td>
</tr>
<tr>
<td>基于 Region 的局部重启</td>
<td>region</td>
</tr>
</tbody>
</table>
<p>&nbsp;</p>

### Restart All Failover Strategy

在全图重启故障恢复策略下，Task 发生故障时会重启作业中的所有 Task 进行故障恢复。

### Restart Pipelined Region Failover Strategy

该策略会将作业中的所有 Task 划分为数个 Region。当有 Task 发生故障时，它会尝试找出进行故障恢复需要重启的最小 Region 集合。
相比于全局重启故障恢复策略，这种策略在一些场景下的故障恢复需要重启的 Task 会更少。

此处 Region 指以 Pipelined 形式进行数据交换的 Task 集合。也就是说，Batch 形式的数据交换会构成 Region 的边界。
- DataStream 和 流式 Table/SQL 作业的所有数据交换都是 Pipelined 形式的。
- 批处理式 Table/SQL 作业的所有数据交换默认都是 Batch 形式的。
- DataSet 作业中的数据交换形式会根据 [ExecutionConfig](execution_configuration.md) 
  中配置的 "ExecutionMode"
  决定。

需要重启的 Region 的判断逻辑如下：
1. 出错 Task 所在 Region 需要重启。
2. 如果要重启的 Region 需要消费的数据有部分无法访问（丢失或损坏），产出该部分数据的 Region 也需要重启。
3. 需要重启的 Region 的下游 Region 也需要重启。这是出于保障数据一致性的考虑，因为一些非确定性的计算或者分发会导致同一个
   Result Partition 每次产生时包含的数据都不相同。

{% top %}
