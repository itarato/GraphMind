package com.graphmind.view {
  
  import flash.events.MouseEvent;
  
  import mx.controls.Image;

  public class FuturesWheelNodeUI extends NodeUI {
    
    [Embed(source="assets/images/arrow_switch.png")]
    public var arrowLinkIconImage:Class;
    public var arrowLinkIcon:Image = new Image();
    
    public function FuturesWheelNodeUI():void {
      super();
    }
    
    public override function initGraphics():void {
      super.initGraphics();
      _displayComp.height = getHeight();
      _displayComp.icon_add.x = 12;
      _displayComp.icon_anchor.x = 32;
      _displayComp.icon_add.y = 62;
      _displayComp.icon_anchor.y = 62;
      _displayComp.icon_has_child.y = 0;
      _backgroundComp.setStyle('cornerRadius', '100');
      _backgroundComp.setStyle('borderThickness', '3');
      _backgroundComp.setStyle('backgroundColor', 0xFFFFFF);
      _displayComp.title_label.height = 60;
      _displayComp.title_label.width = 60;
      _displayComp.title_label.x = 10;
      _displayComp.title_label.y = 10;
      _displayComp.title_label.setStyle('textAlign', 'center');
      
      arrowLinkIcon.x = 52;
      arrowLinkIcon.y = 62;
      arrowLinkIcon.source = arrowLinkIconImage;
      _displayComp.addChild(arrowLinkIcon);
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
      
      _backgroundComp.width = getWidth();
      
      _displayComp.width = getWidth();
      _displayComp.icon_has_child.x = getWidth() - 10;
      _displayComp.insertLeft.x = getWidth();
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