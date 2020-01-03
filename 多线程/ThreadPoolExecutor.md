# ThreadPoolExecutor
参考： https://www.jianshu.com/p/fa1eac9710c8

## 属性介绍

```
private static final int COUNT_BITS = Integer.SIZE - 3;
private static final int CAPACITY   = (1 << COUNT_BITS) - 1;

// runState is stored in the high-order bits
private static final int RUNNING    = -1 << COUNT_BITS;
private static final int SHUTDOWN   =  0 << COUNT_BITS;
private static final int STOP       =  1 << COUNT_BITS;
private static final int TIDYING    =  2 << COUNT_BITS;
private static final int TERMINATED =  3 << COUNT_BITS;
```

```
CAPACITY：  0001 1111 1111 1111 1111 1111 1111 1111
~CAPACITY： 1110 0000 0000 0000 0000 0000 0000 0000
RUNNING：   1010 0000 0000 0000 0000 0000 0000 0000
SHUTDOWN：  0000 0000 0000 0000 0000 0000 0000 0000
STOP：      0010 0000 0000 0000 0000 0000 0000 0000
TIDYING：   0100 0000 0000 0000 0000 0000 0000 0000
TERMINATED：0110 0000 0000 0000 0000 0000 0000 0000
```

runStateOf(): 获取前3位的运算结果，也就是运行状态
workerCountOf(): 获取后面29位的运算结果，也就是线程的数量
ctlOf(int rs, int wc)：函数明显是把经过上述两个步骤的整数结果合并成原来整数的作用。

状态值的比较： RUNNING < SHUTDOWN < STOP < TIDYING < TERMINATED


```java
public void execute(Runnable command) {
	if (command == null)
		throw new NullPointerException();
		
	int c = ctl.get();
	if (workerCountOf(c) < corePoolSize) { // 如果正在运行的线程数少于核心线程数
		if (addWorker(command, true)) // 尝试新增一个工作线程
			return;
		c = ctl.get();
	}
	if (isRunning(c) && workQueue.offer(command)) {
		int recheck = ctl.get();
		if (! isRunning(recheck) && remove(command)) // 如果线程池停止了，则从队列移除任务，并且拒绝任务。疑问：这时候拒绝任务，有可能这个任务已经被执行完了？？？
			reject(command);
		else if (workerCountOf(recheck) == 0) // 线程池正在运行，且工作线程等于0，新增一个工作线程
			addWorker(null, false);
	}
	else if (!addWorker(command, false)) // 添加非核心线程失败，说明线程池停止了或者队列满了，拒绝任务。
		reject(command);
}
```

1. 如果正在运行的线程数少于核心线程数，尝试新增一个工作线程。调用addWorker是原子操作
2. 如果向队列中添加任务成功，再次检查线程池运行状态，
								如果线程池停止了，那么移除任务并拒绝接收任务
								如果线程数量为0，尝试新开启一个线程
3. 如果向队列添加任务失败，且添加线程失败，说明线程停止了或者队列满了，拒绝任务

总结：
1. 添加任务时，当任务队列满了，会添加非核心线程来处理任务
2. 两次检查线程状态的目的： 因为在检查线程池运行状态和向队列添加任务之间可能发生：1.线程池停止了 2.任务执行完了，工作线程全死了





问题：
1. 问什么要用一个变量AtomicInteger来，既表示运行状态，又表示线程数量？至于这么节省内存空间吗？
2. 见上：疑问：这时候拒绝任务，有可能这个任务已经被执行完了？？？
	答： 上述方法remove成功了，说明任务还在队列中，可以执行拒绝任务


