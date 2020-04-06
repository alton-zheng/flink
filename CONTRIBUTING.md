## 如何贡献项目

领取或创建新的 [Issue](https://github.com/alton-zheng/Flink/issues)，如 [issue 1](https://github.com/alton-zheng/Flink/issues/1) ，在编辑栏的右侧添加自己为 `issue`。

在 [GitHub](https://github.com/alton-zheng/Flink/fork) 上 `fork` 项目到自己的仓库，你的如 `user_name/Flink`，然后 `clone` 到本地，并设置用户信息。

```bash
$ git clone https://github.com/alton-zheng/Flink.git

$ cd Flink
```

修改代码后提交，并推送到自己的仓库，注意修改提交消息为对应 Issue 号和描述。

```bash
# 更新内容

$ git commit -a -s

# 在提交对话框里添加类似如下内容 "Fix issue #1: 描述你的修改内容"

$ git push
```

在 [GitHub](https://github.com/alton-zheng/Flink/pulls) 上提交 `Pull Request`，添加标签，并邀请维护者进行 `Review`。

定期使用源项目仓库内容同步更新自己仓库的内容。

```bash
$ git remote add upstream https://github.com/alton-zheng/Flink

$ git fetch upstream

$ git rebase upstream/master

$ git push -f origin master
```

## 排版规范

本开源书籍排版布局和翻译风格上参考**阮一峰**老师的 [中文技术文档的写作规范](https://github.com/ruanyf/document-style-guide)

翻译规范

本规范主要列出了一些常见的翻译问题，并提供了一些指导意见和建议。请译者和校对者尽量遵循本规范，这能使得 Flink 中文文档在行为上更统一，在质量上更高。



1. 使用纯文本工具进行翻译，不要使用富文本工具

使用纯文本工具可以进行翻译，可以有效避免增加新行、删除行、破坏链接、破坏引号、破坏星号等行为。



2. 汉字与英文、数字之间需空格



我们建议汉字与英文或数字之间以空格隔开，以增强中英文混排的美观性和可读性。



注意：中文标点符号前后不需要跟空格，即使前后挨着的是英文单词。



3. 文档链接



英文版文档中可能会包含引用文档中其他文章的绝对链接，此时要注意将链接修改为中文版的 URL。

修改的方法很简单，一般在根目录之后加上 zh/ 的子目录即可。比如下面是 DataStream API 的链接。



[DataStream API]({{ site.baseurl }}/dev/datastream_api.html)



需要修改成中文链接



[DataStream API]({{ site.baseurl }}/zh/dev/datastream_api.html)

注意：如果是相对链接，则不需要修改，如 [YARN](../ops/deployment/yarn_setup.html)。



4. 标题锚点链接

文档中可能会包含标题锚点链接，当将标题从英文改成中文后，其锚点链接地址也会发生改变，导致原有锚点链接失效。

如下链接，引用了一个标题锚点（convert-a-table-into-a-datastream），但是其对应的标题被翻译成中文后，该链接会失效。

[通用概念]({{ site.baseurl }}/zh/dev/table/common.html#convert-a-table-into-a-datastream)


为了使链接仍然有效，我们需要在翻译后的标题上增加一个 <a name="original_titile_anchor"></a> 标签。



如原标题：



## Convert a Table into a DataStream


翻译后需要在标题前增加一个 <a> 标签，注意 <a> 和标题之间有一个空行。



<a name="table-to-stream-conversion"></a>

## 将表转换成 DataStream


5. 中文标点符号



中文里面请使用中文标点符号。注意英文中没有顿号，应该使用顿号的地方在英文中一般使用的是逗号，在翻译时应注意将其翻译为顿号。比如“Kubernetes, Mesos, Docker” 应该翻译成 “Kubernetes、Mesos、Docker”。



6. 一般用“你”，而不是“您”



为了风格统一，我们建议在一般情况下使用“你”即可，这样与读者距离近一些。当然必要的时候可以使用“您”来称呼，比如 warning 提示的时候。



7. 示例代码及注释



示例代码中的注释最好能够翻译，当然也可以选择不翻译（当注释很简单时）。



8. 意译优于直译



有些同学翻译的文章很容易有翻译腔，就是经常把原文一字不漏地、逐句地翻译了出来。但这样并不代表翻译更准确，反而有时候读着会很别扭。所以建议在翻译完以后，自己多读几遍，看看是否符合原意、是否绕口、是否简洁。在充分理解原文的基础上，可以适当采用意译的方式来翻译。有时候为了简化句子，有些数量词、助词、主语都可以省略。





"...的...的...的..."



比如英文中经常会用 's 来表达从属关系，一字不落地都将其翻译成 "的" 就会很翻译腔。在中文里面有些 "的" 完全可以去掉，不会影响表达的意思，还能简洁很多，看下面的例子：



Flink's documentation is located in the docs folder in Flink's source code repository



当然，你可以将"的"字都翻译出来，但是读起来很不顺畅：



❌ Flink 的文档位于 Flink 的源码仓库的 docs 文件夹中。



去掉不必要的"的"字，就会简洁很多：

✅ Flink 文档位于 Flink 源码仓库的 docs 文件夹中。





"一个……"



英文一般比较严谨，当代表多个时，会使用复数名字，在翻译成中文时，一般不需要刻意把这种复数翻译出来。



在英文里，当单数可数名词时，前面一般会有“a”或“an”，但在中文里我们大多数时候是不用把“一个...”给翻译出来的。



比如下面这个例子：



State is a first-class citizen in Flink.



我们可以将“a”翻译成“一个”：



❌ 状态是 Flink 中的一个一等公民。



虽然看起来没什么问题，但是这里的“一个”完全是多余的，去掉之后不但不会影响翻译效果，而且还会显得更加简洁：



✅ 状态是 Flink 中的一等公民。



专业术语
术语翻译表请遵循下方的表格，该表格中列出了社区推荐的翻译，和不推荐翻译的术语。请尽量遵守，但请注意该表格并不是完善的，仍在演进中，如果发现有不恰当的翻译或不确定的翻译，请在邮件列表中讨论，或在这篇 Google Doc 中评论。

重要：文章中第一次出现专业术语翻译的地方需要给出英文原文。例如：“如果看到反压（back pressure）警告，则...”

专有词要注意大小写，如 Flink，Java，Scala，API，SQL，不要用小写的 flink, java, scala, api, sql。

当单词是指代码中的属性名、方法名、对象名、类名、标签名等时，可以不译。例如 "parallelism parameter" 不需要翻译成“并发参数”，而是应为“parallelism 属性”。

术语表 （Glossary）
我们一直认为一个单词一定要结合上下文才能确定准确的含义，所以该表格仅作为翻译的参考。如果遇到不确定的翻译，请随时在社区中发起讨论。

???：待讨论

N/A: 该术语不建议翻译

该表格按字母顺序排序

Term

Chinese Simplified

Description

At-Least-Once

至少一次


At-Most-Once

至多一次


Back Pressure

反压


Chain (noun)

链

e.g. operator chain -> 算子链

Chain (verb)

链接

e.g.  Flink chains operator subtasks together into tasks.

-> Flink 将算子的 subtask 链接成 task。

Checkpoint

N/A

不翻译。虽然有地方翻译成“检查点”，但我们仍不建议翻译。

Connector	连接器	
Exactly-Once

精确一次


Fault Tolerance

容错


Failover

故障恢复


Fit

拟合

仅适用于数学和机器学习中，其他场景请结合上下文翻译。

High Availability

高可用


Join

N/A

Join 在中文中也很常用，翻译成“连接”反而不习惯。

Key / Keys

键


Keyed

N/A

一般不建议翻译。例如: keyed state, keyed stream，在 Flink 中都是有特殊含义的。non-keyed 也类似。

K-Fold Splits

K折划分


Lazy Evaluation

延迟计算


Metric

指标


MinMaxScaler

最大最小值归一化


Operator

算子


Operator Chain

算子链


Polymorphism

多态


Savepoint

N/A


Schema

N/A

指对结构的描述，例如：data schema，table schema，state schema

Setup	设置	如 cluster setup 可以翻译成 "集群设置"。
State

状态


State Backend

N/A


Side output

旁路输出


Sink	N/A	不翻译
Transformation

转换/转换操作


Task / Subtask

N/A

当特指 Flink 中的运行单元时，不翻译。

Tuple

N/A

当特指 Flink Tuple 对象时，不翻译。

Watermark

N/A


Window

Tumbling Window

Sliding Window

Session Window

Global Window

窗口

滚动窗口

滑动窗口

会话窗口

全局窗口






