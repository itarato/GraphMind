package com.graphmind.event {
  
	import flash.events.Event;
	
	public class StageEvent extends Event	{

		public static var MINDMAP_CREATION_COMPLETE:String = 'mindmapCreationComplete';
		
		public function StageEvent(type:String) {
			super(type);
		}

	}
	
}