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





#### 方法讲解


计数方法，类似longAdder原理，减少并发
```
private final void fullAddCount(long x, boolean wasUncontended) {
	int h;
	if ((h = ThreadLocalRandom.getProbe()) == 0) {
		ThreadLocalRandom.localInit();      // force initialization
		h = ThreadLocalRandom.getProbe();
		wasUncontended = true;
	}
	boolean collide = false;                // True if last slot nonempty
	for (;;) {
		CounterCell[] as; CounterCell a; int n; long v;
		if ((as = counterCells) != null && (n = as.length) > 0) { // 数组不为空
			if ((a = as[(n - 1) & h]) == null) { // counterCells数组不为空，但是对应下标为空，有可能有其它线程在初始化数组
				if (cellsBusy == 0) {  // 如果没有其他线程在初始化数组，则进行初始化某个下标的元素CounterCell
					CounterCell r = new CounterCell(x); // Optimistic create
					if (cellsBusy == 0 &&
						U.compareAndSwapInt(this, CELLSBUSY, 0, 1)) {
						boolean created = false;
						try {               // Recheck under lock
							CounterCell[] rs; int m, j;
							if ((rs = counterCells) != null &&
								(m = rs.length) > 0 &&
								rs[j = (m - 1) & h] == null) {
								rs[j] = r;
								created = true;
							}
						} finally {
							cellsBusy = 0;
						}
						if (created) // 成功则退出
							break;
						continue;           // Slot is now non-empty
					}
				}
				collide = false;
			}
			else if (!wasUncontended)       // CAS already known to fail
				wasUncontended = true;      // Continue after rehash
			else if (U.compareAndSwapLong(a, CELLVALUE, v = a.value, v + x))
				break;
			else if (counterCells != as || n >= NCPU)
				collide = false;            // At max size or stale
			else if (!collide)
				collide = true;
			else if (cellsBusy == 0 &&
					 U.compareAndSwapInt(this, CELLSBUSY, 0, 1)) { // 竞争比较大，给数组扩容
				try {
					if (counterCells == as) {// Expand table unless stale
						CounterCell[] rs = new CounterCell[n << 1];
						for (int i = 0; i < n; ++i)
							rs[i] = as[i];
						counterCells = rs;
					}
				} finally {
					cellsBusy = 0;
				}
				collide = false;
				continue;                   // Retry with expanded table
			}
			h = ThreadLocalRandom.advanceProbe(h);
		}
		else if (cellsBusy == 0 && counterCells == as &&
				 U.compareAndSwapInt(this, CELLSBUSY, 0, 1)) { // 数组为空，则判断尝试获取锁，然后初始化数组并设置增加值
			boolean init = false;
			try {                           // Initialize table
				if (counterCells == as) {
					CounterCell[] rs = new CounterCell[2];
					rs[h & 1] = new CounterCell(x);
					counterCells = rs;
					init = true;
				}
			} finally {
				cellsBusy = 0;
			}
			if (init)
				break; // 成功则退出
		}
		else if (U.compareAndSwapLong(this, BASECOUNT, v = baseCount, v + x)) // 数组为空，且cellsBusy被其它线程获取到了，尝试增加值
			break;                          // Fall back on using base
	}
}
```



