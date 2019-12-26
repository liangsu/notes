# FutureTask

	可取消的任务，补充了Runnable多线程下不能获取线程执行返回结果的缺点，在等待返回结果的时候支持超时等待

1. 继承关系
　　* FutureTask implement RunnableFuture
	* RunnableFuture extends Runnable, Future
	
2. 属性：
   2.1 volatile int state
		* NEW          = 0， 创建FutureTask的时候的状态
		* COMPLETING   = 1， 任务执行完成，先通过原子操作将状态修改COMPLETING，修改成功了之后，再紧接着设置为NORMAL
		* NORMAL       = 2
		* EXCEPTIONAL  = 3
		* CANCELLED    = 4
		* INTERRUPTING = 5
		* INTERRUPTED  = 6
		
		* 可能出现的情况：
			* NEW -> COMPLETING -> NORMAL
			* NEW -> COMPLETING -> EXCEPTIONAL
			* NEW -> CANCELLED
			* NEW -> INTERRUPTING -> INTERRUPTED
		
   2.2 Callable<V> callable
		* 要执行的任务，执行完成会这是为null，所以一个FutureTask只能够执行一次
   
   2.3 Object outcome
		* 执行完成之后的返回结果
   
   2.4 Thread runner
		* 当前执行FutureTask的线程
   
   2.5 WaitNode waiters
		* 是一个链表，存放的是所有等待获取结果的对象
		* 内部有一个当前等待的线程对象
   
3. run方法：

```java
public void run() {
	// 1. 如果状态不是新建，停止执行
	// 2.设置当前线程变量，如果设置失败了，说明这个任务被执行过，通过这一步的设置，保证了下面的动作只会有一个线程操作
	if (state != NEW || 
		!UNSAFE.compareAndSwapObject(this, runnerOffset,
									 null, Thread.currentThread()))
		return;
	try {
		Callable<V> c = callable;
		if (c != null && state == NEW) {
			V result;
			boolean ran;
			try {
				result = c.call();
				ran = true;
			} catch (Throwable ex) {
				result = null;
				ran = false;
				setException(ex); // 执行异常，设置异常结果
			}
			if (ran) // 执行完成，设置返回结果
				set(result);
		}
	} finally {
		// runner must be non-null until state is settled to
		// prevent concurrent calls to run()
		runner = null;
		// state must be re-read after nulling runner to prevent
		// leaked interrupts
		int s = state;
		if (s >= INTERRUPTING)
			handlePossibleCancellationInterrupt(s);
	}
}
```   


3.1 解释：
		2. 设置当前线程变量，
			* 如果设置失败了，说明这个任务被执行过
			* 通过这一步的设置，保证了下面的动作只会有一个线程操作
			
			
4. set方法：

```java
protected void set(V v) {
	if (UNSAFE.compareAndSwapInt(this, stateOffset, NEW, COMPLETING)) { // 只有状态修改成功了，才能修改下面的操作
		outcome = v;
		UNSAFE.putOrderedInt(this, stateOffset, NORMAL); // final state
		finishCompletion(); // 完成回调，唤醒等待结果的线程
	}
}
```

4.1 解释：
	* set方法是，任务执行完成之后调用设置返回结果的
	* 除非状态已经被修改了或者任务被取消才会设置失败
	
	
5. 	finishCompletion方法
		* 在正常执行完成、执行异常、取消任务cancel时，都会被调用
	
```java
private void finishCompletion() {
	// assert state > COMPLETING;
	for (WaitNode q; (q = waiters) != null;) { 
		if (UNSAFE.compareAndSwapObject(this, waitersOffset, q, null)) { // 使用乐观锁【循环+原子操作】，唤醒等待获取结果的线程
			for (;;) {
				Thread t = q.thread;
				if (t != null) {
					q.thread = null;
					LockSupport.unpark(t); // 唤醒等待线程
				}
				WaitNode next = q.next;
				if (next == null)
					break;
				q.next = null; // unlink to help gc
				q = next;
			}
			break;
		}
	}

	done(); // 其它操作

	callable = null;        // to reduce footprint
}
```	
	
6. cancel方法

```java
public boolean cancel(boolean mayInterruptIfRunning) {
	// 当线程是新增，则尝试执行取消任务
	if (!(state == NEW &&
		  UNSAFE.compareAndSwapInt(this, stateOffset, NEW,
			  mayInterruptIfRunning ? INTERRUPTING : CANCELLED)))
		return false;
	try {    // in case call to interrupt throws exception
		if (mayInterruptIfRunning) {
			try {
				Thread t = runner;
				if (t != null)
					t.interrupt();
			} finally { // final state
				UNSAFE.putOrderedInt(this, stateOffset, INTERRUPTED);
			}
		}
	} finally {
		finishCompletion();
	}
	return true;
}
```
	
6.1 解释：
	* mayInterruptIfRunning： 用于判断任务正在运行，是否执行运行任务线程的interrupt方法
	* mayInterruptIfRunning = false， 
		* 如果任务正在执行，任务会继续执行完成
		* 任务没有执行，那么任务也不会被执行
	* mayInterruptIfRunning = true,
		* 如果任务正在执行，则执行线程会中断，如果任务中有判断interrupted、阻塞则会有相应的异常等
		* 任务没有执行，那么任务也不会被执行
	
	
	
7. awaitDone方法

```java
/**
 * Awaits completion or aborts on interrupt or timeout.
 *
 * @param timed true if use timed waits
 * @param nanos 等待时间，如果设置了timed 为 true
 * @return 等待结束之后的状态
 */
private int awaitDone(boolean timed, long nanos)
	throws InterruptedException {
	final long deadline = timed ? System.nanoTime() + nanos : 0L; // 等待截止时间点
	WaitNode q = null;
	boolean queued = false;
	for (;;) {
		if (Thread.interrupted()) { // 在cancel方法被调用的时候会被触发
			removeWaiter(q);
			throw new InterruptedException();
		}

		int s = state;
		if (s > COMPLETING) { // 3.任务执行完成，返回
			if (q != null)
				q.thread = null;
			return s;
		}
		else if (s == COMPLETING) // 任务刚执行完成，还做做任务执行完成之后的后续操作，交出执行时间片，再等一等
			Thread.yield();
		else if (q == null)
			q = new WaitNode(); // 创建等待对象，方便在任务执行完成的时候，执行线程的唤醒操作
		else if (!queued)
			queued = UNSAFE.compareAndSwapObject(this, waitersOffset,
												 q.next = waiters, q); // 将等待对象，加入等待队列
		else if (timed) {
			nanos = deadline - System.nanoTime();
			if (nanos <= 0L) {
				removeWaiter(q);
				return state;
			}
			LockSupport.parkNanos(this, nanos); // 将线程挂起指定时间
		}
		else
			LockSupport.park(this); // 挂起，在任务执行完成会被唤醒
	}
}
```	
	
	疑问：1. 注释中的3，在任务执行完成后，为什么不执行removeWaiter(q)这个方法
			答： 在执行方法removeWaiter的时候，会自动将WaitNode.thread为空的移除掉
		  2. 创建WaitNode，和将WaitNode加入链表本可以做成在一个if中来完成，为什么要放到两个if中
			答： 我的理解，刚创建WaitNode，然后在加入链表，加入列表的操作可能会因为并发的问题导致加入错误，
			    下次继续加入的话又要重新创建WaitNode，分成两步可以避免频繁重新创建相同的对象
	
	
	
	
	
	
	
	
	


			
	
	
	
	
	

