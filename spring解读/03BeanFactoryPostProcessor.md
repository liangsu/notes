# BeanFactoryPostProcessor

>



1. 作用：

## 1. 相关类

1. BeanDefinitionRegistryPostProcessor
   * 继承自BeanFactoryPostProcessor
   * spring内部的唯一实现内：ConfigurationClassPostProcessor
2. ConfigurationClassPostProcessor
   * 作用：扫描带有`@Configuration`注解的类生成BeanDefinition，扫描

## 2. BeanFactoryPostProcessor调用过程

> BeanFactoryPostProcessor的关键调用代码在：PostProcessorRegistrationDelegate#invokeBeanFactoryPostProcessors()中

1. 首先调用接口`BeanDefinitionRegistryPostProcessor`的`postProcessBeanDefinitionRegistry`方法，调用顺序是先调用实现了接口`PriorityOrdered`，然后调用实现接口`Ordered`，最后调用没有实现排序接口的。
   * 目的：在spring内部唯一实现了接口`BeanDefinitionRegistryPostProcessor`的内是`ConfigurationClassPostProcessor`，这一步的目的是为了先扫描出基于注解中的所有的`BeanDefinition`
   
   * spring内部默认的`BeanDefinitionRegistryPostProcessor`注册为`BeanDefinition`的位置：`AnnotatedBeanDefinitionReader`的构造方法中
   
   * 新版mybatis的扩展有基于`BeanDefinitionRegistryPostProcessor`的实现来注册mapper
   
     
   
2. 调用`BeanDefinitionRegistryPostProcessor`的`postProcessBeanFactory`方法

   

3. 调用普通的`BeanFactoryPostProcessor`，调用顺序：`PriorityOrdered` > `Ordered` > `其它`

```java
public static void invokeBeanFactoryPostProcessors(
			ConfigurableListableBeanFactory beanFactory, List<BeanFactoryPostProcessor> beanFactoryPostProcessors) {

		// Invoke BeanDefinitionRegistryPostProcessors first, if any.
		Set<String> processedBeans = new HashSet<>();

		if (beanFactory instanceof BeanDefinitionRegistry) {
			BeanDefinitionRegistry registry = (BeanDefinitionRegistry) beanFactory;
			List<BeanFactoryPostProcessor> regularPostProcessors = new ArrayList<>();
			List<BeanDefinitionRegistryPostProcessor> registryProcessors = new ArrayList<>();

			for (BeanFactoryPostProcessor postProcessor : beanFactoryPostProcessors) {
				if (postProcessor instanceof BeanDefinitionRegistryPostProcessor) {
					BeanDefinitionRegistryPostProcessor registryProcessor =
							(BeanDefinitionRegistryPostProcessor) postProcessor;
					registryProcessor.postProcessBeanDefinitionRegistry(registry);
					registryProcessors.add(registryProcessor);
				}
				else {
					regularPostProcessors.add(postProcessor);
				}
			}

			// 分开调用BeanDefinitionRegistryPostProcessors，根据接口PriorityOrdered、Ordered、其它的顺序调用
			// Do not initialize FactoryBeans here: We need to leave all regular beans
			// uninitialized to let the bean factory post-processors apply to them!
			// Separate between BeanDefinitionRegistryPostProcessors that implement
			// PriorityOrdered, Ordered, and the rest.
			List<BeanDefinitionRegistryPostProcessor> currentRegistryProcessors = new ArrayList<>();

			// First, invoke the BeanDefinitionRegistryPostProcessors that implement PriorityOrdered.
			String[] postProcessorNames =
					beanFactory.getBeanNamesForType(BeanDefinitionRegistryPostProcessor.class, true, false);
			for (String ppName : postProcessorNames) {
				if (beanFactory.isTypeMatch(ppName, PriorityOrdered.class)) {
					// 这里为什么通过beanFactory.getBean调用获取spring内部的BeanDefinitionRegistryPostProcessor，而不是new出来？
					// 答：因为程序员有可能会实现一个BeanDefinitionRegistryPostProcessor，方便扩展
					currentRegistryProcessors.add(beanFactory.getBean(ppName, BeanDefinitionRegistryPostProcessor.class));
					processedBeans.add(ppName);
				}
			}
			sortPostProcessors(currentRegistryProcessors, beanFactory);
			registryProcessors.addAll(currentRegistryProcessors);
			invokeBeanDefinitionRegistryPostProcessors(currentRegistryProcessors, registry);
			currentRegistryProcessors.clear();

			// Next, invoke the BeanDefinitionRegistryPostProcessors that implement Ordered.
			postProcessorNames = beanFactory.getBeanNamesForType(BeanDefinitionRegistryPostProcessor.class, true, false);
			for (String ppName : postProcessorNames) {
				if (!processedBeans.contains(ppName) && beanFactory.isTypeMatch(ppName, Ordered.class)) {
					currentRegistryProcessors.add(beanFactory.getBean(ppName, BeanDefinitionRegistryPostProcessor.class));
					processedBeans.add(ppName);
				}
			}
			sortPostProcessors(currentRegistryProcessors, beanFactory);
			registryProcessors.addAll(currentRegistryProcessors);
			invokeBeanDefinitionRegistryPostProcessors(currentRegistryProcessors, registry);
			currentRegistryProcessors.clear();

			// Finally, invoke all other BeanDefinitionRegistryPostProcessors until no further ones appear.
			boolean reiterate = true;
			// 这里循环调用的目的：调用BeanDefinitionRegistryPostProcessors的方法后，可能还会产生新的BeanDefinitionRegistryPostProcessors
			while (reiterate) {
				reiterate = false;
				postProcessorNames = beanFactory.getBeanNamesForType(BeanDefinitionRegistryPostProcessor.class, true, false);
				for (String ppName : postProcessorNames) {
					if (!processedBeans.contains(ppName)) {
						currentRegistryProcessors.add(beanFactory.getBean(ppName, BeanDefinitionRegistryPostProcessor.class));
						processedBeans.add(ppName);
						reiterate = true;
					}
				}
				sortPostProcessors(currentRegistryProcessors, beanFactory);
				registryProcessors.addAll(currentRegistryProcessors);
				invokeBeanDefinitionRegistryPostProcessors(currentRegistryProcessors, registry);
				currentRegistryProcessors.clear();
			}

			// Now, invoke the postProcessBeanFactory callback of all processors handled so far.
			invokeBeanFactoryPostProcessors(registryProcessors, beanFactory);
			invokeBeanFactoryPostProcessors(regularPostProcessors, beanFactory);
		}

		else {
			// Invoke factory processors registered with the context instance.
			invokeBeanFactoryPostProcessors(beanFactoryPostProcessors, beanFactory);
		}

		// Do not initialize FactoryBeans here: We need to leave all regular beans
		// uninitialized to let the bean factory post-processors apply to them!
		String[] postProcessorNames =
				beanFactory.getBeanNamesForType(BeanFactoryPostProcessor.class, true, false);

		// Separate between BeanFactoryPostProcessors that implement PriorityOrdered,
		// Ordered, and the rest.
		List<BeanFactoryPostProcessor> priorityOrderedPostProcessors = new ArrayList<>();
		List<String> orderedPostProcessorNames = new ArrayList<>();
		List<String> nonOrderedPostProcessorNames = new ArrayList<>();
		for (String ppName : postProcessorNames) {
			if (processedBeans.contains(ppName)) {
				// skip - already processed in first phase above
			}
			else if (beanFactory.isTypeMatch(ppName, PriorityOrdered.class)) {
				priorityOrderedPostProcessors.add(beanFactory.getBean(ppName, BeanFactoryPostProcessor.class));
			}
			else if (beanFactory.isTypeMatch(ppName, Ordered.class)) {
				orderedPostProcessorNames.add(ppName);
			}
			else {
				nonOrderedPostProcessorNames.add(ppName);
			}
		}

		// First, invoke the BeanFactoryPostProcessors that implement PriorityOrdered.
		sortPostProcessors(priorityOrderedPostProcessors, beanFactory);
		invokeBeanFactoryPostProcessors(priorityOrderedPostProcessors, beanFactory);

		// Next, invoke the BeanFactoryPostProcessors that implement Ordered.
		List<BeanFactoryPostProcessor> orderedPostProcessors = new ArrayList<>(orderedPostProcessorNames.size());
		for (String postProcessorName : orderedPostProcessorNames) {
			orderedPostProcessors.add(beanFactory.getBean(postProcessorName, BeanFactoryPostProcessor.class));
		}
		sortPostProcessors(orderedPostProcessors, beanFactory);
		invokeBeanFactoryPostProcessors(orderedPostProcessors, beanFactory);

		// Finally, invoke all other BeanFactoryPostProcessors.
		List<BeanFactoryPostProcessor> nonOrderedPostProcessors = new ArrayList<>(nonOrderedPostProcessorNames.size());
		for (String postProcessorName : nonOrderedPostProcessorNames) {
			nonOrderedPostProcessors.add(beanFactory.getBean(postProcessorName, BeanFactoryPostProcessor.class));
		}
		invokeBeanFactoryPostProcessors(nonOrderedPostProcessors, beanFactory);

		// Clear cached merged bean definitions since the post-processors might have
		// modified the original metadata, e.g. replacing placeholders in values...
		beanFactory.clearMetadataCache();
	}
```

