package grozav.paul.net.stratus
{
	import flash.events.Event;
	import flash.net.NetStream;
	
	public class StratusPeerEvent extends Event
	{
		public static const PEER_CONNECTED:String = "peerConnected";
		public static const PEER_DISCONNECTED:String = "peerDisconnected";
		
		public var peerStream:NetStream;
		public var peerId:String;
		public var streamName:String;
		
		public function StratusPeerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}