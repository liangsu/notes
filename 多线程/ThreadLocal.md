# ThreadLocal


## Thread类
1. 在Thread类上有个属性ThreadLocalMap：
```
public class Thread implements Runnable{
	// 
	ThreadLocal.ThreadLocalMap threadLocals;
	
	// ....
}
```

## ThreadLocal类

```
public class ThreadLocal<T> {
    // 这个hashcode是放入ThreadLocalMap中的key值
    private final int threadLocalHashCode = nextHashCode();

    // 用于生成hashcode使用
    private static AtomicInteger nextHashCode = new AtomicInteger();

    // 生成hashcode的增长量
    private static final int HASH_INCREMENT = 0x61c88647;

    // 生成hashcode
    private static int nextHashCode() {
        return nextHashCode.getAndAdd(HASH_INCREMENT);
    }
```

问题：这个hashcode的设计有什么含义吗？


