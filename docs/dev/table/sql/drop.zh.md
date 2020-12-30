# DROP 语句

- [执行 DROP 语句](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/drop.html#执行-drop-语句)
- [DROP TABLE](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/drop.html#drop-table)
- [DROP DATABASE](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/drop.html#drop-database)
- [DROP VIEW](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/drop.html#drop-view)
- [DROP FUNCTION](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/drop.html#drop-function)

DROP 语句用于从当前或指定的 [Catalog](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html) 中删除一个已经注册的表、视图或函数。

Flink SQL 目前支持以下 DROP 语句：

- DROP TABLE
- DROP DATABASE
- DROP VIEW
- DROP FUNCTION

## 执行 DROP 语句

可以使用 `TableEnvironment` 中的 `executeSql()` 方法执行 DROP 语句。 若 DROP 操作执行成功，`executeSql()` 方法返回 ‘OK’，否则会抛出异常。

以下的例子展示了如何在 `TableEnvironment` 中执行一个 DROP 语句。

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/drop.html#tab_Java_1)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/drop.html#tab_Scala_1)
- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/drop.html#tab_Python_1)
- [**SQL CLI**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/drop.html#tab_SQL_CLI_1)

```
EnvironmentSettings settings = EnvironmentSettings.newInstance()...
TableEnvironment tableEnv = TableEnvironment.create(settings);

// 注册名为 “Orders” 的表
tableEnv.executeSql("CREATE TABLE Orders (`user` BIGINT, product STRING, amount INT) WITH (...)");

// 字符串数组： ["Orders"]
String[] tables = tableEnv.listTables();
// or tableEnv.executeSql("SHOW TABLES").print();

// 从 catalog 删除 “Orders” 表
tableEnv.executeSql("DROP TABLE Orders");

// 空字符串数组
String[] tables = tableEnv.listTables();
// or tableEnv.executeSql("SHOW TABLES").print();
```

## DROP TABLE

```
DROP TABLE [IF EXISTS] [catalog_name.][db_name.]table_name
```

根据给定的表名删除某个表。若需要删除的表不存在，则抛出异常。

**IF EXISTS**

表不存在时不会进行任何操作。

## DROP DATABASE

```
DROP DATABASE [IF EXISTS] [catalog_name.]db_name [ (RESTRICT | CASCADE) ]
```

根据给定的表名删除数据库。若需要删除的数据库不存在会抛出异常 。

**IF EXISTS**

若数据库不存在，不执行任何操作。

**RESTRICT**

当删除一个非空数据库时，会触发异常。（默认为开）

**CASCADE**

删除一个非空数据库时，把相关联的表与函数一并删除。

## DROP VIEW

```
DROP [TEMPORARY] VIEW  [IF EXISTS] [catalog_name.][db_name.]view_name
```

删除一个有 catalog 和数据库命名空间的视图。若需要删除的视图不存在，则会产生异常。

**TEMPORARY**

删除一个有 catalog 和数据库命名空间的临时视图。

**IF EXISTS**

若视图不存在，则不会进行任何操作。

**依赖管理** Flink 没有使用 CASCADE / RESTRICT 关键字来维护视图的依赖关系，当前的方案是在用户使用视图时再提示错误信息，比如在视图的底层表已经被删除等场景。

## DROP FUNCTION

```
DROP [TEMPORARY|TEMPORARY SYSTEM] FUNCTION [IF EXISTS] [catalog_name.][db_name.]function_name;
```

删除一个有 catalog 和数据库命名空间的 catalog function。若需要删除的函数不存在，则会产生异常。

**TEMPORARY**

删除一个有 catalog 和数据库命名空间的临时 catalog function。

**TEMPORARY SYSTEM**

删除一个没有数据库命名空间的临时系统函数。

**IF EXISTS**

若函数不存在，则不会进行任何操作。