# 同步
翻译自： https://wiki.openjdk.java.net/display/HotSpot/Synchronization

## Synchronization and Object Locking（同步和对象锁定）

One of the major strengths of the Java programming language is its built-in support for multi-threaded programs. An object that is shared between multiple threads can be locked in order to synchronize its access. Java provides primitives to designate critical code regions, which act on a shared object and which may be executed only by one thread at a time. The first thread that enters the region locks the shared object. When a second thread is about to enter the same region, it must wait until the first thread has unlocked the object again.

java编程语言的一个主要优势是支持多线程编程。一个被多个线程共享的对象能够被锁定以同步对其访问。java提供了元语言来指定**临界区**，哪些作用于共享对象哪些只能在同一时刻只能有一个线程执行。第一个进入临界区的线程锁定共享对象，当第二个线程准备进入临界区时，它必须等待第一个线程释放了这个对象的锁。

In the Java HotSpot™ VM, every object is preceded by a class pointer and a header word. The header word, which stores the identity hash code as well as age and marking bits for generational garbage collection, is also used to implement a *thin lock scheme* [[Agesen99](https://wiki.openjdk.java.net/display/HotSpot/Synchronization#Synchronization-Agesen99), [Bacon98](https://wiki.openjdk.java.net/display/HotSpot/Synchronization#Synchronization-Bacon98)]. The following figure shows the layout of the header word and the representation of different object states

在java HotSpot 虚拟机中，每一个对象的头部都有一个class pointer和header word。header word存储有hashcode、age、标记位，用于垃圾收集、实现轻量级锁。下图展示了对象不同状态下header word的对象布局。

![image-20200626191901005](E:\学习笔记\多线程\mark word.png)

The right-hand side of the figure illustrates the standard locking process. As long as an object is unlocked, the last two bits have the value 01. When a method synchronizes on an object, the header word and a pointer to the object are stored in a lock record within the current stack frame. Then the VM attempts to install a pointer to the lock record in the object's header word via a *compare-and-swap* operation. If it succeeds, the current thread afterwards owns the lock. Since lock records are always aligned at word boundaries, the last two bits of the header word are then 00 and identify the object as being locked.

右图说明了标准的加锁过程。只要对象是未锁定状态，最后的2位是01。当方法在对象上同步时，header word和对象的指针将被存储到当前线程的栈帧中，然后虚拟机将使用cas操作尝试把对象的header word更新为指向Lock Record的指针。如果成功，当前线程就拥有了这把锁。由于Lock Records总是按word边界对齐，header word的最后2位将是00，以表明这个对象被锁定了。

If the compare-and-swap operation fails because the object was locked before, the VM first tests whether the header word points into the method stack of the current thread. In this case, the thread already owns the object's lock and can safely continue its execution. For such a *recursively* locked object, the lock record is initialized with 0 instead of the object's header word. Only if two different threads concurrently synchronize on the same object, the thin lock must be *inflated* to a heavyweight monitor for the management of waiting threads.

如果cas操作失败，那么这个对象在之前就已经被锁定了，这时虚拟机会检测header word的指针是否指向当前线程的方法栈。如果是，那么这个线程已经拥有对象的锁，可以安全地继续执行。对于这样一个递归锁定的对象，lock record将被初始化为0，而不是对象的header word。只有当两个不同的线程在同一个对象上并发同步时，轻量级锁就必须膨胀为重量级锁，以便管理等待的线程。

Thin locks are a lot cheaper than inflated locks, but their performance suffers from the fact that every compare-and-swap operation must be executed atomically on multi-processor machines, although most objects are locked and unlocked only by one particular thread. In Java 6, this drawback is addressed by a so-called *store-free biased locking technique* [[Russell06](https://wiki.openjdk.java.net/display/HotSpot/Synchronization#Synchronization-Russel06)], which uses concepts similar to [[Kawachiya02](https://wiki.openjdk.java.net/display/HotSpot/Synchronization#Synchronization-Kawachiya02)]. Only the first lock acquisition performs an atomic compare-and-swap to install an ID of the locking thread into the header word. The object is then said to be *biased* towards the thread. Future locking and unlocking of the object by the same thread do not require any atomic operation or an update of the header word. Even the lock record on the stack is left uninitialized as it will never be examined for a biased object.

轻量级锁比重量级锁的代价小很多。但是它们的性能受到以下情况的影响:在大多数对象仅由一个线程锁定和解锁的时候，每次获取锁、解锁都要执行cas操作。在Java 6中，这个缺点被一个叫做无存储的偏向锁技术[[Russell06](https://wiki.openjdk.java.net/display/HotSpot/Synchronization#Synchronization-Russel06)]解决，它使用类似于[[Kawachiya02](https://wiki.openjdk.java.net/display/HotSpot/Synchronization#Synchronization-Kawachiya02)]的概念。只有第一次获取锁的时候才会执行cas操作，并在header word中设置线程的id。可以看作这个对象偏向于这个线程。在未来这个对象被同一个线程锁定和解锁就不用再次需要原子操作或者更新header word了。甚至在栈上也不会初始化lock record，因为一个已偏向的对象从来不会检测lock record。

When a thread synchronizes on an object that is biased towards another thread, the bias must be *revoked* by making the object appear as if it had been locked the regular way. The stack of the bias owner is traversed, lock records associated with the object are adjusted according to the thin lock scheme, and a pointer to the oldest of them is installed in the object's header word. All threads must be suspended for this operation. The bias is also revoked when the identity hash code of an object is accessed since the hash code bits are shared with the thread ID.

当一个线程需要同步一个已经被偏向了的对象的时候，这个偏向状态必须被撤销，这个对象将被转换为常规的锁定方式。遍历偏向锁拥有者的所有的方法栈，将与对象关联的锁记录根据轻量级锁的方案进行调整。并且在对象的header word中设置了一个指向其中最老的一个的指针，在执行这个操作的时候所有的线程必须挂起。偏向锁被撤销的另一个场景是调用hash code方法的时候，因为在header word中hash code和thread id是占用的相同地址空间。

Objects that are explicitly designed to be shared between multiple threads, such as producer/consumer queues, are not suitable for biased locking. Therefore, biased locking is disabled for a class if revocations for its instances happened frequently in the past. This is called *bulk revocation*. If the locking code is invoked on an instance of a class for which biased locking was disabled, it performs the standard thin locking. Newly allocated instances of the class are marked as non-biasable.

如果一个对象被设计为在多个线程之间共享的，那么它并不适合使用偏向锁，比如生产者/消费者队列。因此，如果一个类的实例在过去经常被撤销偏向状态，这个类的偏向锁将被禁止，这被称为**批量撤销bulk revocation**。如果在禁用偏向锁的类的实例上调用获取锁代码，它将执行轻量级锁的获取锁的方法。新分配的类实例也将被标记为不可偏向。

A similar mechanism, called *bulk rebiasing*, optimizes situations in which objects of a class are locked and unlocked by different threads but never concurrently. It invalidates the bias of all instances of a class without disabling biased locking. An *epoch value* in the class acts as a timestamp that indicates the validity of the bias. This value is copied into the header word upon object allocation. Bulk rebiasing can then efficiently be implemented as an increment of the epoch in the appropriate class. The next time an instance of this class is going to be locked, the code detects a different value in the header word and rebiases the object towards the current thread.

一个被叫做**批量重新偏向*bulk rebiasing***的机制，优化了这个场景：一个类的对象被不同的线程锁定和解锁，但从不并发执行锁定、解锁操作。它使一个类的所有实例的偏向状态作废，而不是禁用偏向锁。类中的epoch的值充当了时间戳的作用，表示偏向的有效性。这个值在对象分配的时候复制到header word中。在多次偏向的时候将会使epoch 的值递增。下次锁定该类的实例的时候，代码在header word中检测到一个不同的值，并将对象重新偏向到当前线程。

## Source Code Hints（源码提示）

Synchronization affects multiple parts of the JVM: The structure of the object header is defined in the classes `oopDesc` and `markOopDesc`, the code for thin locks is integrated in the interpreter and compilers, and the class `ObjectMonitor` represents inflated locks. Biased locking is centralized in the class `BiasedLocking`. It can be enabled via the flag `-XX:+UseBiasedLocking` and disabled via `-XX:-UseBiasedLocking`. It is enabled by default for Java 6 and Java 7, but activated only some seconds after the application startup. Therefore, beware of short-running [micro-benchmarks](https://wiki.openjdk.java.net/display/HotSpot/MicroBenchmarks). If necessary, turn off the delay using the flag `-XX:BiasedLockingStartupDelay=0`.

同步影响JVM的多个部分：对象头的结构体的定义在类`oopDesc `和`markOopDesc`中，轻量级锁的代码实现继承在解释器和编译器中，类`ObjectMonitor` 表示膨胀的锁。偏向锁集中在类`BiasedLocking`中。偏向锁通过`-XX:+UseBiasedLocking`启用，通过`-XX:-UseBiasedLocking`禁用。在java 6和java 7中默认是启用的，但是在应用程序启动后几秒才被激活。因此当心运行时间短的[micro-benchmarks](https://wiki.openjdk.java.net/display/HotSpot/MicroBenchmarks)基准测试。如果有必要，可以使用`-XX:BiasedLockingStartupDelay=0`关闭延迟激活偏向锁的选项。



## 名词解释

1. Lock Record是什么？

   答：如果一个线程要锁定一个对象的时候，将在当前线程的栈帧中建立一个名为锁记录（Lock Record）的空间，用于存储锁对象的header word的拷贝。官方为这个拷贝加了一个前缀Displaced，即Displaced mark word



