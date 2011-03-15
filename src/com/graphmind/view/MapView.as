package com.graphmind.view {
  
  import com.graphmind.event.MapEvent;
  
  import mx.containers.Canvas;
  import mx.core.Container;
  import mx.core.ScrollPolicy;
  import mx.core.UIComponent;
  
  [Event(name="mindmapCreationComplete", type="com.graphmind.event.MapEvent")]
  public class MapView extends Canvas {

    /**
    * Inner scrollable container view.
    */
    public var container:Canvas = new Canvas();    
    
    /**
    * Layer for the node connections.
    */
    public var connectionLayer:Canvas = new Canvas();
    
    /**
    * Layer for the clouds.
    */
    public var cloudLayer:Canvas = new Canvas();
    
    /**
    * Layer for the node objects.
    */
    public var nodeLayer:Canvas = new Canvas();
    
  
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
      
//      nodeLayer.setStyle('height', '100%');
//      nodeLayer.setStyle('width', '100%');
//      connectionLayer.setStyle('height', '100%');
//      connectionLayer.setStyle('width', '100%');
//      cloudLayer.setStyle('height', '100%');
//      cloudLayer.setStyle('width', '100%');
      
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
      container.width  = nodeLayer.width = connectionLayer.width = cloudLayer.width = width;
      container.height = nodeLayer.height = connectionLayer.height = cloudLayer.height = height;
    }
    

  }
  
}

