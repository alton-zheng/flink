# EXPLAIN 语句

- [运行一条 EXPLAIN 语句](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/explain.html#运行一条-explain-语句)
- [语法](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/explain.html#语法)

EXPLAIN 语句用来解释一条 query 语句或者 INSERT 语句的逻辑计划和优化后的计划。

## 运行一条 EXPLAIN 语句

EXPLAIN 语句可以通过 `TableEnvironment` 的 `executeSql()` 执行。 若 EXPLAIN 操作执行成功，`executeSql()` 方法返回解释的结果，否则会抛出异常。

以下的例子展示了如何在 `TableEnvironment` 中执行一条 EXPLAIN 语句。

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/explain.html#tab_Java_1)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/explain.html#tab_Scala_1)
- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/explain.html#tab_Python_1)
- [**SQL CLI**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/explain.html#tab_SQL_CLI_1)

```
StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
StreamTableEnvironment tEnv = StreamTableEnvironment.create(env);

// register a table named "Orders"
tEnv.executeSql("CREATE TABLE MyTable1 (`count` bigint, word VARCHAR(256)) WITH (...)");
tEnv.executeSql("CREATE TABLE MyTable2 (`count` bigint, word VARCHAR(256)) WITH (...)");

// explain SELECT statement through TableEnvironment.explainSql()
String explanation = tEnv.explainSql(
  "SELECT `count`, word FROM MyTable1 WHERE word LIKE 'F%' " +
  "UNION ALL " + 
  "SELECT `count`, word FROM MyTable2");
System.out.println(explanation);

// explain SELECT statement through TableEnvironment.executeSql()
TableResult tableResult = tEnv.executeSql(
  "EXPLAIN PLAN FOR " + 
  "SELECT `count`, word FROM MyTable1 WHERE word LIKE 'F%' " +
  "UNION ALL " + 
  "SELECT `count`, word FROM MyTable2");
tableResult.print();
```

执行 `EXPLAIN` 语句后的结果为：

```
== Abstract Syntax Tree ==
LogicalUnion(all=[true])
  LogicalFilter(condition=[LIKE($1, _UTF-16LE'F%')])
    FlinkLogicalTableSourceScan(table=[[default_catalog, default_database, MyTable1]], fields=[count, word])
  FlinkLogicalTableSourceScan(table=[[default_catalog, default_database, MyTable2]], fields=[count, word])
  

== Optimized Logical Plan ==
DataStreamUnion(all=[true], union all=[count, word])
  DataStreamCalc(select=[count, word], where=[LIKE(word, _UTF-16LE'F%')])
    TableSourceScan(table=[[default_catalog, default_database, MyTable1]], fields=[count, word])
  TableSourceScan(table=[[default_catalog, default_database, MyTable2]], fields=[count, word])

== Physical Execution Plan ==
Stage 1 : Data Source
	content : collect elements with CollectionInputFormat

Stage 2 : Data Source
	content : collect elements with CollectionInputFormat

	Stage 3 : Operator
		content : from: (count, word)
		ship_strategy : REBALANCE

		Stage 4 : Operator
			content : where: (LIKE(word, _UTF-16LE'F%')), select: (count, word)
			ship_strategy : FORWARD

			Stage 5 : Operator
				content : from: (count, word)
				ship_strategy : REBALANCE
```

[ Back to top](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/explain.html#top)

## 语法

```
EXPLAIN PLAN FOR <query_statement_or_insert_statement>
```

请参阅 [Queries](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/queries.html#supported-syntax) 页面获得 query 的语法。 请参阅 [INSERT](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/insert.html) 页面获得 INSERT 的语法。