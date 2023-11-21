# slfj

```
public final class LoggerFactory{
	public static Logger getLogger(String name) {
		ILoggerFactory iLoggerFactory = getILoggerFactory();
		return iLoggerFactory.getLogger(name);
	}
}
```


1. 加载具体的日志实现类

由于slfj是日志接口，并没有具体的日志实现，所以在实例化的时候，会涉及到去加载具体的日志实现类。
所以在logback.jar中，它为了让slfj能够加载到自己，会在自己的jar包写一个slfj要去加载的类`org/slf4j/impl/StaticLoggerBinder.class`

```
bind(){
	Set<URL> staticLoggerBinderPathSet = ClassLoader.getSystemResources("org/slf4j/impl/StaticLoggerBinder.class");
	
	// 打印加载到的日志路径

	// 实例化具体日志实现，如果有多个这里会随机实例化一个
	StaticLoggerBinder.getSingleton();
}
```

```
SLF4J: Class path contains multiple SLF4J bindings.
SLF4J: Found binding in [jar:file:/my-custome-log-9.0.3.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: Found binding in [jar:file:/logback-classic-1.1.3.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
SLF4J: Actual binding is of type [ch.qos.logback.classic.util.ContextSelectorStaticBinder]
```



ch.qos.logback.classic.LoggerContext




## logback

打印日志内部状态：
```
LoggerContext lc = (LoggerContext) LoggerFactory.getILoggerFactory();
StatusPrinter.print(lc);
```

```
12:49:22,076 |-INFO in ch.qos.logback.classic.LoggerContext[default] - Could NOT find resource [logback.groovy]
12:49:22,078 |-INFO in ch.qos.logback.classic.LoggerContext[default] - Could NOT find resource [logback-test.xml]
12:49:22,093 |-INFO in ch.qos.logback.classic.LoggerContext[default] - Could NOT find resource [logback.xml]
12:49:22,093 |-INFO in ch.qos.logback.classic.LoggerContext[default] - Setting up default configuration.
```
