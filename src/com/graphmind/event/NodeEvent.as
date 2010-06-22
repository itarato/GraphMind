package com.graphmind.event {
	
	import com.graphmind.display.NodeController;
	
	import flash.events.Event;
	
	public class NodeEvent extends Event {
		
		public static var UPDATE_DATA:String 	   = 'updateData';
		public static var UPDATE_GRAPHICS:String   = 'updateGraphic';
		public static var MOVED:String 			   = 'moved';
		public static var DELETED:String 		   = 'deleted';
		public static var CREATED:String		   = 'created';
		public static var ATTRIBUTE_CHANGED:String = 'attributeChanged';
		public static var DRAG_AND_DROP_FINISHED:String = 'finished_drag_and_drop';
		
		public var node:NodeController;
		
		public function NodeEvent(type:String, node:NodeController = null) {
			super(type);
			this.node = node; 
		}

	}
	
}