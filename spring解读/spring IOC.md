## spring bean的生命周期Scope：
* spring的生命周期Scope：单例、prototype，其它Scope（如sessionScope、request级别等）
	* spring自带的一些Scope的有：SimpleTransactionScope、SimpleThreadScope、ServletContextScope
	* 或者我们也可以扩展一个自己的Scope级别的，开发流程待定？？？

* 单例的创建： 创建完成之后将创建完成的对象放入一个singletonObjects的map中，之后每次从这个map中获取

* prototype的创建：每次重新创建对象

* 其它Scope级别的创建：其实这就相当于是将创建好的对象放在哪里的问题，如果是session级别的，就放入session中，如果是request级别的就放入request中。后面对象就从session/request中获取对象


## FactoryBean
* 在spring中，如果一个对象实现了FactoryBean接口，那么在创建这个对象的时候后会做特殊处理。如果有一个xxxFactoryBean，在获取的bean时，根据xxx获取到的对象是xxxFactoryBean.getObject()的对象
	根据&xxx获取到的才是FactoryBean对象
* 应用背景： 当你创建的一个对象非常的复杂的时候，通过spring的简单装配功能很难构造出来时，这时你想把装配过程自己实现，但构造出来的对象依然由spring容器管理，就实现FactoryBean接口，在getObject（）编写你构造对象的代码
* 实际应用：
	* mybatis中的：org.mybatis.spring.SqlSessionFactoryBean
	* dubbo中的： com.alibaba.dubbo.config.spring.ReferenceBean
	
	

## BeanFactoryPostProcessor
* 描述：对加载的BeanDefinition进行加工，
* 最经典的配置文件中的${message}进行替换的是：PropertyPlaceholderConfigurer、PropertySourcesPlaceholderConfigurer
* ConfigurationClassPostProcessor 基于注解的扫描









Import ImportBeanDefinitionRegistrar


BeanDefinitionRegistryPostProcessor




