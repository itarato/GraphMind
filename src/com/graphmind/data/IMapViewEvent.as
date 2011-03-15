package com.graphmind.data {
  
  import mx.events.FlexEvent;
  
  public interface IMapViewEvent {
  
    function onSaveMap():void;
    function onStartDragMap():void;
    function onMoveMap():void;
    function onDragEndMap():void;
    function onRequestRefreshMap():void;
    function onMapDidLoaded(event:FlexEvent):void;
    function onCloseMap():void;
    
  }
  
}
