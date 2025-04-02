<center><h2>Tested with Red5 0.9.1</h2>(25.08.2010)</center>
<br/>Make sure that in your deployed webapps directory that you have a folder with the name of your application and under that, it mirrors this dir structure:
<br/>WEB-INF/
<br/>   classes/ (your compiled classes)
<br/>   lib/ (your required JAR files)
<br/>   web.xml
<br/>   red5-web.xml
<br/>   red5-web.properties
<br/>
	<hr/>
<br/><b>red5-web.properties</b>:
<div style="background-color:#dadada">
	webapp.contextPath=/<b>app1</b>
	<br/>webapp.virtualHosts=*
	<br/>
	<br/>
</div>
<br/><b>red5-web.xml</b>:
<div style="background-color:#dadada">
	<br/>	&lt;?xml version="1.0" encoding="UTF-8"?>
	<br/>	&lt;!DOCTYPE beans PUBLIC "-//SPRING//DTD BEAN//EN" "http://www.springframework.org/dtd/spring-beans.dtd">
	<br/>	&lt;beans>
	<br/>	
	<br/>	&lt;bean id="placeholderConfig" class="org.springframework.beans.factory.config.PropertyPlaceholderConfigurer">
	<br/>	    &lt;property name="location" value="/WEB-INF/red5-web.properties" />
	<br/>	&lt;/bean>
	<br/>	
	<br/>	&lt;bean id="web.context" class="org.red5.server.Context" autowire="byType" />
	<br/>	
	<br/>	&lt;bean id="web.scope" class="org.red5.server.WebScope" init-method="register">
	<br/>		&lt;property name="server" ref="red5.server" />
	<br/>		&lt;property name="parent" ref="global.scope" />
	<br/>		&lt;property name="context" ref="web.context" />
	<br/>		&lt;property name="handler" ref="web.handler" />
	<br/>		&lt;property name="contextPath" value="${webapp.contextPath}" />
	<br/>		&lt;property name="virtualHosts" value="${webapp.virtualHosts}" />
	<br/>	&lt;/bean>
	<br/>	
	<br/>	&lt;bean id="web.handler" class="<b>grozav.paul.red5.app1.Application</b>" singleton="true" />
	<br/>
	<br/>&lt;/beans>
	<br/>
	<br/>
</div>
<br/><b>web.xml</b>:
<div style="background-color:#dadada">
	&lt;?xml version="1.0" encoding="ISO-8859-1"?>
	<br/>&lt;web-app xmlns="http://java.sun.com/xml/ns/j2ee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://java.sun.com/xml/ns/j2ee http://java.sun.com/xml/ns/j2ee/web-app_2_4.xsd" version="2.4">
	<br/>
	<br/>	&lt;display-name><b>app1</b>&lt;/display-name>
	<br/>	
	<br/>	&lt;context-param>
	<br/>		&lt;param-name>webAppRootKey&lt;/param-name>
	<br/>		&lt;param-value>/<b>app1</b>&lt;/param-value>
	<br/>	&lt;/context-param>
	<br/>
	<br/>&lt;/web-app>
	<br/>
	<br/>
</div>