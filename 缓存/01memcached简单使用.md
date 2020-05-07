# memcached 

## 一、memcached 启动
* 启动命令`memcached.exe -m 64 -p 11211 -vvv`
* telnet连接： `telnet 127.0.0.1 11211`,按下`ctrl + ]` 打开回显，并按下回车

## 二、命令讲解：

### 1. add 增加命令：`add key flag expire length`
* 例如：`add name 0 0 8`，按下回车，再输入存入的值：`xiaoming`
* key 关键字
* flag 自定义任意值，主要用于表明数据类型
* expire 有效期，可以指定n秒后失效，也可以指定某个时间戳如：1493046634，也可以是0。其中0并不是代表永久不失效
```
    expire为0有两层含义：
    1. memcached在编译的时候，有一个默认的失效常量，默认为30天，当为0时则为30天失效
    2. 0代表不自动失效，有新数据进入时，会把老数据踢出
```
* length 存储字符的长度
* add不能增加已有的key的值

### 2. get 命令
* 获取存储的值，例如： `get name`

### 3. replace 命令
* 用于替换已有key的值，没有key的替换不会成功
* 示例：`replace name 0 0 3`,`tom`

### 4. set 命令
* 已有key的，做替换操作
* 没有key的，做增加操作
* 示例： `set name 0 0 4 5`,`jerry`

### 5. delete 命令
* 删除key，示例：`delete name`

### 6. incr/decr 增加/减少命令
* 运算时基于32位无符号整形运算，最小减少到0，最大增加到`待探索`
* 示例： `incr age 3`或者`decr age 2`
* 只能针对正整数或零做加减，负数小数都不行

### 7. stats 统计命令
```
STAT pid 20284     进程号
STAT uptime 1603   允许时间
STAT time 1493126994 当前时间戳
STAT version 1.4.5 
STAT pointer_size 64
STAT rusage_user 0.328125
STAT rusage_system 2.906250
STAT curr_connections 10
STAT total_connections 11
STAT connection_structures 11
STAT cmd_get 18   获取次数
STAT cmd_set 16   增加命令次数
STAT cmd_flush 1  
STAT get_hits 15  命中次数
STAT get_misses 3 未命中次数
STAT delete_misses 0
STAT delete_hits 1
STAT incr_misses 0
STAT incr_hits 17
STAT decr_misses 0
STAT decr_hits 1
STAT cas_misses 0
STAT cas_hits 0
STAT cas_badval 0
STAT auth_cmds 0
STAT auth_errors 0
STAT bytes_read 1138
STAT bytes_written 1314
STAT limit_maxbytes 67108864
STAT accepting_conns 1
STAT listen_disabled_num 0
STAT threads 4
STAT conn_yields 0
STAT bytes 89
STAT curr_items 1
STAT total_items 18
STAT evictions 0
STAT reclaimed 0
```

### 8. flush_all 清空命令
* 清空所有缓存

---

## 三、memcached内存管理
* 参考： http://blog.csdn.net/hguisu/article/details/7353482
* Slab Allocation机制：整理内存以便重复使用

* Slab Allocation的原理相当简单：

* 1）首先，像一般的内存池一样,  从操作系统分配到一大块内存。
* 2）将分配的内存分割成各种尺寸的块（chunk），并把尺寸相同的块分成组（chunk的集合），chunk的大小按照一定比例逐渐递增

```
slab class   1: chunk size        96 perslab   10922
slab class   2: chunk size       120 perslab    8738
slab class   3: chunk size       152 perslab    6898
slab class   4: chunk size       192 perslab    5461
slab class   5: chunk size       240 perslab    4369
slab class   6: chunk size       304 perslab    3449
slab class   7: chunk size       384 perslab    2730
slab class   8: chunk size       480 perslab    2184
slab class   9: chunk size       600 perslab    1747
slab class  10: chunk size       752 perslab    1394
slab class  11: chunk size       944 perslab    1110
slab class  12: chunk size      1184 perslab     885
slab class  13: chunk size      1480 perslab     708
slab class  14: chunk size      1856 perslab     564
slab class  15: chunk size      2320 perslab     451
slab class  16: chunk size      2904 perslab     361
slab class  17: chunk size      3632 perslab     288
slab class  18: chunk size      4544 perslab     230
slab class  19: chunk size      5680 perslab     184
slab class  20: chunk size      7104 perslab     147
slab class  21: chunk size      8880 perslab     118
slab class  22: chunk size     11104 perslab      94
slab class  23: chunk size     13880 perslab      75
slab class  24: chunk size     17352 perslab      60
slab class  25: chunk size     21696 perslab      48
slab class  26: chunk size     27120 perslab      38
slab class  27: chunk size     33904 perslab      30
slab class  28: chunk size     42384 perslab      24
slab class  29: chunk size     52984 perslab      19
slab class  30: chunk size     66232 perslab      15
slab class  31: chunk size     82792 perslab      12
slab class  32: chunk size    103496 perslab      10
slab class  33: chunk size    129376 perslab       8
slab class  34: chunk size    161720 perslab       6
slab class  35: chunk size    202152 perslab       5
slab class  36: chunk size    252696 perslab       4
slab class  37: chunk size    315872 perslab       3
slab class  38: chunk size    394840 perslab       2
slab class  39: chunk size    493552 perslab       2
slab class  40: chunk size    616944 perslab       1
slab class  41: chunk size    771184 perslab       1
slab class  42: chunk size   1048576 perslab       1
```

