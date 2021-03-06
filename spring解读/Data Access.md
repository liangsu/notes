# 数据访问

这部分文档关于在数据访问层与业务层或者service层的交互

本文将详细介绍Spring的事务管理支持，然后全面的讲解数据访问框架的技术以及使用spring框架集成。

# 1. 事务管理

全面的事务支持是使用Spring框架的最引人注目的原因之一。Spring框架为事务管理提供了一致的抽象，它提供了以下好处：

* 为跨不同的事务api提供了一致的编程模型，如java事务接口（JTA）、JDBC、Hibernate和Java Persistence API (JPA) 
* 支持声明式事务管理
* 比复杂的事务管理（如JTA）更简单的编程式事务管理
* 与Spring的数据访问抽象的天然集成

下面的部分描述了Spring框架的事务特性和技术:

* [Spring框架的事务支持模型的优点](#1.1 Spring框架的事务模型的优点)：描述了为什么您将使用Spring框架的事务抽象而不是EJB容器管理的事务(CMT)，或者选择通过专有API(如Hibernate)驱动本地事务。
* [理解Spring框架事务的抽象](#1.2 理解spring事务的抽象)：概括了核心类，并描述如何配置数据源以及如何从各种数据源中获取DataSource
* 事务的资源同步：描述了应用程序代码如何确保正确地创建、重用和清理资源
* 声明性事务管理：描述了对声明性事务管理的支持
* 编程式事务管理：涵盖了对编程(即显式编码)事务管理的支持
* 事务绑定事件：描述如何在事务中使用应用程序事件

本章还包括对最佳实践的讨论，应用服务器集成和常见问题的解决方案

## 1.1 Spring框架的事务模型的优点

传统的Java EE开发人员有两种事务管理选择:全局事务或本地事务，这两种选择都有很大的局限性。接下来的两部分将回顾全局和本地事务管理，然后讨论Spring框架的事务管理支持如何解决全局和本地事务模型的局限性

### 1.1.1 全局事务

全局事务允许您使用多个事务资源，通常是关系数据库和消息队列。应用服务器通过JTA管理全局事务，JTA是一个很麻烦的API(部分原因是它的异常模型)。此外，JTA的`UserTransaction`通常需要来自JNDI，这意味着您还需要使用JNDI才能使用JTA。全局事务的使用限制了任何潜在的应用程序代码重用，因为JTA通常只在应用程序服务器环境中可用

以前使用全局事务的首选方法是通过EJB CMT(Container Managed Transaction)。CMT是声明式事务管理的一种形式(与编程事务管理不同)。EJB CMT消除了对与事务相关的JNDI查找的需要，尽管EJB本身的使用需要使用JNDI。它消除了编写Java代码来控制事务的大部分需求，但不是全部需求。最大的缺点是CMT与JTA和应用服务器环境绑定在一起。而且，只有在选择在EJB中实现业务逻辑(或者至少在事务性EJB外观之后)时，它才可用。EJB的缺点是如此之大，以至于这不是一个有吸引力的提议，特别是在面对声明性事务管理的引人注目的替代方案时

### 1.1.2 本地事务

本地事务是指定了数据源的，例如一个事务关联一个jdbc connection。本地事务可能更容易使用，但有一个明显的缺点:它们不能跨多个事务工作。例如，使用JDBC连接管理事务的代码不能在全局JTA事务中运行。因为应用服务器不参与事务管理，所以它不能帮助确保跨多个资源的正确性。(值得注意的是，大多数应用程序使用单一事务资源。)另一个缺点是，本地事务对编程模型具有侵入性

### 1.1.3 Spring框架的一致编程模型

Spring解决了全局和本地事务的缺点。它允许应用程序开发人员在任何环境中使用一致的编程模型。只需编写一次代码，就可以从不同环境中的不同事务管理策略中获益。Spring框架提供了声明式和编程式事务管理。大多数用户喜欢声明式事务管理，我们在大多数情况下推荐使用它

通过编程事务管理，开发人员使用Spring Framework事务抽象，它可以运行在任何底层事务基础设施上。使用首选声明式模型，开发人员通常只编写很少或根本不编写与事务管理相关的代码，因此不依赖于Spring Framework事务API或任何其他事务API

提示：您是否需要一个应用程序服务器来进行事务管理？

当一个企业Java应用程序需要一个应用服务器时，Spring框架的事务管理支持改变传统的规则。

特别地，您不需要一个纯粹用于通过ejb的声明性事务的应用程序服务器。事实上，即使您的应用服务器具有强大的JTA功能，您也可以认为Spring框架的声明性事务提供了比EJB CMT更强大和更高效的编程模型。

通常，只有当应用程序需要跨多个资源处理事务时，才需要JTA应用服务器功能，而这对许多应用程序来说不是必需的。许多高端应用程序使用单一的、高度可伸缩的数据库(如Oracle RAC)。独立事务管理器(如Atomikos事务和JOTM)是其他选项。当然，您可能需要其他应用服务器功能，如Java消息服务(JMS)和Java EE连接器体系结构(JCA)。Spring框架允许您选择何时将应用程序扩展到完全加载的应用程序服务器。

使用EJB CMT或JTA的唯一替代方法是使用本地事务(如JDBC连接上的事务)编写代码，如果您需要在全局的容器管理的事务中运行代码，那么将面临大量的重做。使用Spring框架，只有配置文件中的一些bean定义需要更改(而不是代码)。

## 1.2 理解spring事务的抽象

Spring事务抽象的关键是事务策略的概念。事务策略由接口`org.springframework.transaction`定义。`PlatformTransactionManager`接口，如下：

```java
public interface PlatformTransactionManager {

    TransactionStatus getTransaction(TransactionDefinition definition) throws TransactionException;

    void commit(TransactionStatus status) throws TransactionException;

    void rollback(TransactionStatus status) throws TransactionException;
}

```

这主要是一个服务提供者接口(service provider interface，简称SPI)，而且您可以从应用程序代码中编程地使用它。由于`PlatformTransactionManager`是一个接口，因此可以根据需要轻松地对其进行降级或剔除。它不绑定到查找策略，比如JNDI。`PlatformTransactionManager`实现的定义类似于Spring Framework IoC容器中的任何其他对象(或bean)。这一优点使Spring框架事务成为有意义的抽象，即使在使用JTA时也是如此。与直接使用JTA相比，测试事务性代码要容易得多

同样，为了符合Spring的理念，`TransactionException`可以由任何`PlatformTransactionManager`接口的方法抛出的没有检查的异常(也就是说，它扩展了`java.lang.RuntimeException`类)。事务基础设施故障几乎总是致命的。在应用程序代码实际上可以从事务失败中恢复的极少数情况下，应用程序开发人员仍然可以选择捕获和处理`TransactionException`。突出的一点是，开发人员并不是被迫这样做。

方法`getTransaction(..)`返回了一个`TransactionStatus`对象，这个方法的形参是`TransactionDefinition`。它的返回值可能是一个新开的事务，也可能返回是一个已经存在的事务（如果再当前方法调用堆栈中存在一个匹配的事务）。后一种情况的含义是，在Java EE事务上下文中，一个`TransactionStatus`关联一个线程。

接口`TransactionDefinition`的说明：

* 传播机制：通常，在事务范围内执行的所有代码都在该事务中运行。但是，如果在事务上下文已经存在的情况下执行事务方法，则可以指定行为。例如，代码可以在现有事务中继续运行(常见情况)，或者可以挂起现有事务并创建一个新事务。Spring提供了EJB CMT中常见的所有事务传播选项。要了解Spring中事务传播的语义，请参阅【事务传播】
* 隔离级别：这个事务与其他事务的工作分离的程度。例如，此事务是否可以看到其他事务未提交的写操作？
* 超时时间：在超时和由底层事务基础设施自动回滚之前，该事务运行了多长时间

* Read-only status：代码读取但不修改数据时，可以使用只读事务。只读事务在某些情况下可能是有用的优化，比如在使用Hibernate时

这些设置反映了标准的事务概念。如果需要，请参阅讨论事务隔离级别和其他核心事务概念的参考资料。理解这些概念对于使用Spring框架或任何事务管理解决方案都是必不可少的

接口`TransactionStatus`为事务代码提供了一种简单的方法来控制事务执行和查询事务状态。这些概念应该很熟悉，因为它们对所有事务api都很常见。下面的清单显示了接口`TransactionStatus`

```java
public interface TransactionStatus extends SavepointManager {

    boolean isNewTransaction();

    boolean hasSavepoint();

    void setRollbackOnly();

    boolean isRollbackOnly();

    void flush();

    boolean isCompleted();
}
```

无论您在Spring中选择声明式事务管理还是编程式事务管理，定义正确的`PlatformTransactionManager`实现都是绝对必要的。您通常通过依赖项注入来定义此实现

`PlatformTransactionManager`实现通常需要了解它们工作的环境:JDBC、JTA、Hibernate等等。下面的示例展示了如何定义本地`PlatformTransactionManager`实现(在本例中，使用纯JDBC)。

```xml
<bean id="dataSource" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
    <property name="driverClassName" value="${jdbc.driverClassName}" />
    <property name="url" value="${jdbc.url}" />
    <property name="username" value="${jdbc.username}" />
    <property name="password" value="${jdbc.password}" />
</bean>
```

相关的`PlatformTransactionManager` bean定义有一个对数据源定义的引用。它应该类似于下面的例子

```xml
<bean id="txManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
    <property name="dataSource" ref="dataSource"/>
</bean>
```

如果您在Java EE容器中使用JTA，那么您将使用通过JNDI获得容器的`DataSource`，并与Spring的`JtaTransactionManager`结合使用。下面的示例显示了JTA和JNDI查找版本的样子:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:jee="http://www.springframework.org/schema/jee"
    xsi:schemaLocation="
        http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/jee
        https://www.springframework.org/schema/jee/spring-jee.xsd">

    <jee:jndi-lookup id="dataSource" jndi-name="jdbc/jpetstore"/>

    <bean id="txManager" class="org.springframework.transaction.jta.JtaTransactionManager" />

    <!-- other <bean/> definitions here -->

</beans>
```

`JtaTransactionManager`不需要知道数据源(或任何其他特定资源)，因为它使用容器的全局事务管理基础结构

提示：数据源bean的前面定义使用`jee`名称空间中的<jndi-lookup/>标记。有关更多信息，请参阅JEE模式。

您还可以轻松地使用`Hibernate`本地事务，如下面的示例所示。在这种情况下，您需要定义Hibernate `LocalSessionFactoryBean`，您的应用程序代码可以使用它来获取`Hibernate`的`session`实例

DataSource bean定义类似于前面显示的本地JDBC示例，因此在下面的示例中没有显示。

提示：如果数据源(由任何非jta事务管理器使用)通过JNDI查找并由Java EE容器管理，那么它应该是非事务性的，因为管理事务的是Spring框架(而不是Java EE容器)。

本例中的txManager bean是HibernateTransactionManager类型。正如DataSourceTransactionManager需要对数据源的引用一样，HibernateTransactionManager需要对SessionFactory的引用。下面的示例声明了sessionFactory和txManager bean

```xml
<bean id="sessionFactory" class="org.springframework.orm.hibernate5.LocalSessionFactoryBean">
    <property name="dataSource" ref="dataSource"/>
    <property name="mappingResources">
        <list>
            <value>org/springframework/samples/petclinic/hibernate/petclinic.hbm.xml</value>
        </list>
    </property>
    <property name="hibernateProperties">
        <value>
            hibernate.dialect=${hibernate.dialect}
        </value>
    </property>
</bean>

<bean id="txManager" class="org.springframework.orm.hibernate5.HibernateTransactionManager">
    <property name="sessionFactory" ref="sessionFactory"/>
</bean>
```

如果你使用Hibernate和Java EE容器管理的JTA事务，你应该使用JtaTransactionManager，就像在前面的JTA例子中一样，如下面的例子所示

```xml
<bean id="txManager" class="org.springframework.transaction.jta.JtaTransactionManager"/>
```

提示：如果您使用JTA，那么您的事务管理器定义应该是相同的，无论您使用什么数据访问技术(JDBC、Hibernate JPA或任何其他支持的技术)。这是因为JTA事务是全局事务，可以征募任何事务资源。

在所有这些情况下，应用程序代码都不需要更改。您可以仅通过更改配置来更改事务的管理方式，即使这种更改意味着从本地事务转移到全局事务，或者从全局事务转移到本地事务。

## 1.3 事务的资源同步（Synchronizing Resources with Transactions）

如何创建不同的事务管理器，以及如何将它们链接到需要同步到事务的相关资源(例如`DataSourceTransactionManager`到JDBC数据源，`HibernateTransactionManager`到Hibernate的`SessionFactory`，等等)，现在应该很清楚了。本节描述应用程序代码(通过使用JDBC、Hibernate或JPA等持久性API直接或间接地)如何确保正确地创建、重用和清理这些资源。本节还讨论了如何通过相关的`PlatformTransactionManager`(可选)触发事务同步。

### 1.3.1 高层的同步方法

首选的方法是使用Spring最高级别的基于模板的持久性集成api，或者使用本地ORM api和事务感知的工厂bean或代理来管理本地资源工厂。这些事务感知解决方案在内部处理资源创建和重用、清理、资源的可选事务同步和异常映射。因此，用户数据访问代码不必处理这些任务，但可以只关注非样板持久性逻辑。通常，使用本机ORM API或通过使用`JdbcTemplate`采用模板方法进行JDBC访问。这些解决方案将在本参考文档的后续章节中详细介绍

### 1.3.2 底层的同步方法

DataSourceUtils(用于JDBC)、EntityManagerFactoryUtils(用于JPA)、SessionFactoryUtils(用于Hibernate)等类是比较底层的。当你想让应用程序代码直接处理原生资源类型的持久性API,您使用这些类来确保适当的Spring Framework-managed实例,事务是(可选)同步的,在这个过程中发生的和异常正确映射到一个一致的API

例如，对于JDBC，您可以使用Spring的`org.springframework.jdbc.datasource.DataSourceUtils`代替调用`DataSource`上的`getConnection()`方法的传统JDBC方法。DataSourceUtils类，如下：

```java
Connection conn = DataSourceUtils.getConnection(dataSource);
```

如果现有事务已经有一个与之同步(关联了一个connection)的connection，则返回该实例。否则，方法调用将触发一个新connection的创建，该连接将(可选地)与任何现有事务同步，并可用于随后在同一事务中重用。如前所述，任何`SQLException`异常都被包装在Spring Framework `CannotGetJdbcConnectionException`中，后者是Spring Framework中未检查的异常`DataAccessException`的子类之一。这种方法提供了比从`SQLException`更容易获得的信息，并确保跨数据库甚至跨不同持久性技术的可移植性

这种方法在没有Spring事务管理的情况下也可以工作(事务同步是可选的)，因此无论是否使用Spring进行事务管理，您都可以使用它。

当然，一旦您使用了Spring的JDBC支持、JPA支持或Hibernate支持，您通常不喜欢使用`DataSourceUtils`或其他辅助类，因为您更喜欢使用Spring抽象而不是直接使用相关api。例如，如果您使用Spring的`JdbcTemplate`或`jdbc.object`包去简化JDBC的使用，因为连接的获取是无感知的，不需要编写任何特殊代码。

### 1.3.3 `TransactionAwareDataSourceProxy`

在最底层存在`TransactionAwareDataSourceProxy`类。这是目标`DataSource`的代理，它包装目标`DataSource`以增加对spring对事务的管理。在这方面，它类似于由Java EE服务器提供的事务性JNDI数据源

除非现有代码必须通过调用标准JDBC `DataSource`接口实现时，您几乎不应该需要或希望使用这个类。在这种情况下，该代码可能是可用的，但参与了spring管理的事务。您可以使用前面提到的高层抽象来编写新代码。

## 1.4 声明式事务管理

> 提示：大多数Spring框架用户选择声明式事务管理。此选项对应用程序代码的影响最小，因此最符合非侵入性轻量级容器的理想

Spring框架的声明式事务管理是通过Spring面向切面编程(AOP)实现的。然而，由于Spring框架发行版附带了事务切面的代码，并且可以以模板方式使用，因此通常不需要理解AOP概念就可以有效地使用这些代码。

Spring框架的声明式事务管理类似于EJB CMT，因为您可以将事务行为(或不指定)指定到单个方法级别。如果需要，可以在事务上下文中进行`setRollbackOnly()`调用。这两种事务管理类型的区别是：

* 与绑定到JTA的EJB CMT不同，Spring框架的声明式事务管理可以在任何环境中工作。通过使用JDBC、JPA或通过调整配置文件Hibernate，它可以处理JTA事务或本地事务。
* 您可以将Spring Framework声明性事务管理应用到任何类，而不仅仅是ejb等特殊类。
* Spring框架提供了声明式[回滚规则]()，这一特性在EJB中没有对应的功能。提供了对回滚规则的编程和声明性支持
* Spring框架允许使用AOP自定义事务行为。例如，您可以在事务回滚的情况下插入自定义的行为。您还可以添加任意advice以及事务性advice。使用EJB CMT，您不能影响容器的事务管理，除非使用`setRollbackOnly()`
* Spring框架不像高端应用服务器那样支持跨远程调用传播事务上下文。如果您需要这个特性，我们建议您使用EJB。但是，在使用这种特性之前要仔细考虑，因为通常不希望事务跨越远程调用。

回滚规则的概念很重要。它们允许您指定哪些exceptions (和throwables)应该导致自动回滚。可以在配置中声明性地指定，而不是在Java代码中。因此，尽管您仍然可以在`TransactionStatus`对象上调用`setRollbackOnly()`来回滚当前事务，但常用方法是您指定一条规则，比如`MyApplicationException`必须回滚事务。此选项的显著优点是业务对象不依赖于事务基础结构。例如，他们通常不需要导入Spring事务api或其他Spring api。

虽然EJB容器默认行为会自动回滚系统异常(通常是运行时异常)上的事务，但是EJB CMT不会自动回滚应用程序异常(即，除了`java.rmi.RemoteException`之外的检查异常)上的事务。虽然声明性事务管理的Spring默认行为遵循EJB约定(仅在未检查的异常上自动回滚)，但是定制这种行为通常很有用

### 1.4.1 理解spring声明式事务管理的实现

仅仅告诉您使用`@Transactional`注解您的类，将`@EnableTransactionManagement`添加到您的配置中，并期望您理解它是如何工作的是不够的。为了加深理解，本节解释了在发生与事务相关的事件时，Spring框架的声明式事务的底层架构的工作方式

关于Spring框架的声明性事务支持，需要掌握的最重要概念是，这种支持是通过AOP代理启用的，事务相关的advice是由元数据(目前是基于XML或注解)驱动的。AOP与事务元数据的结合产生了一个AOP代理，该代理使用`TransactionInterceptor`与适当的`PlatformTransactionManager`实现来围绕方法调用驱动事务

下面的图片显示了在事务代理上调用方法的概念视图:

![](tx.png)

### 1.4.2 声明式事务实现的示例

考虑以下接口及其实现。这个例子使用`Foo`和`Bar`类作为占位符，这样您就可以专注于事务的使用，而不必关注特定的域模型。对于本例来说，`DefaultFooService`类在每个已实现方法的主体中抛出`UnsupportedOperationException`实例是很好的。该行为让您看到事务被创建，然后回滚，以响应`UnsupportedOperationException`实例。下面的清单显示了`FooService`接口

```java
// the service interface that we want to make transactional

package x.y.service;

public interface FooService {

    Foo getFoo(String fooName);

    Foo getFoo(String fooName, String barName);

    void insertFoo(Foo foo);

    void updateFoo(Foo foo);

}
```

*：*下面的例子展示了上述接口的实现:

```java
package x.y.service;

public class DefaultFooService implements FooService {

    @Override
    public Foo getFoo(String fooName) {
        // ...
    }

    @Override
    public Foo getFoo(String fooName, String barName) {
        // ...
    }

    @Override
    public void insertFoo(Foo foo) {
        // ...
    }

    @Override
    public void updateFoo(Foo foo) {
        // ...
    }
}
```

假设`FooService`接口的前两个方法`getFoo(String)`和`getFoo(String, String)`必须在具有只读语义的事务上下文中执行，而其他方法`insertFoo(Foo)`和`updateFoo(Foo)`必须在具有读写语义的事务上下文中执行。下面几段将详细解释下面的配置

```xml
<!-- from the file 'context.xml' -->
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:aop="http://www.springframework.org/schema/aop"
    xmlns:tx="http://www.springframework.org/schema/tx"
    xsi:schemaLocation="
        http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/tx
        https://www.springframework.org/schema/tx/spring-tx.xsd
        http://www.springframework.org/schema/aop
        https://www.springframework.org/schema/aop/spring-aop.xsd">

    <!-- this is the service object that we want to make transactional -->
    <bean id="fooService" class="x.y.service.DefaultFooService"/>

    <!-- the transactional advice (what 'happens'; see the <aop:advisor/> bean below) -->
    <tx:advice id="txAdvice" transaction-manager="txManager">
        <!-- the transactional semantics... -->
        <tx:attributes>
            <!-- all methods starting with 'get' are read-only -->
            <tx:method name="get*" read-only="true"/>
            <!-- other methods use the default transaction settings (see below) -->
            <tx:method name="*"/>
        </tx:attributes>
    </tx:advice>

    <!-- ensure that the above transactional advice runs for any execution
        of an operation defined by the FooService interface -->
    <aop:config>
        <aop:pointcut id="fooServiceOperation" expression="execution(* x.y.service.FooService.*(..))"/>
        <aop:advisor advice-ref="txAdvice" pointcut-ref="fooServiceOperation"/>
    </aop:config>

    <!-- don't forget the DataSource -->
    <bean id="dataSource" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
        <property name="driverClassName" value="oracle.jdbc.driver.OracleDriver"/>
        <property name="url" value="jdbc:oracle:thin:@rj-t42:1521:elvis"/>
        <property name="username" value="scott"/>
        <property name="password" value="tiger"/>
    </bean>

    <!-- similarly, don't forget the PlatformTransactionManager -->
    <bean id="txManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
        <property name="dataSource" ref="dataSource"/>
    </bean>

    <!-- other <bean/> definitions here -->

</beans>
```

检查前面的配置。它假设您想要使service对象`fooService` 具有事务。要应用的事务语义封装在`<tx:advice/>`定义中。`<tx:advice/>`的定义是“以`get`开始的所有方法都在只读事务的上下文中执行，其他所有方法都按照默认事务语义执行”。`<tx:advice/>`的属性`transaction-manager`是指定一个事务管理器`PlatformTransactionManager`（在这个例子中是`txManager`）

> 提示：如果你想要装配的`PlatformTransactionManager`的名称是`transactionManager`，你能够在`<tx:advice/>`中省略掉属性`transaction-manager`。如果你想要装配的`PlatformTransactionManager`的名称是其它情况，你必须指定属性`transactionManager`，就像前面的例子一样

`<aop:config/>`定义确保由txAdvice bean定义的事务通知在程序中的适当位置执行。首先，定义一个切入点，它与`FooService`接口(fooServiceOperation)中定义的任何操作的执行相匹配。然后，通过使用advisor将切入点与`txAdvice`关联起来。结果表明，在执行fooServiceOperation时，将运行由`txAdvice`定义的advice

在`<aop:pointcut/>`元素中定义的表达式是一个AspectJ切入点表达式。有关Spring中的切入点表达式的更多细节，请参阅AOP部分。

一个常见的需求是使整个服务层都是事务性的。最好的方法是更改切入点表达式以匹配服务层中的任何操作。下面的例子展示了如何做到这一点:

```xml
<aop:config>
    <aop:pointcut id="fooServiceMethods" expression="execution(* x.y.service.*.*(..))"/>
    <aop:advisor advice-ref="txAdvice" pointcut-ref="fooServiceMethods"/>
</aop:config>
```

现在我们已经分析了配置，您可能会问自己，“所有这些配置实际上是做什么的?”

前面显示的配置作用：根据`fooService` bean definition的定义来创建对象的时候，创建一个事务代理对象。这个事务代理中有关于事务的advice，以便在调用这个代理对象的时候，根据事务的配置来开启、挂起一个事务或者标记一个只读事务等等。考虑下面的程序，测试运行前面显示的配置：

```java
public final class Boot {

    public static void main(final String[] args) throws Exception {
        ApplicationContext ctx = new ClassPathXmlApplicationContext("context.xml", Boot.class);
        FooService fooService = (FooService) ctx.getBean("fooService");
        fooService.insertFoo (new Foo());
    }
}
```

运行上面程序的输出应该类似于以下内容(为清晰起见，`DefaultFooService`类的`insertFoo(..)`方法抛出的`UnsupportedOperationException`的Log4J输出和堆栈跟踪已经被截断):

```verilog
<!-- the Spring container is starting up... -->
[AspectJInvocationContextExposingAdvisorAutoProxyCreator] - Creating implicit proxy for bean 'fooService' with 0 common interceptors and 1 specific interceptors

<!-- the DefaultFooService is actually proxied -->
[JdkDynamicAopProxy] - Creating JDK dynamic proxy for [x.y.service.DefaultFooService]

<!-- ... the insertFoo(..) method is now being invoked on the proxy -->
[TransactionInterceptor] - Getting transaction for x.y.service.FooService.insertFoo

<!-- the transactional advice kicks in here... -->
[DataSourceTransactionManager] - Creating new transaction with name [x.y.service.FooService.insertFoo]
[DataSourceTransactionManager] - Acquired Connection [org.apache.commons.dbcp.PoolableConnection@a53de4] for JDBC transaction

<!-- the insertFoo(..) method from DefaultFooService throws an exception... -->
[RuleBasedTransactionAttribute] - Applying rules to determine whether transaction should rollback on java.lang.UnsupportedOperationException
[TransactionInterceptor] - Invoking rollback for transaction on x.y.service.FooService.insertFoo due to throwable [java.lang.UnsupportedOperationException]

<!-- and the transaction is rolled back (by default, RuntimeException instances cause rollback) -->
[DataSourceTransactionManager] - Rolling back JDBC transaction on Connection [org.apache.commons.dbcp.PoolableConnection@a53de4]
[DataSourceTransactionManager] - Releasing JDBC Connection after transaction
[DataSourceUtils] - Returning JDBC Connection to DataSource

Exception in thread "main" java.lang.UnsupportedOperationException at x.y.service.DefaultFooService.insertFoo(DefaultFooService.java:14)
<!-- AOP infrastructure stack trace elements removed for clarity -->
at $Proxy0.insertFoo(Unknown Source)
at Boot.main(Boot.java:11)
```

### 1.4.3 回滚一个声明式事务

上一节概述了如何在应用程序中声明性地为类(通常是服务层类)指定事务设置的基础知识。本节描述如何以简单的声明式方式控制事务回滚。

要向Spring框架的事务表明事务的工作要回滚，推荐的方法是从当前在事务上下文中执行的代码中抛出一个`Exception`。Spring框架的事务基础结构代码在捕捉到一个冒泡调用堆栈并时，决定是否将回滚事务。

在其默认配置中，Spring框架的事务基础结构代码只在运行时未检查的异常情况下标记回滚的事务。也就是说，当抛出的异常是`RuntimeException`的实例或子类时。(默认情况下，错误实例也会导致回滚)。从事务方法抛出的已检查异常不会导致默认配置中的回滚。

您可以精确的配置事务回滚的`Exception`异常类型，包括已检查的异常。下面的XML代码片段演示了如何为检查过的、应用程序指定的`Exception`异常类型配置回滚:

```xml
<tx:advice id="txAdvice" transaction-manager="txManager">
    <tx:attributes>
    <tx:method name="get*" read-only="true" rollback-for="NoProductInStockException"/>
    <tx:method name="*"/>
    </tx:attributes>
</tx:advice>
```

如果不希望在抛出异常时回滚事务，还可以指定“无回滚规则”。下面的示例告诉Spring框架的事务基础结构，即使面对未处理的`InstrumentNotFoundException`，也要提交事务：

```xml
<tx:advice id="txAdvice">
    <tx:attributes>
    <tx:method name="updateStock" no-rollback-for="InstrumentNotFoundException"/>
    <tx:method name="*"/>
    </tx:attributes>
</tx:advice>
```

当Spring框架的事务基础结构捕获一个异常并参考配置的回滚规则以确定是否将事务标记为回滚时，最强匹配的规则获胜。因此，在以下配置的情况下，除了`InstrumentNotFoundException`之外的任何异常都会导致相应事务的回滚

```xml
<tx:advice id="txAdvice">
    <tx:attributes>
    <tx:method name="*" rollback-for="Throwable" no-rollback-for="InstrumentNotFoundException"/>
    </tx:attributes>
</tx:advice>
```

您还可以通过编程方式指示所需的回滚。虽然很简单，但是这个过程具有很强的侵入性，并且将您的代码紧密地与Spring框架的事务基础结构结合在一起。下面的示例演示如何以编程方式指示所需的回滚

```java
public void resolvePosition() {
    try {
        // some business logic...
    } catch (NoProductInStockException ex) {
        // trigger rollback programmatically
        TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
    }
}
```

如果可能的话，强烈建议您使用声明式方法进行回滚。编程回滚在您绝对需要的时候是可用的，但是它的使用与实现一个干净的基于pojo的体系结构是背道而驰的。

### 1.4.4 为不同的Beans配置不同的事务语义

考虑这样一个场景:您有许多服务层对象，并且希望对每个对象应用完全不同的事务配置。可以通过使用不同的`pointcut`和`advice-ref`属性值定义不同的`<aop:advisor/>`元素来实现。

作为比较，首先假设您的所有服务层类都定义在包`x.y.service`中。要使该包(或子包)中定义的类实例以及名称以`Service`结尾的所有bean具有默认的事务配置，您可以编写以下内容

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:aop="http://www.springframework.org/schema/aop"
    xmlns:tx="http://www.springframework.org/schema/tx"
    xsi:schemaLocation="
        http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/tx
        https://www.springframework.org/schema/tx/spring-tx.xsd
        http://www.springframework.org/schema/aop
        https://www.springframework.org/schema/aop/spring-aop.xsd">

    <aop:config>

        <aop:pointcut id="serviceOperation"
                expression="execution(* x.y.service..*Service.*(..))"/>

        <aop:advisor pointcut-ref="serviceOperation" advice-ref="txAdvice"/>

    </aop:config>

    <!-- these two beans will be transactional... -->
    <bean id="fooService" class="x.y.service.DefaultFooService"/>
    <bean id="barService" class="x.y.service.extras.SimpleBarService"/>

    <!-- ... and these two beans won't -->
    <bean id="anotherService" class="org.xyz.SomeService"/> <!-- (not in the right package) -->
    <bean id="barManager" class="x.y.service.SimpleBarManager"/> <!-- (doesn't end in 'Service') -->

    <tx:advice id="txAdvice">
        <tx:attributes>
            <tx:method name="get*" read-only="true"/>
            <tx:method name="*"/>
        </tx:attributes>
    </tx:advice>

    <!-- other transaction infrastructure beans such as a PlatformTransactionManager omitted... -->

</beans>
```

下面的示例展示了如何使用完全不同的事务设置配置两个不同的bean:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:aop="http://www.springframework.org/schema/aop"
    xmlns:tx="http://www.springframework.org/schema/tx"
    xsi:schemaLocation="
        http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/tx
        https://www.springframework.org/schema/tx/spring-tx.xsd
        http://www.springframework.org/schema/aop
        https://www.springframework.org/schema/aop/spring-aop.xsd">

    <aop:config>

        <aop:pointcut id="defaultServiceOperation"
                expression="execution(* x.y.service.*Service.*(..))"/>

        <aop:pointcut id="noTxServiceOperation"
                expression="execution(* x.y.service.ddl.DefaultDdlManager.*(..))"/>

        <aop:advisor pointcut-ref="defaultServiceOperation" advice-ref="defaultTxAdvice"/>

        <aop:advisor pointcut-ref="noTxServiceOperation" advice-ref="noTxAdvice"/>

    </aop:config>

    <!-- this bean will be transactional (see the 'defaultServiceOperation' pointcut) -->
    <bean id="fooService" class="x.y.service.DefaultFooService"/>

    <!-- this bean will also be transactional, but with totally different transactional settings -->
    <bean id="anotherFooService" class="x.y.service.ddl.DefaultDdlManager"/>

    <tx:advice id="defaultTxAdvice">
        <tx:attributes>
            <tx:method name="get*" read-only="true"/>
            <tx:method name="*"/>
        </tx:attributes>
    </tx:advice>

    <tx:advice id="noTxAdvice">
        <tx:attributes>
            <tx:method name="*" propagation="NEVER"/>
        </tx:attributes>
    </tx:advice>

    <!-- other transaction infrastructure beans such as a PlatformTransactionManager omitted... -->

</beans>
```

### 1.4.5  配置`<tx:advice/> `

本节总结了使用`<tx:advice/>`标记可以指定的各种事务设置。默认`<tx:advice/>`设置为:

* 传播机制propagation：`REQUIRED`
* 隔离级别：`DEFAULT`
* 事务时读写事务
* 事务超时默认为基础事务系统的默认超时，如果不支持超时，则为none。
* 任何`RuntimeException`都会触发回滚，而任何检查过的异常则不会

您可以更改这些默认设置。下表总结了`<tx:advice/>`和`<tx:attributes/>`标签内嵌的`<tx:method/>`标签的各种属性:

`<tx:method/>`的设置：

|       属性        | 是否必填 | 默认值  | 描述                                                         |
| :---------------: | -------- | ------- | :----------------------------------------------------------- |
|       name        | YES      |         | 要与事务属性关联的方法名。通配符(*)可用于将相同的事务属性设置与许多方法(例如，get*、handle*、on*Event，等等)关联起来。 |
|    propagation    | No       |         | 事务的传播级别                                               |
|     isolation     | No       | DEFAULT | 事务的隔离级别。仅适用于`REQUIRED`或`REQUIRES_NEW`的传播级别。 |
|      timeout      | No       | -1      | 事务超时时间。仅适用于`REQUIRED`或`REQUIRES_NEW`的传播级别。 |
|    `read-only`    | No       |         | 读写事务或者只读事务。仅适用于`REQUIRED`或`REQUIRES_NEW`的传播级别。 |
|  `rollback-for`   | No       | false   | 用逗号隔开的需要回滚的异常。例如：`com.foo.MyBusinessException,ServletException` |
| `no-rollback-for` | No       |         | 用逗号隔开的不需要回滚的异常。例如：`com.foo.MyBusinessException,ServletException` |

### 1.4.6 `@Transactional`的使用

除了事务配置的基于xml的声明式方法外，还可以使用基于注解的方法。在Java源代码中直接声明事务语义使声明更接近受影响的代码。不适当耦合的危险不大，因为本来应该以事务方式使用的代码几乎总是以这种方式部署的