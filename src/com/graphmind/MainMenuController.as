package com.graphmind {

  import flash.events.MouseEvent;
  
  import mx.containers.HBox;
  import mx.controls.LinkButton;
  
  public class MainMenuController {
    
    private static var container:HBox; 

    
    /**
    * Initialize the menu bar and its data source.
    */
    public static function init(hbox:HBox):void {
      MainMenuController.container = hbox;
    }
    
    
    /**
    * Create and add a menu item to the menu bar.
    */
    public static function createIconMenuItem(imgSource:Class, tooltip:String, callback:Function):void {
      var link:LinkButton = new LinkButton();
      link.label = tooltip;
      link.setStyle('icon', imgSource);
      container.addChild(link);
      link.addEventListener(MouseEvent.CLICK, callback);
    }
    
  }
  
}
