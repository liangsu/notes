# spring BeanDefinition

>个人理解：BeanDefinition是用于存放了spring创建bean的所有信息，在java中创建对象是通过class创建的，在spring容器中，创建bean是通过BeanDefinition创建的。



## 1. BeanDefinition接口

```java
public interface BeanDefinition extends AttributeAccessor, BeanMetadataElement{
}
```

1. `AttributeAccessor`:

   ​	用于存放元数据信息，一些额外的信息，在做一些扩展的时候可以用来存放一些BeanDefinition中没有定义的信息

2. BeanMetadataElement

   ​	用于存放数据源信息source，如：class文件的路径


## 2. BeanDefinition属性

1. parentName：
	
	 在xml中配置中bean的时候指定了parent的时候的名称，用于根据父类创建子类
	
	```xml
	<bean id="parentBean" class="com.Parent" ></bean>
	<bean parent="parentBean">
		<!-- 其它子类的信息 -->
	</bean>
	```
	
2. beanClassName:

   该bean所属的Class，可以在执行BeanFactoryPostProcessor期间修改

3. scope

   作用域，常用的singleton、prototype、request、thread

4. lazyInit

   是否懒加载。作用？

5. dependsOn

   指明Bean在创建之前需要依赖的Bean，可通过`@DependsOn`配置

   例如：A dependsOn B，那么在实例化A之前要先实例化B。

6. autowireCandidate

   在装配过程中是否作为候选对象，**注意**仅仅在根据type进行装配的时候生效，如果是根据name进行装配，这个属性不生效

   ```xml
   <bean class="com.Room"> <!-- 有一个属性人 -->
   </bean>
   
   <!--autowire-candidate:false，代表在byType注入的时候，不会成为候选对象 -->
   <bean class="com.APerson" autowire-candidate="false"></bean>
   <bean class="com.BPerson"></bean>
   ```

7. primary

   装备中的主要的候选对象

8. factoryBeanName

    * 在使用`@Bean`注解的时候，`@bean`注解所在的类的Bean的名称，`@Bean`方法的名称为factoryMethodName。
    * 例子：如下，为User产生的BeanDefinition，factoryBeanName为appConfig，factoryMethodName为createUser

    ```java
    @Confiuration
    class AppConfig{
        @Bean
    	public User createUser(){
            return new User();
        }
    }
    ```

    

9. factoryMethodName

10. ConstructorArgumentValues

11. PropertyValues

12. initMethodName

      Bean生命周期回调的初始化方法

13. destroyMethodName

      Bean生命周期回调的销毁方法

14. role

15. description

      描述，没什么作用

16. 



## 3. BeanDefinition的实现类的区别

1. RootBeanDefinition
   * 作为模板bd（BeanDefinition简称）
   * 真实的bd
   * 不能作为子db，在设置parentName的时候会报错
   
2. ChildBeanDefinition
   
   * 子bd，构造函数中必须传父bd的名称
   
3. GenericBeanDefinition
   * 既可以作为父db，也可以作为子db
   * 真实的bd
   * 通过xml配置扫描出来的bd
   
4. AnnotatedGenericBeanDefinition

   * 加了`@Configuration`，然后使用`AnnotatedBeanDefinitionReader#register(AppConfig.class)`生成的bd

   ```java
   AnnotationConfigApplicationContext ac = 
       new AnnotationConfigApplicationContext(AppConfig.class);
   ```

5. ScannedGenericBeanDefinition

   * 通过`@Componet`注解扫描出来的

6. ConfigurationClassBeanDefinition

   * 通过`@Bean`扫描出来的



扫描、parse、验证、life

## 4. refresh方法

