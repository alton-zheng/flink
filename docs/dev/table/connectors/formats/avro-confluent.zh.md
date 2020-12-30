# Confluent Avro Format

**Format: Serialization Schema** **Format: Deserialization Schema**

- [依赖](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/avro-confluent.html#依赖)
- [如何创建使用 Avro-Confluent 格式的表](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/avro-confluent.html#如何创建使用-avro-confluent-格式的表)
- [Format 参数](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/avro-confluent.html#format-参数)
- [数据类型映射](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/avro-confluent.html#数据类型映射)

Avro Schema Registry (`avro-confluent`) 格式能让你读取被 `io.confluent.kafka.serializers.KafkaAvroSerializer`序列化的记录，以及可以写入成能被 `io.confluent.kafka.serializers.KafkaAvroDeserializer`反序列化的记录。

当以这种格式读取（反序列化）记录时，将根据记录中编码的 schema 版本 id 从配置的 Confluent Schema Registry 中获取 Avro writer schema ，而从 table schema 中推断出 reader schema。

当以这种格式写入（序列化）记录时，Avro schema 是从 table schema 中推断出来的，并会用来检索要与数据一起编码的 schema id。我们会在配置的 Confluent Schema Registry 中配置的 [subject](https://docs.confluent.io/current/schema-registry/index.html#schemas-subjects-and-topics) 下，检索 schema id。subject 通过 `avro-confluent.schema-registry.subject` 参数来制定。

Avro Schema Registry 格式只能与[Apache Kafka SQL连接器](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/kafka.html)结合使用。

## 依赖

In order to use the Avro Schema Registry format the following dependencies are required for both projects using a build automation tool (such as Maven or SBT) and SQL Client with SQL JAR bundles.

| Maven dependency                | SQL Client JAR                                               |
| :------------------------------ | :----------------------------------------------------------- |
| `flink-avro-confluent-registry` | [Download](https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-avro-confluent-registry/1.12.0/flink-sql-avro-confluent-registry-1.12.0.jar) |

## 如何创建使用 Avro-Confluent 格式的表

以下是一个使用 Kafka 连接器和 Confluent Avro 格式创建表的示例。

- [**SQL**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/avro-confluent.html#tab_SQL_0)

```
CREATE TABLE user_behavior (
  user_id BIGINT,
  item_id BIGINT,
  category_id BIGINT,
  behavior STRING,
  ts TIMESTAMP(3)
) WITH (
  'connector' = 'kafka',
  'properties.bootstrap.servers' = 'localhost:9092',
  'topic' = 'user_behavior'
  'format' = 'avro-confluent',
  'avro-confluent.schema-registry.url' = 'http://localhost:8081',
  'avro-confluent.schema-registry.subject' = 'user_behavior'
)
```

## Format 参数

| 参数                                   | 是否必选  | 默认值 |  类型  |                             描述                             |
| :------------------------------------- | :-------: | :----: | :----: | :----------------------------------------------------------: |
| format                                 |   必选    | (none) | String |       指定要使用的格式，这里应该是 `'avro-confluent'`.       |
| avro-confluent.schema-registry.url     |   必选    | (none) | String |   用于获取/注册 schemas 的 Confluent Schema Registry 的URL   |
| avro-confluent.schema-registry.subject | sink 必选 | (none) | String | Confluent Schema Registry主题，用于在序列化期间注册此格式使用的 schema |

## 数据类型映射

目前 Apache Flink 都是从 table schema 去推断反序列化期间的 Avro reader schema 和序列化期间的 Avro writer schema。显式地定义 Avro schema 暂不支持。 [Apache Avro Format](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/avro.html#data-type-mapping)中描述了 Flink 数据类型和 Avro 类型的对应关系。

除了此处列出的类型之外，Flink 还支持读取/写入可为空（nullable）的类型。 Flink 将可为空的类型映射到 Avro `union(something, null)`, 其中 `something` 是从 Flink 类型转换的 Avro 类型。

您可以参考 [Avro Specification](https://avro.apache.org/docs/current/spec.html) 以获取有关 Avro 类型的更多信息。