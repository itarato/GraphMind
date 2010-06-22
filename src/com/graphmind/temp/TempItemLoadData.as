package com.graphmind.temp {
	import com.graphmind.data.NodeData;
	import com.graphmind.display.TreeNodeController;
	
	
	public class TempItemLoadData {
	
		// Parent node
		public var nodeItem:TreeNodeController = null;	
		// Node data.
		public var nodeItemData:NodeData = null;
		// Success callback on load.
		public var success:Function = null;
		
		public function TempItemLoadData() {}

	}
}