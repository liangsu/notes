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

   ​	用于存放数据源信息，如：class文件的路径


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

   指明Bean在创建之前需要依赖的Bean

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

9. factoryMethodName

10. ConstructorArgumentValues

11. PropertyValues

12. initMethodName

13. destroyMethodName

14. role

15. description

16. 





扫描、parse、验证、life

AttributeAccessor：元数据操作的api

source



obtainFreshBeanFactory()
	获取BeanFactory，没有BeanFactory创建BeanFactory，如果是xml的实现，还会触发解析xml为BeanDefinition
	需要验证
	

prepareBeanFactory

contextConfigLocation
HttpServlet -> FrameworkServlet -> DispatcherServlet


ConfigurationClassPostProcessor

ConfigurationClassParser 
ConfigurationClass
ComponentScanAnnotationParser
ClassPathBeanDefinitionScanner

ScannedGenericBeanDefinition

