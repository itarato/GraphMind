package com.graphmind.visualizer
{
	import com.graphmind.display.ArrowLink;
	import com.graphmind.display.NodeItem;
	
	import flash.errors.IllegalOperationError;
	
	import mx.core.UIComponent;

	public class ArrowLinkDrawer extends Drawer
	{
		public function ArrowLinkDrawer(target:UIComponent)
		{
			super(target);
		}
		
		public override function redraw():void {
			throw new IllegalOperationError('Don\'t call this.');
		}
		
		public function draw(arrowLink:ArrowLink):void {
			if (!arrowLink.isReady) return;
			if (arrowLink.destinationNode.getParentNode() && (arrowLink.destinationNode.getParentNode() as NodeItem).isCollapsed()) return;
			if (arrowLink.sourceNode.getParentNode() && (arrowLink.sourceNode.getParentNode() as NodeItem).isCollapsed()) return;
			
			_target.graphics.lineStyle(2, 0x0073BA, 0.8);
			_target.graphics.moveTo(
				arrowLink.sourceNode.x + arrowLink.sourceNode.getWidth(), 
				arrowLink.sourceNode.y + (arrowLink.sourceNode.getHeight() >> 1)
			);
			_target.graphics.lineTo(
				arrowLink.destinationNode.x, 
				arrowLink.destinationNode.y + (arrowLink.destinationNode.getHeight() >> 1)
			);
		}
		
	}
}