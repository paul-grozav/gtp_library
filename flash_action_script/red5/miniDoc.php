<head><title> Mini documentatie Red5 - Grozav Paul </title></head>
<link REL="SHORTCUT ICON" HREF="http://1.pe-web.ro/public/files/media/icon/red5.ico">

<b>Client Side(ActionScript):</b>
<br><a href="#CSswitch(NetStatusEvent)"> switch(NetStatusEvent) </a>

<br><br><b>Server Side(Java):</b>
<br><a href="#SSappStart">Application start</a> 
<br><a href="#SSappConnect"> When a client connects to the app </a> 
<br><a href="#SSappLeave"> When a client disconnects from the app </a>

<br><br><b>my Java classes:</b>
<br><a href="#MJCAlert"> Alert.show("my message") </a> 
<br><a href="#MJCInvoke"> Invoke.invokeOnAllClientsFromScope(IScope, String, Object[]) </a>










<hr>
<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>


<hr><a name="CSswitch(NetStatusEvent)">
	switch(evt.info.code){<br>
		case "NetConnection.Connect.Success":<br>
			Alert.show("Connected");<br>
		break;<br>
		case "NetConnection.Connect.Closed":<br>
			Alert.show("Disconnected");<br>
		break;<br>
	}<br>
</a>




<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>





<hr><a name="SSappStart">
	public boolean appStart(IScope app){<br>
		Alert.show("Aplication " + app.getName() + " was started");<br>
		return true;<br>
	}<br>
</a>

<hr><a name="SSappConnect">
	public boolean appConnect(IConnection conn, Object[] params){<br>
		Alert.show(conn.getRemoteAddress() + " connected to the application");<br>
		return true;<br>
	}<br>
</a>

<hr><a name="SSappLeave">
	public void appLeave(IClient client, IScope app){<br>
		Alert.show("Client disconnect");<br>
	}<br>
</a>




<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>







<hr><a name="MJCAlert">
public class Alert{<br>
	public static void show(String msg){<br>
		Dimension screenR = Toolkit.getDefaultToolkit().getScreenSize();<br>
		JFrame window = new JFrame("Atentie");<br>
			JLabel message = new JLabel(msg);<br>
			window.getContentPane().add(message);<br>
		window.pack();<br>
		window.setVisible(true);<br>
		window.setLocation(new Point((screenR.width - window.getWidth())/2, (screenR.height - window.getHeight())/2));<br>
	}<br>
}<br>
</a>


<hr><a name="MJCInvoke">
public class Invoke{<br>
	public static void invokeOnAllClientsFromScope(IScope scope, String method, Object[] params){<br>
		Iterator<IConnection> connections = scope.getConnections();<br>
		while(connections.hasNext()){<br>
			IConnection conexiune = connections.next();<br>
			if(conexiune instanceof IServiceCapableConnection){<br>
				((IServiceCapableConnection) conexiune).invoke(method, params);<br>
			}<br>
		}<br>
	}<br>
}<br>
</a>









<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>