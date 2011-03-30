package com.graphmind.display {
  
	import com.graphmind.display.TreeArrowLink;
	import mx.containers.Canvas;
	import mx.core.UIComponent;

	public class TreeArrowLinkDrawer extends Drawer {

    /**
    * Constructor.
    */
		public function TreeArrowLinkDrawer(target:UIComponent) {
			super(target);
		}
		
		
		/**
		 * Draw the arrow link.
		 */
		public function draw(arrowLink:TreeArrowLink):void {
			if (!arrowLink.isReady) return;
			if (arrowLink.destinationNode.getParentNode() && arrowLink.destinationNode.getParentNode().isCollapsed()) return;
			if (arrowLink.sourceNode.getParentNode() && arrowLink.sourceNode.getParentNode().isCollapsed()) return;
			
			_target.graphics.lineStyle(3, 0x446688, 0.8);
			_target.graphics.moveTo(
				arrowLink.sourceNode.view.x + (arrowLink.sourceNode.view.width >> 1), 
				arrowLink.sourceNode.view.y + (arrowLink.sourceNode.view.height >> 1)
			);
			_target.graphics.lineTo(
				arrowLink.destinationNode.view.x + (arrowLink.destinationNode.view.width >> 1), 
				arrowLink.destinationNode.view.y + (arrowLink.destinationNode.view.height >> 1)
			);
		}
		
	}
	
}
