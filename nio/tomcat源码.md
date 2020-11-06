# tomcat

Acceptor使用的是阻塞式io，为什么呢？
Poller使用的是多路复用器，非阻塞式io

	
Acceptor
Poller

```
AbstractEndpoint{

	protected List<Acceptor<U>> acceptors;

	public final void start() throws Exception {
		// 初始化ServerSocketChannel，并绑定端口
        bind();
        
		// 1. 创建业务线程池
		// 2. 创建读取连接数据的Poller
		// 3. 创建建立连接的Acceptor
        startInternal();
    }

}
```






https://medium.com/@xunnan.xu/its-all-about-buffers-zero-copy-mmap-and-java-nio-50f2a1bfc05c



