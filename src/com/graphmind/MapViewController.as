package com.graphmind {
  
  import com.graphmind.data.IMapViewEvent;
  import com.graphmind.display.TreeDrawer;
  import com.graphmind.event.MapEvent;
  import com.graphmind.view.MapView;
  
  import flash.events.EventDispatcher;
  import flash.filters.BlurFilter;
  
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
      unlock();
    }


    /**
    * Lock a map from user actions.
    */
    public function lock():void {
      view.lockLayer.visible = true;
      view.filters = [new BlurFilter(6.0, 6.0)];
    }
    
    
    /**
    * Lock a map from user actions.
    */
    public function unlock():void {
      view.lockLayer.visible = false;
      view.filters = [];
    }


    /**********************************
    * IMapViewEvent
    ***********************************/
    
    public function onMapDidLoaded(event:FlexEvent):void {}
    
  }
  
}
