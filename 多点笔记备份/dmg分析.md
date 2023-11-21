# dmg分析


启用mq的自动配置类：RocketAutoConfigure
dmall.rocket.producer.enable=true



配置参考： RocketProducerProperties、AuthProperties

DefRocketProducerWrapper

RocketProducerRateLimitDecorator
	限流器，核心实现`RateLimiter`

RocketProducerMetricDecorator

CoreRocketProducerImpl