# 本地模式安装

请按照以下几个步骤下载最新的稳定版本开始使用。

&nbsp;

## 步骤 1：下载

为了运行Flink，只需提前安装好 **Java 8 或者 Java 11**。你可以通过以下命令来检查 Java 是否已经安装正确。

```
java -version
```

[下载](https://flink.apache.org/downloads.html) release 1.12.0 并解压。

```
$ tar -xzf flink-1.12.0-bin-scala_2.11.tgz
$ cd flink-1.12.0-bin-scala_2.11
```

&nbsp;

## 步骤 2：启动集群

Flink 附带了一个 bash 脚本，可以用于启动本地集群。

```
$ ./bin/start-cluster.sh
Starting cluster.
Starting standalonesession daemon on host.
Starting taskexecutor daemon on host.
```

&nbsp;

## 步骤 3：提交作业（Job）

Flink 的 Releases 附带了许多的示例作业。你可以任意选择一个，快速部署到已运行的集群上。

```
$ ./bin/flink run examples/streaming/WordCount.jar
$ tail log/flink-*-taskexecutor-*.out
  (to,1)
  (be,1)
  (or,1)
  (not,1)
  (to,2)
  (be,2)
```

另外，你可以通过 Flink 的 [Web UI](http://localhost:8081/) 来监视集群的状态和正在运行的作业。

&nbsp;

## 步骤 4：停止集群

完成后，你可以快速停止集群和所有正在运行的组件。

```
$ ./bin/stop-cluster.sh
```