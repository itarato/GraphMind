package com.graphmind.visualizer
{
	import com.graphmind.display.NodeItem;
	
	import flash.errors.IllegalOperationError;
	import flash.geom.Point;
	
	import mx.containers.Canvas;
	
	public class ConnectionDrawer extends Drawer
	{
		public function ConnectionDrawer(target:Canvas) {
			super(target);
		}
		
		public override function redraw():void {
			throw new IllegalOperationError('Connections shouldn\'t created this way.');
		}
		
		public function draw(nodeFrom:NodeItem, nodeTo:NodeItem):void {
			_target.graphics.lineStyle(2, 0x777777);
			var pFrom:Point = new Point(nodeFrom.x + nodeFrom.getWidth(), nodeFrom.y + (NodeItem.HEIGHT >> 1));
			var pTo:Point   = new Point(nodeTo.x, nodeTo.y + (NodeItem.HEIGHT >> 1));
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