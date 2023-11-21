# 定时器 ddc

启动配置类：`DdcAutoConfiguration`

启动类：SchedulerStarter


ApplicationContext{
	
	StatusReqServiceHttpImpl

	// 执行任务的线程池
	Map<Integer, ExecutorService> executorServiceMap;
}


SdkServer{

	start(){
		ArchHttpServer archHttpServer = new ArchHttpServerImpl();
		SdkServerService sdkServerService = new SdkServerServiceImpl(this.executingTaskList);
        archHttpServer.addHandler("/ddc/dispatcher", new DispatcherHandler(sdkServerService));
	}
}


DispatcherHandler

SdkServerServiceImpl

TaskExecuteThread