```
private final void addCount(long x, int check) {
	CounterCell[] as; long b, s;
	if ((as = counterCells) != null ||
		!U.compareAndSwapLong(this, BASECOUNT, b = baseCount, s = b + x)) {
		CounterCell a; long v; int m;
		boolean uncontended = true;
		if (as == null || (m = as.length - 1) < 0 ||
			(a = as[ThreadLocalRandom.getProbe() & m]) == null ||
			!(uncontended =
			  U.compareAndSwapLong(a, CELLVALUE, v = a.value, v + x))) {
			fullAddCount(x, uncontended);
			return;
		}
		if (check <= 1)
			return;
		s = sumCount(); // 元素的总数
	}
	if (check >= 0) {
		Node<K,V>[] tab, nt; int n, sc;
		while (s >= (long)(sc = sizeCtl) && (tab = table) != null &&
			   (n = tab.length) < MAXIMUM_CAPACITY) { // 达到扩容的阈值，进行扩容
			int rs = resizeStamp(n); // 一个负数值
			if (sc < 0) { // sizeCtl小于0，表示有线程正在进行扩容
				if ((sc >>> RESIZE_STAMP_SHIFT) != rs || sc == rs + 1 ||
					sc == rs + MAX_RESIZERS || (nt = nextTable) == null ||
					transferIndex <= 0)
					break;
				if (U.compareAndSwapInt(this, SIZECTL, sc, sc + 1)) // 增加扩容线程的数量，帮助扩容
					transfer(tab, nt);
			}
			else if (U.compareAndSwapInt(this, SIZECTL, sc,
										 (rs << RESIZE_STAMP_SHIFT) + 2)) // 将sizeCtl修改改为负数，表示在扩容
				transfer(tab, null);
			s = sumCount();
		}
	}
}
```
sizeCtl： 
	用来控制初始化和扩容，当为负数的时候表示正在扩容或者初始化，-1的时候是初始化，或者 -(1 + 扩容线程的数量)。
	当table为null时，保存创建table时的初始化大小，或默认为0。初始化后，保存下次扩容的大小，在此基础上调整表的大小


```
static final int resizeStamp(int n) {
	return Integer.numberOfLeadingZeros(n) | (1 << (RESIZE_STAMP_BITS - 1));
}

Integer.numberOfLeadingZeros(n): 计算数字n的二进制中，前面0的数量。如n=16,结果为27

RESIZE_STAMP_BITS = 16


RESIZE_STAMP_BITS - 1的二进制表示：	0000 0000 0000 0000 0000 0000 0000 1111
1 << (RESIZE_STAMP_BITS - 1):     	0000 0000 0000 0000 0000 0000 0001 1110
Integer.numberOfLeadingZeros(n)： 	0000 0000 0000 0000 0000 0000 0001 0000
或运算的结果：					  	0000 0000 0000 0000 0000 0000 0001 1110
```


扩容的代码：
* 在扩容的时候，有可能会有多个线程一起迁移数据，这时就需要每个线程分配一些hash桶来迁移。

