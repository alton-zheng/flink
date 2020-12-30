# CSV Format

**Format: Serialization Schema** **Format: Deserialization Schema**

- [依赖](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/csv.html#依赖)
- [如何创建使用 CSV 格式的表](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/csv.html#如何创建使用-csv-格式的表)
- [Format 参数](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/csv.html#format-参数)
- [数据类型映射](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/csv.html#数据类型映射)

[CSV](https://zh.wikipedia.org/wiki/逗号分隔值) Format 允许我们基于 CSV schema 进行解析和生成 CSV 数据。 目前 CSV schema 是基于 table schema 推断而来的。

## 依赖

In order to use the CSV format the following dependencies are required for both projects using a build automation tool (such as Maven or SBT) and SQL Client with SQL JAR bundles.

| Maven dependency | SQL Client JAR |
| :--------------- | :------------- |
| `flink-csv`      | Built-in       |

## 如何创建使用 CSV 格式的表

以下是一个使用 Kafka 连接器和 CSV 格式创建表的示例。

- [**SQL**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/csv.html#tab_SQL_0)

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
 'format' = 'csv',
 'csv.ignore-parse-errors' = 'true',
 'csv.allow-comments' = 'true'
)
```

## Format 参数

| 参数                        | 是否必选 | 默认值 |  类型   |                             描述                             |
| :-------------------------- | :------: | :----: | :-----: | :----------------------------------------------------------: |
| format                      |   必选   | (none) | String  |            指定要使用的格式，这里应该是 `'csv'`。            |
| csv.field-delimiter         |   可选   |  `,`   | String  | 字段分隔符 (默认`','`)，必须为单字符。你可以使用反斜杠字符指定一些特殊字符，例如 `'\t'` 代表制表符。 你也可以通过 unicode 编码在纯 SQL 文本中指定一些特殊字符，例如 `'csv.field-delimiter' = U&'\0001'` 代表 `0x01` 字符。 |
| csv.disable-quote-character |   可选   | false  | Boolean | 是否禁止对引用的值使用引号 (默认是 false). 如果禁止，选项 `'csv.quote-character'` 不能设置。 |
| csv.quote-character         |   可选   |  `"`   | String  |             用于围住字段值的引号字符 (默认`"`).              |
| csv.allow-comments          |   可选   | false  | Boolean | 是否允许忽略注释行（默认不允许），注释行以 `'#'` 作为起始字符。 如果允许注释行，请确保 `csv.ignore-parse-errors` 也开启了从而允许空行。 |
| csv.ignore-parse-errors     |   可选   | false  | Boolean | 当解析异常时，是跳过当前字段或行，还是抛出错误失败（默认为 false，即抛出错误失败）。如果忽略字段的解析异常，则会将该字段值设置为`null`。 |
| csv.array-element-delimiter |   可选   |  `;`   | String  |             分隔数组和行元素的字符串(默认`';'`).             |
| csv.escape-character        |   可选   | (none) | String  |                     转义字符(默认关闭).                      |
| csv.null-literal            |   可选   | (none) | String  |             是否将 "null" 字符串转化为 null 值。             |

## 数据类型映射

目前 CSV 的 schema 都是从 table schema 推断而来的。显式地定义 CSV schema 暂不支持。 Flink 的 CSV Format 数据使用 [jackson databind API](https://github.com/FasterXML/jackson-databind) 去解析 CSV 字符串。

下面的表格列出了flink数据和CSV数据的对应关系。

| Flink SQL 类型            | CSV 类型                        |
| :------------------------ | :------------------------------ |
| `CHAR / VARCHAR / STRING` | `string`                        |
| `BOOLEAN`                 | `boolean`                       |
| `BINARY / VARBINARY`      | `string with encoding: base64`  |
| `DECIMAL`                 | `number`                        |
| `TINYINT`                 | `number`                        |
| `SMALLINT`                | `number`                        |
| `INT`                     | `number`                        |
| `BIGINT`                  | `number`                        |
| `FLOAT`                   | `number`                        |
| `DOUBLE`                  | `number`                        |
| `DATE`                    | `string with format: date`      |
| `TIME`                    | `string with format: time`      |
| `TIMESTAMP`               | `string with format: date-time` |
| `INTERVAL`                | `number`                        |
| `ARRAY`                   | `array`                         |
| `ROW`                     | `object`                        |