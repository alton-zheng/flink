# Avro Format

**Format: Serialization Schema** **Format: Deserialization Schema**

- [依赖](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/avro.html#依赖)
- [如何使用 Avro format 创建表](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/avro.html#如何使用-avro-format-创建表)
- [Format 参数](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/avro.html#format-参数)
- [数据类型映射](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/avro.html#数据类型映射)

[Apache Avro](https://avro.apache.org/) format 允许基于 Avro schema 读取和写入 Avro 数据。目前，Avro schema 从 table schema 推导而来。

## 依赖

In order to use the Avro format the following dependencies are required for both projects using a build automation tool (such as Maven or SBT) and SQL Client with SQL JAR bundles.

| Maven dependency | SQL Client JAR                                               |
| :--------------- | :----------------------------------------------------------- |
| `flink-sql-avro` | [Download](https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-avro/1.12.0/flink-sql-avro-1.12.0.jar) |

## 如何使用 Avro format 创建表

这是使用 Kafka 连接器和 Avro format 创建表的示例。

- [**SQL**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/avro.html#tab_SQL_0)

```
CREATE TABLE user_behavior (
  user_id BIGINT,
  item_id BIGINT,
  category_id BIGINT,
  behavior STRING,
  ts TIMESTAMP(3)
) WITH (
 'connector' = 'kafka',
 'topic' = 'user_behavior',
 'properties.bootstrap.servers' = 'localhost:9092',
 'properties.group.id' = 'testGroup',
 'format' = 'avro'
)
```

## Format 参数

| 参数       | 是否必选 | 默认值 |  类型  |                             描述                             |
| :--------- | :------: | :----: | :----: | :----------------------------------------------------------: |
| format     |   必要   | (none) | String |          指定使用什么 format，这里应该是 `'avro'`。          |
| avro.codec |   可选   | (none) | String | 仅用于 [filesystem](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/filesystem.html)，avro 压缩编解码器。默认不压缩。目前支持：deflate、snappy、bzip2、xz。 |

## 数据类型映射

目前，Avro schema 通常是从 table schema 中推导而来。尚不支持显式定义 Avro schema。因此，下表列出了从 Flink 类型到 Avro 类型的类型映射。

| Flink SQL 类型                                   | Avro 类型 | Avro 逻辑类型      |
| :----------------------------------------------- | :-------- | :----------------- |
| CHAR / VARCHAR / STRING                          | string    |                    |
| `BOOLEAN`                                        | `boolean` |                    |
| `BINARY / VARBINARY`                             | `bytes`   |                    |
| `DECIMAL`                                        | `fixed`   | `decimal`          |
| `TINYINT`                                        | `int`     |                    |
| `SMALLINT`                                       | `int`     |                    |
| `INT`                                            | `int`     |                    |
| `BIGINT`                                         | `long`    |                    |
| `FLOAT`                                          | `float`   |                    |
| `DOUBLE`                                         | `double`  |                    |
| `DATE`                                           | `int`     | `date`             |
| `TIME`                                           | `int`     | `time-millis`      |
| `TIMESTAMP`                                      | `long`    | `timestamp-millis` |
| `ARRAY`                                          | `array`   |                    |
| `MAP` (key 必须是 string/char/varchar 类型)      | `map`     |                    |
| `MULTISET` (元素必须是 string/char/varchar 类型) | `map`     |                    |
| `ROW`                                            | `record`  |                    |

除了上面列出的类型，Flink 支持读取/写入 nullable 的类型。Flink 将 nullable 的类型映射到 Avro `union(something, null)`，其中 `something` 是从 Flink 类型转换的 Avro 类型。

您可以参考 [Avro 规范](https://avro.apache.org/docs/current/spec.html) 获取更多有关 Avro 类型的信息。