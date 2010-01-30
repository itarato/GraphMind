package com.graphmind.visualizer {
	
	import flash.events.EventDispatcher;
	
	import mx.core.UIComponent;
	
	public class Drawer extends EventDispatcher	{
		
		protected var _target:UIComponent;
		
		public function Drawer(target:UIComponent) {
			_target = target;
		}
		
		public function clearAll():void {
			_target.graphics.clear();
		}

	}
	
}