# BlackHole SQL 连接器

**Sink: Bounded** **Sink: UnBounded**

- [如何创建 BlackHole 表](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/blackhole.html#如何创建-blackhole-表)
- [连接器选项](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/blackhole.html#连接器选项)

BlackHole 连接器允许接收所有输入记录。它被设计用于：

- 高性能测试。
- UDF 输出，而不是实质性 sink。

就像类 Unix 操作系统上的 /dev/null。

BlackHole 连接器是内置的。

## 如何创建 BlackHole 表

- [**SQL**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/blackhole.html#tab_SQL_0)

```
CREATE TABLE blackhole_table (
 f0 INT,
 f1 INT,
 f2 STRING,
 f3 DOUBLE
) WITH (
 'connector' = 'blackhole'
)
```

或者，可以基于现有模式使用 [LIKE 子句](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/create.html#create-table) 创建。

- [**SQL**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/blackhole.html#tab_SQL_1)

```
CREATE TABLE blackhole_table WITH ('connector' = 'blackhole')
LIKE source_table (EXCLUDING ALL)
```

## 连接器选项

| 选项      | 是否必要 | 默认值 |  类型  |                     描述                     |
| :-------- | :------: | :----: | :----: | :------------------------------------------: |
| connector |   必要   | (none) | String | 指定需要使用的连接器，此处应为 `blackhole`。 |