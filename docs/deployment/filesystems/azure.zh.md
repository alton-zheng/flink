# Azure Blob 存储

[Azure Blob 存储](https://docs.microsoft.com/en-us/azure/storage/) 是一项由 Microsoft 管理的服务，能提供多种应用场景下的云存储。 Azure Blob 存储可与 Flink 一起使用以**读取**和**写入数据**，以及与[流 State Backend](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/ops/state/state_backends.html) 结合使用。

- [Shaded Hadoop Azure Blob 存储文件系统](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/filesystems/azure.html#shaded-hadoop-azure-blob-存储文件系统)
- [凭据配置](https://ci.apache.org/projects/flink/flink-docs-release-1.12/zh/deployment/filesystems/azure.html#凭据配置)

通过以下格式指定路径，Azure Blob 存储对象可类似于普通文件使用：

```
wasb://<your-container>@$<your-azure-account>.blob.core.windows.net/<object-path>

// SSL 加密访问
wasbs://<your-container>@$<your-azure-account>.blob.core.windows.net/<object-path>
```

参见以下代码了解如何在 Flink 作业中使用 Azure Blob 存储：

```
// 读取 Azure Blob 存储
env.readTextFile("wasb://<your-container>@$<your-azure-account>.blob.core.windows.net/<object-path>");

// 写入 Azure Blob 存储
stream.writeAsText("wasb://<your-container>@$<your-azure-account>.blob.core.windows.net/<object-path>")

// 将 Azure Blob 存储用作 FsStatebackend
env.setStateBackend(new FsStateBackend("wasb://<your-container>@$<your-azure-account>.blob.core.windows.net/<object-path>"));
```

### Shaded Hadoop Azure Blob 存储文件系统

为使用 flink-azure-fs-hadoop，在启动 Flink 之前，将对应的 JAR 文件从 opt 目录复制到 Flink 发行版中的 plugin 目录下的一个文件夹中，例如：

```
mkdir ./plugins/azure-fs-hadoop
cp ./opt/flink-azure-fs-hadoop-1.12.0.jar ./plugins/azure-fs-hadoop/
```

`flink-azure-fs-hadoop` 为使用 *wasb://* 和 *wasbs://* (SSL 加密访问) 的 URI 注册了默认的文件系统包装器。

### 凭据配置

Hadoop 的 Azure 文件系统支持通过 Hadoop 配置来配置凭据，如 [Hadoop Azure Blob Storage 文档](https://hadoop.apache.org/docs/current/hadoop-azure/index.html#Configuring_Credentials) 所述。 为方便起见，Flink 将所有的 Flink 配置添加 `fs.azure` 键前缀后转发至文件系统的 Hadoop 配置中。因此，可通过以下方法在 `flink-conf.yaml` 中配置 Azure Blob 存储密钥：

```yaml
fs.azure.account.key.<account_name>.blob.core.windows.net: <azure_storage_key>
```

或者通过在 `flink-conf.yaml` 中设置以下配置键，将文件系统配置为从环境变量 `AZURE_STORAGE_KEY` 读取 Azure Blob 存储密钥：

```yaml
fs.azure.account.keyprovider.<account_name>.blob.core.windows.net: org.apache.flink.fs.azurefs.EnvironmentVariableKeyProvider
```

