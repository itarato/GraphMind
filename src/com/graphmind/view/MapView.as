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
    public var container:UIComponent = new Container();    
    
    /**
    * Layer for the node connections.
    */
    public var connectionLayer:Container = new Container();
    
    /**
    * Layer for the clouds.
    */
    public var cloudLayer:Container = new Container();
    
    /**
    * Layer for the node objects.
    */
    public var nodeLayer:Container = new Container();
    
  
  
    /**
    * Constructor.
    */    
    public function MapView() {
      super();

      // Add UI layers.      
      addChild(container);
      container.addChild(cloudLayer);
      container.addChild(connectionLayer);
      container.addChild(nodeLayer);
      
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

