# TableEnvironment

本篇文档是对 PyFlink `TableEnvironment` 的介绍。 文档包括对 `TableEnvironment` 类中每个公共接口的详细描述。

- [创建 TableEnvironment](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/table_environment.html#创建-tableenvironment)
- TableEnvironment API
  - [Table/SQL 操作](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/table_environment.html#tablesql-操作)
  - [执行/解释作业](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/table_environment.html#执行解释作业)
  - [创建/删除用户自定义函数](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/table_environment.html#创建删除用户自定义函数)
  - [依赖管理](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/table_environment.html#依赖管理)
  - [配置](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/table_environment.html#配置)
  - [Catalog APIs](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/table_environment.html#catalog-apis)
- [Statebackend，Checkpoint 以及重启策略](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/table_environment.html#statebackendcheckpoint-以及重启策略)

## 创建 TableEnvironment

创建 `TableEnvironment` 的推荐方式是通过 `EnvironmentSettings` 对象创建:

```
from pyflink.table import EnvironmentSettings, StreamTableEnvironment, BatchTableEnvironment

# 创建 blink 流 TableEnvironment
env_settings = EnvironmentSettings.new_instance().in_streaming_mode().use_blink_planner().build()
table_env = StreamTableEnvironment.create(environment_settings=env_settings)

# 创建 blink 批 TableEnvironment
env_settings = EnvironmentSettings.new_instance().in_batch_mode().use_blink_planner().build()
table_env = BatchTableEnvironment.create(environment_settings=env_settings)

# 创建 flink 流 TableEnvironment
env_settings = EnvironmentSettings.new_instance().in_streaming_mode().use_old_planner().build()
table_env = StreamTableEnvironment.create(environment_settings=env_settings)

# 创建 flink 批 TableEnvironment
env_settings = EnvironmentSettings.new_instance().in_batch_mode().use_old_planner().build()
table_env = BatchTableEnvironment.create(environment_settings=env_settings)
```

如果你需要使用 `TableEnvironment` 所依赖的 `ExecutionEnvironment`/`StreamExecutionEnvironment` 对象， 例如：与 DataStream API 混合编程，使用 `ExecutionEnvironment`/`StreamExecutionEnvironment` APIs 进行配置， 你也可以通过一个 `TableConfig` 对象从 `ExecutionEnvironment`/`StreamExecutionEnvironment` 中创建出 `TableEnvironment`，其中 `TableConfig` 是可选的：

```
from pyflink.dataset import ExecutionEnvironment
from pyflink.datastream import StreamExecutionEnvironment
from pyflink.table import StreamTableEnvironment, BatchTableEnvironment, TableConfig

# 通过 StreamExecutionEnvironment 创建 blink 流 TableEnvironment
env = StreamExecutionEnvironment.get_execution_environment()
table_env = StreamTableEnvironment.create(env)

# 通过 StreamExecutionEnvironment 和 TableConfig 创建 blink 流 TableEnvironment
env = StreamExecutionEnvironment.get_execution_environment()
table_config = TableConfig()  # you can add configuration options in it
table_env = StreamTableEnvironment.create(env, table_config)

# 通过 ExecutionEnvironment 创建 flink 批 TableEnvironment 
env = ExecutionEnvironment.get_execution_environment()
table_env = BatchTableEnvironment.create(env)

# 通过 ExecutionEnvironment 和 TableConfig 创建 flink 批 TableEnvironment
env = ExecutionEnvironment.get_execution_environment()
table_config = TableConfig()  # you can add configuration options in it
table_env = BatchTableEnvironment.create(env, table_config)

# 通过 StreamExecutionEnvironment 创建 flink 流 TableEnvironment
env = StreamExecutionEnvironment.get_execution_environment()
env_settings = EnvironmentSettings.new_instance().in_streaming_mode().use_old_planner().build()
table_env = StreamTableEnvironment.create(env, environment_settings=env_settings)
```

**注意：** 现在， `ExecutionEnvironment`/`StreamExecutionEnvironment` 中所有的配置项几乎都可以通过 `TableEnvironment.get_config()` 来配置，更多详情，可查阅 [配置](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html)。 只有少数很少使用的或者被废弃的配置仍然需要直接通过 `ExecutionEnvironment` /`StreamExecutionEnvironment` 来配置，例如输入依赖约束。

## TableEnvironment API

### Table/SQL 操作

这些 APIs 用来创建或者删除 Table API/SQL 表和写查询：

| APIs                                                         |                             描述                             |                             文档                             |
| :----------------------------------------------------------- | :----------------------------------------------------------: | :----------------------------------------------------------: |
| **from_elements(elements, schema=None, verify_schema=True)** |                    通过元素集合来创建表。                    | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.from_elements) |
| **from_pandas(pdf, schema=None, split_num=1)**               |               通过 pandas DataFrame 来创建表。               | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.from_pandas) |
| **from_path(path)**                                          | 通过指定路径下已注册的表来创建一个表，例如通过 **create_temporary_view** 注册表。 | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.from_path) |
| **sql_query(query)**                                         |   执行一条 SQL 查询，并将查询的结果作为一个 `Table` 对象。   | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.sql_query) |
| **create_temporary_view(view_path, table)**                  |  将一个 `Table` 对象注册为一张临时表，类似于 SQL 的临时表。  | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.create_temporary_view) |
| **drop_temporary_view(view_path)**                           |                删除指定路径下已注册的临时表。                | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.drop_temporary_view) |
| **drop_temporary_table(table_path)**                         | 删除指定路径下已注册的临时表。 你可以使用这个接口来删除临时 source 表和临时 sink 表。 | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.drop_temporary_table) |
| **execute_sql(stmt)**                                        | 执行指定的语句并返回执行结果。 执行语句可以是 DDL/DML/DQL/SHOW/DESCRIBE/EXPLAIN/USE。  注意，对于 "INSERT INTO" 语句，这是一个异步操作，通常在向远程集群提交作业时才需要使用。 但是，如果在本地集群或者 IDE 中执行作业时，你需要等待作业执行完成，这时你可以查阅 [这里](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/faq.html#wait-for-jobs-to-finish-when-executing-jobs-in-mini-cluster) 来获取更多细节。 更多关于 SQL 语句的细节，可查阅 [SQL](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sql/) 文档。 | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.execute_sql) |

**废弃的 APIs**

| APIs                                          |                             描述                             |                             文档                             |
| :-------------------------------------------- | :----------------------------------------------------------: | :----------------------------------------------------------: |
| **from_table_source(table_source)**           |                通过 table source 创建一张表。                | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.from_table_source) |
| **scan(\*table_path)**                        | 从 catalog 中扫描已注册的表并且返回结果表。 它可以使用 **from_path** 来替换。 | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.scan) |
| **register_table(name, table)**               | 在 TableEnvironment 的 catalog 中用唯一名称注册一个 “Table” 对象。 可以在 SQL 查询中引用已注册的表。 它可以使用 **create_temporary_view** 替换。 | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.register_table) |
| **register_table_source(name, table_source)** | 在 TableEnvironment 的 catalog 中注册一个外部 `TableSource`。 | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.register_table_source) |
| **register_table_sink(name, table_sink)**     | 在 TableEnvironment 的 catalog 中注册一个外部 `TableSink`。  | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.register_table_sink) |
| **insert_into(target_path, table)**           | 将 `Table` 对象的内容写到指定的 sink 表中。 注意，这个接口不会触发作业的执行。 你需要调用 `execute` 方法来执行你的作业。 | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.insert_into) |
| **sql_update(stmt)**                          | 计算 INSERT, UPDATE 或者 DELETE 等 SQL 语句或者一个 DDL 语句。 它可以使用 **execute_sql** 来替换。 | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.sql_update) |
| **connect(connector_descriptor)**             | 根据描述符创建临时表。 目前推荐的方式是使用 **execute_sql** 来注册临时表。 | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.connect) |

