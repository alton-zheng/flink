# 调试窗口与事件时间

- [监控当前事件时间（Event Time）](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/ops/debugging/debugging_event_time.html#监控当前事件时间event-time)
- [处理散乱的事件时间](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/ops/debugging/debugging_event_time.html#处理散乱的事件时间)



## 监控当前事件时间（Event Time）

Flink 的[事件时间](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/event_time.html)和 watermark 支持对于处理乱序事件是十分强大的特性。然而，由于是系统内部跟踪时间进度，所以很难了解究竟正在发生什么。

可以通过 Flink web 界面或[指标系统](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/ops/metrics.html)访问 task 的 low watermarks。

Flink 中的 task 通过调用 `currentInputWatermark` 方法暴露一个指标，该指标表示当前 task 所接收到的 the lowest watermark。这个 long 类型值表示“当前事件时间”。该值通过获取上游算子收到的所有 watermarks 的最小值来计算。这意味着用 watermarks 跟踪的事件时间总是由最落后的 source 控制。

**使用 web 界面**可以访问 low watermark 指标，在指标选项卡中选择一个 task，然后选择 `<taskNr>.currentInputWatermark` 指标。在新的显示框中，你可以看到此 task 的当前 low watermark。

获取指标的另一种方式是使用**指标报告器**之一，如[指标系统](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/ops/metrics.html)文档所述。对于本地集群设置，我们推荐使用 JMX 指标报告器和类似于 [VisualVM](https://visualvm.github.io/) 的工具。



## 处理散乱的事件时间

- 方式 1：延迟的 Watermark（表明完整性），窗口提前触发
- 方式 2：具有最大延迟启发式的 Watermark，窗口接受迟到的数据