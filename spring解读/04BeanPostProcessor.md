# BeanPostProcessor

>对bean的实例化、初始化做一些改变

1. 整理所有的bpp
2. 整理bpp的注册位置
3. 整理各个bpp的作用
4. bbp的扩展点

## 分类

1. BeanPostProcessor
   * postProcessBeforeInitialization
   * postProcessAfterInitialization
2. SmartInstantiationAwareBeanPostProcessor
   * determineCandidateConstructors
   * getEarlyBeanReference
3. MergedBeanDefinitionPostProcessor
4. InstantiationAwareBeanPostProcessor
	懒加载实例、CommonsPool2TargetSource、ThreadLocalTargetSource、PrototypeTargetSource
	```
	<bean class="org.springframework.aop.framework.autoproxy.BeanNameAutoProxyCreator">
      		<property name="customTargetSourceCreators">
      			<list>
      				<bean class="org.springframework.aop.framework.autoproxy.target.LazyInitTargetSourceCreator"/>        
      			</list>
      		</property>
    </bean>
	```
	
5. 





BeanFactoryAdvisorRetrievalHelperAdapter

ReflectiveAspectJAdvisorFactory

BeanFactoryAspectJAdvisorsBuilderAdapter


调用顺序：
	1. InstantiationAwareBeanPostProcessor
	
	
	2. SmartInstantiationAwareBeanPostProcessor

	MergedBeanDefinitionPostProcessor
		修改合并后的BeanDefinition中的信息，用于后续填充属性等的使用
		
		InstantiationAwareBeanPostProcessor
		
		
		
		
		
		
		
		
		
		


