# 04MC如何淘汰冷key和失效key

> Mc的key过期，不会立即删除。
>
> Mc 对 key 的淘汰，包括失效和删除回收两个纬度。

![](03.04mc淘汰key.png)

## 1. mc淘汰key的策略

1. 第一种是获取时的惰性删除，即 key 在失效后，不立即删除淘汰，而在获取时，检测 key 的状态，如果失效，才进行真正的删除并回收存储空间
2. 第二种方式是在需要对 Item 进行内存分配申请时，如果内存已全部用完，且该 Item 对应的slabclass 没有空闲的 chunk 可用，申请失败，则会对 LRU 队尾进行同步扫描，回收过期失效的 key，如果没有失效的 key，则会强制删除一个 key
3. 第三种方式是 LRU 维护线程，不定期扫描 4 个 LRU 队列，对过期 key/value 进行异步淘汰



## 2. key的失效

1. 失效key：
   * key过期
   * flush all
   * 回收之前占用内存空间

### 2.1 flush all失效

> 描述：失效所有的key，flush all 立即失效，flash all [expireTime] 多少秒钟之后失效

全局setting中有两个配置：

```
oldest_live // 失效时间，N秒后的时间戳
oldest_cas // 小于该值的所有cas值都认定为失效，
```

1. 实现原理：
   * 调用`flash all [expireTime]` ，将`oldest_live`设置为N秒后的时间戳
   * 调用`flush all`，将`oldest_cas`设为当前最大的全局 cas 值

## 2. key的删除

### 2.1 惰性删除

> 描述：指在 touch、get、gets 等指令处理时，首先需要查询 key，找到 key 所在的 Item，然后校验 key 是否过期，是否被 flush，如果过期或被 flush，则直接进行真正的删除回收操作

1. 校验key是否过期的逻辑：

   * 直接判断过期时间是否过期

   * 再检查 key 的最近访问时间是否小于全局设置中的 oldest_live，，如果小于则说明 key 被 flush 了
   * 最后检查 key 的 cas 唯一 id 值，如果小于全局设置中的 oldest_cas，说明也被 flush 了

### 2.2 内存分配失败，LRU 同步淘汰

1. Mc 在插入或变更 key 时，内存分配逻辑：

   * 找到合适的slabclass，并从分配一个空间item空间，如果失败执行下面

   * 同步对该 slabclass 的 COLD LRU 进行队尾元素淘汰，如果淘汰失败，继续下面

   * 同步对 HOT LRU 进行队尾轮询，如果 key 过期失效则进行淘汰回收，否则进行迁移

### 2.3 LRU 维护线程，异步淘汰

1. 异步淘汰解决的问题：
   * 在 key 进行读取、插入或变更时，同步进行 key 淘汰回收，是一种低效的方法，会导致mc性能下降
2. 异步淘汰的对象：
   * Mc 有 64 个 slabclass，其中 1~63 号 slabclass 用于存取 Item 数据。
   * 1~63 号 slabclass 还分别对应了 4 个 LRU，分布是 TEMP、HOT、WARM、COLD LRU
   * 维护线程会按策略阶段sleep，对总共 63*4 = 252 个 LRU进行队尾清理工作

3. 清理顺序：

   * TEMP LRU、HOT LRU、WARM LRU、COLD  LRU

4. TEMP LRU的清理：

   1. 写入key时，过期时间小于61插入该链表。
   2. 内存限制：没有链表长度限制
   3. 循环500次队尾，淘汰队尾的key

5. HOT LRU清理：

   1. 内存限制：不得超过所在 slabclass 总实际使用内存的 20%
   2. 首先循环500次淘汰队尾的key，记录没失效的key
   3. 接着计算内存占用，将多余的key，ACTIVE状态的key迁移到 WARM LRU，非 ACTIVE 状态的 key迁移到COLD LRU

6. WARM LRU清理：

   * 内存限制：不得超过所在 slabclass 总实际使用内存的 40%
   * 首先循环500次淘汰队尾的key，记录没失效的key
   * 接着计算内存占用，ACTIVE状态的key搬运到 LRU 队列头部，非 ACTIVE 状态的 key迁移到COLD LRU

7. CODE LRU清理：

   * 内存限制：没有链表长度限制
   * 首先循环500次淘汰队尾的key，记录没失效的key

   * ACTIVE状态的key搬运到WARM LRU