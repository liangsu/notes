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



commitLog格式：
```agsl

queueOffset 8
PHYSICALOFFSET 8

STORETIMESTAMP 8

```

sysFlag 4个字节，用一个int表示

| bit    | 7 | 6 | 5         | 4        | 3           | 2                | 1                | 0                |
|--------|---|---|-----------|----------|-------------|------------------|------------------|------------------|
| byte 1 |   |   | STOREHOST | BORNHOST | TRANSACTION | TRANSACTION      | MULTI_TAGS       | COMPRESSED       |
| byte 2 |   |   |           |          |             | COMPRESSION_TYPE | COMPRESSION_TYPE | COMPRESSION_TYPE |
| byte 3 |   |   |           |          |             |                  |                  |                  |
| byte 4 |   |   |           |          |             |                  |                  |                  |


BORNHOST： ip标识位，1标识ipv6，0标识ipv4
STOREHOST：ip标识位，1标识ipv6，0标识ipv4

```
{
    required u4 TOTALSIZE = 1;
    required u4 MAGICCODE = 2;
    required u4 BODYCRC = 3;
    required u4 QUEUEID = 4;
    required u4 FLAG = 5;
    required u8 QUEUEOFFSET = 6;
    
    // 在磁盘中，从TOTALSIZE开始位置 + 整个消息体的总长度
    required u8 PHYSICALOFFSET = 7;
    required u4 SYSFLAG = 8;
    required u8 BORNTIMESTAMP = 9;
    
    // ipv4占4个字节，ipv6占16个字节
    required u4/u8 BORNHOST = 10;
    
    required u8 STORETIMESTAMP = 11;
    required bytes STOREHOSTADDRESS = 12;
    required u4 RECONSUMETIMES = 13;
    
    // Prepared Transaction Offset
    required u8 PreparedTransactionOffset = 14;
    
    // 内容体长度
    required u4 bodyLength = 15;
    // 可为空
    optional bytes body;
    
    // v2版本:short， 其它 byte
    u2/u1 topicLength = 16;
    required bytes topic;
    
    // 17 properties配置
    required u2 propertiesLength = 17;
    // 可为空
    optional bytes propertiesData = 18;
}
```
