# 环境安装

- [环境要求](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/installation.html#环境要求)
- [环境设置](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/installation.html#环境设置)
- [PyFlink 安装](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/installation.html#pyflink-安装)

## 环境要求

**注意** PyFlink需要特定的Python版本（3.5, 3.6, 3.7 或 3.8）。请运行以下命令，以确保Python版本满足要求。

```
$ python --version
# the version printed here must be 3.5, 3.6, 3.7 or 3.8
```

## 环境设置

你的系统也许安装了好几个版本的Python。你可以运行下面的`ls`命令来查看你系统中安装的Python版本有哪些:

```
$ ls /usr/bin/python*
```

为了满足Python版本要求，你可以选择通过软链接的方式将`python`指向`python3`解释器:

```
ln -s /usr/bin/python3 python
```

除了软链接的方式，你也可以选择创建一个Python virtual env（`venv`）的方式。关于如何创建一个virtual env，你可以参考[准备Python虚拟环境](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/faq.html#preparing-python-virtual-environment)

如果你不想使用软链接的方式改变系统`python`解释器的指向的话，你可以使用配置的方式指定Python解释器。 关于指定编译作业使用的Python解释器，你可以参考[python client executable](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/python_config.html#python-client-executable) 关于指定执行python udf worker使用Python解释器，你可以参考[python executable](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/dev/python/python_config.html#python-executable)

## PyFlink 安装

PyFlink已经被发布到[PyPi](https://pypi.org/project/apache-flink/)，可以通过如下方式安装PyFlink：

```
$ python -m pip install apache-flink 1.12.0
```

您也可以从源码手动构建PyFlink，具体可以参见[开发指南](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/flinkDev/building.html#build-pyflink).

**注意** 从Flink 1.11版本开始, PyFlink作业支持在Windows系统上运行，因此您也可以在Windows上开发和调试PyFlink作业了。