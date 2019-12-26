# Unsafe
 参考： https://www.jianshu.com/p/2e5b92d0962e
  
  Thread.sleep、Object.wait、LockSupport.park 区别	 https://www.jianshu.com/p/58b711301615
 
public final native boolean compareAndSwapObject(Object obj, long offset, Object expect, Object update)
	1. 原子操作

putOrderedInt 
设置值 并且马上写入主存，该变量必须是volatile类型


public native void unpark(Object var1);
	* 唤醒线程

public native void park(boolean var1, long var2);
	* 挂起线程



# LockSupport

LockSupport.parkNanos(Object blocker, long nanos): 挂起线程

	1.在调用park()之前调用了unpark或者interrupt则park直接返回，不会挂起。
	2.如果time <= 0则直接返回。
	3.如果之前未调用park unpark并且time > 0,则会挂起当前线程，但是在挂起time ms时如果未收到唤醒信号也会返回继续执行。
	4.park未知原因调用出错则直接返回（一般不会出现）


心得：
1. park、unpark方法，能够决定阻塞、唤醒具体的哪个线程，而如果使用Object的wait、notify却不能唤醒指定线程，使得AQS能够实现公平锁、非公平锁
	
	
	
	