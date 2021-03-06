# JDK中Map的讲解

## HashMap

### jdk1.7 
数据结构：数组+链表

异或运算：相同为0，不同为1
```
  1101
^ 0000
  1101
```

计算hash算法：
```
final int hash(Object k) {
	// hashSeed的初始值是0
	int h = hashSeed;
	if (0 != h && k instanceof String) {
		return sun.misc.Hashing.stringHash32((String) k);
	}

	// 当hashSeed为0是，异或之后的结果还是原来的hashCode
	h ^= k.hashCode();

	// This function ensures that hashCodes that differ only by
	// constant multiples at each bit position have a bounded
	// number of collisions (approximately 8 at default load factor).
	h ^= (h >>> 20) ^ (h >>> 12);
	return h ^ (h >>> 7) ^ (h >>> 4);
}

// 计算在hash表中数组的下标
static int indexFor(int h, int length) {
	// assert Integer.bitCount(length) == 1 : "length must be a non-zero power of 2";
	return h & (length-1);
}
```


1. jdk1.7中，使用的头插法



2. 多线程问题：在hash表扩容的时候可能出现循环链表，在调用get方法的时候导致死循环

扩容时机：  size > initialCapacity * loadFactor

hash扩容的目的：加快查询速度



以下代码会报错：
```
private static void testHashMap() {
	HashMap<String, Object> map = new HashMap(1);
	map.put("1", "2");
	map.put("2", "2");
	map.put("3", "2");

	// 这行代码的本质是使用迭代器，见下面使用迭代器的代码
	for(String key : map.keySet()){
		if("2".equals(key)){
			map.remove(key);
		}
	}

	// 使用迭代器遍历
	Iterator<String> iterator = map.keySet().iterator();
	while(iterator.hasNext()){
		String key = iterator.next();
		if("2".equals(key)){
			map.remove(key); // 抛异常：ConcurrentModificationException
			iterator.remove(); // 正确写法
		}
	}
}
```

### 1.8中

数据结构： 数组 + 链表/红黑树

链表插入：采用尾插法

当链表长度等于8（包括待插入的元素）的时候转换为红黑树，在调用get方法的时候加快查询速度，在插入的时候也可以提高速度

```
final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
                   boolean evict) {
	Node<K,V>[] tab; Node<K,V> p; int n, i;

	// 如果table为空，则初始化
	if ((tab = table) == null || (n = tab.length) == 0)
		n = (tab = resize()).length;
	
	if ((p = tab[i = (n - 1) & hash]) == null) // 如果头结点为空，则直接将新结点放在头部
		tab[i] = newNode(hash, key, value, null);
	else { // 头结点不为空
		
		Node<K,V> e; K k;
		if (p.hash == hash &&
			((k = p.key) == key || (key != null && key.equals(k)))) // 头结点与要插入的key相同
			e = p;
		else if (p instanceof TreeNode) // 头结点是红黑树
			e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
		else { // 头结点不为空，且是链表
			
			// 遍历链表，查找链表中是否已经插入过要新增的key，如果没有则新增结点。
			for (int binCount = 0; ; ++binCount) {
				if ((e = p.next) == null) {
					p.next = newNode(hash, key, value, null); // 使用尾插法
					if (binCount >= TREEIFY_THRESHOLD - 1) // 如果大于8，则将链表转换为红黑树
						treeifyBin(tab, hash); 
					break;
				}
				if (e.hash == hash &&
					((k = e.key) == key || (key != null && key.equals(k)))) // 链表中有新增的key
					break;
				p = e;
			}
		}
		
		// map中存在有key
		if (e != null) {
			V oldValue = e.value;
			if (!onlyIfAbsent || oldValue == null)
				e.value = value;
			afterNodeAccess(e);
			return oldValue;
		}
	}
	++modCount; // 修改次数+1
	
	// 大于了阀值，扩容hash表
	if (++size > threshold)
		resize();
	afterNodeInsertion(evict);
	return null;
}
```


## ConcurrentHashMap

