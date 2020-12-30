# SHOW 语句

- [执行 SHOW 语句](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/show.html#执行-show-语句)
- [SHOW CATALOGS](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/show.html#show-catalogs)
- [SHOW CURRENT CATALOG](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/show.html#show-current-catalog)
- [SHOW DATABASES](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/show.html#show-databases)
- [SHOW CURRENT DATABASE](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/show.html#show-current-database)
- [SHOW TABLES](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/show.html#show-tables)
- [SHOW VIEWS](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/show.html#show-views)
- [SHOW FUNCTIONS](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/show.html#show-functions)

SHOW 语句用于列出所有的 catalog，或者列出当前 catalog 中所有的 database，或者列出当前 catalog 和当前 database 的所有表或视图，或者列出当前正在使用的 catalog 和 database, 或者列出所有的 function，包括：临时系统 function，系统 function，临时 catalog function，当前 catalog 和 database 中的 catalog function。

目前 Flink SQL 支持下列 SHOW 语句：

- SHOW CATALOGS
- SHOW CURRENT CATALOG
- SHOW DATABASES
- SHOW CURRENT DATABASE
- SHOW TABLES
- SHOW VIEWS
- SHOW FUNCTIONS

## 执行 SHOW 语句

可以使用 `TableEnvironment` 中的 `executeSql()` 方法执行 SHOW 语句。 若 SHOW 操作执行成功，`executeSql()` 方法返回所有对象，否则会抛出异常。

以下的例子展示了如何在 `TableEnvironment` 中执行一个 SHOW 语句。

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/show.html#tab_Java_1)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/show.html#tab_Scala_1)
- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/show.html#tab_Python_1)
- [**SQL CLI**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/show.html#tab_SQL_CLI_1)

```
StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
StreamTableEnvironment tEnv = StreamTableEnvironment.create(env);

// show catalogs
tEnv.executeSql("SHOW CATALOGS").print();
// +-----------------+
// |    catalog name |
// +-----------------+
// | default_catalog |
// +-----------------+

// show current catalog
tEnv.executeSql("SHOW CURRENT CATALOG").print();
// +----------------------+
// | current catalog name |
// +----------------------+
// |      default_catalog |
// +----------------------+

// show databases
tEnv.executeSql("SHOW DATABASES").print();
// +------------------+
// |    database name |
// +------------------+
// | default_database |
// +------------------+

// show current database
tEnv.executeSql("SHOW CURRENT DATABASE").print();
// +-----------------------+
// | current database name |
// +-----------------------+
// |      default_database |
// +-----------------------+

// create a table
tEnv.executeSql("CREATE TABLE my_table (...) WITH (...)");
// show tables
tEnv.executeSql("SHOW TABLES").print();
// +------------+
// | table name |
// +------------+
// |   my_table |
// +------------+

// create a view
tEnv.executeSql("CREATE VIEW my_view AS ...");
// show views
tEnv.executeSql("SHOW VIEWS").print();
// +-----------+
// | view name |
// +-----------+
// |   my_view |
// +-----------+

// show functions
tEnv.executeSql("SHOW FUNCTIONS").print();
// +---------------+
// | function name |
// +---------------+
// |           mod |
// |        sha256 |
// |           ... |
// +---------------+
```

[ Back to top](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/show.html#top)

## SHOW CATALOGS

```
SHOW CATALOGS
```

展示所有的 catalog。

## SHOW CURRENT CATALOG

```
SHOW CURRENT CATALOG
```

显示当前正在使用的 catalog。

## SHOW DATABASES

```
SHOW DATABASES
```

展示当前 catalog 中所有的 database。

## SHOW CURRENT DATABASE

```
SHOW CURRENT DATABASE
```

显示当前正在使用的 database。

## SHOW TABLES

```
SHOW TABLES
```

展示当前 catalog 和当前 database 中所有的表。

## SHOW VIEWS

```
SHOW VIEWS
```

展示当前 catalog 和当前 database 中所有的视图。

## SHOW FUNCTIONS

```
SHOW FUNCTIONS
```

展示所有的 function，包括：临时系统 function, 系统 function, 临时 catalog function，当前 catalog 和 database 中的 catalog function。