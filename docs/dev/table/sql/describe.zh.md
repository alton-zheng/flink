# DESCRIBE 语句

- [执行 DESCRIBE 语句](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/describe.html#执行-describe-语句)
- [语法](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/describe.html#语法)

DESCRIBE 语句用来描述一张表或者视图的 Schema。

## 执行 DESCRIBE 语句

DESCRIBE 语句可以通过 `TableEnvironment` 的 `executeSql()` 执行。 若 DESCRIBE 操作执行成功，`executeSql()` 方法返回该表的 Schema，否则会抛出异常。

以下的例子展示了如何在 `TableEnvironment` 中执行一个 DESCRIBE 语句。

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/describe.html#tab_Java_1)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/describe.html#tab_Scala_1)
- [**Python**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/describe.html#tab_Python_1)
- [**SQL CLI**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/describe.html#tab_SQL_CLI_1)

```
EnvironmentSettings settings = EnvironmentSettings.newInstance()...
TableEnvironment tableEnv = TableEnvironment.create(settings);

// register a table named "Orders"
tableEnv.executeSql(
        "CREATE TABLE Orders (" +
        " `user` BIGINT NOT NULl," +
        " product VARCHAR(32)," +
        " amount INT," +
        " ts TIMESTAMP(3)," +
        " ptime AS PROCTIME()," +
        " PRIMARY KEY(`user`) NOT ENFORCED," +
        " WATERMARK FOR ts AS ts - INTERVAL '1' SECONDS" +
        ") with (...)");

// print the schema
tableEnv.executeSql("DESCRIBE Orders").print();
```

上述例子执行的结果为:

```
+---------+----------------------------------+-------+-----------+-----------------+----------------------------+
|    name |                             type |  null |       key | computed column |                  watermark |
+---------+----------------------------------+-------+-----------+-----------------+----------------------------+
|    user |                           BIGINT | false | PRI(user) |                 |                            |
| product |                      VARCHAR(32) |  true |           |                 |                            |
|  amount |                              INT |  true |           |                 |                            |
|      ts |           TIMESTAMP(3) *ROWTIME* |  true |           |                 | `ts` - INTERVAL '1' SECOND |
|   ptime | TIMESTAMP(3) NOT NULL *PROCTIME* | false |           |      PROCTIME() |                            |
+---------+----------------------------------+-------+-----------+-----------------+----------------------------+
5 rows in set
```

[ Back to top](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/describe.html#top)

## 语法

```
DESCRIBE [catalog_name.][db_name.]table_name
```