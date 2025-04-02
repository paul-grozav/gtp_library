package grozav.paul.net.stratus
{
	import flash.events.Event;
	import flash.net.NetConnection;
	
	public class StratusEvent extends Event
	{
		public static const CONNECTED_TO_SERVER:String = "connectedToServer";
		public static const CONNECTION_CLOSED:String = "connectionClosed";
		public static const CONNECTION_FAILED:String = "connectionFailed";
		
		public var connection:NetConnection;
		public var address:String;
		
		public function StratusEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}