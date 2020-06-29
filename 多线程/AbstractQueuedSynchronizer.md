# AbstractQueuedSynchronizer

	CLH

## 

1. 属性：

1.1 private transient volatile Node head;

1.2 private transient volatile Node tail;

1.3 private volatile int state;
	* 一个线程重入锁的次数
	* 共享锁：被多个线程重入的次数
	* 排它锁：被单个线程重入的次数

1.4 node内部类的介绍
		

```java
static final class Node {
	/** 用于标记一个节点在等待共享锁 */
	static final Node SHARED = new Node();
	/** 用于标记一个节点在等待排它锁 */
	static final Node EXCLUSIVE = null;

	/** 等待状态：线程被取消了 */
	static final int CANCELLED =  1;
	/** 等待状态：表明线程需要被唤醒 unparking waitStatus value to indicate successor's thread needs unparking */
	static final int SIGNAL    = -1;
	/** waitStatus value to indicate thread is waiting on condition */
	static final int CONDITION = -2;
	/**
	 * waitStatus value to indicate the next acquireShared should
	 * unconditionally propagate
	 */
	static final int PROPAGATE = -3;

	 
	// 节点的等待状态，默认为0
	volatile int waitStatus;

	
	volatile Node prev;

	
	volatile Node next;

	// 等待的线程
	volatile Thread thread;

	// 表明获取锁的类型
	Node nextWaiter;

	
	Node(Thread thread, Node mode) {     // Used by addWaiter
		this.nextWaiter = mode;
		this.thread = thread;
	}

	Node(Thread thread, int waitStatus) { // Used by Condition
		this.waitStatus = waitStatus;
		this.thread = thread;
	}
}
```


2. 方法acquire(int arg)
	
```java
/**
 * Acquires in exclusive mode, ignoring interrupts.  Implemented
 * by invoking at least once {@link #tryAcquire},
 * returning on success.  Otherwise the thread is queued, possibly
 * repeatedly blocking and unblocking, invoking {@link
 * #tryAcquire} until success.  This method can be used
 * to implement method {@link Lock#lock}.
 *
 * @param arg the acquire argument.  This value is conveyed to
 *        {@link #tryAcquire} but is otherwise uninterpreted and
 *        can represent anything you like.
 */
public final void acquire(int arg) {
	if (!tryAcquire(arg) && // 尝试获取锁，获取锁成功则直接返回，获取失败执行后面的
		acquireQueued(addWaiter(Node.EXCLUSIVE), arg)) // 1. 加入等待队列；2. 
		selfInterrupt();
}
```

		2.1 获取排他锁


​		

3. 方法tryAcquire()

3.1 公平锁的实现方式FairSync

```java
protected final boolean tryAcquire(int acquires) {
	final Thread current = Thread.currentThread();
	int c = getState();
	if (c == 0) { // 没有人获取锁
		if (!hasQueuedPredecessors() && // 查询是否有其它线程在等待获取这把锁。（在判断c==0到这步之间可能有其它线程在尝试获取锁，再次判断是否有其它线程是否在获取锁）
			compareAndSetState(0, acquires)) { // 通过原子操作，设置成功代表获取锁成功
			setExclusiveOwnerThread(current); // 设置获取到排他锁的线程为本线程
			return true;
		}
	}
	else if (current == getExclusiveOwnerThread()) { // 有线程已经获取到了排他锁，判断获取排他锁的线程是不是本线程
		int nextc = c + acquires; // 增加锁定次数
		if (nextc < 0)
			throw new Error("Maximum lock count exceeded"); // 超过最大锁定次数
		setState(nextc); // 重入锁，设置锁定次数+1
		return true;
	}
	return false;
}
```

	返回：获取锁是否成功


3.2 非公平锁的实现方式NonfairSync，具体实现类Sync

```java
final boolean nonfairTryAcquire(int acquires) {
	final Thread current = Thread.currentThread();
	int c = getState();
	if (c == 0) { // 没有人获取锁
		if (compareAndSetState(0, acquires)) { // 通过原子操作，设置成功代表获取锁成功
			setExclusiveOwnerThread(current); // 设置获取到排他锁的线程为本线程
			return true;
		}
	}
	else if (current == getExclusiveOwnerThread()) {
		int nextc = c + acquires;
		if (nextc < 0) // overflow
			throw new Error("Maximum lock count exceeded");
		setState(nextc);
		return true;
	}
	return false;
}
```

	非公平锁和公平锁的获取锁的区别在：少了判断【查询是否有其它线程在等待获取这把锁】

