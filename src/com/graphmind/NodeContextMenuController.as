package com.graphmind {
  
  import com.graphmind.data.NodeContextMenu;
  import com.graphmind.data.NodeContextMenuSection;
  
  import flash.events.ContextMenuEvent;
  import flash.ui.ContextMenuItem;
  
  /**
  * Manager of a node's context menus.
  * It collects sections and items and outputs the context menu link list.
  */
  public class NodeContextMenuController {
    
    /**
    * Add new menu item.
    */
    public function addItem(name:String, callback:Function, weight:Number = 0, sectionName:String = 'default'):void {
      var item:NodeContextMenu = new NodeContextMenu(name, callback, weight);
      var section:NodeContextMenuSection = NodeContextMenuSection.getSection(sectionName);
      section.addContextMenu(item);
    }

    
    /**
    * Set weight of a section.
    */
    public function setSectionWeight(name:String, weight:Number):void {
      var section:NodeContextMenuSection = NodeContextMenuSection.getSection(name);
      section.weight = weight;
    }
    
    
    /**
    * Get the final item list - used by ContextMenu.customMenu.
    */
    public function getContextMenus():Array {
      var out:Array = [];
      var isFirstFlag:Boolean = false;
      
      NodeContextMenuSection.sortSection();
      
      for each (var section:NodeContextMenuSection in NodeContextMenuSection.sections) {
        isFirstFlag = true;
        for each (var item:NodeContextMenu in section.contextMenus) {
          var contextMenu:ContextMenuItem = new ContextMenuItem(item.name, isFirstFlag);
          contextMenu.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, item.callback);
          isFirstFlag = false;
          out.push(contextMenu);
        }
      }
      
      return out;
    }

  }
  
}
