
## 概念
Aspect： 
	切面，跨多个类的关注点的模块化。事务管理是企业级Java应用程序中横切关注点的一个很好的例子。在Spring AOP中，切面是通过使用常规类(基于模式的方法)或使用@Aspect注释的常规类(或者@AspectJ风格)来实现的
	
Join point：
	连接点，程序执行期间的一个点，如方法执行或异常处理期间的一个点。在Spring AOP中，连接点总是表示方法执行。
	某个方法上运行？
	
Advice
	通知（动作），切面在特定连接点上执行的动作。不同类型的advice包括“around”、“before”和“after”的advice。(稍后讨论通知类型。)许多AOP框架(包括Spring)将advice建模为拦截器，并围绕连接点维护拦截器链
	方法之前、之后运行？
		
Pointcut
	切入点，匹配连接点的谓词。通知与切入点表达式相关联，并在与切入点匹配的任何连接点上运行(例如，具有特定名称的方法的执行)。
	与连接点相匹配的切入点是AOP的核心概念，Spring在默认情况下使用AspectJ风格作为切入点表达式。
	
	在那个方法上运行？

Introduction
	代表类型声明其他方法或字段。Spring AOP允许向任何被通知的对象（被代理的对象）引入新的接口(以及相应的实现)。
	例如，您可以使用一个Introduction使一个bean实现一个IsModified接口，以简化缓存。(在AspectJ社区中，Introduction称为inter-type（进入类）的声明。

Target object
	目标对象，被一个或多个切面通知的对象。也称为“advised object”。因为Spring AOP是通过使用运行时代理实现的，所以这个对象经常是一个代理对象。

AOP proxy
	AOP框架为了实现切面(通知方法的执行等等)而创建的对象。在Spring框架中，AOP代理由JDK动态代理或CGLIB代理实现
	
Weaving
	织入，将切面与程序中的类或者对象联系起来创建advised object。这可以在编译时(如AspectJ编译器)、加载时或运行时完成。与其他纯Java AOP框架一样，Spring AOP是在运行时执行织入。


Aspect: A modularization of a concern that cuts across multiple classes. Transaction management is a good example of a crosscutting concern in enterprise Java applications. In Spring AOP, aspects are implemented by using regular classes (the schema-based approach) or regular classes annotated with the @Aspect annotation (the @AspectJ style).

Join point: A point during the execution of a program, such as the execution of a method or the handling of an exception. In Spring AOP, a join point always represents a method execution.

Advice: Action taken by an aspect at a particular join point. Different types of advice include “around”, “before” and “after” advice. (Advice types are discussed later.) Many AOP frameworks, including Spring, model an advice as an interceptor and maintain a chain of interceptors around the join point.

Pointcut: A predicate that matches join points. Advice is associated with a pointcut expression and runs at any join point matched by the pointcut (for example, the execution of a method with a certain name). The concept of join points as matched by pointcut expressions is central to AOP, and Spring uses the AspectJ pointcut expression language by default.

Introduction: Declaring additional methods or fields on behalf of a type. Spring AOP lets you introduce new interfaces (and a corresponding implementation) to any advised object. For example, you could use an introduction to make a bean implement an IsModified interface, to simplify caching. (An introduction is known as an inter-type declaration in the AspectJ community.)

Target object: An object being advised by one or more aspects. Also referred to as the “advised object”. Since Spring AOP is implemented by using runtime proxies, this object is always a proxied object.

AOP proxy: An object created by the AOP framework in order to implement the aspect contracts (advise method executions and so on). In the Spring Framework, an AOP proxy is a JDK dynamic proxy or a CGLIB proxy.

Weaving: linking aspects with other application types or objects to create an advised object. This can be done at compile time (using the AspectJ compiler, for example), load time, or at runtime. Spring AOP, like other pure Java AOP frameworks, performs weaving at runtime.