```java
public void refresh() throws BeansException, IllegalStateException {
		synchronized (this.startupShutdownMonitor) {
			// Prepare this context for refreshing.
			prepareRefresh();

			// Tell the subclass to refresh the internal bean factory.
			// 获取内部的BeanFactory、如果是xml的BeanFactory，还会扫描xml为BeanDefinition
			ConfigurableListableBeanFactory beanFactory = obtainFreshBeanFactory();

			// Prepare the bean factory for use in this context.
			// 准备一些初始类：ApplicationContextAwareProcessor
			prepareBeanFactory(beanFactory);

			try {
				// Allows post-processing of the bean factory in context subclasses.
				postProcessBeanFactory(beanFactory);

				// Invoke factory processors registered as beans in the context.
				// 扫描class为BeanDefinition，并调用BeanFactoryPostProcessor
                // 首先调用spring内置的BeanDefinitionRegistryPostProcessor，扫描BeanDefinition，然后再调用其它的BeanFactoryPostProcessor
				// 1. 执行PriorityOrdered的BeanDefinitionRegistryPostProcessor
				// 2. 再执行Ordered的BeanDefinitionRegistryPostProcessor
				// 3. 然后执行没有顺序的BeanDefinitionRegistryPostProcessor
				// 4. 最后递归执行前面扫描出来的BeanDefinitionRegistryPostProcessor
				// 5. 调用BeanDefinitionRegistryPostProcessor的父接口BeanFactoryPostProcessor的方法
				// 6. 按PriorityOrdered、Ordered、无顺序，执行BeanFactoryPostProcessor，跳过前面步骤执行过的BeanDefinitionRegistryPostProcessor
				invokeBeanFactoryPostProcessors(beanFactory);

				// Register bean processors that intercept bean creation.
				// 实例化bpp，并向beanFactory注册bpp
				registerBeanPostProcessors(beanFactory);

				// Initialize message source for this context.
				// 初始化消息
				initMessageSource();

				// Initialize event multicaster for this context.
				// 初始化广播器
				initApplicationEventMulticaster();

				// Initialize other special beans in specific context subclasses.
				// 在特定的context中初始化相关的bean，如在ServletWebServerApplicationContext中创建tomcat服务
				onRefresh();

				// Check for listener beans and register them.
				// 注册监听器
				registerListeners();

				// Instantiate all remaining (non-lazy-init) singletons.
				// 实例化所有单例（非延迟加载的）
				finishBeanFactoryInitialization(beanFactory);

				// Last step: publish corresponding event.
				// spring容器的生命周期回调，如调用LifecycleProcessor.onRefresh
				finishRefresh();
			}

			catch (BeansException ex) {
				if (logger.isWarnEnabled()) {
					logger.warn("Exception encountered during context initialization - " +
							"cancelling refresh attempt: " + ex);
				}

				// Destroy already created singletons to avoid dangling resources.
				destroyBeans();

				// Reset 'active' flag.
				cancelRefresh(ex);

				// Propagate exception to caller.
				throw ex;
			}

			finally {
				// Reset common introspection caches in Spring's core, since we
				// might not ever need metadata for singleton beans anymore...
				resetCommonCaches();
			}
		}
	}
```







obtainFreshBeanFactory()
	获取BeanFactory，没有BeanFactory创建BeanFactory，如果是xml的实现，还会触发解析xml为BeanDefinition
	需要验证???
	

prepareBeanFactory

contextConfigLocation
HttpServlet -> FrameworkServlet -> DispatcherServlet


ConfigurationClassPostProcessor

ConfigurationClassParser 
ConfigurationClass
ComponentScanAnnotationParser
ClassPathBeanDefinitionScanner



AnnotatedBeanDefinitionReader：

​	在spring以注解的方式刚启动的时候，还不知道扫描哪些包，这时候通过调用这个类的register方法，注册spring的配置类（带有@Configuration注解的类）为BeanDefinition，然后再后续spring容器调用refresh方法，执行调用BeanFactoryPostProcessor的时候，根据之前注册的配置bd上的信息，扫描其它的bd





精度spring源码，能对spring做二次开发，对spring的各种扩展点有深刻的理解

BeanFactoryPostProcessor 和它的子接口

ImportBeanDefinitionRegister



depend-check



beanFactoryPostProcessor:

​	spring内部的、自定义的

​	修改bd、注册bd、修改bean工厂





1. bean





