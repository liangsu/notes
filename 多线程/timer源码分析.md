# timer源码分析.md

## 1. Timer类

### 1.1 属性

1. TaskQueue queue： 任务队列对象
	* 充当锁，保护属性：TimerThread.newTasksMayBeScheduled、TaskQueue.queue
	
2. TimerThread thread： 直线任务的线程，是一个单线程
3. AtomicInteger nextSerialNumber： 用于产生定时器线程名称的序列号，"Timer-" + "序列号"


## 2. TimerThread类

### 2.1 属性：

1. boolean newTasksMayBeScheduled： 
	* 结束线程
	* 保护锁：queue，修改它的值要使用锁queue
	
2. TaskQueue queue
	* 来自Timer类传入

### 2.2 大体逻辑：

1. 判断queue中是否有任务，如果没有则等待。当添加新任务的时候，唤醒。
2. 从queue获取【执行时间最早】的任务，如果任务取消了，则从queue中移除任务，回到步骤1。
3. taskFired=true，已经到了任务执行时间，
	如果不是循环任务，则从queue中移除任务，并标记任务已执行；
	如果是循环任务，重新计算下次执行时间，并修正queue中任务的顺序。
4. taskFired=false，还没到任务执行时间，则线程进入等待，等待时间为：下次执行时间-当前时间，等待结束回到步骤1。
5. 上面步骤如果taskFired=true，则执行任务

* 相关代码见：TimerThread#mainLoop
```java
    private void mainLoop() {
        while (true) {
            try {
                TimerTask task;
                boolean taskFired;
                synchronized(queue) {
                    // Wait for queue to become non-empty
                    while (queue.isEmpty() && newTasksMayBeScheduled)
                        queue.wait();
                    if (queue.isEmpty())
                        break; // 队列为空，且定时器已经被取消掉了，则结束循环。本线程死亡

                    // Queue nonempty; look at first evt and do the right thing
                    long currentTime, executionTime;
                    task = queue.getMin();
                    synchronized(task.lock) {
                        if (task.state == TimerTask.CANCELLED) {
                            queue.removeMin();
                            continue;  // No action required, poll queue again
                        }
                        currentTime = System.currentTimeMillis();
                        executionTime = task.nextExecutionTime;
                        if (taskFired = (executionTime<=currentTime)) {
                            if (task.period == 0) { // 非重复执行任务，移除
                                queue.removeMin();
                                task.state = TimerTask.EXECUTED;
                            } else { // 重复执行任务，计算下次执行时间，并重新排序
                                queue.rescheduleMin(
                                  task.period<0 ? currentTime   - task.period
                                                : executionTime + task.period);
                            }
                        }
                    }
                    if (!taskFired) // 任务还没到执行时间，等待
                        queue.wait(executionTime - currentTime);
                }
                if (taskFired)  // 任务已经到了执行时间，执行任务, 不需要锁
                    task.run();
            } catch(InterruptedException e) {
            }
        }
    }
```


## 3. TaskQueue类

### 3.1 属性：

1. TimerTask[] queue = new TimerTask[128]： 任务数组
	* 涉及算法：小顶堆
	* 添加任务时，数组长度不够，数组扩容为原来的一倍
	* 数组下标从1开始，0号位置没有使用，和使用的算法有关系
	* 数组中的任务，是按照下次执行时间排好序的，下标越小，执行下次执行时间越早
	* 在操作这个数组时，要先获取锁：TaskQueue的实例
	
2. int size： 任务数量


## 4. TimerTask类

### 4.1 属性：
1. final Object lock = new Object()： 
	* 用于保护属性：state、nextExecutionTime

2. int state = VIRGIN：表明任务状态
	* VIRGIN： 新增任务，还没加入定时任务Timer的队列
	* SCHEDULED： 刚加入定时任务Timer的队列；如果是一个不重复执行的任务，表明任务还没执行
	* EXECUTED： 不重复执行的任务才会有的状态，表明任务已经执行了，或者正在执行
	* CANCELLED： 表明任务已取消

3. long nextExecutionTime： 下次执行时间

4. long period = 0：
	* 重复执行的任务才使用的属性
	* 不重复执行的任务值为0
	* 表明每次执行间隔时间


## 5. 堆排序（大顶堆、小顶堆）
详见参考： 
https://www.cnblogs.com/henry-1202/p/9307927.html
https://www.cnblogs.com/lanhaicode/p/10546257.html


### 5.1 什么是堆？
* 堆是一种非线性结构，（本篇随笔主要分析堆的数组实现）可以把堆看作一个数组，也可以被看作一个完全二叉树，通俗来讲堆其实就是利用完全二叉树的结构来维护的一维数组

* 按照堆的特点可以把堆分为大顶堆和小顶堆
	大顶堆：每个结点的值都大于或等于其左右孩子结点的值
	小顶堆：每个结点的值都小于或等于其左右孩子结点的值


* 二叉树中，父节点下标i，则左子节点下标：2*i + 1；右子节点下标：2*i + 1

















