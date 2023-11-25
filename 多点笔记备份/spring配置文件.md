# spring配置文件变量替换时机

问题：
1. spring配置文件的解析流程是怎样的？
2. @Value与xml中的变量有区别吗？

	
	
## 注解`@PropertySource` `@Value`的解析流程

```
@PropertySource(value = "classpath:application.properties")
public class Tester {

	public static void main(String[] args) throws Exception {
		AnnotationConfigApplicationContext ac = new AnnotationConfigApplicationContext(Tester.class);
	}


@Data
@Component
class TestModel{
    @Value("${spring.datasource.driver-class-name}")
    private String annoStr;
}

}
```

1. 在new AnnotationConfigApplicationContext会注册下面的BeanFactoryPostProcesser：
```
ConfigurationClassPostProcessor
AutowiredAnnotationBeanPostProcessor
CommonAnnotationBeanPostProcessor
PersistenceAnnotationBeanPostProcessor
EventListenerMethodProcessor
DefaultEventListenerFactory
```



2. 创建`StandardEnvironment`，在new AnnotatedBeanDefinitionReader(this) 的时候创建 StandardEnvironment
3. 为配置类注册 AnnotatedGenericBeanDefinition Tester.class

4. 调用`ConfigurationClassPostProcessor`解析 Tester.class

	解析PropertySource的路径
	使用`DefaultPropertySourceFactory`加载文件为`PropertySource`
	添加到`environment`中
	
	MutablePropertySources propertySources = ((ConfigurableEnvironment) this.environment).getPropertySources();
	
5. 在创建bean的时候，调用`AutowiredAnnotationBeanPostProcessor`去替换@Value的值


## xml文件中的占位符替换


```
<beans>
	<context:property-placeholder location="classpath:application.properties" />
	
	<bean id="testModel" class="com.adjust.TestModel">
		<property name="str" value="${spring.datasource.driver-class-name}"></property>
	</bean>
</beans>
```

1. 通过`ContextNamespaceHandler`注册解析器`PropertyPlaceholderBeanDefinitionParser`
2. 在解析xml文件的时候，注册bd：`PropertySourcesPlaceholderConfigurer`
3. 替换BeanDefinition中的变量

```
PropertySourcesPlaceholderConfigurer{

	postProcessBeanFactory(beanFactory){
		// 新建一个多配置源
		this.propertySources = new MutablePropertySources();
		
		// 将环境加入propertySources，以便使用环境中的变量
		propertySources.add(environment);
		
		// 根据 location 读取配置文件
		PropertySource propertySource = mergeProperties()
		// 加入
		propertySources.add(propertySource);
		
		// 替换bd中的property变量
		processProperties(beanFactory, new PropertySourcesPropertyResolver(this.propertySources));
	}
}
```


## springBoot对application.yml配置文件的加载


1. 调用springboot的run方法

2. 发布一个事件`ApplicationEnvironmentPreparedEvent`

3. 事件监听器`ConfigFileApplicationListener` 去加载配置文件`application.yml`


