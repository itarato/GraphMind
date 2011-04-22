package com.graphmind {
  
  import mx.containers.Canvas;
  import mx.containers.VBox;
  import mx.controls.Image;
  import mx.core.BitmapAsset;
  import mx.core.ScrollPolicy;
  import mx.core.UIComponent;
  
  public class DropDownMenuPanelConroller extends Canvas {
    
    public var menuIcon:Image;

    public var panel:VBox = new VBox();
    
    
    public function DropDownMenuPanelConroller(iconSource:BitmapAsset, tooltip:String) {
      super();

      menuIcon = new Image();
      menuIcon.source = iconSource;
      menuIcon.toolTip = tooltip;
      
      addChild(panel);
      panel.setStyle('backgroundColor', '0xDDDDDD');
      panel.setStyle('paddingTop', '12');
      panel.setStyle('paddingBottom', '12');
      panel.setStyle('paddingRight', '6');
      panel.setStyle('paddingLeft', '6');
      panel.horizontalScrollPolicy = ScrollPolicy.OFF;
      panel.verticalScrollPolicy = ScrollPolicy.OFF;
    }
    
    
    public function addFormItem(item:UIComponent):void {
      panel.addChild(item);
    }
    
  }
  
}
