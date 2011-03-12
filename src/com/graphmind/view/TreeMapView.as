package com.graphmind.view {

  import mx.core.Container;
  
  public class TreeMapView extends MapView {

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
    public function TreeMapView() {
      super();
      
      container.addChild(cloudLayer);
      container.addChild(connectionLayer);
      container.addChild(nodeLayer);
    }
    
  }
  
}
