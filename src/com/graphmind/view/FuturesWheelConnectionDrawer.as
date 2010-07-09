package com.graphmind.view {
  
  import com.graphmind.display.ITreeItem;
  
  import mx.core.UIComponent;

  public class FuturesWheelConnectionDrawer extends TreeConnectionDrawer {
    
    public function FuturesWheelConnectionDrawer(target:UIComponent):void {
      super(target);
    }
    
    public override function draw(nodeFrom:ITreeItem, nodeTo:ITreeItem):void {
    }
    
    public function drawWithColor(nodeFrom:ITreeItem, nodeTo:ITreeItem, color:uint = 0x777777):void {
      _target.graphics.lineStyle(2, color);
      _target.graphics.moveTo(
        nodeFrom.getUI().x + (nodeFrom.getUI().getWidth() >> 1), 
        nodeFrom.getUI().y + (nodeFrom.getUI().getHeight() >> 1)
      );
      _target.graphics.lineTo(
        nodeTo.getUI().x + (nodeTo.getUI().getWidth() >> 1),
        nodeTo.getUI().y + (nodeTo.getUI().getHeight() >> 1)
      );
    }
    
  }
  
}