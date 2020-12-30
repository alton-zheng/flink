# 连接器

本篇描述了如何在 PyFlink 中使用连接器，并着重介绍了在 Python 程序中使用 Flink 连接器时需要注意的细节。

- [下载连接器（connector）和格式（format）jar 包](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/python_table_api_connectors.html#下载连接器connector和格式formatjar-包)
- [如何使用连接器](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/python_table_api_connectors.html#如何使用连接器)
- 内置的 Sources 和 Sinks
  - [和 Pandas 之间互转](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/python_table_api_connectors.html#和-pandas-之间互转)
  - [from_elements()](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/python_table_api_connectors.html#from_elements)
- [用户自定义的 source 和 sink](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/python_table_api_connectors.html#用户自定义的-source-和-sink)

**Note** 想要了解常见的连接器信息和通用配置，请查阅相关的 [Java/Scala 文档](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/)。

## 下载连接器（connector）和格式（format）jar 包

由于 Flink 是一个基于 Java/Scala 的项目，连接器（connector）和格式（format）的实现是作为 jar 包存在的，要在 PyFlink 作业中使用，首先需要将其指定为作业的 [依赖](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/dependency_management.html)。

```
table_env.get_config().get_configuration().set_string("pipeline.jars", "file:///my/jar/path/connector.jar;file:///my/jar/path/json.jar")
```

## 如何使用连接器

在 PyFink Table API 中，DDL 是定义 source 和 sink 比较推荐的方式，这可以通过 `TableEnvironment` 中的 `execute_sql()` 方法来完成，然后就可以在作业中使用这张表了。

```
source_ddl = """
        CREATE TABLE source_table(
            a VARCHAR,
            b INT
        ) WITH (
          'connector' =' = 'kafka',
          'topic' = 'source_topic',
          'properties.bootstrap.servers' = 'kafka:9092',
          'properties.group.id' = 'test_3',
          'scan.startup.mode' = 'latest-offset',
          'format' = 'json'
        )
        """

sink_ddl = """
        CREATE TABLE sink_table(
            a VARCHAR
        ) WITH (
          'connector' = 'kafka',
          'topic' = 'sink_topic',
          'properties.bootstrap.servers' = 'kafka:9092',
          'format' = 'json'
        )
        """

t_env.execute_sql(source_ddl)
t_env.execute_sql(sink_ddl)

t_env.sql_query("SELECT a FROM source_table") \
    .execute_insert("sink_table").wait()
```

下面是如何在 PyFlink 中使用 Kafka source/sink 和 JSON 格式的完整示例。

```
from pyflink.datastream import StreamExecutionEnvironment, TimeCharacteristic
from pyflink.table import StreamTableEnvironment, EnvironmentSettings


def log_processing():
    env = StreamExecutionEnvironment.get_execution_environment()
    env_settings = EnvironmentSettings.Builder().use_blink_planner().build()
    t_env = StreamTableEnvironment.create(stream_execution_environment=env, environment_settings=env_settings)
    # specify connector and format jars
    t_env.get_config().get_configuration().set_string("pipeline.jars", "file:///my/jar/path/connector.jar;file:///my/jar/path/json.jar")
    
    source_ddl = """
            CREATE TABLE source_table(
                a VARCHAR,
                b INT
            ) WITH (
              'connector' = 'kafka',
              'topic' = 'source_topic',
              'properties.bootstrap.servers' = 'kafka:9092',
              'properties.group.id' = 'test_3',
              'scan.startup.mode' = 'latest-offset',
              'format' = 'json'
            )
            """

    sink_ddl = """
            CREATE TABLE sink_table(
                a VARCHAR
            ) WITH (
              'connector' = 'kafka',
              'topic' = 'sink_topic',
              'properties.bootstrap.servers' = 'kafka:9092',
              'format' = 'json'
            )
            """

    t_env.execute_sql(source_ddl)
    t_env.execute_sql(sink_ddl)

    t_env.sql_query("SELECT a FROM source_table") \
        .execute_insert("sink_table").wait()


if __name__ == '__main__':
    log_processing()
```

## 内置的 Sources 和 Sinks

有些 source 和 sink 被内置在 Flink 中，可以直接使用。这些内置的 source 包括将 Pandas DataFrame 作为数据源，或者将一个元素集合作为数据源。内置的 sink 包括将数据转换为 Pandas DataFrame 等。

### 和 Pandas 之间互转

PyFlink 表支持与 Pandas DataFrame 之间互相转换。

```
import pandas as pd
import numpy as np

# 创建一个 PyFlink 表
pdf = pd.DataFrame(np.random.rand(1000, 2))
table = t_env.from_pandas(pdf, ["a", "b"]).filter("a > 0.5")

# 将 PyFlink 表转换成 Pandas DataFrame
pdf = table.to_pandas()
```

### from_elements()

`from_elements()` 用于从一个元素集合中创建一张表。元素类型必须是可支持的原子类型或者复杂类型。

```
table_env.from_elements([(1, 'Hi'), (2, 'Hello')])

# 使用第二个参数指定自定义字段名
table_env.from_elements([(1, 'Hi'), (2, 'Hello')], ['a', 'b'])

# 使用第二个参数指定自定义表结构
table_env.from_elements([(1, 'Hi'), (2, 'Hello')],
                        DataTypes.ROW([DataTypes.FIELD("a", DataTypes.INT()),
                                       DataTypes.FIELD("b", DataTypes.STRING())]))
```

以上查询返回的表如下:

```
+----+-------+
| a  |   b   |
+====+=======+
| 1  |  Hi   |
+----+-------+
| 2  | Hello |
+----+-------+
```

## 用户自定义的 source 和 sink

在某些情况下，你可能想要自定义 source 或 sink。目前，source 和 sink 必须使用 Java/Scala 实现，你可以定义一个 `TableFactory` ，然后通过 DDL 在 PyFlink 作业中来使用它们。更多详情，可查阅 [Java/Scala 文档](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sourceSinks.html)。