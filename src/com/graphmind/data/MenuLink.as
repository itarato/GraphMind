/**
 * Represents a menu item in the main menu bar.
 */
package com.graphmind.data {
  
  public class MenuLink {
  
    public var icon:Class;
    
    public var title:String;
    
    public var callback:Function;
    
    public function MenuLink(icon:Class, title:String, callback:Function) {
      this.icon = icon;
      this.title = title;
      this.callback = callback;
    }

  }
  
}
