# feign
> 参考： https://blog.csdn.net/lgq2626/article/details/80392914
	http://springcloud.cn/view/409
	
	feign的创建步骤大体分为：
	1. 注册FeignClient配置类和FeignClient BeanDefinition
	2. 实例化Feign上下文对象FeignContext 
	3. 创建 Feign.builder 对象 
	4. 生成负载均衡代理类 
	5. 生成默认代理类 
	6. 注入到spring容器


## 1. 注册BeanDefinition

1. @EnableFeignClients注解，导入BeanDefinition的注册类FeignClientsRegistrar（实现接口：ImportBeanDefinitionRegistrar）

2. 注册类FeignClientsRegistrar注册bd的流程：
	* 注册默认的 `FeignClientSpecification` 的`BeanDefinition`
	* 扫描出带有注解`@FeignClient`的类，
		* 为每个类注册一个配置类bd: FeignClientSpecification
		* 注册bd: FeignClientFactoryBean

## 2. 实例化Feign上下文对象FeignContext

1. 通过springboot的spi机制加载，对应配置文件`spring.factories`，加载类`FeignAutoConfiguration`

2. FeignAutoConfiguration的流程：
	* 根据FeignClientSpecification，创建FeignContext，FeignContext中包含有所有实例化后的`FeignClientSpecification`
	* 创建Targeter，扩展用于根据hystrix创建不同特征的代理对象
	* 创建http客户端对象，ApacheHttpClient、OkHttpClient、Client.Default（默认实现）
	

	FeignContext
		继承自： NamedContextFactory
		



-----------------------------------------------------------------------------------------------------------------------------------------

## 1.feign调用关键类：

### 1.1 EnableFeignClients： 

1. 用于导入feign的配置FeignClientsRegistrar注解

### FeignClientsRegistrar： 

1. 关键方法registerFeignClient()

2. 注册fegin的全局配置`FeignClientSpecification`。每一个feign也会注册一个`FeignClientSpecification`配置
	* 全局配置名称： default.com.chaoyingtec.helmet.fence.FenceServerApplication
	* 单个feign的配置名称：从FeignClient上获取，优先级： contextId > value > name > serviceId
	
3. 注册feign的实例，为每一个feign的接口关联`FeignClientFactoryBean`

## FeignAutoConfiguration

1. 通过springboot的spi机制加载，对应配置文件spring.factories

2. 作用：
	2.1 根据FeignClientSpecification，创建FeignContext
	2.2 创建Targeter，扩展用于根据hystrix创建不同特征的代理对象
	2.3 创建http客户端对象，ApacheHttpClient、OkHttpClient、Client.Default（默认实现）

## FeignContext

	继承自： NamedContextFactory
	关于feign的所有配置基本都是从这里获取的

1. 属性：
	* List<FeignClientSpecification> configurations： 所有的配置类
	
2. 作用：
	2.1 根据feign的配置类`FeignClientSpecification`创建spring容器`AnnotationConfigApplicationContext`，
		spring容器除了注册`FeignClientSpecification`指定的配置文件外，还注册了一个默认配置文件，默认配置文件为以下2种中的一种：
			* FeignClientsConfiguration： 编解码器、Contract（解析feign方法使用）、重试策略、Feign.Builder、FeignLoggerFactory、等
			* RibbonClientConfiguration： ribbon相关的配置，上面有的这里都有
			
	2.2 

### FeignClientFactoryBean： 

1. 属性：
	* Class<?> type: Feign的接口类
	* String name:
	* String url:
	* String contextId: 比较重要，创建spring容器`AnnotationConfigApplicationContext`的id
	* String path:
	* boolean decode404:
	* ApplicationContext applicationContext: 通过ApplicationContextAware注入
	* Class<?> fallback = void.class:
	* Class<?> fallbackFactory = void.class:

2. 用于创建feign对象

3. 功能：
	* 获取FeignContext
	* 注入：远程调用客户端Client、编解码器、日志、重试策略、拦截器等，主要为构造类`Feign.Builder`填充属性


## Feign.Builder
1. 属性：
	* final List<RequestInterceptor> requestInterceptors ： 拦截器
    * Logger.Level logLevel： 日志
    * Contract contract = new Contract.Default() :  解析出方法属性MethodMetadata，用于创建方法的参数解析器
    * Client client : 执行http请求的客户端，默认使用Client.Default
    * Retryer retryer : 重试策略
    * Logger logger :
    * Encoder encoder = new Encoder.Default():  编码器
    * Decoder decoder = new Decoder.Default():  解码器
    * QueryMapEncoder queryMapEncoder :
    * ErrorDecoder errorDecoder :
    * Options options:
    * InvocationHandlerFactory invocationHandlerFactory :
    * boolean decode404:
    * boolean closeAfterDecode :
    * ExceptionPropagationPolicy propagationPolicy :

2. 创建 SynchronousMethodHandler.Factory
3. 创建 ParseHandlersByName
4. 创建`ReflectiveFeign`，注入：ParseHandlersByName、InvocationHandlerFactory、QueryMapEncoder

## ReflectiveFeign

1. 关键方法：newInstance()，创建feign接口代理类。代理处理类是：FeignInvocationHandler


### ReflectiveFeign.FeignInvocationHandler： 是内部类，feign的代理的处理器

1. 属性：
	* Target target：
	* Map<Method, MethodHandler> dispatch： 每个方法，对应的处理器，实现类：SynchronousMethodHandler

### ReflectiveFeign.ParseHandlersByName：

