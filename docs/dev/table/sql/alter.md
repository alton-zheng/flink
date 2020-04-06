# ALTER 语句

ALTER 语句用于修改一个已经在 [Catalog]({{ site.baseurl }}/zh/dev/table/catalogs.html) 中注册的表、视图或函数定义。

Flink SQL 目前支持以下 ALTER 语句：

- ALTER TABLE
- ALTER DATABASE
- ALTER FUNCTION

## 执行 ALTER 语句

可以使用 `TableEnvironment` 中的 `sqlUpdate()` 方法执行 ALTER 语句，也可以在 [SQL CLI]({{ site.baseurl }}/zh/dev/table/sqlClient.html) 中执行 ALTER 语句。 若 ALTER 操作执行成功，`sqlUpdate()` 方法不返回任何内容，否则会抛出异常。

以下的例子展示了如何在 `TableEnvironment` 和  SQL CLI 中执行一个 ALTER 语句。

```java
EnvironmentSettings settings = EnvironmentSettings.newInstance()...
TableEnvironment tableEnv = TableEnvironment.create(settings);

// 注册名为 “Orders” 的表
tableEnv.sqlUpdate("CREATE TABLE Orders (`user` BIGINT, product STRING, amount INT) WITH (...)");

// 字符串数组： ["Orders"]
String[] tables = tableEnv.listTable();

// 把 “Orders” 的表名改为 “NewOrders”
tableEnv.sqlUpdate("ALTER TABLE Orders RENAME TO NewOrders;");

// 字符串数组：["NewOrders"]
String[] tables = tableEnv.listTable();
```

```scala
val settings = EnvironmentSettings.newInstance()...
val tableEnv = TableEnvironment.create(settings)

// 注册名为 “Orders” 的表
tableEnv.sqlUpdate("CREATE TABLE Orders (`user` BIGINT, product STRING, amount INT) WITH (...)");

// 字符串数组： ["Orders"]
val tables = tableEnv.listTable()

// 把 “Orders” 的表名改为 “NewOrders”
tableEnv.sqlUpdate("ALTER TABLE Orders RENAME TO NewOrders;")

// 字符串数组：["NewOrders"]
val tables = tableEnv.listTable()
```

```python
settings = EnvironmentSettings.newInstance()...
table_env = TableEnvironment.create(settings)

# 字符串数组： ["Orders"]
tables = tableEnv.listTable()

# 把 “Orders” 的表名改为 “NewOrders”
tableEnv.sqlUpdate("ALTER TABLE Orders RENAME TO NewOrders;")

# 字符串数组：["NewOrders"]
tables = tableEnv.listTable()
```

```sqlite-psql
Flink SQL> CREATE TABLE Orders (`user` BIGINT, product STRING, amount INT) WITH (...);
[INFO] Table has been created.

Flink SQL> SHOW TABLES;
Orders

Flink SQL> ALTER TABLE Orders RENAME TO NewOrders;
[INFO] Table has been removed.

Flink SQL> SHOW TABLES;
NewOrders
```

## ALTER TABLE

* 重命名表

```sqlite-psql
ALTER TABLE [catalog_name.][db_name.]table_name RENAME TO new_table_name
```

把原有的表名更改为新的表名。

* 设置或修改表属性

```sqlite-psql
ALTER TABLE [catalog_name.][db_name.]table_name SET (key1=val1, key2=val2, ...)
```

为指定的表设置一个或多个属性。若个别属性已经存在于表中，则使用新的值覆盖旧的值。

## ALTER DATABASE

```sqlite-psql
ALTER DATABASE [catalog_name.]db_name SET (key1=val1, key2=val2, ...)
```

在数据库中设置一个或多个属性。若个别属性已经在数据库中设定，将会使用新值覆盖旧值。

## ALTER FUNCTION
```sqlite-psql
ALTER [TEMPORARY|TEMPORARY SYSTEM] FUNCTION
  [IF EXISTS] [catalog_name.][db_name.]function_name
  AS identifier [LANGUAGE JAVA|SCALA|
```

修改一个有 catalog 和数据库命名空间的 catalog function ，其需要指定 JAVA / SCALA 或其他 language tag 完整的 classpath。若函数不存在，删除会抛出异常。

**TEMPORARY**

修改一个有 catalog 和数据库命名空间的临时 catalog function ，并覆盖原有的 catalog function 。

**TEMPORARY SYSTEM**

修改一个没有数据库命名空间的临时系统 catalog function ，并覆盖系统内置的函数。

**IF EXISTS**

若函数不存在，则不进行任何操作。

**LANGUAGE JAVA\|SCALA**

Language tag 用于指定 Flink runtime 如何执行这个函数。目前，只支持 JAVA 和 SCALA，且函数的默认语言为 JAVA。