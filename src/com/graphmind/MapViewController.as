package com.graphmind {
  
  import com.graphmind.data.IMapViewEvent;
  import com.graphmind.NodeViewController;
  import com.graphmind.event.MapEvent;
  import com.graphmind.view.MapView;
  import com.graphmind.display.TreeDrawer;
  
  import flash.events.Event;
  import flash.events.EventDispatcher;
  
  import mx.events.FlexEvent;
  
  [Event(name="mindmapUpdated", type="com.graphmind.event.MapEvent")]
  public class MapViewController extends EventDispatcher implements IMapViewEvent {

    /**
    * View object.
    */    
    public var view:MapView;
    
    /**
     * Drawer of the application (can be TreeDrawer, GraphDrawer, etc.)
     */
    protected var treeDrawer:TreeDrawer;
    
    /**
     * Desktop UI size.
     */
    public static var MAP_DEFAULT_HEIGHT:int = 2000;
    public static var MAP_DEFAULT_WIDTH:int = 3000;


    /**
    * Constructor.
    */    
    public function MapViewController() {
      view = new MapView();
      view.setContainerSize(MAP_DEFAULT_WIDTH, MAP_DEFAULT_HEIGHT);
      view.addEventListener(FlexEvent.CREATION_COMPLETE, onMapDidLoaded);
    }


    /**********************************
    * IMapViewEvent
    ***********************************/
    
    public function onMapDidLoaded(event:FlexEvent):void {
    }
    
  }
  
}
