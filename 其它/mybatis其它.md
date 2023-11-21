


SqlSource
	RawSqlSource
	StaticSqlSource
	
BoundSql




mybatis本地缓存
1. 绑定在`SqlSession`上面的，一个`SqlSession`对应一个`Executor`
2. 根据sql、参数作为缓存key
3. 查询的时候，先从缓存拿去，没有则查询数据库，然后放入本地缓存
4. 一旦执行更新语句，则清空本地缓存
5. 可以通过开关`localCacheScope`控制

