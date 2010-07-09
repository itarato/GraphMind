package com.graphmind.view
{
  import com.graphmind.display.ITreeNode;
  import com.graphmind.display.TreeArrowLink;
  
  import mx.core.UIComponent;

  public class FuturesWheelArrowLinkUI extends TreeArrowLinkUI
  {
    public function FuturesWheelArrowLinkUI(target:UIComponent) {
      super(target);
    }
    
    public override function draw(arrowLink:TreeArrowLink):void {
      if (!arrowLink.isReady) return;
      if (arrowLink.destinationNode.getParentNode() && arrowLink.destinationNode.getParentNode().isCollapsed()) return;
      if (arrowLink.sourceNode.getParentNode() && arrowLink.sourceNode.getParentNode().isCollapsed()) return;
      
      arrowLink.width = 6;
      arrowLink.height = Math.sqrt(
        Math.pow(arrowLink.destinationNode.getUI().x - arrowLink.sourceNode.getUI().x, 2) + 
        Math.pow(arrowLink.destinationNode.getUI().y - arrowLink.sourceNode.getUI().y, 2)
      );
      arrowLink.setStyle('borderStyle', 'solid');
      arrowLink.setStyle('borderColor', 0xFFFFFF);
      arrowLink.setStyle('borderThickness', 2);
      arrowLink.setStyle('backgroundColor', FuturesWheelDrawer.getLevelColor(levelNum(arrowLink.sourceNode) + 1));
      _target.addChild(arrowLink);
      arrowLink.x = arrowLink.sourceNode.getUI().x + (arrowLink.sourceNode.getUI().getWidth() >> 1);
      arrowLink.y = arrowLink.sourceNode.getUI().y + (arrowLink.sourceNode.getUI().getHeight() >> 1);
      arrowLink.rotation = Math.atan2(
        arrowLink.destinationNode.getUI().x - arrowLink.sourceNode.getUI().x,
        arrowLink.destinationNode.getUI().y - arrowLink.sourceNode.getUI().y
      ) * (-180.0 / Math.PI);
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