## 3. ConfigurationClassPostProcessor的解析过程

> 该类主要是用于扫描带有configuration的类，根据配置信息扫描注册BeanDefinition。
>
> 如果是基于注解的扫描，或者xml配置文件中带有`<context:annotation-config/>`和`<context:component-scan/>`都会启用解析类

### 3.1 子接口方法postProcessBeanDefinitionRegistry

1. 从BeanDefinitionMap（后续简称bdMap）中拿到所有已经注册的bd，过滤出配置类（带有configuration的类，或者一个component类内部带有configuration/component修饰的类）

2. 解析配置类
   * 首先解析`@Component`注解
   * 解析`@PropertySources`
   * 解析` @ComponentScan`和`@ComponentScans`，根据这两个注解配置的包路径扫描出BeanDefinition，并从扫描出的bd中过滤出配置类，递归调用配置类的解析方法
   * 解析`@Import`
   * 解析`@ImportResource`
   * 解析`@Bean`
   * 如果该类有父类，返回父类，再解析父类

### 3.2 父接口方法postProcessBeanFactory

1. 使用cglib增强带有configuration注解的bd，为这种bd产生代理class，并修改bd的beanClass
   * 增加的切面BeanMethodInterceptor
2. 注册BeanPostProcessor：ImportAwareBeanPostProcessor



ImportBeanDefinitionRegistrar

ImportSelector

DeferredImportSelector

@Import



## 问题记录

spring在解决循环依赖中，放入提前暴露的缓存，为什么是放入一个使用ObjectFactory包裹的对象？

答：在包裹的方法里面有为bean创建代理的步骤

spring的生命周期中有实例化、放入提前暴露的缓存、填充属性、创建代理对象。而spring在解决循环依赖的过程中，是采用前面的步骤，为什么spring在解决循环依赖的时候不采用：实例化、创建代理对象、放入提前暴露的缓存、填充属性的步骤？