### jdk1.7中：

数据结构： Segment数组 + HashEntry数组 + 链表
	
initialCapacity： 初始容量，表示这个map准备存放的元素的个数

concurrencyLevel:  并发级别，表示Segment数组的长度，该值最终会被计算为2的幂，默认值16

每个Segment中HashEntry的数组长度cap = initialCapacity / concurrencyLevel，最小取2

分段锁：使用的ReentrantLock

扩容：扩容的时候只扩展某一个Segment下的数组，不是全体Segment都扩容


#### 方法讲解

Segment.put方法
```
final V put(K key, int hash, V value, boolean onlyIfAbsent) {
	// 获取锁
	// scanAndLockForPut方法返回之后必定是获取到了锁的
	HashEntry<K,V> node = tryLock() ? null :
		scanAndLockForPut(key, hash, value);
	V oldValue;
	try {
		HashEntry<K,V>[] tab = table;
		int index = (tab.length - 1) & hash;
		HashEntry<K,V> first = entryAt(tab, index); // 获取头结点
		for (HashEntry<K,V> e = first;;) {
			if (e != null) {
				K k;
				if ((k = e.key) == key ||
					(e.hash == hash && key.equals(k))) { // 要添加的key在map中存在
					oldValue = e.value;
					if (!onlyIfAbsent) { // 是否替换以前的值
						e.value = value;
						++modCount; // 修改次数+1
					}
					break;
				}
				e = e.next;
			}
			else {
				if (node != null)
					node.setNext(first);
				else
					node = new HashEntry<K,V>(hash, key, value, first); // 使用的头插法
				int c = count + 1;
				if (c > threshold && tab.length < MAXIMUM_CAPACITY)
					rehash(node); // 扩容
				else
					setEntryAt(tab, index, node); // 插入数据
				++modCount;
				count = c;
				oldValue = null;
				break;
			}
		}
	} finally {
		// 释放锁
		unlock();
	}
	return oldValue;
}
```


```
/**
    这个方法主要目的：
        加锁，先尝试是用乐观锁，达到乐观锁的次数之后使用悲观所。
	    在尝试乐观锁期间，如果可以，尝试把加锁之后的事情提前做了，避免cpu空转，比如创建HashEntry结点

	返回值： 返回值可能值，可能null，当方法返回则必定加锁成功
 */
private HashEntry<K,V> scanAndLockForPut(K key, int hash, V value) {
	HashEntry<K,V> first = entryForHash(this, hash);
	HashEntry<K,V> e = first;
	HashEntry<K,V> node = null;
	int retries = -1; // negative while locating node
	while (!tryLock()) { // 尝试加锁失败
		HashEntry<K,V> f; // to recheck first below
		
		if (retries < 0) { // 遍历链表，如果找到有要add的key则不遍历，或者如果创建了node也不遍历了
			if (e == null) {
				// 提前创建一个node结点，估计是为了后面插入的时候避免再创建元素，在忙等待期间做一些后面需要做的事情，避免cpu空转
				if (node == null) // speculatively create node
					node = new HashEntry<K,V>(hash, key, value, null);
				retries = 0;
			}
			else if (key.equals(e.key))
				retries = 0;
			else
				e = e.next;
		}
		else if (++retries > MAX_SCAN_RETRIES) { // 到达乐观锁的尝试次数，使用lock方法
			lock();
			break;
		}
		else if ((retries & 1) == 0 &&
				 (f = entryForHash(this, hash)) != first) { // 尝试加锁次数是偶数时，如果发现头结点有变化，重新回到retries<0的执行逻辑
			e = first = f; // re-traverse if entry changed
			retries = -1;
		}
	}
	return node;
}
```



### jdk1.8中：

数据结构： 数组 + 链表/红黑树
	
当链表长度等于8（包括待插入的元素）的时候转换为红黑树，在调用get方法的时候加快查询速度，在插入的时候也可以提高速度

分段锁：使用的synchronized，对头结点加锁

扩容：
























