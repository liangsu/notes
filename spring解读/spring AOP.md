## 
* 启用spring aop方式
	* 注解：	@EnableAspectJAutoProxy
	* 配置文件：<aop:aspectj-autoproxy/>
	

* 代理增强核心类： org.springframework.aop.aspectj.annotation.AnnotationAwareAspectJAutoProxyCreator

* 获取暴露的代理对象： AopContext

## 切点pointcut
* spring在扫描到pointcut配置时，会为pointcut生成一个RootBeanDefinition，beanClass是AspectJExpressionPointcut，Scope是prototype

## 通知器advisor
* spring在扫描到advisor配置时，会为pointcut生成一个RootBeanDefinition，beanClass是DefaultBeanFactoryPointcutAdvisor，Scope是singleton
* spring还会根据注解了@aspect的类，生成advisor

## 通知advice
* spring在扫描到advisor配置时，会为pointcut生成一个RootBeanDefinition，beanClass是AspectJMethodBeforeAdvice、AspectJAfterAdvice、AspectJAfterReturningAdvice、AspectJAfterThrowingAdvice、AspectJAroundAdvice中的一个，Scope是singleton




## ScopedProxyFactoryBean


InstantiationModelAwarePointcutAdvisorImpl



targetSourcedBeans
earlyProxyReferences
advisedBeans
proxyTypes


问题： 
1. 基于注解的扫描是怎么实现的？哪个地方创建的切面的BeanDefinition
2. AoP的BeanPostProcess在哪些位置发挥了作用:1/4/8主要在BeanPostProcessor.postProcessAfterInitialization上发挥的作用，
3. InstantiationAwareBeanPostProcessor.postProcessBeforeInstantiation的作用与应用场景？


实例化 Instantiation
初始化 Initialization


## spring beanPostProcessor调用链：
1. AbstractAutowireCapableBeanFactory#createBean() ----> applyBeanPostProcessorsBeforeInstantiation()： InstantiationAwareBeanPostProcessor.postProcessBeforeInstantiation() 循环调用返回结果不会空就结束循环调用
2. AbstractAutowireCapableBeanFactory#doCreateBean() ----> createBeanInstance() ----> determineConstructorsFromBeanPostProcessors()：	SmartInstantiationAwareBeanPostProcessor.determineCandidateConstructors()
3. AbstractAutowireCapableBeanFactory#doCreateBean() ----> applyMergedBeanDefinitionPostProcessors()：	MergedBeanDefinitionPostProcessor.postProcessMergedBeanDefinition()
4. AbstractAutowireCapableBeanFactory#doCreateBean() ----> getEarlyBeanReference()：	SmartInstantiationAwareBeanPostProcessor.getEarlyBeanReference()  循环调用返回结果为空就结束循环调用
5. AbstractAutowireCapableBeanFactory#populateBean()： InstantiationAwareBeanPostProcessor.postProcessAfterInstantiation() 填充属性时 ，循环调用返回结果为false就结束循环调用
6. AbstractAutowireCapableBeanFactory#populateBean()： InstantiationAwareBeanPostProcessor.postProcessPropertyValues()
7. AbstractAutowireCapableBeanFactory#initializeBean() ----> applyBeanPostProcessorsBeforeInitialization()：	BeanPostProcessor.postProcessBeforeInitialization()
8. AbstractAutowireCapableBeanFactory#initializeBean() ----> applyBeanPostProcessorsAfterInitialization()： BeanPostProcessor.postProcessAfterInitialization()


1/4/8
