# 表中的模式检测

搜索一组事件模式（event pattern）是一种常见的用例，尤其是在数据流情景中。Flink 提供[复杂事件处理（CEP）库](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/libs/cep.html)，该库允许在事件流中进行模式检测。此外，Flink 的 SQL API 提供了一种关系式的查询表达方式，其中包含大量内置函数和基于规则的优化，可以开箱即用。

2016 年 12 月，国际标准化组织（ISO）发布了新版本的 SQL 标准，其中包括在 *SQL 中的行模式识别（Row Pattern Recognition in SQL）*([ISO/IEC TR 19075-5:2016](https://standards.iso.org/ittf/PubliclyAvailableStandards/c065143_ISO_IEC_TR_19075-5_2016.zip))。它允许 Flink 使用 `MATCH_RECOGNIZE` 子句融合 CEP 和 SQL API，以便在 SQL 中进行复杂事件处理。

`MATCH_RECOGNIZE` 子句启用以下任务：

- 使用 `PARTITION BY` 和 `ORDER BY` 子句对数据进行逻辑分区和排序。
- 使用 `PATTERN` 子句定义要查找的行模式。这些模式使用类似于正则表达式的语法。
- 在 `DEFINE` 子句中指定行模式变量的逻辑组合。
- measures 是指在 `MEASURES` 子句中定义的表达式，这些表达式可用于 SQL 查询中的其他部分。

下面的示例演示了基本模式识别的语法：

```
SELECT T.aid, T.bid, T.cid
FROM MyTable
    MATCH_RECOGNIZE (
      PARTITION BY userid
      ORDER BY proctime
      MEASURES
        A.id AS aid,
        B.id AS bid,
        C.id AS cid
      PATTERN (A B C)
      DEFINE
        A AS name = 'a',
        B AS name = 'b',
        C AS name = 'c'
    ) AS T
```

本页将更详细地解释每个关键字，并演示说明更复杂的示例。

**注意** Flink 的 `MATCH_RECOGNIZE` 子句实现是一个完整标准子集。仅支持以下部分中记录的功能。基于社区反馈，可能会支持其他功能，请查看[已知的局限](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#known-limitations)。

- 介绍和示例
  - [安装指南](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#安装指南)
  - [SQL 语义](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#sql-语义)
  - [示例](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#示例)
- [分区](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#分区)
- [事件顺序](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#事件顺序)
- Define & Measures
  - [Aggregations](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#aggregations)
- 定义模式
  - [贪婪量词和勉强量词](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#贪婪量词和勉强量词)
  - [时间约束](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#时间约束)
- [输出方式](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#输出方式)
- 模式导航
  - [引用模式变量](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#引用模式变量)
  - [Logical Offsets](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#logical-offsets)
- [匹配后的策略](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#匹配后的策略)
- [时间属性](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#时间属性)
- [控制内存消耗](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#控制内存消耗)
- [已知的局限](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#已知的局限)



## 介绍和示例



### 安装指南

模式识别特性使用 Apache Flink 内部的 CEP 库。为了能够使用 `MATCH_RECOGNIZE` 子句，需要将库作为依赖项添加到 Maven 项目中。

```
<dependency>
  <groupId>org.apache.flink</groupId>
  <artifactId>flink-cep_2.11</artifactId>
  <version>1.12.0</version>
</dependency>
```

或者，也可以将依赖项添加到集群的 classpath（查看 [dependency section](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/project-configuration.html) 获取更多相关依赖信息）。

如果你想在 [SQL Client](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/sqlClient.html) 中使用 `MATCH_RECOGNIZE` 子句，你无需执行任何操作，因为默认情况下包含所有依赖项。



### SQL 语义

每个 `MATCH_RECOGNIZE` 查询都包含以下子句：

- [PARTITION BY](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#partitioning) - 定义表的逻辑分区；类似于 `GROUP BY` 操作。
- [ORDER BY](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#order-of-events) - 指定传入行的排序方式；这是必须的，因为模式依赖于顺序。
- [MEASURES](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#define--measures) - 定义子句的输出；类似于 `SELECT` 子句。
- [ONE ROW PER MATCH](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#output-mode) - 输出方式，定义每个匹配项应产生多少行。
- [AFTER MATCH SKIP](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#after-match-strategy) - 指定下一个匹配的开始位置；这也是控制单个事件可以属于多少个不同匹配项的方法。
- [PATTERN](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#defining-a-pattern) - 允许使用类似于 *正则表达式* 的语法构造搜索的模式。
- [DEFINE](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#define--measures) - 本部分定义了模式变量必须满足的条件。

**注意** 目前，`MATCH_RECOGNIZE` 子句只能应用于[追加表](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/dynamic_tables.html#update-and-append-queries)。此外，它也总是生成一个追加表。



### 示例

对于我们的示例，我们假设已经注册了一个表 `Ticker`。该表包含特定时间点的股票价格。

这张表的 schema 如下：

```
Ticker
     |-- symbol: String                           # 股票的代号
     |-- price: Long                              # 股票的价格
     |-- tax: Long                                # 股票应纳税额
     |-- rowtime: TimeIndicatorTypeInfo(rowtime)  # 更改这些值的时间点
```

为了简化，我们只考虑单个股票 `ACME` 的传入数据。Ticker 可以类似于下表，其中的行是连续追加的。

```
symbol         rowtime         price    tax
======  ====================  ======= =======
'ACME'  '01-Apr-11 10:00:00'   12      1
'ACME'  '01-Apr-11 10:00:01'   17      2
'ACME'  '01-Apr-11 10:00:02'   19      1
'ACME'  '01-Apr-11 10:00:03'   21      3
'ACME'  '01-Apr-11 10:00:04'   25      2
'ACME'  '01-Apr-11 10:00:05'   18      1
'ACME'  '01-Apr-11 10:00:06'   15      1
'ACME'  '01-Apr-11 10:00:07'   14      2
'ACME'  '01-Apr-11 10:00:08'   24      2
'ACME'  '01-Apr-11 10:00:09'   25      2
'ACME'  '01-Apr-11 10:00:10'   19      1
```

现在的任务是找出一个单一股票价格不断下降的时期。为此，可以编写如下查询：

```
SELECT *
FROM Ticker
    MATCH_RECOGNIZE (
        PARTITION BY symbol
        ORDER BY rowtime
        MEASURES
            START_ROW.rowtime AS start_tstamp,
            LAST(PRICE_DOWN.rowtime) AS bottom_tstamp,
            LAST(PRICE_UP.rowtime) AS end_tstamp
        ONE ROW PER MATCH
        AFTER MATCH SKIP TO LAST PRICE_UP
        PATTERN (START_ROW PRICE_DOWN+ PRICE_UP)
        DEFINE
            PRICE_DOWN AS
                (LAST(PRICE_DOWN.price, 1) IS NULL AND PRICE_DOWN.price < START_ROW.price) OR
                    PRICE_DOWN.price < LAST(PRICE_DOWN.price, 1),
            PRICE_UP AS
                PRICE_UP.price > LAST(PRICE_DOWN.price, 1)
    ) MR;
```

此查询将 `Ticker` 表按照 `symbol` 列进行分区并按照 `rowtime` 属性进行排序。

`PATTERN` 子句指定我们对以下模式感兴趣：该模式具有开始事件 `START_ROW`，然后是一个或多个 `PRICE_DOWN` 事件，并以 `PRICE_UP` 事件结束。如果可以找到这样的模式，如 `AFTER MATCH SKIP TO LAST` 子句所示，则从最后一个 `PRICE_UP` 事件开始寻找下一个模式匹配。

`DEFINE` 子句指定 `PRICE_DOWN` 和 `PRICE_UP` 事件需要满足的条件。尽管不存在 `START_ROW` 模式变量，但它具有一个始终被评估为 `TRUE` 隐式条件。

模式变量 `PRICE_DOWN` 定义为价格小于满足 `PRICE_DOWN` 条件的最后一行。对于初始情况或没有满足 `PRICE_DOWN` 条件的最后一行时，该行的价格应小于该模式中前一行（由 `START_ROW` 引用）的价格。

模式变量 `PRICE_UP` 定义为价格大于满足 `PRICE_DOWN` 条件的最后一行。

此查询为股票价格持续下跌的每个期间生成摘要行。

在查询的 `MEASURES` 子句部分定义确切的输出行信息。输出行数由 `ONE ROW PER MATCH` 输出方式定义。

```
 symbol       start_tstamp       bottom_tstamp         end_tstamp
=========  ==================  ==================  ==================
ACME       01-APR-11 10:00:04  01-APR-11 10:00:07  01-APR-11 10:00:08
```

该行结果描述了从 `01-APR-11 10:00:04` 开始的价格下跌期，在 `01-APR-11 10:00:07` 达到最低价格，到 `01-APR-11 10:00:08` 再次上涨。



## 分区

可以在分区数据中寻找模式，例如单个股票行情或特定用户的趋势。这可以用 `PARTITION BY` 子句来表示。该子句类似于对 aggregation 使用 `GROUP BY`。

**注意** 强烈建议对传入的数据进行分区，否则 `MATCH_RECOGNIZE` 子句将被转换为非并行算子，以确保全局排序。



## 事件顺序

Apache Flink 可以根据时间（[处理时间或者事件时间](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/time_attributes.html)）进行模式搜索。

如果是事件时间，则在将事件传递到内部模式状态机之前对其进行排序。所以，无论行添加到表的顺序如何，生成的输出都是正确的。而模式是按照每行中所包含的时间指定顺序计算的。

`MATCH_RECOGNIZE` 子句假定升序的 [时间属性](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/time_attributes.html) 是 `ORDER BY` 子句的第一个参数。

对于示例 `Ticker` 表，诸如 `ORDER BY rowtime ASC, price DESC` 的定义是有效的，但 `ORDER BY price, rowtime` 或者 `ORDER BY rowtime DESC, price ASC` 是无效的。

## Define & Measures

`DEFINE` 和 `MEASURES` 关键字与简单 SQL 查询中的 `WHERE` 和 `SELECT` 子句具有相近的含义。

`MEASURES` 子句定义匹配模式的输出中要包含哪些内容。它可以投影列并定义表达式进行计算。产生的行数取决于[输出方式](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#output-mode)设置。

`DEFINE` 子句指定行必须满足的条件才能被分类到相应的[模式变量](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#defining-a-pattern)。如果没有为模式变量定义条件，则将对每一行使用计算结果为 `true` 的默认条件。

有关在这些子句中可使用的表达式的更详细的说明，请查看[事件流导航](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#pattern-navigation)部分。

### Aggregations

Aggregations 可以在 `DEFINE` 和 `MEASURES` 子句中使用。支持[内置函数](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/functions/systemFunctions.html)和[用户自定义函数](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/functions/udfs.html)。

对相应匹配项的行子集可以使用 Aggregate functions。请查看[事件流导航](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#pattern-navigation)部分以了解如何计算这些子集。

下面这个示例的任务是找出股票平均价格没有低于某个阈值的最长时间段。它展示了 `MATCH_RECOGNIZE` 在 aggregation 中的可表达性。可以使用以下查询执行此任务：

```
SELECT *
FROM Ticker
    MATCH_RECOGNIZE (
        PARTITION BY symbol
        ORDER BY rowtime
        MEASURES
            FIRST(A.rowtime) AS start_tstamp,
            LAST(A.rowtime) AS end_tstamp,
            AVG(A.price) AS avgPrice
        ONE ROW PER MATCH
        AFTER MATCH SKIP PAST LAST ROW
        PATTERN (A+ B)
        DEFINE
            A AS AVG(A.price) < 15
    ) MR;
```

给定此查询和以下输入值：

```
symbol         rowtime         price    tax
======  ====================  ======= =======
'ACME'  '01-Apr-11 10:00:00'   12      1
'ACME'  '01-Apr-11 10:00:01'   17      2
'ACME'  '01-Apr-11 10:00:02'   13      1
'ACME'  '01-Apr-11 10:00:03'   16      3
'ACME'  '01-Apr-11 10:00:04'   25      2
'ACME'  '01-Apr-11 10:00:05'   2       1
'ACME'  '01-Apr-11 10:00:06'   4       1
'ACME'  '01-Apr-11 10:00:07'   10      2
'ACME'  '01-Apr-11 10:00:08'   15      2
'ACME'  '01-Apr-11 10:00:09'   25      2
'ACME'  '01-Apr-11 10:00:10'   25      1
'ACME'  '01-Apr-11 10:00:11'   30      1
```

只要事件的平均价格不超过 `15`，查询就会将事件作为模式变量 `A` 的一部分进行累积。 例如，这种限制发生在 `01-Apr-11 10：00：04`。接下来的时间段在 `01-Apr-11 10:00:11` 再次超过平均价格 `15`。因此，所述查询的结果将是：

```
 symbol       start_tstamp       end_tstamp          avgPrice
=========  ==================  ==================  ============
ACME       01-APR-11 10:00:00  01-APR-11 10:00:03     14.5
ACME       01-APR-11 10:00:05  01-APR-11 10:00:10     13.5
```

**注意** Aggregation 可以应用于表达式，但前提是它们引用单个模式变量。因此，`SUM(A.price * A.tax)` 是有效的，而 `AVG(A.price * B.tax)` 则是无效的。

**注意** 不支持 `DISTINCT` aggregation。



## 定义模式

`MATCH_RECOGNIZE` 子句允许用户在事件流中使用功能强大、表达力强的语法搜索模式，这种语法与广泛使用的正则表达式语法有些相似。

每个模式都是由基本的构建块构造的，称为 *模式变量*，可以应用算子（量词和其他修饰符）到这些模块中。整个模式必须用括号括起来。

示例模式如下所示：

```
PATTERN (A B+ C* D)
```

可以使用以下算子：

- *Concatenation* - 像 `(A B)` 这样的模式意味着 `A` 和 `B` 之间的连接是严格的。因此，在它们之间不能存在没有映射到 `A` 或 `B` 的行。

- Quantifiers

   

  \- 修改可以映射到模式变量的行数。

  - `*` — *0* 或者多行
  - `+` — *1* 或者多行
  - `?` — *0* 或者 *1* 行
  - `{ n }` — 严格 *n* 行（*n > 0*）
  - `{ n, }` — *n* 或者更多行（*n ≥ 0*）
  - `{ n, m }` — 在 *n* 到 *m*（包含）行之间（*0 ≤ n ≤ m，0 < m*）
  - `{ , m }` — 在 *0* 到 *m*（包含）行之间（*m > 0*）

**注意** 不支持可能产生空匹配的模式。此类模式的示例如 `PATTERN (A*)`，`PATTERN (A? B*)`，`PATTERN (A{0,} B{0,} C*)` 等。



### 贪婪量词和勉强量词

每一个量词可以是 *贪婪*（默认行为）的或者 *勉强* 的。贪婪的量词尝试匹配尽可能多的行，而勉强的量词则尝试匹配尽可能少的行。

为了说明区别，可以通过查询查看以下示例，其中贪婪量词应用于 `B` 变量：

```
SELECT *
FROM Ticker
    MATCH_RECOGNIZE(
        PARTITION BY symbol
        ORDER BY rowtime
        MEASURES
            C.price AS lastPrice
        ONE ROW PER MATCH
        AFTER MATCH SKIP PAST LAST ROW
        PATTERN (A B* C)
        DEFINE
            A AS A.price > 10,
            B AS B.price < 15,
            C AS C.price > 12
    )
```

假设我们有以下输入：

```
 symbol  tax   price          rowtime
======= ===== ======== =====================
 XYZ     1     10       2018-09-17 10:00:02
 XYZ     2     11       2018-09-17 10:00:03
 XYZ     1     12       2018-09-17 10:00:04
 XYZ     2     13       2018-09-17 10:00:05
 XYZ     1     14       2018-09-17 10:00:06
 XYZ     2     16       2018-09-17 10:00:07
```

上面的模式将产生以下输出：

```
 symbol   lastPrice
======== ===========
 XYZ      16
```

将 `B*` 修改为 `B*?` 的同一查询，这意味着 `B*` 应该是勉强的，将产生：

```
 symbol   lastPrice
======== ===========
 XYZ      13
 XYZ      16
```

模式变量 `B` 只匹配价格为 `12` 的行，而不是包含价格为 `12`、`13` 和 `14` 的行。

**注意** 模式的最后一个变量不能使用贪婪量词。因此，不允许使用类似 `(A B*)` 的模式。通过引入条件为 `B` 的人工状态（例如 `C`），可以轻松解决此问题。因此，你可以使用类似以下的查询：

```
PATTERN (A B* C)
DEFINE
    A AS condA(),
    B AS condB(),
    C AS NOT condB()
```

**注意** 目前不支持可选的勉强量词（`A??` 或者 `A{0,1}?`）。



### 时间约束

特别是对于流的使用场景，通常需要在给定的时间内完成模式。这要求限制住 Flink 在内部必须保持的状态总体大小（即已经过期的状态就不需要再维护了），即使在贪婪的量词的情况下也是如此。

因此，Flink SQL 支持附加的（非标准 SQL）`WITHIN` 子句来定义模式的时间约束。子句可以在 `PATTERN` 子句之后定义，并以毫秒为间隔进行解析。

如果潜在匹配的第一个和最后一个事件之间的时间长于给定值，则不会将这种匹配追加到结果表中。

**注意** 通常鼓励使用 `WITHIN` 子句，因为它有助于 Flink 进行有效的内存管理。一旦达到阈值，即可修剪基础状态。

**注意** 然而，`WITHIN` 子句不是 SQL 标准的一部分。时间约束处理的方法已被提议将来可能会改变。

下面的示例查询说明了 `WITHIN` 子句的用法：

```
SELECT *
FROM Ticker
    MATCH_RECOGNIZE(
        PARTITION BY symbol
        ORDER BY rowtime
        MEASURES
            C.rowtime AS dropTime,
            A.price - C.price AS dropDiff
        ONE ROW PER MATCH
        AFTER MATCH SKIP PAST LAST ROW
        PATTERN (A B* C) WITHIN INTERVAL '1' HOUR
        DEFINE
            B AS B.price > A.price - 10
            C AS C.price < A.price - 10
    )
```

该查询检测到在 1 小时的间隔内价格下降了 `10`。

假设该查询用于分析以下股票数据：

```
symbol         rowtime         price    tax
======  ====================  ======= =======
'ACME'  '01-Apr-11 10:00:00'   20      1
'ACME'  '01-Apr-11 10:20:00'   17      2
'ACME'  '01-Apr-11 10:40:00'   18      1
'ACME'  '01-Apr-11 11:00:00'   11      3
'ACME'  '01-Apr-11 11:20:00'   14      2
'ACME'  '01-Apr-11 11:40:00'   9       1
'ACME'  '01-Apr-11 12:00:00'   15      1
'ACME'  '01-Apr-11 12:20:00'   14      2
'ACME'  '01-Apr-11 12:40:00'   24      2
'ACME'  '01-Apr-11 13:00:00'   1       2
'ACME'  '01-Apr-11 13:20:00'   19      1
```

查询将生成以下结果：

```
symbol         dropTime         dropDiff
======  ====================  =============
'ACME'  '01-Apr-11 13:00:00'      14
```

结果行代表价格从 `15`（在`01-Apr-11 12:00:00`）下降到 `1`（在`01-Apr-11 13:00:00`）。`dropDiff` 列包含价格差异。

请注意，即使价格也下降了较高的值，例如，下降了 `11`（在 `01-Apr-11 10:00:00` 和 `01-Apr-11 11:40:00` 之间），这两个事件之间的时间差大于 1 小时。因此，它们不会产生匹配。



## 输出方式

*输出方式* 描述每个找到的匹配项应该输出多少行。SQL 标准描述了两种方式：

- `ALL ROWS PER MATCH`
- `ONE ROW PER MATCH`

目前，唯一支持的输出方式是 `ONE ROW PER MATCH`，它将始终为每个找到的匹配项生成一个输出摘要行。

输出行的 schema 将是按特定顺序连接 `[partitioning columns] + [measures columns]`。

以下示例显示了所定义的查询的输出：

```
SELECT *
FROM Ticker
    MATCH_RECOGNIZE(
        PARTITION BY symbol
        ORDER BY rowtime
        MEASURES
            FIRST(A.price) AS startPrice,
            LAST(A.price) AS topPrice,
            B.price AS lastPrice
        ONE ROW PER MATCH
        PATTERN (A+ B)
        DEFINE
            A AS LAST(A.price, 1) IS NULL OR A.price > LAST(A.price, 1),
            B AS B.price < LAST(A.price)
    )
```

对于以下输入行：

```
 symbol   tax   price          rowtime
======== ===== ======== =====================
 XYZ      1     10       2018-09-17 10:00:02
 XYZ      2     12       2018-09-17 10:00:03
 XYZ      1     13       2018-09-17 10:00:04
 XYZ      2     11       2018-09-17 10:00:05
```

该查询将生成以下输出：

```
 symbol   startPrice   topPrice   lastPrice
======== ============ ========== ===========
 XYZ      10           13         11
```

该模式识别由 `symbol` 列分区。即使在 `MEASURES` 子句中未明确提及，分区列仍会添加到结果的开头。



## 模式导航

`DEFINE` 和 `MEASURES` 子句允许在（可能）匹配模式的行列表中进行导航。

本节讨论用于声明条件或产生输出结果的导航。



### 引用模式变量

*引用模式变量* 允许引用一组映射到 `DEFINE` 或 `MEASURES` 子句中特定模式变量的行。

例如，如果我们尝试将当前行与 `A` 进行匹配，则表达式 `A.price` 描述了目前为止已映射到 `A` 的一组行加上当前行。如果 `DEFINE`/`MEASURES` 子句中的表达式需要一行（例如 `a.price` 或 `a.price > 10`），它将选择属于相应集合的最后一个值。

如果没有指定模式变量（例如 `SUM(price)`），则表达式引用默认模式变量 `*`，该变量引用模式中的所有变量。换句话说，它创建了一个列表，其中列出了迄今为止映射到任何变量的所有行以及当前行。



#### 示例

对于更全面的示例，可以查看以下模式和相应的条件：

```
PATTERN (A B+)
DEFINE
  A AS A.price >= 10,
  B AS B.price > A.price AND SUM(price) < 100 AND SUM(B.price) < 80
```

下表描述了如何为每个传入事件计算这些条件。

该表由以下列组成：

- `#` - 行标识符，用于唯一标识列表中的传入行 `[A.price]`/`[B.price]`/`[price]`。
- `price` - 传入行的价格。
- `[A.price]`/`[B.price]`/`[price]` - 描述 `DEFINE` 子句中用于计算条件的行列表。
- `Classifier` - 当前行的分类器，指示该行映射到的模式变量。
- `A.price`/`B.price`/`SUM(price)`/`SUM(B.price)` - 描述了这些表达式求值后的结果。

|  #   | price | Classifier | [A.price] |   [B.price]    |      [price]       | A.price | B.price | SUM(price) | SUM(B.price) |
| :--: | :---: | :--------: | :-------: | :------------: | :----------------: | :-----: | :-----: | :--------: | :----------: |
|  #1  |  10   |    -> A    |    #1     |       -        |         -          |   10    |    -    |     -      |      -       |
|  #2  |  15   |    -> B    |    #1     |       #2       |       #1, #2       |   10    |   15    |     25     |      15      |
|  #3  |  20   |    -> B    |    #1     |     #2, #3     |     #1, #2, #3     |   10    |   20    |     45     |      35      |
|  #4  |  31   |    -> B    |    #1     |   #2, #3, #4   |   #1, #2, #3, #4   |   10    |   31    |     76     |      66      |
|  #5  |  35   |            |    #1     | #2, #3, #4, #5 | #1, #2, #3, #4, #5 |   10    |   35    |    111     |     101      |

从表中可以看出，第一行映射到模式变量 `A`，随后的行映射到模式变量 `B`。但是，最后一行不满足 `B` 条件，因为所有映射行 `SUM(price)` 的总和与 `B` 中所有行的总和都超过了指定的阈值。

### Logical Offsets

*Logical offsets* 在映射到指定模式变量的事件启用导航。这可以用两个相应的函数表示：

| Offset functions           |                             描述                             |
| :------------------------- | :----------------------------------------------------------: |
| `LAST(variable.field, n)`  | 返回映射到变量最后 n 个元素的事件中的字段值。计数从映射的最后一个元素开始。 |
| `FIRST(variable.field, n)` | 返回映射到变量的第 *n* 个元素的事件中的字段值。计数从映射的第一个元素开始。 |



#### 示例

对于更全面的示例，可以参考以下模式和相应的条件：

```
PATTERN (A B+)
DEFINE
  A AS A.price >= 10,
  B AS (LAST(B.price, 1) IS NULL OR B.price > LAST(B.price, 1)) AND
       (LAST(B.price, 2) IS NULL OR B.price > 2 * LAST(B.price, 2))
```

下表描述了如何为每个传入事件计算这些条件。

该表包括以下列：

- `price` - 传入行的价格。
- `Classifier` - 当前行的分类器，指示该行映射到的模式变量。
- `LAST(B.price, 1)`/`LAST(B.price, 2)` - 描述对这些表达式求值后的结果。

| price | Classifier | LAST(B.price, 1) | LAST(B.price, 2) |                        Comment                         |
| :---: | :--------: | :--------------: | :--------------: | :----------------------------------------------------: |
|  10   |    -> A    |                  |                  |                                                        |
|  15   |    -> B    |       null       |       null       | 注意 `LAST(B.price, 1)` 为空，因为仍然没有映射到 `B`。 |
|  20   |    -> B    |        15        |       null       |                                                        |
|  31   |    -> B    |        20        |        15        |                                                        |
|  35   |            |        31        |        20        |             因为 `35 < 2 * 20` 没有映射。              |

将默认模式变量与 logical offsets 一起使用也可能很有意义。

在这种情况下，offset 会包含到目前为止映射的所有行：

```
PATTERN (A B? C)
DEFINE
  B AS B.price < 20,
  C AS LAST(price, 1) < C.price
```

| price | Classifier | LAST(price, 1) |                       Comment                        |
| :---: | :--------: | :------------: | :--------------------------------------------------: |
|  10   |    -> A    |                |                                                      |
|  15   |    -> B    |                |                                                      |
|  20   |    -> C    |       15       | `LAST(price, 1)` 被计算为映射到 `B` 变量的行的价格。 |

如果第二行没有映射到 `B` 变量，则会得到以下结果：

| price | Classifier | LAST(price, 1) |                       Comment                        |
| :---: | :--------: | :------------: | :--------------------------------------------------: |
|  10   |    -> A    |                |                                                      |
|  20   |    -> C    |       10       | `LAST(price, 1)` 被计算为映射到 `A` 变量的行的价格。 |

也可以在 `FIRST/LAST` 函数的第一个参数中使用多个模式变量引用。这样，可以编写访问多个列的表达式。但是，它们都必须使用相同的模式变量。换句话说，必须在一行中计算 `LAST`/`FIRST` 函数的值。

因此，可以使用 `LAST(A.price * A.tax)`，但不允许使用类似 `LAST(A.price * B.tax)` 的表达式。



## 匹配后的策略

`AFTER MATCH SKIP` 子句指定在找到完全匹配后从何处开始新的匹配过程。

有四种不同的策略：

- `SKIP PAST LAST ROW` - 在当前匹配的最后一行之后的下一行继续模式匹配。
- `SKIP TO NEXT ROW` - 继续从匹配项开始行后的下一行开始搜索新匹配项。
- `SKIP TO LAST variable` - 恢复映射到指定模式变量的最后一行的模式匹配。
- `SKIP TO FIRST variable` - 在映射到指定模式变量的第一行继续模式匹配。

这也是一种指定单个事件可以属于多少个匹配项的方法。例如，使用 `SKIP PAST LAST ROW` 策略，每个事件最多只能属于一个匹配项。



#### 示例

为了更好地理解这些策略之间的差异，我们可以看看下面的例子。

对于以下输入行：

```
 symbol   tax   price         rowtime
======== ===== ======= =====================
 XYZ      1     7       2018-09-17 10:00:01
 XYZ      2     9       2018-09-17 10:00:02
 XYZ      1     10      2018-09-17 10:00:03
 XYZ      2     5       2018-09-17 10:00:04
 XYZ      2     10      2018-09-17 10:00:05
 XYZ      2     7       2018-09-17 10:00:06
 XYZ      2     14      2018-09-17 10:00:07
```

我们使用不同的策略评估以下查询：

```
SELECT *
FROM Ticker
    MATCH_RECOGNIZE(
        PARTITION BY symbol
        ORDER BY rowtime
        MEASURES
            SUM(A.price) AS sumPrice,
            FIRST(rowtime) AS startTime,
            LAST(rowtime) AS endTime
        ONE ROW PER MATCH
        [AFTER MATCH STRATEGY]
        PATTERN (A+ C)
        DEFINE
            A AS SUM(A.price) < 30
    )
```

该查询返回映射到 `A` 的总体匹配的第一个和最后一个时间戳所有行的价格之和。

查询将根据使用的 `AFTER MATCH` 策略产生不同的结果：

##### `AFTER MATCH SKIP PAST LAST ROW`

```
 symbol   sumPrice        startTime              endTime
======== ========== ===================== =====================
 XYZ      26         2018-09-17 10:00:01   2018-09-17 10:00:04
 XYZ      17         2018-09-17 10:00:05   2018-09-17 10:00:07
```

第一个结果与 #1，#2，#3，#4 行匹配。

第二个结果与 #5，#6, #7 行匹配。

##### `AFTER MATCH SKIP TO NEXT ROW`

```
 symbol   sumPrice        startTime              endTime
======== ========== ===================== =====================
 XYZ      26         2018-09-17 10:00:01   2018-09-17 10:00:04
 XYZ      24         2018-09-17 10:00:02   2018-09-17 10:00:05
 XYZ      25         2018-09-17 10:00:03   2018-09-17 10:00:06
 XYZ      22         2018-09-17 10:00:04   2018-09-17 10:00:07
 XYZ      17         2018-09-17 10:00:05   2018-09-17 10:00:07
```

同样，第一个结果与 #1，#2，#3，#4 行匹配。

与上一个策略相比，下一个匹配再次包含 #2 行匹配。因此，第二个结果与 #2，#3，#4，#5 行匹配。

第三个结果与 #3，#4，#5, #6 行匹配。

第四个结果与 #4，#5，#6, #7 行匹配。

最后一个结果与 #5，#6, #7 行匹配。

##### `AFTER MATCH SKIP TO LAST A`

```
 symbol   sumPrice        startTime              endTime
======== ========== ===================== =====================
 XYZ      26         2018-09-17 10:00:01   2018-09-17 10:00:04
 XYZ      25         2018-09-17 10:00:03   2018-09-17 10:00:06
 XYZ      17         2018-09-17 10:00:05   2018-09-17 10:00:07
```

同样，第一个结果与 #1，#2，#3，#4 行匹配。

与前一个策略相比，下一个匹配只包含 #3 行（对应 `A`）用于下一个匹配。因此，第二个结果与 #3，#4，#5, #6 行匹配。

最后一个结果与 #5，#6, #7 行匹配。

##### `AFTER MATCH SKIP TO FIRST A`

这种组合将产生一个运行时异常，因为人们总是试图在上一个开始的地方开始一个新的匹配。这将产生一个无限循环，因此是禁止的。

必须记住，在 `SKIP TO FIRST/LAST variable` 策略的场景下，可能没有映射到该变量的行（例如，对于模式 `A*`）。在这种情况下，将抛出一个运行时异常，因为标准要求一个有效的行来继续匹配。



## 时间属性

为了在 `MATCH_RECOGNIZE` 之上应用一些后续查询，可能需要使用[时间属性](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/time_attributes.html)。有两个函数可供选择：

| Function           | Description                                                  |
| :----------------- | :----------------------------------------------------------- |
| `MATCH_ROWTIME()`  | 返回映射到给定模式的最后一行的时间戳。结果属性是[行时间属性](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/time_attributes.html)，可用于后续基于时间的操作，例如 [interval joins](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/joins.html#interval-joins) 和 [group window or over window aggregations](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#aggregations)。 |
| `MATCH_PROCTIME()` | 返回[处理时间属性](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/time_attributes.html#processing-time)，该属性可用于随后的基于时间的操作，例如 [interval joins](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/joins.html#interval-joins) 和 [group window or over window aggregations](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#aggregations)。 |



## 控制内存消耗

在编写 `MATCH_RECOGNIZE` 查询时，内存消耗是一个重要的考虑因素，因为潜在匹配的空间是以宽度优先的方式构建的。鉴于此，我们必须确保模式能够完成。最好使用映射到匹配项的合理数量的行，因为它们必须内存相适。

例如，该模式不能有没有接受每一行上限的量词。这种模式可以是这样的：

```
PATTERN (A B+ C)
DEFINE
  A as A.price > 10,
  C as C.price > 20
```

查询将每个传入行映射到 `B` 变量，因此永远不会完成。可以纠正此查询，例如，通过否定 `C` 的条件：

```
PATTERN (A B+ C)
DEFINE
  A as A.price > 10,
  B as B.price <= 20,
  C as C.price > 20
```

或者使用 [reluctant quantifier](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#greedy--reluctant-quantifiers)：

```
PATTERN (A B+? C)
DEFINE
  A as A.price > 10,
  C as C.price > 20
```

**注意** 请注意，`MATCH_RECOGNIZE` 子句未使用配置的 [state retention time](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/query_configuration.html#idle-state-retention-time)。为此，可能需要使用 `WITHIN` [子句](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#time-constraint)。



## 已知的局限

Flink 对 `MATCH_RECOGNIZE` 子句实现是一项长期持续的工作，目前尚不支持 SQL 标准的某些功能。

不支持的功能包括：

- 模式表达式：

  - Pattern groups - 这意味着量词不能应用于模式的子序列。因此，`(A (B C)+)` 不是有效的模式。
  - Alterations - 像 `PATTERN((A B | C D) E)`这样的模式，这意味着在寻找 `E` 行之前必须先找到子序列 `A B` 或者 `C D`。
  - `PERMUTE` operator - 这等同于它应用于所示的所有变量的排列 `PATTERN (PERMUTE (A, B, C))` = `PATTERN (A B C | A C B | B A C | B C A | C A B | C B A)`。
  - Anchors - `^, $`，表示分区的开始/结束，在流上下文中没有意义，将不被支持。
  - Exclusion - `PATTERN ({- A -} B)` 表示将查找 `A`，但是不会参与输出。这只适用于 `ALL ROWS PER MATCH` 方式。
  - Reluctant optional quantifier - `PATTERN A??` 只支持贪婪的可选量词。

- ```
  ALL ROWS PER MATCH
  ```

   

  输出方式 - 为参与创建匹配项的每一行产生一个输出行。这也意味着：

  - `MEASURES` 子句唯一支持的语义是 `FINAL`
  - `CLASSIFIER` 函数，尚不支持返回行映射到的模式变量。

- `SUBSET` - 它允许创建模式变量的逻辑组，并在 `DEFINE` 和 `MEASURES` 子句中使用这些组。

- Physical offsets - `PREV/NEXT`，它为所有可见事件建立索引，而不是仅将那些映射到模式变量的事件编入索引（如 [logical offsets](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/table/streaming/match_recognize.html#logical-offsets) 的情况）。

- 提取时间属性 - 目前无法为后续基于时间的操作提取时间属性。

- `MATCH_RECOGNIZE` 仅 SQL 支持。Table API 中没有等效项。

- Aggregations:

  - 不支持 distinct aggregations。