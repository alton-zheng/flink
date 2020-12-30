# Print SQL 连接器

**Sink**

- [如何创建一张基于 Print 的表](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/print.html#如何创建一张基于-print-的表)
- [连接器参数](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/print.html#连接器参数)

Print 连接器允许将每一行写入标准输出流或者标准错误流。

设计目的：

- 简单的流作业测试。
- 对生产调试带来极大便利。

四种 format 选项：

| 打印内容                 |          条件 1          |      条件 2      |
| :----------------------- | :----------------------: | :--------------: |
| 标识符:任务 ID> 输出数据 |  需要提供前缀打印标识符  | parallelism > 1  |
| 标识符> 输出数据         |  需要提供前缀打印标识符  | parallelism == 1 |
| 任务 ID> 输出数据        | 不需要提供前缀打印标识符 | parallelism > 1  |
| 输出数据                 | 不需要提供前缀打印标识符 | parallelism == 1 |

输出字符串格式为 “$row_kind(f0,f1,f2…)”，row_kind是一个 [RowKind](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/java/org/apache/flink/types/RowKind.html) 类型的短字符串，例如：”+I(1,1)”。

Print 连接器是内置的。

**注意** 在任务运行时使用 Print Sinks 打印记录，你需要注意观察任务日志。

## 如何创建一张基于 Print 的表

- [**SQL**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/print.html#tab_SQL_0)

```
CREATE TABLE print_table (
 f0 INT,
 f1 INT,
 f2 STRING,
 f3 DOUBLE
) WITH (
 'connector' = 'print'
)
```

或者，也可以通过 [LIKE子句](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/create.html#create-table) 基于已有表的结构去创建新表。

- [**SQL**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/print.html#tab_SQL_1)

```
CREATE TABLE print_table WITH ('connector' = 'print')
LIKE source_table (EXCLUDING ALL)
```

## 连接器参数

| 参数             | 是否必选 | 默认参数 | 数据类型 |                            描述                            |
| :--------------- | :------: | :------: | :------: | :--------------------------------------------------------: |
| connector        |   必选   |  (none)  |  String  |            指定要使用的连接器，此处应为 'print'            |
| print-identifier |   可选   |  (none)  |  String  |             配置一个标识符作为输出数据的前缀。             |
| standard-error   |   可选   |  false   | Boolean  | 如果 format 需要打印为标准错误而不是标准输出，则为 True 。 |