### 执行/解释作业

这些 APIs 是用来执行/解释作业。注意，`execute_sql` API 也可以用于执行作业。

| APIs                                   |                             描述                             |                             文档                             |
| :------------------------------------- | :----------------------------------------------------------: | :----------------------------------------------------------: |
| **explain_sql(stmt, \*extra_details)** |             返回指定语句的抽象语法树和执行计划。             | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.explain_sql) |
| **create_statement_set()**             | 创建一个可接受 DML 语句或表的 StatementSet 实例。 它可用于执行包含多个 sink 的作业。 | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.create_statement_set) |

**废弃的 APIs**

| APIs                                    |                             描述                             |                             文档                             |
| :-------------------------------------- | :----------------------------------------------------------: | :----------------------------------------------------------: |
| **explain(table=None, extended=False)** | 返回指定 Table API 和 SQL 查询的抽象语法树，以及用来计算给定 `Table` 对象或者多个 sink 计划结果的执行计划。 如果你使用 "insert_into" 或者 "sql_update" 方法将数据发送到多个 sinks，你可以通过这个方法来得到执行计划。 它也可以用 **TableEnvironment.explain_sql**，**Table.explain** 或者 **StatementSet.explain** 来替换。 | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.explain) |
| **execute(job_name)**                   | 触发程序执行。执行环境将执行程序的所有部分。 如果你想要使用 **insert_into** 或者 **sql_update** 方法将数据发送到结果表，你可以使用这个方法触发程序的执行。 这个方法将阻塞客户端程序，直到任务完成/取消/失败。 | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.execute) |

