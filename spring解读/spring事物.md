# spring事物  sql缓存



TransactionAutoConfiguration

DataSourceTransactionManagerAutoConfiguration

DataSourceAutoConfiguration

org.apache.ibatis.executor.resultset.DefaultResultSetHandler#handleRowValuesForSimpleResultMap

org.apache.ibatis.executor.resultset.DefaultResultSetHandler#getRowValue()


org.apache.ibatis.executor.resultset.DefaultResultSetHandler#handleResultSets


MybatisPlusAutoConfiguration

ResultSet:
	wasNull(): 判断是否为空，获取的值是否为默认值，依据这个判断
	

	getType(): 能够向前、向后遍历


​	

`@EnableTransactionManagement`导入了spring事务的一些配置

aop相关：

 * `BeanFactoryTransactionAttributeSourceAdvisor`：将这个类注册到spring容器中，利用了spring aop的功能。在创建bean的时候执行BeanPostProcessor的创建代理的方法的时候，会为bean寻找interceptor，就能够找到这个类作为advice。

    * 属性`TransactionAttributeSource`的方法`getTransactionAttribute`有判断该advice是否适用于某个类。这个方法内部有判断该方法上面是否有`@transaction`注解
    * 属性`TransactionInterceptor` 该类是spring aop中的advice，在该方法中有判断事务开启、提交、回滚相关的代码

   

##

1. 场景1

更新了数据
删除缓存
再拿去缓存

2. 场景2

插入一条
获取这条
事务回滚了



















