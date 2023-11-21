# 重试sdk

访问路径：
https://partner.rta-os.com/#index/callprotect_df/retryData/list

## 快速开始
```
<dependency>
	<groupId>com.dmall</groupId>
	<artifactId>call-protect-sdk-df</artifactId>
	<version>0.1.0-SNAPSHOT</version>
</dependency>
```

```
/**
 * 上报重试的服务
 */
@Bean
public ReferenceBean<CallProtectServer> callProtectServer() {
	ReferenceBean<CallProtectServer> ref = new ReferenceBean<>();
	ref.setInterface(CallProtectServer.class);
	ref.setId("callProtectServer");
	ref.setProtocol(dubboConsumerProperties.getProtocol());
	ref.setTimeout(2000);
	ref.setCheck(false);
	ref.setRetries(0);
	return ref;
}
```

```
/**
 * 重试处理类
 */
@Bean
public void simpleCallProtectClient(){
	return new SimpleCallProtectClient();
}

/**
 * 暴露的重试接口
 */
@Bean
public ServiceBean<SimpleICallProtectClient> callProtectClient(SimpleICallProtectClient simpleCallProtectClient) {
	ServiceBean<SimpleICallProtectClient> serviceBean = new ServiceBean<>();
	serviceBean.setInterface(SimpleICallProtectClient.class.getName());
	serviceBean.setRef(simpleCallProtectClient);
	serviceBean.setTimeout(10000);
	return serviceBean;
}


/**
 * 上报注册：
 *   指明上报重试接口时的系统编码、回调接口
 */
@Bean
public CallProtectRegister getCallProtectRegister(@Value("${dmall.dmc.projectCode}") String projectCode, @Value("${dmall.dmc.appCode}") String appCode) {
	CallProtectRegister hanlder = new CallProtectRegister();
	hanlder.setProjectCode(projectCode);
	hanlder.setAppCode(appCode);
	hanlder.setClientInterface(SimpleICallProtectClient.class.getName());
	return hanlder;
}
```


```
@Retry(argsClassName = {"com.User"}, maxRetry = 1000, catched = true)
public void invoke(User model) {
	CallProtectUtil.vender(model.getVendorId(), null);
	CallProtectUtil.setSearchKey(model.getVcOrderDO().getPoNo());
	
	// ... 业务操作
	
	
}
```

## 简绍

CallProtectServer： 上报重试异常的类

重试线程名前缀：CallProtectRetry


ThreadLocalData


RetryHanlder