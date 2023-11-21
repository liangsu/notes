1. dubbo server端启动过程

```
<dubbo:application name="demo-provider"/>

<dubbo:registry address="zookeeper://${zookeeper.address:127.0.0.1}:2181"/>

<dubbo:provider token="true"/>

<bean id="demoService" class="org.apache.dubbo.samples.basic.impl.DemoServiceImpl"/>

<dubbo:service interface="org.apache.dubbo.samples.basic.api.DemoService" ref="demoService"/>
```

DubboNamespaceHandler  DubboBeanDefinitionParser

首先使用`DubboNamespaceHandler`解析dubbo标签，这个类中的有做一些dubbo的基础组件的注册
```
public BeanDefinition parse(Element element, ParserContext parserContext) {
	BeanDefinitionRegistry registry = parserContext.getRegistry();
	// 注册spring解析的一些基础组件
	registerAnnotationConfigProcessors(registry);

	// 注册dubbo的基础组件
	DubboSpringInitializer.initialize(parserContext.getRegistry());

	BeanDefinition beanDefinition = super.parse(element, parserContext);
	setSource(beanDefinition);
	return beanDefinition;
}
```

ReferenceAnnotationBeanPostProcessor
DubboConfigAliasPostProcessor
DubboApplicationListenerRegistrar
DubboConfigDefaultPropertyValueBeanPostProcessor
DubboConfigEarlyInitializationPostProcessor


ApplicationConfig
RegistryConfig
ProviderConfig
ServiceBean



----------------------------------------
```
public class Application {
    private static String zookeeperHost = System
            .getProperty("zookeeper.address", "127.0.0.1");
    private static String zookeeperPort = System.getProperty("zookeeper.port",
            "2181");

    public static void main(String[] args) throws Exception {
        ServiceConfig<GreetingsService> service = new ServiceConfig<>();
        service.setApplication(new ApplicationConfig("first-dubbo-provider"));
        service.setRegistry(new RegistryConfig(
                "zookeeper://" + zookeeperHost + ":" + zookeeperPort));
        service.setInterface(GreetingsService.class);
        service.setRef(new GreetingsServiceImpl());
        service.export();

        System.out.println("dubbo service started");
        new CountDownLatch(1).await();
    }
}
```



AbstractMethodConfig

FrameworkModel
ApplicationModel


FrameworkModel : ScopeModel


ExtensionDirector
ExtensionPostProcessor
ScopeModelAwareExtensionProcessor
ScopeBeanFactory

ScopeModelInitializer





ExtensionDirector.getExtensionLoader()
先使用父ExtensionDirector的，如果没有再使用自身创建的ExtensionLoader


TypeBuilder
ExtensionInjector




LoadingStrategy 加载策略，定义插件从哪些文件夹中加载
	DubboInternalLoadingStrategy
	DubboLoadingStrategy
	ServicesLoadingStrategy



ExtensionLoader

	getAdaptiveExtensionClass
	  根据加载策略LoadingStrategy去加载定义的class，如果class中有`@Adaptive`标记，则这个是Adaptive class，否则会动态生成一个`Protocol$Adaptive`的class

	  如果接口方法上有加`@Adaptive`,那么生成的代码类似如下：
		```
		refer(){
			ScopeModel scopeModel = ScopeModelUtil.getOrDefault(url.getScopeModel(), org.apache.dubbo.rpc.Protocol.class);
			Protocol extension = (Protocol) scopeModel.getExtensionLoader(Protocol.class).getExtension(extName);
			extension.refer(arg0, arg1);
		}
		```

	实例化插件的过程：（有点类似spring的bean的实例化过程）
		先根据实例化策略`InstantiationStrategy`将class实例化
		调用`ExtensionPostProcessor#postProcessBeforeInitialization()`方法
		如果`ExtensionInjector`不为空，注入属性
		如果实现了接口`ExtensionAccessorAware`，调用`setExtensionAccessor()`方法
		调用`ExtensionPostProcessor#postProcessAfterInitialization()`方法
		如果对象实现了接口`Lifecycle`，调用`initialize()`方法




Invoker invoker = ProxyFactory.getInvoker();

Protocol.export(invoker)

ExchangeServer Exchanger.bind(url, ExchangeHandler){
	RemotingServer = Transporter.bind(url, ChannelHandler); // NettyServer
	return HeaderExchangeServer(RemotingServer);
}


service-discovery-registry://127.0.0.1:2181/org.apache.dubbo.registry.RegistryService?application=first-dubbo-provider&dubbo=2.0.2&pid=19592&registry=zookeeper&release=3.0.7&timestamp=1651551883297
registry

zookeeper://127.0.0.1:2181/org.apache.dubbo.registry.RegistryService?application=first-dubbo-provider&dubbo=2.0.2&pid=19592&release=3.0.7&timestamp=1651551883297


1. 先导出`MetadataService`的服务，用于dubbo-admin查询改服务提供的接口列表及其配置
2. 导出本地提供的远程服务


RegistryProtocol：向注册中心注册远程服务
RegistryProtocol

zookeeper://127.0.0.1:2181


registry://127.0.0.1:2181/org.apache.dubbo.registry.RegistryService?application=first-dubbo-provider&dubbo=2.0.2&pid=19732&registry=zookeeper&release=3.0.7&timestamp=1651563408706

service-discovery-registry://127.0.0.1:2181/org.apache.dubbo.registry.RegistryService?application=first-dubbo-provider&dubbo=2.0.2&pid=19732&registry=zookeeper&release=3.0.7&timestamp=1651563408706


