# spring应用

1. 自动装配的模式（Autowiring modes）：基于xml才有
	* no
	* byName
	* byType
	* constructor

2. 注入方式：
	* 基于setter
	* 构造方法

3. Autowire注入解析：
	* AutowiredAnnotationBeanPostProcessor
	
4. Resource注入的解析：
	* CommonAnnotationBeanPostProcessor

5. spring Bean的生命周期回调
	5.1 实现方式：
		* 注解：@PostConstructor、@PreDestroy
		* 接口：InitializingBean 、DisposableBean 
		* xml配置：init-method、destroy-method
	
	5.2 同时存在的调用顺序：
		* 注解 > 接口 > xml配置
		
	5.3 具体实现调用类：
		* 注解： 	InitDestroyAnnotationBeanPostProcessor
		* 接口： 	AbstractAutowireCapableBeanFactory#invokeInitMethods
		* xml配置： AbstractAutowireCapableBeanFactory#invokeCustomInitMethod

	5.4 生命周期回调的应用：
		* 连接mq
		* eureka连接注册中心
		* 初始化websocket服务端
		* 初始化热点数据、缓存数据

6. spring容器的生命周期回调实现：
	* Lifecycle
	* SmartLifecycle
	
	6.1 应用：
		* 


## 面试题：
1. 如何把一个自己new的对象，放入spring容器管理？
	* FactoryBean
	* @Bean
	* ApplicationContext.registerSinglton
	
	
2. spring生命周期回调:
有3中实现方式，注解、接口、xml配置，在三者同时存在的时候，注解>接口>xml先后执行，因为在spring生命周期中，先在一个beanPostProcessor
中执行注解的回调，然后再一个	
	
	

	