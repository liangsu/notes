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

	
	


tcpdump -i enp6s0 host 192.168.10.34

tcpdump -nn -i enp6s0 port 9090













