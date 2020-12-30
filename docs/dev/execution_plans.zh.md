# 执行计划

Flink 的优化器会根据诸如数据量或集群机器数等不同的参数自动地为你的程序选择执行策略。但在大多数情况下，准确地了解 Flink 会如何执行你的程序是很有帮助的。

**执行计划可视化工具**

Flink 为执行计划提供了[可视化工具](https://flink.apache.org/visualizer/)，它可以把用 JSON 格式表示的作业执行计划以图的形式展现，并且其中会包含完整的执行策略标注。

以下代码展示了如何在你的程序中打印 JSON 格式的执行计划：

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/execution_plans.html#tab_Java_0)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/execution_plans.html#tab_Scala_0)

```
final ExecutionEnvironment env = ExecutionEnvironment.getExecutionEnvironment();

...

System.out.println(env.getExecutionPlan());
```

可以通过如下步骤可视化执行计划：

1. 使用你的浏览器**打开**[可视化工具网站](https://flink.apache.org/visualizer/)，
2. 将 JSON 字符串拷贝并**粘贴**到文本框中，
3. **点击** draw 按钮。

完成后，详细的执行计划图会在网页中呈现。

![A flink job execution graph.](https://ci.apache.org/projects/flink/flink-docs-release-1.12/fig/plan_visualizer.png)

**Web 界面**

Flink 提供了用于提交和执行任务的 Web 界面。该界面是 JobManager Web 界面的一部分，起到管理监控的作用，默认情况下运行在 8081 端口。

可视化工具可以在执行 Flink 作业之前展示执行计划图，你可以据此来指定程序的参数。