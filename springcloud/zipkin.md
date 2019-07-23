# zipkin




## 遇到的问题：
1. 将数据持久化到mysql8的配置时，页面报一些sql的错误
	* mysql配置sqlmod的原因导致的,修改为以下就好了
	```
		# 之前的默认值： ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION
		sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
	```
	
	* 配置的zipkin-storage-mysql与zipkin的版本没对应上，要使用一样的版本

2. 使用rabbitMQ时，没有为用户配置虚拟主机，导致报错
