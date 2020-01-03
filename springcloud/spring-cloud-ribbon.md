# ribbon

	简介：ribbon是一个客户端负载均衡插件，内部维护有一个服务列表，支持切换各种负载均衡算法。
	主要初始化类：`RibbonClientConfiguration`, 主要初始化逻辑在方法`ribbonLoadBalancer`中的创建`ZoneAwareLoadBalancer`的过程

## 自动配置类

AutoServiceRegistrationConfiguration

NacosDiscoveryAutoConfiguration

RibbonClientConfiguration

RibbonNacosAutoConfiguration


## 关键类

IClientConfig
	* 配置类：连接超时时间、读取超时时间、gzip、自定义的配置
	
ServerList
	* 用于获取服务列表
	* 实现类： NacosServerList、

ServerListFilter
	* 过滤服务列表

IRule
	* 从可调用的服务列表中，选择调用哪个服务器

ILoadBalancer
	* 维护服务列表
	* 选择调用服务

ServerListUpdater
	* 更新动态服务列表的策略

RetryHandler
	* 重试策略

IPing
	* 心跳，判断服务是否还存活
	* DummyPing：这个实现，不会启动定时器去ping

ZoneAwareLoadBalancer
	* 整合类，整合ILoadBalancer、IRule、ServerListUpdater的类

Server
	
ServerIntrospector

FeignLoadBalancer
	
LoadBalancerClient
	
	


	
	
	
	
	
	