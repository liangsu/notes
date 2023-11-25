# dmg


CoreRocketConsumerImpl

DefaultMQPushConsumer

DefaultMQPushConsumerImpl


消息监听器：
MessageListener
	MessageListenerConcurrently
		MessageListenerConcurrentlyImpl 并发消费 
	MessageListenerOrderly
		MessageListenerOrderlyImpl 顺序消费
	
	
消息处理类：
RocketMessageHandler
	MessageHandlerDecorator 装饰者
		MessageHandlerMetricDecorator 带统计信息的消费者
		
		




		