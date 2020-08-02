# jstack 使用

1.  jstack日志分析

   ```
   "mythread1" #13 prio=5 os_prio=0 tid=0x000000001e3c3800 nid=0x387c waiting on condition [0x000000001f0ee000]
      java.lang.Thread.State: WAITING (parking)
           at sun.misc.Unsafe.park(Native Method)
           - parking to wait for  <0x000000076b246648> (a java.util.concurrent.locks.ReentrantLock$NonfairSync)
           at java.util.concurrent.locks.LockSupport.park(LockSupport.java:175)
           at java.util.concurrent.locks.AbstractQueuedSynchronizer.parkAndCheckInterrupt(AbstractQueuedSynchronizer.java:836)
           at java.util.concurrent.locks.AbstractQueuedSynchronizer.acquireQueued(AbstractQueuedSynchronizer.java:870)
           at java.util.concurrent.locks.AbstractQueuedSynchronizer.acquire(AbstractQueuedSynchronizer.java:1199)
           at java.util.concurrent.locks.ReentrantLock$NonfairSync.lock(ReentrantLock.java:209)
           at java.util.concurrent.locks.ReentrantLock.lock(ReentrantLock.java:285)
           at com.ls.thread.DeathLock$1.run(DeathLock.java:21)
   
      Locked ownable synchronizers:
           - <0x000000076b246618> (a java.util.concurrent.locks.ReentrantLock$NonfairSync)
           - <0x000000076b246678> (a java.util.concurrent.locks.ReentrantLock$NonfairSync)
   ```

   从上面的日志，可以看出，线程名称`mythread1`，线程状态是`WAITING`，是由于调用`Unsafe.park`而阻塞的，该线程已经拥有的同步器有：`0x000000076b246618`、`0x000000076b246678`，要获取同步器`0x000000076b246648`，这些同步器都是互斥锁。

   如果是调用`synchronized`获取的锁，那么日志如下：

   ```java
   synchronized (lock1){
       TimeUnit.SECONDS.sleep(1);
       synchronized (lock2){
           System.out.println("thread 1");
       }
   }
   ```

   ```
   "mythread1" #13 prio=5 os_prio=0 tid=0x000000001dcc3000 nid=0x2c98 waiting for monitor entry [0x000000001ea0f000]
      java.lang.Thread.State: BLOCKED (on object monitor)
           at com.ls.thread.DeathLock2$1.run(DeathLock2.java:21)
           - waiting to lock <0x000000076b23c968> (a java.lang.Object)
           - locked <0x000000076b23c958> (a java.lang.Object)
   
      Locked ownable synchronizers:
           - None
   ```

   从上面的日志可以看出，`Locked ownable synchronizers`下没有内容

2. 死锁日志：

   ```
   Found one Java-level deadlock:
   =============================
   "mythread2":
     waiting for ownable synchronizer 0x000000076b2478b0, (a java.util.concurrent.locks.ReentrantLock$NonfairSync),
     which is held by "mythread1"
   "mythread1":
     waiting for ownable synchronizer 0x000000076b2478e0, (a java.util.concurrent.locks.ReentrantLock$NonfairSync),
     which is held by "mythread2"
   
   Java stack information for the threads listed above:
   ===================================================
   "mythread2":
           at sun.misc.Unsafe.park(Native Method)
           - parking to wait for  <0x000000076b2478b0> (a java.util.concurrent.locks.ReentrantLock$NonfairSync)
           at java.util.concurrent.locks.LockSupport.park(LockSupport.java:175)
           at java.util.concurrent.locks.AbstractQueuedSynchronizer.parkAndCheckInterrupt(AbstractQueuedSynchronizer.java:836)
           at java.util.concurrent.locks.AbstractQueuedSynchronizer.acquireQueued(AbstractQueuedSynchronizer.java:870)
           at java.util.concurrent.locks.AbstractQueuedSynchronizer.acquire(AbstractQueuedSynchronizer.java:1199)
           at java.util.concurrent.locks.ReentrantLock$NonfairSync.lock(ReentrantLock.java:209)
           at java.util.concurrent.locks.ReentrantLock.lock(ReentrantLock.java:285)
           at com.ls.thread.DeathLock$2.run(DeathLock.java:37)
   "mythread1":
           at sun.misc.Unsafe.park(Native Method)
           - parking to wait for  <0x000000076b2478e0> (a java.util.concurrent.locks.ReentrantLock$NonfairSync)
           at java.util.concurrent.locks.LockSupport.park(LockSupport.java:175)
           at java.util.concurrent.locks.AbstractQueuedSynchronizer.parkAndCheckInterrupt(AbstractQueuedSynchronizer.java:836)
           at java.util.concurrent.locks.AbstractQueuedSynchronizer.acquireQueued(AbstractQueuedSynchronizer.java:870)
           at java.util.concurrent.locks.AbstractQueuedSynchronizer.acquire(AbstractQueuedSynchronizer.java:1199)
           at java.util.concurrent.locks.ReentrantLock$NonfairSync.lock(ReentrantLock.java:209)
           at java.util.concurrent.locks.ReentrantLock.lock(ReentrantLock.java:285)
           at com.ls.thread.DeathLock$1.run(DeathLock.java:24)
   
   Found 1 deadlock.
   ```

