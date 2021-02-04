# java nio


查看进程的文件描述符： lsof -p pid

netstat -natp

tcpdump的使用

tcp基于连接

四元组： cip_cport + sip_sport

back_log： 建立连接收，如果没有将连接分配给线程，那么额外的连接数量



MTU:1500
MSS:数据内容大小

noDelay： false启用优化，如果发送的包大于bufferSize，开启优化后会攒到一起发送出去；true不启用优化，如果发送的包大于bufferSize，根据内核的调度发送很多次出去。

CLI_BOO: 是否将第一个字节马上发出去，可以在发送第一个字节的时候，探测服务端是否正常，不正常可以不急着发送后面的数据。

keepalive:  tcp如果建立了连接，双方很久都不说话，对方还活着吗？如果这个参数为true，那么会隔一段时间发送一个心跳包。所以如果建立了很多连接，即使没有请求，维护心跳的成本也很大。



## 

strace -ff -o out cmd

socket
bind
listen
accpet();

clone()

recv(fd)


www.kegel.com/c10k.html



```
[root@k8s-master home]# ulimit -a
core file size          (blocks, -c) 0
data seg size           (kbytes, -d) unlimited
scheduling priority             (-e) 0
file size               (blocks, -f) unlimited
pending signals                 (-i) 191675
max locked memory       (kbytes, -l) 64
max memory size         (kbytes, -m) unlimited
open files                      (-n) 1024
pipe size            (512 bytes, -p) 8
POSIX message queues     (bytes, -q) 819200
real-time priority              (-r) 0
stack size              (kbytes, -s) 8192
cpu time               (seconds, -t) unlimited
max user processes              (-u) 191675
virtual memory          (kbytes, -v) unlimited
file locks                      (-x) unlimited
```

ulimit -sHn 500000


NIO优势： 可以通过一个或这几个线程，解决N个连接的处理
NIO的问题：C10中，没循环一次，会有O(n)复杂度的recv系统调用，很多调用是无意义的。



多路复用器：
	select posix： 有文件描述符数量的限制FD_SIZE，默认1024
	poll： 没有1024的限制
	epoll
	kqueue
	
无论NIO、select、poll都需要便利所有的io，询问状态。只不过
	NIO：这个便利在内核态、用户态的切换
	select、poll：这个便利只有一次系统调用，然后内核根据传递的fds便利、修改状态

select、poll的弊端：
	1. 每次调用需要重新、重复传递fds
	2. 每次内核被调用之后，针对这次调用触发一个便利fds全量的复杂度
	

网卡中断：
	* 一次package
	* buffer
	* 轮询
	




epoll_create -> fd
epoll_ctl
epoll_wait
fcntl 设置非阻塞


CLOSED
close_wait
fin_wait2
在TIME_WAIT没有结束之前，内核中的四元组被占用，相同的对端不能使用这个资源建立新的连接。浪费了名额


net.ipv4.tcp_tw_reuse=0



1. bytebuf
2. eventLoopGroup
3. 



rpc:
1. 通信、连接数量、拆包
2. 动态代理、序列化、协议封装
3. 连接池
5. 


io thread：
task thread：

netty接收到io请求之后，相关的业务处理方式：
	* 在io thread中处理
	* 创建任务，在业务线程中处理
	* 将业务任务打散到各个io thread上


结合redis的线程模型看看




## 问题

1. FileChannel与普通的FileInputStream/FileOutputStream有什么区别？性能是否有差异？是否能减少系统调用？
   答：没有区别

2. 脏页刷新磁盘的比例如果比较小，BufferedWriter与OutputWrite相比较，性能出现在磁盘上；脏页刷新磁盘的比例如果比较大，性能出现在系统调用上

3. bio建立连接慢的原因：因为要创建线程。但是不是建立连接是在内核建立的吗，建立完成连接就返回，不会涉及到用户态，也就不会涉及到调用clone的时候慢了？
   答： 
   
4. 同步IO与异步IO的区别？
   答：同步指：不管是阻塞io还是非阻塞io，如果有数据准备好，操作系统将准备好的数据从内核空间太拷贝到用户空间，需要阻塞用户空间的进程；如果没有数据准备好，阻塞io会阻塞线程，非阻塞io不会阻塞线程。
	   异步IO则不同，操作系统将准备好的数据从内核空间太拷贝到用户空间，只需要调用一下用户空间的回调函数，告知数据已经准备好了。
	
