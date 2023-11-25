package com.dmall.inventory.adjust.web.test;


import com.dmall.admiral.client.AdmiralClientContext;
import com.dmall.admiral.client.ClientLaunchMode;
import com.dmall.admiral.client.spring.AdmiralClassModifierListener;
import com.dmall.admiral.client.spring.AdmiralPlaceholderConfigurer;
import com.dmall.rdp.toolkit.starter.admiral.EnableAdmiral;
import io.admiral.client.config.manage.GlobalObjectManagerRefs;
import io.admiral.client.config.manage.ObjectManager;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.MutablePropertySources;
import org.springframework.core.env.PropertySource;
import org.springframework.core.env.PropertySources;

@Configuration
@ComponentScan(value = {
        "com.dmall.inventory.adjust.web.test"
})
//@EnableAdmiral
public class TestApp {
    public static void main(String[] args) throws InterruptedException {
        try {
            AdmiralClientContext.doModifyClasses(new String[] { "com.dmall.inventory.adjust.web.test" }, null);
        } catch (Exception e) {
            e.printStackTrace();
        }

        AnnotationConfigApplicationContext ac = new AnnotationConfigApplicationContext(TestApp.class);

//        ac.addApplicationListener(new AdmiralClassModifierListener(
//                new String[] { "com.dmall.inventory.adjust.web.test" }, null));


        String property = ac.getEnvironment().getProperty("elasticsearch.cluster.host");
        System.out.println(property);

//        AdmiralPlaceholderConfigurer pc = ac.getBean(AdmiralPlaceholderConfigurer.class);
//        PropertySources appliedPropertySources = pc.getAppliedPropertySources();
//        PropertySource<?> propertySource = appliedPropertySources.get(AdmiralPlaceholderConfigurer.ADMIRAL_PROPERTIES_PROPERTY_SOURCE_NAME);
//        ac.getEnvironment().getPropertySources().addFirst(propertySource);

        property = ac.getEnvironment().getProperty("elasticsearch.cluster.host");
        System.out.println(property);

        MyConfig myConfig = ac.getBean(MyConfig.class);

        while(true){
            AdmiralPlaceholderConfigurer pc = ac.getBean(AdmiralPlaceholderConfigurer.class);
            PropertySources appliedPropertySources = pc.getAppliedPropertySources();
            PropertySource<?> propertySource = appliedPropertySources.get(AdmiralPlaceholderConfigurer.ADMIRAL_PROPERTIES_PROPERTY_SOURCE_NAME);
            System.out.println(propertySource.getProperty("hello"));

            System.out.println("对象："+myConfig.getHello());

            Thread.sleep(1000 * 10);
        }
    }

    @Bean(name = "propertyPlaceholderConfigurer", destroyMethod = "close")
    public AdmiralPlaceholderConfigurer createAdmiralPlaceholderConfigurer() {
        try {
            AdmiralPlaceholderConfigurer admiralPlaceholderConfigurer = new AdmiralPlaceholderConfigurer(
                    ClientLaunchMode.REMOTE.getValue(),
                    "dev",
                    "coo-store-system-dev-man-rdp-statistics",
                    "CD4AF4B64BF5F4AA8BBC86E2A3B50706612505C311520BD3D2AF556987E589666E29C750E23709CFAA650593EB4064BD",
                    "861f4479bbf7e051e06524f5",
                    null,
                    1,
                    false,
                    "");
            return admiralPlaceholderConfigurer;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
