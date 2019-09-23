# mybatis

mybatis的启动过程，就是SqlSessionFactory的构建过程

## 基础结构：
* org.apache.ibatis.session.Configuration：
	* Environment： 
	* String databaseId： 
		
	* MapperRegistry mapperRegistry： 
	* InterceptorChain：拦截器链
	* TypeHandlerRegistry： 类型注册器
	* TypeAliasRegistry ： 别名注册器
	* LanguageDriverRegistry： 语言驱动注册器
	
	* Map<String, MappedStatement> mappedStatements： 存放sql的类
	* Map<String, Cache> caches： 
	* Map<String, ResultMap> resultMaps
	* Map<String, ParameterMap> parameterMaps
	* Map<String, KeyGenerator> keyGenerators
	
	* Set<String> loadedResources： 所有已经加载过的mapper.xml文件
	* Map<String, XNode> sqlFragments
	
	* Collection<XMLStatementBuilder> incompleteStatements
	* Collection<CacheRefResolver> incompleteCacheRefs
	* Collection<ResultMapResolver> incompleteResultMaps
	* Collection<MethodResolver> incompleteMethods
	
* Environment：
	* TransactionFactory
	* DataSource
	
* InterceptorChain：
	* List<Interceptor> interceptors： 包含有所有的拦截器

* MappedStatement
	* String resource ：
	* Configuration configuration;
	* String id： sql的id
	* Integer fetchSize;
	* Integer timeout;
	* StatementType statementType;
	* ResultSetType resultSetType;
	* SqlSource sqlSource： sql语句
	* Cache cache;
	* ParameterMap parameterMap;
	* List<ResultMap> resultMaps;
	* boolean flushCacheRequired;
	* boolean useCache;
	* boolean resultOrdered;
	* SqlCommandType sqlCommandType;
	* KeyGenerator keyGenerator;
	* String[] keyProperties;
	* String[] keyColumns;
	* boolean hasNestedResultMaps;
	* String databaseId;
	* Log statementLog;
	* LanguageDriver lang;
	* String[] resultSets;

* org.apache.ibatis.session.defaults.DefaultSqlSessionFactory
	* configuration

* MapperProxy
	* Map<Method, MapperMethod/MybatisMapperMethod> methodCache: 存放每个方法的执行sql的方式
	* SqlSession： 一个MapperProxy实例，都会有一个单独的SqlSession实例（是SqlSessionTemplate）
	
* MapperMethod
	* 
	
* SqlSessionTemplate
	* sqlSessionFactory : 作用：在执行sql的时候没有SqlSession时创建一个
	* SqlSession sqlSessionProxy： 真正执行sql的类，是SqlSession的代理类，代理处理类：SqlSessionInterceptor，有创建SqlSession和开启事务的作用，在没有SqlSession的时候会调用sqlSessionFactory创建SqlSession

总结：
1. mybatis的启动过程，首先将所有配置相关的解析到Configuration中，Configuration中包含有mybatis运行中的所有配置。如：sql语句相关的MappedStatement
2. 在创建DefaultSqlSessionFactory时，构造函数有传入Configuration，Configuration在sql执行的过程中也会多次使用到

## 拦截器
* mybatis拦截器讲解： https://www.cnblogs.com/fangjian0423/p/mybatis-interceptor.html
* 存放所有的拦截器： org.apache.ibatis.plugin.InterceptorChain
* 用于获取一个对象的可用拦截器： org.apache.ibatis.plugin.InterceptorChain#pluginAll 
* 判断本拦截器是否适用于某个类： org.apache.ibatis.plugin.Interceptor#plugin
* 判断某个类是否能使用这个拦截器： org.apache.ibatis.plugin.Plugin#wrap ，且Plugin是创建的代理处理器，该类的invoke方法是真正判断是否调用interceptor方法

## mybatis查询执行顺序：
* sqlSessionTemplate执行select查询 -> 获取sqlsessionFactory ------> 开启sqlSession (包含executor) ---> 执行executor的query(4个参数) --> 执行executor的query(6个参数) --> 执行statementHandler.query
```
interceptor3（4个参数）
interceptor2 （4个参数）
	query(6个参数)
interceptor1 (6个参数)
```

## mybatis的mapper
* mapper的代理类： org.apache.ibatis.binding.MapperProxy
* spring与mybatis结合生成mapper的bean类：mapperFactoryBean
* 创建代理对象的工厂： MapperProxyFactory


## sql解析
* 解析类：org.apache.ibatis.builder.SqlSourceBuilder


# mybatis-pagehelper：
* 分页核心类拦截器： com.github.pagehelper.PageInterceptor
* pagehelper拦截器详解： https://github.com/pagehelper/Mybatis-PageHelper/blob/master/wikis/zh/Interceptor.md
* 疑问：既然query(4个参数)的方法，最终会调用query(6个参数)的方法，为什么PageInterceptor不做成只拦截query(6个参数)，这样还不会打乱拦截器的执行顺序


# mybatis-plus: 
* 通过重写sqlSessionFactory类来达到生成简单的crud方法，springboot的默认配置重新类：MybatisPlusAutoConfiguration#sqlSessionFactory
* mapper简单CRUD的xml解析注入接口：com.baomidou.mybatisplus.core.injector.ISqlInjector


* 填充主键： com.baomidou.mybatisplus.core.MybatisDefaultParameterHandler#populateKeys

# mybatis-plus中使用缓存
>> 只有通过id获取对象的方法才使用缓存，其它的update、insert、delete方法清空缓存
* 

				
/*mycat: datanode=dn1*/select count(*) from dth_affair;




1. 将主键字段都改为id，如sys_user表的user_id改为id，
	* 注意修改model.java
	* 注意修改mapper.xml文件，以及使用了这张表的其它xml文件
	* 注意修改页面上的html
2. 将所有的mapper接口类，继承自com.sccl.base.mapper.MybatisMapper


1. 使用mybatis-plus修改分页查询
2. 增加根据id、shardKey的查询方法

	
	

	
	
	
	
1. 部分更新
2. 即使为空也更新
<if test="affairName!= null  and affairName !='' ">	
	
	
<script>
INSERT INTO SYS_USER_GROUP <trim prefix="(" suffix=")" suffixOverrides=",">
id,
<if test="createUserId != null">create_user_id,</if>
<if test="deleted != null">deleted,</if>
<if test="expireTime != null">expire_time,</if>
<if test="createTime != null">create_time,</if>
<if test="name != null">name,</if>
<if test="sign != null">sign,</if>
<if test="structureId != null">structure_id,</if>
<if test="updateTime != null">update_time,</if>
<if test="dead != null">dead,</if>
<if test="type != null">type,</if>
</trim> VALUES <trim prefix="(" suffix=")" suffixOverrides=",">
#{id},
<if test="createUserId != null">#{createUserId},</if>
<if test="deleted != null">#{deleted},</if>
<if test="expireTime != null">#{expireTime},</if>
<if test="createTime != null">#{createTime},</if>
<if test="name != null">#{name},</if>
<if test="sign != null">#{sign},</if>
<if test="structureId != null">#{structureId},</if>
<if test="updateTime != null">#{updateTime},</if>
<if test="dead != null">#{dead},</if>
<if test="type != null">#{type},</if>
</trim>
</script>




