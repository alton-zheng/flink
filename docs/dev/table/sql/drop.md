# DROP 语句
DROP 语句用于从当前或指定的 [Catalog]({{ site.baseurl }}/zh/dev/table/catalogs.html) 中删除一个已经注册的表、视图或函数。

Flink SQL 目前支持以下 DROP 语句：

- DROP TABLE
- DROP DATABASE
- DROP FUNCTION

## 执行 DROP 语句

可以使用 `TableEnvironment` 中的 `sqlUpdate()` 方法执行 DROP 语句，也可以在 [SQL CLI]({{ site.baseurl }}/zh/dev/table/sqlClient.html) 中执行 DROP 语句。 若 DROP 操作执行成功，`sqlUpdate()` 方法不返回任何内容，否则会抛出异常。

以下的例子展示了如何在 `TableEnvironment` 和  SQL CLI 中执行一个 DROP 语句。

```java
EnvironmentSettings settings = EnvironmentSettings.newInstance()...
TableEnvironment tableEnv = TableEnvironment.create(settings);

// 注册名为 “Orders” 的表
tableEnv.sqlUpdate("CREATE TABLE Orders (`user` BIGINT, product STRING, amount INT) WITH (...)");

// 字符串数组： ["Orders"]
String[] tables = tableEnv.listTable();

// 从 catalog 删除 “Orders” 表
tableEnv.sqlUpdate("DROP TABLE Orders");

// 空字符串数组
String[] tables = tableEnv.listTable();
```

```scala
val settings = EnvironmentSettings.newInstance()...
val tableEnv = TableEnvironment.create(settings)

// 注册名为 “Orders” 的表
tableEnv.sqlUpdate("CREATE TABLE Orders (`user` BIGINT, product STRING, amount INT) WITH (...)");

// 字符串数组： ["Orders"]
val tables = tableEnv.listTable()

// 从 catalog 删除 “Orders” 表
tableEnv.sqlUpdate("DROP TABLE Orders")

// 空字符串数组
val tables = tableEnv.listTable()
```

```python
settings = EnvironmentSettings.newInstance()...
table_env = TableEnvironment.create(settings)

# 字符串数组： ["Orders"]
tables = tableEnv.listTable()

# 从 catalog 删除 “Orders” 表
tableEnv.sqlUpdate("DROP TABLE Orders")

# 空字符串数组
tables = tableEnv.listTable()
```

```sqlite-psql
Flink SQL> CREATE TABLE Orders (`user` BIGINT, product STRING, amount INT) WITH (...);
[INFO] Table has been created.

Flink SQL> SHOW TABLES;
Orders

Flink SQL> DROP TABLE Orders;
[INFO] Table has been removed.

Flink SQL> SHOW TABLES;
[INFO] Result was empty.
```

## DROP TABLE

```sqlite-psql
DROP TABLE [IF EXISTS] [catalog_name.][db_name.]table_name
```

根据给定的表名删除某个表。若需要删除的表不存在，则抛出异常。

**IF EXISTS**

表不存在时不会进行任何操作。

## DROP DATABASE

```sqlite-psql
DROP DATABASE [IF EXISTS] [catalog_name.]db_name [ (RESTRICT | CASCADE) ]
```

根据给定的表名删除数据库。若需要删除的数据库不存在会抛出异常 。

**IF EXISTS**

若数据库不存在，不执行任何操作。

**RESTRICT**

当删除一个非空数据库时，会触发异常。（默认为开）

**CASCADE**

删除一个非空数据库时，把相关联的表与函数一并删除。

## DROP FUNCTION

```sqlite-psql
DROP [TEMPORARY|TEMPORARY SYSTEM] FUNCTION [IF EXISTS] [catalog_name.][db_name.]function_name;
```

删除一个有 catalog 和数据库命名空间的 catalog function。若需要删除的函数不存在，则会产生异常。

**TEMPORARY**

删除一个有 catalog 和数据库命名空间的临时 catalog function。

**TEMPORARY SYSTEM**

删除一个没有数据库命名空间的临时系统函数。

**IF EXISTS**

若函数不存在，则不会进行任何操作。