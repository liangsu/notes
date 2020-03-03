# kafka
介绍： http://kafka.apachecn.org/intro.html

## 介绍：

### 分布式
1. 每个分区都有一台 server 作为 “leader”，零台或者多台server作为 follwers
2. leader server 处理一切对 partition （分区）的读写请求，而follwers只需被动的同步leader上的数据。当leader宕机了，followers 中的一台服务器会自动成为新的 leader
2. 每台 server 都会成为某些分区的 leader 和某些分区的 follower，因此集群的负载是平衡的

### 生产者
1. 生产者可以将数据发布到所选择的topic（主题）中。
2. 生产者负责将记录分配到topic的哪一个 partition（分区）中

### 消费者
1. 消费者使用一个【消费组】名称来进行标识，发布到topic中的每条记录被分配给订阅消费组中的一个消费者实例.消费者实例可以分布在多个进程中或者多个机器上。
2. 如果所有的消费者实例在同一消费组中，消息记录会负载平衡到每一个消费者实例.
3. 如果所有的消费者实例在不同的消费组中，每条消息记录会广播到所有的消费者进程.
4. 消费者组中的消费者实例个数不能超过分区的数量


## 快速开始

1. 启动服务：
```
bin/kafka-server-start.sh config/server.properties
```

2. 创建一个名为“test”的topic，它有一个分区和一个副本
```
> bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic test
```

3. 发送一些消息
```
> bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test
```

4. 启动一个 consumer
```
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning
```


进入容器： docker exec -it 容器名称/id

## 生产消息
docker exec hm-kafka /opt/kafka_2.12-2.0.1/bin/kafka-console-producer.sh --broker-list hm-kafka:9092 --topic rfid 



## 查看topic信息
docker exec hm-kafka /opt/kafka_2.12-2.0.1/bin/kafka-topics.sh --zookeeper hm-zookeeper --describe --topic rfid

查看所有的消费组：
docker exec hm-kafka /opt/kafka_2.12-2.0.1/bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list

查看某个消费组的消费情况：
docker exec hm-kafka /opt/kafka_2.12-2.0.1/bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group fence-server



## 查看topic的内容

* docker exec hm-kafka /opt/kafka_2.12-2.0.1/bin/kafka-console-consumer.sh --bootstrap-server hm-kafka:9092 --topic rfid --from-beginning
* docker exec hm-kafka /opt/kafka_2.12-2.0.1/bin/kafka-console-consumer.sh --bootstrap-server hm-kafka:9092 --topic rfid --new-consumer --partition 0 --offset 1447

docker exec hm-kafka /opt/kafka_2.12-2.0.1/bin/kafka-console-consumer.sh --bootstrap-server hm-kafka:9092 --topic rfid --partition 0 --offset 1447


docker exec hm-kafka /opt/kafka_2.12-2.0.1/bin/kafka-console-consumer.sh --zookeeper hm-zookeeper --topic gps --from-beginning

/opt/kafka_2.12-2.0.1/bin/kafka-console-consumer.sh --bootstrap-server hm-kafka:9092 --topic gps --new-consumer --partition 0 --offset 20


docker exec hm-kafka /opt/kafka_2.12-2.0.1/bin/kafka-console-consumer.sh --bootstrap-server hm-kafka:9092 --topic lbs --from-beginning

* 发给gps给kafka
{"type":300,"message":{"acceleratorX":-9.577,"acceleratorY":6.282,"acceleratorZ":-4.98,"cache":false,"deviceId":"imei1129-01","latitude":29.716525,"longitude":122.056492,"star":11,"time":1572241349096},"class":"com.chaoyingtec.helmet.comm.stream.model.stream.gps.DeviceGpsMessage"}

* 发给安全帽通讯服务的：
```
{"t":10,"e":"864082010106865","n":[{"s":1,"y":"29.716525","x":"122.056492","g":11,"xs":"-9.577","ys":"6.282","zs":"-4.98","time":1572241349096},
	{"s":1,"y":"29.716530","x":"122.056477","g":9,"xs":"-7.891","ys":"2.451","zs":"-12.182","time":1572241350094},
	{"s":1,"y":"29.716532","x":"122.056460","g":8,"xs":"-11.109","ys":"4.06","zs":"-5.516","time":1572241351097},
	{"s":1,"y":"29.716545","x":"122.056453","g":5,"xs":"-7.738","ys":"1.838","zs":"-4.826","time":1572241352094},
	{"s":1,"y":"29.716555","x":"122.056428","g":5,"xs":"-6.205","ys":"-1.608","zs":"-3.371","time":1572241353066},
	{"s":1,"y":"29.716582","x":"122.056402","g":3,"xs":"-5.669","ys":"-3.294","zs":"-5.746","time":1572241354090},
	{"s":1,"y":"29.716578","x":"122.056360","g":3,"xs":"-7.202","ys":"2.298","zs":"-7.431","time":1572241355087},
	{"s":1,"y":"29.716603","x":"122.056340","g":3,"xs":"-9.653","ys":"1.685","zs":"-8.427","time":1572241356089},
	{"s":1,"y":"29.716612","x":"122.056333","g":3,"xs":"-8.734","ys":"1.379","zs":"-7.202","time":1572241357091},
	{"s":1,"y":"29.716608","x":"122.056345","g":5,"xs":"-7.048","ys":"1.302","zs":"-6.129","time":1572241358066},
	{"s":1,"y":"29.716580","x":"122.056413","g":6,"xs":"-8.504","ys":"4.75","zs":"-4.673","time":1572241359093},
	{"s":1,"y":"29.716563","x":"122.056448","g":6,"xs":"-6.282","ys":"-1.685","zs":"-6.359","time":1572241360089},
	{"s":1,"y":"29.716552","x":"122.056490","g":6,"xs":"-8.274","ys":"-3.677","zs":"-5.363","time":1572241361093}]}
```


spring.cloud.stream.bindings.device-in.destination=device
spring.cloud.stream.bindings.device-out.destination=device
spring.cloud.stream.bindings.user-in.destination=user
spring.cloud.stream.bindings.user-out.destination=user
spring.cloud.stream.bindings.gps-in.destination=gps
spring.cloud.stream.bindings.gps-out.destination=gps



HighServerDevice.dispatchMessage

rtmp://114.116.49.111:1935/live/864082010106865














