package com.graphmind {

  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.utils.clearInterval;
  import flash.utils.clearTimeout;
  import flash.utils.setTimeout;
  
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
      menu.panel.y = 24;
      menu.panel.visible = false;
      menu.menuIcon.addEventListener(MouseEvent.CLICK, function(e:Event):void{
        menu.panel.visible = !menu.panel.visible;
        menu.panel.x = menu.menuIcon.x - 12;
        
        if (menu.panel.visible) {
          clearTimeout(menu.closeTimeout);
          menu.closeTimeout = setTimeout(function():void{menu.panel.visible = false;}, 1000);
        }
      });
      menu.panel.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void{
        clearInterval(menu.closeTimeout);
      });
      menu.panel.addEventListener(MouseEvent.ROLL_OUT, function(e:MouseEvent):void{
        menu.closeTimeout = setTimeout(function():void{
          menu.panel.visible = false;
        }, 1000);
      });
      GraphMind.i.mindmapMapPanel.addChild(menu.panel);
    }
    
    
  }
  
}
