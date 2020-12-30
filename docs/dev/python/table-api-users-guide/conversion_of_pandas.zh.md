# PyFlink Table 和 Pandas DataFrame 互转

PyFlink支持PyFlink表和Pandas DataFrame之间进行转换。

- [将Pandas DataFrame转换为PyFlink表](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/conversion_of_pandas.html#将pandas-dataframe转换为pyflink表)
- [将PyFlink表转换为Pandas DataFrame](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/table-api-users-guide/conversion_of_pandas.html#将pyflink表转换为pandas-dataframe)

## 将Pandas DataFrame转换为PyFlink表

PyFlink支持将Pandas DataFrame转换成PyFlink表。在内部实现上，会在客户端将Pandas DataFrame序列化成Arrow列存格式，序列化后的数据 在作业执行期间，在Arrow源中会被反序列化，并进行处理。Arrow源除了可以用在批作业中外，还可以用于流作业，它将正确处理检查点并提供恰好一次的保证。

以下示例显示如何从Pandas DataFrame创建PyFlink表：

```
import pandas as pd
import numpy as np

# 创建一个Pandas DataFrame
pdf = pd.DataFrame(np.random.rand(1000, 2))

# 由Pandas DataFrame创建PyFlink表
table = t_env.from_pandas(pdf)

# 由Pandas DataFrame创建指定列名的PyFlink表
table = t_env.from_pandas(pdf, ['f0', 'f1'])

# 由Pandas DataFrame创建指定列类型的PyFlink表
table = t_env.from_pandas(pdf, [DataTypes.DOUBLE(), DataTypes.DOUBLE()])

# 由Pandas DataFrame创建列名和列类型的PyFlink表
table = t_env.from_pandas(pdf,
                          DataTypes.ROW([DataTypes.FIELD("f0", DataTypes.DOUBLE()),
                                         DataTypes.FIELD("f1", DataTypes.DOUBLE())])
```

## 将PyFlink表转换为Pandas DataFrame

除此之外，还支持将PyFlink表转换为Pandas DataFrame。在内部实现上，它将执行表的计算逻辑，得到物化之后的表的执行结果，并 在客户端将其序列化为Arrow列存格式，最大Arrow批处理大小 由配置选项[python.fn-execution.arrow.batch.size](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/python_config.html#python-fn-execution-arrow-batch-size) 确定。 序列化后的数据将被转换为Pandas DataFrame。这意味着需要把表的内容收集到客户端，因此在调用此函数之前，请确保表的内容可以容纳在内存中。 可以通过[Table.limit](https://ci.apache.org/projects/flink/flink-docs-release-1.12/api/python/pyflink.table.html#pyflink.table.Table.limit)，设置收集到客户端的数据的条数。

以下示例显示了如何将PyFlink表转换为Pandas DataFrame：

```
import pandas as pd
import numpy as np

# 创建PyFlink Table
pdf = pd.DataFrame(np.random.rand(1000, 2))
table = t_env.from_pandas(pdf, ["a", "b"]).filter(col('a') > 0.5)

# 转换PyFlink Table为Pandas DataFrame
pdf = table.limit(100).to_pandas()
```