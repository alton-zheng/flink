# Canal Format

**Changelog-Data-Capture Format** **Format: Serialization Schema** **Format: Deserialization Schema**

- [依赖](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/canal.html#依赖)
- [如何使用 Canal Format](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/canal.html#如何使用-canal-format)
- [Format 参数](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/canal.html#format-参数)
- 注意事项
  - [重复的变更事件](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/canal.html#重复的变更事件)
- [数据类型映射](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/canal.html#数据类型映射)

[Canal](https://github.com/alibaba/canal/wiki) 是一个 CDC（ChangeLog Data Capture，变更日志数据捕获）工具，可以实时地将 MySQL 变更传输到其他系统。Canal 为变更日志提供了统一的数据格式，并支持使用 JSON 或 [protobuf](https://developers.google.com/protocol-buffers) 序列化消息（Canal 默认使用 protobuf）。

Flink 支持将 Canal 的 JSON 消息解析为 INSERT / UPDATE / DELETE 消息到 Flink SQL 系统中。在很多情况下，利用这个特性非常的有用，例如

- 将增量数据从数据库同步到其他系统
- 日志审计
- 数据库的实时物化视图
- 关联维度数据库的变更历史，等等。

Flink 还支持将 Flink SQL 中的 INSERT / UPDATE / DELETE 消息编码为 Canal 格式的 JSON 消息，输出到 Kafka 等存储中。 但需要注意的是，目前 Flink 还不支持将 UPDATE_BEFORE 和 UPDATE_AFTER 合并为一条 UPDATE 消息。因此，Flink 将 UPDATE_BEFORE 和 UPDATE_AFTER 分别编码为 DELETE 和 INSERT 类型的 Canal 消息。

*注意：未来会支持 Canal protobuf 类型消息的解析以及输出 Canal 格式的消息。*

## 依赖

In order to use the Canal format the following dependencies are required for both projects using a build automation tool (such as Maven or SBT) and SQL Client with SQL JAR bundles.

| Maven dependency | SQL Client JAR |
| :--------------- | :------------- |
| `flink-json`     | Built-in       |

*注意：有关如何部署 Canal 以将变更日志同步到消息队列，请参阅 [Canal 文档](https://github.com/alibaba/canal/wiki)。*

## 如何使用 Canal Format

Canal 为变更日志提供了统一的格式，下面是一个从 MySQL 库 `products` 表中捕获更新操作的简单示例：

```
{
  "data": [
    {
      "id": "111",
      "name": "scooter",
      "description": "Big 2-wheel scooter",
      "weight": "5.18"
    }
  ],
  "database": "inventory",
  "es": 1589373560000,
  "id": 9,
  "isDdl": false,
  "mysqlType": {
    "id": "INTEGER",
    "name": "VARCHAR(255)",
    "description": "VARCHAR(512)",
    "weight": "FLOAT"
  },
  "old": [
    {
      "weight": "5.15"
    }
  ],
  "pkNames": [
    "id"
  ],
  "sql": "",
  "sqlType": {
    "id": 4,
    "name": 12,
    "description": 12,
    "weight": 7
  },
  "table": "products",
  "ts": 1589373560798,
  "type": "UPDATE"
}
```

*注意：有关各个字段的含义，请参阅 [Canal 文档](https://github.com/alibaba/canal/wiki)*

MySQL `products` 表有4列（`id`，`name`，`description` 和 `weight`）。上面的 JSON 消息是 `products` 表上的一个更新事件，表示 `id = 111` 的行数据上 `weight` 字段值从`5.15`变更成为 `5.18`。假设消息已经同步到了一个 Kafka 主题：`products_binlog`，那么就可以使用以下DDL来从这个主题消费消息并解析变更事件。

- [**SQL**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/canal.html#tab_SQL_0)

```
CREATE TABLE topic_products (
  -- 元数据与 MySQL "products" 表完全相同
  id BIGINT,
  name STRING,
  description STRING,
  weight DECIMAL(10, 2)
) WITH (
 'connector' = 'kafka',
 'topic' = 'products_binlog',
 'properties.bootstrap.servers' = 'localhost:9092',
 'properties.group.id' = 'testGroup',
 'format' = 'canal-json'  -- 使用 canal-json 格式
)
```

将 Kafka 主题注册成 Flink 表之后，就可以将 Canal 消息用作变更日志源。

- [**SQL**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/canal.html#tab_SQL_1)

```
-- 关于MySQL "products" 表的实时物化视图
-- 计算相同产品的最新平均重量
SELECT name, AVG(weight) FROM topic_products GROUP BY name;

-- 将 MySQL "products" 表的所有数据和增量更改同步到
-- Elasticsearch "products" 索引以供将来搜索
INSERT INTO elasticsearch_products
SELECT * FROM topic_products;
```

## Format 参数

| 选项                                 |   要求   |   默认   |  类型   |                             描述                             |
| :----------------------------------- | :------: | :------: | :-----: | :----------------------------------------------------------: |
| format                               |   必填   |  (none)  | String  |          指定要使用的格式，此处应为 `'canal-json'`.          |
| canal-json.ignore-parse-errors       |   选填   |  false   | Boolean | 当解析异常时，是跳过当前字段或行，还是抛出错误失败（默认为 false，即抛出错误失败）。如果忽略字段的解析异常，则会将该字段值设置为`null`。 |
| canal-json.timestamp-format.standard |   选填   | `'SQL'`  | String  | 指定输入和输出时间戳格式。当前支持的值是 `'SQL'` 和 `'ISO-8601'`:选项 `'SQL'` 将解析 "yyyy-MM-dd HH:mm:ss.s{precision}" 格式的输入时间戳，例如 '2020-12-30 12:13:14.123'，并以相同格式输出时间戳。选项 `'ISO-8601'` 将解析 "yyyy-MM-ddTHH:mm:ss.s{precision}" 格式的输入时间戳，例如 '2020-12-30T12:13:14.123'，并以相同的格式输出时间戳。 |
| canal-json.map-null-key.mode         |   选填   | `'FAIL'` | String  | 指定处理 Map 中 key 值为空的方法. 当前支持的值有 `'FAIL'`, `'DROP'` 和 `'LITERAL'`:Option `'FAIL'` 将抛出异常，如果遇到 Map 中 key 值为空的数据。Option `'DROP'` 将丢弃 Map 中 key 值为空的数据项。Option `'LITERAL'` 将使用字符串常量来替换 Map 中的空 key 值。字符串常量的值由 `'canal-json.map-null-key.literal'` 定义。 |
| canal-json.map-null-key.literal      |   选填   |  'null'  | String  | 当 `'canal-json.map-null-key.mode'` 是 LITERAL 的时候，指定字符串常量替换 Map 中的空 key 值。 |
| canal-json.database.include          | optional |  (none)  | String  | 仅读取指定数据库的 changelog 记录（通过对比 Canal 记录中的 "database" 元数据字段） |
| canal-json.table.include             | optional |  (none)  | String  | 仅读取指定表的 changelog 记录（通过对比 Canal 记录中的 "table" 元数据字段）。 |

## 注意事项

### 重复的变更事件

在正常的操作环境下，Canal 应用能以 **exactly-once** 的语义投递每条变更事件。在这种情况下，Flink 消费 Canal 产生的变更事件能够工作得很好。 然而，当有故障发生时，Canal 应用只能保证 **at-least-once** 的投递语义。 这也意味着，在非正常情况下，Canal 可能会投递重复的变更事件到消息队列中，当 Flink 从消息队列中消费的时候就会得到重复的事件。 这可能会导致 Flink query 的运行得到错误的结果或者非预期的异常。因此，建议在这种情况下，建议在这种情况下，将作业参数 [`table.exec.source.cdc-events-duplicate`](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/config.html#table-exec-source-cdc-events-duplicate) 设置成 `true`，并在该 source 上定义 PRIMARY KEY。 框架会生成一个额外的有状态算子，使用该 primary key 来对变更事件去重并生成一个规范化的 changelog 流。

## 数据类型映射

目前，Canal Format 使用 JSON Format 进行序列化和反序列化。 有关数据类型映射的更多详细信息，请参阅 [JSON Format 文档](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/json.html#data-type-mapping)。