## Aspect Oriented Programming with Spring（面向切面编程）

在程序结构设计中面向切面编程（aop）是对面向对象编程（oop）的补充。在oop中模块化的单元是类，而在aop中模块化的单元时aspect。aspect的模块化关注点横跨了多个类或者对象（如事务管理）。在aop的文献中，这样的关注点通常被称为“crosscutting”（横切）

## 1. AOP概念

让我们从定义一些核心的AOP概念和术语开始。这些术语并不是spring特有的。不幸的是，AOP术语不是特别直观。但是，如果Spring使用自己的术语，会更令人困惑了。

* Aspect：  切面，跨多个类的关注点的模块化。事务管理是企业级Java应用程序中横切关注点的一个很好的例子。在Spring AOP中，切面是通过使用常规类(基于模式的方法)或使用@Aspect注释的常规类(或者@AspectJ风格)来实现的
* Join point： 连接点，程序执行期间的一个点，如方法执行或异常处理期间的一个点。在Spring AOP中，连接点总是表示方法执行。（某个方法上运行）
* Advice： 通知（动作），切面在特定连接点上执行的动作。不同类型的advice包括“around”、“before”和“after”的advice。(稍后讨论通知类型。)许多AOP框架(包括Spring)将advice建模为拦截器，并围绕连接点维护拦截器链（方法之前、之后运行的动作）
* Pointcut：切入点，匹配连接点的谓词。通知与切入点表达式相关联，并在与切入点匹配的任何连接点上运行(例如，具有特定名称的方法的执行)。
  	与连接点相匹配的切入点是AOP的核心概念，Spring在默认情况下使用AspectJ风格作为切入点表达式。（在哪些方法上运行）
* Introduction：声明一个类的额外的方法或者属性。Spring AOP允许向任何被通知的对象（被代理的对象）引入新的接口(以及相应的实现)。例如，您可以使用一个Introduction使一个bean实现一个IsModified接口，以简化缓存。(在AspectJ社区中，Introduction称为inter-type declarations（进入类的声明）。
* Target object： 目标对象，被一个或多个切面通知的对象。也称为“advised object”。因为Spring AOP是通过使用运行时代理实现的，所以这个对象经常是一个代理对象。
* AOP proxy： AOP框架为了实现切面(通知方法的执行等等)而创建的对象。在Spring框架中，AOP代理由JDK动态代理或CGLIB代理实现
* Weaving： 织入，将切面与程序中的类或者对象联系起来创建advised object。这可以在编译时(如AspectJ编译器)、加载时或运行时完成。与其他纯Java AOP框架一样，**Spring AOP是在运行时执行织入**。



## 2. 以编程方式创建aop代理对象

除了使用`<aop:config>`和`<aop:aspectj-autoproxy>`定义切面外，还可以使用编程的方式创建代理对象（advise target object）。

```java
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

## 3. spring aop的api

### 3.1 PointCut api

#### 概念

```java
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

#### pointcut上的操作

spring支持在pointcut上适用交集、并集。
交集：每个pointcut匹配都可以，并集：任意一个pointcut匹配都可以。你可以使用`Pointcuts`或者`ComposablePointcut`去编排你的pointcut。但是使用aspect的表达式风格的仅支持简单的操作

#### AspectJ Expression Pointcuts （AspectJ表达式的pointcut）

从spring2.0开始pointcut的实现是通过`AspectJExpressionPointcut`，使用了aspject的库提供的表达式风格

#### 便利的pointcut的实现方式

Static Pointcuts：
	静态的pointcut是基于类、方法的匹配来判断，不用通过调用的参数来判断是否匹配。

Regular Expression Pointcuts（正则表达式风格的Pointcuts）：
	实现pointcut的匹配功能的一种方式是使用正则表达式。如`JdkRegexpMethodPointcut`

```xml
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

### 3.2 advice api

spring支持几种advice类型，并且可以扩展任意的其它的advice

#### Interception Around Advice

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

#### Before Advice

一种简单的advice类型，在执行方法之前调用，它不需要`MethodInvocation`对象。

before advice最大的优点就是不用担心执行`proceed`抛出异常



```java
public interface MethodBeforeAdvice extends BeforeAdvice {

    void before(Method m, Object[] args, Object target) throws Throwable;
}
```

### 3.3 advisor api

在Spring中，Advisor是aspect，这种aspect只包含一个advice对象，并关联它的pointcut。

除了introductions的特殊情况，advisor可以和任何advice一起使用。`org.springframework.aop.support.DefaultPointcutAdvisor`是最常用的advisor类，它能够和`MethodInterceptor`、`BeforeAdvice`或`ThrowsAdvice`一起使用。

可以在Spring中将advisor和advice类型混合在同一个AOP代理中。例如，您可以在一个代理配置中使用interception around advice, throws advice, and before advice，Spring会自动创建必要的拦截器链。



## 4. 使用`ProxyFactoryBean`创建aop代理

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

## 5. 使用`ProxyFactory`创建aop代理

用Spring编程地创建AOP代理很容易。这使您可以使用Spring AOP而不依赖于Spring IoC

```java
ProxyFactory factory = new ProxyFactory(myBusinessInterfaceImpl);
factory.addAdvice(myMethodInterceptor);
factory.addAdvisor(myAdvisor);
MyBusinessInterface tb = (MyBusinessInterface) factory.getProxy();
```

在`ProxyFactory`（继承自`AdvisedSupport`的方法）上有一些方法添加advice。`AdvisedSupport`是`ProxyFactory`和`ProxyFactoryBean`的父类

## 6. Manipulating Advised Objects（配置advised对象）

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

## 7. 使用内置的`auto-proxy`

`org.springframework.aop.framework.autoproxy`包提供有自动代理创建器

##### `BeanNameAutoProxyCreator`



##### `DefaultAdvisorAutoProxyCreator`



## 8. 使用TargetSource

HotSwappableTargetSource

CommonsPool2TargetSource

PrototypeTargetSource

ThreadLocalTargetSource





## 9. 其他
AspectMetadata















