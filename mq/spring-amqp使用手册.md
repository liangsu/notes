# spring-amqp使用手册


## 介绍
ConnectionFactory： 
	* PooledChannelConnectionFactory： 
	* ThreadChannelConnectionFactory： 可以确保严格的消息顺序
	* CachingConnectionFactory： 使用发布者的消息确认或者想开启多个连接
	
	
PooledChannelConnectionFactory：
	管理了一个单独的连接和2个Channel池，一个池用于有事物的channel，一个池是用于没有事务的channel。需要依赖commons-pool2的池管理

ThreadChannelConnectionFactory：
	该工厂管理一个连接和两个`ThreadLocal`，一个用于有事务的channel，另一个用于没有事务的channel
	
CachingConnectionFactory：
	提供的第三种实现是CachingConnectionFactory，默认情况下，它建立一个可以由应用程序共享的连接代理。共享连接是可能的，因为使用AMQP进行消息传递的工作单元实际上是一个通道(在某些方面，这类似于JMS中的连接和会话之间的关系)。连接实例提供了一个createChannel方法。CachingConnectionFactory实现支持对这些通道进行缓存，并根据通道是否为事务性通道维护单独的缓存。在创建CachingConnectionFactory实例时，可以通过构造函数提供“主机名”。您还应该提供“用户名”和“密码”属性。要配置通道缓存的大小(默认值是25)，可以调用setChannelCacheSize()方法
	

## 

```
import com.rabbitmq.client.Channel;
import org.springframework.amqp.core.Message;
import org.springframework.amqp.core.MessageListener;
import org.springframework.amqp.rabbit.annotation.EnableRabbit;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.amqp.rabbit.config.SimpleRabbitListenerContainerFactory;
import org.springframework.amqp.rabbit.connection.CachingConnectionFactory;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.connection.PooledChannelConnectionFactory;
import org.springframework.amqp.rabbit.listener.RabbitListenerContainerFactory;
import org.springframework.amqp.rabbit.listener.SimpleMessageListenerContainer;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.autoconfigure.amqp.SimpleRabbitListenerContainerFactoryConfigurer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

import java.io.IOException;

@Configuration
@EnableRabbit
public class RabbitMQConfig {

    @Bean
    public ConnectionFactory connectionFactory(){
        com.rabbitmq.client.ConnectionFactory connectionFactory = new com.rabbitmq.client.ConnectionFactory();
        connectionFactory.setHost("192.168.10.241");
        connectionFactory.setPort(18030);
        connectionFactory.setUsername("chaoying");
        connectionFactory.setPassword("chaoying123456");
        connectionFactory.setVirtualHost("/liangsu");
        PooledChannelConnectionFactory pooledChannelConnectionFactory = new PooledChannelConnectionFactory(connectionFactory);
//        pooledChannelConnectionFactory.setPoolConfigurer();
        return pooledChannelConnectionFactory;

//        CachingConnectionFactory cachingConnectionFactory = new CachingConnectionFactory();
//        cachingConnectionFactory.setHost("192.168.10.241");
//        cachingConnectionFactory.setPort(18030);
//        cachingConnectionFactory.setUsername("chaoying");
//        cachingConnectionFactory.setPassword("chaoying123456");
//        cachingConnectionFactory.setVirtualHost("/liangsu");
//        return cachingConnectionFactory;
    }

//    @Bean
//    public SimpleMessageListenerContainer messageListenerContainer() {
//        SimpleMessageListenerContainer container = new SimpleMessageListenerContainer();
//        container.setConnectionFactory(connectionFactory());
//        container.setQueueNames("mq_c");
////        container.setMessageListener(exampleListener());
//        return container;
//    }

    @Bean
    public SimpleRabbitListenerContainerFactory rabbitListenerContainerFactory() {
        SimpleRabbitListenerContainerFactory factory = new SimpleRabbitListenerContainerFactory();
        factory.setConnectionFactory(connectionFactory());
        factory.setConcurrentConsumers(10);
        factory.setMaxConcurrentConsumers(10);
//        factory.setContainerCustomizer(container -> /* customize the container */);
        return factory;
    }

//    @Bean
//    public MessageListener exampleListener() {
//        return new MessageListener() {
//            public void onMessage(Message message) {
//                String content = new String(message.getBody());
//                System.out.println(Thread.currentThread().getName() + ": " + content);
//            }
//        };
//    }


    @RabbitListener(queues = "mq_c")
    public void processMessage(Message message) {
        String content = new String(message.getBody());
        System.out.println(Thread.currentThread().getName() + "收到消息: " + content);
    }

}
```

17:15:12.811 [main] ERROR org.springframework.amqp.rabbit.listener.SimpleMessageListenerContainer - Consumer failed to start in 60000 milliseconds; does the task executor have enough threads to support the container concurrency?










