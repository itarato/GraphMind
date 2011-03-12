package com.graphmind.view {
	
	import flash.events.EventDispatcher;
	
	import mx.core.UIComponent;
	
	public class Drawer extends EventDispatcher	{
		
		/**
		 * UI element where actual drawing happens.
		 */
		protected var _target:UIComponent;
		
	   /**
	   * Indicate if the UI is locked to use.
	   * Usually locked during drawing actions.
	   */
		protected var _isLocked:Boolean = false;
		
		
		/**
		 * Constructor.
		 */
		public function Drawer(target:UIComponent) {
			_target = target;
		}
		
		
		/**
		 * Clear all graphics on target.
		 */
		public function clear():void {
			_target.graphics.clear();
		}


    /**
    * Lock target.
    */		
		public function lock():void {
			_isLocked = true;
		}
		
		
		/**
		 * Unlock target.
		 */
		public function unlock():void {
			_isLocked = false;
		}
		
		
		/**
		 * Get lock status.
		 */
		public function get isLocked():Boolean {
		  return _isLocked;
		}

	}
	
}
