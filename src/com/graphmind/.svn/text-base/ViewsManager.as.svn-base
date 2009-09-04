package com.graphmind {
	
	import com.graphmind.data.ViewsCollection;
	import com.graphmind.net.SiteConnection;
	
	import mx.rpc.events.ResultEvent;
	
	public class ViewsManager
	{
		private static var _instance:ViewsManager = null;
		
		public function ViewsManager() {
		}
		
		public static function getInstance():ViewsManager {
			if (_instance == null) {
				_instance = new ViewsManager();
			}
			
			return _instance;
		}
		
		public function receiveViewsData(result:ResultEvent, sc:SiteConnection):void {
			for each (var data:Object in result.result) {
				var viewsTable:ViewsCollection = new ViewsCollection(data, sc);
			}
		}
		
	}
}