# tomcat中的InputBuffer

org.apache.coyote.InputBuffer

tomcat从socket中读取数据，离不开`InputBuffer`，这时它的作用是存储socket中数据。但是我们跟踪源码，会发现InputBuffer的实现类很多。

实现类层次结构：
```
org.apache.coyote.InputBuffer
	org.apache.coyote.http11.AbstractInputBuffer
		org.apache.coyote.http11.InternalNioInputBuffer
		org.apache.coyote.http11.InternalInputBuffer
		org.apache.coyote.http11.InternalAprInputBuffer
	org.apache.coyote.http11.InputFilter
		org.apache.coyote.http11.filters.BufferedInputFilter
		org.apache.coyote.http11.filters.ChunkedInputFilter
		org.apache.coyote.http11.filters.IdentityInputFilter
		org.apache.coyote.http11.filters.SavedRequestInputFilter
		org.apache.coyote.http11.filters.VoidInputFilter
	内部类：
	org.apache.coyote.http11.InternalInputBuffer.InputStreamInputBuffer
	org.apache.coyote.ajp.AbstractAjpProcessor.SocketInputBuffer
	org.apache.coyote.http11.InternalAprInputBuffer.SocketInputBuffer
	org.apache.coyote.http11.InternalNioInputBuffer.SocketInputBuffer
```

* 其中`AbstractInputBuffer`定义了从socket中读取数据的公共方法，包括用于存储socket中读取的数据的buf等，它的子类是分别根据bio、nio解析socket的实现。

* `InputFilter`继承自`InputBuffer`，并新增了方法`setBuffer(InputBuffer buffer)`，从接口定义中不难看出这是要使用装饰者模式。

* `IdentityInputFilter`用于根据http头部的`Content-Length`定义的长度，从socket中读取请求体中的内容

* `ChunkedInputFilter`用于根据http头部的`transfer-encoding`定义的chunked，从socket读取请求体中分块读取内容

* 上面的内部类，主要作用是作为暴露`AbstractInputBuffer`的实现方法中从socket读取数据的接口


```
public interface InputBuffer {

    public int doRead(ByteChunk chunk, Request request)
        throws IOException;

    public int available();

}
```



以下详细梳理`AbstractInputBuffer`的功能：
	* 将socket中读取的数据存储于buf字节数组中，后面解析http协议的时候也只是对该数组的引用，降低内存占用
	
	* 该类的doRead方法，定义了读取http请求体的方法，根据http头部的`Content-Length`或者`transfer-encoding`的不同，activeFilters分别对应不同的InputFilter；
	
	* 由于activeFilters读取的数据需要来自buf字节数组，所以又派生出了暴露出从socket读取数据的几个InputBuffer的内部类
	
	* 字段`filterLibrary`定义了读取请求体的一个类，该值是在`AbstractHttp11Processor#initializeFilters`中初始化的
	
```
AbstractInputBuffer<S> implements InputBuffer{
	// 
	protected byte[] buf;
    protected int lastValid; // 表示buf的有效数据范围
    protected int pos; // 表示当前buf的开始数据下标
    protected int end; // header数据的结束位置，同时也是请求体数据的开始位置。请求头解析结束，设置end的值
	
	// 
	protected InputBuffer inputStreamInputBuffer;
	
	protected InputFilter[] filterLibrary;
	
	protected InputFilter[] activeFilters;
	
	
	protected abstract boolean fill(boolean block) throws IOException;
	
	
	@Override
    public int doRead(ByteChunk chunk, Request req)
        throws IOException {

        if (lastActiveFilter == -1)
            return inputStreamInputBuffer.doRead(chunk, req);
        else
            return activeFilters[lastActiveFilter].doRead(chunk,req);

    }
	
}
```


`InputFilter`详细功能：

	* end()方法的作用：一、返回在调用doRead的时候多读了数据导致pos后移多余的数值，在请求结束时，用于修复pos的位置。二、将请求体中的数据读完，方便解析下一个http请求
	
```
public interface InputFilter extends InputBuffer {

    public int doRead(ByteChunk chunk, Request unused)
        throws IOException;

    public void setRequest(Request request);

	// 标记filter准备处理下一个请求
    public void recycle();

    public ByteChunk getEncodingName();

    public void setBuffer(InputBuffer buffer);

    public long end() throws IOException;
}
```



## ByteChunk、CharChunk


```
AbstractChunk{

	private int limit = -1;

    protected int start;
    protected int end;

}
```


```
ByteChunk extends AbstractChunk{
	private byte[] buff;

}
```











## 问题
1. 为什么AbstractInputBuffer.doRead方法不直接调用fill方法，或者直接从socket中读取数据？而是要通过inputStreamInputBuffer或者activeFilters来读取数据。
答：因为servlet在处理一个http请求的时候，如果有请求体，在servlet的处理逻辑中不一定会调用

2. 为什么我们在调用request.getInputStream().read()的时候不直接调用从socket读取数据，而要通过activeFilters中转一下？
答： 



