```
-----------------------------
|  |  |  |  | bound |    | i|
-----------------------------

private final void transfer(Node<K,V>[] tab, Node<K,V>[] nextTab) {
	int n = tab.length, stride;
	
	// 计算迁移的步长：表示本线程需要迁移多少个桶
	if ((stride = (NCPU > 1) ? (n >>> 3) / NCPU : n) < MIN_TRANSFER_STRIDE)
		stride = MIN_TRANSFER_STRIDE; // subdivide range
	
	// 初始化新table，大小为原来的2倍
	if (nextTab == null) {
		try {
			@SuppressWarnings("unchecked")
			Node<K,V>[] nt = (Node<K,V>[])new Node<?,?>[n << 1]; // 新table的大小为原来的2倍
			nextTab = nt;
		} catch (Throwable ex) {      // try to cope with OOME
			sizeCtl = Integer.MAX_VALUE;
			return;
		}
		nextTable = nextTab;
		transferIndex = n; // 需要扩容的桶数量
	}
	
	int nextn = nextTab.length;
	ForwardingNode<K,V> fwd = new ForwardingNode<K,V>(nextTab);
	boolean advance = true;
	boolean finishing = false; // to ensure sweep before committing nextTab
	for (int i = 0, bound = 0;;) {
		Node<K,V> f; int fh;
		while (advance) { // 计算本线程在扩容中需要迁移的桶的下标bound和i
			int nextIndex, nextBound;
			if (--i >= bound || finishing) // 迁移数据还未完成，i--，继续迁移下一个桶的位置，退出while循环
				advance = false;
			else if ((nextIndex = transferIndex) <= 0) { // 表示需要迁移的桶的位置被分配完成，或者迁移完成
				i = -1;
				advance = false;
			}
			else if (U.compareAndSwapInt
					 (this, TRANSFERINDEX, nextIndex,
					  nextBound = (nextIndex > stride ?
								   nextIndex - stride : 0))) { // 通过乐观锁，设置迁移桶的下标
				bound = nextBound;
				i = nextIndex - 1;
				advance = false;
			}
		}
		
		if (i < 0 || i >= n || i + n >= nextn) { // 这个方法没看懂？？？？？？？？
			int sc;
			if (finishing) {
				nextTable = null;
				table = nextTab;
				sizeCtl = (n << 1) - (n >>> 1);
				return;
			}
			if (U.compareAndSwapInt(this, SIZECTL, sc = sizeCtl, sc - 1)) { // 这个方法没看懂？？？？？？？？
				if ((sc - 2) != resizeStamp(n) << RESIZE_STAMP_SHIFT)
					return;
				finishing = advance = true;
				i = n; // recheck before commit
			}
		}
		else if ((f = tabAt(tab, i)) == null) // 如果该位置为空，设置一个ForwardingNode，防止这时候有其它线程put的时候向这个位置put
			advance = casTabAt(tab, i, null, fwd);
		else if ((fh = f.hash) == MOVED)
			advance = true; // already processed
		else {
			synchronized (f) {
				if (tabAt(tab, i) == f) { // 加锁之后再次判断头结点是否被修改了
					Node<K,V> ln, hn;
					if (fh >= 0) { // 链表的迁移，红黑树的头结点的hash是-2
						int runBit = fh & n;
						Node<K,V> lastRun = f;
						for (Node<K,V> p = f.next; p != null; p = p.next) {
							int b = p.hash & n;
							if (b != runBit) {
								runBit = b;
								lastRun = p;
							}
						}
						if (runBit == 0) {
							ln = lastRun;
							hn = null;
						}
						else {
							hn = lastRun;
							ln = null;
						}
						for (Node<K,V> p = f; p != lastRun; p = p.next) {
							int ph = p.hash; K pk = p.key; V pv = p.val;
							if ((ph & n) == 0)
								ln = new Node<K,V>(ph, pk, pv, ln);
							else
								hn = new Node<K,V>(ph, pk, pv, hn);
						}
						setTabAt(nextTab, i, ln);
						setTabAt(nextTab, i + n, hn);
						setTabAt(tab, i, fwd);
						advance = true; // 迁移完成，设置为true，重新计算下次迁移桶的位置i
					}
					else if (f instanceof TreeBin) { // 红黑树的迁移
						TreeBin<K,V> t = (TreeBin<K,V>)f;
						TreeNode<K,V> lo = null, loTail = null;
						TreeNode<K,V> hi = null, hiTail = null;
						int lc = 0, hc = 0;
						for (Node<K,V> e = t.first; e != null; e = e.next) {
							int h = e.hash;
							TreeNode<K,V> p = new TreeNode<K,V>
								(h, e.key, e.val, null, null);
							if ((h & n) == 0) {
								if ((p.prev = loTail) == null)
									lo = p;
								else
									loTail.next = p;
								loTail = p;
								++lc;
							}
							else {
								if ((p.prev = hiTail) == null)
									hi = p;
								else
									hiTail.next = p;
								hiTail = p;
								++hc;
							}
						}
						ln = (lc <= UNTREEIFY_THRESHOLD) ? untreeify(lo) :
							(hc != 0) ? new TreeBin<K,V>(lo) : t;
						hn = (hc <= UNTREEIFY_THRESHOLD) ? untreeify(hi) :
							(lc != 0) ? new TreeBin<K,V>(hi) : t;
						setTabAt(nextTab, i, ln);
						setTabAt(nextTab, i + n, hn);
						setTabAt(tab, i, fwd);
						advance = true;
					}
				}
			}
		}
	}
}
```


