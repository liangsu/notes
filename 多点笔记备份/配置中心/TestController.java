package com.dmall.rdp.requisition.web.controller.requisition;

import com.dmall.admiral.client.config.anonation.ManagedField;
import com.dmall.admiral.client.config.anonation.ManagedResource;
import com.dmall.rdp.requisition.pojo.web.vo.HttpResult;
import io.swagger.annotations.Api;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@Api("test")
@RestController
@RequestMapping("/test")
@Slf4j
@ManagedResource
public class TestController {
    @ManagedField(key = "hello", isVolatile = true)
    private String ManagedField;
    @Value("${hello}")
    private String value;
//    @Value("${config.prop}")
//    private String prop;

    @ManagedField(key = "repeat", isVolatile = true)
    private String repeatManagedField;
    @Value("${repeat}")
    private String repeatValue;

    @Value("${repeat2}")
    @ManagedField(key = "repeat2", isVolatile = true)
    private String repeatValue2;

    @GetMapping("/config")
    public HttpResult config() {
        Map<String, Object> map = new HashMap<>();
        map.put("ManagedField", ManagedField);
        map.put("value", value);
//        map.put("prop", prop);
        map.put("repeatManagedField", repeatManagedField);
        map.put("repeat", repeatValue);
        map.put("repeatValue2", repeatValue2);
        return HttpResult.success(map);
    }

}
