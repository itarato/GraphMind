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
     * Active node's attributes -> to display it as attributes.
     * Sensitive information not included (ie: passwords).
     */ 
    [Bindable]
    public var selectedNodeData:ArrayCollection = new ArrayCollection();
    
    
    /**
    * Consructor.
    */
    public function AppFormController() {
      // Event handlers.
      EventCenter.subscribe(EventCenterEvent.NODE_IS_SELECTED, onNodeSelected);
    }

    
    /**
    * Act when a node was got selected.
    */
    public function onNodeSelected(event:EventCenterEvent):void {
      var node:NodeViewController = event.data as NodeViewController;
      
      selectedNodeData.removeAll();
      for (var key:* in node.nodeData.drupalData) {
        selectedNodeData.addItem({
          key: key,
          value: node.nodeData.drupalData[key]
        });
      }     
      
//      GraphMind.i.mindmapToolsPanel.node_info_panel.nodeLabelRTE.htmlText = node.view.nodeComponentView.title_label.htmlText || node.view.nodeComponentView.title_label.text;
//      GraphMind.i.mindmapToolsPanel.node_info_panel.link.text = node.nodeData.link;
//      GraphMind.i.mindmapToolsPanel.node_attributes_panel.attributes_update_param.text = '';
//      GraphMind.i.mindmapToolsPanel.node_attributes_panel.attributes_update_value.text = '';
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
    
    
    public function onClick_RTESaveButton(text:String):void {
      EventCenter.notify(EventCenterEvent.ACTIVE_NODE_TITLE_IS_CHANGED, text); 
    }
    
    
    public function onClick_SaveNodeLink(text:String):void {
      EventCenter.notify(EventCenterEvent.ACTIVE_NODE_LINK_IS_CHANGED, text);
    }
    
    
    public function onClick_SaveGraphmindButton():void {
      EventCenter.notify(EventCenterEvent.REQUEST_TO_SAVE);
    }
    
    
    public function onClick_NodeAttributeAddOrUpdateButton(param:String, value:String):void {
      EventCenter.notify(EventCenterEvent.ACTIVE_NODE_SAVE_ATTRIBUTE, {param: param, value: value});
    }
    
        
    public function onClick_NodeAttributeRemoveButton(param:String):void {
      EventCenter.notify(EventCenterEvent.ACTIVE_NODE_REMOVE_ATTRIBUTE, param);
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
