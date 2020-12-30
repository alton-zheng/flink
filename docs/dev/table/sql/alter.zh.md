# ALTER 语句

- [执行 ALTER 语句](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/alter.html#执行-alter-语句)
- [ALTER TABLE](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/alter.html#alter-table)
- [ALTER DATABASE](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/alter.html#alter-database)
- [ALTER FUNCTION](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/alter.html#alter-function)

ALTER 语句用于修改一个已经在 [Catalog](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html) 中注册的表、视图或函数定义。

Flink SQL 目前支持以下 ALTER 语句：

- ALTER TABLE
- ALTER DATABASE
- ALTER FUNCTION

## 执行 ALTER 语句

可以使用 `TableEnvironment` 中的 `executeSql()` 方法执行 ALTER 语句。 若 ALTER 操作执行成功，`executeSql()` 方法返回 ‘OK’，否则会抛出异常。

以下的例子展示了如何在 `TableEnvironment` 中执行一个 ALTER 语句。

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/alter.html#tab_Java_1)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/alter.html#tab_Scala_1)
- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/alter.html#tab_Python_1)
- [**SQL CLI**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/alter.html#tab_SQL_CLI_1)

```
EnvironmentSettings settings = EnvironmentSettings.newInstance()...
TableEnvironment tableEnv = TableEnvironment.create(settings);

// 注册名为 “Orders” 的表
tableEnv.executeSql("CREATE TABLE Orders (`user` BIGINT, product STRING, amount INT) WITH (...)");

// 字符串数组： ["Orders"]
String[] tables = tableEnv.listTables();
// or tableEnv.executeSql("SHOW TABLES").print();

// 把 “Orders” 的表名改为 “NewOrders”
tableEnv.executeSql("ALTER TABLE Orders RENAME TO NewOrders;");

// 字符串数组：["NewOrders"]
String[] tables = tableEnv.listTables();
// or tableEnv.executeSql("SHOW TABLES").print();
```

## ALTER TABLE

- 重命名表

```
ALTER TABLE [catalog_name.][db_name.]table_name RENAME TO new_table_name
```

把原有的表名更改为新的表名。

- 设置或修改表属性

```
ALTER TABLE [catalog_name.][db_name.]table_name SET (key1=val1, key2=val2, ...)
```

为指定的表设置一个或多个属性。若个别属性已经存在于表中，则使用新的值覆盖旧的值。

## ALTER DATABASE

```
ALTER DATABASE [catalog_name.]db_name SET (key1=val1, key2=val2, ...)
```

在数据库中设置一个或多个属性。若个别属性已经在数据库中设定，将会使用新值覆盖旧值。

## ALTER FUNCTION

```
ALTER [TEMPORARY|TEMPORARY SYSTEM] FUNCTION
  [IF EXISTS] [catalog_name.][db_name.]function_name
  AS identifier [LANGUAGE JAVA|SCALA|PYTHON]
```

修改一个有 catalog 和数据库命名空间的 catalog function ，需要指定一个新的 identifier ，可指定 language tag 。若函数不存在，删除会抛出异常。

如果 language tag 是 JAVA 或者 SCALA ，则 identifier 是 UDF 实现类的全限定名。关于 JAVA/SCALA UDF 的实现，请参考 [自定义函数](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/functions/udfs.html)。

如果 language tag 是 PYTHON ， 则 identifier 是 UDF 对象的全限定名，例如 `pyflink.table.tests.test_udf.add`。关于 PYTHON UDF 的实现，请参考 [Python UDFs](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/udfs/python_udfs.html)。

**TEMPORARY**

修改一个有 catalog 和数据库命名空间的临时 catalog function ，并覆盖原有的 catalog function 。

**TEMPORARY SYSTEM**

修改一个没有数据库命名空间的临时系统 catalog function ，并覆盖系统内置的函数。

**IF EXISTS**

若函数不存在，则不进行任何操作。

**LANGUAGE JAVA|SCALA|PYTHON**

Language tag 用于指定 Flink runtime 如何执行这个函数。目前，只支持 JAVA，SCALA 和 PYTHON，且函数的默认语言为 JAVA。