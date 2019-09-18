## 本地安装教程

获得一个Flink示例程序，并运行在几个简单的步骤。

---
### Setup: Download and Start Flink

Flink运行在**Linux**、**Mac OS X**和**Windows**上。要能够运行Flink，惟一的要求是拥有一个可以工作的Java 8.x。Windows用户，请看看[Flink on Windows](flink_on_windows.md)指南，它描述了如何在Windows上运行Flink进行本地设置。

你可以发出以下命令，检查Java的安装是否正确:
```java
java - version
```

如果使用Java 8，输出将如下所示:

```log
java version "1.8.0_111"
Java(TM) SE Runtime Environment (build 1.8.0_111-b14)
Java HotSpot(TM) 64-Bit Server VM (build 25.111-b14, mixed mode)
```

下载并解压

- 从[下载页面](http://flink.apache.org/downloads.html)下载一个二进制文件。您可以选择任何您喜欢的Scala变体。对于某些特性，您可能还必须下载预打包的Hadoop jar之一，并将其放入/lib目录中。
- 到下载目录。
- 解压下载的存档文件。
```bash
cd ~/Downloads        # Go to download directory
$ tar xzf flink-*.tgz   # Unpack the downloaded archive
$ cd flink-1.9.0
```

为 MacOS X 用户， Flink 能通过 [`Homebrew`](https://brew.sh/) 安装
```bash
$ brew install apache-flink
...
$ flink --version
Version: 1.2.0, Commit ID: 1c659cf
```

--- 
### Start a Local Flink Cluster
```bash
$ ./bin/ Start -cluster.sh # Start Flink
```

在`http://localhost:8081`处检查调度程序的web前端，并确保一切正常运行。web前端应该报告一个可用的TaskManager实例。

![jobmanager-1](../../images/jobmanager-1.png)


您还可以通过检查logs目录中的日志文件来验证系统是否正在运行:

```bash
$ tail log/flink-*-standalonesession-*.log
INFO ... - Rest endpoint listening at localhost:8081
INFO ... - http://localhost:8081 was granted leadership ...
INFO ... - Web frontend listening at http://localhost:8081.
INFO ... - Starting RPC endpoint for StandaloneResourceManager at akka://flink/user/resourcemanager .
INFO ... - Starting RPC endpoint for StandaloneDispatcher at akka://flink/user/dispatcher .
INFO ... - ResourceManager akka.tcp://flink@localhost:6123/user/resourcemanager was granted leadership ...
INFO ... - Starting the SlotManager.
INFO ... - Dispatcher akka.tcp://flink@localhost:6123/user/dispatcher was granted leadership ...
INFO ... - Recovering all persisted jobs.
INFO ... - Registering TaskManager ... at ResourceManager
```

### Read the Code
您可以在GitHub上的[scala](https://github.com/apache/flink/blob/master/flink-examples/flink-examples-streaming/src/main/scala/org/apache/flink/streaming/scala/examples/socket/SocketWindowWordCount.scala)和[java](https://github.com/apache/flink/blob/master/flink-examples/flink-examples-streaming/src/main/java/org/apache/flink/streaming/examples/socket/SocketWindowWordCount.java)中找到这个`SocketWindowWordCount`示例的完整源代码。

```scala
object SocketWindowWordCount {

    def main(args: Array[String]) : Unit = {

        // the port to connect to
        val port: Int = try {
            ParameterTool.fromArgs(args).getInt("port")
        } catch {
            case e: Exception => {
                System.err.println("No port specified. Please run 'SocketWindowWordCount --port <port>'")
                return
            }
        }

        // get the execution environment
        val env: StreamExecutionEnvironment = StreamExecutionEnvironment.getExecutionEnvironment

        // get input data by connecting to the socket
        val text = env.socketTextStream("localhost", port, '\n')

        // parse the data, group it, window it, and aggregate the counts
        val windowCounts = text
            .flatMap { w => w.split("\\s") }
            .map { w => WordWithCount(w, 1) }
            .keyBy("word")
            .timeWindow(Time.seconds(5), Time.seconds(1))
            .sum("count")

        // print the results with a single thread, rather than in parallel
        windowCounts.print().setParallelism(1)

        env.execute("Socket Window WordCount")
    }

    // Data type for words with count
    case class WordWithCount(word: String, count: Long)
}
```

---
### Run the Example

现在，我们要运行这个Flink应用程序。它将从套接字中读取文本，并每5秒打印前5秒内每个不同单词出现的次数，即处理时间的滚动窗口，只要单词是浮动的。

首先，我们使用netcat通过
```bash
$ nc - l9000
```

- 提交Flink程序:
```bash
$ ./bin/flink run examples/streaming/SocketWindowWordCount.jar --port 9000
Starting execution of program
```

程序连接到套接字并等待输入。您可以检查web界面，以验证作业是否按预期运行:

![jobmanager-2](../../images/jobmanager-2.png)

![jobmanager-3](../../images/jobmanager-3.png)

- 单词以5秒的时间窗口(处理时间、翻转窗口)计算，并打印到stdout。监控TaskManager的输出文件，用nc写一些文本(输入按下后逐行发送到Flink):
```bash
$ nc -l 9000
lorem ipsum
ipsum ipsum ipsum
bye

```
.out文件将在每个时间窗口的末尾打印计数，只要单词是浮动的，例如:

```bash
$ tail -f log/flink-*-taskexecutor-*.out
lorem : 1
bye : 1
ipsum : 4
```

要停止Flink当你完成输入:
```bash
$ ./bin/stop-cluster.sh
```

下一个步骤
查看更多示例，以更好地了解Flink的编程api。完成这些之后，继续阅读[`stream guide`](https://ci.apache.org/projects/flink/flink-docs-release-1.9/dev/datastream_api.html)。