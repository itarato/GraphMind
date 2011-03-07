package com.graphmind.event
{
  import flash.events.Event;

  public class ApplicationEvent extends Event
  {
    public function ApplicationEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
    {
      super(type, bubbles, cancelable);
    }
    
  }
}