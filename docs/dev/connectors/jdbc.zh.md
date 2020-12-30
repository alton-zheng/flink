# JDBC Connector

该连接器可以向 JDBC 数据库写入数据。

添加下面的依赖以便使用该连接器（同时添加 JDBC 驱动）：

```
<dependency>
  <groupId>org.apache.flink</groupId>
  <artifactId>flink-connector-jdbc_2.11</artifactId>
  <version>1.12.0</version>
</dependency>
```

注意该连接器目前还 **不是** 二进制发行版的一部分，如何在集群中运行请参考 [这里](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/project-configuration.html)。

已创建的 JDBC Sink 能够保证至少一次的语义。 更有效的精确执行一次可以通过 upsert 语句或幂等更新实现。

用法示例：

```
StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
env
        .fromElements(...)
        .addSink(JdbcSink.sink(
                "insert into books (id, title, author, price, qty) values (?,?,?,?,?)",
                (ps, t) -> {
                    ps.setInt(1, t.id);
                    ps.setString(2, t.title);
                    ps.setString(3, t.author);
                    ps.setDouble(4, t.price);
                    ps.setInt(5, t.qty);
                },
                new JdbcConnectionOptions.JdbcConnectionOptionsBuilder()
                        .withUrl(getDbMetadata().getUrl())
                        .withDriverName(getDbMetadata().getDriverClass())
                        .build()));
env.execute();
```