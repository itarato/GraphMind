package com.graphmind.display {
  
	import com.graphmind.view.NodeView;
	
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	public class TreeConnectionDrawer extends Drawer {
	  
	  /**
	  * Constructor.
	  */
		public function TreeConnectionDrawer(target:UIComponent) {
			super(target);
		}
		
		
		/**
		 * Draw the connection.
		 */
		public function draw(nodeFrom:NodeViewController, nodeTo:NodeViewController):void {
			_target.graphics.lineStyle(2, 0x777777);
			var pFrom:Point = new Point(nodeFrom.view.x + nodeFrom.view.backgroundView.width, nodeFrom.view.y + (NodeView.HEIGHT >> 1));
			var pTo:Point   = new Point(nodeTo.view.x, nodeTo.view.y + (NodeView.HEIGHT >> 1));
			_target.graphics.moveTo((pFrom.x + pTo.x) >> 1, (pFrom.y + pTo.y) >> 1);
			_target.graphics.curveTo(
				pFrom.x + ((pTo.x - pFrom.x) >> 2),
				pFrom.y,
				pFrom.x,
				pFrom.y
			);
			_target.graphics.moveTo((pFrom.x + pTo.x) >> 1, (pFrom.y + pTo.y) >> 1);
			_target.graphics.curveTo(
				pTo.x - ((pTo.x - pFrom.x) >> 2),
				pTo.y,
				pTo.x,
				pTo.y
			);
		}

	}
	
}
