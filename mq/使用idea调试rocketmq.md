# idea 调试 rocketmq

## broker启动

1. broker.conf修改
```agsl
brokerClusterName = DefaultCluster
brokerName = broker-a
brokerId = 0
deleteWhen = 04
fileReservedTime = 48
brokerRole = ASYNC_MASTER
flushDiskType = ASYNC_FLUSH

autoCreateTopicEnable = true

# 存储路径
storePathRootDir=C:\\Users\\zhang'jie\\Desktop\\rocket-home\\store
# commitLog 存储路径
storePathCommitLog=C:\\Users\\zhang'jie\\Desktop\\store\\commitlog
# 消费队列存储路径
storePathConsumeQueue=C:\\Users\\zhang'jie\\Desktop\\store\\consumequeue
# 消息索引存储路径
storePathIndex=C:\\Users\\zhang'jie\\Desktop\\store\\index
# checkpoint 文件存储路径
storeCheckpoint=C:\\Users\\zhang'jie\\Desktop\\store\\checkpoint
# abort 文件存储路径
abortFile=C:\\Users\\zhang'jie\\Desktop\\store\\abort
```

2. 设置启动参数：
```agsl
-n localhost:9876 -c C:\Users\zhang'jie\Desktop\rocket-home\conf\broker.conf
```

3. 设置启动环境变量`ROCKETMQ_HOME`


## 其它

* 创建topic
```agsl
mqadmin updatetopic -n localhost:9876 -t TestTopic -c DefaultCluster
```





TopicConfigManager
TopicQueueMappingManager
ConsumerOffsetManager
SubscriptionGroupManager
ConsumerFilterManager
ConsumerOrderInfoManager


















