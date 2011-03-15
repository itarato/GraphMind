package com.graphmind.event {
  
  import flash.events.Event;

  public class EventCenterEvent extends Event {
    
    public static var NODE_SELECTED:String      = 'nodeSelected';
    public static var NODE_UNSELECTED:String    = 'nodeUnselected';
    public static var NODE_MOVED:String         = 'nodeMoved';
    public static var NODE_START_DRAG:String    = 'nodeStartDrag';
    public static var NODE_PREPARE_DRAG:String  = 'nodePrepareDrag';
    public static var NODE_FINISH_DRAG:String   = 'nodeFinishDrag';
    public static var NODE_CREATED:String       = 'nodeCreated';
    
    public static var MAP_UPDATED:String        = 'mapUpdated';
    public static var MAP_SAVED:String          = 'mapSaved';
    
    /**
    * Object that emitted the event.
    */
    public var sender:Object;
    
    /**
    * Data.
    */
    public var data:Object;
    
    
    /**
    * Constructor.
    */
    public function EventCenterEvent(type:String, sender:Object = null, data:Object = null, bubbles:Boolean=false, cancelable:Boolean=false) {
      this.sender = sender;
      this.data   = data;
      super(type, bubbles, cancelable);
    }
    
  }

}
