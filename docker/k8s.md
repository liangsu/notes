# kubernetes

## 问题：
1. 只有大公司才会用吧？！


## 1.pod

1. 自主式pod、控制器管理的pod

2. 多个容器可以共用一个pod，同一个pod中的应用可以通过localhost访问，共用文件，端口不能冲突。

3. replicationController： 用来确保应用的副本数始终保持在用户定义的副本数

4. replicaSet: 和replicationController没有本质区别，新增了集合操作的功能

5. deployment: 虽然replicaSet可以独立使用，建议使用deployment来管理replicaSet

6. Horizontal Pod Autoscaling： 在V1中仅支持根据cpu利用率扩容，在vlalpha版本中，支持根据内存和用户自定义的metric扩缩容

7. StatefulSet： 为了解决有状态服务的问题（对应：replicaSet和deployment是为无状态服务的）
	* 稳定的持久化存储
	* 稳定的网络标志
	* 有序部署，有序扩展
	* 有序收缩，有序删除


