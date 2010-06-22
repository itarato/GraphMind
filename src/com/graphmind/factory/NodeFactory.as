package com.graphmind.factory
{
	import com.graphmind.data.NodeData;
	import com.graphmind.display.TreeNodeController;
	import com.graphmind.net.SiteConnection;
	
	public class NodeFactory
	{
	
		public static function createNode(data:Object, type:String, sc:SiteConnection = null, title:String = null):TreeNodeController {
			var nid:NodeData = new NodeData(
				data,
				type,
				sc
			);
			
			// Set extra title
			if (title) {
				nid.title = title;
			}
			
			var ni:TreeNodeController = new TreeNodeController(nid);
			return ni;
		}
	
	}
}