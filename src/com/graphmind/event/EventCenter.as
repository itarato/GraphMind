package com.graphmind.event {
  
  import flash.events.EventDispatcher;
  import flash.events.IEventDispatcher;

  public class EventCenter extends EventDispatcher {

    /**
    * Shared event center object.
    */
    private static var i:EventCenter = new EventCenter();
    
    
    /**
    * Constructor.
    */
    public function EventCenter(target:IEventDispatcher=null) {
      i = this;
      super(target);
    }
    
    
    /**
    * Bradcast event.
    */
    public static function notify(type:String, sender:Object = null, data:Object = null):void {
      i.dispatchEvent(new EventCenterEvent(type, sender, data));
    }


    /**
    * Subscribe to an event.
    */    
    public static function subscribe(type:String, callback:Function):void {
      i.addEventListener(type, callback);
    }
    
  }
  
}
