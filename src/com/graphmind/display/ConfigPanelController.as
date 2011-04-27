/**
 * Handle config panels.
 */
package com.graphmind.display {
  
  import com.graphmind.event.EventCenter;
  import com.graphmind.event.EventCenterEvent;
  import com.graphmind.view.ConfigPanelView;
  
  import flash.events.MouseEvent;
  
  import mx.controls.HRule;
  import mx.core.UIComponent;
  import mx.events.FlexEvent;
  
  
  public class ConfigPanelController {
    
    /**
    * Panel view.
    */
    public var view:ConfigPanelView = new ConfigPanelView();

    
    /**
    * Constructor.
    */
    public function ConfigPanelController(title:String) {
      view.label = title;
      view.addEventListener(FlexEvent.CREATION_COMPLETE, function(e:FlexEvent):void {
        addExitItem(view.exit_icon);
      });
      view.visible = false;
      GraphMind.i.addChild(view);
    }
    
    
    /**
    * Add config item.
    */
    public function addItem(item:UIComponent):void {
      view.items.addChild(item);
    }
    
    
    /**
    * Add items that can indicate closing the panel after submission.
    */
    public function addExitItem(item:UIComponent):void {
      item.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{
        hide();
      });
    }
    
    
    /**
    * Show panel.
    */
    public function show():void {
      view.x = (view.parent.width - 400) * 0.5;
      view.y = 64;
      view.visible = true;
      EventCenter.notify(EventCenterEvent.MAP_LOCK);
    }
    
    
    /**
    * Hide panel.
    */
    public function hide():void {
      view.visible = false;
      EventCenter.notify(EventCenterEvent.MAP_UNLOCK);
    }

  }
  
}
