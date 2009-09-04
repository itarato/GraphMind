package com.graphmind.util {
	import com.graphmind.display.NodeItem;
	
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	
	public class ConnectionCreator {
		
		public static function drawConnection(target:UIComponent, fromNode:NodeItem,  toNode:NodeItem):void {
			target.graphics.lineStyle(2, 0x333333);
			var pFrom:Point = new Point(fromNode.x + NodeItem.WIDTH, fromNode.y + NodeItem.HEIGHT / 2);
			var pTo:Point   = new Point(toNode.x, toNode.y + NodeItem.HEIGHT / 2);
			target.graphics.moveTo((pFrom.x + pTo.x) / 2, (pFrom.y + pTo.y) / 2);
			//target.graphics.lineTo();
			target.graphics.curveTo(
				pFrom.x + (pTo.x - pFrom.x) / 4,
				pFrom.y,
				pFrom.x,
				pFrom.y
			);
			target.graphics.moveTo((pFrom.x + pTo.x) / 2, (pFrom.y + pTo.y) / 2);
			target.graphics.curveTo(
				pTo.x - (pTo.x - pFrom.x) / 4,
				pTo.y,
				pTo.x,
				pTo.y
			);
		}
		
	}
	
}