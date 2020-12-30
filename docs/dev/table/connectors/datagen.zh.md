# DataGen SQL 连接器

**Scan Source: 有界** **Scan Source: 无界**

- [怎么创建一个 DataGen 的表](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/datagen.html#怎么创建一个-datagen-的表)
- [连接器参数](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/datagen.html#连接器参数)

DataGen 连接器允许按数据生成规则进行读取。

DataGen 连接器可以使用[计算列语法](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/create.html#create-table)。 这使您可以灵活地生成记录。

DataGen 连接器是内置的。

**注意** 不支持复杂类型: Array，Map，Row。 请用计算列构造这些类型。

## 怎么创建一个 DataGen 的表

表的有界性：当表中字段的数据全部生成完成后，source 就结束了。 因此，表的有界性取决于字段的有界性。

每个列，都有两种生成数据的方法：

- 随机生成器是默认的生成器，您可以指定随机生成的最大和最小值。char、varchar、string （类型）可以指定长度。它是无界的生成器。
- 序列生成器，您可以指定序列的起始和结束值。它是有界的生成器，当序列数字达到结束值，读取结束。

- [**SQL**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/datagen.html#tab_SQL_0)

```
CREATE TABLE datagen (
 f_sequence INT,
 f_random INT,
 f_random_str STRING,
 ts AS localtimestamp,
 WATERMARK FOR ts AS ts
) WITH (
 'connector' = 'datagen',

 -- optional options --

 'rows-per-second'='5',

 'fields.f_sequence.kind'='sequence',
 'fields.f_sequence.start'='1',
 'fields.f_sequence.end'='1000',

 'fields.f_random.min'='1',
 'fields.f_random.max'='1000',

 'fields.f_random_str.length'='10'
)
```

## 连接器参数

| 参数            | 是否必选 |        默认参数         |    数据类型     |                           描述                           |
| :-------------- | :------: | :---------------------: | :-------------: | :------------------------------------------------------: |
| connector       |   必须   |         (none)          |     String      |          指定要使用的连接器，这里是 'datagen'。          |
| rows-per-second |   可选   |          10000          |      Long       |          每秒生成的行数，用以控制数据发出速率。          |
| fields.#.kind   |   可选   |         random          |     String      |  指定 '#' 字段的生成器。可以是 'sequence' 或 'random'。  |
| fields.#.min    |   可选   | (Minimum value of type) | (Type of field) |           随机生成器的最小值，适用于数字类型。           |
| fields.#.max    |   可选   | (Maximum value of type) | (Type of field) |           随机生成器的最大值，适用于数字类型。           |
| fields.#.length |   可选   |           100           |     Integer     | 随机生成器生成字符的长度，适用于 char、varchar、string。 |
| fields.#.start  |   可选   |         (none)          | (Type of field) |                   序列生成器的起始值。                   |
| fields.#.end    |   可选   |         (none)          | (Type of field) |                   序列生成器的结束值。                   |