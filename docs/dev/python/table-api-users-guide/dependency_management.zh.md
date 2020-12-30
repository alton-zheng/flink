# 依赖管理

- [Java 依赖管理](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/dependency_management.html#java-依赖管理)
- [Python 依赖管理](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/dependency_management.html#python-依赖管理)
- [Java/Scala程序中的Python依赖管理](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/dependency_management.html#javascala程序中的python依赖管理)



# Java 依赖管理

如果应用了第三方 Java 依赖， 用户可以通过以下 Python Table API进行配置，或者在提交作业时直接通过[命令行参数](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/cli.html#usage)配置。

```
# 通过 "pipeline.jars" 参数指定 jar 包 URL列表， 每个 URL 使用 ";" 分隔。这些 jar 包最终会被上传到集群中。
# 注意：当前支持通过本地文件 URL 进行上传(以 "file://" 开头)。
table_env.get_config().get_configuration().set_string("pipeline.jars", "file:///my/jar/path/connector.jar;file:///my/jar/path/udf.jar")

# 通过 "pipeline.jars" 参数指定依赖 URL 列表， 这些 URL 通过 ";" 分隔，它们最终会被添加到集群的 classpath 中。
# 注意： 必须指定这些文件路径的协议 (如 file://), 并确保这些 URL 在本地客户端和集群都能访问。
table_env.get_config().get_configuration().set_string("pipeline.classpaths", "file:///my/jar/path/connector.jar;file:///my/jar/path/udf.jar")
```



# Python 依赖管理

如果程序中应用到了 Python 第三方依赖，用户可以使用以下 Table API 配置依赖信息，或在提交作业时直接通过[命令行参数](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/cli.html#usage)配置。

| APIs                                                         | Description                                                  |
| :----------------------------------------------------------- | :----------------------------------------------------------- |
| **add_python_file(file_path)**                               | 添加 Python 文件依赖，可以是 Python文件、Python 包或本地文件目录。他们最终会被添加到 Python Worker 的 PYTHONPATH 中，从而让 Python 函数能够正确访问读取。`table_env.add_python_file(file_path)` |
| **set_python_requirements(requirements_file_path, requirements_cache_dir=None)** | 配置一个 requirements.txt 文件用于指定 Python 第三方依赖，这些依赖会被安装到一个临时目录并添加到 Python Worker 的 PYTHONPATH 中。对于在集群中无法访问的外部依赖，用户可以通过 "requirements_cached_dir" 参数指定一个包含这些依赖安装包的目录，这个目录文件会被上传到集群并实现离线安装。`# 执行下面的 shell 命令 echo numpy==1.16.5 > requirements.txt pip download -d cached_dir -r requirements.txt --no-binary :all: # python 代码 table_env.set_python_requirements("requirements.txt", "cached_dir")`请确保这些依赖安装包和集群运行环境所使用的 Python 版本相匹配。此外，这些依赖将通过 Pip 安装， 请确保 Pip 的版本（version >= 7.1.0） 和 Setuptools 的版本（version >= 37.0.0）符合要求。 |
| **add_python_archive(archive_path, target_dir=None)**        | 添加 Python 归档文件依赖。归档文件内的文件将会被提取到 Python Worker 的工作目录下。如果指定了 "target_dir" 参数，归档文件则会被提取到指定名字的目录文件中，否则文件被提取到和归档文件名相同的目录中。`# shell 命令 # 断言 python 解释器的相对路径是 py_env/bin/python zip -r py_env.zip py_env # python 代码 table_env.add_python_archive("py_env.zip") # 或者 table_env.add_python_archive("py_env.zip", "myenv") # 归档文件中的文件可以被 Python 函数读取 def my_udf():    with open("myenv/py_env/data/data.txt") as f:        ...`请确保上传的 Python 环境和集群运行环境匹配。目前只支持上传 zip 格式的文件，如 zip, jar, whl, egg等等。 |
| **set_python_executable(python_exec)**                       | 配置用于执行 Python Worker 的 Python 解释器路径，如 "/usr/local/bin/python3"。`table_env.add_python_archive("py_env.zip") table_env.get_config().set_python_executable("py_env.zip/py_env/bin/python")`请确保配置的 Python 环境和集群运行环境匹配。 |



# Java/Scala程序中的Python依赖管理

It also supports to use Python UDFs in the Java Table API programs or pure SQL programs. The following example shows how to use the Python UDFs in a Java Table API program:

```
import org.apache.flink.configuration.CoreOptions;
import org.apache.flink.table.api.EnvironmentSettings;
import org.apache.flink.table.api.TableEnvironment;

TableEnvironment tEnv = TableEnvironment.create(
    EnvironmentSettings.newInstance().useBlinkPlanner().inBatchMode().build());
tEnv.getConfig().getConfiguration().set(CoreOptions.DEFAULT_PARALLELISM, 1);

// register the Python UDF
tEnv.executeSql("create temporary system function add_one as 'add_one.add_one' language python");

tEnv.createTemporaryView("source", tEnv.fromValues(1L, 2L, 3L).as("a"));

// use Python UDF in the Java Table API program
tEnv.executeSql("select add_one(a) as a from source").collect();
```

You can refer to the SQL statement about [CREATE FUNCTION](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/create.html#create-function) for more details on how to create Python user-defined functions using SQL statements.

The Python dependencies could be specified via the Python [config options](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/python_config.html#python-options), such as **python.archives**, **python.files**, **python.requirements**, **python.client.executable**, **python.executable**. etc or through [command line arguments](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/cli.html#usage) when submitting the job.