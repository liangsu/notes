# ConfigurationClassParser

简介：
这个类用于解析被`@configuration`注解的类，将解析的结果放到`ConfigurationClass`中，一个配置类（被`@configuration`注解的类）可能会解析出多个`ConfigurationClass`，
因为这个配置类中可能通过使用`@Import`导入其它的配置类

这个类有助于将解析配置类结构的关注点与基于模型内容注册BeanDefinition对象的关注点分离开来(需要立即注册的{@code @ComponentScan}注释除外)

这个基于asn的实现避免了反射和急于加载类，以便与Spring ApplicationContext中的延迟类加载有效地互操作

ConfigurationClassBeanDefinitionReader
