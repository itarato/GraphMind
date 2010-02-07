package com.graphmind.event
{
	import flash.events.Event;
	
	public class StageEvent extends Event
	{
		public static var MINDMAP_UPDATED:String = 'mindmapUpdated';
		
		public function StageEvent(type:String)
		{
			super(type);
		}

	}
}