### 创建/删除用户自定义函数

这些 APIs 用来注册 UDFs 或者 删除已注册的 UDFs。 注意，`execute_sql` API 也可以用于注册/删除 UDFs。 关于不同类型 UDFs 的详细信息，可查阅 [用户自定义函数](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/functions/)。

| APIs                                                         |                             描述                             |                             文档                             |
| :----------------------------------------------------------- | :----------------------------------------------------------: | :----------------------------------------------------------: |
| **create_temporary_function(path, function)**                |    将一个 Python 用户自定义函数注册为临时 catalog 函数。     | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.create_temporary_function) |
| **create_temporary_system_function(name, function)**         | 将一个 Python 用户自定义函数注册为临时系统函数。 如果临时系统函数的名称与临时 catalog 函数名称相同，优先使用临时系统函数。 | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.create_temporary_system_function) |
| **create_java_function(path, function_class_name, ignore_if_exists=None)** | 将 Java 用户自定义函数注册为指定路径下的 catalog 函数。 如果 catalog 是持久化的，则可以跨多个 Flink 会话和集群使用已注册的 catalog 函数。 | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.create_java_function) |
| **create_java_temporary_function(path, function_class_name)** |       将 Java 用户自定义函数注册为临时 catalog 函数。        | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.create_java_temporary_function) |
| **create_java_temporary_system_function(name, function_class_name)** |          将 Java 用户定义的函数注册为临时系统函数。          | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.create_java_temporary_system_function) |
| **drop_function(path)**                                      |            删除指定路径下已注册的 catalog 函数。             | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.drop_function) |
| **drop_temporary_function(path)**                            |             删除指定名称下已注册的临时系统函数。             | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.drop_temporary_function) |
| **drop_temporary_system_function(name)**                     |             删除指定名称下已注册的临时系统函数。             | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.drop_temporary_system_function) |

**废弃的 APIs**

| APIs                                                  |                             描述                             |                             文档                             |
| :---------------------------------------------------- | :----------------------------------------------------------: | :----------------------------------------------------------: |
| **register_function(name, function)**                 | 注册一个 Python 用户自定义函数，并为其指定一个唯一的名称。 若已有与该名称相同的用户自定义函数，则替换之。 它可以通过 **create_temporary_system_function** 来替换。 | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.register_function) |
| **register_java_function(name, function_class_name)** | 注册一个 Java 用户自定义函数，并为其指定一个唯一的名称。 若已有与该名称相同的用户自定义函数，则替换之。 它可以通过 **create_java_temporary_system_function** 来替换。 | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.register_java_function) |

### 依赖管理

这些 APIs 用来管理 Python UDFs 所需要的 Python 依赖。 更多细节可查阅 [依赖管理](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/dependency_management.html#python-dependency-in-python-program)。

| APIs                                                         |                             描述                             |                             文档                             |
| :----------------------------------------------------------- | :----------------------------------------------------------: | :----------------------------------------------------------: |
| **add_python_file(file_path)**                               | 添加 Python 依赖，可以是 Python 文件，Python 包或者本地目录。 它们将会被添加到 Python UDF 工作程序的 PYTHONPATH 中。 | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.add_python_file) |
| **set_python_requirements(requirements_file_path, requirements_cache_dir=None)** | 指定一个 requirements.txt 文件，该文件定义了第三方依赖关系。 这些依赖项将安装到一个临时 catalog 中，并添加到 Python UDF 工作程序的 PYTHONPATH 中。 | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.set_python_requirements) |
| **add_python_archive(archive_path, target_dir=None)**        | 添加 Python 归档文件。该文件将被解压到 Python UDF 程序的工作目录中。 | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.add_python_archive) |

### 配置

| APIs             |                             描述                             |                             文档                             |
| :--------------- | :----------------------------------------------------------: | :----------------------------------------------------------: |
| **get_config()** | 返回 table config，可以通过 table config 来定义 Table API 的运行时行为。 你可以在 [配置](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html) 和 [Python 配置](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/python_config.html) 中找到所有可用的配置选项。  下面的代码示例展示了如何通过这个 API 来设置配置选项：`# set the parallelism to 8 table_env.get_config().get_configuration().set_string(    "parallelism.default", "8")` | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.get_config) |

