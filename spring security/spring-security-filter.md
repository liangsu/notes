# 拦截器

## 1.拦截器链：

1. 基础拦截器链，FilterChainProxy可能有多个
DelegatingFilterProxy --> FilterChainProxy --> FilterChainProxy

2. FilterChainProxy中包含有一个拦截器链，spring security基本配置中，默认的filter链15个：
[org.springframework.security.web.context.request.async.WebAsyncManagerIntegrationFilter
org.springframework.security.web.context.SecurityContextPersistenceFilter
org.springframework.security.web.header.HeaderWriterFilter
org.springframework.security.web.csrf.CsrfFilter
org.springframework.security.web.authentication.logout.LogoutFilter
org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter
org.springframework.security.web.authentication.ui.DefaultLoginPageGeneratingFilter
org.springframework.security.web.authentication.ui.DefaultLogoutPageGeneratingFilter
org.springframework.security.web.authentication.www.BasicAuthenticationFilter
org.springframework.security.web.savedrequest.RequestCacheAwareFilter
org.springframework.security.web.servletapi.SecurityContextHolderAwareRequestFilter
org.springframework.security.web.authentication.AnonymousAuthenticationFilter
org.springframework.security.web.session.SessionManagementFilter
org.springframework.security.web.access.ExceptionTranslationFilter
org.springframework.security.web.access.intercept.FilterSecurityInterceptor]

3. 通过注解EnableAuthorizationServer和类AuthorizationServerConfigurerAdapter的认证服务器的默认拦截器链11个：
[org.springframework.security.web.context.request.async.WebAsyncManagerIntegrationFilter
org.springframework.security.web.context.SecurityContextPersistenceFilter
org.springframework.security.web.header.HeaderWriterFilter
org.springframework.security.web.authentication.logout.LogoutFilter
org.springframework.security.web.authentication.www.BasicAuthenticationFilter
org.springframework.security.web.savedrequest.RequestCacheAwareFilter
org.springframework.security.web.servletapi.SecurityContextHolderAwareRequestFilter
org.springframework.security.web.authentication.AnonymousAuthenticationFilter
org.springframework.security.web.session.SessionManagementFilter
org.springframework.security.web.access.ExceptionTranslationFilter
org.springframework.security.web.access.intercept.FilterSecurityInterceptor]

	* 认证服务的filter中并没有做什么特殊的操作，获取token、验证token的操作主要是通过各个FrameworkEndpoint来做的

4. 通过注解EnableResourceServer和类ResourceServerConfigurerAdapter的资源服务器的默认拦截器链11个：
[org.springframework.security.web.context.request.async.WebAsyncManagerIntegrationFilter
org.springframework.security.web.context.SecurityContextPersistenceFilter
org.springframework.security.web.header.HeaderWriterFilter
org.springframework.security.web.authentication.logout.LogoutFilter
org.springframework.security.oauth2.provider.authentication.OAuth2AuthenticationProcessingFilter
org.springframework.security.web.savedrequest.RequestCacheAwareFilter
org.springframework.security.web.servletapi.SecurityContextHolderAwareRequestFilter
org.springframework.security.web.authentication.AnonymousAuthenticationFilter
org.springframework.security.web.session.SessionManagementFilter
org.springframework.security.web.access.ExceptionTranslationFilter
org.springframework.security.web.access.intercept.FilterSecurityInterceptor]
	
	* 新增的filter有：OAuth2AuthenticationProcessingFilter
		* OAuth2AuthenticationManager
		* DefaultTokenServices实现接口AuthorizationServerTokenServices, ResourceServerTokenServices

5. 通过设置httpSecurity的oauth2Login()，的单点登录客户端的默认拦截器链15个：
[org.springframework.security.web.context.request.async.WebAsyncManagerIntegrationFilter
org.springframework.security.web.context.SecurityContextPersistenceFilter
org.springframework.security.web.header.HeaderWriterFilter
org.springframework.security.web.csrf.CsrfFilter
org.springframework.security.web.authentication.logout.LogoutFilter
org.springframework.security.oauth2.client.web.OAuth2AuthorizationRequestRedirectFilter
org.springframework.security.oauth2.client.web.OAuth2LoginAuthenticationFilter
org.springframework.security.web.authentication.ui.DefaultLoginPageGeneratingFilter
org.springframework.security.web.authentication.ui.DefaultLogoutPageGeneratingFilter
org.springframework.security.web.savedrequest.RequestCacheAwareFilter
org.springframework.security.web.servletapi.SecurityContextHolderAwareRequestFilter
org.springframework.security.web.authentication.AnonymousAuthenticationFilter
org.springframework.security.web.session.SessionManagementFilter
org.springframework.security.web.access.ExceptionTranslationFilter
org.springframework.security.web.access.intercept.FilterSecurityInterceptor]

	* 新增的filter有：OAuth2AuthorizationRequestRedirectFilter、OAuth2LoginAuthenticationFilter
	
	
	

## 2.拦截器详解：

