# admire配置中心-快速开始


admiral-client-2.1.2-RELEASE.jar

AdmiralApplicationContextInitializer

<dependency>
	<artifactId>admiral-client</artifactId>
	<groupId>com.dmall.admiral</groupId>
	<version>2.0.8</version>
</dependency>


1. 启动类加上：@EnableAdmiral

```
AdmiralPlaceholderConfigurer{
	// 
	AdmiralClientContext admiralClientContext;
	
	PropertyPlaceholderConfigurerResolver implements PlaceholderResolver{
		// 解析配置
		@Override
        public String resolvePlaceholder(String placeholderName) {
            return AdmiralPlaceholderConfigurer.this.resolvePlaceholder(placeholderName, props, systemPropertiesMode);
        }
	}
	
	resolvePlaceholder(){
		// 1. 系统配置优先，则首先获取系统配置
		
		// 2. 系统配置为空，则获取远程配置
		admiralClientContext.getPropertyHolder().getValue(placeholder)

	}
}
```


```
AdmiralClientContext{
	//
	ObjectManager objectManager;
	
	// 监听远程配置改变，并解析
	private ConnectionManager connectionManager;
	
	// 对AdmiralPropertyHolder的引用
	private PropertyHolder propertyHolder;
	
}
```

ConnectionManager:
* 内部维护了一个netty的连接，服务端有数据修改时，通过这个推送给客户端
* 解析数据的关键解码器：`AdmiralConfigHandler`
* 当数据有修改，会调用`ObjectManager`通知所有监听配置的类


ManagedClassModifier：
* 找到所有被`@ManagedResource`注解的类
* 修改类的构造函数，在构造函数的结尾,将该实例对象注册到`ObjectManager`中去。
* 构造函数结束调用的类：GlobalObjectManagerRefs


```
ObjectManager{
	// 依次异步调用设置配置值的线程
	InvokeThread invokeFieldThread;
    InvokeThread invokeMethodThread;

	// 被管理的对象，通过register方法注册到这个类
	// key: 配置的key， value：有哪些对象
	// 方便在事件通知的使用及时通知
	Map<String, List<Object>> managedObjectsMap;
	
	BlockingQueue<InvokeRequest> fieldInvokeQueue;
	
	BlockingQueue<InvokeRequest> methodInvokeQueue;
	
	notify(String key){
		当配置改变的时候，被调用。从managedObjectsMap中获取对象列表，依次设置值
	}
}
```


	
AdmiralServerNodeList：
* 配置中心服务端节点


```
AdmiralPropertyHolder{
	// 动态配置
	List<Map<String, Object>> dynamicConfigItems;
	// 静态配置
	List<Map<String, Object>> staticConfigItems
	// 本地配置
	Properties localProps;

	loadFromRemote(){
		1. 加载远程配置
		2. 解析出动态配置、静态配置
	}
}
```




ManagedResource
ManagedField

${user.home}/.admiral
admiral_client_${appName}_d.data
admiral_client_${appName}_d.data


@Import(AdmiralSpringbootConfigurationInitializer.class)


<dependency>
	<artifactId>admiral-client</artifactId>
	<groupId>com.dmall.admiral</groupId>
	<version>2.0.8</version>
</dependency>


## admiral对spring的扩展

1. 通过spring.factories注册启动类
```
org.springframework.boot.env.EnvironmentPostProcessor=com.dmall.admiral.client.springboot.autoconfigure.AdmiralConfigEnvironmentProcessor
```

2. 通过`AdmiralSpringbootConfigurationInitializer`注册`AdmiralPlaceholderConfigurer`，以便替换BeanDefinition中的变量。

3. `AdmiralPlaceholderConfigurer`中的替换变量的代码
```
protected String resolvePlaceholder(String placeholder, Properties props, int systemPropertiesMode){

	String propVal = null;
	if (systemPropertiesMode == 2) {
		// 先使用System.getProperty，为空再使用System.getenv
		propVal = this.resolveSystemProperty(placeholder);
	}

	if (propVal == null) {
		if (this.userOriginalPropertySources) {
			// 使用原始的配置文件来解析
			propVal = this.propertySourcesPropertyResolver.getProperty(placeholder);
		} else {
			// 使用远程解析
			propVal = this.resolvePlaceholder(placeholder, props);
		}
	}

	if (propVal == null && systemPropertiesMode == 1) {
		propVal = this.resolveSystemProperty(placeholder);
	}

	return propVal;
}
```