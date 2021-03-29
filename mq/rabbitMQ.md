总结：


1. Connection可以用来创建多个Channel实例，但是Channel实例不能再多线程间共享，应用程序应该为每一个线程开辟一个Channel。某些情况下Channel的操作可以并发运行，
	但是在其它情况下会导致在网络上出现错误的通信帧交错，同时会影响发送方确认（publisher confirm）机制的运行，所以多线程间共享channel是非线程安全的。

2. 自动删除的队列：连接一断开，队列就会被删除

3. 交换机：
	* 交换机类型：fanout、direct、topic、header
	* durable：持久化
	* autoDelete： 是否自动删除。自动删除的前提是至少有一个队列或交换器与这个交换器绑定，之后所有与这个交换器绑定的队列或者交换器解绑。不是客户端断开连接
	* internal： 是否内置的。内置的客户端不能使用

4. 队列：
	* durable： 持久化
	* exclusive： 是否排它。对首次声明它的连接可见，并在连接断开时自动删除
	* autoDelete： 自动删除。自动删除的前提是至少有一个消费者与这个队列连接，之后所有与这个队列连接的消费者断开连接。不是客户端断开连接




## 并发消费

```
Concurrency Considerations
Consumer concurrency is primarily a matter of client library implementation details and application configuration. 
With most client libraries (e.g. Java, .NET, Go, Erlang) deliveries are dispatched to a thread pool (or similar) 
that handles all asynchronous consumer operations. The pool usually has controllable degree of concurrency.

Java and .NET clients guarantee that deliveries on a single channel will be dispatched in the same order there 
were received regardless of the degree of concurrency. Note that once dispatched, concurrent processing of 
deliveries will result in a natural race condition between the threads doing the processing.

Certain clients (e.g. Bunny) and frameworks might choose to limit consumer dispatch pool to a single 
thread (or similar) to avoid a natural race condition when deliveries are processed concurrently. Some applications 
depend on strictly sequential processing of deliveries and thus must use concurrency factor of one or handle 
synchronisation in their own code. Applications that can process deliveries concurrently can use the degree of 
concurrency up to the number of cores available to them.
```


官方文档： 
摘自： https://www.rabbitmq.com/api-guide.html#concurrency
```
Channels and Concurrency Considerations (Thread Safety)
As a rule of thumb, sharing Channel instances between threads is something to be avoided. Applications should prefer using a Channel per thread instead of sharing the same Channel across multiple threads.

While some operations on channels are safe to invoke concurrently, some are not and will result in incorrect frame interleaving on the wire, double acknowledgements and so on.

Concurrent publishing on a shared channel can result in incorrect frame interleaving on the wire, triggering a connection-level protocol exception and immediate connection closure by the broker. It therefore requires explicit synchronization in application code (Channel#basicPublish must be invoked in a critical section). Sharing channels between threads will also interfere with Publisher Confirms. Concurrent publishing on a shared channel is best avoided entirely, e.g. by using a channel per thread.

It is possible to use channel pooling to avoid concurrent publishing on a shared channel: once a thread is done working with a channel, it returns it to the pool, making the channel available for another thread. Channel pooling can be thought of as a specific synchronization solution. It is recommended that an existing pooling library is used instead of a homegrown solution. For example, Spring AMQP which comes with a ready-to-use channel pooling feature.

Channels consume resources and in most cases applications very rarely need more than a few hundreds open channels in the same JVM process. If we assume that the application has a thread for each channel (as channel shouldn't be used concurrently), thousands of threads for a single JVM is already a fair amount of overhead that likely can be avoided. Moreover a few fast publishers can easily saturate a network interface and a broker node: publishing involves less work than routing, storing and delivering messages.

A classic anti-pattern to be avoided is opening a channel for each published message. Channels are supposed to be reasonably long-lived and opening a new one is a network round-trip which makes this pattern extremely inefficient.

Consuming in one thread and publishing in another thread on a shared channel can be safe.

Server-pushed deliveries (see the section below) are dispatched concurrently with a guarantee that per-channel ordering is preserved. The dispatch mechanism uses a java.util.concurrent.ExecutorService, one per connection. It is possible to provide a custom executor that will be shared by all connections produced by a single ConnectionFactory using the ConnectionFactory#setSharedExecutor setter.

When manual acknowledgements are used, it is important to consider what thread does the acknowledgement. If it's different from the thread that received the delivery (e.g. Consumer#handleDelivery delegated delivery handling to a different thread), acknowledging with the multiple parameter set to true is unsafe and will result in double-acknowledgements, and therefore a channel-level protocol exception that closes the channel. Acknowledging a single message at a time can be safe.
```

