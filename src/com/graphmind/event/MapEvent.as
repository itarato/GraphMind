package com.graphmind.event {
  
	import flash.events.Event;
	
	public class MapEvent extends Event	{

		public static var MINDMAP_CREATION_COMPLETE:String = 'mindmapCreationComplete';
		
		public function MapEvent(type:String) {
			super(type);
		}

	}
	
}

