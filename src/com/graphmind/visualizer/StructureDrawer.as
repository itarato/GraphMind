package com.graphmind.visualizer {
	
	import com.graphmind.display.NodeItem;
	
	import flash.errors.IllegalOperationError;
	
	import mx.core.UIComponent;

	public class StructureDrawer extends Drawer {
		
		private var _nodeDrawer:NodeDrawer;
		
		public function StructureDrawer(target:UIComponent, nodeDrawer:NodeDrawer) {
			super(target);
			_nodeDrawer = nodeDrawer;
		}

		public function redraw():void {
			throw new IllegalOperationError('This is an abstract function.');
		}
		
		public function addNodeToStage(node:NodeItem):void {
			_target.addChild(node);
		}
	}
	
}