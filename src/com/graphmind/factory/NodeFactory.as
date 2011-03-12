package com.graphmind.factory {
  
	import com.graphmind.data.NodeData;
	import com.graphmind.display.NodeViewController;
	import com.kitten.network.Connection;
	
	public class NodeFactory {
	
	   /**
	   * Create and preset a node.
	   */
		public static function createNode(data:Object, type:String, conn:Connection = null, title:String = null):NodeViewController {
			var nodeData:NodeData = new NodeData(data, type, conn);
			
			// Set extra title
			if (title) {
				nodeData.title = title;
			}
			
			var node:NodeViewController = new NodeViewController(nodeData);
			
			return node;
		}
	
	}
	
}
