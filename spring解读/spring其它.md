# spring其它

## Configuration作用：
> 参考： https://www.cnblogs.com/duanxz/p/7493276.html

### @Configuation加载Spring方法

1. 相当于配置文件<beans>标签，可用于配置spring容器(应用上下文)。SpringBootApplication复合注解中就包含Configuration注解

2. @Configuration启动容器+@Bean注册Bean，@Bean下管理bean的生命周期
	* @Bean相当于配置文件的<bean>标签

3. @Configuration启动容器 + @ComponentScan + @Component 实现注册bean

4. 使用 AnnotationConfigApplicationContext 注册 AppContext 类的两种方法

	* 配置类的注册方式是将其传递给 AnnotationConfigApplicationContext 构造函数
	```java
	public static void main(String[] args) {
        // @Configuration注解的spring容器加载方式，用AnnotationConfigApplicationContext替换ClassPathXmlApplicationContext
        ApplicationContext context = new AnnotationConfigApplicationContext(TestConfiguration.class);

        //获取bean
        TestBean tb = (TestBean) context.getBean("testBean");
        tb.sayHello();
    }
	```
	
	* AnnotationConfigApplicationContext 的register 方法传入配置类来注册配置类
	```
	public static void main(String[] args) {
	  ApplicationContext ctx = new AnnotationConfigApplicationContext();
	  ctx.register(AppContext.class)
	}
	```

### 组合多个配置类

1. 在@configuration中引入spring的xml配置文件
```
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.ImportResource;

@Configuration
@ImportResource("classpath:applicationContext-configuration.xml")
public class WebConfig {
}
```

2. 在@configuration中引入其它注解配置
```
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;
import org.springframework.context.annotation.ImportResource;

import com.dxz.demo.configuration.TestConfiguration;

@Configuration
@ImportResource("classpath:applicationContext-configuration.xml")
@Import(TestConfiguration.class)
public class WebConfig {
}
```

3. @configuration嵌套（嵌套的Configuration必须是静态类）
```
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

@Configuration
@ComponentScan(basePackages = "com.dxz.demo.configuration3")
public class TestConfiguration {
    public TestConfiguration() {
        System.out.println("TestConfiguration容器启动初始化。。。");
    }
    
    @Configuration
    static class DatabaseConfig {
        @Bean
        DataSource dataSource() {
            return new DataSource();
        }
    }
}
```

### Spring的@PropertySource + Environment，@PropertySource（PropertySourcesPlaceholderConfigurer）+@Value配合使用

### @EnableXXX注解

1. 配合@Configuration使用，包括 @EnableAsync, @EnableScheduling, @EnableTransactionManagement, @EnableAspectJAutoProxy, @EnableWebMvc。




















