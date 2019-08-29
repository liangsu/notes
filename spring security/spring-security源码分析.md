# spring security源码分析


## 一、初始化分析

### 1.1 构建类SecurityBuilder
>  WebSecurity、HttpSecurity都是使用的这套构建流程

#### 关键属性：

* Map<Class<? extends Object>, Object> sharedObjects： 共享对象池
* LinkedHashMap<Class<? extends SecurityConfigurer<O, B>>, List<SecurityConfigurer<O, B>>> configurers： 配置列表

#### 构建器类图：
![spring-security构建器类图](E:\学习笔记\spring security\spring-security构建器类图.png)

#### 构建流程：AbstractConfiguredSecurityBuilder#doBuild

```java
protected final O doBuild() throws Exception {
	synchronized (configurers) {
		buildState = BuildState.INITIALIZING;

		beforeInit();
		init(); // 依次调用configurers的init方法

		buildState = BuildState.CONFIGURING;

		beforeConfigure();
		configure(); // 依次调用configurers的configure方法

		buildState = BuildState.BUILDING;

		O result = performBuild();

		buildState = BuildState.BUILT;

		return result;
	}
}
```



### 1.2 WebSecurityConfiguration

#### 功能：
1. 获取所有的SecurityConfigurer类
2. 创建一个WebSecurity，并运用所有的SecurityConfigurer
3. 调用WebSecurity的build()方法构建出一个Servlet的Filter（即：FilterChainProxy），里面包含有所有的SecurityFilterChain
4. 


### 1.3 WebSecurity： 

#### 描述：
* 包含有所有的webSecurityConfigurer，包含WebSecurityConfigurerAdapter

#### 属性：

* 


#### configurers种类：

* WebSecurityConfigurerAdapter
* ResourceServerConfiguration
* AuthorizationServerSecurityConfiguration


#### 构建过程：
* init()
	* WebSecurityConfigurerAdapter： 封装所有的HttpSecurity，并调用其方法WebSecurityConfigurerAdapter#configure(HttpSecurity)，然后注册到WebSecurity中的securityFilterChainBuilders
* configure()
  * WebSecurityConfigurerAdapter：配置WebSecurity，一般用于配置忽略拦截的url等
  * ResourceServerConfiguration：
* performBuild()
	* 将忽ignoredRequests封装为DefaultSecurityFilterChain（实现了接口SecurityFilterChain）
	* 调用HttpSecurity的build()方法，构建出一个DefaultSecurityFilterChain
	* 创建一个`FilterChainProxy`，里面包含有所有的`SecurityFilterChain`

### 1.4 HttpSecurity:

#### 描述：
* 实现接口：SecurityBuilder
* 构建出一个DefaultSecurityFilterChain：默认匹配所有路径，包含有一个Filter列表

#### 属性：
* List<Filter> filters：过滤器
* requestMatcher：一个匹配所有路径的`RequestMatcher`，默认实现`AnyRequestMatcher.INSTANCE`

#### configurers种类：
1. configurers种类有所有继承自AbstractHttpConfigurer的类，如：
	* CsrfConfigurer
	* ExceptionHandlingConfigurer
	* HeadersConfigurer
	* SessionManagementConfigurer
	* SecurityContextConfigurer
	* DefaultLoginPageConfigurer
	* LogoutConfigurer
	* FormLoginConfigurer
	* ExpressionUrlAuthorizationConfigurer
	* ResourceServerSecurityConfigurer
	* OAuth2LoginConfigurer
	
	
#### 构建过程：
1. init()
	
	* FormLoginConfigurer：
	* DefaultLoginPageConfigurer：设置共享对象DefaultLoginPageGeneratingFilter
	* HeadersConfigurer、SessionManagementConfigurer： 无操作
	* OAuth2LoginConfigurer：设置ExceptionHandlingConfigurer的没有访问权限的时候的重定向的登录页面等
	
2. beforeConfigure()

* 从共享对象池中获取AuthenticationManagerBuilder，并调用其build()方法，构建出AuthenticationManager，然后放入共享对象池
	
3. configure()
	
	* 作用：添加各种配置的Filter，认证的增加认证的Filter，session管理的增加session管理的Filter
	* FormLoginConfigurer：增加UsernamePasswordAuthenticationFilter，登录、登出的拦截器
	* ExpressionUrlAuthorizationConfigurer： 增加FilterSecurityInterceptor，用于拦截登录了的请求，判断哪些路径是否有权限，没有登录直接没权限访问，匿名用户有访问权限
	* DefaultLoginPageConfigurer: 增加DefaultLoginPageGeneratingFilter、DefaultLogoutPageGeneratingFilter
	* LogoutConfigurer： 增加LogoutFilter
	* SessionManagementConfigurer：增加SessionManagementFilter
	* ResourceServerSecurityConfigurer：增加OAuth2AuthenticationProcessingFilter
	* OAuth2LoginConfigurer： 增加OAuth2AuthorizationRequestRedirectFilter、OAuth2LoginAuthenticationFilter
	
3. performBuild()
	* 以filters、requestMatcher为参数，创建DefaultSecurityFilterChain
   




   
OAuth2ClientContextFilter
OAuth2AuthorizationRequestRedirectFilter： 判断是否重定向到第三方去登录
OAuth2LoginAuthenticationFilter： 获取token、userinfo
   

ClientRegistration
clientRegistrationRepository
OAuth2AuthorizationRequest
authorizationRequestRepository

DefaultOAuth2UserService



<GET http://localhost:8001/auth/user/me,[Accept:"application/json", Authorization:"Bearer e86b0df1-4f75-40bc-bc2a-cd44299fc193"]>
   



   
