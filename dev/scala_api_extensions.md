# Scala API Extensions

为了在Scala和Java api之间保持相当程度的一致性，在批处理和流处理的标准api中省略了一些允许Scala具有高级表达能力的特性。

如果您想享受完整的Scala体验，您可以选择选择通过隐式转换增强Scala API的扩展。

要使用所有可用的扩展，您只需为`DataSet API`添加一个简单的导入

```scala
import org.apache.flink.api.scala.extensions._
```

或 `DataStream API`
```scala
import org.apache.flink.streaming.api.scala.extensions._
```

或者，您可以导入单独的扩展`a-là-carte`来只使用您喜欢的扩展。

## Accept partial functions

通常，DataSet和DataStream api都不接受用于解构元组、case类或集合的匿名模式匹配函数，如下所示
```scala
val data: DataSet[(Int, String, Double)] = // [...]
data.map {
  case (id, name, temperature) => // [...]
  // The previous line causes the following compilation error:
  // "The argument types of an anonymous function must be fully known. (SLS 8.5)"
}
```

这个扩展在DataSet和DataStream Scala API中引入了新的方法，这些方法在扩展的API中具有一对一的对应关系。这些委托方法确实支持匿名模式匹配函数。

### DataSet API
```
Method                        Original                           Example
mapWith                       map (DataSet)                      data.mapWith {
                                                                   case (_, value) => value.toString
                                                                 }
                                                                 
mapPartitionWith              mapPartition (DataSet)             data.mapPartitionWith {
                                                                   case head #:: _ => head
                                                                 }
                                                                 
flatMapWith                   flatMap (DataSet)                  data.flatMapWith {
                                                                   case (_, name, visitTimes) => visitTimes.map(name -> _)
                                                                 }
                                                                 
filterWith                    filter (DataSet)                   data.filterWith {
                                                                   case Train(_, isOnTime) => isOnTime
                                                                 }
                                                                 
reduceWith                    reduce (DataSet, GroupedDataSet)   data.reduceWith {
                                                                   case ((_, amount1), (_, amount2)) => amount1 + amount2
                                                                 }
                                                                 
reduceGroupWith               reduceGroup (GroupedDataSet)       data.reduceGroupWith {
                                                                   case id #:: value #:: _ => id -> value
                                                                 }
                                                                 
groupingBy                    groupBy (DataSet)                  data.groupingBy {
                                                                   case (id, _, _) => id
                                                                 }
                                                                 
sortGroupWith                 sortGroup (GroupedDataSet)         grouped.sortGroupWith(Order.ASCENDING) {
                                                                   case House(_, value) => value
                                                                 }
                                                                 
combineGroupWith              combineGroup (GroupedDataSet)      grouped.combineGroupWith {
                                                                   case header #:: amounts => amounts.sum
                                                                 }
                                                                 
projecting                    apply (JoinDataSet, CrossDataSet)  data1.join(data2).
                                                                   whereClause(case (pk, _) => pk).
                                                                   isEqualTo(case (_, fk) => fk).
                                                                   projecting {
                                                                     case ((pk, tx), (products, fk)) => tx -> products
                                                                   }
                                                                   
                                                                 data1.cross(data2).projecting {
                                                                   case ((a, _), (_, b) => a -> b
                                                                 }
                                                                 
projecting                    apply (CoGroupDataSet)             data1.coGroup(data2).
                                                                   whereClause(case (pk, _) => pk).
                                                                   isEqualTo(case (_, fk) => fk).
                                                                   projecting {
                                                                     case (head1 #:: _, head2 #:: _) => head1 -> head2
                                                                   }
                                                                 }
```


### DataStream API
```
Method	                      Original	                             Example
mapWith	                      map (DataStream)	                     data.mapWith {
		                                                               case (_, value) => value.toString
		                                                             }
		                                                             
flatMapWith	                  flatMap (DataStream)	                 data.flatMapWith {
		                                                               case (_, name, visits) => visits.map(name -> _)
		                                                             }
		                                                             
filterWith	                  filter (DataStream)	                 data.filterWith {
		                                                               case Train(_, isOnTime) => isOnTime
		                                                             }
		                                                             
keyingBy	                  keyBy (DataStream)	                 data.keyingBy {
		                                                               case (id, _, _) => id
		                                                             }
		                                                             
mapWith	                      map (ConnectedDataStream)	             data.mapWith(
		                                                               map1 = case (_, value) => value.toString,
		                                                               map2 = case (_, _, value, _) => value + 1
		                                                             )
		                                                             
flatMapWith	                  flatMap (ConnectedDataStream)	         data.flatMapWith(
		                                                               flatMap1 = case (_, json) => parse(json),
		                                                               flatMap2 = case (_, _, json, _) => parse(json)
		                                                             )
		                                                             
keyingBy	                  keyBy (ConnectedDataStream)	         data.keyingBy(
		                                                               key1 = case (_, timestamp) => timestamp,
		                                                               key2 = case (id, _, _) => id
		                                                             )
		                                                             
reduceWith	                  reduce (KeyedStream, WindowedStream)	 data.reduceWith {
		                                                               case ((_, sum1), (_, sum2) => sum1 + sum2
		                                                             }
		                                                             
foldWith	                  fold (KeyedStream, WindowedStream)	 data.foldWith(User(bought = 0)) {
		                                                               case (User(b), (_, items)) => User(b + items.size)
		                                                             }
		                                                             
applyWith	                  apply (WindowedStream)	             data.applyWith(0)(
		                                                               foldFunction = case (sum, amount) => sum + amount
		                                                               windowFunction = case (k, w, sum) => // [...]
                                                             	     )
                                                             		
projecting	                  apply (JoinedStream)	                 data1.join(data2).
		                                                               whereClause(case (pk, _) => pk).
		                                                               isEqualTo(case (_, fk) => fk).
		                                                               projecting {
		                                                                 case ((pk, tx), (products, fk)) => tx -> products
		                                                             }
```

有关每个方法的语义的更多信息，请参阅[DataSet](../dev/batch/index.html) 和 [DataStream](../dev/datastream_api.md) API文档。

要完全使用此扩展，可以添加以下导入:

```scala
import org.apache.flink.api.scala.extensions.acceptPartialFunctions
```

用于 `DataSet` 扩展：
```scala
import org.apache.flink.streaming.api.scala.extensions.acceptPartialFunctions
```

下面的代码片段展示了如何结合使用这些扩展方法(与DataSet API)的最小示例:

```scala
object Main {
  import org.apache.flink.api.scala.extensions._
  case class Point(x: Double, y: Double)
  def main(args: Array[String]): Unit = {
    val env = ExecutionEnvironment.getExecutionEnvironment
    val ds = env.fromElements(Point(1, 2), Point(3, 4), Point(5, 6))
    ds.filterWith {
      case Point(x, _) => x > 1
    }.reduceWith {
      case (Point(x1, y1), (Point(x2, y2))) => Point(x1 + y1, x2 + y2)
    }.mapWith {
      case Point(x, y) => (x, y)
    }.flatMapWith {
      case (x, y) => Seq("x" -> x, "y" -> y)
    }.groupingBy {
      case (id, value) => id
    }
  }
}
```