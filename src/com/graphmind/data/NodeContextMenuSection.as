package com.graphmind.data {
  
  import mx.collections.ArrayCollection;
  
  /**
  * Section class for node context menus.
  * Section is a set of context menu links divided be separator lines in the menu.
  */
  public class NodeContextMenuSection {
    
    // Unique name of the section
    private var name:String;
    
    // Weight that sets the position
    public var weight:Number = 0; 
    
    // List of context menus
    public var contextMenus:Array = []; 
    
    // Static dicitionary to lookup for sections by their name
    public static var sectionsNameIndex:Object = {};
    
    // List of all sections
    public static var sections:Array = [];
    
    
    /**
    * Constructor.
    * Don't call it directlty - use NodeContextMenuSection.getSection(NAME) instead.
    */
    [Deprecated]
    public function NodeContextMenuSection(name:String) {
      this.name = name;
      sections.push(this);
    }
    
    
    /**
    * Sections instance getter.
    */
    public static function getSection(name:String):NodeContextMenuSection {
      if (!sectionsNameIndex.hasOwnProperty(name)) {
        sectionsNameIndex[name] = new NodeContextMenuSection(name);
      }
      return sectionsNameIndex[name];
    }
    
    
    /**
    * Add new context menu item.
    */
    public function addContextMenu(item:NodeContextMenu):void {
      var idxToInsert:uint = 0;
      while (idxToInsert < contextMenus.length && (contextMenus[idxToInsert] as NodeContextMenu).weight < item.weight) {
        idxToInsert++;
      }
      
      for (var i:uint = contextMenus.length; i > idxToInsert; i--) {
        contextMenus[i] = contextMenus[i - 1];
      }
      
      contextMenus[idxToInsert] = item;
    }
    
    
    /**
    * Sort sections by their weight.
    */
    public static function sortSection():void {
      sections.sort(function(a:NodeContextMenuSection, b:NodeContextMenuSection):int{
        if (a.weight < b.weight) return -1;
        if (a.weight > b.weight) return 1;
        return 0;
      });
    }

  }
  
}
