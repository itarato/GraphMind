package com.graphmind {

	import com.graphmind.view.StructureDrawer;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class AbstractStageManager extends EventDispatcher {
		
		public static var EVENT_MINDMAP_UPDATED:String = 'mindmapUpdated';
		
		/**
		 * Drawer of the application (can be TreeDrawer, GraphDrawer, etc.)
		 */
		public var structureDrawer:StructureDrawer;
		
		public function AbstractStageManager() {
			addEventListener(EVENT_MINDMAP_UPDATED, onMindmapUpdated);
		}
		
		public function init(structureDrawer:StructureDrawer):void {
			this.structureDrawer = structureDrawer;
		}
		
		public function onMindmapUpdated(event:Event):void {
			trace('AbstractStageManager.onMindmapUpdated');
			structureDrawer.refreshGraphics();
		}

	}
	
}