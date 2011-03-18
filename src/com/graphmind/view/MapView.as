package com.graphmind.view {
  
  import com.graphmind.event.MapEvent;
  
  import flash.events.MouseEvent;
  
  import mx.containers.Canvas;
  import mx.core.ScrollPolicy;
  
  [Event(name="mindmapCreationComplete", type="com.graphmind.event.MapEvent")]
  public class MapView extends Canvas {

    /**
    * Container for layers.
    * It's the same size as the others.
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
    * Overlay for various things.
    */
    public var overlayLayer:Canvas = new Canvas();
    
  
    /**
    * Constructor.
    */    
    public function MapView() {
      super();

      setStyle('top', '0');
      setStyle('bottom', '0');
      setStyle('left', '0');
      setStyle('right', '0');
      horizontalScrollPolicy = ScrollPolicy.ON;
      verticalScrollPolicy   = ScrollPolicy.ON;

      // Add UI layers.
      addChild(container);
      container.addChild(cloudLayer);
      container.addChild(connectionLayer);
      container.addChild(nodeLayer);
      container.addChild(overlayLayer);

      // Map is ready to interact.
      // It doesn't mean that there are objects on it.
      dispatchEvent(new MapEvent(MapEvent.MINDMAP_CREATION_COMPLETE));
    }
    
    
    /**
    * Set the size of the inner view.
    */
    public function setContainerSize(width:uint, height:uint):void {
      nodeLayer.width  = connectionLayer.width  = cloudLayer.width  = overlayLayer.width  = width;
      nodeLayer.height = connectionLayer.height = cloudLayer.height = overlayLayer.height = height;
    }
    
    
    public override function toString():String {
      return 'MapView [' + width + ' X ' + height + ']';
    }

  }
  
}

