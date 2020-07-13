# 快速开始

安装了InfluxDB开放源码(OSS)后，您就可以开始做一些很棒的事情了。在本节中，我们将使用`influx`命令行接口(CLI)，它包含在所有的InfluxDB包中，是与数据库交互的一种轻量级且简单的方法。默认情况下，CLI通过8086端口向influxDB数据库API发出请求，从而直接与InfluxDB数据库通信。

```
提示：这个数据库也可以使用raw http请求通信。相关例子请查看写数据、查询数据的例子
```

## 创建数据库

如果您已经在本地安装了influxDB数据库，那么应该可以通过命令行使用内流命令。执行`influx`将启动CLI并自动连接到本地的influxDB数据库实例（假设您已经通过`service influxdb start`或者直接运行`influxd`启动启动了服务器）。输出应该是这样的

```
$ influx -precision rfc3339
Connected to http://localhost:8086 version 1.8.x
InfluxDB shell 1.8.x
>
```

```
提示：
```

## 插入和查询数据

现在我们有了一个数据库，InfluxDB已经准备好接受查询和写入

首先，简要介绍一下数据存储。influxdb数据库中的数据是按照“时间序列”组织的，它包含一个测量值，比如“cpu_load”或“temperature”。时间序列有从零到若干的`points`，每一个测量值都是离散的样本。points包括时间`time`(一个时间戳)，一个测量值`measurement`(例如“cpu_load”)，至少一个键值字段`field`(测量值`measurement`本身，例如“value=0.64”，或“temperature=21.2”)，以及0到多个键值标签`tag`，这些标签包含关于该值的任何元数据(例如“host=server01”，“region=欧洲”，“dc=法兰克福”)。

从概念上讲，您可以将度量看作一个SQL表，其中的主键索引始终是时间。标签和字段实际上是表中的列。标签`tags`被索引，而字段`fields`没有。区别在于，使用InfluxDB，您可以有数百万个度量，您不必预先定义schemas ，并且不存储空值

使用influxdb数据库行协议将points写入到influxdb数据库，它遵循以下格式：

```
<measurement>[,<tag-key>=<tag-value>...] <field-key>=<field-value>[,<field2-key>=<field2-value>...] [unix-nano-timestamp]
```

下面的行是所有可以写入到influxdb数据库的points的例子：

```
cpu,host=serverA,region=us_west value=0.64
payment,device=mobile,product=Notepad,method=credit billed=33,licenses=3i 1434067467100293230
stock,symbol=AAPL bid=127.46,ask=127.48
temperature,machine=unit42,type=assembly external=25,internal=37 1434067467000000000
```

要使用CLI将单个时间序列数据point插入到流感数据库中，请输入insert，后面跟着一个point:

```
> INSERT cpu,host=serverA,region=us_west value=0.64
>
```

