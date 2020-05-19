# Redis 内部数据结构



## 总结：

string 字符串： sds
list：quicklist
set：Redis 采用 dict 来进行存储
sorted set 有序集合类型： 如果元素数小于 128 且元素长度小于 64，则使用 ziplist 存储，否则使用 zskiplist 存储
hash类型：如果元素数小于 512，并且元素长度小于 64，则用 ziplist 存储，否则使用 dict 字典存储
hyperloglog： 采用 sds 简单动态字符串存储
geo： 如果位置数小于 128，则使用 ziplist 存储，否则使用 zskiplist 存储
bitmap： 采用 sds 简单动态字符串存储


hGetAll key： 会遍历整个dict，即使不是自己key的也会遍历比较一下，会存在性能问题
