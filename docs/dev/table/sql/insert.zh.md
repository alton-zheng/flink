# INSERT 语句

- [执行 INSERT 语句](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/insert.html#执行-insert-语句)
- 将 SELECT 查询数据插入表中
  - [语法](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/insert.html#语法)
  - [示例](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/insert.html#示例)
- 将值插入表中
  - [语法](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/insert.html#语法-1)
  - [示例](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/insert.html#示例-1)

INSERT 语句用来向表中添加行。

## 执行 INSERT 语句

单条 INSERT 语句，可以使用 `TableEnvironment` 中的 `executeSql()` 方法执行。`executeSql()` 方法执行 INSERT 语句时会立即提交一个 Flink 作业，并且返回一个 TableResult 对象，通过该对象可以获取 JobClient 方便的操作提交的作业。 多条 INSERT 语句，使用 `TableEnvironment` 中的 `createStatementSet` 创建一个 `StatementSet` 对象，然后使用 `StatementSet` 中的 `addInsertSql()` 方法添加多条 INSERT 语句，最后通过 `StatementSet` 中的 `execute()` 方法来执行。

以下的例子展示了如何在 `TableEnvironment` 中执行一条 INSERT 语句，或者通过 `StatementSet` 执行多条 INSERT 语句。

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/insert.html#tab_Java_1)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/insert.html#tab_Scala_1)
- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/insert.html#tab_Python_1)
- [**SQL CLI**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/insert.html#tab_SQL_CLI_1)

```
EnvironmentSettings settings = EnvironmentSettings.newInstance()...
TableEnvironment tEnv = TableEnvironment.create(settings);

// 注册一个 "Orders" 源表，和 "RubberOrders" 结果表
tEnv.executeSql("CREATE TABLE Orders (`user` BIGINT, product VARCHAR, amount INT) WITH (...)");
tEnv.executeSql("CREATE TABLE RubberOrders(product VARCHAR, amount INT) WITH (...)");

// 运行一条 INSERT 语句，将源表的数据输出到结果表中
TableResult tableResult1 = tEnv.executeSql(
  "INSERT INTO RubberOrders SELECT product, amount FROM Orders WHERE product LIKE '%Rubber%'");
// 通过 TableResult 来获取作业状态
System.out.println(tableResult1.getJobClient().get().getJobStatus());

//----------------------------------------------------------------------------
// 注册一个 "GlassOrders" 结果表用于运行多 INSERT 语句
tEnv.executeSql("CREATE TABLE GlassOrders(product VARCHAR, amount INT) WITH (...)");

// 运行多条 INSERT 语句，将原表数据输出到多个结果表中
StatementSet stmtSet = tEnv.createStatementSet();
// `addInsertSql` 方法每次只接收单条 INSERT 语句
stmtSet.addInsertSql(
  "INSERT INTO RubberOrders SELECT product, amount FROM Orders WHERE product LIKE '%Rubber%'");
stmtSet.addInsertSql(
  "INSERT INTO GlassOrders SELECT product, amount FROM Orders WHERE product LIKE '%Glass%'");
// 执行刚刚添加的所有 INSERT 语句
TableResult tableResult2 = stmtSet.execute();
// 通过 TableResult 来获取作业状态
System.out.println(tableResult1.getJobClient().get().getJobStatus());
```

[ Back to top](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/insert.html#top)

## 将 SELECT 查询数据插入表中

通过 INSERT 语句，可以将查询的结果插入到表中，

### 语法

```
INSERT { INTO | OVERWRITE } [catalog_name.][db_name.]table_name [PARTITION part_spec] select_statement

part_spec:
  (part_col_name1=val1 [, part_col_name2=val2, ...])
```

**OVERWRITE**

`INSERT OVERWRITE` 将会覆盖表中或分区中的任何已存在的数据。否则，新数据会追加到表中或分区中。

**PARTITION**

`PARTITION` 语句应该包含需要插入的静态分区列与值。

### 示例

```
-- 创建一个分区表
CREATE TABLE country_page_view (user STRING, cnt INT, date STRING, country STRING)
PARTITIONED BY (date, country)
WITH (...)

-- 追加行到该静态分区中 (date='2019-8-30', country='China')
INSERT INTO country_page_view PARTITION (date='2019-8-30', country='China')
  SELECT user, cnt FROM page_view_source;

-- 追加行到分区 (date, country) 中，其中 date 是静态分区 '2019-8-30'；country 是动态分区，其值由每一行动态决定
INSERT INTO country_page_view PARTITION (date='2019-8-30')
  SELECT user, cnt, country FROM page_view_source;

-- 覆盖行到静态分区 (date='2019-8-30', country='China')
INSERT OVERWRITE country_page_view PARTITION (date='2019-8-30', country='China')
  SELECT user, cnt FROM page_view_source;

-- 覆盖行到分区 (date, country) 中，其中 date 是静态分区 '2019-8-30'；country 是动态分区，其值由每一行动态决定
INSERT OVERWRITE country_page_view PARTITION (date='2019-8-30')
  SELECT user, cnt, country FROM page_view_source;
```

## 将值插入表中

通过 INSERT 语句，也可以直接将值插入到表中，

### 语法

```
INSERT { INTO | OVERWRITE } [catalog_name.][db_name.]table_name VALUES values_row [, values_row ...]

values_row:
    : (val1 [, val2, ...])
```

**OVERWRITE**

`INSERT OVERWRITE` 将会覆盖表中的任何已存在的数据。否则，新数据会追加到表中。

### 示例

```
CREATE TABLE students (name STRING, age INT, gpa DECIMAL(3, 2)) WITH (...);

INSERT INTO students
  VALUES ('fred flintstone', 35, 1.28), ('barney rubble', 32, 2.32);
```