### Catalog APIs

这些 APIs 用于访问 catalog 和模块。你可以在 [模块](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/modules.html) 和 [catalog](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/catalogs.html) 文档中找到更详细的介绍。

| APIs                                        |                             描述                             |                             文档                             |
| :------------------------------------------ | :----------------------------------------------------------: | :----------------------------------------------------------: |
| **register_catalog(catalog_name, catalog)** |                注册具有唯一名称的 `Catalog`。                | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.register_catalog) |
| **get_catalog(catalog_name)**               |          通过指定的名称来获得已注册的 `Catalog` 。           | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.get_catalog) |
| **use_catalog(catalog_name)**               | 将当前目录设置为所指定的 catalog。 它也将默认数据库设置为所指定 catalog 的默认数据库。 | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.use_catalog) |
| **get_current_catalog()**                   |              获取当前会话默认的 catalog 名称。               | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.get_current_catalog) |
| **get_current_database()**                  |           获取正在运行会话中的当前默认数据库名称。           | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.get_current_database) |
| **use_database(database_name)**             | 设置当前默认的数据库。 它必须存在当前 catalog 中。 当寻找未限定的对象名称时，该路径将被用作默认路径。 | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.use_database) |
| **load_module(module_name, module)**        |   加载给定名称的 `Module`。 模块将按照加载的顺序进行保存。   | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.load_module) |
| **unload_module(module_name)**              |                  卸载给定名称的 `Module`。                   | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.unload_module) |
| **list_catalogs()**                         |        获取在这个环境中注册的所有 catalog 目录名称。         | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.list_catalogs) |
| **list_modules()**                          |             获取在这个环境中注册的所有模块名称。             | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.list_modules) |
| **list_databases()**                        |            获取当前 catalog 中所有数据库的名称。             | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.list_databases) |
| **list_tables()**                           | 获取当前 catalog 的当前数据库下的所有表和临时表的名称。 它可以返回永久和临时的表和视图。 | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.list_tables) |
| **list_views()**                            | 获取当前 catalog 的当前数据库中的所有临时表名称。 它既可以返回永久的也可以返回临时的临时表。 | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.list_views) |
| **list_user_defined_functions()**           |       获取在该环境中已注册的所有用户自定义函数的名称。       | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.list_user_defined_functions) |
| **list_functions()**                        |                 获取该环境中所有函数的名称。                 | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.list_functions) |
| **list_temporary_tables()**                 | 获取当前命名空间（当前 catalog 的当前数据库）中所有可用的表和临时表名称。 | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.list_temporary_tables) |
| **list_temporary_views()**                  | 获取当前命名空间（当前 catalog 的当前数据库）中所有可用的临时表名称。 | [链接](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.TableEnvironment.list_temporary_views) |

## Statebackend，Checkpoint 以及重启策略

在 Flink 1.10 之前，你可以通过 `StreamExecutionEnvironment` 来配置 statebackend，checkpointing 以及重启策略。 现在你可以通过在 `TableConfig` 中，通过设置键值选项来配置它们，更多详情可查阅 [容错](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#fault-tolerance)，[State Backends](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#checkpoints-and-state-backends) 以及 [Checkpointing](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/config.html#checkpointing)。

下面代码示例展示了如何通过 Table API 来配置 statebackend，checkpoint 以及重启策略：

```
# 设置重启策略为 "fixed-delay"
table_env.get_config().get_configuration().set_string("restart-strategy", "fixed-delay")
table_env.get_config().get_configuration().set_string("restart-strategy.fixed-delay.attempts", "3")
table_env.get_config().get_configuration().set_string("restart-strategy.fixed-delay.delay", "30s")

# 设置 checkpoint 模式为 EXACTLY_ONCE
table_env.get_config().get_configuration().set_string("execution.checkpointing.mode", "EXACTLY_ONCE")
table_env.get_config().get_configuration().set_string("execution.checkpointing.interval", "3min")

# 设置 statebackend 类型为 "rocksdb"，其他可选项有 "filesystem" 和 "jobmanager"
# 你也可以将这个属性设置为 StateBackendFactory 的完整类名
# e.g. org.apache.flink.contrib.streaming.state.RocksDBStateBackendFactory
table_env.get_config().get_configuration().set_string("state.backend", "rocksdb")

# 设置 RocksDB statebackend 所需要的 checkpoint 目录
table_env.get_config().get_configuration().set_string("state.checkpoints.dir", "file:///tmp/checkpoints/")
```