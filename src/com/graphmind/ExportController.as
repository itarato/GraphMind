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
      return '<map version="0.9.0">' + "\n" +
             '<!-- To view this file, download free mind mapping software FreeMind from http://freemind.sourceforge.net -->' +
             '<attribute_registry SHOW_ATTRIBUTES="hide"/>' + "\n" +
             node.exportToFreeMindFormat() + 
             '</map>' + "\n";
    }
    
    
    /**
     * Save work into host node
     */
    public static function saveFreeMindXMLToDrupal(xml:String):void {
      ConnectionController.mainConnection.call(
        'graphmind.saveGraphMind', 
        onSaveFreemindXMLToDrupalSucceed, 
        ConnectionController.defaultRequestErrorHandler, 
        ApplicationController.getHostEntityVID(),
        ApplicationController.getHostEntityDelta(),
        ApplicationController.getHostEntityFieldName(),
        xml
      );
    }
    
    
    /**
    * Save map silently.
    */
    public static function saveFreeMindXMLToDrupalSilent(xml:String):void {
      ConnectionController.mainConnection.call(
        'graphmind.saveGraphMind', 
        function(e:Object):void{
          lastSaved = new Date().time;
          EventCenter.notify(EventCenterEvent.MAP_SAVED_SILENTLY, e);
        }, 
        ConnectionController.defaultRequestErrorHandler, 
        ApplicationController.getHostEntityVID(),
        ApplicationController.getHostEntityDelta(),
        ApplicationController.getHostEntityFieldName(),
        xml
      );
    }
    
    
    private static function onSaveFreemindXMLToDrupalSucceed(result:Object):void {
      lastSaved = new Date().time;
      EventCenter.notify(EventCenterEvent.MAP_SAVED, result);
    }

  }
  
}