* 警示： 如果要存一个80个字节的字符，而96的仓库已经满了，这时不会将它的存在120的仓库中，而是踢除96的仓库的老数据

我的疑问：
1. 如果开始存的在slab仓库为96中，后来set为了大于96的字符，这会怎么存储？



### 四、数据过期
1. 当某个值过期后，并没有从内存删除，因此stats统计时，curr_item有其信息
2. 当取值时，判断是否过期，如果过期，返回空，并且清空，curr_item就减少
3. 如果之前没有get过，将不会自动删除，当有某个新值去占用它的位置时，当成空chunk来占用

* lazy expiration 惰性失效，好处：节省了cpu时间和检测的成本

### 五、删除机制
* memcached使用LRU删除机制
* LRU：least recently used 最近最少使用
* FIFO: first in first out 先进先出

## 六、memcached中的参数限制

* key的长度：250字节（二进制协议65535个字节）
* value的限制： 最大1M
* 内存限制：32位下最大设置到2G
* 

## memcached分布式部署
* 可以使用一致性hash来计算key
* 参考： http://www.cnblogs.com/lintong/p/4383427.html

## 七、缓存雪崩现象
* 缓存失效后，database压力骤增被压垮，重启缓存数据库后，缓存为空，数据库压力大再被压垮，反复多次重启数据库，才使系统运行起来
* 或者缓存周期性失效，比如每6小时失效，那么每6小时，将有一个请求“峰值”，严重者可能甚至会令DB崩溃

## 八、缓存无底洞
* 原文案例： http://highscalability.com/blog/2009/10/26/facebooks-memcached-multiget-hole-more-machines-more-capacit.html
* 在多台memcached的系统中，当一个请求过来，会去多个memcached访问，当访问量大了，会导致memcached的连接数增大，这时候为了降低每个memcached的连接数，增加了memcached数量，但依然每台memcached的连接数没有得到降低的现象称为“缓存无底洞现象”
* “缓存无底洞”导致原因：一个请求过来，会去访问多个memcached，说明该请求的数据被存在了多个memcached上，当你增加了memcached数量时，由于hash散列原则，导致该请求的数据被放在了更多的memcached上，这样一个请求过来并没有使原来的memcached的访问量降低
* 解决办法：修改hash算法，使相关的key存在同一台memcached服务器上

## 九、永久数据被踢现象
* 当有数据失效时，memcached是不知道有数据失效的，只有在get的时候才知道数据是否失效，所以当某个slab数据库仓库被存满，且有期限的数据失效时，但它的最近最少访问次数大于未失效的老数据时，当进入一个属于该数据仓库的数据时，就会把老数据踢除，而不是踢除已经失效的数据


## 十、memcached的java客户端
* xmemcached使用指南： https://github.com/killme2008/xmemcached/wiki/Xmemcached-%E4%B8%AD%E6%96%87%E7%94%A8%E6%88%B7%E6%8C%87%E5%8D%97


## 练习：
1. 编写一个用于memcached的一致性hash算法，并初始化缓存数据，模拟请求，统计在memcached增加、减少过程中的命中率
2. 模拟老数据被踢现象

## 扩展
1. memcache实现并发所
2. session同步

## memcache的使用：
1. 初始化了两个memcache客户端，一个用于存储数据库数据，一个用于超时并发锁
2. 并发锁的实现原理

* key： 用于生成token值，表明执行顺序，调用incr生成
* key_concurrent： 记录当前正在执行token的值
* key_max_concurrent: 记录超时的最大的token,小于该token的所有token都超时
* key_unlocktimeout： 解锁时间
