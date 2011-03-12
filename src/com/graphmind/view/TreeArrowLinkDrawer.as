package com.graphmind.view {
  
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
				arrowLink.sourceNode.getUI().x + (arrowLink.sourceNode.getUI().getWidth() >> 1), 
				arrowLink.sourceNode.getUI().y + (arrowLink.sourceNode.getUI().getHeight() >> 1)
			);
			_target.graphics.lineTo(
				arrowLink.destinationNode.getUI().x + (arrowLink.destinationNode.getUI().getWidth() >> 1), 
				arrowLink.destinationNode.getUI().y + (arrowLink.destinationNode.getUI().getHeight() >> 1)
			);
		}
		
	}
	
}
