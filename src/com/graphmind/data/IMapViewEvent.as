package com.graphmind.data {
  
  import com.graphmind.display.NodeViewController;
  
  public interface IMapViewEvent {
  
    function onSaveMap():void;
    function onStartDragMap():void;
    function onMoveMap():void;
    function onDragEndMap():void;
    function onRequestRefreshMap():void;
    function onLoadMap():void;
    function onCloseMap():void;
    
  }
  
}
