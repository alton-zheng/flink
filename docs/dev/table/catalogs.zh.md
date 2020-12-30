# Catalogs

Catalog 提供了元数据信息，例如数据库、表、分区、视图以及数据库或其他外部系统中存储的函数和信息。

数据处理最关键的方面之一是管理元数据。 元数据可以是临时的，例如临时表、或者通过 TableEnvironment 注册的 UDF。 元数据也可以是持久化的，例如 Hive Metastore 中的元数据。Catalog 提供了一个统一的API，用于管理元数据，并使其可以从 Table API 和 SQL 查询语句中来访问。

- Catalog 类型
  - [GenericInMemoryCatalog](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#genericinmemorycatalog)
  - [JdbcCatalog](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#jdbccatalog)
  - [HiveCatalog](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#hivecatalog)
  - [用户自定义 Catalog](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#用户自定义-catalog)
- 如何创建 Flink 表并将其注册到 Catalog
  - [使用 SQL DDL](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#使用-sql-ddl)
  - [使用 Java/Scala](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#使用-javascala)
- Catalog API
  - [数据库操作](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#数据库操作)
  - [表操作](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#表操作)
  - [视图操作](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#视图操作)
  - [分区操作](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#分区操作)
  - [函数操作](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#函数操作)
- 通过 Table API 和 SQL Client 操作 Catalog
  - [注册 Catalog](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#注册-catalog)
  - [修改当前的 Catalog 和数据库](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#修改当前的-catalog-和数据库)
  - [列出可用的 Catalog](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#列出可用的-catalog)
  - [列出可用的数据库](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#列出可用的数据库)
  - [列出可用的表](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#列出可用的表)

## Catalog 类型

### GenericInMemoryCatalog

`GenericInMemoryCatalog` 是基于内存实现的 Catalog，所有元数据只在 session 的生命周期内可用。

### JdbcCatalog

`JdbcCatalog` 使得用户可以将 Flink 通过 JDBC 协议连接到关系数据库。`PostgresCatalog` 是当前实现的唯一一种 JDBC Catalog。 参考 [JdbcCatalog 文档](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/jdbc.html) 获取关于配置 JDBC catalog 的详细信息。

### HiveCatalog

`HiveCatalog` 有两个用途：作为原生 Flink 元数据的持久化存储，以及作为读写现有 Hive 元数据的接口。 Flink 的 [Hive 文档](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/connectors/hive/) 提供了有关设置 `HiveCatalog` 以及访问现有 Hive 元数据的详细信息。

**警告** Hive Metastore 以小写形式存储所有元数据对象名称。而 `GenericInMemoryCatalog` 区分大小写。

### 用户自定义 Catalog

Catalog 是可扩展的，用户可以通过实现 `Catalog` 接口来开发自定义 Catalog。 想要在 SQL CLI 中使用自定义 Catalog，用户除了需要实现自定义的 Catalog 之外，还需要为这个 Catalog 实现对应的 `CatalogFactory` 接口。

`CatalogFactory` 定义了一组属性，用于 SQL CLI 启动时配置 Catalog。 这组属性集将传递给发现服务，在该服务中，服务会尝试将属性关联到 `CatalogFactory` 并初始化相应的 Catalog 实例。

## 如何创建 Flink 表并将其注册到 Catalog

### 使用 SQL DDL

用户可以使用 DDL 通过 Table API 或者 SQL Client 在 Catalog 中创建表。

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Java_0)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Scala_0)
- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Python_0)
- [**SQL Client**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_SQL_Client_0)

```
TableEnvironment tableEnv = ...

// Create a HiveCatalog 
Catalog catalog = new HiveCatalog("myhive", null, "<path_of_hive_conf>");

// Register the catalog
tableEnv.registerCatalog("myhive", catalog);

// Create a catalog database
tableEnv.executeSql("CREATE DATABASE mydb WITH (...)");

// Create a catalog table
tableEnv.executeSql("CREATE TABLE mytable (name STRING, age INT) WITH (...)");

tableEnv.listTables(); // should return the tables in current catalog and database.
```

更多详细信息，请参考[Flink SQL CREATE DDL](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/create.html)。

### 使用 Java/Scala

用户可以用编程的方式使用Java 或者 Scala 来创建 Catalog 表。

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Java_1)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Scala_1)
- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Python_1)

```
import org.apache.flink.table.api.*;
import org.apache.flink.table.catalog.*;
import org.apache.flink.table.catalog.hive.HiveCatalog;
import org.apache.flink.table.descriptors.Kafka;

TableEnvironment tableEnv = TableEnvironment.create(EnvironmentSettings.newInstance().build());

// Create a HiveCatalog
Catalog catalog = new HiveCatalog("myhive", null, "<path_of_hive_conf>");

// Register the catalog
tableEnv.registerCatalog("myhive", catalog);

// Create a catalog database
catalog.createDatabase("mydb", new CatalogDatabaseImpl(...));

// Create a catalog table
TableSchema schema = TableSchema.builder()
    .field("name", DataTypes.STRING())
    .field("age", DataTypes.INT())
    .build();

catalog.createTable(
        new ObjectPath("mydb", "mytable"),
        new CatalogTableImpl(
            schema,
            new Kafka()
                .version("0.11")
                ....
                .startFromEarlist()
                .toProperties(),
            "my comment"
        ),
        false
    );

List<String> tables = catalog.listTables("mydb"); // tables should contain "mytable"
```

## Catalog API

注意：这里只列出了编程方式的 Catalog API，用户可以使用 SQL DDL 实现许多相同的功能。 关于 DDL 的详细信息请参考 [SQL CREATE DDL](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/create.html)。

### 数据库操作

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Java_2)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Scala_2)
- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Python_2)

```
// create database
catalog.createDatabase("mydb", new CatalogDatabaseImpl(...), false);

// drop database
catalog.dropDatabase("mydb", false);

// alter database
catalog.alterDatabase("mydb", new CatalogDatabaseImpl(...), false);

// get databse
catalog.getDatabase("mydb");

// check if a database exist
catalog.databaseExists("mydb");

// list databases in a catalog
catalog.listDatabases("mycatalog");
```

### 表操作

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Java_3)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Scala_3)
- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Python_3)

```
// create table
catalog.createTable(new ObjectPath("mydb", "mytable"), new CatalogTableImpl(...), false);

// drop table
catalog.dropTable(new ObjectPath("mydb", "mytable"), false);

// alter table
catalog.alterTable(new ObjectPath("mydb", "mytable"), new CatalogTableImpl(...), false);

// rename table
catalog.renameTable(new ObjectPath("mydb", "mytable"), "my_new_table");

// get table
catalog.getTable("mytable");

// check if a table exist or not
catalog.tableExists("mytable");

// list tables in a database
catalog.listTables("mydb");
```

### 视图操作

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Java_4)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Scala_4)
- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Python_4)

```
// create view
catalog.createTable(new ObjectPath("mydb", "myview"), new CatalogViewImpl(...), false);

// drop view
catalog.dropTable(new ObjectPath("mydb", "myview"), false);

// alter view
catalog.alterTable(new ObjectPath("mydb", "mytable"), new CatalogViewImpl(...), false);

// rename view
catalog.renameTable(new ObjectPath("mydb", "myview"), "my_new_view", false);

// get view
catalog.getTable("myview");

// check if a view exist or not
catalog.tableExists("mytable");

// list views in a database
catalog.listViews("mydb");
```

### 分区操作

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Java_5)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Scala_5)
- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Python_5)

