package com.graphmind.visualizer {
	
	import flash.errors.IllegalOperationError;
	
	import mx.core.UIComponent;

	public class StructureDrawer extends Drawer {
		
		public function StructureDrawer(target:UIComponent) {
			super(target);
		}

		public function redraw():void {
			throw new IllegalOperationError('This is an abstract function.');
		}
		
	}
	
}