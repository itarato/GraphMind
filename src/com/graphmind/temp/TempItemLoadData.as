package com.graphmind.temp {
	import com.graphmind.data.NodeItemData;
	import com.graphmind.display.NodeItem;
	import com.graphmind.net.SiteConnection;
	
	
	public class TempItemLoadData {
	
		// Parent node
		public var nodeItem:NodeItem = null;	
		// Node data.
		public var nodeItemData:NodeItemData = null;
		// Success callback on load.
		public var success:Function = null;
		
		public function TempItemLoadData() {}

	}
}