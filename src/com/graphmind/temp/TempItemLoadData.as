package com.graphmind.temp {
	import com.graphmind.data.NodeData;
	import com.graphmind.display.NodeViewController;
	
	
	public class TempItemLoadData {
	
		// Parent node
		public var nodeItem:NodeViewController = null;	
		// Node data.
		public var nodeItemData:NodeData = null;
		// Success callback on load.
		public var success:Function = null;
		
		public function TempItemLoadData() {}

	}
}
