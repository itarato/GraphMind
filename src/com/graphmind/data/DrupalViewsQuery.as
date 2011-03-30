package com.graphmind.data {
  
	import com.graphmind.net.SiteConnection;

	
	public class DrupalViewsQuery {
	  
		public var views:DrupalViews;
		
		public var name:String;
		
		public var args:String 	 = '';
		
		public var offset:int 	 = 0;
		
		public var limit:int 	 = 0;
		
		public var fields:String = '';

		
		public function DrupalViewsQuery()	{}

	}
	
}
