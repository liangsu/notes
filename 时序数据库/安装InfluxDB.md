# 安装

翻译自： https://docs.influxdata.com/influxdb/v1.8/introduction/install/

这个页面提供了安装、启动和配置InfluxDB开放源码(OSS)的指导。

## influxDB OSS安装前提

要成功安装influxDB数据库包，可能需要`root`或管理员特权。

### influxDB OSS网络端口

默认情况下，influxDB数据库使用以下网络端口：

* TCP端口`8086`可用于使用influxDB数据库API进行客户机-服务器通信
* TCP端口`8088`可用于RPC服务执行备份和恢复操作

除了上面的端口之外，influxDB数据库还提供了多个可能需要自定义端口的插件。所有端口映射都可以通过配置文件进行修改，对于默认安装，该配置文件位于`/etc/influxdb/influxdb.conf`

### 网络时间协议（NTP）

influxDB数据库使用主机的UTC本地时间来为数据分配时间戳，并进行协调。使用网络时间协议(NTP)同步主机间的时间;如果各个主机的时钟没有使用NTP同步，那么写入到influxDB数据库的数据上的时间戳可能会不准确

## 安装influxDB OSS

对于不想安装任何软件并准备使用influxDB数据库的用户，您可能想要检查我们的托管型influxDB数据库产品

### Ubuntu和 Debian

有关如何从文件安装Debian软件包的说明，请参阅[下载](https://influxdata.com/downloads/)页面。

Debian和Ubuntu用户可以使用apt-get包管理器安装最新的稳定版本的influxDB数据库。

对于Ubuntu用户，使用以下命令添加influxDB数据存储库

```shell
wget -qO- https://repos.influxdata.com/influxdb.key | sudo apt-key add -
source /etc/lsb-release
echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
```

对于Debian用户，添加influxDB数据仓库

```xml
wget -qO- https://repos.influxdata.com/influxdb.key | sudo apt-key add -
source /etc/os-release
echo "deb https://repos.influxdata.com/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
```

然后，安装并启动influxDB数据库服务:

```
sudo apt-get update && sudo apt-get install influxdb
sudo service influxdb start
```

或者如果你的操作系统使用systemd (Ubuntu 15.04+， debian8 +):

```shell
sudo apt-get update && sudo apt-get install influxdb
sudo systemctl unmask influxdb.service
sudo systemctl start influxdb
```

## 验证下载的二进制文件的真实性(可选)

略。

## 配置influxDB OSS

系统对每个配置文件设置都有内部默认值。使用`influxd config`查看默认配置设置

> 注意：如果在公共可访问的端点上部署了influxDB数据库，我们强烈建议启用身份验证。否则，数据将对任何未经身份验证的用户公开。默认设置不启用身份验证和授权。此外，不应该仅仅依靠身份验证和授权来防止访问和保护数据免受恶意参与者的攻击。如果需要额外的安全性或遵从性特性，则应该在第三方服务后运行InfluxDB。查看[身份验证和授权]()设置

本地配置文件(`/etc/influxdb/influxdb.conf`)中的大多数设置都被注释掉了;所有注释取消的设置将由内部默认值决定。本地配置文件中任何未注释的设置都会覆盖内部默认值。请注意，本地配置文件不需要包含每个配置设置。

有两种方法可以用您的配置文件启动influxDB数据库：

* 使用`-config`选项指定进程配置文件的路径

```shell
influxd -config /etc/influxdb/influxdb.conf
```

* 在环境变量`INFLUXDB_CONFIG_PATH`中设置配置文件的路径，并启动进程。例如

```shell
echo $INFLUXDB_CONFIG_PATH
/etc/influxdb/influxdb.conf

influxd
```

influxDB数据库首先检查`-config`选项，然后检查环境变量。

关更多信息，请参阅配置文档

### 数据和WAL目录权限

确保存储数据和预写日志(WAL)的目录对于运行`influxd`服务的用户是可写的。

> 注意：如果data和WAL目录不可写，则`influxd`服务将不会启动

关于`data`和`wal`目录路径的信息可以在配置InfluxDB文档的数据设置部分中找到。

## 在AWS上托管influxDB数据库

### 对influxDB数据库的硬件要求

我们建议使用两个SSD卷，一个用于`influxdb/wal`，另一个用于`influxdb/data`。根据您的负载，每个卷应该有大约1k-3k的IOPS。在IOPS较低的情况下，`influxdb/data`应该拥有更多的磁盘空间，而在IOPS较高的情况下，`influxdb/wal`应该拥有更少的磁盘空间。

每台机器都应该有至少8GB的RAM。

我们已经看到了R4类机器的最佳性能，因为它们比C3/C4类和M4类提供更多的内存

### 配置influxDB数据库OSS实例

本示例假设您使用了两个SSD卷，并且已经正确地挂载了它们。这个示例还假设每个卷在`/mnt/influx`和`/mnt/db`挂载。有关如何做到这一点的更多信息，请参阅Amazon文档关于如何将卷添加到您的实例

### 配置文件

您必须为您拥有的每个influxDB数据库实例适当地更新配置文件

```
...

[meta]
  dir = "/mnt/db/meta"
  ...

...

[data]
  dir = "/mnt/db/data"
  ...
wal-dir = "/mnt/influx/wal"
  ...

...

[hinted-handoff]
    ...
dir = "/mnt/db/hh"
    ...
```

### 授权和认证

对于所有AWS部署，我们强烈建议启用身份验证。否则，您的influxDB数据库实例可能对任何未经身份验证的用户公开可用。默认设置不启用身份验证和授权。此外，不应该仅仅依靠身份验证和授权来防止访问和保护数据免受恶意参与者的攻击。如果需要额外的安全性或遵从性特性，则应该在AWS提供的其他服务之后运行influxDB数据库。检查身份验证和授权设置。

### InfluxDB OSS权限

当使用非标准目录进行influxDB数据库的数据和配置时，也要确保正确设置文件系统权限:

```shell
chown influxdb:influxdb /mnt/influx
chown influxdb:influxdb /mnt/db
```

对于InfluxDB 1.7.6或更高版本，您必须给init.sh文件的所有者权限。为此，在您的`influxdb`目录中运行以下脚本：

```shell
if [ ! -f "$STDOUT" ]; then
    mkdir -p $(dirname $STDOUT)
    chown $USER:$GROUP $(dirname $STDOUT)
 fi

 if [ ! -f "$STDERR" ]; then
    mkdir -p $(dirname $STDERR)
    chown $USER:$GROUP $(dirname $STDERR)
 fi

 # Override init script variables with DEFAULT values
```

