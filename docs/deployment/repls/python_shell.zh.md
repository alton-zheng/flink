# Python REPL

Flink附带了一个集成的交互式Python Shell。 它既能够运行在本地启动的local模式，也能够运行在集群启动的cluster模式下。 本地安装Flink，请看[本地安装](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/resource-providers/standalone/)页面。 您也可以从源码安装Flink，请看[从源码构建 Flink](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/flinkDev/building.html)页面。

**注意** Python Shell会调用“python”命令。关于Python执行环境的要求，请参考Python Table API[环境安装](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/installation.html)。

你可以通过PyPi安装PyFlink，然后使用Python Shell:

```bash
# 安装 PyFlink
$ python -m pip install apache-flink
# 执行脚本
$ pyflink-shell.sh local
```

关于如何在一个Cluster集群上运行Python shell，可以参考启动章节介绍。

## 使用

当前Python shell支持Table API的功能。 在启动之后，Table Environment的相关内容将会被自动加载。 可以通过变量”bt_env”来使用BatchTableEnvironment，通过变量”st_env”来使用StreamTableEnvironment。

### Table API

下面是一个通过Python Shell 运行的简单示例:

- [**Stream**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/repls/python_shell.html#tab_Stream_0)
- [**Batch**](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/repls/python_shell.html#tab_Batch_0)

```
>>> import tempfile
>>> import os
>>> import shutil
>>> sink_path = tempfile.gettempdir() + '/streaming.csv'
>>> if os.path.exists(sink_path):
...     if os.path.isfile(sink_path):
...         os.remove(sink_path)
...     else:
...         shutil.rmtree(sink_path)
>>> s_env.set_parallelism(1)
>>> t = st_env.from_elements([(1, 'hi', 'hello'), (2, 'hi', 'hello')], ['a', 'b', 'c'])
>>> st_env.connect(FileSystem().path(sink_path))\
...     .with_format(OldCsv()
...         .field_delimiter(',')
...         .field("a", DataTypes.BIGINT())
...         .field("b", DataTypes.STRING())
...         .field("c", DataTypes.STRING()))\
...     .with_schema(Schema()
...         .field("a", DataTypes.BIGINT())
...         .field("b", DataTypes.STRING())
...         .field("c", DataTypes.STRING()))\
...     .create_temporary_table("stream_sink")
>>> t.select("a + 1, b, c")\
...     .execute_insert("stream_sink").wait()
>>> # 如果作业运行在local模式, 你可以执行以下代码查看结果:
>>> with open(sink_path, 'r') as f:
...     print(f.read())
```

## 启动

查看Python Shell提供的可选参数，可以使用:

```
pyflink-shell.sh --help
```

### Local

Python Shell运行在local模式下，只需要执行:

```
pyflink-shell.sh local
```

### Remote

Python Shell运行在一个指定的JobManager上，通过关键字`remote`和对应的JobManager 的地址和端口号来进行指定:

```
pyflink-shell.sh remote <hostname> <portnumber>
```

### Yarn Python Shell cluster

Python Shell可以运行在YARN集群之上。Python shell在Yarn上部署一个新的Flink集群，并进行连接。除了指定container数量，你也 可以指定JobManager的内存，YARN应用的名字等参数。 例如，在一个部署了两个TaskManager的Yarn集群上运行Python Shell:

```
pyflink-shell.sh yarn -n 2
```

关于所有可选的参数，可以查看本页面底部的完整说明。

### Yarn Session

如果你已经通过Flink Yarn Session部署了一个Flink集群，能够通过以下的命令连接到这个集群:

```
pyflink-shell.sh yarn
```

## 完整的参考

```
Flink Python Shell
使用: pyflink-shell.sh [local|remote|yarn] [options] <args>...

命令: local [选项]
启动一个部署在local的Flink Python shell
使用:
    -h,--help   查看所有可选的参数
命令: remote [选项] <host> <port>
启动一个部署在remote集群的Flink Python shell
  <host>
        JobManager的主机名
  <port>
        JobManager的端口号

使用:
    -h,--help   查看所有可选的参数

命令: yarn [选项]
启动一个部署在Yarn集群的Flink Python Shell
使用:
     -h,--help                       查看所有可选的参数
     -jm,--jobManagerMemory <arg>    具有可选单元的JobManager
                                     的container的内存（默认值：MB)
     -n,--container <arg>            需要分配的YARN container的
                                     数量 (=TaskManager的数量)            
     -nm,--name <arg>                自定义YARN Application的名字
     -qu,--queue <arg>               指定YARN的queue     
     -s,--slots <arg>                每个TaskManager上slots的数量     
     -tm,--taskManagerMemory <arg>   具有可选单元的每个TaskManager
                                     的container的内存（默认值：MB）
-h | --help
    打印输出使用文档
```