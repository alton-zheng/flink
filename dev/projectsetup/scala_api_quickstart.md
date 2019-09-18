# Scala 项目模板

*   [构建工具](scala_api_quickstart.md#构建工具)
*   [SBT](scala_api_quickstart.md#sbt)

    *   [创建项目](scala_api_quickstart.md#%E5%88%9B%E5%BB%BA%E9%A1%B9%E7%9B%AE)
    *   [构建项目](scala_api_quickstart.md#%E6%9E%84%E5%BB%BA%E9%A1%B9%E7%9B%AE)
    *   [运行项目](scala_api_quickstart.md#%E8%BF%90%E8%A1%8C%E9%A1%B9%E7%9B%AE)

*   [Maven](scala_api_quickstart.md#maven)

    *   [环境要求](scala_api_quickstart.md#%E7%8E%AF%E5%A2%83%E8%A6%81%E6%B1%82)
    *   [创建项目](scala_api_quickstart.md#%E5%88%9B%E5%BB%BA%E9%A1%B9%E7%9B%AE-1)
    *   [检查项目](scala_api_quickstart.md#%E6%A3%80%E6%9F%A5%E9%A1%B9%E7%9B%AE)
    *   [构建](scala_api_quickstart.md#%E6%9E%84%E5%BB%BA)

*   [下一步](scala_api_quickstart.md#%E4%B8%8B%E4%B8%80%E6%AD%A5)

## 构建工具

可以使用不同的构建工具来构建Flink项目。 为了快速入门，Flink为以下构建工具提供了项目模板：

*   [SBT](scala_api_quickstart.md#sbt)
*   [Maven](scala_api_quickstart.md#maven)

这些模板将帮助你建立项目的框架并创建初始化的构建文件。

## SBT

### 创建项目

你可以通过以下两种方法之一构建新项目:

- 使用 **sbt 模版**
```bash
$ sbt new tillrohrmann/flink-project.g8
```

这里将提示你输入几个参数 (项目名称，Flink版本...) 然后从 [Flink项目模版](https://github.com/tillrohrmann/flink-project.g8)创建一个Flink项目。 你的sbt版本需要不小于0.13.13才能执行这个命令。如有必要，你可以参考这个[安装指南](http://www.scala-sbt.org/download.md)获取合适版本的sbt。</div>


- 运行 **quickstart 脚本**
```bash
$ bash <(curl https://flink.apache.org/q/sbt-quickstart.sh)
```
这将在指定的目录创建一个Flink项目。

### 构建项目

为了构建你的项目，仅需简单的运行 `sbt clean assembly` 命令。 这将在 **target/scala_your-major-scala-version/** 目录中创建一个 fat-jar **your-project-name-assembly-0.1-SNAPSHOT.jar**。

### 运行项目

为了构建你的项目，需要运行 `sbt run`。

默认情况下，这会在运行 `sbt` 的 JVM 中运行你的作业。 为了在不同的 JVM 中运行，请添加以下内容添加到 `build.sbt`

```bash
fork in run := true
```

#### IntelliJ

我们建议你使用 IntelliJ 来开发Flink作业。 开始，你需要将新建的项目导入到 IntelliJ。 通过 File -> New -> Project from Existing Sources... 操作路径，然后选择项目目录。之后 IntelliJ 将自动检测到 build.sbt 文件并设置好所有内容。

为了运行你的Flink作业，建议选择 mainRunner 模块作为 Run/Debug Configuration 的类路径。 这将确保在作业执行时可以使用所有设置为 provided 的依赖项。 你可以通过 Run -> Edit Configurations... 配置 Run/Debug Configurations，然后从 Use classpath of module 下拉框中选择 mainRunner。

#### Eclipse

为了将新建的项目导入 [Eclipse](https://eclipse.org/), 首先需要创建一个 Eclipse 项目文件。 通过插件 [sbteclipse](https://github.com/typesafehub/sbteclipse) 创建项目文件，并将下面的内容添加到 `PROJECT_DIR/project/plugins.sbt` 文件中:

```bash
addSbtPlugin("com.typesafe.sbteclipse" % "sbteclipse-plugin" % "4.0.0")
```

在 `sbt` 中使用以下命令创建 Eclipse 项目文件

```bash
> eclipse
```

现在你可以通过 `File -> Import... -> Existing Projects into Workspace` 将项目导入 Eclipse，然后选择项目目录。

## Maven

### 环境要求

唯一的要求是安装 **Maven 3.0.4** (或更高版本) 和 **Java 8.x**。

### 创建项目

使用以下命令之一来 **创建项目**:

- 使用 **Maven archetypes**
```bash
    $ mvn archetype:generate                               \
      -DarchetypeGroupId=org.apache.flink              \
      -DarchetypeArtifactId=flink-quickstart-scala     \
      -DarchetypeVersion=1.9.0
```

这将允许你 **为新项目命名**。同时以交互式的方式询问你项目的 groupId，artifactId 和 package 名称.</div>

- 运行 quickstart 开始脚本
```bash
$ curl https://flink.apache.org/q/quickstart-scala.sh | bash -s 1.9.0
```

### 检查项目

项目创建后，工作目录中将多出一个新目录。如果你使用的是 _curl_ 方式创建项目，目录称为 `quickstart`，如果是另外一种创建方式，目录则称为你指定的 `artifactId`。

```bash
$ tree quickstart/
quickstart/
├── pom.xml
└── src
    └── main
        ├── resources
        │   └── log4j.properties
        └── scala
            └── org
                └── myorg
                    └── quickstart
                        ├── BatchJob.scala
                        └── StreamingJob.scala
```

样例项目是一个 **Maven 项目**, 包含了两个类： _StreamingJob_ 和 _BatchJob_ 是 _DataStream_ 和 _DataSet_ 程序的基本框架程序. _main_ 方法是程序的入口, 既用于 IDE 内的测试/执行，也用于合理部署。

我们建议你将 **此项目导入你的 IDE**。

IntelliJ IDEA 支持 Maven 开箱即用，并为Scala开发提供插件。 从我们的经验来看，IntelliJ 提供了最好的Flink应用程序开发体验。

对于 Eclipse，需要以下的插件，你可以从提供的 Eclipse Update Sites 安装这些插件：

*   _Eclipse 4.x_

    *   [Scala IDE](http://download.scala-ide.org/sdk/lithium/e44/scala211/stable/site)
    *   [m2eclipse-scala](http://alchim31.free.fr/m2e-scala/update-site)
    *   [Build Helper Maven Plugin](https://repo1.maven.org/maven2/.m2e/connectors/m2eclipse-buildhelper/0.15.0/N/0.15.0.201207090124/)

*   _Eclipse 3.8_

    *   [Scala IDE for Scala 2.11](http://download.scala-ide.org/sdk/helium/e38/scala211/stable/site) 或者 [Scala IDE for Scala 2.10](http://download.scala-ide.org/sdk/helium/e38/scala210/stable/site)
    *   [m2eclipse-scala](http://alchim31.free.fr/m2e-scala/update-site)
    *   [Build Helper Maven Plugin](https://repository.sonatype.org/content/repositories/forge-sites/m2e-extras/0.14.0/N/0.14.0.201109282148/)

### 构建

如果你想要 **构建/打包你的项目**, 进入到你的项目目录，并执行命令&lsquo;`mvn clean package`&rsquo;。 你将 **找到一个 JAR 文件**，其中包含了你的应用程序，以及已作为依赖项添加到应用程序的连接器和库：`target/<artifact-id>-<version>.jar`。

**注意:** 如果你使用其他类而不是 _StreamingJob_ 作为应用程序的主类/入口，我们建议你相应地更改 `pom.xml` 文件中 `mainClass` 的设置。这样，Flink 运行应用程序时无需另外指定主类。

## 下一步

开始编写你的应用！

如果你准备编写流处理应用，正在寻找灵感来写什么， 可以看看[流处理应用程序教程](../../getting-started/tutorials/datastream_api.md#writing-a-flink-program)

如果你准备编写批处理应用，正在寻找灵感来写什么， 可以看看[批处理应用程序示例](../../dev/batch/examples.md)

有关 API 的完整概述，请查看 [DataStream API](../../dev/datastream_api.md) 和 [DataSet API](../../dev/batch/index.md) 部分。

.md

如果你有任何问题，请发信至我们的[邮箱列表](http://mail-archives.apache.org/mod_mbox/flink-user/)。 我们很乐意提供帮助。