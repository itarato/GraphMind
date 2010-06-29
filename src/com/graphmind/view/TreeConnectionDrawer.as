package com.graphmind.view
{
	import com.graphmind.display.ITreeItem;
	
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	public class TreeConnectionDrawer extends Drawer
	{
		public function TreeConnectionDrawer(target:UIComponent) {
			super(target);
		}
		
		public function draw(nodeFrom:ITreeItem, nodeTo:ITreeItem):void {
			_target.graphics.lineStyle(2, 0x777777);
			var pFrom:Point = new Point(nodeFrom.getUI().x + nodeFrom.getUI().getWidth(), nodeFrom.getUI().y + (NodeUI.HEIGHT >> 1));
			var pTo:Point   = new Point(nodeTo.getUI().x, nodeTo.getUI().y + (NodeUI.HEIGHT >> 1));
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