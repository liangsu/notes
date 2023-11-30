## Executor

Executor
	BaseExecutor
		SimpleExecutor
		ReuseExecutor
		BatchExecutor
		
SimpleExecutor： 普通sql的执行器

ReuseExecutor： 对于每一条用过的Statement会存起来放入一个map中，每次执行一条新sql的时候判断有没有，如果有则使用以前的

BatchExecutor：
	对应于jdbc中的`statement.addBatch()`操作
	

CachingExecutor
	二级缓存的实现
	
	
	
一对一的关系：
connection ----> Transaction ----> Executor ----> DefaultSqlSession


Mapper ----> SqlSessionTemplate ----> SqlSession的获取和开启 ----> DefaultSqlSession



	

# mybatis结果集的处理

mybatis处理结果集的类是`ResultSetHandler`

处理逻辑伪代码：
```

// 创建resultSet的结果容器集，由于有些数据支持一次执行，返回多个ResultSet的情况，比如执行存储过程，可能返回多个ResultSet
final List<Object> multipleResults = new ArrayList<>();

// 遍历ResultSet处理结果集
List<ResultSet> rss = stmt.getResultSets();
for (ResultSet rs : rss) {

	// 处理resultSet
	
	// 跳过RowBounds行数
	skipRows(resultSet, rowBounds);
	
	while(rs.next()) {
		// 获取鉴别器对应的resultMap
		ResultMap discriminatedResultMap = resolveDiscriminatedResultMap(resultSet, resultMap, null);
		
		// 创建返回结果对象
		Object rowValue = createResultObject(rsw, resultMap, lazyLoader, columnPrefix);
		
		// 遍历ResultMap中所有字段的Mapping，从ResultSet中获取字段值，并设置到对象`rowValue`中去
		metaObject.setValue(mapping.property, value);
		
		// 将行结果存储起来
		ResultHandler.handleResult(rowValue);
	}

}

```


ResultHandler  存储结果值
	DefaultMapResultHandler
	DefaultResultHandler	基于列表


BaseTypeHandler


给对象赋值
ObjectWrapper
	BaseWrapper
		MapWrapper
		BeanWrapper
			CustomBeanWrapper
			
	CollectionWrapper
	CustomObjectWrapper
	


MapperMethod	










MethodInvoker

ObjectWrapper




可选 STATEMENT，PREPARED 或 CALLABLE。这会让 MyBatis 分别使用 Statement，PreparedStatement 或 CallableStatement，默认值：PREPARED。
















