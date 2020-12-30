# Debezium Format

**Changelog-Data-Capture Format** **Format: Serialization Schema** **Format: Deserialization Schema**

- [依赖](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/debezium.html#依赖)
- [如何使用 Debezium Format](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/debezium.html#如何使用-debezium-format)
- [Available Metadata](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/debezium.html#available-metadata)
- [Format 参数](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/debezium.html#format-参数)
- 注意事项
  - [重复的变更事件](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/debezium.html#section-1)
  - [消费 Debezium Postgres Connector 产生的数据](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/debezium.html#debezium-postgres-connector-)
- [数据类型映射](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/debezium.html#section-2)

[Debezium](https://debezium.io/) 是一个 CDC（Changelog Data Capture，变更数据捕获）的工具，可以把来自 MySQL、PostgreSQL、Oracle、Microsoft SQL Server 和许多其他数据库的更改实时流式传输到 Kafka 中。 Debezium 为变更日志提供了统一的格式结构，并支持使用 JSON 和 Apache Avro 序列化消息。

Flink 支持将 Debezium JSON 和 Avro 消息解析为 INSERT / UPDATE / DELETE 消息到 Flink SQL 系统中。在很多情况下，利用这个特性非常的有用，例如

- 将增量数据从数据库同步到其他系统
- 日志审计
- 数据库的实时物化视图
- 关联维度数据库的变更历史，等等。

Flink 还支持将 Flink SQL 中的 INSERT / UPDATE / DELETE 消息编码为 Debezium 格式的 JSON 或 Avro 消息，输出到 Kafka 等存储中。 但需要注意的是，目前 Flink 还不支持将 UPDATE_BEFORE 和 UPDATE_AFTER 合并为一条 UPDATE 消息。因此，Flink 将 UPDATE_BEFORE 和 UPDATE_AFTER 分别编码为 DELETE 和 INSERT 类型的 Debezium 消息。

## 依赖

- [**Debezium Avro**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/debezium.html#tab_Debezium_Avro_0)
- [**Debezium Json**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/debezium.html#tab_Debezium_Json_0)

In order to use the Debezium format the following dependencies are required for both projects using a build automation tool (such as Maven or SBT) and SQL Client with SQL JAR bundles.

| Maven dependency                | SQL Client JAR                                               |
| :------------------------------ | :----------------------------------------------------------- |
| `flink-avro-confluent-registry` | [Download](https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-avro-confluent-registry/1.12.0/flink-sql-avro-confluent-registry-1.12.0.jar) |

*注意: 请参考 [Debezium 文档](https://debezium.io/documentation/reference/1.3/index.html)，了解如何设置 Debezium Kafka Connect 用来将变更日志同步到 Kafka 主题。*

## 如何使用 Debezium Format

Debezium 为变更日志提供了统一的格式，这是一个 JSON 格式的从 MySQL product 表捕获的更新操作的简单示例:

```
{
  "before": {
    "id": 111,
    "name": "scooter",
    "description": "Big 2-wheel scooter",
    "weight": 5.18
  },
  "after": {
    "id": 111,
    "name": "scooter",
    "description": "Big 2-wheel scooter",
    "weight": 5.15
  },
  "source": {...},
  "op": "u",
  "ts_ms": 1589362330904,
  "transaction": null
}
```

*注意: 请参考 [Debezium 文档](https://debezium.io/documentation/reference/1.3/connectors/mysql.html#mysql-connector-events_debezium)，了解每个字段的含义。*

MySQL 产品表有4列（`id`、`name`、`description`、`weight`）。上面的 JSON 消息是 `products` 表上的一条更新事件，其中 `id = 111` 的行的 `weight` 值从 `5.18` 更改为 `5.15`。假设此消息已同步到 Kafka 主题 `products_binlog`，则可以使用以下 DDL 来使用此主题并解析更改事件。

- [**SQL**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/debezium.html#tab_SQL_1)

```
CREATE TABLE topic_products (
  -- schema 与 MySQL 的 products 表完全相同
  id BIGINT,
  name STRING,
  description STRING,
  weight DECIMAL(10, 2)
) WITH (
 'connector' = 'kafka',
 'topic' = 'products_binlog',
 'properties.bootstrap.servers' = 'localhost:9092',
 'properties.group.id' = 'testGroup',
  -- 使用 'debezium-json' format 来解析 Debezium 的 JSON 消息
  -- 如果 Debezium 用 Avro 编码消息，请使用 'debezium-avro-confluent'
 'format' = 'debezium-json'  -- 如果 Debezium 用 Avro 编码消息，请使用 'debezium-avro-confluent'
)
```

在某些情况下，用户在设置 Debezium Kafka Connect 时，可能会开启 Kafka 的配置 `'value.converter.schemas.enable'`，用来在消息体中包含 schema 信息。然后，Debezium JSON 消息可能如下所示:

```
{
  "schema": {...},
  "payload": {
    "before": {
      "id": 111,
      "name": "scooter",
      "description": "Big 2-wheel scooter",
      "weight": 5.18
    },
    "after": {
      "id": 111,
      "name": "scooter",
      "description": "Big 2-wheel scooter",
      "weight": 5.15
    },
    "source": {...},
    "op": "u",
    "ts_ms": 1589362330904,
    "transaction": null
  }
}
```

为了解析这一类信息，你需要在上述 DDL WITH 子句中添加选项 `'debezium-json.schema-include' = 'true'`（默认为 false）。通常情况下，建议不要包含 schema 的描述，因为这样会使消息变得非常冗长，并降低解析性能。

在将主题注册为 Flink 表之后，可以将 Debezium 消息用作变更日志源。

- [**SQL**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/debezium.html#tab_SQL_2)

```
-- MySQL "products" 的实时物化视图
-- 计算相同产品的最新平均重量
SELECT name, AVG(weight) FROM topic_products GROUP BY name;

-- 将 MySQL "products" 表的所有数据和增量更改同步到
-- Elasticsearch "products" 索引，供将来查找
INSERT INTO elasticsearch_products
SELECT * FROM topic_products;
```

## Available Metadata

The following format metadata can be exposed as read-only (`VIRTUAL`) columns in a table definition.

**Attention** Format metadata fields are only available if the corresponding connector forwards format metadata. Currently, only the Kafka connector is able to expose metadata fields for its value format.

| Key                   |                Data Type                 |                         Description                          |
| :-------------------- | :--------------------------------------: | :----------------------------------------------------------: |
| `schema`              |              `STRING NULL`               | JSON string describing the schema of the payload. Null if the schema is not included in the Debezium record. |
| `ingestion-timestamp` | `TIMESTAMP(3) WITH LOCAL TIME ZONE NULL` | The timestamp at which the connector processed the event. Corresponds to the `ts_ms` field in the Debezium record. |
| `source.timestamp`    | `TIMESTAMP(3) WITH LOCAL TIME ZONE NULL` | The timestamp at which the source system created the event. Corresponds to the `source.ts_ms` field in the Debezium record. |
| `source.database`     |              `STRING NULL`               | The originating database. Corresponds to the `source.db` field in the Debezium record if available. |
| `source.schema`       |              `STRING NULL`               | The originating database schema. Corresponds to the `source.schema` field in the Debezium record if available. |
| `source.table`        |              `STRING NULL`               | The originating database table. Corresponds to the `source.table` or `source.collection` field in the Debezium record if available. |
| `source.properties`   |        `MAP<STRING, STRING> NULL`        | Map of various source properties. Corresponds to the `source` field in the Debezium record. |

The following example shows how to access Debezium metadata fields in Kafka:

- [**SQL**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/debezium.html#tab_SQL_3)

```
CREATE TABLE KafkaTable (
  `event_time` TIMESTAMP(3) METADATA FROM 'value.source.timestamp' VIRTUAL,
  `origin_table` STRING METADATA FROM 'value.source.table' VIRTUAL,
  `user_id` BIGINT,
  `item_id` BIGINT,
  `behavior` STRING
) WITH (
  'connector' = 'kafka',
  'topic' = 'user_behavior',
  'properties.bootstrap.servers' = 'localhost:9092',
  'properties.group.id' = 'testGroup',
  'scan.startup.mode' = 'earliest-offset',
  'value.format' = 'debezium-json'
);
```

## Format 参数

Flink 提供了 `debezium-avro-confluent` 和 `debezium-json` 两种 format 来解析 Debezium 生成的 JSON 格式和 Avro 格式的消息。 请使用 `debezium-avro-confluent` 来解析 Debezium 的 Avro 消息，使用 `debezium-json` 来解析 Debezium 的 JSON 消息。

- [**Debezium Avro**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/debezium.html#tab_Debezium_Avro_4)
- [**Debezium Json**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/debezium.html#tab_Debezium_Json_4)

| 参数                                            | 是否必选  | 默认值 |  类型  |                             描述                             |
| :---------------------------------------------- | :-------: | :----: | :----: | :----------------------------------------------------------: |
| format                                          |   必选    | (none) | String |   指定要使用的格式，此处应为 `'debezium-avro-confluent'`。   |
| debezium-avro-confluent.schema-registry.url     |   必选    | (none) | String | 用于获取/注册 schemas 的 Confluent Schema Registry 的 URL。  |
| debezium-avro-confluent.schema-registry.subject | sink 必选 | (none) | String | Confluent Schema Registry主题，用于在序列化期间注册此格式使用的 schema。 |

## 注意事项

### 重复的变更事件

在正常的操作环境下，Debezium 应用能以 **exactly-once** 的语义投递每条变更事件。在这种情况下，Flink 消费 Debezium 产生的变更事件能够工作得很好。 然而，当有故障发生时，Debezium 应用只能保证 **at-least-once** 的投递语义。可以查看 [Debezium 官方文档](https://debezium.io/documentation/faq/#what_happens_when_an_application_stops_or_crashes) 了解更多关于 Debezium 的消息投递语义。 这也意味着，在非正常情况下，Debezium 可能会投递重复的变更事件到 Kafka 中，当 Flink 从 Kafka 中消费的时候就会得到重复的事件。 这可能会导致 Flink query 的运行得到错误的结果或者非预期的异常。因此，建议在这种情况下，将作业参数 [`table.exec.source.cdc-events-duplicate`](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/config.html#table-exec-source-cdc-events-duplicate) 设置成 `true`，并在该 source 上定义 PRIMARY KEY。 框架会生成一个额外的有状态算子，使用该 primary key 来对变更事件去重并生成一个规范化的 changelog 流。

### 消费 Debezium Postgres Connector 产生的数据

如果你正在使用 [Debezium PostgreSQL Connector](https://debezium.io/documentation/reference/1.2/connectors/postgresql.html) 捕获变更到 Kafka，请确保被监控表的 [REPLICA IDENTITY](https://www.postgresql.org/docs/current/sql-altertable.html#SQL-CREATETABLE-REPLICA-IDENTITY) 已经被配置成 `FULL` 了，默认值是 `DEFAULT`。 否则，Flink SQL 将无法正确解析 Debezium 数据。

当配置为 `FULL` 时，更新和删除事件将完整包含所有列的之前的值。当为其他配置时，更新和删除事件的 “before” 字段将只包含 primary key 字段的值，或者为 null（没有 primary key）。 你可以通过运行 `ALTER TABLE <your-table-name> REPLICA IDENTITY FULL` 来更改 `REPLICA IDENTITY` 的配置。 请阅读 [Debezium 关于 PostgreSQL REPLICA IDENTITY 的文档](https://debezium.io/documentation/reference/1.2/connectors/postgresql.html#postgresql-replica-identity) 了解更多。

## 数据类型映射

目前，Debezium Format 使用 JSON Format 进行序列化和反序列化。有关数据类型映射的更多详细信息，请参考 [JSON Format 文档](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/json.html#data-type-mapping) 和 [Confluent Avro Format 文档](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/avro-confluent.html#data-type-mapping)。