## Python API 教程

在该教程中，我们会从零开始，介绍如何创建一个Flink Python项目及运行Python Table API程序。

---
### 创建一个Python Table API项目
首先，你可以使用你最熟悉的IDE，创建一个Python项目。然后，你需要安装PyFlink包， 请参考构建PyFlink了解详细信息。

---
### 编写一个Flink Python Table API程序
编写Flink Python Table API程序的第一步是创建BatchTableEnvironment (或者StreamTableEnvironment，如果你要创建一个流式作业)。这是Python Table API作业的入口类。
```python
exec_env = ExecutionEnvironment.get_execution_environment()
exec_env.set_parallelism(1)
t_config = TableConfig()
t_env = BatchTableEnvironment.create(exec_env, t_config)
```

`ExecutionEnvironment` (或者`StreamExecutionEnvironment`，如果你要创建一个流式作业) 可以用来设置执行参数，比如重启策略，缺省并发值等。

TableConfig可以用来设置缺省的catalog名字，自动生成代码时方法大小的阈值等.

接下来，我们将介绍如何创建源表和结果表。
```python
t_env.connect(FileSystem().path('/tmp/input')) \
    .with_format(OldCsv()
                 .line_delimiter(' ')
                 .field('word', DataTypes.STRING())) \
    .with_schema(Schema()
                 .field('word', DataTypes.STRING())) \
    .register_table_source('mySource')

t_env.connect(FileSystem().path('/tmp/output')) \
    .with_format(OldCsv()
                 .field_delimiter('\t')
                 .field('word', DataTypes.STRING())
                 .field('count', DataTypes.BIGINT())) \
    .with_schema(Schema()
                 .field('word', DataTypes.STRING())
                 .field('count', DataTypes.BIGINT())) \
    .register_table_sink('mySink')
```

上面的程序展示了如何创建及在ExecutionEnvironment中注册表名分别为mySource和mySink的表。 其中，源表mySource有一列: word，该表代表了从输入文件/tmp/input中读取的单词； 结果表mySink有两列: word和count，该表会将计算结果输出到文件/tmp/output中，字段之间使用\t作为分隔符。

接下来，我们介绍如何创建一个作业：该作业读取表mySource中的数据，进行一些变换，然后将结果写入表mySink。
```python
t_env.scan('mySource') \
    .group_by('word') \
    .select('word, count(1)') \
    .insert_into('mySink')
```

最后，需要做的就是启动Flink Python Table API作业。上面所有的操作，比如创建源表 进行变换以及写入结果表的操作都只是构建作业逻辑图，只有当t_env.execute(job_name)被调用的时候， 作业才会被真正提交到集群或者本地进行执行。
```python
t_env.execute("python_job")
```

该教程的完整代码如下:
```python
from pyflink.dataset import ExecutionEnvironment
from pyflink.table import TableConfig, DataTypes, BatchTableEnvironment
from pyflink.table.descriptors import Schema, OldCsv, FileSystem

exec_env = ExecutionEnvironment.get_execution_environment()
exec_env.set_parallelism(1)
t_config = TableConfig()
t_env = BatchTableEnvironment.create(exec_env, t_config)

t_env.connect(FileSystem().path('/tmp/input')) \
    .with_format(OldCsv()
                 .line_delimiter(' ')
                 .field('word', DataTypes.STRING())) \
    .with_schema(Schema()
                 .field('word', DataTypes.STRING())) \
    .register_table_source('mySource')

t_env.connect(FileSystem().path('/tmp/output')) \
    .with_format(OldCsv()
                 .field_delimiter('\t')
                 .field('word', DataTypes.STRING())
                 .field('count', DataTypes.BIGINT())) \
    .with_schema(Schema()
                 .field('word', DataTypes.STRING())
                 .field('count', DataTypes.BIGINT())) \
    .register_table_sink('mySink')

t_env.scan('mySource') \
    .group_by('word') \
    .select('word, count(1)') \
    .insert_into('mySink')

t_env.execute("python_job")
```

--- 
### 执行一个Flink Python Table API程序
可以在IDE中或者命令行中运行作业（假设作业名为WordCount.py）：
```bash
$ python WordCount.py
```

上述命令会构建Python Table API程序，并在本地mini cluster中运行。如果想将作业提交到远端集群执行， 可以参考作业提交示例。

上述教程介绍了如何编写并运行一个Flink Python Table API程序，如果想了解Flink Python Table API 的更多信息，可以参考Flink Python Table API文档。