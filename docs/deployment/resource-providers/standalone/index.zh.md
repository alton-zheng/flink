# Standalone

本页面提供了关于如何在*静态*（但可能异构）集群上以*完全分布式方式*运行 Flink 的说明。

- 需求
  - [软件需求](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/resource-providers/standalone/#软件需求)
  - [`JAVA_HOME` 配置](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/resource-providers/standalone/#java_home-配置)
- Flink 设置
  - [配置 Flink](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/resource-providers/standalone/#配置-flink)
  - [启动 Flink](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/resource-providers/standalone/#启动-flink)
  - [为集群添加 JobManager/TaskManager 实例](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/resource-providers/standalone/#为集群添加-jobmanagertaskmanager-实例)
- High-Availability with Standalone
  - [Masters File (masters)](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/resource-providers/standalone/#masters-file-masters)
  - [Example: Standalone Cluster with 2 JobManagers](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/resource-providers/standalone/#example-standalone-cluster-with-2-jobmanagers)



## 需求



### 软件需求

Flink 运行在所有*类 UNIX 环境*下，例如 **Linux**，**Mac OS X** 和 **Cygwin** （Windows），集群由**一个 master 节点**以及**一个或多个 worker 节点**构成。在配置系统之前，请确保**在每个节点上**安装有以下软件：

- **Java 1.8.x** 或更高版本，
- **ssh** （必须运行 sshd 以执行用于管理 Flink 各组件的脚本）

如果集群不满足软件要求，那么你需要安装/更新这些软件。

使集群中所有节点使用**免密码 SSH** 以及拥有**相同的目录结构**可以让你使用脚本来控制一切。

[ Back to top](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/resource-providers/standalone/#top)



### `JAVA_HOME` 配置

Flink 需要 master 和所有 worker 节点设置 `JAVA_HOME` 环境变量，并指向你的 Java 安装目录。

你可以在 `conf/flink-conf.yaml` 文件中通过 `env.java.home` 配置项来设置此变量。

[ Back to top](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/resource-providers/standalone/#top)



## Flink 设置

前往 [下载页面](https://flink.apache.org/zh/downloads.html) 获取可运行的软件包。

在下载完最新的发布版本后，复制压缩文件到 master 节点并解压：

```
tar xzf flink-*.tgz
cd flink-*
```



### 配置 Flink

在解压完文件后，你需要编辑 *conf/flink-conf.yaml* 文件来为集群配置 Flink。

设置 `jobmanager.rpc.address` 配置项指向 master 节点。你也应该通过设置 `jobmanager.memory.process.size` 和 `taskmanager.memory.process.size` 配置项来定义 Flink 允许在每个节点上分配的最大内存值。

这些值的单位是 MB。如果一些 worker 节点上有你想分配到 Flink 系统的多余内存，你可以在这些特定节点的 *conf/flink-conf.yaml* 文件中重写 `taskmanager.memory.process.size` 或 `taskmanager.memory.flink.size` 的默认值。

最后，你必须提供集群上会被用作为 worker 节点的所有节点列表，也就是运行 TaskManager 的节点。编辑文件 *conf/workers* 并输入每个 worker 节点的 IP 或主机名。

以下例子展示了三个节点（IP 地址从 *10.0.0.1* 到 *10.0.0.3*，主机名为 *master*、*worker1*、 *woker2*）的设置，以及配置文件（在所有机器上都需要在相同路径访问）的内容：

![img](https://ci.apache.org/projects/flink/flink-docs-release-1.12/page/img/quickstart_cluster.png)

/path/to/**flink/conf/
flink-conf.yaml**

```
jobmanager.rpc.address: 10.0.0.1
```



/path/to/**flink/
conf/workers**

```
10.0.0.2
10.0.0.3
```



Flink 目录必须放在所有 worker 节点的相同目录下。你可以使用共享的 NFS 目录，或将 Flink 目录复制到每个 worker 节点上。

请参考 [配置参数页面](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html) 获取更多细节以及额外的配置项。

特别地，

- 每个 JobManager 的可用内存值（`jobmanager.memory.process.size`），
- 每个 TaskManager 的可用内存值 （`taskmanager.memory.process.size`，并检查 [内存调优指南](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/memory/mem_tuning.html#configure-memory-for-standalone-deployment)），
- 每台机器的可用 CPU 数（`taskmanager.numberOfTaskSlots`），
- 集群中所有 CPU 数（`parallelism.default`）和
- 临时目录（`io.tmp.dirs`）

的值都是非常重要的配置项。

[ Back to top](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/resource-providers/standalone/#top)



### 启动 Flink

下面的脚本在本地节点启动了一个 JobManager 并通过 SSH 连接到 *workers* 文件中所有的 worker 节点，在每个节点上启动 TaskManager。现在你的 Flink 系统已经启动并运行着。可以通过配置的 RPC 端口向本地节点上的 JobManager 提交作业。

假定你在 master 节点并且在 Flink 目录下：

```
bin/start-cluster.sh
```

为了关闭 Flink，这里同样有一个 `stop-cluster.sh` 脚本。

[ Back to top](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/resource-providers/standalone/#top)



### 为集群添加 JobManager/TaskManager 实例

你可以使用 `bin/jobmanager.sh` 和 `bin/taskmanager.sh` 脚本为正在运行的集群添加 JobManager 和 TaskManager 实例。



#### 添加 JobManager

```
bin/jobmanager.sh ((start|start-foreground) [host] [webui-port])|stop|stop-all
```



#### 添加 TaskManager

```
bin/taskmanager.sh start|start-foreground|stop|stop-all
```

确保在你想启动/关闭相应实例的主机上执行这些脚本。

## High-Availability with Standalone

In order to enable HA for a standalone cluster, you have to use the [ZooKeeper HA services](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/ha/zookeeper_ha.html).

Additionally, you have to configure your cluster to start multiple JobManagers.

### Masters File (masters)

In order to start an HA-cluster configure the *masters* file in `conf/masters`:

- **masters file**: The *masters file* contains all hosts, on which JobManagers are started, and the ports to which the web user interface binds.

  ```
  jobManagerAddress1:webUIPort1
  [...]
  jobManagerAddressX:webUIPortX
  ```

By default, the job manager will pick a *random port* for inter process communication. You can change this via the [high-availability.jobmanager.port](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#high-availability-jobmanager-port) key. This key accepts single ports (e.g. `50010`), ranges (`50000-50025`), or a combination of both (`50010,50011,50020-50025,50050-50075`).

### Example: Standalone Cluster with 2 JobManagers

1. **Configure high availability mode and ZooKeeper quorum** in `conf/flink-conf.yaml`:

   ```
   high-availability: zookeeper
   high-availability.zookeeper.quorum: localhost:2181
   high-availability.zookeeper.path.root: /flink
   high-availability.cluster-id: /cluster_one # important: customize per cluster
   high-availability.storageDir: hdfs:///flink/recovery
   ```

2. **Configure masters** in `conf/masters`:

   ```
   localhost:8081
   localhost:8082
   ```

3. **Configure ZooKeeper server** in `conf/zoo.cfg` (currently it’s only possible to run a single ZooKeeper server per machine):

   ```
   server.0=localhost:2888:3888
   ```

4. **Start ZooKeeper quorum**:

   ```
   $ bin/start-zookeeper-quorum.sh
   Starting zookeeper daemon on host localhost.
   ```

5. **Start an HA-cluster**:

   ```
   $ bin/start-cluster.sh
   Starting HA cluster with 2 masters and 1 peers in ZooKeeper quorum.
   Starting standalonesession daemon on host localhost.
   Starting standalonesession daemon on host localhost.
   Starting taskexecutor daemon on host localhost.
   ```

6. **Stop ZooKeeper quorum and cluster**:

   ```
   $ bin/stop-cluster.sh
   Stopping taskexecutor daemon (pid: 7647) on localhost.
   Stopping standalonesession daemon (pid: 7495) on host localhost.
   Stopping standalonesession daemon (pid: 7349) on host localhost.
   $ bin/stop-zookeeper-quorum.sh
   Stopping zookeeper daemon (pid: 7101) on host localhost.
   ```