## Apache Flink 1.9.0 Release Announcement
2019年8月22日

---

Apache Flink社区自豪地宣布了Apache Flink 1.9.0的发布。

Apache Flink项目的目标是开发一个流处理系统来统一和支持多种形式的实时和离线数据处理应用程序以及事件驱动的应用程序。在这个版本中，通过在一个统一的运行时下集成Flink的流和批处理功能，我们在这方面向前迈出了一大步。

此路径上的重要特性是批处理作业的批处理风格恢复，以及针对表API和SQL查询的基于blink的新查询引擎的预览。我们还激动地宣布State Processor API的可用性，它是最常被请求的特性之一，允许用户使用Flink DataSet作业读写保存点。最后，Flink 1.9包含了一个重新构建的WebUI，并预览了Flink的新Python表API及其与Apache Hive生态系统的集成。

这篇博客文章描述了所有主要的新特性和改进，需要注意的重要变化以及未来的发展方向。有关更多细节，请查看[完整的版本更改日志](https://issues.apache.org/jira/secure/ReleaseNote.jspa?projectId=12315522&version=12344601)。

这个版本的二进制发行版和源代码工件现在可以通过Flink项目的下载页面以及更新的文档获得。Flink 1.9与之前的1兼容api。为使用@Public注释的api发布x版本。

请在Flink邮件列表或JIRA中下载该版本并与社区分享您的想法。一如既往，非常感谢您的反馈!

---

### New Features and improvements

---

#### Fine-grained Batch Recovery(FLIP-1)

从任务失败中恢复批处理作业(数据集、表API和SQL)的时间显著减少。在Flink 1.9之前，通过取消所有任务并重新启动整个作业来恢复批作业中的任务失败。这项工作是从零开始的，所有的进步都付诸东流。有了这个版本，Flink可以配置为将恢复限制在同一故障转移区域中的那些任务。故障转移区域是通过管道数据交换连接的一组任务。因此，作业的批处理洗牌连接定义了其故障转移区域的边界。更多细节可以在[FLIP-1](https://cwiki.apache.org/confluence/display/FLINK/FLIP-1+%3A+Fine+Grained+Recovery+from+Task+Failures)中找到。
![release-19-flip1](../images/release-19-flip1.png)

要使用这种新的故障转移策略，您需要执行以下设置:

确保您拥有配置项`jobmanager.execution.failover-strategy`(`flink-conf.yaml`)。
注意:默认情况下，1.9发行版的配置中有这个配置项，但是当重用以前设置的配置文件时，您必须手动添加它。

此外，您需要在`ExecutionConfig`中设置批处理作业的`ExecutionMode`，以配置`data shuffle`不是`pipelined`，并且作业具有多个`failover region`。

“Region”故障转移策略还改进了`embarrassingly parallel`流作业的恢复，即，没有任何像keyBy()或重新平衡这样的混乱。当恢复这样的作业时，只重新启动受影响`pipeline`(`failover region`)的任务。对于所有其他流作业，恢复行为与之前的Flink版本相同。

---

#### State Processor API (FLIP-43)

在Flink 1.9之前，从外部访问作业的状态仅限于(仍然)实验性的可查询状态。该版本引入了一个新的功能强大的库，可以使用`batch DataSet API`读取、写入和修改状态快照。实际上，这意味着:

- Flink作业状态可以通过从外部系统(如外部数据库)读取数据并将其转换为保存点来引导。
- 可以使用任何`Flink`的批处理`api` (`DataSet`、`Table`、`SQL`)查询保存点中的状态，例如分析相关的状态模式，或者检查状态中的差异，以支持应用程序`auditing`或`troubleshooting`。
- 与之前需要在模式访问上进行在线迁移的方法相比，保存点中的状态模式可以离线迁移。
- 可以识别和纠正保存点中的无效数据。

新的状态处理器API涵盖快照的所有变体:`savepoints`、`fill checkpoints`和`incremental checkpoints`。更多细节可以在[FLIP-43](https://cwiki.apache.org/confluence/display/FLINK/FLIP-43%3A+State+Processor+API)中找到

---

#### Stop-with-Savepoint (FLIP-34)

使用[保存点取消](https://ci.apache.org/projects/flink/flink-docs-stable/ops/state/savepoints.html#operations)是`stopping`/`restarting`、`forking`或`updating`Flink作业的常见操作。然而，现有的实现并不能保证对外部存储系统的输出持久性(只针对一次接收)。为了改进停止作业时的端到端(end-to-end)语义，Flink 1.9引入了一种新的挂起模式来停止具有与发出的数据一致的保存点的作业。你可以暂停与Flink的CLI客户端的作业如下:

```bash
bin/flink stop -p [:targetDirectory] :jobId
```

成功时将最终作业状态设置为FINISHED，允许用户检测所请求操作的故障。

更多细节可以在[FLIP-34](https://cwiki.apache.org/confluence/pages/viewpage.action?pageId=103090212)中找到

---

#### Flink WebUI Rework

在讨论了Flink的WebUI内部的现代化之后，这个组件使用`Angular`的最新稳定版本进行了重构——基本上是`Angular` 1.x 到 7.x 版本的一个改进。重新设计的版本是1.9.0中的默认版本，但是有一个链接可以切换到旧的WebUI。

![release-19-web1](../images/release-19-web1.png) 

![release-19-web2](../images/release-19-web2.png)

注意:web ui 往后的版本对WebUI老版本的功能奇偶性将不会得到保证。

---

#### Preview of the new Blink SQL Query Processor

在Blink捐赠给Apache Flink之后，社区致力于集成Blink的查询优化器和`Table API`和`SQL`的`runtime`。作为第一步，我们将整体的`flink-table`模块重构为更小的模块([FLIP-32](https://cwiki.apache.org/confluence/display/FLINK/FLIP-32%3A+Restructure+flink-table+for+future+contributions))。这导致了Java和Scala API模块、优化器模块和运行时模块之间的清晰分离和定义良好的接口。

![release-19-stack](../images/release-19-stack.png)

接下来，我们扩展`Blink`的`planner`来实现新的优化器接口，这样现在就有两个可插入的查询处理器来执行表API和SQL语句:`pre-1.9 Flink`处理器和新的`Blink-based`的查询处理器。Blink-based查询处理器提供了更好的SQL覆盖率(在1.9版本，全`TCP-H`覆盖,`TPC-DS`覆盖计划则是为下一个版本),对批量查询的性能改善的结果更广泛的查询优化(基于成本的方案选择和优化规则),改进的代码生成和优化算子的实现。基于`blink`的查询处理器还提供了更强大的`streaming runner`，提供了一些新特性(例如维度表连接、TopN、重复数据删除)和优化，以解决聚合中的数据倾斜问题，并提供了更有用的内置函数。

**注意**:查询处理器的语义和支持的操作集大部分是一致的，但没有完全对齐。

然而，`Blink`查询处理器的集成还没有完全完成。因此，pre-1.9 Flink处理器仍然是Flink 1.9中的默认处理器，建议用于生产设置。在创建一个`TableEnvironment`时，您可以通过`EnvironmentSettings`来配置Blink处理器，从而启用它。所选处理器必须位于正在执行的Java进程的类路径上。对于集群设置，这两个查询处理器都使用默认配置自动加载。当从IDE运行查询时，您需要显式地向项目添加一个planner依赖项
```xml
<!-- Either... (for the old planner that was available before Flink 1.9) -->
<dependency>
  <groupId>org.apache.flink</groupId>
  <artifactId>flink-table-planner_2.11</artifactId>
  <version>1.9.0</version>
  <scope>provided</scope>
</dependency>
<!-- or.. (for the new Blink planner) -->
<dependency>
  <groupId>org.apache.flink</groupId>
  <artifactId>flink-table-planner-blink_2.11</artifactId>
  <version>1.9.0</version>
  <scope>provided</scope>
</dependency>
```

- Other Improvements to the Table API and SQL

除了Blink planner令人兴奋的进展外，社区还对这些接口进行了一系列其他改进，包括:

  - Scala-free Table API and SQL for Java users ([FLIP-32](https://cwiki.apache.org/confluence/display/FLINK/FLIP-32%3A+Restructure+flink-table+for+future+contributions))

作为flink-table模块重构和拆分的一部分，创建了两个用于Java和Scala的独立API模块。对于Scala用户，实际上没有什么变化，但是Java用户现在可以使用`Table API`和/或SQL，而不需要引入Scala依赖项。

  - Rework of the Table API Type System ([FLIP-37](https://cwiki.apache.org/confluence/display/FLINK/FLIP-37%3A+Rework+of+the+Table+API+Type+System))

社区实现了一个新的数据类型系统，将`Table API`从`Flink`的`TypeInformation`类中分离出来，并提高其对SQL标准的遵从性。这项工作仍在进行中，预计将在下一个版本中完成。在Flink 1.9中，udf和其他一些东西还没有移植到新的类型系统中。

  - Multi-column and Multi-row Transformations for Table API ([FLIP-29](https://cwiki.apache.org/confluence/pages/viewpage.action?pageId=97552739))

`Table API`的功能通过一组支持多行和/或多列输入和输出的转换进行了扩展。这些转换极大地简化了处理逻辑的实现，而使用关系操作符实现这些逻辑将非常麻烦。

  - New, Unified Catalog APIs ([FLIP-30](https://cwiki.apache.org/confluence/display/FLINK/FLIP-30%3A+Unified+Catalog+APIs))

我们重新编写了`catalog APIs`来存储元数据，并统一了内部和外部`catalog`的处理。这项工作主要是作为Hive集成的先决条件启动的(见下文)，但它提高了在Flink中管理目录元数据的总体便利性。除了改进catalog接口之外，我们还扩展了它们的功能。以前用于`Table API`或SQL查询的表定义是不稳定的。使用Flink 1.9，用SQL DDL语句注册的表的元数据可以保存在目录中。这意味着您可以将一个由Kafka主题支持的表添加到一个Metastore目录中，然后在目录连接到Metastore时查询这个表。

  - Rework of the Table API Type System (FLIP-37)

到目前为止，Flink SQL只支持DML语句(例如`SELECT`、`INSERT`)。外部表(表源和表接收器)必须通过Java/Scala代码或配置文件注册。对于1.9，我们添加了对SQL DDL语句的支持，以注册和删除表和视图(创建表、删除表)。但是，我们还没有添加特定于流的语法扩展来定义时间戳提取和水印生成。计划在下一个版本中全面支持流用例。

--- 
#### Preview of Full Hive Integration ([FLINK-10556](https://issues.apache.org/jira/browse/FLINK-10556))

Apache Hive在Hadoop的生态系统中被广泛地用于存储和查询大量的结构化数据。除了是一个查询处理器，Hive还提供一个名为Metastore的目录来管理和组织大型数据集。查询处理器的一个常见集成点是与Hive的Metastore集成，以便能够访问Hive管理的数据。

最近，社区开始为Flink的`Table Api`和`SQL`实现一个外部`catalog`，该`catalog`连接到Hive的`Metastore`。在Flink 1.9中，用户将能够查询和处理存储在Hive中的所有数据。如前所述，您还将能够在Metastore中持久存储Flink表的元数据。此外，Hive集成还支持在Flink `Table API`或SQL查询中使用Hive的udf。更多细节请参阅FLINK-10556。

虽然以前，`Table Api`或SQL查询的表定义总是不稳定的，但是新`catalog`连接器还允许将用SQL DDL语句创建的表持久化到Metastore中(见上文)。这意味着您要连接到Metastore并注册一个表，例如，由`Kafka topic`支持的表。从现在开始，只要`catalog`连接到`Metastore`，就可以查询该表。

请注意，Flink 1.9中的Hive支持是实验性的。我们计划在下一个版本中稳定这些特性，并期待您的反馈。

---

#### Preview of the new Python Table API ([FLIP-38](https://cwiki.apache.org/confluence/display/FLINK/FLIP-38%3A+Python+Table+API))

这个版本还引入了Python `Table API`的第一个版本(FLIP-38)。这标志着我们朝着将成熟的Python支持引入Flink的目标迈进了一步。该特性被设计为一个围绕表API的瘦Python API包装器，基本上将Python`Table API`方法调用转换为Java表API调用。在Flink 1.9附带的最初版本中，Python`Table APi`还不支持udf，只支持标准的关系操作。Python中实现的对udf的支持是未来版本的路线图。

如果您想尝试新的`Python API`，您必须手动安装`PyFlink`。从那里，您可以查看此演练或自己探索它。社区目前正在准备一个`pyflink Python`包，可以通过`pip`安装。

---

### Important Changes

`Table API`和`SQL`现在是`Flink`发行版的默认配置的一部分。以前，必须通过将对应的JAR文件从`./opt`移动到`./lib`来启用`Table API`和`SQL`。
机器学习库(flink-ml)已被删除，以准备[FLIP-39](https://docs.google.com/document/d/1StObo1DLp8iiy0rbukx8kwAJb0BwDZrQrMWub3DzsEo/edit)。
旧的DataSet和DataStream Python api已被删除，取而代之的是[FLIP-38](https://cwiki.apache.org/confluence/display/FLINK/FLIP-38%3A+Python+Table+API)。
Flink可以在`Java 9`上编译和运行。注意，与外部系统(连接器、文件系统、记者)交互的某些组件可能无法工作，因为各自的项目可能跳过了Java 9支持。

---

### Release Notes

如果您计划将Flink安装升级到Flink 1.9.0，请查看发布说明，以获得更详细的更改和新特性列表。

---

### List of Contributors

我们要感谢所有的贡献者，他们使这个版本成为可能:

Abdul Qadeer (abqadeer), Aitozi, Alberto Romero, Aleksey Pak, Alexander Fedulov, Alice Yan, Aljoscha Krettek, Aloys, Andrew Duffy, Andrey Zagrebin, Ankur, Artsem Semianenka, Benchao Li, Biao Liu, Bo WANG, Bowen L, Chesnay Schepler, Clark Yang, Congxian Qiu, Cristian, Danny Chan, David Moravek, Dawid Wysakowicz, Dian Fu, EronWright, Fabian Hueske, Fabio Lombardelli, Fokko Driesprong, Gao Yun, Gary Yao, Gen Luo, Gyula Fora, Hequn Cheng, Hongtao Zhang, Huang Xingbo, HuangXingBo, Hugo Da Cruz Louro, Humberto Rodríguez A, Hwanju Kim, Igal Shilman, Jamie Grier, Jark Wu, Jason, Jasper Yue, Jeff Zhang, Jiangjie (Becket) Qin, Jiezhi.G, Jincheng Sun, Jing Zhang, Jingsong Lee, Juan Gentile, Jungtaek Lim, Kailash Dayanand, Kevin Bohinski, Konstantin Knauf, Konstantinos Papadopoulos, Kostas Kloudas, Kurt Young, Lakshmi, Lakshmi Gururaja Rao, Leeviiii, LouisXu, Maximilian Michels, Nico Kruber, Niels Basjes, Paul Lam, PengFei Li, Peter Huang, Pierre Zemb, Piotr Nowojski, Piyush Narang, Richard Deurwaarder, Robert Metzger, Robert Stoll, Romano Vacca, Rong Rong, Rui Li, Ryantaocer, Scott Mitchell, Seth Wiesman, Shannon Carey, Shimin Yang, Stefan Richter, Stephan Ewen, Stephen Connolly, Steven Wu, SuXingLee, TANG Wen-hui, Thomas Weise, Till Rohrmann, Timo Walther, Tom Goong, TsReaper, Tzu-Li (Gordon) Tai, Ufuk Celebi, Victor Wong, WangHengwei, Wei Zhong, WeiZhong94, Xintong Song, Xpray, XuQianJin-Stars, Xuefu Zhang, Xupingyong, Yangze Guo, Yu Li, Yun Gao, Yun Tang, Zhanchun Zhang, Zhenghua Gao, Zhijiang, Zhu Zhu, Zili Chen, aloys, arganzheng, azagrebin, bd2019us, beyond1920, biao.liub, blueszheng, boshu Zheng, chenqi, chummyhe89, chunpinghe, dcadmin, dianfu, godfrey he, guanghui01.rong, hehuiyuan, hello, hequn8128, jackyyin, joongkeun.yang, klion26, lamber-ken, leesf, liguowei, lincoln-lil, liyafan82, luoqi, mans2singh, maqingxiang, maxin, mjl, okidogi, ozan, potseluev, qiangsi.lq, qiaoran, robbinli, shaoxuan-wang, shengqian.zhou, shenlang.sl, shuai-xu, sunhaibotb, tianchen, tianchen92, tison, tom_gong, vinoyang, vthinkxie, wanggeng3, wenhuitang, winifredtamg, xl38154, xuyang1706, yangfei5, yanghua, yuzhao.cyz, zhangxin516, zhangxinxing, zhaofaxian, zhijiang, zjuwangg, 林小铂, 黄培松, 时无两丶.