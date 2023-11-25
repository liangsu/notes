
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



版本3：
保证任务有序执行





