package com.graphmind.factory
{
	import com.graphmind.data.NodeItemData;
	import com.graphmind.display.NodeItem;
	import com.graphmind.net.SiteConnection;
	
	public class NodeFactory
	{
	
		public static function createNode(data:Object, type:String, sc:SiteConnection = null, title:String = null):NodeItem {
			var nid:NodeItemData = new NodeItemData(
				data,
				type,
				sc
			);
			
			// Set extra title
			if (title) {
				nid.title = title;
			}
			
			var ni:NodeItem = new NodeItem(nid);
			return ni;
		}
	
	}
}