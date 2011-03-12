package com.graphmind.temp
{
	import com.graphmind.data.ViewsServicesParamsVO;
	import com.graphmind.display.NodeViewController;
	
	public class TempViewLoadData
	{
		// Parent node item (GraphMind node).
		public var nodeItem:NodeViewController = null;
		// Views argument object.
		public var viewsData:ViewsServicesParamsVO = null;
		// Callback on success
		public var success:Function = null;
		
		public function TempViewLoadData() {}

	}
}