1. apply()负责解析feign的每个方法,通过解析参数类型，为每个方法产生一个参数解析器`BuildTemplateByResolvingArgs`以及方法解析器MethodHandler
2. Map<String, MethodHandler>
	
### BuildTemplateByResolvingArgs

1. 作用：解析方法上的参数
2. 实现类：BuildFormEncodedTemplateFromArgs、BuildEncodedTemplateFromArgs、BuildTemplateByResolvingArgs

3. BuildFormEncodedTemplateFromArgs
	* form表单参数解析
	* 会调用到编码器feign.codec.Encoder

4. BuildEncodedTemplateFromArgs
	* 上传文件
	* 会调用到编码器feign.codec.Encoder
	
5. BuildTemplateByResolvingArgs
	* 一般参数解析，拼接url上的参数
	* 不涉及编码器

	
### SynchronousMethodHandler：

1. 同步方法调用处理类，invoke()负责调用请求

### LoadBalancerFeignClient：
	注意区分： FeignLoadBalancer

作用：
	1. 内部使用ribbon的方式，实现feign的负载均衡

### FeignLoadBalancer

	ribbon的实现


## 调用
* feign的http请求头
```
POST /affairInnerRest/queryListApply HTTP/1.1

X-Span-Name: http:/affairInnerRest/queryListApply
X-B3-SpanId: b28e60d3a626f050
X-B3-ParentSpanId: 1d45dc9d0bf079f6
X-B3-Sampled: 0
X-B3-TraceId: 1d45dc9d0bf079f6
Content-Type: application/json:charset=UTF-8
Accept: */*
User-Agent: Java/1.8.0_73
Host: 127.0.0.1:8888
Connection: keep-alive
Content-Length: 2582
```


CachingSpringLoadBalancerFactory

# Ribbon
> 参考： https://blog.csdn.net/lgq2626/article/details/80481514

* 设置ribbon服务列表从配置文件中读取
```
ribbon.eureka.enabled=false
dothings-service.ribbon.listOfServers=http\://127.0.0.1\:8888
```

# eureka
> 参考： https://blog.csdn.net/lgq2626/article/details/80288992

## 客户端访问链接：
* 获取服务列表： http://localhost:8761/eureka/apps
* 注册服务：	http://localhost:8761/eureka/apps/EGOV-MANA-UI
* 获取服务变化： http://localhost:8761/eureka/apps/delta
* 心跳检测： PUT http://localhost:8761/eureka/apps/EGOV-MANA-UI/DESKTOP-BLOVI7D:egov-mana-ui?status=UP&lastDirtyTimestamp=1540390454845

EurekaServiceRegistry 操作EurekaRegistration的类，注册、注销、设置状态
EurekaRegistration 客户端

AbstractJerseyEurekaHttpClient：包含访问eureka的所有连接


* spring.factories文件：
```
org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
org.springframework.cloud.netflix.eureka.config.EurekaClientConfigServerAutoConfiguration,\
org.springframework.cloud.netflix.eureka.config.EurekaDiscoveryClientConfigServiceAutoConfiguration,\
org.springframework.cloud.netflix.eureka.EurekaClientAutoConfiguration,\
org.springframework.cloud.netflix.ribbon.eureka.RibbonEurekaAutoConfiguration

org.springframework.cloud.bootstrap.BootstrapConfiguration=\
org.springframework.cloud.netflix.eureka.config.EurekaDiscoveryClientConfigServiceBootstrapConfiguration

org.springframework.cloud.client.discovery.EnableDiscoveryClient=\
org.springframework.cloud.netflix.eureka.EurekaDiscoveryClientConfiguration
```


DiscoveryJerseyProvider
ApplicationsResource   访问eureka的链接的处理器
PeerReplicationResource
SecureVIPResource
ServerInfoResource
StatusResource
VIPResource

# 服务跟踪
> 参考： https://blog.csdn.net/u013039300/article/details/79577356


com.netflix.discovery.DiscoveryClient.getAndStoreFullRegistry()
com.netflix.discovery.DiscoveryClient.reconcileAndLogDifference(Applications, String)
com.netflix.discovery.DiscoveryClient.fetchRegistryFromBackup()



com.netflix.niws.loadbalancer.DiscoveryEnabledNIWSServerList.obtainServersViaDiscovery()


mysql下载地址：
https://edelivery.oracle.com/osdc/faces/SoftwareDelivery


# config
* 配置修改随时生效



python sqliv.py -t "http://218.6.169.98:25678/portal" -e google  

python sqliv.py -d inurl:article.php?id= -e google



ribbon.eureka.enabled=true
attachment-service.ribbon.listofservers=http\://10.206.20.197\:6030
callman-service.ribbon.listofservers=http\://10.206.20.197\:6070
data-service.ribbon.listofservers=http\://10.206.20.197\:7010
dothings-service.ribbon.listofservers=http\://127.0.0.1\:8888
egov-mana-config.ribbon.listofservers=http\://10.206.20.197\:9082
egov-mana-ui-zipkin.ribbon.listofservers=http\://10.206.20.197\:9030
egov-wf-service.ribbon.listofservers=http\://10.206.20.197\:7004
esheet-service.ribbon.listofservers=http\://10.206.20.197\:6040
mq-service.ribbon.listofservers=http\://10.206.20.197\:6010
things-service.ribbon.listofservers=http\://10.206.20.197\:7020
timeanalysis-service.ribbon.listofservers=http\://10.206.20.197\:5090