```java
private boolean addWorker(Runnable firstTask, boolean core) {
	// 反复尝试增加工作线程数量
	retry:
	for (;;) {
		int c = ctl.get();
		int rs = runStateOf(c);

		// Check if queue empty only if necessary.
		// 只有队列为非空，才不会直接返回，见表格1
		if (rs >= SHUTDOWN && // 线程池停止了
			! (rs == SHUTDOWN &&
			   firstTask == null &&
			   ! workQueue.isEmpty()))
			return false;

		for (;;) {
			int wc = workerCountOf(c);
			if (wc >= CAPACITY ||
				wc >= (core ? corePoolSize : maximumPoolSize)) // 如果线程数超标，则返回
				return false;
			if (compareAndIncrementWorkerCount(c)) // 使用乐观锁，增加工作线程数量，增加成功结束外层循环。这里不直接调用incr方法，是怕在增加之后，线程池状态变了
				break retry;
			c = ctl.get();  // Re-read ctl
			if (runStateOf(c) != rs) // 再次检查状态，如果线程池的状态变了，再次进行下次循环
				continue retry;
			// else CAS failed due to workerCount change; retry inner loop
		}
	}

	boolean workerStarted = false;
	boolean workerAdded = false;
	Worker w = null;
	try {
		w = new Worker(firstTask);
		final Thread t = w.thread;
		if (t != null) {
			final ReentrantLock mainLock = this.mainLock;
			mainLock.lock();
			try {
				// Recheck while holding lock.
				// Back out on ThreadFactory failure or if
				// shut down before lock acquired.
				int rs = runStateOf(ctl.get());

				if (rs < SHUTDOWN ||
					(rs == SHUTDOWN && firstTask == null)) {
					if (t.isAlive()) // precheck that t is startable
						throw new IllegalThreadStateException();
					workers.add(w);
					int s = workers.size();
					if (s > largestPoolSize)
						largestPoolSize = s;
					workerAdded = true;
				}
			} finally {
				mainLock.unlock();
			}
			if (workerAdded) {
				t.start(); // 将线程启动放在外面，是为了减少持锁时间
				workerStarted = true;
			}
		}
	} finally {
		if (! workerStarted)
			addWorkerFailed(w);
	}
	return workerStarted;
}
```

1.  上述语句的执行结果，表格1：

|    rs    | firstTask | queue是否为空 | 是否执行if语句 |
| :------: | :-------: | :-----------: | :------------: |
| shutdown |   null    |      空       |      true      |
| shutdown |   null    |     非空      |     false      |
| shutdown |    not    |      空       |      true      |
| shutdown |    not    |     非空      |      true      |
|   STOP   |   null    |      空       |      true      |
|   STOP   |   null    |     非空      |      true      |
|   STOP   |    not    |      空       |      true      |
|   STOP   |    not    |     非空      |      true      |

可以换成：
```java
if(rs != SHUTDOWN || firstTask != null || workQueue.isEmpty()){

}
```

总结： 
1. 增加工作线程数量的操作包含两步，原本是可以通过一个锁就完成了的，变成了使用【乐观锁】+【原子操作】来完成，从而达到了减小锁的粒度
	* 判断工作线程的数量是否超标
	* 增加工作线程的数量（原子操作）
   
	
3. 如果我来写：
	* 创建工作线程
	* 锁： 加入工作线程集合
	* 加入工作线程集合
	* 开启线程
	* 开始失败处理
   如果我来写：
    * 创建工作线程
    * 锁：加入工作线程集合
	* 锁：开启线程
	* 锁：开始失败处理



```
final void tryTerminate() {
	for (;;) {
		int c = ctl.get();
		if (isRunning(c) ||
			runStateAtLeast(c, TIDYING) ||
			(runStateOf(c) == SHUTDOWN && ! workQueue.isEmpty()))
			return;
		if (workerCountOf(c) != 0) { // Eligible to terminate
			interruptIdleWorkers(ONLY_ONE);
			return;
		}

		final ReentrantLock mainLock = this.mainLock;
		mainLock.lock();
		try {
			if (ctl.compareAndSet(c, ctlOf(TIDYING, 0))) {
				try {
					terminated();
				} finally {
					ctl.set(ctlOf(TERMINATED, 0));
					termination.signalAll();
				}
				return;
			}
		} finally {
			mainLock.unlock();
		}
		// else retry on failed CAS
	}
}
```	




线程池拒绝策略：
1. 丢失
2. 抛异常
3. 直接运行任务
4. 开启一个线程来运行任务
5. 丢失最老的任务
6. 阻塞一段时间在投递，如果还失败，抛异常
























