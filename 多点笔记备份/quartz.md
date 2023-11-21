# quartz

```
SchedulerFactory sf = new StdSchedulerFactory();
Scheduler sched = sf.getScheduler();
```

1. 启动过程：
加载类加载器：ClassLoadHelper
实例化JobFactory
InstanceIdGenerator
ThreadPool：SimpleThreadPool 任务执线程池
JobStore
如果是基于jdbc的存储，实例化`Semaphore`（用于数据库连接获取）
实例化数据源`ConnectionProvider`，并放入`DBConnectionManager`
SchedulerPlugin
JobListener
TriggerListener
ThreadExecutor：DefaultThreadExecutor，调度线程
JobRunShellFactory
QuartzSchedulerResources

创建`QuartzScheduler`
	创建`QuartzSchedulerThread`,然后使用`ThreadExecutor`去执行
	ExecutingJobsManager
	ErrorLogger
	SchedulerSignalerImpl	

创建Scheduler：StdScheduler


2. 提交job

调用`JobStore`存储job和trigger
通知监听器，有job新增
修改`QuartzSchedulerThread`的下次执行时间 `signalSchedulingChange()`
通知监听器，任务被定时`jobScheduled`


3. 执行任务

使用`QuartzSchedulerThread`调度任务，最后放入`ThreadPool`去执行任务

```
while (!halted.get()) { // 没有停止则无限循环
	
	synchronized (sigLock) {
			如果被暂停了`paused`，无限循环等待1s
	}
	
	// 获取将要执行的 triggers
	List triggers = JobStore.acquireNextTriggers();

	// 获取第一个trigger,判断是否到了执行时间，没到则等待
	synchronized (sigLock) {
		sigLock.wait(timeUntilTrigger);
	}
	
	// 封装triggers，返回一个可以给`QuartzSchedulerThread`看执行结果的对象
	List<TriggerFiredResult> res = qsRsrcs.getJobStore().triggersFired(triggers);
	
	for (res) {
		// 创建执行任务，里面封装了触发器调用、捕捉异常、等
		JobRunShell shell = qsRsrcs.getJobRunShellFactory().createJobRunShell(bndle);
		shell.initialize(qs);
		
		// 执行任务
		QuartzSchedulerResources.getThreadPool().runInThread(shell);
	}
	
	
	// 随机等待30s左右，可被中断，当有更早的新任务加入时，方便快速执行
	synchronized(sigLock) {
		try {
		  if(!halted.get()) {
			if (!isScheduleChanged()) {
			  sigLock.wait(timeUntilContinue);
			}
		  }
		} catch (InterruptedException ignore) {
		}
	}
	
}
```
