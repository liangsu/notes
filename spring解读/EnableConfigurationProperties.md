# @EnableConfigurationProperties注解

1. 解析流程
2. PropertySourcesPlaceholderConfigurer

## 1. 解析流程

1. 通过@EnableConfigurationProperties导入EnableConfigurationPropertiesRegistrar

2.  EnableConfigurationPropertiesRegistrar的作用

* 注册ConfigurationPropertiesBindingPostProcessor的beanDefinition
* 注册`BoundConfigurationProperties`的beanDefinition
* 注册MethodValidationExcludeFilter的beanDefinition
* 将EnableConfigurationProperties的value的class注册为bd

```
EnableConfigurationPropertiesRegistrar{

	public registerBeanDefinitions(){
		// 注册beanDefinition
		ConfigurationPropertiesBindingPostProcessor
		ConfigurationPropertiesBinder.Factory
		ConfigurationPropertiesBinder
		BoundConfigurationProperties
		MethodValidationExcludeFilter
		将EnableConfigurationProperties的value的class注册为bd
	}
}
```

3. `ConfigurationPropertiesBinder`的作用：
* 从ApplicationContext中获取`PropertySourcesPlaceholderConfigurer`对象，进而获取对properties文件的引用`PropertySources`
* `PropertySources`是PropertySource的集合，持有对properties文件的引用。
* 提炼的相关代码：

```
class ConfigurationPropertiesBinder{
	
	ConfigurationPropertiesBinder(ApplicationContext applicationContext) {
		// 从ApplicationContext中获取`PropertySourcesPlaceholderConfigurer`对象，进而获取对properties文件的引用`PropertySources`
		this.propertySources = new PropertySourcesDeducer(applicationContext).getPropertySources();
		
		this.configurationPropertiesValidator = getConfigurationPropertiesValidator(applicationContext);
		this.jsr303Present = ConfigurationPropertiesJsr303Validator.isJsr303Present(applicationContext);
	}

}

class PropertySourcesDeducer{
	
	PropertySources getPropertySources() {
		// 由 <context:property-placeholder location="classpath:xxx.properties"/> 标签解析出的对象
		PropertySourcesPlaceholderConfigurer configurer = getSinglePropertySourcesPlaceholderConfigurer();
		if (configurer != null) {
			return configurer.getAppliedPropertySources();
		}
		MutablePropertySources sources = extractEnvironmentPropertySources();
		Assert.state(sources != null,
				"Unable to obtain PropertySources from PropertySourcesPlaceholderConfigurer or Environment");
		return sources;
	}
}
```

4. `PropertySourcesPlaceholderConfigurer`：

4.1 由来
* 在ContextNamespaceHandler解析标签`<context:property-placeholder locaton='xxxx.properties' />`的时候，
	会由`PropertyPlaceholderBeanDefinitionParser`注册一个`PropertySourcesPlaceholderConfigurer`的BeanDefinition

4.2 作用：
* 它的父类`PropertiesLoaderSupport`负责读取properties文件，并合并内容重复key的内容，关键方法`mergeProperties()`

* 

```
class PropertySourcesPlaceholderConfigurer{

	// 获取对properties文件的引用
	public PropertySources getAppliedPropertySources() throws IllegalStateException {
		return this.appliedPropertySources;
	}
}


class PropertiesLoaderSupport{

	mergeProperties(){
		// 读取properties文件的内容等操作
	}
}
```

5. ConfigurationPropertiesBindingPostProcessor


 














