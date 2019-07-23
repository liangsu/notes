# hystrix

## 产生背景
Hystrix 的主要目的是保护跨进程调用，避免因为超时等问题，导致的级联故障

## 功能
1. 跳闸
2. 服务降级
3. 监控，相关指标如下：
	* success: 请求成功次数
	* Short-Circuited：表示断路器打开后，直接被短路的请求数
	* Timeout：请求超时数
	* Rejected：表示因为线程池满而被拒绝的请求数
	* Failure：表示因为异常而导致失败的请求数
	* Error%：错误率，计算公式： Error% = (Timeout + Rejected + Failure)/ Total
	* Hosts: 应用个数
	* Median: Command 的中位数时间
	* Mean: Command 的平均时间
	* 90th/99th/99.5th: P90、P99、P99.5 时间
	* Rolling 10 second counters: 说明一下计数都是在一个10秒的滚动窗口内统计的
	* with 1 second granularity: 这个滚动窗口是以1秒为粒度进行统计的	
4. 限流
5. 资源隔离
6. 超时

## 服务降级
1. 触发条件：主方法抛出异常、主方法执行超时、线程池拒绝、断路器打开


# sentinel
java -Dserver.port=8080 -Dcsp.sentinel.dashboard.server=localhost:8080 -Dproject.name=sentinel-dashboard -jar sentinel-dashboard.jar

## 服务降级
* 降级策略：
	* 平均响应时间 (DEGRADE_GRADE_RT)
	* 异常比例 (DEGRADE_GRADE_EXCEPTION_RATIO)：
	* 异常数 (DEGRADE_GRADE_EXCEPTION_COUNT)
	
1. 触发条件：达到了降级策略时实施降级



## 漏铜算法、令牌桶算法、滑动窗口
