# 指标

PyFlink支持指标系统，该指标系统允许收集指标并将其暴露给外部系统。

- 注册指标
  - [指标类型](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/metrics.html#指标类型)
- 范围（Scope）
  - [用户范围（User Scope）](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/metrics.html#用户范围user-scope)
  - [系统范围（System Scope）](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/metrics.html#系统范围system-scope)
  - [所有变量列表](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/metrics.html#所有变量列表)
  - [用户变量（User Variables）](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/metrics.html#用户变量user-variables)
- [PyFlink和Flink的共通部分](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/metrics.html#pyflink和flink的共通部分)

## 注册指标

您可以通过在[用户自定义函数](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/udfs/python_udfs.html)的`open`方法中调用`function_context.get_metric_group()`来访问指标系统。 `get_metric_group()`方法返回一个`MetricGroup`对象，您可以在该对象上创建和注册新指标。

### 指标类型

PyFlink支持计数器`Counters`，量表`Gauges`，分布`Distribution`和仪表`Meters`。

#### 计数器 Counter

`Counter`用于计算某个东西的出现次数。可以通过`inc()/inc(n: int)`或`dec()/dec(n: int)`增加或减少当前值。 您可以通过在`MetricGroup`上调用`counter(name: str)`来创建和注册`Counter`。

- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/metrics.html#tab_Python_0)

```
from pyflink.table.udf import ScalarFunction

class MyUDF(ScalarFunction):

    def __init__(self):
        self.counter = None

    def open(self, function_context):
        self.counter = function_context.get_metric_group().counter("my_counter")

    def eval(self, i):
        self.counter.inc(i)
        return i
```

#### 量表

`Gauge`可按需返回数值。您可以通过在MetricGroup上调用`gauge(name: str, obj: Callable[[], int])`来注册一个量表。Callable对象将用于汇报数值。量表指标(Gauge metrics)只能用于汇报整数值。

- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/metrics.html#tab_Python_1)

```
from pyflink.table.udf import ScalarFunction

class MyUDF(ScalarFunction):

    def __init__(self):
        self.length = 0

    def open(self, function_context):
        function_context.get_metric_group().gauge("my_gauge", lambda : self.length)

    def eval(self, i):
        self.length = i
        return i - 1
```

#### 分布（Distribution）

`Distribution`用于报告关于所报告值分布的信息（总和，计数，最小，最大和平均值）的指标。可以通过`update(n: int)`来更新当前值。您可以通过在MetricGroup上调用`distribution(name: str)`来注册该指标。分布指标(Distribution metrics)只能用于汇报整数指标。

- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/metrics.html#tab_Python_2)

```
from pyflink.table.udf import ScalarFunction

class MyUDF(ScalarFunction):

    def __init__(self):
        self.distribution = None

    def open(self, function_context):
        self.distribution = function_context.get_metric_group().distribution("my_distribution")

    def eval(self, i):
        self.distribution.update(i)
        return i - 1
```

#### 仪表

仪表用于汇报平均吞吐量。可以使用`mark_event()`函数来注册事件的发生，使用mark_event(n: int)函数来注册同时发生的多个事件。 您可以通过在MetricGroup上调用`meter(self, name: str, time_span_in_seconds: int = 60)`来注册仪表。time_span_in_seconds的默认值为60。

- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/metrics.html#tab_Python_3)

```
from pyflink.table.udf import ScalarFunction

class MyUDF(ScalarFunction):

    def __init__(self):
        self.meter = None

    def open(self, function_context):
        super().open(function_context)
        # 120秒内统计的平均每秒事件数，默认是60秒
        self.meter = function_context.get_metric_group().meter("my_meter", time_span_in_seconds=120)

    def eval(self, i):
        self.meter.mark_event(i)
        return i - 1
```

## 范围（Scope）

您可以参考Java指标文档以获取有关[范围定义](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/ops/metrics.html#Scope)的更多详细信息。

### 用户范围（User Scope）

您可以通过调用`MetricGroup.add_group(key: str, value: str = None)`来定义用户范围。如果`value`不为`None`，则创建一个新的键值`MetricGroup`对。 其中，键组被添加到该组的子组中，而值组又被添加到键组的子组中。在这种情况下，值组将作为结果返回，与此同时，创建一个用户变量。

- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/metrics.html#tab_Python_4)

```
function_context
    .get_metric_group()
    .add_group("my_metrics")
    .counter("my_counter")

function_context
    .get_metric_group()
    .add_group("my_metrics_key", "my_metrics_value")
    .counter("my_counter")
```

### 系统范围（System Scope）

您可以参考Java指标文档以获取有关[系统范围](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/ops/metrics.html#system-scope)的更多详细信息。

### 所有变量列表

您可以参考Java指标文档以获取有关[“所有变量列表”的](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/ops/metrics.html#list-of-all-variables)更多详细信息。

### 用户变量（User Variables）

您可以通过调用`MetricGroup.addGroup(key: str, value: str = None)`并指定value参数来定义用户变量。

**重要提示：**用户变量不能在以`scope format`中使用。

- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/metrics.html#tab_Python_5)

```
function_context
    .get_metric_group()
    .add_group("my_metrics_key", "my_metrics_value")
    .counter("my_counter")
```

## PyFlink和Flink的共通部分

您可以参考Java的指标文档，以获取关于以下部分的更多详细信息：

- [Reporter](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/metric_reporters.html) 。
- [系统指标](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/ops/metrics.html#system-metrics) 。
- [延迟跟踪](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/ops/metrics.html#latency-tracking) 。
- [REST API集成](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/ops/metrics.html#rest-api-integration) 。
- [仪表板集成](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/ops/metrics.html#dashboard-integration) 。