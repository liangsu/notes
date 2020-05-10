# memcached原理

## 1. slab机制

![](.\02.01mc内存分布.png)

![](.\02.02mc的slab内存分布.png)

1. mc将内存划分为一系列大小相同的slab，也就是说mc内部采用slab机制管理内存分配。默认情况下一个slab就是1M
2. slab进一步划分为chunk，每个chunk存储一个item，利用item结构存储数据。这个机制存储数据的时候会产生内部碎片
3. 一组具有相同 chunk size 的所有 slab，就组成一个 slabclass。如上图slab1和slab2都属于slabclass[1]
4. 每个slabclass中维护有一个freelist，包含这组 slab 里所有空闲的 chunk
5. 新增一个key/value时，内存分配：如果 Mc 有空闲空间，则从 slabclass 的 freelist 分配；如果没有空闲空间，则从对应 slabclass id 对应的 LRU 中剔除一个 Item，来复用这个 Item 的空间
6. 在查找一个key的时候，MC是通过HashTable来定位的。该hash冲突的解决：单向链表

## 2.特性

1. 高性能，单节点压测性能能达到百万级的 QPS
2. 访问协议很简单，只有 get/set/cas/touch/gat/stats 等有限的几个命令。Mc 的访问协议简单，跟它的存储结构也有关系
3. Mc 存储结构很简单，只存储简单的 key/value 键值对，而且对 value 直接以二进制方式存储，不识别内部存储结构，所以有限几个指令就可以满足操作需要
4. Mc 完全基于内存操作，在系统运行期间，在有新 key 写进来时，如果没有空闲内存分配，就会对最不活跃的 key 进行 eviction 剔除操作
5. Mc 服务节点运行也特别简单，不同 Mc 节点之间互不通信，由 client 自行负责管理数据分布。