package com.dmall.inventory.adjust.web.test;

//import io.admiral.client.config.anonation.ManagedField;
//import io.admiral.client.config.anonation.ManagedResource;
import com.dmall.admiral.client.config.anonation.ManagedField;
import com.dmall.admiral.client.config.anonation.ManagedResource;
import lombok.Data;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Data
@Component
@ManagedResource
public class MyConfig {

    @ManagedField(key = "hello", isVolatile = true)
//    @Value("${hello}")
    private String hello;

}
