package com.graphmind {
  
  import com.graphmind.event.EventCenter;
  import com.graphmind.event.EventCenterEvent;
  import com.kitten.network.Connection;
  
  
  public class ExportController {
    
    /**
     * Last timestamp of the saved state.
     * Important when checking multi editing collisions.
     * If the self's lastSaved is earlier than on the Drupal side, it means
     * an other client saved a different state. Currently there is no
     * way for multiediting ;.( - Arms of Sorrow - Killswitch Engage
     */
    public static var lastSaved:Number = new Date().time;
    
    
    /**
     * Export work to FreeMind XML format
     * @return string
     */
    public static function getFreeMindXML(node:NodeViewController):String {
      return '<map version="0.9.0">' + "\n" + node.exportToFreeMindFormat() + '</map>' + "\n";
    }
    
    
    /**
     * Save work into host node
     */
    public static function saveFreeMindXMLToDrupal(conn:Connection, xml:String, nid:uint):void {
      conn.call('graphmind.saveGraphMind', onSaveFreemindXMLToDrupalSucceed, null, nid, xml, lastSaved * 0.001);
    }
    
    
    private static function onSaveFreemindXMLToDrupalSucceed(result:Object):void {
      lastSaved = new Date().time;
      EventCenter.notify(EventCenterEvent.MAP_SAVED, result);
    }

  }
  
}
