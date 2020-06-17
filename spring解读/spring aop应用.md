# spring aop

## 编程方式创建aop代理对象

```
public static void aop(){
	AA targeObject = new AA();
	// create a factory that can generate a proxy for the given target object
	AspectJProxyFactory factory = new AspectJProxyFactory(targeObject);

	// add an aspect, the class must be an @AspectJ aspect
	// you can call this as many times as you need with different aspects
	factory.addAspect(LogAspect.class);

	// you can also add existing aspect instances, the type of the object supplied must be an @AspectJ aspect
//  factory.addAspect(usageTracker);

	// now get the proxy object...
	AA proxy = factory.getProxy();
	proxy.aa();
}
```

## PointCut api

1. PointCut
```
public interface Pointcut {

    ClassFilter getClassFilter();

    MethodMatcher getMethodMatcher();

}

public interface ClassFilter {

    boolean matches(Class clazz);
}

public interface MethodMatcher {
	
	// 判断某个类的某个方法是否和pointcut匹配
	// 这个方法的执行是再spring aop代理对象创建的时候执行，避免每次方法调用的时候执行
    boolean matches(Method m, Class targetClass);

	// 用于控制3个参数的matches方法是否执行，如果返回false，3个参数的方法永远不会执行，返回true，3个参数的方法才会在每次方法调用的时候执行
    boolean isRuntime();

	// 这个方法是再每次方法调用的时候执行，通过参数判断是否执行advice
    boolean matches(Method m, Class targetClass, Object[] args);
}
```


ClassFilter用来约束pointcut是否适用某个类。

MethodMatcher：
	`matches(Method, Class)`判断某个类的某个方法是否和pointcut匹配，这个方法的执行是再spring aop代理对象创建的时候执行，避免每次方法调用的时候执行。
	`isRuntime`用于控制3个参数的matches方法是否执行，如果返回false，3个参数的方法永远不会执行，返回true，3个参数的方法才会在每次方法调用的时候执行
	`matches(Method, Class, Object[])`这个方法是再每次方法调用的时候执行，通过参数判断是否执行advice


2. pointcut上的操作

spring支持在pointcut上适用交集、并集。
交集：每个pointcut匹配都可以，并集：任意一个pointcut匹配都可以。你可以使用`Pointcuts`或者`ComposablePointcut`去编排你的pointcut。但是使用aspect的表达式风格的仅支持简单的操作

3. AspectJ Expression Pointcuts （AspectJ表达式的pointcut）

从spring2.0开始pointcut的实现是通过`AspectJExpressionPointcut`，使用了aspject的库提供的表达式风格

4. 便利的pointcut的实现方式

Static Pointcuts：
	静态的pointcut是基于类、方法的匹配来判断，不用通过调用的参数来判断是否匹配。

Regular Expression Pointcuts（正则表达式风格的Pointcuts）：
	实现pointcut的匹配功能的一种方式是使用正则表达式。如`JdkRegexpMethodPointcut`

```
<bean id="settersAndAbsquatulatePointcut" class="org.springframework.aop.support.JdkRegexpMethodPointcut">
    <property name="patterns">
        <list>
            <value>.*set.*</value>
            <value>.*absquatulate</value>
        </list>
    </property>
</bean>
```

	ControlFlowPointcut

## advice api

spring支持几种advice类型，并且可以扩展任意的其它的advice

### Interception Around Advice

在spring中最基本的advice类型是interception around advice

```java
public interface MethodInterceptor extends Interceptor {

    Object invoke(MethodInvocation invocation) throws Throwable;
}

public class DebugInterceptor implements MethodInterceptor {

    public Object invoke(MethodInvocation invocation) throws Throwable {
        System.out.println("Before: invocation=[" + invocation + "]");
        Object rval = invocation.proceed();
        System.out.println("Invocation returned");
        return rval;
    }
}
```

当调用`MethodInvocation`的`proceed`方法时，会沿着拦截器链执行到join point。在执行`proceed`方法的时候有可能会抛出一个异常

### Before Advice

一种简单的advice类型，在执行方法之前调用，它不需要`MethodInvocation`对象。

before advice最大的优点就是不用担心执行`proceed`抛出异常



```java
public interface MethodBeforeAdvice extends BeforeAdvice {

    void before(Method m, Object[] args, Object target) throws Throwable;
}
```



## 使用`ProxyFactoryBean`创建aop代理

使用`ProxyFactoryBean`创建aop最大的好处是advice、pointcuts能够被spring的ioc管理。

与Spring提供的大多数FactoryBean实现一样，ProxyFactoryBean类本身也是一个JavaBean。其属性用于：

	* 指定要代理的对象
	* 指定是否使用cglib