DecodeHandler(new HeaderExchangeHandler(ExchangeHandler))


MultiMessageHandler(new HeartbeatHandler(Dispatcher.dispatch()))

DefaultChannelPipeline{(NettyServer$1#0 = org.apache.dubbo.remoting.transport.netty4.NettyServer$1), (decoder = org.apache.dubbo.remoting.transport.netty4.NettyCodecAdapter$InternalDecoder), (encoder = org.apache.dubbo.remoting.transport.netty4.NettyCodecAdapter$InternalEncoder), (server-idle-handler = io.netty.handler.timeout.IdleStateHandler), (handler = org.apache.dubbo.remoting.transport.netty4.NettyServerHandler)}


service-discovery-registry
registry
xxxx

registry-type=service
registry-protocol-type=xxx
registry


## 服务注册过程：

首先根据ServiceConfig生成注册信息url：
```
别名：service-discovery-registry url
service-discovery-registry://127.0.0.1:2181/org.apache.dubbo.registry.RegistryService?application=first-dubbo-provider&dubbo=2.0.2&pid=18880&registry=zookeeper&release=3.0.7&timestamp=1651632887552

别名： registry url
registry://127.0.0.1:2181/org.apache.dubbo.registry.RegistryService?application=first-dubbo-provider&dubbo=2.0.2&pid=18880&registry=zookeeper&release=3.0.7&timestamp=1651632887552
```

在导出远程服务的时候，还会生成一条导出服务创建的url,并作为上面注册信息url的`attributes`（Map类型）参数放入，key是`export`
```
别名： dubbo url
dubbo://192.168.3.58:20880/org.apache.dubbo.samples.api.GreetingsService?anyhost=true&application=first-dubbo-provider&background=false&bind.ip=192.168.3.58&bind.port=20880&deprecated=false&dubbo=2.0.2&dynamic=true&generic=false&interface=org.apache.dubbo.samples.api.GreetingsService&methods=sayHi&pid=18880&release=3.0.7&service-name-mapping=true&side=provider&timestamp=1651632887555
```

遍历上述注册信息url的时候，会导出远程服务，都会调用到服务注册处理类`RegistryProtocol`

在service-discovery-registry url处理的过程中，先使用dubbo url创建服务，然后调用类`ServiceDiscoveryRegistry`注册服务。

在registry url处理的过程中，也是先使用dubbo url创建服务，不过这时候dubbo服务已经创建了，不会重复创建，再调用`ZookeeperRegistry`注册到Zookeeper。

	`ServiceDiscoveryRegistry`的作用主要是为了`MetadataService`提供服务提供着的注册信息
	
	`MetadataService` 主要有2个作用：
		1. 给consumer提供查询接口列表的元数据信息，以及接口的配置
		2. 给dubbo-admin提供查询服务的元数据信息


zookeeper路径说明：
```
/dubbo
	/接口名，如：org.apache.dubbo.samples.api.GreetingsService
		/provider
			/服务1 url
			/服务2 url
		/consumer

/services
	/微服务名称
	 /ip地址，data：元数据信息


例子：
/dubbo
	/org.apache.dubbo.samples.api.GreetingsService
		/provider
			/dubbo://192.168.3.58:20880/org.apache.dubbo.samples.api.GreetingsService?anyhost=true&application=first-dubbo-provider&background=false&deprecated=false&dubbo=2.0.2&dynamic=true&generic=false&interface=org.apache.dubbo.samples.api.GreetingsService&methods=sayHi&pid=16336&release=3.0.7&service-name-mapping=true&side=provider&timestamp=1651633422593
```





url参数：
registry： 注册时使用的协议，有：zookeeper等



----------------------------------------
调用过程

Wrapper.invokeMethod	JavassistProxyFactory.getInvoker
org.apache.dubbo.rpc.proxy.AbstractProxyInvoker#invoke
org.apache.dubbo.config.invoker.DelegateProviderMetaDataInvoker#invoke
org.apache.dubbo.rpc.protocol.InvokerWrapper#invoke
org.apache.dubbo.rpc.filter.ClassLoaderCallbackFilter#invoke
org.apache.dubbo.rpc.cluster.filter.FilterChainBuilder.CopyOfFilterChainNode#invoke
org.apache.dubbo.rpc.protocol.dubbo.filter.TraceFilter#invoke
org.apache.dubbo.rpc.cluster.filter.FilterChainBuilder.CopyOfFilterChainNode#invoke
org.apache.dubbo.rpc.filter.TimeoutFilter#invoke
org.apache.dubbo.rpc.cluster.filter.FilterChainBuilder.CopyOfFilterChainNode#invoke
org.apache.dubbo.monitor.support.MonitorFilter#invoke
org.apache.dubbo.rpc.cluster.filter.FilterChainBuilder.CopyOfFilterChainNode#invoke
org.apache.dubbo.rpc.filter.ExceptionFilter#invoke

org.apache.dubbo.rpc.cluster.filter.FilterChainBuilder.CallbackRegistrationInvoker#invoke
org.apache.dubbo.remoting.exchange.support.ExchangeHandlerAdapter#reply
org.apache.dubbo.remoting.exchange.support.header.HeaderExchangeHandler#handleRequest
org.apache.dubbo.remoting.exchange.support.header.HeaderExchangeHandler#received
org.apache.dubbo.remoting.transport.DecodeHandler#received
org.apache.dubbo.remoting.transport.dispatcher.ChannelEventRunnable


