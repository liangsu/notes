# ConfigurationClassParser

简介：
        这个类用于解析被`@configuration`注解的类，将解析的结果放到`ConfigurationClass`中，一个配置类（被`@configuration`注解的类）可能会解析出多个`ConfigurationClass`，因为这个配置类中可能通过使用`@Import`导入其它的配置类

　　这个类有助于将解析配置类和注册BeanDefinition分离(除了`@ComponentScan`注解需要立即被注册)

　　这个基于asｍ的实现避免了反射和急于加载类，以便与Spring ApplicationContext中的延迟类加载有效地互操作



1. 递归的解析配置类和它的父类
   * 递归解析所有的Component注解（@configuration也是被Component标记的）
   * 解析PropertySources、PropertySource
   * 解析@ComponentScan、ComponentScan，并扫描注册bd，再从扫描出的bd中找出配置类，再次调用【递归的解析配置类和它的父类】
   * 解析@Import注解
     * 如果是`ImportSelector`，调用接口方法，获取所有的类名，再次调用【递归的解析配置类和它的父类】
     * 如果是`DeferredImportSelector`，放入延迟加载的队列里面
     * 如果是`ImportBeanDefinitionRegistrar`，放入队列
     * 如果是普通类，再次调用【递归的解析配置类和它的父类】
   * 解析@ImportResource
   * 解析@Bean methods
   * 解析父类



## 1. `Import`注解

`@import`注解导入的类，可以是普通的类、`ImportSelector`、`DeferredImportSelector`、`ImportBeanDefinitionRegistrar`

如果导入的是普通类，相当于在普通的类上加了一个注解`@Componet`。



### 1.1 `ImportSelector`

1. 常见用途：用于决定启用哪个配置类（被`@configuration`注解的类）

2. 可以实现的下面的这些接口，并且这些接口的方法调用会在`selectImports`之前被调用：
   	*  EnvironmentAware
   	*  BeanFactoryAware
   	*  BeanClassLoaderAware
   	*  ResourceLoaderAware
3. 或者可以提供一个构造函数，带有下面的这些参数类型：
   * Environment
   * BeanFactory
   * ClassLoader
   * ResourceLoader
4. 这个接口的实现类经常和`@Import`一起使用，如果是子接口`DeferredImportSelector`，那么它会推迟到所有的**配置类**都被解析之后执行

### 1.2 `DeferredImportSelector`

1. 这个接口的运行时在所有的配置类解析完成之后运行，当被导入的类标记有`@Conditional`时特别有用
2. 它的实现类还可以实现接口`org.springframework.core.Ordered`、`org.springframework.core.annotation.Order`表名它的执行顺序
3. 它的实现类还可以通过方法`getImportGroup`提供一个`Group`，提供一个排序、过滤的功能

### 1.3 `ImportBeanDefinitionRegistrar`

1. 当解析配置类的时候，可以使用这个类的实现类注册额外的BeanDefinition，这种方式用来在BeanDefinition级别（与方法级别、或者实例级别不同）区分不同的bd
2. 和上面的两个类一样，也是通过`Import`导入
3. 和接口`ImportSelector`、`DeferredImportSelector`一样，也可以实现上面的`Aware`的接口，或者构造函数