1. WebAsyncManagerIntegrationFilter：
作用： 待定

2. SecurityContextPersistenceFilter
作用： 做持久化SecurityContext的工作，可以使用SecurityContextHolder来在其它地方获取到SecurityContext。
持久化策略： 线程级、当前线程传递级、全局（整个jvm就一个）
功能：
	* 从HttpSession中获取SecurityContext，并设置到SecurityContextHolder中
	* 如果没有HttpSession，则不会有SecurityContext

3. HeaderWriterFilter：
作用： 设置返回Header

4. CsrfFilter
作用：防止跨站访问，用于在form表单中生成一个token

5. LogoutFilter
作用： 处理退出登录的请求，定义退出登录做的操作，默认有CsrfLogoutHandler、SecurityContextLogoutHandler

功能：
	* CsrfLogoutHandler：将该请求的token置为空
	* SecurityContextLogoutHandler： 清除所有的session信息，清除SecurityContext中的认证信息
	* 退出登录成功后的处理，默认重定向到某一个页面

6. UsernamePasswordAuthenticationFilter
作用：处理登录验证的请求

7. DefaultLoginPageGeneratingFilter
作用：获取登录页面

8. DefaultLogoutPageGeneratingFilter
作用： 获取退出登录页面

9. BasicAuthenticationFilter

10. RequestCacheAwareFilter

11. SecurityContextHolderAwareRequestFilter

12. AnonymousAuthenticationFilter
作用： 如果没有授权信息，创建一个匿名用户，赋予匿名用户的权限

13. SessionManagementFilter


14. ExceptionTranslationFilter
作用：异常处理

15. FilterSecurityInterceptor
作用：用于拦截登录了的请求，判断哪些路径是否有权限，没有登录直接没权限访问，匿名用户有特定的访问权限

16. OncePerRequestFilter： 
作用： 保证一次请求，即使有多个一样的，只会执行一次这个Filter，一般作为某个拦截器的父类使用，在父类方法中提供了只执行一次的保证机制

17. OAuth2AuthenticationProcessingFilter
作用： 资源服务器特有的，通过token获取相关的用户授权信息等，并设置到SecurityContextHolder的SecurityContext中共享使用

功能：
	* 调用OAuth2AuthenticationManager的授权方法
	* 如果是默认的：调用DefaultTokenServices（实现接口AuthorizationServerTokenServices, ResourceServerTokenServices）的方法，从tokenStore中获取用户授权信息（要求认证服务和资源服务器使用同一个tokenStore）
	* 如果是远程的：调用RemoteTokenServices的方法，从远程获取获取用户授权信息
	
顺序：AbstractPreAuthenticatedProcessingFilter 之前	
	
18. OAuth2AuthorizationRequestRedirectFilter
作用： 如果解析到请求的url链接是要使用第三方登录的请求，则根据配置重定向到第三方。
	原始链接： http://localhost:8002/ui/oauth2/authorization/github
	重定向后： https://github.com/login/oauth/authorize?response_type=code&client_id=79c2dbe37f3ad4e5ff08&state=PSMDezqrYcN-RkHF1WM_u75APppAsJd_AtCV7F0rtQU%3D&redirect_uri=http://localhost:8002/ui/login/oauth2/code/github

19. OAuth2LoginAuthenticationFilter
作用： 根据第三方登录成功后的code，获取access_token、userinfo。SecurityContextHolder的设置等

20. ExceptionTranslationFilter
作用： 详细待定
	* 如果发现没有访问权限，跳转到登录页面
	

## 3.filter默认优先级顺序

1. filter默认优先级顺序，第一个filter的顺序order的值为100，后面的filter步长为100
```
ChannelProcessingFilter
ConcurrentSessionFilter
WebAsyncManagerIntegrationFilter
SecurityContextPersistenceFilter
HeaderWriterFilter
CorsFilter
CsrfFilter
LogoutFilter
org.springframework.security.oauth2.client.web.OAuth2AuthorizationRequestRedirectFilter
X509AuthenticationFilter
AbstractPreAuthenticatedProcessingFilter
org.springframework.security.cas.web.CasAuthenticationFilter
org.springframework.security.oauth2.client.web.OAuth2LoginAuthenticationFilter
UsernamePasswordAuthenticationFilter
ConcurrentSessionFilter
org.springframework.security.openid.OpenIDAuthenticationFilter
DefaultLoginPageGeneratingFilter
DefaultLogoutPageGeneratingFilter
ConcurrentSessionFilter
DigestAuthenticationFilter
org.springframework.security.oauth2.server.resource.web.BearerTokenAuthenticationFilter
BasicAuthenticationFilter
RequestCacheAwareFilter
SecurityContextHolderAwareRequestFilter
JaasApiIntegrationFilter
RememberMeAuthenticationFilter
AnonymousAuthenticationFilter
org.springframework.security.oauth2.client.web.OAuth2AuthorizationCodeGrantFilter
SessionManagementFilter
ExceptionTranslationFilter
FilterSecurityInterceptor
SwitchUserFilter
```











