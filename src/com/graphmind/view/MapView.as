package com.graphmind.view {
  
  import com.graphmind.event.MapEvent;
  
  import mx.core.Container;
  import mx.core.ScrollPolicy;
  import mx.core.UIComponent;
  
  [Event(name="mindmapCreationComplete", type="com.graphmind.event.MapEvent")]
  public class MapView extends Container {

    /**
    * Inner scrollable container view.
    */
    public var container:UIComponent;
  
  
    /**
    * Constructor.
    */    
    public function MapView() {
      super();
      
      addChild(container);
      horizontalScrollPolicy = ScrollPolicy.ON;
      verticalScrollPolicy   = ScrollPolicy.ON;
      
      // Map is ready to interact.
      // It doesn't mean that there are objects on it.
      dispatchEvent(new MapEvent(MapEvent.MINDMAP_CREATION_COMPLETE));
    }
    
    
    /**
    * Set the size of the inner view.
    */
    public function setContainerSize(width:uint, height:uint):void {
      container.width  = width;
      container.height = height;
    }
    

    /**
    * Ask for refreshing the display.
    */    
    public function refreshDisplay():void {
    }

  }
  
}

