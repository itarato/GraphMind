package com.graphmind.event
{
	import flash.events.Event;
	
	public class StageEvent extends Event
	{
		public static var MINDMAP_UPDATED:String = 'mindmapUpdated';
		
		public var height:Number;
		
		public function StageEvent(type:String, height:Number = 0)
		{
			super(type);
			this.height = height;
		}

	}
}