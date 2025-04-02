package grozav.paul.net.stratus
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import mx.controls.Alert;

	//EVENTS
	/** Cand m-am conectat cu succes la server **/
	[Event(name="connectedToServer", type="grozav.paul.net.stratus.StratusEvent")]
	/** Cand conexiunea cu serverul s-a inchis(a fost pierduta) **/
	[Event(name="connectionClosed", type="grozav.paul.net.stratus.StratusEvent")]
	/** Cand nu s-a putut conecta la server **/
	[Event(name="connectionFailed", type="grozav.paul.net.stratus.StratusEvent")]
	
	/** Cand un partener s-a conectat la stream.
	 * <br />Foloseste PEER_CONNECTED lansat de StratusSendStream ca sa aflii cand se conecteaza un peer la stream
	 * <br />Acest eveniment se lanseaza cand un peer se conecteaza la orice stream. Astfel ca nu mai stii la ce stream s-a conectat.**/
	[Event(name="peerConnected", type="grozav.paul.net.stratus.StratusPeerEvent")]
	/** Cand un partener s-a deconectat de la stream **/
	[Event(name="peerDisconnected", type="grozav.paul.net.stratus.StratusPeerEvent")]
	
	/** Alt NetStatusEvent **/
	[Event(name="netStatus", type="flash.events.NetStatusEvent")]

	public class StratusConnection extends EventDispatcher
	{
		/** Adresa catre server (la care se concateneaza ID-ul pentru adresa completa) **/
		private const STRATUS_SERVER_ADDRESS:String = "rtmfp://stratus.adobe.com/";
		
		/** Conexiunea catre server **/
		public var connection:NetConnection = new NetConnection();
		
		/** Conectat sau nu la server **/
		[Bindable]public var connected:Boolean = false;
		
		/** ID-ul generat de server **/
		[Bindable]public var myId:String;
		
		public function StratusConnection(target:IEventDispatcher=null){ super(target); }
		
		/** Conecteaza-te la server folosind acest ID(key) **/
		public function connect(developerKey:String):void{
			connection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			connection.connect(STRATUS_SERVER_ADDRESS+developerKey);
		}
		
		/**
		 * Aceasta functie se ocupa de
		 * <br/><b>conexiunea cu serverul</b>
		 * <br/>- conectat cu succes
		 * <br/>- conexiune inchisa
		 * <br/>- conexiune esuata
		 * <br/><b>conectarea partenerilor</b>
		 * <br/>- conectat cu succes
		 * <br/>- conexiune inchisa
		 **/
		private function onNetStatus(event:NetStatusEvent):void{
			switch (event.info.code){
				case "NetConnection.Connect.Success":
					onConnected();
				break;
				
				case "NetConnection.Connect.Closed":
					onConnectionClosed(event);
				break;
				
				case "NetConnection.Connect.Failed":
					onConnectionFailed();
				break;
				
				case "NetStream.Connect.Success":
					onPeerConnected(event);
				break;
				
				case "NetStream.Connect.Closed":
					onPeerDisconnected(event);
				break;
				
				default:
					dispatchEvent(event);
				break;
			}
		}
		
		private function onConnected():void{
			connected = true;
			myId = connection.nearID;
			var e:StratusEvent = new StratusEvent(StratusEvent.CONNECTED_TO_SERVER);
			e.connection = connection;
			e.address = connection.uri;
			dispatchEvent(e);
		}
		private function onConnectionClosed(event:NetStatusEvent):void{
			connected = false;
			var e:StratusEvent = new StratusEvent(StratusEvent.CONNECTION_CLOSED);
			e.connection = connection;
			e.address = connection.uri;
			dispatchEvent(e);
		}
		private function onConnectionFailed():void{
			connected = false;
			var e:StratusEvent = new StratusEvent(StratusEvent.CONNECTION_FAILED);
			e.connection = connection;
			e.address = connection.uri;
			dispatchEvent(e);
		}
		
		private function onPeerConnected(event:NetStatusEvent):void{
			var ns:NetStream;
			var e:StratusPeerEvent = new StratusPeerEvent(StratusPeerEvent.PEER_CONNECTED);
			e.peerStream = event.info.stream;
			e.peerId = event.info.stream.farID;
			e.streamName = null;
			dispatchEvent(e);
		}
		private function onPeerDisconnected(event:NetStatusEvent):void{
			var e:StratusPeerEvent = new StratusPeerEvent(StratusPeerEvent.PEER_DISCONNECTED);
			e.peerStream = event.info.stream;
			e.peerId = event.info.stream.farID;
			e.streamName = null;
			dispatchEvent(e);
		}
		
	}
}