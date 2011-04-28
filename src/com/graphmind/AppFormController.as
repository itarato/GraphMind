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

    
    /**
     * Event for clicking on the view load panel.
     */
    public function onClick_LoadViewsSubmitButton():void {
      var views:DrupalViewsQuery = new DrupalViewsQuery();
      views.args      = GraphMind.i.panelLoadView.view_arguments.text;
      views.limit     = parseInt(GraphMind.i.panelLoadView.view_limit.text);
      views.offset    = parseInt(GraphMind.i.panelLoadView.view_offset.text);
      views.name = GraphMind.i.panelLoadView.view_name.text;
      views.views    = GraphMind.i.panelLoadView.view_views_datagrid.selectedItem as DrupalViews;
      
      var temp:DrupalViewsRequestParamObject = new DrupalViewsRequestParamObject();
      temp.parentNode = TreeMapViewController.activeNode;
      temp.views = views;
      
      EventCenter.notify(EventCenterEvent.LOAD_DRUPAL_VIEWS, temp);
      
      GraphMind.i.currentState = '';
    }
    
    
    /**
     * Event on cancelling views load panel.
     */
    public function onClick_LoadViewsCancelButton():void {
      GraphMind.i.currentState = '';
    }
    
    
    /**
     * Event on submitting item loading panel.
     */
    public function onClick_LoadItemSubmit():void {
      var temp:DrupalItemRequestParamObject = new DrupalItemRequestParamObject();
      temp.type = GraphMind.i.panelLoadDrupalItem.item_type.selectedItem.data;
      temp.conn = GraphMind.i.panelLoadDrupalItem.item_source.selectedItem as Connection;
      temp.id = GraphMind.i.panelLoadDrupalItem.item_id.text;
      temp.parentNode = TreeMapViewController.activeNode;

      EventCenter.notify(EventCenterEvent.LOAD_DRUPAL_ITEM, temp);
      
      GraphMind.i.currentState = '';
    }
    
    
    /**
     * Event for on item loader cancel.
     */
    public function onClick_LoadItemCancel():void {
      GraphMind.i.currentState = '';
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
