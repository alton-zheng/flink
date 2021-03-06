# HBase SQL 连接器

**Scan Source: Bounded** **Lookup Source: Sync Mode** **Sink: Batch** **Sink: Streaming Upsert Mode**

- [依赖](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/hbase.html#依赖)
- [如何使用 HBase 表](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/hbase.html#如何使用-hbase-表)
- [连接器参数](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/hbase.html#连接器参数)
- [数据类型映射表](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/hbase.html#数据类型映射表)

HBase 连接器支持读取和写入 HBase 集群。本文档介绍如何使用 HBase 连接器基于 HBase 进行 SQL 查询。

HBase 连接器在 upsert 模式下运行，可以使用 DDL 中定义的主键与外部系统交换更新操作消息。但是主键只能基于 HBase 的 rowkey 字段定义。如果没有声明主键，HBase 连接器默认取 rowkey 作为主键。

## 依赖

In order to use the HBase connector the following dependencies are required for both projects using a build automation tool (such as Maven or SBT) and SQL Client with SQL JAR bundles.

| HBase version | Maven dependency                 | SQL Client JAR                                               |
| :------------ | :------------------------------- | :----------------------------------------------------------- |
| 1.4.x         | `flink-connector-hbase-1.4_2.11` | [Download](https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-connector-hbase-1.4_2.11/1.12.0/flink-sql-connector-hbase-1.4_2.11-1.12.0.jar) |
| 2.2.x         | `flink-connector-hbase-2.2_2.11` | [Download](https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-connector-hbase-2.2_2.11/1.12.0/flink-sql-connector-hbase-2.2_2.11-1.12.0.jar) |

## 如何使用 HBase 表

所有 HBase 表的列簇必须定义为 ROW 类型，字段名对应列簇名（column family），嵌套的字段名对应列限定符名（column qualifier）。用户只需在表结构中声明查询中使用的的列簇和列限定符。除了 ROW 类型的列，剩下的原子数据类型字段（比如，STRING, BIGINT）将被识别为 HBase 的 rowkey，一张表中只能声明一个 rowkey。rowkey 字段的名字可以是任意的，如果是保留关键字，需要用反引号。

- [**SQL**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/hbase.html#tab_SQL_0)

```
-- 在 Flink SQL 中注册 HBase 表 "mytable"
CREATE TABLE hTable (
 rowkey INT,
 family1 ROW<q1 INT>,
 family2 ROW<q2 STRING, q3 BIGINT>,
 family3 ROW<q4 DOUBLE, q5 BOOLEAN, q6 STRING>,
 PRIMARY KEY (rowkey) NOT ENFORCED
) WITH (
 'connector' = 'hbase-1.4',
 'table-name' = 'mytable',
 'zookeeper.quorum' = 'localhost:2181'
);

-- 用 ROW(...) 构造函数构造列簇，并往 HBase 表写数据。
-- 假设 "T" 的表结构是 [rowkey, f1q1, f2q2, f2q3, f3q4, f3q5, f3q6]
INSERT INTO hTable
SELECT rowkey, ROW(f1q1), ROW(f2q2, f2q3), ROW(f3q4, f3q5, f3q6) FROM T;

-- 从 HBase 表扫描数据
SELECT rowkey, family1, family3.q4, family3.q6 FROM hTable;

-- temporal join HBase 表，将 HBase 表作为维表
SELECT * FROM myTopic
LEFT JOIN hTable FOR SYSTEM_TIME AS OF myTopic.proctime
ON myTopic.key = hTable.rowkey;
```

## 连接器参数

| 参数                       | 是否必选 | 默认参数 |  数据类型  |                             描述                             |
| :------------------------- | :------: | :------: | :--------: | :----------------------------------------------------------: |
| connector                  |   必选   |  (none)  |   String   | 指定使用的连接器, 支持的值如下 :`hbase-1.4`: 连接 HBase 1.4.x 集群`hbase-2.2`: 连接 HBase 2.2.x 集群 |
| table-name                 |   必选   |  (none)  |   String   |                     连接的 HBase 表名。                      |
| zookeeper.quorum           |   必选   |  (none)  |   String   |                HBase Zookeeper quorum 信息。                 |
| zookeeper.znode.parent     |   可选   |  /hbase  |   String   |               HBase 集群的 Zookeeper 根目录。                |
| null-string-literal        |   可选   |   null   |   String   | 当字符串值为 `null` 时的存储形式，默认存成 "null" 字符串。HBase 的 source 和 sink 的编解码将所有数据类型（除字符串外）将 `null` 值以空字节来存储。 |
| sink.buffer-flush.max-size |   可选   |   2mb    | MemorySize | 写入的参数选项。每次写入请求缓存行的最大大小。它能提升写入 HBase 数据库的性能，但是也可能增加延迟。设置为 "0" 关闭此选项。 |
| sink.buffer-flush.max-rows |   可选   |   1000   |  Integer   | 写入的参数选项。 每次写入请求缓存的最大行数。它能提升写入 HBase 数据库的性能，但是也可能增加延迟。设置为 "0" 关闭此选项。 |
| sink.buffer-flush.interval |   可选   |    1s    |  Duration  | 写入的参数选项。刷写缓存行的间隔。它能提升写入 HBase 数据库的性能，但是也可能增加延迟。设置为 "0" 关闭此选项。注意："sink.buffer-flush.max-size" 和 "sink.buffer-flush.max-rows" 同时设置为 "0"，刷写选项整个异步处理缓存行为。 |
| sink.parallelism           |   可选   |  (none)  |  Integer   | 为 HBase sink operator 定义并行度。默认情况下，并行度由框架决定，和链在一起的上游 operator 一样。 |

## 数据类型映射表

HBase 以字节数组存储所有数据。在读和写过程中要序列化和反序列化数据。

Flink 的 HBase 连接器利用 HBase（Hadoop) 的工具类 `org.apache.hadoop.hbase.util.Bytes` 进行字节数组和 Flink 数据类型转换。

Flink 的 HBase 连接器将所有数据类型（除字符串外）`null` 值编码成空字节。对于字符串类型，`null` 值的字面值由`null-string-literal`选项值决定。

数据类型映射表如下：

| Flink 数据类型            | HBase 转换                                                   |
| :------------------------ | :----------------------------------------------------------- |
| `CHAR / VARCHAR / STRING` | `byte[] toBytes(String s) String toString(byte[] b)`         |
| `BOOLEAN`                 | `byte[] toBytes(boolean b) boolean toBoolean(byte[] b)`      |
| `BINARY / VARBINARY`      | 返回 `byte[]`。                                              |
| `DECIMAL`                 | `byte[] toBytes(BigDecimal v) BigDecimal toBigDecimal(byte[] b)` |
| `TINYINT`                 | `new byte[] { val } bytes[0] // returns first and only byte from bytes` |
| `SMALLINT`                | `byte[] toBytes(short val) short toShort(byte[] bytes)`      |
| `INT`                     | `byte[] toBytes(int val) int toInt(byte[] bytes)`            |
| `BIGINT`                  | `byte[] toBytes(long val) long toLong(byte[] bytes)`         |
| `FLOAT`                   | `byte[] toBytes(float val) float toFloat(byte[] bytes)`      |
| `DOUBLE`                  | `byte[] toBytes(double val) double toDouble(byte[] bytes)`   |
| `DATE`                    | 从 1970-01-01 00:00:00 UTC 开始的天数，int 值。              |
| `TIME`                    | 从 1970-01-01 00:00:00 UTC 开始天的毫秒数，int 值。          |
| `TIMESTAMP`               | 从 1970-01-01 00:00:00 UTC 开始的毫秒数，long 值。           |
| `ARRAY`                   | 不支持                                                       |
| `MAP / MULTISET`          | 不支持                                                       |
| `ROW`                     | 不支持                                                       |