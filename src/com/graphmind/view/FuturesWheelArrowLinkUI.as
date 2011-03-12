package com.graphmind.view
{
  import com.graphmind.display.ITreeNode;
  import com.graphmind.display.TreeArrowLink;
  
  import mx.core.UIComponent;

  public class FuturesWheelArrowLinkUI extends TreeArrowLinkDrawer {
    private static var PI_IN_DEG:Number = 180.0 / Math.PI;
    
    public function FuturesWheelArrowLinkUI(target:UIComponent) {
      super(target);
    }
    
    public override function draw(arrowLink:TreeArrowLink):void {
      if (!arrowLink.isReady) return;
      if (arrowLink.destinationNode.getParentNode() && arrowLink.destinationNode.getParentNode().isCollapsed()) return;
      if (arrowLink.sourceNode.getParentNode() && arrowLink.sourceNode.getParentNode().isCollapsed()) return;
      
      var destX:Number    = arrowLink.destinationNode.getUI().x;
      var destY:Number    = arrowLink.destinationNode.getUI().y;
      var sourceX:Number  = arrowLink.sourceNode.getUI().x;
      var sourceY:Number  = arrowLink.sourceNode.getUI().y;
      arrowLink.width = 6;
      arrowLink.height = Math.sqrt(Math.pow(destX - sourceX, 2) + Math.pow(destY - sourceY, 2));
      arrowLink.setStyle('borderStyle', 'solid');
      arrowLink.setStyle('borderColor', 0xFFFFFF);
      arrowLink.setStyle('borderThickness', 2);
      arrowLink.setStyle('backgroundColor', FuturesWheelDrawer.getLevelColor(levelNum(arrowLink.sourceNode) + 1));
      
      _target.addChild(arrowLink);
      arrowLink.x = sourceX + (arrowLink.sourceNode.getUI().getWidth() >> 1);
      arrowLink.y = sourceY + (arrowLink.sourceNode.getUI().getHeight() >> 1);
      arrowLink.rotation = Math.atan2(destX - sourceX, destY - sourceY) * -PI_IN_DEG;
    }
    
    private function levelNum(node:ITreeNode):uint {
      if (!node.getParentNode()) {
        return 0;
      } else {
        return levelNum(node.getParentNode()) + 1;
      }
    }
    
  }
}