5. 调用select之后，在内核级别的遍历为什么会比较慢？和epoll相比能慢多少？

6. 多个selector模型中，怎么解决有些selector忙碌，有些selector空闲的问题？

	
7. 背景：只要send-Queue为空，则会触发wirte事件。
	在多线程中处理read、write事件时，当select之后有read事件时，需要先注销read事件，开启线程去处理，不然会反复的开启read线程。
	当向一个selector注册了一个channel的read、在响应客户端的时候需要注册write事件，写完了之后又要注销write事件，涉及到了反复的系统的调用，会导致系统性能低下。
	
	单线程的情况下：处理了read事件之后需要返回客户端请求，然后注册write事件，write事件触发了之后也需要注销write事件，也不能解决反复的系统调用。
	
	
```
单线程版本：
keys = select();
while(key : keys){
	if(read){
		data = read();
		register(write); // 注册write事件
		
	}else if(write){
		
		// write数据...
		// 注销write事件
	
	}
}

多线程版本：
keys = select();
while(key : keys){
	if(read){
	
		// 注销read事件
		unregister(read);
		
		new Thread({
			data = read();
			register(write); // 注册write事件
		}).start();
		
		
	}else if(write){
		
		// 注销write事件
		unregister(write);
		
		new Thread({
			// write数据...
			// 注销write事件
		}).start();
		
	}
}
```
结论：多线程版本相比较单线程版本，多了read事件的反复注册、注销，增加了系统调用，但是write事件的注册、注销并没有减少



7. 验证：在单线程中，read比较块，wirte比较慢，导致一直write丢失的问题
	答：问题没复现





tcpdump -i enp6s0 host 192.168.10.34

tcpdump -nn -i enp6s0 port 9090

1:47




## 游戏

cocos
unreal
unity



HttpServerCodec
HttpObjectAggregator
WebSocketServerProtocalHandler
simple



国标28181协议 16版本

一线架构师实践指南


http://cdn0001.afrxvk.cn/hero_story/demo/step010/index.html?serverAddr=127.0.0.1:12345&userId=1
http://cdn0001.afrxvk.cn/hero_story/demo/step020/index.html?serverAddr=127.0.0.1:12345&userId=1
-- 增加登陆、英雄选择
http://cdn0001.afrxvk.cn/hero_story/demo/step030/index.html?serverAddr=127.0.0.1:12345&userId=1
-- 增加排行榜
http://cdn0001.afrxvk.cn/hero_story/demo/step040/index.html?serverAddr=127.0.0.1:12345

protobuf




帧同步、状态同步



单线程模型： 完全可以eventLoopGroup采用一个线程就可以了？


数据库查询：异步查询，回调处理主业务方法

问题：

1. 用户血量的减少导致死锁：用户1攻击用户2，同时用户2攻击用户1，导致死锁
	答：业务的处理放入单线程中处理（主业务线程）

2. 在主业务线程中处理，数据库查询慢，导致阻塞其它请求的响应，
   答：将数据的查询放入异步线程中处理，这个异步线程池可以是多个线程，查询完成之后，做回调，回到主线程中处理业务逻辑。

3. 用户注册请求点击两次，导致发起了两次请求，在数据库插入的时候插入了多条相同记录
   答：在异步处理的时候，将某个任务绑定到唯一的一个线程上处理
		
	多线程异步处理数据库操作中，根据bindId将相同id的任务绑定到一个固定的线程上，它采取的方式是将bindId%线程数量，这样有可能会导致：有些线程忙死，有写线程空闲，如何解决这个问题？
	
	https://oomake.com/question/2146378
	
	



线程模型： 多线程（网络io处理） —— 单线程(主业务处理) —— 多线程(数据库查询)


gps的进出电子围栏的判断： gps(id) -> exchange -> queue1(1), queue2(2)


参考： https://www.thetopsites.net/article/52089566.shtml
根据id将某个任务绑定到一个给定的线程

