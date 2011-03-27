package com.graphmind.view {
  
  import flash.events.MouseEvent;
  
  import mx.controls.Image;

  public class FuturesWheelNodeView extends NodeView {
    
    [Embed(source="assets/images/arrow_switch.png")]
    public var arrowLinkIconImage:Class;
    public var arrowLinkIcon:Image = new Image();
    
    public function FuturesWheelNodeView():void {
      super();
    }
    
    public override function initGraphics():void {
      super.initGraphics();
      nodeComponentView.height = getHeight();
      nodeComponentView.icon_add.x = 12;
      nodeComponentView.icon_anchor.x = 32;
      nodeComponentView.icon_add.y = 62;
      nodeComponentView.icon_anchor.y = 62;
      nodeComponentView.icon_has_child.y = 0;
      backgroundView.setStyle('cornerRadius', '100');
      backgroundView.setStyle('borderThickness', '3');
      backgroundView.setStyle('backgroundColor', 0xFFFFFF);
      nodeComponentView.title_label.height = 60;
      nodeComponentView.title_label.width = 60;
      nodeComponentView.title_label.x = 10;
      nodeComponentView.title_label.y = 10;
      nodeComponentView.title_label.setStyle('textAlign', 'center');
      
      arrowLinkIcon.x = 52;
      arrowLinkIcon.y = 62;
      arrowLinkIcon.source = arrowLinkIconImage;
      nodeComponentView.addChild(arrowLinkIcon);
      arrowLinkIcon.visible = false
    }
    
    public override function getHeight():uint {
      return 80;
    }
    
    public override function refreshGraphics():void {
      if (!isGraphicsUpdated) return;
      
//      for (var idx:* in icons) {
//        Image(icons[idx]).y = 20;
//        Image(icons[idx]).x = 40 + ICON_WIDTH * idx;
//      }
      
      backgroundView.width = getWidth();
      
      nodeComponentView.width = getWidth();
      nodeComponentView.icon_has_child.x = getWidth() - 10;
      nodeComponentView.insertLeft.x = getWidth();
      //_displayComp.title_label.width = getWidth();
      
      isGraphicsUpdated = false;
    }
    
    public override function getWidth():uint {
      //return ((_displayComp.title_label.measuredWidth > (40 + _getIconsExtraWidth())) ? _displayComp.title_label.measuredWidth : (40 + _getIconsExtraWidth())) + 4;
      return getHeight(); 
    }
    
//    private function getLevelNum():uint {
//      var level:uint = 0;
//    }

    public override function addIcon(icon:Image):void {
    }
    
  }
  
}