4. addWaiter方法

```java
private Node addWaiter(Node mode) {
        Node node = new Node(Thread.currentThread(), mode); // 使用自身线程创建一个等待节点
        // Try the fast path of enq; backup to full enq on failure
		// 先尝试一次能否快速加入等待锁的链表，如果不成功再执行后面的enq方法，实现的功能和enq中的一段代码一样
        Node pred = tail;
        if (pred != null) {
            node.prev = pred;
            if (compareAndSetTail(pred, node)) {
                pred.next = node;
                return node;
            }
        }
        enq(node); // 
        return node;
    }
```

5. enq方法

```java
/**
 *  加入等待队列
 */
private Node enq(final Node node) {
	for (;;) {
		Node t = tail;
		if (t == null) { // Must initialize
			if (compareAndSetHead(new Node()))
				tail = head;
		} else {
			node.prev = t;
			if (compareAndSetTail(t, node)) {
				t.next = node;
				return t;
			}
		}
	}
}
```

6. 方法acquireQueued

```java
/**
 * Acquires in exclusive uninterruptible mode for thread already in
 * queue. Used by condition wait methods as well as acquire.
 *
 * @param node 等待获取锁的节点
 * @param arg the acquire argument
 * @return true：在等待的时候发生过中断interrupt
 */
final boolean acquireQueued(final Node node, int arg) {
	boolean failed = true;
	try {
		boolean interrupted = false;
		for (;;) {
			final Node p = node.predecessor(); // 获取前一个节点
			if (p == head && tryAcquire(arg)) { // 如果前一个节点是头节点，再次尝试获取锁
				setHead(node); // 获取锁成功，设置头部节点为当前节点
				p.next = null; // help GC
				failed = false;
				return interrupted;
			}
			if (shouldParkAfterFailedAcquire(p, node) && // 检查是否应该休眠
				parkAndCheckInterrupt()) // 休眠，在唤醒时检查被唤醒的动作是正常唤醒，还是被中断唤醒
				interrupted = true;
		}
	} finally {
		if (failed)
			cancelAcquire(node);
	}
}
```

7. 方法

```java
/**
 * Checks and updates status for a node that failed to acquire.
 * Returns true if thread should block. This is the main signal
 * control in all acquire loops.  Requires that pred == node.prev.
 *
 * @param pred node's predecessor holding status
 * @param node the node
 * @return {@code true} if thread should block
 */
private static boolean shouldParkAfterFailedAcquire(Node pred, Node node) {
	int ws = pred.waitStatus;
	if (ws == Node.SIGNAL)
		/*
		 * This node has already set status asking a release
		 * to signal it, so it can safely park.
		 */
		return true;
	if (ws > 0) {
		/*
		 * Predecessor was cancelled. Skip over predecessors and
		 * indicate retry.
		 */
		do {
			node.prev = pred = pred.prev;
		} while (pred.waitStatus > 0);
		pred.next = node;
	} else {
		/*
		 * waitStatus must be 0 or PROPAGATE.  Indicate that we
		 * need a signal, but don't park yet.  Caller will need to
		 * retry to make sure it cannot acquire before parking.
		 */
		compareAndSetWaitStatus(pred, ws, Node.SIGNAL);
	}
	return false;
}
```


​	
​	
​	
​	
​	
​	
​	
​	
​	
​	
```
SHARED_UNIT：      0000 0000 0000 0001 0000 0000 0000 0000	// 共享锁每次加的值
MAX_COUNT：        0000 0000 0000 0000 1111 1111 1111 1111	// 锁的最大次数
EXCLUSIVE_MASK：   0000 0000 0000 0000 1111 1111 1111 1111	// 排它锁的掩码值
```

共享锁获取成功： state 增加	
	失败：增加排队节点
	


​	
​	
​	
​	
​	
​	
​	
​	
​	
​	
​	
​	
​	
​	
​	
​	
​	
​	
​	
​	
​	
​	
​	
​	
​	
​	
​	
​	
​	
​	
​	
​	
​	
​	
​	
​	