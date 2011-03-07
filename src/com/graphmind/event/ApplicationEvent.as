package com.graphmind.event {
  
  import flash.events.Event;

  public class ApplicationEvent extends Event {
    
    /**
     * Event: triggered when application loaded the basic data.
     */
    public static var APPLICATION_DATA_COMPLETE:String = 'applicationDataComplete';
    
    public function ApplicationEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
      super(type, bubbles, cancelable);
    }
    
  }
  
}