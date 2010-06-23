package com.graphmind.event {
	
	import com.graphmind.display.NodeController;
	
	import flash.events.Event;
	
	public class NodeEvent extends Event {
		
		public static var UPDATE_DATA:String 	          = 'node_update_data';
		public static var UPDATE_GRAPHICS:String        = 'node_update_graphic';
		public static var MOVED:String 			            = 'node_moved';
		public static var DELETED:String 		            = 'node_deleted';
		public static var CREATED:String		            = 'node_created';
		public static var ATTRIBUTE_CHANGED:String      = 'node_attribute_changed';
		public static var DRAG_AND_DROP_FINISHED:String = 'node_finished_drag_and_drop';
		
		public var node:NodeController;
		
		public function NodeEvent(type:String, node:NodeController = null) {
			super(type);
			this.node = node; 
		}

	}
	
}