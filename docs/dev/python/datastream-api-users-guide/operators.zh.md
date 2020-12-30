# 算子

用户通过算子能将一个或多个 DataStream 转换成新的 DataStream，在应用程序中可以将多个数据转换算子合并成一个复杂的数据流拓扑。



# 数据流转换

Python Flink DataStream 程序主要是通过实现各种算子完成对 DataStream 数据的转换（如 mapping，filtering， reducing等等）。请访问 [算子](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/stream/operators/?code_tab=python)页了解 Python DataStream API 目前已支持的各种算子。



# 算子函数接口

在 Python DataStream API 中，大部分的算子需要用户实现自定义函数作为算子接口的输入，接下来的内容将描述几种实现自定义函数的方式：



## 实现方法接口

Python DataStream API 给各种算子提供了函数接口，用户可以定义接口的实现，并作为参数传递给算子。例如， `MapFunction` 对应 `map` 转换算子， `FilterFunction` 对应 `filter` 算子等等。下面以 MapFunction 接口为例：



```
# Implementing MapFunction
class MyMapFunction(MapFunction):
    
    def map(self, value):
        return value + 1
        
data_stream = env.from_collection([1, 2, 3, 4, 5], type_info=Types.INT())
mapped_stream = data_stream.map(MyMapFunction(), output_type=Types.INT())
```



**注意** 在 Python DataStream API, 用户能指定自定义函数的输出数据类型，如若不指定，将默认使用 `Types.PICKLED_BYTE_ARRAY` 数据类型，数据通过 pickle 序列化成字节数组发往下游算子。更多细节请访问 [数据类型](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/datastream-api-users-guide/data_types.html)页.



## Lambda 函数

如此前的例子中所示，大部分算子 API 也能以 lambda 函数的形式定义具体的数据转换逻辑：



```
data_stream = env.from_collection([1, 2, 3, 4, 5], type_info=Types.INT())
mapped_stream = data_stream.map(lambda x: x + 1, output_type=Types.INT())
```



**注意** ConnectedStream.map() 和 ConnectedStream.flat_map() 算子目前只支持实现 CoMapFunction 接口和 CoFlatMapFunction 接口。



## Python 函数

用户也可以直接通过实现一个 Python 函数来定义具体的数据转换逻辑并传递给算子 API ：



```
def my_map_func(value):
    return value + 1

data_stream = env.from_collection([1, 2, 3, 4, 5], type_info=Types.INT())
mapped_stream = data_stream.map(my_map_func, output_type=Types.INT())
```