有一些属性继承自`ProxyConfig`（所有的aop代理工厂的父类），它的属性包含以下选项：

	* `proxyTargetClass`：如果代理的是类而不是接口，true则使用cglib代理
	* `optimize`：控制主动优化是否应用于通过CGLIB创建的代理。除非完全理解相关的AOP代理如何处理优化，否则不应该轻率地使用此设置。目前仅用于CGLIB代理。它对JDK动态代理没有影响
	* `frozen`：如果代理配置设置为冻结，则不允许更改配置。当您不希望调用者在创建代理后(通过advised接口)能够操作代理时，这对于轻微的优化是非常有用的。该属性的默认值为false，因此允许进行更改(比如添加额外的advice)
	* `exposeProxy`：决定当前代理类是否暴露到ThreadLocal中，以方便目标对象使用它。如果需要获取代理对象，将这个属性设置为true，目标对象可以调用`AopContext.currentProxy`获取代理对象

其它在`ProxyFactoryBean`上面的属性：

 * `proxyInterfaces`：接口名称的字符串数组，如果没有设置值，将使用cglib代理

 * `interceptorNames`：`Advisor`、interceptor、advice 的字符串数组。顺序很重要，先到先得。列表中的第一个拦截器是第一个能够拦截调用的拦截器

   这些名称是当前工厂中的bean名称，包括来自祖先工厂的bean名称。您不能在这里提到bean引用，因为这样做会导致ProxyFactoryBean忽略通知的单例设置

   interceptor的名称中可以带有`*`星号。与`*`匹配的名称advised bean都会被应用。例如：`global*`表示所有已global开头的advised bean都会被用到

* singleton：无论getObject()方法被调用多少次，工厂是否应该返回单个实例。有几个FactoryBean实现提供了这样的方法。默认值为true。如果你想使用有状态通知—例如，有状态混合—使用原型通知和单例值false。

```xml
<bean id="proxy" class="org.springframework.aop.framework.ProxyFactoryBean">
    <property name="target" ref="service"/>
    <property name="interceptorNames">
        <list>
            <value>global*</value>
        </list>
    </property>
</bean>

<bean id="global_debug" class="org.springframework.aop.interceptor.DebugInterceptor"/>
<bean id="global_performance" class="org.springframework.aop.interceptor.PerformanceMonitorInterceptor"/>
```

## 使用`ProxyFactory`创建aop代理

用Spring编程地创建AOP代理很容易。这使您可以使用Spring AOP而不依赖于Spring IoC

```java
ProxyFactory factory = new ProxyFactory(myBusinessInterfaceImpl);
factory.addAdvice(myMethodInterceptor);
factory.addAdvisor(myAdvisor);
MyBusinessInterface tb = (MyBusinessInterface) factory.getProxy();
```

在`ProxyFactory`（继承自`AdvisedSupport`的方法）上有一些方法添加advice。`AdvisedSupport`是`ProxyFactory`和`ProxyFactoryBean`的父类

## Manipulating Advised Objects（配置advised对象）

无论你怎么创建AOP代理对象，你都可以使用`org.springframework.aop.framework.Advised`接口来配置它们。此接口包括以下方法：

```java
Advisor[] getAdvisors();

void addAdvice(Advice advice) throws AopConfigException;

void addAdvice(int pos, Advice advice) throws AopConfigException;

void addAdvisor(Advisor advisor) throws AopConfigException;

void addAdvisor(int pos, Advisor advisor) throws AopConfigException;

int indexOf(Advisor advisor);

boolean removeAdvisor(Advisor advisor) throws AopConfigException;

void removeAdvisor(int index) throws AopConfigException;

boolean replaceAdvisor(Advisor a, Advisor b) throws AopConfigException;

boolean isFrozen();

```

```java
Advised advised = (Advised) myObject;
Advisor[] advisors = advised.getAdvisors();
int oldAdvisorCount = advisors.length;
System.out.println(oldAdvisorCount + " advisors");

// Add an advice like an interceptor without a pointcut
// Will match all proxied methods
// Can use for interceptors, before, after returning or throws advice
advised.addAdvice(new DebugInterceptor());

// Add selective advice using a pointcut
advised.addAdvisor(new DefaultPointcutAdvisor(mySpecialPointcut, myAdvice));

assertEquals("Added two advisors", oldAdvisorCount + 2, advised.getAdvisors().length);

```

## 使用内置的`auto-proxy`

`org.springframework.aop.framework.autoproxy`包提供有自动代理创建器

##### `BeanNameAutoProxyCreator`



##### `DefaultAdvisorAutoProxyCreator`



## 使用TargetSource

HotSwappableTargetSource

CommonsPool2TargetSource

PrototypeTargetSource

ThreadLocalTargetSource























## 其他
AspectMetadata















