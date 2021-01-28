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

```
Poller implements Runnable{
	Selector selector;
	
	SynchronizedQueue<PollerEvent> events = new SynchronizedQueue<>();
	
	run(){
	
		
	
	}
	
}
```


SocketProcessor


https://medium.com/@xunnan.xu/its-all-about-buffers-zero-copy-mmap-and-java-nio-50f2a1bfc05c



```
Bootstrap {
	// 使用catalinaLoader类加载器实例化对象
	Object catalinaDaemon = new Catalina();

	init(){
	
		// 初始化类加载器
		// 1. 加载类加载器commonLoader
		// 2. 使用commonLoader加载类加载器：catalinaLoader、sharedLoader
		initClassLoaders();
		
	}

	start(){
		catalinaDaemon.start();
	}

}
```

```
Catalina{

	// 使用的sharedLoader
	ClassLoader parentClassLoader;
	
	// 根据server.xml解析而来
	Server server = new StandardServer();
	
	
	
	
	start(){
	
	
	}
}
```



## 组件
Valve: 阀门，是一个与特定容器相关联的解析请求的组件。一系列的Valve通常和Pipeline关联使用。链表结构

Pipeline
	List<Valve>
	Basic Valve： 链表中最后的一个Valve


Server
	List<Service>
	

Engine
	List<Host>
	Pipeline pipeline;
		Basic Valve： StandardEngineValve
		
		
Host	一个应用一个host
	List<Context>
	Pipeline pipeline;
		StandardHostValve:
	
	
Context	应用的wrapper的集合
	List<Wrapper>
	Pipeline pipeline;
		StandardContextValve


Wrapper： 一个Servlet的class对应一个Wrapper
	List<Servlet>
	Pipeline pipeline;
		StandardWrapperValve





Connector： 定义使用的协议
	ProtocolHandler protocolHandler 


## 请求解析流程：
Acceptor -> 
NioEndpoint.Poller#processKey -> Executor.execute() -> SocketProcessor#run() -> Http11Processor#service -> CoyoteAdapter#service -> 
StandardEngineValve -> StandardHostValve -> StandardContextValve -> StandardWrapperValve -> ApplicationFilterChain.doFilter() -> Servlet.service()

AbstractProtocol.AbstractConnectionHandler#process


### http协议的解析

http协议组成：请求行 + 请求头 + 请求体
```
GET /serveletDemo/hello HTTP/1.1
Host: localhost:8080
Connection: keep-alive
Cache-Control: max-age=0
sec-ch-ua: "Google Chrome";v="87", " Not;A Brand";v="99", "Chromium";v="87"
sec-ch-ua-mobile: ?0
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9
Sec-Fetch-Site: none
Sec-Fetch-Mode: navigate
Sec-Fetch-User: ?1
Sec-Fetch-Dest: document
Accept-Encoding: gzip, deflate, br
Accept-Language: zh-CN,zh-TW;q=0.9,zh;q=0.8,en;q=0.7
Cookie: ABTEST=7|1607424680|v17
```

tomcat支持的协议有http协议和ajp协议，每种协议针对nio和bio有不同的协议解析实现类，协议解析的顶级接口是`Processor`，实现类有：`Http11NioProcessor`、`Http11Processor`，
它们都有一个共同的父类：`AbstractHttp11Processor`、`AbstractProcessor`，在解析socket连接的过程中，一个socket实例对应一个`Processor`解析类，层次结构如下：
```
Processor
	AbstractProcessor
		AbstractHttp11Processor
			Http11NioProcessor
			AbstractProcessor
```


在解析http协议的时候还离不开输入流缓冲`org.apache.coyote.InputBuffer`，用于将从socket中读取的数据都存入到`org.apache.coyote.InputBuffer`中的一个byte数组中去，后续解析http协议的时候都从这个数组中拿数据，
以及http协议中的哪个字段是哪些字节则由`MessageBytes`、`ByteChunk`来维护，以此来减少内存空间的占用。

InputBuffer的实现类：
	* InternalNioInputBuffer : nio的实现方式
	* InternalInputBuffer ： bio的实现方式

```
AbstractInputBuffer {
	// 存放从socket读取的数据
	protected byte[] buf;
}
```



```
MessageBytes{
	ByteChunk byteC=new ByteChunk();
	CharChunk charC=new CharChunk();
}

ByteChunk{
	private byte[] buff; // 对InputBuffer中的数组的引用
	protected int start; // 有效数据的起始下标
    protected int end;   // 有效数据的结束下标
}
```


```
AbstractHttp11Processor {

	protected abstract AbstractInputBuffer<S> getInputBuffer();
}


Http11NioProcessor extends AbstractHttp11Processor{

	protected InternalNioInputBuffer inputBuffer = null;
	protected Request request = new Request();
	
	public Http11NioProcessor(){
		inputBuffer = new InternalNioInputBuffer(request, maxHttpHeaderSize, rejectIllegalHeader, httpParser);
		request.setInputBuffer(inputBuffer);
	}
}
```


