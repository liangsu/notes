# spring与mybatis的整合包
实现的功能如下：
1. 将SqlSessionFactory交由spring容器管理
2. 将mapper交由spring容器管理
3. 将事务交由spring管理
4. 增加新功能SqlSessionTemplate


## 一、将SqlSessionFactory交由spring容器管理
1. 由于SqlsessionFactory的创建比较复杂，如果交由spring IOC去装配可能无法实现，所以把SQLSessionFactory交由spring容器去管理是通过类SqlSessionFactoryBean实现的
	* SqlSessionFactoryBean继承自FactoryBean，spring在创建FactoryBean的对象时会做特殊处理，我们在getBean的时候，获取的是FactoryBean调用getObject()得到对象，并且放入了spring的容器中
	* 通过FactoryBean，把SqlSessionFactory的复杂创建过程交由代码实现
2. 在SqlSessionFactory中注入了事务管理器： SpringManagedTransactionFactory


## 二、将mapper交由spring容器管理
### MapperScannerRegistrar
* 功能： 扫描mapper，并注册到spring容器，交由spring管理
* MapperScannerRegistrar实现了接口ImportBeanDefinitionRegistrar，实现了这个接口的类，再配合使用注解@Import(MapperScannerRegistrar.class)，便能在spring初始化的时候调用它
	很幸运，在MapperScan注解中就有使用到Import注解导入MapperScannerRegistrar，所以在使用MapperScan注解的时候，便启用了扫描Mapper注册到spring的功能
*  ClassPathMapperScanner：真正扫描Mapper接口并注册到spring的实现类
	* 继承自ClassPathBeanDefinitionScanner
	* 该类扫描注册的BeanDefinition的默认类都是：MapperFactoryBean
	
### MapperFactoryBean	
* 为mapper接口生成真正实例，并交由spring管理
* 继承自MapperFactoryBean
* 获取真正实例其实是调用的mybatis内部的方法：getSqlSession().getMapper(this.mapperInterface);


## 三、将事务交由spring管理
* spring管理mybatis事务的实现很简单，和mybatis的设计天然的支持将事务交由第三方管理有关

### SpringManagedTransactionFactory
* 继承自mybatis的TransactionFactory
* 当mybatis需要新建一个事务的时候，new一个SpringManagedTransaction对象

### SpringManagedTransaction
* 继承自mybatis的Transaction
* 当需要获取一个连接的时候调用spring-jdbc的方法：DataSourceUtils.getConnection(this.dataSource);
	* DataSourceUtils内部是将一个ThreadLocal变量存储的Connection，这样做之后就相当于获取的连接是从spring获取，从而达到将事务交给spring管理


## 四、增加了SqlSessionTemplate的功能
* 在使用时需要注入SqlSessionFactory，配置文件使用方式如下：
```
<bean id="sqlSessionTemplate" class="org.mybatis.spring.SqlSessionTemplate">
   <constructor-arg ref="sqlSessionFactory" />
</bean>
```
* 在spring boot中有对SqlSessionTemplate的自动注入配置,在类MybatisAutoConfiguration中
```
  @Bean
  @ConditionalOnMissingBean
  public SqlSessionTemplate sqlSessionTemplate(SqlSessionFactory sqlSessionFactory) {
    ExecutorType executorType = this.properties.getExecutorType();
    if (executorType != null) {
      return new SqlSessionTemplate(sqlSessionFactory, executorType);
    } else {
      return new SqlSessionTemplate(sqlSessionFactory);
    }
  }
```



