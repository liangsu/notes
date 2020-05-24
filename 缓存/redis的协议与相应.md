# redis的协议与相应



## 1. 设计原则

1. Redis 协议的请求响应模型：

   * ping-pong 模式，即 client 发送一个请求，server 回复一个响应，一问一答的访问模式
   * pipeline 模式，即 client 一次连续发送多个请求，然后等待 server 响应，server 处理完请求后，把响应返回给 client
   * pub/sub 模式。
     * 即发布订阅模式，client 通过 subscribe 订阅一个 channel，然后 client 进入订阅状态，静静等待。
     * 当有消息产生时，server 会持续自动推送消息给 client，不需要 client 的额外请求。
     * 客户端在进入订阅状态后，只可接受订阅相关的命令如 SUBSCRIBE、PSUBSCRIBE、UNSUBSCRIBE 和 PUNSUBSCRIBE，除了这些命令，其他命令一律失效

2. 响应格式（5 种）

   * simple strings 简单字符串类型，以 + 开头，后面跟字符串，以 CRLF（即 \r\n）结尾。

     ```
     // 输入： 
     set name xiaoming
     // 响应：
     +OK 
     ```

   * Redis 协议将错误作为一种专门的类型，格式同简单字符串类型，唯一不同的是以 -（减号）开头。

     ```
     // 输入
     aaa
     // 响应
     -ERR unknown command 'aaa'
     ```

   * Integer 整数类型。整数类型以 ：开头，后面跟字符串表示的数字，最后以回车换行结尾。

     ```
     // 输入：
     incr age
     // 响应：
     :23
     ```

   * bulk strings 字符串块类型。字符串块分头部和真正字符串内容两部分。

     * 字符串块类型的头部， 为 $ 开头，随后跟真正字符串内容的字节长度，然后以 CRLF 结尾。
     * 字符串块的头部之后，跟随真正的字符串内容，最后以 CRLF 结束字符串块

     ```
     // 输入：
     get name    
     // 响应：
     $9
     xiaoliang
     ```

   * Arrays 数组类型

     * Arrays 数组类型，以 * 开头，随后跟一个数组长度 N，然后以回车换行结尾
     * 后后面跟随 N 个数组元素，每个数组元素的类型，可以是 Redis 协议中除内联格式外的任何一种类型

     ```
     // 输入：
     mget name age
     // 响应：
     *2
     $9
     xiaoliang
     $2
     23
     ```

## 2. 协议分类

> Redis 协议主要分为 16 种，其中 8 种协议对应前面我们讲到的 8 种数据类型，你选择了使用什么数据类型，就使用对应的响应操作指令即可，剩下 8 种协议如下所示：

1. pub-sub 发布订阅协议，client 可以订阅 channel，持续等待 server 推送消息。
2. 事务协议，事务协议可以用 multi 和 exec 封装一些列指令，来一次性执行。
3. 脚本协议，关键指令是 eval、evalsha 和 script等
4. 连接协议，主要包括权限控制，切换 DB，关闭连接等
5. 复制协议，包括 slaveof、role、psync 等
6. 配置协议，config set/get 等，可以在线修改/获取配置
7. 调试统计协议，如 slowlog，monitor，info 等
8. 其他内部命令，如 migrate，dump，restore 等

## 3. Redis client 的使用及改进

> 以 Java 语言为例，广泛使用的有 Jedis、Redisson 等

### 3.1 比较客户端特性

1. Jedis client
   * 优势是轻量，简洁，便于集成和改造，它支持连接池，提供指令维度的操作，几乎支持 Redis 的所有指令，
   * 但它不支持读写分离
2. Redisson
   * 基于 Netty 实现，非阻塞 IO，性能较高，而且支持异步请求和连接池，
   * 还支持读写分离、读负载均衡，
   * 它内建了 tomcat Session ，支持 spring session 集成，但 redisson 实现相对复杂

### 3.2 Redis client 的使用及改进

1. client 访问异常时

   * 可以增加重试策略，在访问某个 slave 异常时，需要重试其他 slave 节点

2. 改进：

   * 需要增加对 Redis 主从切换、slave 扩展的支持，比如采用守护线程定期扫描 master、slave 域名，发现 IP 变更，及时切换连接
   * 对于多个 slave 的访问，还需要增加负载均衡策略
   * Redis client 还可以与配置中心、Redis 集群管理平台整合，从而实时感知及协调 Redis 服务的访问

   