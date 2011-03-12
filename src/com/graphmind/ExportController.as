package com.graphmind {
  
  import com.graphmind.display.NodeViewController;
  import com.graphmind.event.EventCenter;
  import com.graphmind.event.EventCenterEvent;
  
  public class ExportController {
    
    public function ExportController() {}

        
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
    public static function saveFreeMindXMLToDrupal():String {
      var mm:String = getFreeMindXML(TreeMapViewController.rootNode);
      // @TODO implement
//      ConnectionManager.saveGraphMind(
//        ApplicationController.i.getHostNodeID(),
//        mm,
//        ApplicationController.i.lastSaved,
//        ApplicationController.i.baseSiteConnection, 
//        ApplicationController.i._save_stage_saved
//      );
      EventCenter.notify(EventCenterEvent.MAP_SAVED);
      return mm;
    }

  }
  
}
