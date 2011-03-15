package com.graphmind {
  
  import com.graphmind.data.IMapViewData;
  import com.graphmind.data.IMapViewEvent;
  import com.graphmind.display.NodeViewController;
  import com.graphmind.event.MapEvent;
  import com.graphmind.view.MapView;
  import com.graphmind.view.TreeDrawer;
  
  import flash.events.EventDispatcher;
  
  [Event(name="mindmapUpdated", type="com.graphmind.event.MapEvent")]
  public class MapViewController extends EventDispatcher implements IMapViewData, IMapViewEvent {

    /**
    * View object.
    */    
    public var view:MapView;
    
    /**
     * Drawer of the application (can be TreeDrawer, GraphDrawer, etc.)
     */
    public var treeDrawer:TreeDrawer;
    
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
      view.addEventListener(MapEvent.MINDMAP_CREATION_COMPLETE, onLoadMap);
    }


    /**********************************
    * IMapViewData.
    ***********************************/
    
    public function getRootNode():NodeViewController {
      return null;
    }
    
    
    /**********************************
    * IMapViewEvent
    ***********************************/
    
    public function onSaveMap():void {
    }
    
    
    public function onStartDragMap():void {
    }
    
    
    public function onMoveMap():void {
    }
    
    
    public function onDragEndMap():void {
    }
    
    
    public function onRequestRefreshMap():void {
    }
    
    
    public function onLoadMap():void {
    }
    
    
    public function onCloseMap():void {
    }

  }
  
}
