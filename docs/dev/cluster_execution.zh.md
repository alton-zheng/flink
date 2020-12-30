# 集群执行

- [命令行界面（Interface）](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/cluster_execution.html#命令行界面interface)
- 远程环境（Remote Environment）
  - [Maven Dependency](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/cluster_execution.html#maven-dependency)
  - [示例](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/cluster_execution.html#示例)

Flink 程序可以分布式运行在多机器集群上。有两种方式可以将程序提交到集群上执行：



## 命令行界面（Interface）

命令行界面使你可以将打包的程序（JARs）提交到集群（或单机设置）。

有关详细信息，请参阅[命令行界面](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/cli.html)文档。



## 远程环境（Remote Environment）

远程环境使你可以直接在集群上执行 Flink Java 程序。远程环境指向你要执行程序的集群。



### Maven Dependency

如果将程序作为 Maven 项目开发，则必须添加 `flink-clients` 模块的依赖：

```
<dependency>
  <groupId>org.apache.flink</groupId>
  <artifactId>flink-clients_2.11</artifactId>
  <version>1.12.0</version>
</dependency>
```



### 示例

下面演示了 `RemoteEnvironment` 的用法：

```
public static void main(String[] args) throws Exception {
    ExecutionEnvironment env = ExecutionEnvironment
        .createRemoteEnvironment("flink-jobmanager", 8081, "/home/user/udfs.jar");

    DataSet<String> data = env.readTextFile("hdfs://path/to/file");

    data
        .filter(new FilterFunction<String>() {
            public boolean filter(String value) {
                return value.startsWith("http://");
            }
        })
        .writeAsText("hdfs://path/to/result");

    env.execute();
}
```

请注意，该程序包含用户自定义代码，因此需要一个带有附加代码类的 JAR 文件。远程环境的构造函数使用 JAR 文件的路径进行构造。