```
org.apache.coyote.Request{
	private org.apache.coyote.InputBuffer inputBuffer = null;
}
```

```
org.apache.catalina.connector.Request{

	protected org.apache.coyote.Request coyoteRequest;
	
	protected org.apache.catalina.connector.InputBuffer inputBuffer = new InputBuffer();
	
	public void setCoyoteRequest(org.apache.coyote.Request coyoteRequest) {
        this.coyoteRequest = coyoteRequest;
        inputBuffer.setRequest(coyoteRequest);
    }
	
	public HttpServletRequest getRequest() {
        if (facade == null) {
            facade = new RequestFacade(this);
        }
        return facade;
    }
	
	@Override
    public ServletInputStream getInputStream() throws IOException {
        if (inputStream == null) {
            inputStream = new CoyoteInputStream(inputBuffer);
        }
        return inputStream;
    }
}
```

```
RequestFacade{
	protected org.apache.catalina.connector.Request request = null;
	
	public ServletInputStream getInputStream() throws IOException {
        return request.getInputStream();
    }
}
```


org.apache.coyote.InputBuffer
org.apache.catalina.connector.InputBuffer


org.apache.coyote.Request
org.apache.catalina.connector.Request
org.apache.catalina.connector.RequestFacade


org.apache.coyote.http11.InputFilter
	* BufferedInputFilter
	* IdentityInputFilter
	* ChunkedInputFilter
	* SavedRequestInputFilter
	* VoidInputFilter






## 启动过程

Bootstrap.start

Catalina.start()
	StandardServer.start()
		StandardService.start()
			Container.start()
			Executor.start()
			Connector.start()
			
			
Connector： 定义使用的协议，Http11Protocol、AjpProtocol或者自定义的
	ProtocolHandler protocolHandler


## 类加载器
	common
	server
	shared

org.apache.catalina.startup.Catalina






## 长连接的底层原理与源码实现

如果在浏览器端发起http请求的时候在头部设置了`Connection: keep-alive`的属性，那么tomcat在处理这个连接的时候就有可能把这个连接当做是一个长连接来处理。
作为长连接的socket，在使用完之后并不会关闭连接，反之短连接在使用完之后会关闭连接，并在返回的http协议的头部会有`Connection: close`。

服务端关闭连接的例子：
```
请求头：
Connection: keep-alive

响应头：
Connection: close
Content-Length: 13
```


关于长连接的配置参数server.xml：
```
<Connector port="8080" protocol="org.apache.coyote.http11.Http11NioProtocol"
               connectionTimeout="20000" 
			   redirectPort="8443"
               disableKeepAlive="true"
               maxKeepAliveRequests="1"
    />
```

disableKeepAlive: 
	* 在nio下该值永远为false，不可配置，bio下才可以配置

soTimeout
maxKeepAlivedSocket
maxKeepAliveRequests
	* 指一个连接，最多可以一次执行多少个请求
	* 如果`maxKeepAliveRequests`的值是1，则在解析socket连接的时候，一次最多处理一个http请求，且不允许建立长连接。



从`AbstractHttp11Processor.process()`中提炼出来的操作：
```
while(keepAlive){
	// 解析请求行
	getInputBuffer().parseRequestLine(keptAlive);

	// 解析请求头
	getInputBuffer().parseHeaders();
	
	// 在读取http请求头之后，根据读取的参数，设置相关参数，如：keepAlive
    prepareRequest();
	
	// 如果maxKeepAliveRequests等于1，则禁用长连接；如果这个连接处理的http请求书没有达到maxKeepAliveRequests，也继续处理http请求
	// 注意：keepAliveLeft的初始值等于maxKeepAliveRequests
	if (maxKeepAliveRequests == 1) {
		keepAlive = false;
	} else if (maxKeepAliveRequests > 0 &&
			--keepAliveLeft <= 0) {
		keepAlive = false;
	}
	
	// 处理请求
	adapter.service(request, response);
	
	// 
	endRequest();
	
	getInputBuffer().nextRequest();
    getOutputBuffer().nextRequest();
	
	// 判断是否结束循环
	if (breakKeepAliveLoop(socketWrapper)) {
		break;
	}
}
```

从上面的代码可以看出，如果http请求头设置了keep-alive，那么tomcat后台在处理这个连接的时候，会循环处理这个连接，在这个过程中这个连接会一直占用一个tomcat的线程。


```
NioChannel{
	SocketChannel sc;
	ApplicationBufferHandler bufHandler;
	Poller poller;
}

SocketWrapper {
	// E可能的类型：NioChannel
	E socket;
	
	// 该值来自：NioEndpoint.this.getMaxKeepAliveRequests，从server.xml中配置
	protected volatile int keepAliveLeft = 100;
	
}

KeyAttachment extends SocketWrapper{
	// 
	Poller poller;
}
```

KeyAttachment 在selector注册的att参数





171.212.210.166




