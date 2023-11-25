# DruidDataSource


## 1. 文档：

配置参数： https://github.com/alibaba/druid/wiki/DruidDataSource配置属性列表

## 2. 连接的获取与释放

2.1 从池中获取、释放连接的原理

`DruidDataSource`源码中有：
```
DruidDataSource{
	// 连接池
	private volatile DruidConnectionHolder[] connections;
	// 池中被拿去、放入的索引，拿去连接之后，poolingCount--，放入之后poolingCount++
	private int poolingCount;
	
	// 放入池中
	putLast(conn)(){
		// 放入池中
        connections[poolingCount] = conn;
        // 增加索引
		poolingCount++;
	}
	
	// 从尾部拿去
	pollLast(){
		poolingCount--;
		DruidConnectionHolder last = connections[poolingCount];
		connections[poolingCount] = null;
		return last;
	}
}
```

2.2 调用关闭连接时，将真实的连接，放入`DruidDataSource`中
```
DruidPooledConnection{
	
	close(){
		// 将真实的连接，放入DruidDataSource中
		dataSource.recycle(this)
	}

}
```




