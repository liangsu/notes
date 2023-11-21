# spring事务源码解析

> 简介： 为了方便理解，防止在无关逻辑花费太多精力，本分析只是抽取了spring事务相关的核心源码的大致逻辑，与源码不一定完全一致

步骤：
1. @[TOC](事务aop的切入时机)
2. @[TOC](spring事务创建、提交、回滚)


## 1. 事务aop的切入时机

1.1 通过`@EnableTransactionManagement`启用事务自动配置，引入配置类`ProxyTransactionManagementConfiguration`
```
@Import(TransactionManagementConfigurationSelector.class)
@EnableTransactionManagement
```

1.2 通过配置类，配置切面、切入点
```
ProxyTransactionManagementConfiguration{
	
	// 只有一个切面的切点advisor
	@Bean
	BeanFactoryTransactionAttributeSourceAdvisor(){}
	
	// 用于解析被调用方法上Transaction注解上的属性，控制事务时用到
	@Bean
	TransactionAttributeSource(){}
	
	// 事务切面，主要实现方法在父类：TransactionAspectSupport
	@Bean
	TransactionInterceptor(){}
}
```

1.3 定义了只有一个切面的advisor
```
BeanFactoryTransactionAttributeSourceAdvisor{

	// 定义切入点: 使用了@Transaction注解的类
	@Override
	public Pointcut getPointcut() {
		return new TransactionAttributeSourcePointcut();
	}

}
```

1.4 切入点的判断类
```
TransactionAttributeSourcePointcut extends StaticMethodMatcherPointcut{
	
	protected TransactionAttributeSourcePointcut() {
		// 设置aop需要代理的类：使用了@Transaction注解的
		setClassFilter(new TransactionAttributeSourceClassFilter());
	}

	// 代理的方法：方法上要有 @Transaction注解
	@Override
	public boolean matches(Method method, Class<?> targetClass) {
		TransactionAttributeSource tas = getTransactionAttributeSource();
		return (tas == null || tas.getTransactionAttribute(method, targetClass) != null);
	}
}
```

## 2. spring事务创建、提交、回滚

2.1 spring事务aop的切面类
```
TransactionAspectSupport{

	invokeWithinTransaction(){
	
		// 创建事务
		status = tm.getTransaction(txAttr);
		
		// 创建事务信息
		TransactionInfo txInfo = new TransactionInfo(tm, txAttr, joinpointIdentification);
		txInfo.newTransactionStatus(status);
				
		Object retVal;
		try {
			// This is an around advice: Invoke the next interceptor in the chain.
			// This will normally result in a target object being invoked.
			// 调用业务方法
			retVal = invocation.proceedWithInvocation();
		}
		catch (Throwable ex) {
			// 如果匹配到回滚类，则回滚事务，否则提交事务
			completeTransactionAfterThrowing(txInfo, ex);
			throw ex;
		}
		
		// 调用tm提交事务
		commitTransactionAfterReturning();
	}

}
```

2.2 spring的抽象事务管理器，管理事务的创建、提交、回滚

```
AbstractPlatformTransactionManager{

	getTransaction(){
		// 获取事务对象
		Object transaction = doGetTransaction();
		
		// 存在事务，则做相应的处理
		if (isExistingTransaction(transaction)) {
			return handleExistingTransaction(def, transaction, debugEnabled);
		}
		
		return startTransaction(def, transaction, debugEnabled, suspendedResources);
	}
	
	startTransaction(definition, transaction, suspendedResources){
		DefaultTransactionStatus status = newTransactionStatus(
				definition, transaction, true, newSynchronization, debugEnabled, suspendedResources);
		// 调用子类的开启事务的方法
		doBegin(transaction, definition);
		return status;
	}
	
	handleExistingTransaction(){
	
		if(PROPAGATION_NOT_SUPPORTED) { // 不需要事务
			
			// 挂起事务，将上一个事务的 连接、事务同步器、名称、是否只读、隔离级别 保存到 suspendedResources
			Object suspendedResources = suspend(transaction);
			
			// 创建新的事务状态
			DefaultTransactionStatus status = newTransactionStatus(
				definition, transaction, newTransaction, newSynchronization, debug, suspendedResources);
			return status;
		}
		
		// 需要开启新事务
		if(PROPAGATION_REQUIRES_NEW){
			// 挂起上一个事务
			SuspendedResourcesHolder suspendedResources = suspend(transaction);
			
			// 开启新事务
			return startTransaction(definition, transaction, debugEnabled, suspendedResources);
		}
		
		// 使用内嵌事务
		if(PROPAGATION_NESTED){ 
		
			// 使用savepoint
			if(useSavepointForNestedTransaction){
				// 创建新的事务状态
				DefaultTransactionStatus status =
							prepareTransactionStatus(definition, transaction, false, false, debugEnabled, null);
				
				// 创建savepoint
				status.createAndHoldSavepoint();
				return status;
			}else{
				// 开启新事务
				return startTransaction(definition, transaction, debugEnabled, null);
			}
		}
		
		// 其它情况（如：使用之前的事务），创建新的事务状态
		DefaultTransactionStatus status = newTransactionStatus(
				definition, transaction, newTransaction, newSynchronization, debug, suspendedResources);
		return status;
	}

}
```

2.3 基于数据源的事务管理器，主要作用数据库连接、真实的提交、回滚事务
```
DataSourceTransactionManager extends AbstractPlatformTransactionManager{
	doGetTransaction(){
		// 创建事务对象
		DataSourceTransactionObject txObject = new DataSourceTransactionObject();
		// 从ThreadLocal中获取当前连接
		ConnectionHolder conHolder = TransactionSynchronizationManager.getResource()
		// 设置到事务对象
		txObject.setConnectionHolder(conHolder, false);
		return txObject
	}

	dobegin(Object transaction, TransactionDefinition definition){
		DataSourceTransactionObject txObject = (DataSourceTransactionObject) transaction;
	
		// 1. 从数据源获取conn
		Connection newCon = obtainDataSource().getConnection();
		
		// 设置事务的连接
		txObject.setConnectionHolder(new ConnectionHolder(newCon), true);
		
		// 绑定连接到ThreadLocal<Map>，防止一个线程有多个事务，map的key是数据源，value是连接
		TransactionSynchronizationManager.bindResource(newCon, obtainDataSource())
	}
	
	doCommit(DefaultTransactionStatus status){
		// 从事务状态获取连接
		DataSourceTransactionObject txObject = (DataSourceTransactionObject) status.getTransaction();
		Connection con = txObject.getConnectionHolder().getConnection();
		// 提交事务
		con.commit();
	}
	
	doRollback(DefaultTransactionStatus status){
		// 从事务状态获取连接
		DataSourceTransactionObject txObject = (DataSourceTransactionObject) status.getTransaction();
		Connection con = txObject.getConnectionHolder().getConnection();
		// 回滚事务
		con.rollback();
	}
}
```

























