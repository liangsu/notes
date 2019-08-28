# spring security

参考： https://my.oschina.net/liuyuantao/blog/1922049


## 1. 基于数据库的验证的调用流程

1.  调用类关系链
    * AbstractAuthenticationProcessingFilter#doFilter()
      * 判断是否需要验证权限
      * 认证通过后的session策略，SecurityContextHolder的设置
      * 登陆失败/成功后的处理，例如remeber me的cookie处理
      * 登陆成功后还是否需要继续执行拦截器链
    * UsernamePasswordAuthenticationFilter#attemptAuthentication()
      * 获取请求中的登录名、密码等其他，封装为对象UsernamePasswordAuthenticationToken
      * 调用AuthenticationManager的认证方法
    * ProviderManager#authenticate()
      * 该类实现了AuthenticationManager接口
      * 该类中包含所有的AuthenticationProvider认证器，遍历所有的认证器，查看哪个认证器支持上一步封装的Authentication认证对象的认证，并执行认证
      * 如果上一步没有得到认证结果，调用父AuthenticationManager的认证
      * 认证通过后的事件通知
    * AbstractUserDetailsAuthenticationProvider#authenticate()
      * 支持认证的类为：UsernamePasswordAuthenticationToken
      * 加入了缓存机制UserCache，默认为空缓存实现
      * 检查账户是否锁定、禁用、过期
      * 密码加密及密码是否正确的检查
      * 检查账户的证书credentials是否过期
      * 封装返回的Authentication对象
    * DaoAuthenticationProvider#retrieveUser()
      * 调用UserDetailsService#loadUserByUsername()的方法
    * UserDetailsService#loadUserByUsername()
      * 一般用户自己实现，调用数据库查询用户
2.  调用类图： ![基于数据库用户的验证流程](E:\学习笔记\spring security\基于数据库用户的验证流程.jpg)





## 2.实现记住我的功能

```java
@Configuration
@EnableWebSecurity
public class WebSecurityConfig extends WebSecurityConfigurerAdapter {
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http
            .rememberMe()
                .key("unique-and-secret")
                .rememberMeCookieName("remember-me-cookie-name")
                .tokenRepository(persistentTokenRepository())
                .tokenValiditySeconds(24 * 60 * 60);
    }
    @Bean
    public PersistentTokenRepository persistentTokenRepository() {
        return new InMemoryTokenRepositoryImpl();
    }
}
```


## 问题记录

1. 资源服务器调用认证服务器的check_token的时候报错： Client not valid: [clientId]
* 导致过程： 在调用InMemoryClientDetailsService#loadClientByClientId的时候没有根据clientId获取到客户端信息
* 解决办法：
	* 待定
	* 猜测：感觉和类的加载先后顺序有关，如果方法`AuthorizationServerConfigurerAdapter#configure(ClientDetailsServiceConfigurer)`能先执行于AuthorizationServerEndpointsConfiguration的实例化就没问题
	* 在注解：EnableAuthorizationServer -> AuthorizationServerSecurityConfiguration -> ClientDetailsServiceConfiguration 的配置类中，有延迟获取ClientDetailsService的方法
	






   

   

   

   

   

   

   

   

   
