# Parquet 格式

**Format: Serialization Schema** **Format: Deserialization Schema**

- [依赖](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/parquet.html#依赖)
- [如何创建基于 Parquet 格式的表](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/parquet.html#如何创建基于-parquet-格式的表)
- [Format 参数](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/parquet.html#format-参数)
- [数据类型映射](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/parquet.html#数据类型映射)

[Apache Parquet](https://parquet.apache.org/) 格式允许读写 Parquet 数据.

## 依赖

In order to use the Parquet format the following dependencies are required for both projects using a build automation tool (such as Maven or SBT) and SQL Client with SQL JAR bundles.

| Maven dependency     | SQL Client JAR                                               |
| :------------------- | :----------------------------------------------------------- |
| `flink-parquet_2.11` | [Download](https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-parquet_2.11/1.12.0/flink-sql-parquet_2.11-1.12.0.jar) |

## 如何创建基于 Parquet 格式的表

以下为用 Filesystem 连接器和 Parquet 格式创建表的示例，

- [**SQL**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/formats/parquet.html#tab_SQL_0)

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
 'format' = 'parquet'
)
```

## Format 参数

| 参数                 | 是否必须 | 默认值 |  类型   |                             描述                             |
| :------------------- | :------: | :----: | :-----: | :----------------------------------------------------------: |
| format               |   必选   | (none) | String  |             指定使用的格式，此处应为"parquet"。              |
| parquet.utc-timezone |   可选   | false  | Boolean | 使用 UTC 时区或本地时区在纪元时间和 LocalDateTime 之间进行转换。Hive 0.x/1.x/2.x 使用本地时区，但 Hive 3.x 使用 UTC 时区。 |

Parquet 格式也支持 [ParquetOutputFormat](https://www.javadoc.io/doc/org.apache.parquet/parquet-hadoop/1.10.0/org/apache/parquet/hadoop/ParquetOutputFormat.html) 的配置。 例如, 可以配置 `parquet.compression=GZIP` 来开启 gzip 压缩。

## 数据类型映射

目前，Parquet 格式类型映射与 Apache Hive 兼容，但与 Apache Spark 有所不同：

- Timestamp：不论精度，映射 timestamp 类型至 int96。
- Decimal：根据精度，映射 decimal 类型至固定长度字节的数组。

下表列举了 Flink 中的数据类型与 JSON 中的数据类型的映射关系。

| Flink 数据类型          |     Parquet 类型     | Parquet 逻辑类型 |
| :---------------------- | :------------------: | :--------------: |
| CHAR / VARCHAR / STRING |        BINARY        |       UTF8       |
| BOOLEAN                 |       BOOLEAN        |                  |
| BINARY / VARBINARY      |        BINARY        |                  |
| DECIMAL                 | FIXED_LEN_BYTE_ARRAY |     DECIMAL      |
| TINYINT                 |        INT32         |      INT_8       |
| SMALLINT                |        INT32         |      INT_16      |
| INT                     |        INT32         |                  |
| BIGINT                  |        INT64         |                  |
| FLOAT                   |        FLOAT         |                  |
| DOUBLE                  |        DOUBLE        |                  |
| DATE                    |        INT32         |       DATE       |
| TIME                    |        INT32         |   TIME_MILLIS    |
| TIMESTAMP               |        INT96         |                  |

**注意** 暂不支持复合数据类型（Array、Map 与 Row）。