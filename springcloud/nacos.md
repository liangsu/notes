# nacos 服务发现

服务发现的核心功能：
	1. 注册自身服务，定时发送心跳
	2. 获取其它的服务列表，并定时更新

spring cloud 与nacos discovery 的自动配置类`NacosDiscoveryAutoConfiguration`。

服务发现的注册机制：
	    类`AbstractAutoServiceRegistration`实现了接口`ApplicationListener`，在监听函数里面做的注册操作，具体实现类`NacosAutoServiceRegistration`，
		这里利用了spring cloud的扩展点实现自动注册
	

## 关键类

	配置类： NacosDiscoveryProperties， 基于spring boot的配置文件方式
	nacos工厂类： NacosFactory，用于创建ConfigService、NamingService、NamingMaintainService
	

### NacosNamingService

描述： implement NamingService
	   服务发现的门面类，提供了获取服务列表、注册服务、注销服务、订阅/取消订阅服务的接口
	   
属性：
	* private String namespace;
    * private String endpoint;
    * private String serverList;
    * private String cacheDir
    * private String logName;
    * private HostReactor hostReactor; 用于维护本地服务列表，定时更新服务列表
    * private BeatReactor beatReactor; 用于定时执行心跳的类
    * private EventDispatcher eventDispatcher; 订阅服务改变的通知事件
    * private NamingProxy serverProxy;
	

### BeatReactor

描述： 用于定时执行心跳的类

属性：
	* private ScheduledExecutorService executorService;
		* 执行心跳的定时器
	
	* private NamingProxy serverProxy;
	
	* public final Map<String, BeatInfo> dom2Beat = new ConcurrentHashMap<String, BeatInfo>();

### BeatTask

描述： 执行心跳的任务对象，用于提交定时器

属性：
	* BeatInfo beatInfo： 心跳信息

### BeatInfo

描述： 心跳信息

属性：
	private int port;
    private String ip;
    private double weight;
    private String serviceName;
    private String cluster;
    private Map<String, String> metadata;
    private volatile boolean scheduled;
    private volatile long period;
    private volatile boolean stopped;

### NamingProxy

描述： 用于封装http请求的参数，调用HttpClient发送请求。
	   所有与nacos服务通信的接口都要经过这个类，发送心跳、注册服务、注销服务
	   
属性：
	* private static final int DEFAULT_SERVER_PORT = 8848;
    * private int serverPort = DEFAULT_SERVER_PORT;
    * private String namespaceId; 命名空间，封装请求参数时会用到
    * private String endpoint;
    * private String nacosDomain;
    * private List<String> serverList; 这是nacos服务端的url地址
    * private List<String> serversFromEndpoint = new ArrayList<String>();
    * private long lastSrvRefTime = 0L;
    * private long vipSrvRefInterMillis = TimeUnit.SECONDS.toMillis(30);
    * private Properties properties;

### HostReactor

描述：获取其它的服务列表，并定时更新

属性：
	* private static final long DEFAULT_DELAY = 1000L;
    * private static final long UPDATE_HOLD_INTERVAL = 5000L;
    * private final Map<String, ScheduledFuture<?>> futureMap = new HashMap<String, ScheduledFuture<?>>(); 
		* key：服务名称+@@+集群名称，value：更新服务的任务UpdateTask
		* 存放需要更新服务列表的任务，有防重的功能，防止一个服务有多个任务在维护
		
    * private Map<String, ServiceInfo> serviceInfoMap; 
		* 存放服务列表，key：服务名称+@@+集群名称，value：服务列表
		
    * private Map<String, Object> updatingMap; 
		* 正在更新的服务，会放入这个map，更新完成后移除
		
    * private PushReceiver pushReceiver;
    * private EventDispatcher eventDispatcher;
		* 订阅服务改变的通知事件
		
    * private NamingProxy serverProxy;
    * private FailoverReactor failoverReactor;
    * private String cacheDir;
    * private ScheduledExecutorService executor;
		* 定时更新服务列表的定时器

关键方法： getServiceInfo


获取某个微服务的服务列表流程：
1. 查询缓存serviceInfoMap中是否有服务，有则返回，没有继续下面
2. 创建服务对象ServiceInfo，并调用远程nacos服务端，获取该服务的服务列表，并更新
3. 判断定时任务futureMap中是否有这个服务的更新任务，没有则增加


### MetricsMonitor



## nacos discovery和ribbon结合相关的类

NacosServiceRegistry
	* 实现了spring cloud的服务注册类ServiceRegistry
	* 注册服务实例

NacosRegistration
	* 被注册的对象，实现了spring cloud的被注册服务的接口：Registration、ServiceInstance

NacosAutoServiceRegistration
	* 自动注册服务的类，继承自sprin cloud的自动注册类`AbstractAutoServiceRegistration`，利用了spring cloud的扩展点实现自动注册

NacosServerList
	* 实现接口ribbon的接口`AbstractServerList`，该接口用于获取服务列表
	* 内部调用NacosNamingService获取服务列表
	
NacosRule
	* ribbon的负载均衡算法的一种


## http请求

注册：

POST /nacos/v1/ns/instance?
groupName=DEFAULT_GROUP
&metadata=%7B%22preserved.register.source%22%3A%22SPRING_CLOUD%22%7D
&namespaceId=4c8d085a-d2dc-478c-ac26-2f78b9b95732
&port=8073
&enable=true
&healthy=true
&clusterName=DEFAULTs
&ip=192.168.10.34
&weight=1.0
&ephemeral=true
&serviceName=DEFAULT_GROUP%40%40location-server
&encoding=UTF-8 HTTP/1.1

groupName	DEFAULT_GROUP
metadata	{"preserved.register.source":"SPRING_CLOUD"}
namespaceId	4c8d085a-d2dc-478c-ac26-2f78b9b95732
port	8073
enable	true
healthy	true
clusterName	DEFAULT
ip	192.168.10.34
weight	1.0
ephemeral	true
serviceName	DEFAULT_GROUP@@location-server
encoding	UTF-8


心跳

PUT /nacos/v1/ns/instance/beat?beat=%7B%22cluster%22%3A%22DEFAULT%22%2C%22ip%22%3A%22192.168.10.34%22%2C%22metadata%22%3A%7B%22preserved.register.source%22%3A%22SPRING_CLOUD%22%7D%2C%22period%22%3A5000%2C%22port%22%3A8073%2C%22scheduled%22%3Afalse%2C%22serviceName%22%3A%22DEFAULT_GROUP%40%40location-server%22%2C%22stopped%22%3Afalse%2C%22weight%22%3A1.0%7D&serviceName=DEFAULT_GROUP%40%40location-server&encoding=UTF-8&namespaceId=4c8d085a-d2dc-478c-ac26-2f78b9b95732 HTTP/1.1

beat	{"cluster":"DEFAULT","ip":"192.168.10.34","metadata":{"preserved.register.source":"SPRING_CLOUD"},"period":5000,"port":8073,"scheduled":false,"serviceName":"DEFAULT_GROUP@@location-server","stopped":false,"weight":1.0}
serviceName	DEFAULT_GROUP@@location-server
encoding	UTF-8
namespaceId	4c8d085a-d2dc-478c-ac26-2f78b9b95732


获取接口列表：
GET /nacos/v1/ns/service/list?pageSize=2147483647&groupName=DEFAULT_GROUP&encoding=UTF-8&namespaceId=4c8d085a-d2dc-478c-ac26-2f78b9b95732&pageNo=1 HTTP/1.1
