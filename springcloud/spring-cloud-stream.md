# spring cloud stream

EnableBinding
1. 为每个Input、Output注解创建BeanDefinition
2. 向spring容器注册：BindableProxyFactory
2. 扫描META-INF/spring.binders，注册BinderTypeRegistry
3. SubscribableChannelBindingTargetFactory
4. MessageSourceBindingTargetFactory


RabbitServiceAutoConfiguration

ExtendedBindingHandlerMappingsProviderConfiguration

## Binder
1. bindConsumer
2. bindProducer

BindableProxyFactory

BindingService.bindProducer








