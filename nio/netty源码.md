# netty


看懂EventLoop的结构
看懂EventLoopGroup的结构
看懂Promise
看懂selector 的 register部分的代码




ThreadExecutorMap{
	
	FastThreadLocal<EventExecutor> mappings 

}



```
NioEventLoopGroup extends MultithreadEventExecutorGroup {
	// 所有的 NioEventLoop
	EventExecutor[] children;
}
```

```
NioEventLoop implements EventLoop, Executor, EventExecutor{
	// 只有一个线程的线程池，默认是：ThreadPerTaskExecutor
	// ThreadPerTaskExecutor: 一个任务一个线程
	Executor executor; 
	
	// nio的Selector
	private Selector selector;
	
	// 
	private final Queue<Runnable> taskQueue;
	
	private final Queue<Runnable> tailTasks;
	
	// 构造函数传入一个executor，这个NioEventLoop在运行起来的时候，
	// 会一直占用一个线程，永不释放
	public NioEventLoop(Executor executor){
		this.executor = ThreadExecutorMap.apply(executor, this);
	}
	
	doStartThread(){
		executor.execute(() ->{
			NioEventLoop.this.run();
		});
	}
	
	run(){
		// 无线循环的run方法
	}

}
```
		
	
	


