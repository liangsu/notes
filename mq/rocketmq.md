# rocketmq




TopicConfigManager
TopicQueueMappingManager
ConsumerOffsetManager
SubscriptionGroupManager
ConsumerFilterManager
ConsumerOrderInfoManager




11  PullMessageProcessor
34  ClientManageProcessor
351 AdminBrokerProcessor
310 SendMessageProcessor



刷盘处理类： GroupCommitService
异步调用刷盘，并唤醒刷盘结果监听者


分配内存的服务：AllocateMappedFileService


* 如果是事务消息，则先将消息写入半消息的topic`RMQ_SYS_TRANS_HALF_TOPIC`










