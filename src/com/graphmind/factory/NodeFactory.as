package com.graphmind.factory {
  
	import com.graphmind.data.NodeData;
	import com.graphmind.display.NodeController;
	import com.graphmind.net.SiteConnection;
	
	public class NodeFactory {
	
		public static function createNode(data:Object, type:String, sc:SiteConnection = null, title:String = null):NodeController {
			var nodeData:NodeData = new NodeData(data, type, sc);
			
			// Set extra title
			if (title) {
				nodeData.title = title;
			}
			
			var node:NodeController = new NodeController(nodeData); 
			
			return node;
		}
	
	}
	
}