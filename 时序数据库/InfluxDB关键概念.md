# InfluxDB关键概念

在深入研究InfluxDB之前，最好先熟悉一下数据库的一些关键概念。本文简要介绍了这些概念和常见的influx数据库术语。下面我们提供了将要涉及的所有术语的列表，但是我们建议从头到尾阅读本文，以便对我们最喜欢的时列数据库有一个更全面的了解。

| [database](https://docs.influxdata.com/influxdb/v1.8/concepts/key_concepts/#database) | [field key](https://docs.influxdata.com/influxdb/v1.8/concepts/key_concepts/#field-key) | [field set](https://docs.influxdata.com/influxdb/v1.8/concepts/key_concepts/#field-set) |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| [field value](https://docs.influxdata.com/influxdb/v1.8/concepts/key_concepts/#field-value) | [measurement](https://docs.influxdata.com/influxdb/v1.8/concepts/key_concepts/#measurement) | [point](https://docs.influxdata.com/influxdb/v1.8/concepts/key_concepts/#point) |
| [retention policy](https://docs.influxdata.com/influxdb/v1.8/concepts/key_concepts/#retention-policy) | [series](https://docs.influxdata.com/influxdb/v1.8/concepts/key_concepts/#series) | [tag key](https://docs.influxdata.com/influxdb/v1.8/concepts/key_concepts/#tag-key) |
| [tag set](https://docs.influxdata.com/influxdb/v1.8/concepts/key_concepts/#tag-set) | [tag value](https://docs.influxdata.com/influxdb/v1.8/concepts/key_concepts/#tag-value) | [timestamp](https://docs.influxdata.com/influxdb/v1.8/concepts/key_concepts/#timestamp) |

如果你喜欢冷冰冰的、铁证如山的事实，请查看术语表。

## 样本数据

接下来的章节引用下面打印出来的数据。数据是虚构的，但是表示了在influx数据库中可信的设置。他们展示了两位科学家(langstroth和perpetua)在两个地点(地点1和地点2)从2015年8月18日午夜到2015年8月18日早上6点12分的蝴蝶和蜜蜂数量。假设数据存在于一个名为`my_database`的数据库中，并且遵循`autogen`保留策略（retention policy）(关于数据库和保留策略的更多内容将在后面介绍)。

提示:将鼠标悬停在工具提示的链接上，了解一下influx数据库术语和布局。

name:**census**

| time                     | **butterflies** | **honeybees** | **location** | **scientist** |
| ------------------------ | --------------- | ------------- | ------------ | ------------- |
| 2015-08-18T00:00:00Z     | 12              | 23            | 1            | langstroth    |
| 2015-08-18T00:00:00Z     | 1               | 30            | 1            | perpetua      |
| 2015-08-18T00:06:00Z     | 11              | 28            | 1            | langstroth    |
| **2015-08-18T00:06:00Z** | **3**           | **28**        | **1**        | **perpetua**  |
| 2015-08-18T05:54:00Z     | 2               | 11            | 2            | langstroth    |
| 2015-08-18T06:00:00Z     | 1               | 10            | 2            | langstroth    |
| 2015-08-18T06:06:00Z     | 8               | 23            | 2            | perpetua      |
| 2015-08-18T06:12:00Z     | 7               | 22            | 2            | perpetua      |

## 讨论

现在您已经看到了influx数据库中的一些示例数据，本节将介绍所有这些数据的含义。

influx数据库是一个时间序列数据库，所以从我们所做的每件事的根源开始是有意义的:时间。在上面的数据中有一个名为`time`的列—influx数据库中的所有数据都有这个列。`time`存储`timestamps`，时间戳在[RFC3339](https://www.ietf.org/rfc/rfc3339.txt) UTC中显示与特定数据相关的日期和时间。

接下来的两列叫做`butterflies`和`honeybees`，是fields。fields由field keys和field values组成。fields keys(`butterflies`和`honeybees`)是字符串;字段键`butterflies`告诉我们，字段值12-7指的是`butterflies`，而字段键`honeybees`的字段值23-22指的是`honeybees`。

字段值是您的数据;它们可以是字符串、浮点数、整数或布尔值，而且，因为influx数据库是一个时间序列数据库，所以字段值总是与时间戳相关联。样本数据中的字段值为:

```
12   23
1    30
11   28
3    28
2    11
1    10
8    23
7    22
```

在上面的数据中，field-key和field-value对的集合组成了一个字段集，下面是样本数据中的8个字段集:

- `butterflies = 12 honeybees = 23`
- `butterflies = 1 honeybees = 30`
- `butterflies = 11 honeybees = 28`
- `butterflies = 3 honeybees = 28`
- `butterflies = 2 honeybees = 11`
- `butterflies = 1 honeybees = 10`
- `butterflies = 8 honeybees = 23`
- `butterflies = 7 honeybees = 22`

字段是influx数据库数据结构中必需的一部分——在influx数据库中不能有没有字段的数据。同样重要的是要注意字段没有索引的。使用字段值作为筛选器的查询必须扫描与查询中的其他条件匹配的所有值。因此，这些字段的查询的性能不能与标签查询相比(更多关于标签的内容在下面)。通常，字段不应该包含常见查询的元数据。

样本数据中的最后两列，称为位置和科学家，是标签。标签由标签键和标签值组成。标签键和标签值都存储为字符串和记录元数据。样本数据中的标签键是location和scientist。标签键位置有两个标签值:1和2。标签关键科学家也有两个标签值:langstroth和perpetua。

样本数据中的最后两列，称为`location`和`scientist`，是标签tags。标签由标签键和标签值组成。标签键和标签值都存储为字符串和记录元数据。样本数据中的标签键是`location`和`scientist`。标签键`location`有两个标签值:1和2。标签键`scientist`也有两个标签值:langstroth和perpetua。

在上面的数据中，tag set是所有标签键-值对的不同组合。样本数据中的四个标签集为:

- `location = 1`, `scientist = langstroth`
- `location = 2`, `scientist = langstroth`
- `location = 1`, `scientist = perpetua`
- `location = 2`, `scientist = perpetua`

标签是可选的。您的数据结构中不需要使用标记，但通常使用它们是一个好主意，因为与字段不同，标记是被索引的。这意味着对标记的查询速度更快，而且标记非常适合存储常见查询的元数据。

避免使用以下保留键:* `_field` * `_measurement` * `time`

如果保留键被包括为标记或字段键，关联点将被丢弃。

> 索引为什么重要:模式案例研究
>
> 假设你注意到你的大部分查询集中在字段键的值`butterflies`和`honeybees`:
>
> `SELECT * FROM "census" WHERE "butterflies" = 1 ` `SELECT * FROM "census" WHERE "honeybees" = 23`
>
> 因为字段没有被索引，所以在提供响应之前，InfluxDB在第一个查询中扫描`butterflies`的每个值，在第二个查询中扫描`honeybees`的每个值。这种行为会影响查询响应时间——尤其是在更大范围内。为了优化您的查询，重新安排您的模式可能是有益的，这样字段(`butterflies`和`honeybees`)成为标签，标签(`butterflies` *and* `honeybees`*)*)成为*fields*:
>
> **name:** **census**
>
> | time                     | **location** | **scientist** | **butterflies** | **honeybees** |
> | ------------------------ | ------------ | ------------- | --------------- | ------------- |
> | 2015-08-18T00:00:00Z     | 1            | langstroth    | 12              | 23            |
> | 2015-08-18T00:00:00Z     | 1            | perpetua      | 1               | 30            |
> | 2015-08-18T00:06:00Z     | 1            | langstroth    | 11              | 28            |
> | **2015-08-18T00:06:00Z** | **1**        | **perpetua**  | **3**           | **28**        |
> | 2015-08-18T05:54:00Z     | 2            | langstroth    | 2               | 11            |
> | 2015-08-18T06:00:00Z     | 2            | langstroth    | 1               | 10            |
> | 2015-08-18T06:06:00Z     | 2            | perpetua      | 8               | 23            |
> | 2015-08-18T06:12:00Z     | 2            | perpetua      | 7               | 22            |
>
> 既然`butterflies`和`honeybees`都是标签，那么在执行上述查询时，InfluxDB将不必扫描它们的每个值——这意味着您的查询将更快。

***measurement*** 作为tags、fields和time列的容器，***measurement*** 的名称是存储在相关字段中的数据的描述。***measurement*** 名称是字符串，对于任何SQL用户，***measurement*** 在概念上类似于table。样本数据中唯一的***measurement***是**census**。**census**这个名字告诉我们，字段值记录的是`butterflies`和`honeybees`的数量，而不是它们的大小、方向或某种幸福指数。

一个单一的***measurement*** 可以属于不同的**保留策略**（retention policies）。保留策略描述了influx数据库保存数据的时间(持续时间)以及在集群中存储了多少份该数据的副本(复制)。如果您有兴趣阅读更多关于保留策略的内容，请查看数据库管理。

> 复制因子对单个节点实例不起作用。

在样本数据中，**census ** ***measurement*** 中的所有内容都属于`autogen`保留策略。influx数据库自动创建该保留策略;它的持续时间是无限的，复制因子设置为1。

现在您已经熟悉了***measurement*** 、tag sets和保留策略（retention policies），让我们来讨论series（系列）。在InfluxDB中，series是共享***measurement*** 、tag sets和field key的point的集合。以上数据由八个系列组成:

| Series number | Measurement | Tag set                                 | Field key     |
| ------------- | ----------- | --------------------------------------- | ------------- |
| series 1      | `census`    | `location = 1`,`scientist = langstroth` | `butterflies` |
| series 2      | `census`    | `location = 2`,`scientist = langstroth` | `butterflies` |
| series 3      | `census`    | `location = 1`,`scientist = perpetua`   | `butterflies` |
| series 4      | `census`    | `location = 2`,`scientist = perpetua`   | `butterflies` |
| series 5      | `census`    | `location = 1`,`scientist = langstroth` | `honeybees`   |
| series 6      | `census`    | `location = 2`,`scientist = langstroth` | `honeybees`   |
| series 7      | `census`    | `location = 1`,`scientist = perpetua`   | `honeybees`   |
| series 8      | `census`    | `location = 2`,`scientist = perpetua`   | `honeybees`   |

在设计模式和使用influx数据库中的数据时，理解系列的概念是非常重要的。

一个**point**代表一个单独的数据记录，它有四个组件:度量、标记集、字段集和时间戳。一个**point**是由它的series和时间戳唯一标识的。

例如，这里有一个point:

```
name: census
-----------------
time                    butterflies honeybees   location    scientist
2015-08-18T00:00:00Z    1           30          1           perpetua
```

本例中的point是series3的一部分，由度量(census)、标记集(location = 1, scientist = perpetua)、字段集(butterflies = 1, honeybees = 30)和时间戳2015-08-18T00:00:00Z定义。

我们刚才讨论的所有内容都存储在数据库中—示例数据存储在数据库`my_database`中。influx数据库与传统的关系数据库类似，可以作为用户、保留策略、连续查询以及时间序列数据的逻辑容器。有关这些主题的更多信息，请参见身份验证和授权和连续查询。

数据库可以有多个用户、连续查询、保留策略和度量。influx数据库是一个无模式数据库，这意味着在任何时候都很容易添加新的度量、标记和字段。它的设计是为了让处理时间序列数据变得非常棒。

你成功了!您已经介绍了influx数据库中的基本概念和术语。如果您刚刚开始，我们建议您看一看入门和编写数据和查询数据指南。我们的时间序列数据库也许能为您服务