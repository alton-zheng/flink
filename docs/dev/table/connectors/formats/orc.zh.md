# Orc Format

**Format: Serialization Schema** **Format: Deserialization Schema**

- [依赖](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/orc.html#依赖)
- [如何用 Orc 格式创建一个表格](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/orc.html#如何用-orc-格式创建一个表格)
- [Format 参数](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/orc.html#format-参数)
- [数据类型映射](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/orc.html#数据类型映射)

[Apache Orc](https://orc.apache.org/) Format 允许读写 ORC 数据。

## 依赖

In order to use the ORC format the following dependencies are required for both projects using a build automation tool (such as Maven or SBT) and SQL Client with SQL JAR bundles.

| Maven dependency | SQL Client JAR                                               |
| :--------------- | :----------------------------------------------------------- |
| `flink-orc_2.11` | [Download](https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-orc_2.11/1.12.0/flink-sql-orc_2.11-1.12.0.jar) |

## 如何用 Orc 格式创建一个表格

下面是一个用 Filesystem connector 和 Orc format 创建表格的例子

- [**SQL**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/orc.html#tab_SQL_0)

```
CREATE TABLE user_behavior (
  user_id BIGINT,
  item_id BIGINT,
  category_id BIGINT,
  behavior STRING,
  ts TIMESTAMP(3),
  dt STRING
) PARTITIONED BY (dt) WITH (
 'connector' = 'filesystem',
 'path' = '/tmp/user_behavior',
 'format' = 'orc'
)
```

## Format 参数

| 参数   | 是否必选 | 默认值 |  类型  |                 描述                 |
| :----- | :------: | :----: | :----: | :----------------------------------: |
| format |   必选   | (none) | String | 指定要使用的格式，这里应该是 'orc'。 |

Orc 格式也支持来源于 [Table properties](https://orc.apache.org/docs/hive-config.html#table-properties) 的表属性。 举个例子，你可以设置 `orc.compress=SNAPPY` 来允许spappy压缩。

## 数据类型映射

Orc 格式类型的映射和 Apache Hive 是兼容的。下面的表格列出了 Flink 类型的数据和 Orc 类型的数据的映射关系。

| Flink 数据类型 | Orc 物理类型 | Orc 逻辑类型 |
| :------------- | :----------: | :----------: |
| CHAR           |    bytes     |     CHAR     |
| VARCHAR        |    bytes     |   VARCHAR    |
| STRING         |    bytes     |    STRING    |
| BOOLEAN        |     long     |   BOOLEAN    |
| BYTES          |    bytes     |    BINARY    |
| DECIMAL        |   decimal    |   DECIMAL    |
| TINYINT        |     long     |     BYTE     |
| SMALLINT       |     long     |    SHORT     |
| INT            |     long     |     INT      |
| BIGINT         |     long     |     LONG     |
| FLOAT          |    double    |    FLOAT     |
| DOUBLE         |    double    |    DOUBLE    |
| DATE           |     long     |     DATE     |
| TIMESTAMP      |  timestamp   |  TIMESTAMP   |

**注意** 复合数据类型: 数组、 映射和行类型暂不支持。