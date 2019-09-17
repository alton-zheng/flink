# Apache Flink® - 数据流上的有状态计算
![flink-home-graphic](../images/flink-home-graphic.png)

---
## 所有流式应用场景
- 事件驱动应用
- 流批分析
- 数据管道 & ETL

---
## 正确性保证
- Exactly-once 状态一致性
- 事件时间处理
- 成熟的迟到数据处理

---
## 分层API
- SQL on Stream & Batch Data
- DataStream API & DataSet API
- ProcessFunction (Time & State)

---
## 焦距运维
- 灵活部署
- 高可用
- 保存点

---
## 大规模计算
- 水平扩展架构
- 支持超大状态
- 增量检查点机制


---
## 性能卓越
- 低延迟
- 高吞吐
- 内存计算

**以上知识概述在下面链接都有介绍：**
- [usecases](docs/usecases.md)
- [flink-applications](docs/flink-applications.md)
- [flink-operations](docs/flink-operations.md)
- [flink-architecture](docs/flink-architecture.md)


---
## Apache Flink 用户
Apache Flink 为全球许多公司和企业的关键业务提供支持。在这个页面上，我们展示了一些著名的 Flink 用户，他们在生产中运行着有意思的用例，并提供了展示更详细信息的链接。

在项目的 wiki 页面中有一个[谁在使用 Flink](https://cwiki.apache.org/confluence/display/FLINK/Powered+by+Flink) 的页面，展示了更多的 Flink 用户。请注意，该列表并不全面。我们只添加明确要求列出的用户。

- Alibaba

全球最大的零售商阿里巴巴（Alibaba）使用 Flink 的分支版本 Blink 来优化实时搜索排名。

[Link](https://ververica.com/blog/blink-flink-alibaba-search)

- Amazon Kinesis Data Analytics 

是一种用于流处理完全托管的云服务，它部分地使用 Apache Flink 来增加其 Java 应用程序功能。 BetterCloud

- BetterCloud

是一个多 SaaS 管理平台，它使用 Flink 从 SaaS 应用程序活动中获取近乎实时的智能。

[Link](https://www.youtube.com/watch?v=_yHds9SvMfE&list=PLDX4T_cnKjD2UC6wJr_wRbIvtlMtkc-n2&index=10)

- Bouygues Telecom

正在运行由 Flink 提供支持的 30 个生产应用程序，每天处理 100 亿个原始事件。

[Link](http://2016.flink-forward.org/kb_sessions/a-brief-history-of-time-with-apache-flink-real-time-monitoring-and-analysis-with-flink-kafka-hb/)

- Capital One

财富 500 强金融服务公司 Capital One 使用 Flink 进行实时活动监控和报警。

[Link](https://www.slideshare.net/FlinkForward/flink-forward-san-francisco-2018-andrew-gao-jeff-sharpe-finding-bad-acorns)

- Comcast
康卡斯特（Comcast）是一家全球媒体和技术公司，它使用 Flink 来实现机器学习模型和近实时事件流处理。
[Link](https://www.youtube.com/watch?v=3NlSPKLbGO4&list=PLDX4T_cnKjD1ida8K59YPR3lfWOq6IhV_)

- Criteo

是开放互联网的广告平台，使用 Flink 进行实时收入监控和近实时事件处理。

[Link](https://medium.com/criteo-labs/criteo-streaming-flink-31816c08da50)

- 滴滴出行

是全球卓越的移动出行平台，使用 Apache Flink支持了实时监控、实时特征抽取、实时ETL等业务。 

[Link](https://blog.didiyun.com/index.php/2018/12/05/realtime-compute/)

- Drivetribe

是由前“Top Gear”主持人创建的数字社区，它使用 Flink 作为指标和内容推荐。

[Link](https://ververica.com/blog/drivetribe-cqrs-apache-flink/)


- Ebay 

Ebay 的监控平台由 Flink 提供支持，可在指标和日志流上计算上千条自定义报警规则。

[Link](https://vimeo.com/265025956/c7d5576622)

- 爱立信

爱立信使用 Flink 构建了一个实时异常检测器，通过大型基础设施进行机器学习。

[Link](https://www.oreilly.com/ideas/applying-the-kappa-architecture-in-the-telco-industry)

- 华为

华为是全球领先的 ICT 基础设施和智能设备供应商。华为云提供基于 Flink 的云服务。

[Link](https://www.slideshare.net/FlinkForward/flink-forward-san-francisco-2018-jinkui-shi-and-radu-tudoran-flink-realtime-analysis-in-cloudstream-service-of-huawei-cloud)

- King

Candy Crush Saga的创建者，使用 Flink 为数据科学团队提供实时分析仪表板。

[Link](https://techblog.king.com/rbea-scalable-real-time-analytics-king/)

- Klaviyo

使用 Apache Flink 扩展其实时分析系统，该系统每秒对超过一百万个事件进行重复数据删除和聚合。

[Link](https://klaviyo.tech/tagged/counting)

- Lyft 

使用 Flink 作为其流媒体平台的处理引擎，例如为机器学习持续生成特征。

[Link](https://www.slideshare.net/SeattleApacheFlinkMeetup/streaminglyft-greg-fee-seattle-apache-flink-meetup-104398613)

- 快手

是中国领先的短视频分享 App，使用了 Apache Flink 搭建了一个实时监控平台，监控短视频和直播的质量。 

[Link](https://mp.weixin.qq.com/s/BghNofoU6cPRn7XfdHR83w)

- MediaMath 

是一家程序化营销公司，它使用 Flink 为其实时报告基础架构提供支持。

[Link](https://www.youtube.com/watch?v=mSLesPzWplA&index=13&list=PLDX4T_cnKjD2UC6wJr_wRbIvtlMtkc-n2)

- Mux 

是一家流媒体视频提供商的分析公司，它使用 Flink 进行实时异常检测和报警。

[Link](https://mux.com/blog/discovering-anomalies-in-real-time-with-apache-flink/)

- OPPO

作为中国最大的手机厂商之一，利用 Apache Flink 构建了实时数据仓库，用于即时分析运营活动效果及用户短期兴趣。

[Link](https://mp.weixin.qq.com/s/DPLJA8Q2gDXLZF17FOcczw)

- Otto Group

全球第二大在线零售商奥托集团（Otto Group）使用 Flink 进行商业智能流处理。

[Link](http://2016.flink-forward.org/kb_sessions/flinkspector-taming-the-squirrel/)

- OVH

使用 Flink 开发面向流的应用程序，比如实时商业智能系统或警报系统。

[Link](https://www.ovh.com/fr/blog/handling-ovhs-alerts-with-apache-flink/)

- ResearchGate

是科学家的社交网络，它使用 Flink 进行网络分析和近似重复检测。

[Link](http://2016.flink-forward.org/kb_sessions/joining-infinity-windowless-stream-processing-with-flink/)

- Telefónica NEXT

Telefónica NEXT的 TÜV 认证数据匿名平台由 Flink 提供支持。

[Link](https://next.telefonica.de/en/solutions/big-data-privacy-services)

- Tencent

作为最大的互联网公司之一，腾讯利用 Apache Flink 构建了一个内部平台，以提高开发和操作实时应用程序的效率。

[Link](https://data.qq.com/article?id=3853)


- Uber 

在 Apache Flink 上构建了基于 SQL 的开源流媒体分析平台 AthenaX。

[Link](https://eng.uber.com/athenax/)


- Yelp 

利用 Flink 为其数据连接器生态系统和流处理基础架构提供支持。

[Link](https://ververica.com/flink-forward/resources/powering-yelps-data-pipeline-infrastructure-with-apache-flink)

- Zalando

是欧洲最大的电子商务公司之一，它使用 Flink 进行实时过程监控和 ETL。

[Link](https://jobs.zalando.com/tech/blog/complex-event-generation-for-business-process-monitoring-using-apache-flink)

---
## 最新博客,只列出2个，其它博客请关注官网
- 状态处理器API:如何读取、写入和修改Flink应用程序的状态
这篇文章探讨了状态处理器API,介绍了Flink 1.9.0,为什么这个功能是Flink一大步,你可以使用它,如何使用它和探索一些未来的发展方向,使功能与Apache Flink进化成一个统一的批处理和流处理系统。

[官方 Link](https://flink.apache.org/feature/2019/09/13/state-processor-api.html)
[中文 Link](../docs/state-processor-api.md)

Apache Flink 1.9.0发布公告
Apache Flink社区自豪地宣布了Apache Flink 1.9.0的发布。

[官方 Link](https://flink.apache.org/feature/2019/09/13/state-processor-api.html)
[中文 Link](../docs/release-1.9.0.md)