版本1：
```
// 自定义的队列
class OrderQueue{
	BlockingQueue queue;
	AtomicBoolean isAssociatedWithWorkingThread = false; // 是否关联了一个正在工作的线程
}

// 每个id，关联一个OrderQueue
ConcurrentHashMap<ID, OrderQueue> map;
// 分摊任务的队列
BlockingQueue<OrderQueue> amortizationQueue; 

// 每个线程对应一个工作队列，可以新建多个线程池，每个线程池的线程数量为1
Thread[] threads ->  workQueue

新增任务：
OrderQueue queue = map.get(id);
if(queue == null){
	map.putIfAbsent(id, new OrderQueue(isAssociatedWithWorkingThread=false));
	queue = map.get(id);
}

if(queue.isAssociatedWithWorkingThread == false){
	amortizationQueue.add(OrderQueue);
}

线程的run方法：
for(;;){
	// 获取自己工作线程中的任务
	OrderQueue orderQueue = this.workQueue.poll(waitingTime);
	// 如果本线程的队列中没有任务，偷取其它线程的工作队列的任务，加入到自己的队列中
	if(orderQueue == null){
		// 偷取其它线程的工作队列的任务
		int i = random();
		orderQueue = threads[i].workQueue.tail(); // 从队列尾部偷取任务
		if(orderQueue != null){
			this.workQueue.add(orderQueue);
			break;
		}
	}
}

// 执行任务
while(!orderQueue.isEmpty()){
	Task task = orderQueue.take();
	task.run();
}
orderQueue.isAssociatedWithWorkingThread.compareAndSet(true, false);
// 再次加入分摊队列，防止在这之间有有新任务添加
amortizationQueue.add(orderQueue); 

任务分配线程：
for(;;){
	OrderQueue orderQueue = amortizationQueue.poll();
	if(!orderQueue.isEmpty 
		&& orderQueue.isAssociatedWithWorkingThread.compareAndSet(false, true)){
		Thread[i].workQueue.add(orderQueue);
	}
}
```

版本2：
````
ConcurrentHashMap<ID, TaskThread> map;

ThreadPool threadPool;

AddTask(Runnable run){
	TaskThread taskThread = map.get(id);
	if(taskThread == null){
		map.putIfAbsent(id, new TaskThread());
		taskThread = map.get(id);
	}
	
	taskThread.queue.add(run);
	
	for(;;){
		
		if(taskThread.state == 0 && taskThread.state.cas(0, 1)){
			threadPool.submit(taskThread);
		}else if(taskThread.state == 1 && taskThread.state.cas(1, 2)){
			
		}else if(taskThread.state == 2 && taskThread.state.cas(2, 1)){
		
		}else if(taskThread.state == 3 && taskThread.state.cas(3, 4)){
		
		}else if(taskThread.state == 4 && taskThread.state.cas(4, 3)){
		
		}else if(taskThread.state == 5 && taskThread.state.cas(5, 0)){
			map.putIfAbsent(id, taskThread);
			threadPool.submit(taskThread);
		}
		
		if(remove.cas(true, false)){
			map.putIfAbsent(id, taskThread);
			threadPool.submit(taskThread);
		}
		
	}
	
}


TaskThread extends Thread{
	
	Queue<Runnable> queue;
	
	// 0：未执行、1：添加任务中、2：执行中、3：执行完成
	// 0：新建、1：线程池中、2：执行中、3：执行完成
	// 0：新建、1：线程池中、2：向池中加任务、3：执行中、4：向执行中加任务、5：执行完成
	AtomeInteger state = AtomeInteger(1);
	
	AtomeInteger remove = AtomeInteger(false);
	
	public void run(){
		
		
		
		for(;;){
			if(remove.compareAndSet(false, true)){
				map.remove(id);
			}else{
			
				Runnable task = null;
				while((task = queue.poll()) != null){
					task.run();
				}
			}
		}
		
	
	}


}

````


socket5协议
websocket拆包

极光、netty、sse

推送：

推送报表：每分钟推送了多少条消息
用户统计报表

用户{
	id
	标签
	别名
	地理位置
	活跃用户
	系统版本
	智能标签
	最近活跃时间
}
	
标签{
	用户、标签名称、标签值
}

消息{
	标签名称
	用户id
	消息内容
}

消息的接收用户{
	消息id
	用户id
	是否接收
}


IM：





## 
tomcat线程架构


AbstractEndpoint
Catalina

Acceptor

业务必须需要线程池




ThreadPool线程池： 全局队列 + 线程

ForkJoinPool线程池： 线程（待队列）
	任务倒去

EventExecutorGroup extends ScheduledExecutorService, Iterable<EventExecutor>

EventExecutor extends EventExecutorGroup

EventLoopGroup extends EventExecutorGroup

EventLoopGroup extends EventExecutorGroup

EventLoop extends OrderedEventExecutor, EventLoopGroup



1. 查看WebSocketServerProtocalHandler的拆包







