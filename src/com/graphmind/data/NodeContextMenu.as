package com.graphmind.data {
  
  /**
  * Context menu pitem re-object.
  */
  public class NodeContextMenu {

    // Weight for ordering
    public var weight:Number = 0;
    
    // Name of the item
    public var name:String;
    
    // Call to action
    public var callback:Function;
    
    
    /**
    * Constructor.
    */
    public function NodeContextMenu(name:String, callback:Function, weight:Number = 0) {
      this.weight   = weight;
      this.name     = name;
      this.callback = callback;
    }

  }
  
}
