package com.graphmind.view {

	import com.graphmind.display.IDisplayItem;
	import com.graphmind.display.IDrawable;
	import com.graphmind.display.NodeController;
	
	import mx.core.UIComponent;

	
	public class NodeUI extends UIComponent implements IDisplayItem, IDrawable {
		
		protected var _sourceNodeController:NodeController;
		
		public function NodeUI(nodeController:NodeController) {
			super();
			_sourceNodeController = nodeController;
		}
		
		
		/**
		 * UI initialization
		 *  - adding UI objects
		 *  - initial settings
		 */
		public function initGraphics():void {
		}
		
		/**
		 * Refresh graphics
		 *  - recalculate boundaries
		 *  - position fixes
		 */
		public function refreshGraphics():void {
		}
		
		public function getHeight():uint {
			return 0;
		}
		
		public function getWidth():uint {
			return 0;
		}
		
		public function getUIComponent():UIComponent {
			return this;
		}

	}
	
}