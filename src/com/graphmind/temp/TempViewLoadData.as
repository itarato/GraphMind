package com.graphmind.temp
{
	import com.graphmind.data.ViewsList;
	import com.graphmind.display.NodeItem;
	
	public class TempViewLoadData
	{
		// Parent node item (GraphMind node).
		public var nodeItem:NodeItem = null;
		// Views argument object.
		public var viewsData:ViewsList = null;
		// Callback on success
		public var success:Function = null;
		
		public function TempViewLoadData() {}

	}
}