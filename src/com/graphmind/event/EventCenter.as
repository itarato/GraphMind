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
    public static function notify(type:String, data:Object = null):EventCenterEvent {
      var e:EventCenterEvent = new EventCenterEvent(type, data);
      i.dispatchEvent(e);
      return e;
    }


    /**
    * Subscribe to an event.
    */    
    public static function subscribe(type:String, callback:Function):void {
      i.addEventListener(type, callback);
    }
    
  }
  
}
