package grozav.paul.net.stratus
{
	import flash.net.NetStream;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	/** Cand un partener s-a conectat la stream **/
	[Event(name="peerConnected", type="grozav.paul.net.stratus.StratusPeerEvent")]
	/** Cand un partener s-a deconectat de la stream **/
	[Event(name="peerDisconnected", type="grozav.paul.net.stratus.StratusPeerEvent")]
	
	public class StratusSendStream extends NetStream
	{
		/**
		 * acceptPeer e o functie ce primeste ca parametru ns:NetStream adica stream-ul cu peer-ul ce vrea sa se
		 * conecteze. Pe baza acestui stream se stabileste daca peer-ul are voie sau nu sa se conecteze la stream.
		 **/
		public function StratusSendStream(connection:StratusConnection, acceptPeer:Function)
		{
			super(connection.connection, NetStream.DIRECT_CONNECTIONS);
			_streamName = streamName;
			
			var streamClient:Object = new Object();
			streamClient.onPeerConnect = function(ns:NetStream):Boolean{
				var accept:Boolean = acceptPeer(ns);
				if(accept){
					var e:StratusPeerEvent = new StratusPeerEvent(StratusPeerEvent.PEER_CONNECTED);
					e.peerStream = ns;
					e.peerId = ns.farID;
					e.streamName = streamName;
					dispatchEvent(e);
					_peerIDs.addItem(ns.farID);
				}
				return accept;
			};
			
			client = streamClient;
			
			connection.addEventListener(StratusPeerEvent.PEER_DISCONNECTED, peerDisconnected);
		}

		public function publishStream(streamName:String):void{
			super.publish(streamName);
			_streamName = streamName;
		} 
		
		private function peerDisconnected(event:StratusPeerEvent):void{
			if(peerIDs.contains(event.peerId)){
				var e:StratusPeerEvent = new StratusPeerEvent(StratusPeerEvent.PEER_DISCONNECTED);
				e.peerStream = event.peerStream;
				e.peerId = event.peerId;
				e.streamName = streamName;
				dispatchEvent(e);
				_peerIDs.removeItemAt(_peerIDs.getItemIndex(event.peerId));
			}
		}
		
		
		private var _streamName:String;
		/**
		 * streamName:String [Read Only]
		 **/
		public function get streamName():String{ return _streamName; }
		

		private var _peerIDs:ArrayCollection = new ArrayCollection();
		/**
		 * peerIDs:ArrayCollection [Read Only]
		 **/
		public function get peerIDs():ArrayCollection{ return _peerIDs;}
	}
}