



StreamListenerAnnotationBeanPostProcessor
	解析注解`@StreamListener`
	
StreamListenerMessageHandler







备份交换机

ttl队列

死信队列

延迟队列：ttl+死信队列

优先级队列

惰性队列：将消息存放在磁盘上，而不是放在内存中，针对消息消费比较慢的情况下比较适用



问题：

1. 声明队列的exclusive与消费队列设置的exclusive有什么关系吗？

2. 如何满足同一设备的消息，被同一个消费这消费

   * 方式1：发送端负载均衡

     事先预定好队列数量，以及routekey（如：key1、key2、key3），绑定到同一个exchange，在发送消息的时候，根据负载均衡算法（比如求余法）计算出routeKey

   * 方式2：消费端负载均衡

3. rabbitmq的集群的作用：

4. rabbitmq在分发消息给多个消费者的时候，消费能力强的，消费的消息越多吗？

   * 是的

5. 事务的实现方式：