# feign
> 参考： https://blog.csdn.net/lgq2626/article/details/80392914

## feign调用关键类：
* FeignClientsRegistrar： 注册feign的实例、fegin的配置，关键方法registerFeignClient()
* FeignClientFactoryBean： 用于创建feign对象
* feign.ReflectiveFeign.FeignInvocationHandler： 是内部类，feign的代理的处理器
* feign.ReflectiveFeign.ParseHandlersByName：apply()负责解析feign的每个方法,通过解析参数类型，
	为每个方法产生一个参数解析器BuildTemplateByResolvingArgs
	以及方法解析器MethodHandler
* SynchronousMethodHandler：同步方法调用处理类，invoke()复制调用请求
* FeignLoadBalancer： 

* FeignClientFactoryBean
FeignClientSpecification



## 调用
* feign的http请求头
```
POST /affairInnerRest/queryListApply HTTP/1.1

X-Span-Name: http:/affairInnerRest/queryListApply
X-B3-SpanId: b28e60d3a626f050
X-B3-ParentSpanId: 1d45dc9d0bf079f6
X-B3-Sampled: 0
X-B3-TraceId: 1d45dc9d0bf079f6
Content-Type: application/json;charset=UTF-8
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










