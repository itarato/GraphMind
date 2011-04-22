package com.graphmind {

  import flash.events.Event;
  import flash.events.MouseEvent;
  
  import mx.containers.HBox;
  import mx.controls.Image;
  import mx.core.BitmapAsset;
  
  public class MainMenuController {
    
    public static var view:HBox;
    
    
    public static function createIconMenuItem(imgSource:BitmapAsset, tooltip:String, callback:Function):void {
      var icon:Image = new Image();
      icon.source = imgSource;
      view.addChild(icon);
      icon.addEventListener(MouseEvent.CLICK, callback);
      icon.toolTip = tooltip;
    }
    
    
    public static function addDropDownMenu(menu:DropDownMenuPanelConroller):void {
      view.addChild(menu.menuIcon);
      menu.panel.y = 29;
      menu.panel.visible = false;
      menu.menuIcon.addEventListener(MouseEvent.CLICK, function(e:Event):void{
        menu.panel.visible = !menu.panel.visible;
        menu.panel.x = menu.menuIcon.x - 12;
      });
      GraphMind.i.mindmapMapPanel.addChild(menu.panel);
    }
    
    
  }
  
}
