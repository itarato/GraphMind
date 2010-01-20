package com.graphmind.net
{
	import com.graphmind.util.Log;
	import com.graphmind.util.OSD;
	
	import mx.rpc.AbstractOperation;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	public class RPCServiceHelper
	{
		public function RPCServiceHelper() {}
		
		/**
		 * Build an RPC connection
		 * 
		 * @param String ns   - Function namespace, ex: system
		 * @param String func - Function, ex: connect
		 * @param String dest - Destination service, ex: amfphp
		 * @param String url  - URL for the service, ex: http://localhost/drupal_site/services/amfphp
		 * @param Function success - Success callback function
		 * @param Function error   - Error callback function
		 * @return AbstractOperation
		 */
		public static function createRPC(ns:String, func:String, dest:String, url:String, success:Function, error:Function = null):AbstractOperation {
			var ro:RemoteObject = new RemoteObject(dest);
			ro.showBusyCursor = true;
			ro.endpoint = url;
			ro.source = ns;
			ro.addEventListener(FaultEvent.FAULT, (error == null) ? onErrorRPCConnection : error);
			ro.addEventListener(ResultEvent.RESULT, success);
			return ro.getOperation(func);
		}
		
		private static function onErrorRPCConnection(error:FaultEvent):void {
			Log.warning('Error during RCP connection: ' + error);
			OSD.show('Error during RCP connection: ' + error, OSD.ERROR);
		}
	}
}