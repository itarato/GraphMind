package com.graphmind {
  
  import com.graphmind.event.EventCenter;
  import com.graphmind.event.EventCenterEvent;
  
  
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
    public static function saveFreeMindXMLToDrupal(xml:String, nid:uint):void {
      ConnectionController.mainConnection.call('graphmind.saveGraphMind', onSaveFreemindXMLToDrupalSucceed, ConnectionController.defaultRequestErrorHandler, nid, xml, lastSaved * 0.001);
    }
    
    
    /**
    * Save map silently.
    */
    public static function saveFreeMindXMLToDrupalSilent(xml:String, nid:uint):void {
      ConnectionController.mainConnection.call('graphmind.saveGraphMind', function(e:Object):void{lastSaved = new Date().time;}, ConnectionController.defaultRequestErrorHandler, nid, xml, lastSaved * 0.001);
    }
    
    
    private static function onSaveFreemindXMLToDrupalSucceed(result:Object):void {
      lastSaved = new Date().time;
      EventCenter.notify(EventCenterEvent.MAP_SAVED, result);
    }

  }
  
}