```
// create view
catalog.createPartition(
    new ObjectPath("mydb", "mytable"),
    new CatalogPartitionSpec(...),
    new CatalogPartitionImpl(...),
    false);

// drop partition
catalog.dropPartition(new ObjectPath("mydb", "mytable"), new CatalogPartitionSpec(...), false);

// alter partition
catalog.alterPartition(
    new ObjectPath("mydb", "mytable"),
    new CatalogPartitionSpec(...),
    new CatalogPartitionImpl(...),
    false);

// get partition
catalog.getPartition(new ObjectPath("mydb", "mytable"), new CatalogPartitionSpec(...));

// check if a partition exist or not
catalog.partitionExists(new ObjectPath("mydb", "mytable"), new CatalogPartitionSpec(...));

// list partitions of a table
catalog.listPartitions(new ObjectPath("mydb", "mytable"));

// list partitions of a table under a give partition spec
catalog.listPartitions(new ObjectPath("mydb", "mytable"), new CatalogPartitionSpec(...));

// list partitions of a table by expression filter
catalog.listPartitions(new ObjectPath("mydb", "mytable"), Arrays.asList(epr1, ...));
```

### 函数操作

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Java_6)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Scala_6)
- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Python_6)

```
// create function
catalog.createFunction(new ObjectPath("mydb", "myfunc"), new CatalogFunctionImpl(...), false);

// drop function
catalog.dropFunction(new ObjectPath("mydb", "myfunc"), false);

// alter function
catalog.alterFunction(new ObjectPath("mydb", "myfunc"), new CatalogFunctionImpl(...), false);

// get function
catalog.getFunction("myfunc");

// check if a function exist or not
catalog.functionExists("myfunc");

// list functions in a database
catalog.listFunctions("mydb");
```

## 通过 Table API 和 SQL Client 操作 Catalog

### 注册 Catalog

用户可以访问默认创建的内存 Catalog `default_catalog`，这个 Catalog 默认拥有一个默认数据库 `default_database`。 用户也可以注册其他的 Catalog 到现有的 Flink 会话中。

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Java_7)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Scala_7)
- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Python_7)
- [**YAML**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_YAML_7)

```
tableEnv.registerCatalog(new CustomCatalog("myCatalog"));
```

### 修改当前的 Catalog 和数据库

Flink 始终在当前的 Catalog 和数据库中寻找表、视图和 UDF。

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Java_8)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Scala_8)
- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Python_8)
- [**SQL**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_SQL_8)

```
tableEnv.useCatalog("myCatalog");
tableEnv.useDatabase("myDb");
```

通过提供全限定名 `catalog.database.object` 来访问不在当前 Catalog 中的元数据信息。

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Java_9)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Scala_9)
- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Python_9)
- [**SQL**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_SQL_9)

```
tableEnv.from("not_the_current_catalog.not_the_current_db.my_table");
```

### 列出可用的 Catalog

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Java_10)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Scala_10)
- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Python_10)
- [**SQL**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_SQL_10)

```
tableEnv.listCatalogs();
```

### 列出可用的数据库

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Java_11)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Scala_11)
- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Python_11)
- [**SQL**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_SQL_11)

```
tableEnv.listDatabases();
```

### 列出可用的表

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Java_12)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Scala_12)
- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_Python_12)
- [**SQL**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html#tab_SQL_12)

```
tableEnv.listTables();
```