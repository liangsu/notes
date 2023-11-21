# cron表达式怎么计划下一执行时间

本文基于：spring-context:5.3.9 中的CronExpression分析

CronField.Type{

	ChronoField field;

	ChronoField[] lowerOrders;

}

CronField{
	Type type
}

BitsCronField{
	long bits;
}


## bits详解：

按二进制位使用，在时、分、秒、日、月中最大的数字是59，所以最多使用60位，
意义表示：第几位不为0，表示第几+1会有执行时间

计算下一执行时刻：

MASK = 0xFFFF FFFF FFFF FFFF // 8字节

举例说明：如果在分这一位，某一个定时器在 10、12 分钟有执行则bits表示为：`0001 0100 0000 0000`

当前时间是： 2022-03-18 18:11:00   11

将MAST右移11位： `1111 1000 0000 0000`

bits & 将MAST右移11位：

0001 0100 0000 0000
1111 1000 0000 0000
0001 0000 0000 0000

结果中最右边有几个0，则表示下一执行时刻是几，结果是：12


## 计算下一执行源码解析


```
private <T extends Temporal & Comparable<? super T>> T nextOrSameInternal(T temporal) {
	// 按周、月、日、时、分、秒的顺序执行
	for (CronField field : this.fields) {
		temporal = field.nextOrSame(temporal);
		if (temporal == null) { // 返回空表示到达了最大执行次数
			return null;
		}
	}
	return temporal;
}
```

```
public <T extends Temporal & Comparable<? super T>> T nextOrSame(T temporal) {
	int current = type().get(temporal);
	// 计算一下执行时刻，如果计算结果全是0，则返回-1
	int next = nextSetBit(current);
	// 如：10 20 30 40 50 有执行结果，当前值是55，运算后的结果全是0，则返回-1
	if (next == -1) {
		temporal = type().rollForward(temporal);
		next = nextSetBit(0);
	}
	if (next == current) {
		return temporal;
	}
	else { // 走到这里，表示需要调整日期，所以这里的最后会调用：type().reset(temporal)，将后置位的时间设置为0值
	
		int count = 0;
		current = type().get(temporal);
		
		// 当下一执行时刻不等于当前时间的时候，执行这里，表示需要调整时间
		// 至于什么时候会触发多次循环还没有理解？？？？？
		while (current != next && count++ < CronExpression.MAX_ATTEMPTS) {
			// 将当前时间调整到下一执行时刻
			temporal = type().elapseUntil(temporal, next);
			
			current = type().get(temporal);
			next = nextSetBit(current);
			if (next == -1) {
				temporal = type().rollForward(temporal);
				next = nextSetBit(0);
			}
		}
		
		if (count >= CronExpression.MAX_ATTEMPTS) {
			return null;
		}
		
		// 重新设置一下后面的时间，如：如果小时变了，则将后面的分、秒设置为0值
		// 周变了，将时、分、秒设置为0值
		return type().reset(temporal);
	}
}
```

返回：
	不为-1：下一执行时刻值
	-1：表示下一执行时刻比可执行的所有值都大，需要增大当前时间再计算下一执行时刻值，
		如：10 20 30 40 50 有执行，当前值是55，运算后的结果全是0，则返回-1
```
private int nextSetBit(int fromIndex) {
	long result = this.bits & (MASK << fromIndex);
	if (result != 0) {
		return Long.numberOfTrailingZeros(result);  // 最右边有几个连续的0
	} else {
		return -1;
	}
}
```


推演示例：
cron表达式： 0 10 * * * ?  每个小时第10分执行
当前时间：   2022-01-01 00:00:00


cron表达式： 0 5 20 * * ?  每个小时第10分执行
当前时间：   2022-03-23 9:10:00  （周三）

|计算字段	|当前值    |下一执行值    |调整后时间|
| ---- | ---- | ---- | ---- |
|计算周：    |  3	    |   3		  |2022-03-23 9:10:00  不变|
|计算月：    |  3       |   3         |2022-03-23 9:10:00  不变|
|计算日：    |  23      |   23        |2022-03-23 9:10:00  不变|
|计算时：    |  9       |   9         |2022-03-23 9:10:00  不变|
|计算分：    |  10      |   20        |2022-03-23 9:20:00  变化|
|计算秒：    |  0       |   0         |2022-03-23 9:20:00  不变|








