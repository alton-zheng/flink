# JSON Format

**Format: Serialization Schema** **Format: Deserialization Schema**

- [依赖](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/json.html#依赖)
- [如何创建一张基于 JSON Format 的表](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/json.html#如何创建一张基于-json-format-的表)
- [Format 参数](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/json.html#format-参数)
- [数据类型映射关系](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/json.html#数据类型映射关系)

[JSON](https://www.json.org/json-en.html) Format 能读写 JSON 格式的数据。当前，JSON schema 是从 table schema 中自动推导而得的。

## 依赖

In order to use the Json format the following dependencies are required for both projects using a build automation tool (such as Maven or SBT) and SQL Client with SQL JAR bundles.

| Maven dependency | SQL Client JAR |
| :--------------- | :------------- |
| `flink-json`     | Built-in       |

## 如何创建一张基于 JSON Format 的表

以下是一个利用 Kafka 以及 JSON Format 构建表的例子。

- [**SQL**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/json.html#tab_SQL_0)

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
 'format' = 'json',
 'json.fail-on-missing-field' = 'false',
 'json.ignore-parse-errors' = 'true'
)
```

## Format 参数

| 参数                           | 是否必须 |  默认值  |  类型   |                             描述                             |
| :----------------------------- | :------: | :------: | :-----: | :----------------------------------------------------------: |
| format                         |   必选   |  (none)  | String  |              声明使用的格式，这里应为`'json'`。              |
| json.fail-on-missing-field     |   可选   |  false   | Boolean | 当解析字段缺失时，是跳过当前字段或行，还是抛出错误失败（默认为 false，即抛出错误失败）。 |
| json.ignore-parse-errors       |   可选   |  false   | Boolean | 当解析异常时，是跳过当前字段或行，还是抛出错误失败（默认为 false，即抛出错误失败）。如果忽略字段的解析异常，则会将该字段值设置为`null`。 |
| json.timestamp-format.standard |   可选   | `'SQL'`  | String  | 声明输入和输出的 `TIMESTAMP` 和 `TIMESTAMP WITH LOCAL TIME ZONE` 的格式。当前支持的格式为`'SQL'` 以及 `'ISO-8601'`：可选参数 `'SQL'` 将会以 "yyyy-MM-dd HH:mm:ss.s{precision}" 的格式解析 TIMESTAMP, 例如 "2020-12-30 12:13:14.123"， 以 "yyyy-MM-dd HH:mm:ss.s{precision}'Z'" 的格式解析 TIMESTAMP WITH LOCAL TIME ZONE, 例如 "2020-12-30 12:13:14.123Z" 且会以相同的格式输出。可选参数 `'ISO-8601'` 将会以 "yyyy-MM-ddTHH:mm:ss.s{precision}" 的格式解析输入 TIMESTAMP, 例如 "2020-12-30T12:13:14.123" ， 以 "yyyy-MM-ddTHH:mm:ss.s{precision}'Z'" 的格式解析 TIMESTAMP WITH LOCAL TIME ZONE, 例如 "2020-12-30T12:13:14.123Z" 且会以相同的格式输出。 |
| json.map-null-key.mode         |   选填   | `'FAIL'` | String  | 指定处理 Map 中 key 值为空的方法. 当前支持的值有 `'FAIL'`, `'DROP'` 和 `'LITERAL'`:Option `'FAIL'` 将抛出异常，如果遇到 Map 中 key 值为空的数据。Option `'DROP'` 将丢弃 Map 中 key 值为空的数据项。Option `'LITERAL'` 将使用字符串常量来替换 Map 中的空 key 值。字符串常量的值由 `'json.map-null-key.literal'` 定义。 |
| json.map-null-key.literal      |   选填   |  'null'  | String  | 当 `'json.map-null-key.mode'` 是 LITERAL 的时候，指定字符串常量替换 Map 中的空 key 值。 |

## 数据类型映射关系

当前，JSON schema 将会自动从 table schema 之中自动推导得到。不支持显式地定义 JSON schema。

在 Flink 中，JSON Format 使用 [jackson databind API](https://github.com/FasterXML/jackson-databind) 去解析和生成 JSON。

下表列出了 Flink 中的数据类型与 JSON 中的数据类型的映射关系。

| Flink SQL 类型                   | JSON 类型                                            |
| :------------------------------- | :--------------------------------------------------- |
| `CHAR / VARCHAR / STRING`        | `string`                                             |
| `BOOLEAN`                        | `boolean`                                            |
| `BINARY / VARBINARY`             | `string with encoding: base64`                       |
| `DECIMAL`                        | `number`                                             |
| `TINYINT`                        | `number`                                             |
| `SMALLINT`                       | `number`                                             |
| `INT`                            | `number`                                             |
| `BIGINT`                         | `number`                                             |
| `FLOAT`                          | `number`                                             |
| `DOUBLE`                         | `number`                                             |
| `DATE`                           | `string with format: date`                           |
| `TIME`                           | `string with format: time`                           |
| `TIMESTAMP`                      | `string with format: date-time`                      |
| `TIMESTAMP_WITH_LOCAL_TIME_ZONE` | `string with format: date-time (with UTC time zone)` |
| `INTERVAL`                       | `number`                                             |
| `ARRAY`                          | `array`                                              |
| `MAP / MULTISET`                 | `object`                                             |
| `ROW`                            | `object`                                             |