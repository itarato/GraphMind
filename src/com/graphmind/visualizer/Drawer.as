package com.graphmind.visualizer {
	
	import flash.events.EventDispatcher;
	
	import mx.core.UIComponent;
	
	public class Drawer extends EventDispatcher	{
		
		protected var _target:UIComponent;
		protected var _isLocked:Boolean = false;
		
		public function Drawer(target:UIComponent) {
			_target = target;
		}
		
		public function clearAll():void {
			_target.graphics.clear();
		}
		
		public function lock():void {
			_isLocked = true;
		}
		
		public function unlock():void {
			_isLocked = false;
		}

	}
	
}