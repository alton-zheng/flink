# Java Lambda 表达式
Java 8引入了一些新的语言特性，旨在更快更清晰地编码。它具有最重要的特性，即所谓的“Lambda表达式”，为函数式编程打开了大门。Lambda表达式允许以一种直接的方式实现和传递函数，而不需要声明额外的(匿名的)类。

但是，当lambda表达式使用Java泛型时，您需要显式声明类型信息，Flink支持对Java API的所有操作符使用lambda表达式。

本文档展示了如何使用lambda表达式，并描述了当前的限制。有关Flink API的一般介绍，请参阅[编程指南](../dev/api_concepts.md)

## Examples and Limitations
下面的示例演示了如何实现一个简单的内联map()函数，该函数使用lambda表达式对输入进行平方。map()函数的输入i和输出参数的类型不需要声明，因为它们是由Java编译器推断的。

```java
env.fromElements(1, 2, 3)
// returns the squared i
.map(i -> i*i)
.print();
```

Flink可以从方法签名OUT map(IN value)的实现中自动提取结果类型信息，因为OUT不是通用的，而是整数。

不幸的是，带有签名void flatMap(值为Collector<OUT> OUT)的flatMap()等函数被Java编译器编译成void flatMap(值为Collector OUT)。这使得Flink不可能自动推断输出类型的类型信息。

Flink很可能会抛出一个类似于下面的异常:

```log
org.apache.flink.api.common.functions.InvalidTypesException: The generic type parameters of 'Collector' are missing.
    In many cases lambda methods don't provide enough information for automatic type extraction when Java generics are involved.
    An easy workaround is to use an (anonymous) class instead that implements the 'org.apache.flink.api.common.functions.FlatMapFunction' interface.
    Otherwise the type has to be specified explicitly using type information.
```

在这种情况下，需要显式地指定类型信息，否则输出将被视为类型对象，从而导致无效的序列化。

```java
import org.apache.flink.api.common.typeinfo.Types;
import org.apache.flink.api.java.DataSet;
import org.apache.flink.util.Collector;

DataSet<Integer> input = env.fromElements(1, 2, 3);

// collector type must be declared
input.flatMap((Integer number, Collector<String> out) -> {
    StringBuilder builder = new StringBuilder();
    for(int i = 0; i < number; i++) {
        builder.append("a");
        out.collect(builder.toString());
    }
})
// provide type information explicitly
.returns(Types.STRING)
// prints "a", "a", "aa", "a", "aa", "aaa"
.print();
```

使用具有泛型返回类型的map()函数时也会出现类似的问题。在下面的示例中，一个方法签名 `Tuple2<Integer, Integer> map(Integer value)`被擦除为`Tuple2 map(Integer value)`。

```java
import org.apache.flink.api.common.functions.MapFunction;
import org.apache.flink.api.java.tuple.Tuple2;

env.fromElements(1, 2, 3)
    .map(i -> Tuple2.of(i, i))    // no information about fields of Tuple2
    .print();
```

一般来说，这些问题可以通过多种方式解决:

```java
import org.apache.flink.api.common.typeinfo.Types;
import org.apache.flink.api.java.tuple.Tuple2;

// use the explicit ".returns(...)"
env.fromElements(1, 2, 3)
    .map(i -> Tuple2.of(i, i))
    .returns(Types.TUPLE(Types.INT, Types.INT))
    .print();

// use a class instead
env.fromElements(1, 2, 3)
    .map(new MyTuple2Mapper())
    .print();

public static class MyTuple2Mapper extends MapFunction<Integer, Tuple2<Integer, Integer>> {
    @Override
    public Tuple2<Integer, Integer> map(Integer i) {
        return Tuple2.of(i, i);
    }
}

// use an anonymous class instead
env.fromElements(1, 2, 3)
    .map(new MapFunction<Integer, Tuple2<Integer, Integer>> {
        @Override
        public Tuple2<Integer, Integer> map(Integer i) {
            return Tuple2.of(i, i);
        }
    })
    .print();

// or in this example use a tuple subclass instead
env.fromElements(1, 2, 3)
    .map(i -> new DoubleTuple(i, i))
    .print();

public static class DoubleTuple extends Tuple2<Integer, Integer> {
    public DoubleTuple(int f0, int f1) {
        this.f0 = f0;
        this.f1 = f1;
    }
}
```
