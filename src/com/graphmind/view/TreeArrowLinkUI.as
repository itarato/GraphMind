package com.graphmind.view
{
	import com.graphmind.display.TreeArrowLink;
	import com.graphmind.display.NodeController;
	
	import flash.errors.IllegalOperationError;
	
	import mx.core.UIComponent;

	public class TreeArrowLinkUI extends Drawer
	{
		public function TreeArrowLinkUI(target:UIComponent) {
			super(target);
		}
		
		public function draw(arrowLink:TreeArrowLink):void {
			if (!arrowLink.isReady) return;
			if (arrowLink.destinationNode.getParentNode() && arrowLink.destinationNode.getParentNode().isCollapsed()) return;
			if (arrowLink.sourceNode.getParentNode() && arrowLink.sourceNode.getParentNode().isCollapsed()) return;
			
			_target.graphics.lineStyle(2, 0x0073BA, 0.8);
			_target.graphics.moveTo(
				arrowLink.sourceNode.getUI().x + arrowLink.sourceNode.getUI().getWidth(), 
				arrowLink.sourceNode.getUI().y + (arrowLink.sourceNode.getUI().getHeight() >> 1)
			);
			_target.graphics.lineTo(
				arrowLink.destinationNode.getUI().x, 
				arrowLink.destinationNode.getUI().y + (arrowLink.destinationNode.getUI().getHeight() >> 1)
			);
		}
		
	}
}