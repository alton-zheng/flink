## 示例
---
### 附带示例
在Flink源文件中，包含了许多 Flink 不同 API 接口的代码示例：

- DataStream 应用
(
[java](https://github.com/apache/flink/tree/master/flink-examples/flink-examples-streaming/src/main/java/org/apache/flink/streaming/examples)
 [scala](https://github.com/apache/flink/blob/master/flink-examples/flink-examples-streaming/src/main/scala/org/apache/flink/streaming/scala/examples)
 )
- DataSet 应用
(
[java](https://github.com/apache/flink/blob/master/flink-examples/flink-examples-batch/src/main/java/org/apache/flink/examples/java)
 [scala](https://github.com/apache/flink/blob/master/flink-examples/flink-examples-batch/src/main/scala/org/apache/flink/examples/scala)
 )
- Table API / SQL 查询
(
[java](https://github.com/apache/flink/blob/master/flink-examples/flink-examples-table/src/main/java/org/apache/flink/table/examples/java)
 [scala](https://github.com/apache/flink/blob/master/flink-examples/flink-examples-table/src/main/scala/org/apache/flink/table/examples/scala)
 )

这些[代码示例](https://ci.apache.org/projects/flink/flink-docs-release-1.9/zh/dev/batch/examples.html#running-an-example)清晰的解释了如何运行一个 Flink 程序。

网上示例
在网上也有一些博客讨论了 Flink 应用示例

- [如何使用 Apache Flink 构建有状态流数据应用](https://www.infoworld.com/article/3293426/big-data/how-to-build-stateful-streaming-applications-with-apache-flink.html)，这篇博客提供了基于 DataStream API 以及两个用于流数据分析的 SQL 查询实现的事件驱动的应用程序。

- [使用 Apache Flink、Elasticsearch 和 Kibana 构建实时仪表板应用程序](https://www.elastic.co/blog/building-real-time-dashboard-applications-with-apache-flink-elasticsearch-and-kibana)是 Elastic 的一篇博客，它向我们提供了一种基于 Apache Flink、Elasticsearch 和 Kibana 构建流数据分析实时仪表板的解决方案。

- 来自 Ververica 的 [Flink 学习网站](https://training.ververica.com/)也有许多示例。你可以从中选取能够亲自实践的部分，并加以练习

---

# Batch 示例

以下示例展示了 Flink 从简单的 WordCount 到图算法的应用。示例代码展示了  [Flink’s DataSet API](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/batch/index.html)  的使用。

完整的源代码可以在 Flink 源代码库的  [flink-examples-batch](https://github.com/apache/flink/blob/master/flink-examples/flink-examples-batch)  模块找到。

- [运行一个示例](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/batch/examples.html#%E8%BF%90%E8%A1%8C%E4%B8%80%E4%B8%AA%E7%A4%BA%E4%BE%8B)
- [Word Count](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/batch/examples.html#word-count)
- [Page Rank](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/batch/examples.html#page-rank)
- [Connected Components（连通组件算法）](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/batch/examples.html#connected-components%E8%BF%9E%E9%80%9A%E7%BB%84%E4%BB%B6%E7%AE%97%E6%B3%95)

## 运行一个示例

在开始运行一个示例前，我们假设你已经有了 Flink 的运行示例。导航栏中的“快速开始（Quickstart）”和“安装（Setup）” 标签页提供了启动 Flink 的不同方法。

最简单的方法就是执行  `./bin/start-cluster.sh`，从而启动一个只有一个 JobManager 和 TaskManager 的本地 Flink 集群。

每个 Flink 的 binary release 都会包含一个`examples`（示例）目录，其中可以找到这个页面上每个示例的 jar 包文件。

可以通过执行以下命令来运行 WordCount 示例:

    ./bin/flink run ./examples/batch/WordCount.jar

其他的示例也可以通过类似的方式执行。

注意很多示例在不传递执行参数的情况下都会使用内置数据。如果需要利用 WordCount 程序计算真实数据，你需要传递存储数据的文件路径。

    ./bin/flink run ./examples/batch/WordCount.jar --input /path/to/some/text/data --output /path/to/result

注意非本地文件系统需要一个对应前缀，例如  `hdfs://`。

## Word Count

WordCount 是大数据系统中的 “Hello World”。他可以计算一个文本集合中不同单词的出现频次。这个算法分两步进行： 第一步，把所有文本切割成单独的单词。第二步，把单词分组并分别统计。

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/batch/examples.html#tab_java_0)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/batch/examples.html#tab_scala_0)

  ExecutionEnvironment env = ExecutionEnvironment.getExecutionEnvironment();

  DataSet<String> text = env.readTextFile("/path/to/file");

  DataSet<Tuple2<String, Integer>> counts =
  // 把每一行文本切割成二元组，每个二元组为: (word,1)
  text.flatMap(new Tokenizer())
  // 根据二元组的第“0”位分组，然后对第“1”位求和
  .groupBy(0)
  .sum(1);

  counts.writeAsCsv(outputPath, "\n", " ");

  // 自定义函数
  public static class Tokenizer implements FlatMapFunction<String, Tuple2<String, Integer>> {

      @Override
      public void flatMap(String value, Collector<Tuple2<String, Integer>> out) {
          // 统一大小写并把每一行切割为单词
          String[] tokens = value.toLowerCase().split("\\W+");

          // 消费二元组
          for (String token : tokens) {
              if (token.length() > 0) {
                  out.collect(new Tuple2<String, Integer>(token, 1));
              }
          }
      }

  }

[WordCount 示例](https://github.com/apache/flink/blob/master//flink-examples/flink-examples-batch/src/main/java/org/apache/flink/examples/java/wordcount/WordCount.java)增加如下执行参数: `--input <path> --output <path>`即可实现上述算法。 任何文本文件都可作为测试数据使用。

## Page Rank

PageRank 算法可以计算互联网中一个网页的重要性，这个重要性通过由一个页面指向其他页面的链接定义。PageRank 算法是一个重复执行相同运算的迭代图算法。在每一次迭代中，每个页面把他当前的 rank 值分发给他所有的邻居节点，并且通过他收到邻居节点的 rank 值更新自身的 rank 值。PageRank 算法因 Google 搜索引擎的使用而流行，它根据网页的重要性来对搜索结果进行排名。

在这个简单的示例中，PageRank 算法由一个[批量迭代](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/batch/iterations.html)和一些固定次数的迭代实现。

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/batch/examples.html#tab_java_1)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/batch/examples.html#tab_scala_1)

  ExecutionEnvironment env = ExecutionEnvironment.getExecutionEnvironment();

  // 通过解析一个 CSV 文件来获取每个页面原始的 rank 值
  DataSet<Tuple2<Long, Double>> pagesWithRanks = env.readCsvFile(pagesInputPath)
  .types(Long.class, Double.class)

  // 链接被编码为邻接表: (page-id, Array(neighbor-ids))
  DataSet<Tuple2<Long, Long[]>> pageLinkLists = getLinksDataSet(env);

  // 设置迭代数据集合
  IterativeDataSet<Tuple2<Long, Double>> iteration = pagesWithRanks.iterate(maxIterations);

  DataSet<Tuple2<Long, Double>> newRanks = iteration
  // 为每个页面匹配其对应的出边，并发送 rank 值
  .join(pageLinkLists).where(0).equalTo(0).flatMap(new JoinVertexWithEdgesMatch())
  // 收集并计算新的 rank 值
  .groupBy(0).sum(1)
  // 施加阻尼系数
  .map(new Dampener(DAMPENING_FACTOR, numPages));

  DataSet<Tuple2<Long, Double>> finalPageRanks = iteration.closeWith(
  newRanks,
  newRanks.join(iteration).where(0).equalTo(0)
  // 结束条件
  .filter(new EpsilonFilter()));

  finalPageRanks.writeAsCsv(outputPath, "\n", " ");

  // 自定义函数

  public static final class JoinVertexWithEdgesMatch
  implements FlatJoinFunction<Tuple2<Long, Double>, Tuple2<Long, Long[]>,
  Tuple2<Long, Double>> {

      @Override
      public void join(<Tuple2<Long, Double> page, Tuple2<Long, Long[]> adj,
                          Collector<Tuple2<Long, Double>> out) {
          Long[] neighbors = adj.f1;
          double rank = page.f1;
          double rankToDistribute = rank / ((double) neigbors.length);

          for (int i = 0; i < neighbors.length; i++) {
              out.collect(new Tuple2<Long, Double>(neighbors[i], rankToDistribute));
          }
      }

  }

  public static final class Dampener implements MapFunction<Tuple2<Long,Double>, Tuple2<Long,Double>> {
  private final double dampening, randomJump;

      public Dampener(double dampening, double numVertices) {
          this.dampening = dampening;
          this.randomJump = (1 - dampening) / numVertices;
      }

      @Override
      public Tuple2<Long, Double> map(Tuple2<Long, Double> value) {
          value.f1 = (value.f1 * dampening) + randomJump;
          return value;
      }

  }

  public static final class EpsilonFilter
  implements FilterFunction<Tuple2<Tuple2<Long, Double>, Tuple2<Long, Double>>> {

      @Override
      public boolean filter(Tuple2<Tuple2<Long, Double>, Tuple2<Long, Double>> value) {
          return Math.abs(value.f0.f1 - value.f1.f1) > EPSILON;
      }

  }

[PageRank 代码](https://github.com/apache/flink/blob/master//flink-examples/flink-examples-batch/src/main/java/org/apache/flink/examples/java/graph/PageRank.java)实现了以上示例。 他需要以下参数来运行: `--pages <path> --links <path> --output <path> --numPages <n> --iterations <n>`。

输入文件是纯文本文件，并且必须存为以下格式：

- 页面被表示为一个长整型（long）ID 并由换行符分割
  - 例如  `"1\n2\n12\n42\n63\n"`  给出了 ID 为 1, 2, 12, 42 和 63 的五个页面。
- 链接由空格分割的两个页面 ID 来表示。每个链接由换行符来分割。
  - 例如  `"1 2\n2 12\n1 12\n42 63\n"`  表示了以下四个有向链接： (1)->(2), (2)->(12), (1)->(12) 和 (42)->(63).

这个简单的实现版本要求每个页面至少有一个入链接和一个出链接（一个页面可以指向自己）。

## Connected Components（连通组件算法）

Connected Components 通过给相连的顶点相同的组件 ID 来标示出一个较大的图中的连通部分。类似 PageRank，Connected Components 也是一个迭代算法。在每一次迭代中，每个顶点把他现在的组件 ID 传播给所有邻居顶点。当一个顶点接收到的组件 ID 小于他自身的组件 ID 时，这个顶点也更新其组件 ID 为这个新组件 ID。

这个代码实现使用了[增量迭代](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/batch/iterations.html)： 没有改变其组件 ID 的顶点不会参与下一轮迭代。这种方法会带来更好的性能，因为后面的迭代可以只处理少量的需要计算的顶点。

- [**Java**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/batch/examples.html#tab_java_2)
- [**Scala**](https://ci.apache.org/projects/flink/flink-docs-release-1.10/zh/dev/batch/examples.html#tab_scala_2)

  // 读取顶点和边的数据
  DataSet<Long> vertices = getVertexDataSet(env);
  DataSet<Tuple2<Long, Long>> edges = getEdgeDataSet(env).flatMap(new UndirectEdge());

  // 分配初始的组件 ID（等于每个顶点的 ID）
  DataSet<Tuple2<Long, Long>> verticesWithInitialId = vertices.map(new DuplicateValue<Long>());

  // 开始一个增量迭代
  DeltaIteration<Tuple2<Long, Long>, Tuple2<Long, Long>> iteration =
  verticesWithInitialId.iterateDelta(verticesWithInitialId, maxIterations, 0);

  // 应用迭代计算逻辑:
  DataSet<Tuple2<Long, Long>> changes = iteration.getWorkset()
  // 链接相应的边
  .join(edges).where(0).equalTo(0).with(new NeighborWithComponentIDJoin())
  // 选出最小的邻居组件 ID
  .groupBy(0).aggregate(Aggregations.MIN, 1)
  // 如果邻居的组件 ID 更小则进行更新
  .join(iteration.getSolutionSet()).where(0).equalTo(0)
  .flatMap(new ComponentIdFilter());

  // 停止增量迭代 （增量和新的数据集是相同的）
  DataSet<Tuple2<Long, Long>> result = iteration.closeWith(changes, changes);

  // 输出结果
  result.writeAsCsv(outputPath, "\n", " ");

  // 自定义函数

  public static final class DuplicateValue<T> implements MapFunction<T, Tuple2<T, T>> {

      @Override
      public Tuple2<T, T> map(T vertex) {
          return new Tuple2<T, T>(vertex, vertex);
      }

  }

  public static final class UndirectEdge
  implements FlatMapFunction<Tuple2<Long, Long>, Tuple2<Long, Long>> {
  Tuple2<Long, Long> invertedEdge = new Tuple2<Long, Long>();

      @Override
      public void flatMap(Tuple2<Long, Long> edge, Collector<Tuple2<Long, Long>> out) {
          invertedEdge.f0 = edge.f1;
          invertedEdge.f1 = edge.f0;
          out.collect(edge);
          out.collect(invertedEdge);
      }

  }

  public static final class NeighborWithComponentIDJoin
  implements JoinFunction<Tuple2<Long, Long>, Tuple2<Long, Long>, Tuple2<Long, Long>> {

      @Override
      public Tuple2<Long, Long> join(Tuple2<Long, Long> vertexWithComponent, Tuple2<Long, Long> edge) {
          return new Tuple2<Long, Long>(edge.f1, vertexWithComponent.f1);
      }

  }

  public static final class ComponentIdFilter
  implements FlatMapFunction<Tuple2<Tuple2<Long, Long>, Tuple2<Long, Long>>,
  Tuple2<Long, Long>> {

      @Override
      public void flatMap(Tuple2<Tuple2<Long, Long>, Tuple2<Long, Long>> value,
                          Collector<Tuple2<Long, Long>> out) {
          if (value.f0.f1 < value.f1.f1) {
              out.collect(value.f0);
          }
      }

  }

[ConnectedComponents 代码](https://github.com/apache/flink/blob/master//flink-examples/flink-examples-batch/src/main/java/org/apache/flink/examples/java/graph/ConnectedComponents.java)  实现了以上示例。他需要以下参数来运行: `--vertices <path> --edges <path> --output <path> --iterations <n>`。

输入文件是纯文本文件并且必须被存储为如下格式：

- 顶点被表示为 ID，并且由换行符分隔。
  - 例如  `"1\n2\n12\n42\n63\n"`  表示 (1), (2), (12), (42) 和 (63)五个顶点。
- 边被表示为空格分隔的顶点对。边由换行符分隔:
  - 例如  `"1 2\n2 12\n1 12\n42 63\n"`  表示四条无向边： (1)-(2), (2)-(12), (1)-(12), and (42)-(63)。
