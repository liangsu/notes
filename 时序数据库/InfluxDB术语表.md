# InfluxDB术语表

## aggregation（聚合）

一个InfluxQL函数，它返回一系列point的聚合值。有关可用和即将发布的聚合的完整列表，请参见InfluxQL函数。

Related entries: [function](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#function), [selector](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#selector), [transformation](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#transformation)

## batch

数据点的集合，采用InfluxDB行协议格式，由换行符(0x0A)分隔。可以使用对写端点的单个HTTP请求将一批点提交到数据库。通过极大地减少HTTP开销，这使得使用流感数据库API的写操作具有更高的性能。尽管不同的用例可以通过更小或更大的批量来更好地服务，但流感数据建议批大小为5,000-10,000点。

Related entries: [InfluxDB line protocol](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#influxdb-line-protocol), [point](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#point)

## bucket（桶）

bucket是在流感db 2.0中存储时间序列数据的命名位置。在InfluxDB 1.8+中，数据库和保留策略(数据库/保留策略)的每个组合代表一个bucket。使用“流感db 2.0 API兼容性接口”包括InfluxDB 1.8+与桶交互。

## continuous query (CQ) 连续查询

在数据库中自动和定期运行的一个InfluxQL查询。连续查询需要在SELECT子句中有一个函数，并且必须包含`GROUP BY time()`子句。看到连续查询。	

Related entries: [function](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#function)

## database

用户、保留策略、连续查询和时间序列数据的逻辑容器。

Related entries: [continuous query](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#continuous-query-cq), [retention policy](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#retention-policy-rp), [user](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#user)

## duration

保留策略的属性，它决定了流感数据库存储数据的时间。比持续时间早的数据将自动从数据库中删除。有关如何设置持续时间，请参阅数据库管理。

Related entries: [retention policy](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#retention-policy-rp)

## field

记录元数据和实际数据值的流感数据库数据结构中的键-值对。在InfluxDB数据结构中，字段是必需的，而且它们没有被索引——对字段值的查询扫描所有匹配指定时间范围的点，因此，与标签相比性能不高。

查询提示:比较字段和标签;标签索引。

Related entries: [field key](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#field-key), [field set](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#field-set), [field value](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#field-value), [tag](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#tag)

## field key

组成字段的键-值对的键部分。字段键是字符串，它们存储元数据。

Related entries: [field](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#field), [field set](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#field-set), [field value](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#field-value), [tag key](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#tag-key)

## field set

点上的字段键和字段值的集合。

Related entries: [field](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#field), [field key](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#field-key), [field value](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#field-value), [point](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#point)

## field value

组成字段的键值对的值部分。字段值是实际数据;它们可以是字符串、浮点数、整数或布尔值。字段值总是与时间戳相关联。

字段值没有被索引-对字段值的查询扫描所有匹配指定时间范围的点，因此，不是性能。

查询提示:比较字段值和标记值;标签值被索引。

Related entries: [field](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#field), [field key](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#field-key), [field set](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#field-set), [tag value](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#tag-value), [timestamp](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#timestamp)

## function

InfluxQL聚合、选择器和转换。有关InfluxQL函数的完整列表，请参见InfluxQL函数。

Related entries: [aggregation](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#aggregation), [selector](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#selector), [transformation](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#transformation)

## identifier

引用连续查询名称、数据库名称、字段键、度量名称、保留策略名称、订阅名称、标记键和用户名的令牌。请参阅查询语言规范。

Related entries: [database](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#database), [field key](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#field-key), [measurement](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#measurement), [retention policy](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#retention-policy-rp), [tag key](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#tag-key), [user](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#user)

## InfluxDB line protocol

基于文本的格式用于向流感数据库写入点。请参阅InfluxDB行协议。

## measurement

流感数据库数据结构中描述存储在相关字段中的数据的部分。测量是字符串。

Related entries: [field](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#field), [series](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#series)

## metastore（元存储）

包含关于系统状态的内部信息。metastore包含用户信息、数据库、保持策略、分片元数据、连续查询和订阅。

Related entries: [database](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#database), [retention policy](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#retention-policy-rp), [user](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#user)

## node

一个独立的`influxd`的进程。

Related entries: [server](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#server)

## now()

本地服务器的纳秒时间戳。

## point

在InfluxDB中，点表示单个数据记录，类似于SQL数据库表中的一行。每一个点:

* 具有度量值、标记集、字段键、字段值和时间戳;
* 是由其序列和时间戳唯一标识的。

在一个序列中，不能存储一个以上具有相同时间戳的点。如果您将一个点写入具有与现有点匹配的时间戳的序列，则字段集将成为新旧字段集的并集，并且任何关联都将转到新字段集。查看*流感数据库如何处理重复点?*

Related entries: [field set](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#field-set), [series](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#series), [timestamp](https://docs.influxdata.com/influxdb/v1.8/concepts/glossary/#timestamp)





