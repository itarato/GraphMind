package com.graphmind {
  
  import com.graphmind.data.DrupalViews;
  import com.graphmind.data.DrupalViewsQuery;
  import com.graphmind.event.EventCenter;
  import com.graphmind.event.EventCenterEvent;
  import com.graphmind.temp.DrupalItemRequestParamObject;
  import com.graphmind.temp.DrupalViewsRequestParamObject;
  import com.graphmind.util.Log;
  import com.graphmind.util.OSD;
  import com.kitten.events.ConnectionEvent;
  import com.kitten.events.ConnectionIOErrorEvent;
  import com.kitten.network.Connection;
  
  import flash.display.StageDisplayState;
  import flash.events.MouseEvent;
  
  import mx.collections.ArrayCollection;
  import mx.controls.Image;
  import mx.core.Application;
  import mx.events.ListEvent;
  
  
  public class AppFormController {
    
    /**
    * Consructor.
    */
    public function AppFormController() {
      // Event handlers.
      EventCenter.subscribe(EventCenterEvent.NODE_IS_SELECTED, onNodeSelected);
    }

    
    public function onClick_SaveGraphmindButton():void {
      EventCenter.notify(EventCenterEvent.REQUEST_TO_SAVE);
    }
    
    
    public function onClick_Icon(event:MouseEvent):void {
      EventCenter.notify(EventCenterEvent.ACTIVE_NODE_ADD_ICON, (event.currentTarget as Image).source.toString());
    }


    /**
     * Select a views from datagrid on the views load panel.
     */
    public function onItemClick_LoadViewDataGrid(event:ListEvent):void {
      var selectedViewsCollection:DrupalViews = event.itemRenderer.data as DrupalViews;
      
      GraphMind.i.panelLoadView.view_name.text = selectedViewsCollection.name;
    }

    
    public function onChange_ScaleSlider(value:Number):void {
      EventCenter.notify(EventCenterEvent.MAP_SCALE_CHANGED, value);
    }
    
    
    public function onChange_NodeSize(value:uint):void {
      EventCenter.notify(EventCenterEvent.REQUEST_TO_CHANGE_NODE_SIZE, value);
    }
    
  }
  
}