翻译如下：
```
通道和并发考虑事项(线程安全)

根据经验，应该避免在线程之间共享Channel实例。应用程序应该更喜欢每个线程使用一个Channel，而不是跨多个线程共享同一个Channel。

虽然通道上的一些操作可以安全地并发调用，但有些操作则不行，并且会导致线路上不正确的帧交错、双重确认等等。

在共享通道上并发发布可能导致连线上不正确的帧交错，触发连接级协议异常，并由代理立即关闭连接。因此，它需要在应用程序代码中显式地
同步(必须在关键部分中调用通道#basicPublish)。线程之间共享通道也会干扰发布者的确认。最好完全避免在共享通道上并发发布，例如，每个
线程使用一个通道。

可以使用channel池来避免在共享通道上并发发布:一旦线程完成了对通道的操作，将它归还到池中，使channel可供其他线程使用。通道池可以看作是一种特定的同步解决方案。建议使用现有的池库，而不是自己开发的解决方案。例如，Spring AMQP具有现成的通道池特性。

通道消耗资源，在大多数情况下，应用程序在同一个JVM进程中很少需要数百个以上的开放通道。如果我们假设应用程序为每个通道都有一个线程(因为通道不应该并发使用)，那么单个JVM的数千个线程已经是相当大的开销，很可能是可以避免的。此外，一些快速发布者很容易使网络接口和代理节点饱和:发布比路由、存储和传递消息涉及的工作更少。

需要避免的一个经典反模式是为每个发布的消息打开一个通道。通道被认为是合理的长寿命的，并且打开一个新的通道是一个网络往返，这使得这个模式非常低效。

在共享通道上的一个线程中消费和在另一个线程中发布消息是安全的。

服务器推送的交付(参见下面一节)是并发分派的，并保证保留每个通道的顺序。调度机制使用java.util.concurrent。ExecutorService，每个连接一个。使用ConnectionFactory#setSharedExecutor setter，可以提供一个自定义执行器，由单个ConnectionFactory生成的所有连接共享。

当使用手动确认时，考虑使用哪个线程执行确认是重要的。如果确认与接收传递的线程不同(例如Consumer#handleDelivery委托传递处理到不同的线程)，将参数multiple设置为true是不安全的，并将导致双重确认，此时会触发通道级协议异常将关闭通道。一次只确认一条信息是安全的。
```










StreamListenerAnnotationBeanPostProcessor
	解析注解`@StreamListener`
	
StreamListenerMessageHandler





## 进阶

备份交换机
	如果发送的消息没有路由的队列，则发送到备份交换机

ttl队列：
	设置方式有两种，一种在队列上设置过期时间，一种发送消息的时候设置过期时间，第一种情况过期的消息在队列头部，可以消息过期就剔除，第二种是在投递给消费者的时候判断消息是否过期

死信队列：消息被拒绝、消息过期、队列达到最大长度

延迟队列：ttl+死信队列

优先级队列

惰性队列：将消息存放在磁盘上，而不是放在内存中，针对消息消费比较慢的情况下比较适用


持久化：
	交换机的持久化：如果交换机不设置为持久化，那么重启之后交换机的元数据会丢失
	队列的持久化：如果队列不设置为持久化，那么重启之后队列的元数据会丢失，队列的数据也会丢失
	消息的持久化：在投递消息的时候将消息设置为持久化。需要队列和消息都设置持久化之后，重启之后消息才不会丢失。

消息丢失：
	1. 消费者消费的时候使用自动ack，消费者接受到消息之后，宕机了导致消息丢失
	2. 持久化消息存入rabbitmq之后，还需要一段时间才能存入磁盘中。rabbitmq并不会为每一条消息都进行同步磁盘fsync。 这个的解决可以设置镜像队列
	3. 发送端消息丢失。可以引入事务或者发送端消息确认机制解决。
	

生产者确认：

	1. 事务机制
	
	```
	channel.txSelect();
	try {
		channel.basicPublish("exchange_t2", "aa", MessageProperties.BASIC, "111".getBytes());
		int i = 1 / 0;
		channel.txCommit();
	}catch (Exception e){
		channel.txRollback();
		e.printStackTrace();
	}
	```
	
	2. 同步confirm机制
	```
		channel.confirmSelect();
		
	    channel.basicPublish("exchange_t2", "aa", MessageProperties.BASIC, "111".getBytes());
		
	    if(!channel.waitForConfirms()){
	        System.out.println("发送消息失败");
	    }
	```
	3. 异步confirm
	```
	channel.confirmSelect();
	try {
		channel.basicPublish("exchange_t2", "aa", MessageProperties.BASIC, "111".getBytes());
	}catch (Exception e){
		e.printStackTrace();
	}
	
	channel.addConfirmListener(new ConfirmListener(){
	
		@Override
		public void handleAck(long deliveryTag, boolean multiple) throws IOException {
			System.out.println("发送成功:" + deliveryTag);
		}
	
		@Override
		public void handleNack(long deliveryTag, boolean multiple) throws IOException {
			System.out.println("发送失败:" + deliveryTag);
		}
	});
	```



## RabbitMQ管理

1. 多租户与权限

   ```
   rabbitmqctl add_vhost vhost1
   rabbitmqctl list_vhosts
   rabbitmqctl delete_vhosts vhost1
   ```

2. 用户管理

   ```
   rabbitmqctl add_user root root123
   rabbitmqctl change_password root root321
   rabbitmqctl clear_password root
   rabbitmqctl delete_user root
   rabbitmqctl list_users
   ```

3. web端管理

rabbitmq提供了很多的管理插件，默认存放在$RABBITMQ_HOME/plugins目录下

```
rabbitmq-plugins enable rabbitmq_management
```

* 查看插件启用情况： `rabbitmq-plugins list`
* 

## 问题：

1. 声明队列的exclusive与消费队列设置的exclusive有什么关系吗？

2. 如何满足同一设备的消息，被同一个消费这消费

   * 方式1：发送端负载均衡

     事先预定好队列数量，以及routekey（如：key1、key2、key3），绑定到同一个exchange，在发送消息的时候，根据负载均衡算法（比如求余法）计算出routeKey

   * 方式2：消费端负载均衡

3. rabbitmq的集群的作用：

4. rabbitmq在分发消息给多个消费者的时候，消费能力强的，消费的消息越多吗？

   * 是的

5. 事务的实现方式：