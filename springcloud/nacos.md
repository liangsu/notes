# nacos

注册：

POST /nacos/v1/ns/instance?
groupName=DEFAULT_GROUP
&metadata=%7B%22preserved.register.source%22%3A%22SPRING_CLOUD%22%7D
&namespaceId=4c8d085a-d2dc-478c-ac26-2f78b9b95732
&port=8073
&enable=true
&healthy=true
&clusterName=DEFAULTs
&ip=192.168.10.34
&weight=1.0
&ephemeral=true
&serviceName=DEFAULT_GROUP%40%40location-server
&encoding=UTF-8 HTTP/1.1

groupName	DEFAULT_GROUP
metadata	{"preserved.register.source":"SPRING_CLOUD"}
namespaceId	4c8d085a-d2dc-478c-ac26-2f78b9b95732
port	8073
enable	true
healthy	true
clusterName	DEFAULT
ip	192.168.10.34
weight	1.0
ephemeral	true
serviceName	DEFAULT_GROUP@@location-server
encoding	UTF-8


心跳

PUT /nacos/v1/ns/instance/beat?beat=%7B%22cluster%22%3A%22DEFAULT%22%2C%22ip%22%3A%22192.168.10.34%22%2C%22metadata%22%3A%7B%22preserved.register.source%22%3A%22SPRING_CLOUD%22%7D%2C%22period%22%3A5000%2C%22port%22%3A8073%2C%22scheduled%22%3Afalse%2C%22serviceName%22%3A%22DEFAULT_GROUP%40%40location-server%22%2C%22stopped%22%3Afalse%2C%22weight%22%3A1.0%7D&serviceName=DEFAULT_GROUP%40%40location-server&encoding=UTF-8&namespaceId=4c8d085a-d2dc-478c-ac26-2f78b9b95732 HTTP/1.1

beat	{"cluster":"DEFAULT","ip":"192.168.10.34","metadata":{"preserved.register.source":"SPRING_CLOUD"},"period":5000,"port":8073,"scheduled":false,"serviceName":"DEFAULT_GROUP@@location-server","stopped":false,"weight":1.0}
serviceName	DEFAULT_GROUP@@location-server
encoding	UTF-8
namespaceId	4c8d085a-d2dc-478c-ac26-2f78b9b95732


获取接口列表：
GET /nacos/v1/ns/service/list?pageSize=2147483647&groupName=DEFAULT_GROUP&encoding=UTF-8&namespaceId=4c8d085a-d2dc-478c-ac26-2f78b9b95732&pageNo=1 HTTP/1.1