3. 检测cpu高

   * 通过`top`命令，查看哪个进程占用cpu高

     ```
     top
     Mem:  16333644k total,  9472968k used,  6860676k free,   165616k buffers
     Swap:        0k total,        0k used,        0k free,  6665292k cached
     
       PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND     
     17850 root      20   0 7588m 112m  11m S 100.7  0.7  47:53.80 java       
      1552 root      20   0  121m  13m 8524 S  0.7  0.1  14:37.75 AliYunDun   
      3581 root      20   0 9750m 2.0g  13m S  0.7 12.9 298:30.20 java        
         1 root      20   0 19360 1612 1308 S  0.0  0.0   0:00.81 init        
         2 root      20   0     0    0    0 S  0.0  0.0   0:00.00 kthreadd    
         3 root      RT   0     0    0    0 S  0.0  0.0   0:00.14 migration/0 
     ```

   * 根据进程id，查找占用cpu高的线程

     ```
     top -H -p 17850
     
     top - 17:43:15 up 5 days,  7:31,  1 user,  load average: 0.99, 0.97, 0.91
     Tasks:  32 total,   1 running,  31 sleeping,   0 stopped,   0 zombie
     Cpu(s):  3.7%us,  8.9%sy,  0.0%ni, 87.4%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
     Mem:  16333644k total,  9592504k used,  6741140k free,   165700k buffers
     Swap:        0k total,        0k used,        0k free,  6781620k cached
     
       PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
     17880 root      20   0 7588m 112m  11m R 99.9  0.7  50:47.43 java
     17856 root      20   0 7588m 112m  11m S  0.3  0.7   0:02.08 java
     17850 root      20   0 7588m 112m  11m S  0.0  0.7   0:00.00 java
     17851 root      20   0 7588m 112m  11m S  0.0  0.7   0:00.23 java
     17852 root      20   0 7588m 112m  11m S  0.0  0.7   0:02.09 java
     17853 root      20   0 7588m 112m  11m S  0.0  0.7   0:02.12 java
     17854 root      20   0 7588m 112m  11m S  0.0  0.7   0:02.07 java
     ```

   * 转换线程id

     ```
     printf "%x\n" 17880          
     45d8
     ```

   * 定位cpu高的线程

     ```
     jstack 17850|grep 45d8 -A 30
     "pool-1-thread-11" #20 prio=5 os_prio=0 tid=0x00007fc860352800 nid=0x45d8 runnable [0x00007fc8417d2000]
        java.lang.Thread.State: RUNNABLE
             at java.io.FileOutputStream.writeBytes(Native Method)
             at java.io.FileOutputStream.write(FileOutputStream.java:326)
             at java.io.BufferedOutputStream.flushBuffer(BufferedOutputStream.java:82)
             at java.io.BufferedOutputStream.flush(BufferedOutputStream.java:140)
             - locked <0x00000006c6c2e708> (a java.io.BufferedOutputStream)
             at java.io.PrintStream.write(PrintStream.java:482)
             - locked <0x00000006c6c10178> (a java.io.PrintStream)
             at sun.nio.cs.StreamEncoder.writeBytes(StreamEncoder.java:221)
             at sun.nio.cs.StreamEncoder.implFlushBuffer(StreamEncoder.java:291)
             at sun.nio.cs.StreamEncoder.flushBuffer(StreamEncoder.java:104)
             - locked <0x00000006c6c26620> (a java.io.OutputStreamWriter)
             at java.io.OutputStreamWriter.flushBuffer(OutputStreamWriter.java:185)
             at java.io.PrintStream.write(PrintStream.java:527)
             - eliminated <0x00000006c6c10178> (a java.io.PrintStream)
             at java.io.PrintStream.print(PrintStream.java:597)
             at java.io.PrintStream.println(PrintStream.java:736)
             - locked <0x00000006c6c10178> (a java.io.PrintStream)
             at com.demo.guava.HardTask.call(HardTask.java:18)
             at com.demo.guava.HardTask.call(HardTask.java:9)
             at java.util.concurrent.FutureTask.run(FutureTask.java:266)
             at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1142)
             at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:617)
             at java.lang.Thread.run(Thread.java:745)
     ```

     





