
/MSS_PURCHASE/portal/portal.do

sccl

org.springframework.web.context.support.XmlWebApplicationContext@1e46561: display name [WebApplicationContext for namespace 'sccl-servlet']; startup date [Tue Jan 17 10:14:38 CST 2017]; parent: org.springframework.web.context.support.XmlWebApplicationContext@14323d5

org.springframework.web.servlet.i18n.AcceptHeaderLocaleResolver@ccaff8

org.springframework.web.servlet.theme.FixedThemeResolver@1b0d0a7

org.springframework.web.context.support.XmlWebApplicationContext@1e46561: display name [WebApplicationContext for namespace 'sccl-servlet']; startup date [Tue Jan 17 10:14:38 CST 2017]; parent: org.springframework.web.context.support.XmlWebApplicationContext@14323d5


handlerMapping:
cn.sccl.common.web.CustomerControllerClassNameHandlerMapping
org.springframework.web.servlet.mvc.support.AbstractControllerUrlHandlerMapping

	org.springframework.web.servlet.handler.AbstractUrlHandlerMapping.registerHandler()

默认的一个拦截器：
org.springframework.web.servlet.handler.AbstractUrlHandlerMapping$PathExposingHandlerInterceptor@17444e7

适配器：
org.springframework.web.servlet.mvc.HttpRequestHandlerAdapter
org.springframework.web.servlet.mvc.SimpleControllerHandlerAdapter
org.springframework.web.servlet.mvc.throwaway.ThrowawayControllerHandlerAdapter
org.springframework.web.servlet.mvc.annotation.AnnotationMethodHandlerAdapter

-----------
handlerMapping： 用于获取要执行的HandlerExecutionChain、以及该handler的拦截器。默认加载所有的handlerMaping
适配器： 用于执行handler
视图解析器： 用于获取视图
视图： 用于渲染视图
主题解析器： 
上传文件解析器：
语言解析器：
异常解析器：
请求到视图名称解析器： 在没有视图的时候，用于获取默认视图




初始化：
org.springframework.web.servlet.FrameworkServlet#initServletBean

org.springframework.web.servlet.FrameworkServlet#initWebApplicationContext

org.springframework.web.servlet.FrameworkServlet#onRefresh
org.springframework.web.servlet.DispatcherServlet#onRefresh

org.springframework.web.servlet.DispatcherServlet#initStrategies

org.springframework.web.servlet.DispatcherServlet#initLocaleResolver


返回对象序列化：
org.springframework.web.servlet.HandlerAdapter#handle
	org.springframework.web.method.support.HandlerMethodReturnValueHandlerComposite#handleReturnValue
		org.springframework.web.servlet.mvc.method.annotation.AbstractMessageConverterMethodProcessor#writeWithMessageConverters()
			org.springframework.http.converter.HttpMessageConverter#write



1. Context继承： springmvc的context的父context继承自RootWebApplicationContext




国际化：
org.springframework.web.servlet.FrameworkServlet#doGet

org.springframework.web.servlet.FrameworkServlet#processRequest

org.springframework.web.servlet.FrameworkServlet#buildLocaleContext
org.springframework.web.servlet.DispatcherServlet#buildLocaleContext















