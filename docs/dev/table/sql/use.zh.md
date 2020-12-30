# USE 语句

- [运行一个 USE 语句](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/use.html#运行一个-use-语句)
- [USE CATLOAG](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/use.html#use-catloag)
- [USE](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/use.html#use)

USE 语句用来设置当前的 catalog 或者 database。

## 运行一个 USE 语句

可以使用 `TableEnvironment` 中的 `executeSql()` 方法执行 USE 语句。 若 USE 操作执行成功，`executeSql()` 方法返回 ‘OK’，否则会抛出异常。

以下的例子展示了如何在 `TableEnvironment` 中执行一个 USE 语句。

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/use.html#tab_Java_1)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/use.html#tab_Scala_1)
- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/use.html#tab_Python_1)
- [**SQL CLI**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/use.html#tab_SQL_CLI_1)

```
StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
StreamTableEnvironment tEnv = StreamTableEnvironment.create(env);

// create a catalog
tEnv.executeSql("CREATE CATALOG cat1 WITH (...)");
tEnv.executeSql("SHOW CATALOGS").print();
// +-----------------+
// |    catalog name |
// +-----------------+
// | default_catalog |
// | cat1            |
// +-----------------+

// change default catalog
tEnv.executeSql("USE CATALOG cat1");

tEnv.executeSql("SHOW DATABASES").print();
// databases are empty
// +---------------+
// | database name |
// +---------------+
// +---------------+

// create a database
tEnv.executeSql("CREATE DATABASE db1 WITH (...)");
tEnv.executeSql("SHOW DATABASES").print();
// +---------------+
// | database name |
// +---------------+
// |        db1    |
// +---------------+

// change default database
tEnv.executeSql("USE db1");
```

[ Back to top](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/use.html#top)

## USE CATLOAG

```
USE CATALOG catalog_name
```

设置当前的 catalog。所有后续命令未显式指定 catalog 的将使用此 catalog。如果指定的的 catalog 不存在，则抛出异常。默认的当前 catalog 是 `default_catalog`。

## USE

```
USE [catalog_name.]database_name
```

设置当前的 database。所有后续命令未显式指定 database 的将使用此 database。如果指定的的 database 不存在，则抛出异常。默认的当前 database 是 `default_database`。