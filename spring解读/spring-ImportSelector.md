# spring ImportSelector作用
参考： https://www.cnblogs.com/niechen/p/9262452.html

## 例子

1. 有一个配置类，要作为可选项
```
public class AppConfig {

    @Bean
    public User user(){
        return new User("admin");
    }

}

public class User {
    private String userName;

    public User(String userName) {
        this.userName = userName;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }
}
```

2. 编写ImportSelector
```
public class SpringImportStudySelector implements ImportSelector, BeanFactoryAware {
    private BeanFactory beanFactory;

    @Override
    public String[] selectImports(AnnotationMetadata importingClassMetadata) {
        importingClassMetadata.getAnnotationTypes().forEach(System.out::println);
        System.out.println("-------------");
        System.out.println(beanFactory);
        return new String[]{AppConfig.class.getName()};
    }

    @Override
    public void setBeanFactory(BeanFactory beanFactory) throws BeansException {
        this.beanFactory = beanFactory;
    }
}
```

3. 编写注解
```
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Target(ElementType.TYPE)
@Import(SpringImportStudySelector.class)
public @interface EnableImportStudy {
}
```

4. 通过以上步骤我们就可以通过注解EnableImportStudy，控制是否启用配置AppConfig


## 解析源码

1. 解析方法：ConfigurationClassParser#processImports()




















