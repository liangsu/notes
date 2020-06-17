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

































## 其他
AspectMetadata















