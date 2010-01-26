package com.graphmind.visualizer {
	
	import flash.errors.IllegalOperationError;
	
	import mx.core.UIComponent;
	
	public class Drawer {
		
		protected var _target:UIComponent;
		
		public function Drawer(target:UIComponent) {
			_target = target;
		}

		public function redraw():void {
			throw new IllegalOperationError('This is an abstract function.');
		}
		
		public function clearAll():void {
			_target.graphics.clear();
		}
		
	}
	
}