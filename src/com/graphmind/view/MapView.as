package com.graphmind.view {
  
  import com.graphmind.event.MapEvent;
  
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
    * Layer to lock all mouse events from the other layers.
    */
    public var lockLayer:Canvas = new Canvas();
    
  
    /**
    * Constructor.
    */    
    public function MapView() {
      super();

      setStyle('top', '0');
      setStyle('bottom', '0');
      setStyle('left', '0');
      setStyle('right', '0');
      setStyle('backgroundColor', '0xFFFFFF');
      horizontalScrollPolicy = ScrollPolicy.ON;
      verticalScrollPolicy   = ScrollPolicy.ON;
      
      // Add UI layers.
      addChild(container);
      container.addChild(cloudLayer);
      container.addChild(connectionLayer);
      container.addChild(overlayLayer);
      container.addChild(nodeLayer);
      container.addChild(lockLayer);
      
      lockLayer.setStyle('backgroundColor', '0x000000');
      lockLayer.alpha = 0.0;

      // Map is ready to interact.
      // It doesn't mean that there are objects on it.
      dispatchEvent(new MapEvent(MapEvent.MINDMAP_CREATION_COMPLETE));
    }
    
    
    /**
    * Set the size of the inner view.
    */
    public function setContainerSize(width:uint, height:uint):void {
      lockLayer.width  = nodeLayer.width  = connectionLayer.width  = cloudLayer.width  = overlayLayer.width  = width;
      lockLayer.height = nodeLayer.height = connectionLayer.height = cloudLayer.height = overlayLayer.height = height;
    }
    
    
    /**
    * Set scale of the map.
    */
    public function setScale(scale:Number):void {
      container.scaleX = scale * 0.01;
      container.scaleY = scale * 0.01;
    }
    
    
    /**
    * Override toString.
    */
    public override function toString():String {
      return 'MapView [' + width + ' X ' + height + ']';
    }

  }
  
}

