package com.graphmind {
  
  import com.graphmind.data.NodeData;
  import com.graphmind.data.ViewsCollection;
  import com.graphmind.data.ViewsServicesParamsVO;
  import com.graphmind.display.NodeViewController;
  import com.graphmind.event.EventCenter;
  import com.graphmind.event.EventCenterEvent;
  import com.graphmind.factory.NodeFactory;
  import com.graphmind.temp.TempItemLoadData;
  import com.graphmind.temp.TempViewLoadData;
  import com.graphmind.util.OSD;
  import com.kitten.network.Connection;
  
  import flash.events.MouseEvent;
  
  import mx.collections.ArrayCollection;
  import mx.controls.Image;
  
  public class AppFormController {
                
    /**
     * Active node's attributes -> to display it as attributes.
     * Sensitive information not included (ie: passwords).
     */ 
    [Bindable]
    public var selectedNodeData:ArrayCollection = new ArrayCollection();
    
    /**
    * Connections.
    */
    [Bindable]
    public var connections:ArrayCollection;
    
    
    /**
    * Consructor.
    */
    public function AppFormController() {
      // Set MXML file controllers.
      GraphMind.i.panelLoadDrupalItem.controller = this;
      GraphMind.i.mindmapToolsPanel.node_save_panel.controller = this;
      GraphMind.i.mindmapToolsPanel.node_info_panel.controller = this;
      GraphMind.i.mindmapToolsPanel.node_attributes_panel.controller = this;
      GraphMind.i.mindmapToolsPanel.node_connections_panel.controller = this;
      
      EventCenter.subscribe(EventCenterEvent.NODE_SELECTED, onNodeSelected);
    }

    
    /**
    * Act when a node was got selected.
    */
    public function onNodeSelected(event:EventCenterEvent):void {
      var node:NodeViewController = event.data as NodeViewController;
      
      for (var key:* in node.nodeData.data) {
        selectedNodeData.addItem({
          key: key,
          value: node.nodeData.data[key]
        });
      }     
      
      GraphMind.i.mindmapToolsPanel.node_info_panel.nodeLabelRTE.htmlText = node.view._displayComp.title_label.htmlText || node.view._displayComp.title_label.text;
      GraphMind.i.mindmapToolsPanel.node_info_panel.link.text = node.nodeData.link;
      GraphMind.i.mindmapToolsPanel.node_attributes_panel.attributes_update_param.text = '';
      GraphMind.i.mindmapToolsPanel.node_attributes_panel.attributes_update_value.text = '';
    }
    
    
        
    /**
     * Event handler for
     */
    public function onClick_AddNewSiteConnectionButton():void {
//      var sc:SiteConnection = SiteConnection.createSiteConnection(
//        GraphMind.i.mindmapToolsPanel.node_connections_panel.connectFormURL.text,
//        GraphMind.i.mindmapToolsPanel.node_connections_panel.connectFormUsername.text,
//        GraphMind.i.mindmapToolsPanel.node_connections_panel.connectFormPassword.text
//      );
//      ConnectionManager.connectToSite(sc);
      // @TODO replace with the new connection system
    }
    
    /**
     * Event for clicking on the view load panel.
     */
    public function onClick_LoadViewsSubmitButton():void {
      loadAndAttachViewsList(
        TreeMapViewController.rootNode,
        GraphMind.i.panelLoadView.view_arguments.text,
        parseInt(GraphMind.i.panelLoadView.view_limit.text),
        parseInt(GraphMind.i.panelLoadView.view_offset.text),
        GraphMind.i.panelLoadView.view_name.text,
        GraphMind.i.panelLoadView.view_views_datagrid.selectedItem as ViewsCollection,
        onSuccess_DrupalViewsLoaded
      );
    }
    
    public function loadAndAttachViewsList(node:NodeViewController, args:String, limit:int, offset:int, viewName:String, viewsInfo:ViewsCollection, onSuccess:Function):void {
      var viewsData:ViewsServicesParamsVO = new ViewsServicesParamsVO();
      viewsData.args    = args;
      // Fields are not supported in Services for D6
      // viewsData.fields   = stage.view_fields.text;
      viewsData.limit     = limit;
      viewsData.offset    = offset;
      viewsData.view_name = viewName;
      viewsData.parent    = viewsInfo;
      
      var loaderData:TempViewLoadData = new TempViewLoadData();
      loaderData.viewsData = viewsData;
      loaderData.nodeItem = node;
      loaderData.success  = onSuccess;
      
      // @TODO implement
//      ConnectionManager.viewListLoad(loaderData);
      
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
      var nodeItemData:NodeData = new NodeData(
        {},
        GraphMind.i.panelLoadDrupalItem.item_type.selectedItem.data,
        GraphMind.i.panelLoadDrupalItem.item_source.selectedItem as Connection
      );
      nodeItemData.drupalID = parseInt(GraphMind.i.panelLoadDrupalItem.item_id.text);
      
      var loaderData:TempItemLoadData = new TempItemLoadData();
      loaderData.nodeItem = TreeMapViewController.rootNode;
      loaderData.nodeItemData = nodeItemData;
      loaderData.success = onSuccess_DrupalItemLoaded;
      
      // @TODO Implement it
//      ConnectionManager.itemLoad(loaderData);
      
      GraphMind.i.currentState = '';
    }
    
    
    /**
     * Event for on item loader cancel.
     */
    public function onClick_LoadItemCancel():void {
      GraphMind.i.currentState = '';
    }
    
    
    public function onSuccess_DrupalViewsLoaded(list:Array, requestData:TempViewLoadData):void {
      if (list.length == 0) {
        OSD.show('Result is empty.', OSD.WARNING);
      }
      for each (var nodeData:Object in list) {
        // @TODO update or append checkbox for the panel?
        var similarNode:NodeViewController = requestData.nodeItem.getEqualChild(nodeData, requestData.viewsData.parent.baseTable) as NodeViewController;
        if (similarNode) {
          similarNode.updateDrupalItem_result(nodeData);
          continue;
        }
        var nodeItem:NodeViewController = NodeFactory.createNode(
          nodeData,
          requestData.viewsData.parent.baseTable,
          requestData.viewsData.parent.source
        );
        requestData.nodeItem.addChildNode(nodeItem);
      }
    }
    
    
    public function onSuccess_DrupalItemLoaded(result:Object, requestData:TempItemLoadData):void {
      requestData.nodeItemData.data = result;
      var nodeItem:NodeViewController = new NodeViewController(requestData.nodeItemData);
      requestData.nodeItem.addChildNode(nodeItem);
      nodeItem.selectNode();
    }
    
        
    public function onClick_RTESaveButton():void {
      if (!NodeViewController.activeNode) return;
      
      NodeViewController.activeNode.setTitle(GraphMind.i.mindmapToolsPanel.node_info_panel.nodeLabelRTE.htmlText);
    }
    
    
    public function onClick_SaveNodeLink():void {
      if (!NodeViewController.activeNode) return;
      
      NodeViewController.activeNode.setLink(GraphMind.i.mindmapToolsPanel.node_info_panel.link.text);
    }
    
    
    public function onClick_ToggleCloudButton():void {
      if (!NodeViewController.activeNode) return;
      
      NodeViewController.activeNode.toggleCloud();
    }
    
        
    public function onClick_SaveGraphmindButton():void {
      ExportController.saveFreeMindXMLToDrupal();
    }
    
    
    public function onClick_DumpFreemindXMLButton():void {
      GraphMind.i.mindmapToolsPanel.node_save_panel.freemindExportTextarea.text = ExportController.getFreeMindXML(TreeMapViewController.rootNode);
    }    
    
    
    public function onClick_NodeAttributeAddOrUpdateButton():void {
      updateNodeAttribute(
        NodeViewController.activeNode,
        GraphMind.i.mindmapToolsPanel.node_attributes_panel.attributes_update_param.text,
        GraphMind.i.mindmapToolsPanel.node_attributes_panel.attributes_update_value.text
      );
    }
    
        
    public function onClick_NodeAttributeRemoveButton():void {
      removeNodeAttribute(NodeViewController.activeNode, GraphMind.i.mindmapToolsPanel.node_attributes_panel.attributes_update_param.text);
    }

    
    // @todo maybe put this into the event handler: onClick_NodeAttributeAddOrUpdateButton
    public function updateNodeAttribute(node:NodeViewController, attribute:String, value:String):void {
      if (!node || !attribute) return;
      
      node.addData(attribute, value);
      node.selectNode();
      
      GraphMind.i.mindmapToolsPanel.node_attributes_panel.attributes_update_param.text = GraphMind.i.mindmapToolsPanel.node_attributes_panel.attributes_update_value.text = '';
    }
    
    
    /**
     * Remove a node's attribute.
     */
    public function removeNodeAttribute(node:NodeViewController, attribute:String):void {
      if (!node || attribute.length == 0) return;
      
      node.deleteData(attribute);
      node.selectNode();
      
      GraphMind.i.mindmapToolsPanel.node_attributes_panel.attributes_update_param.text = GraphMind.i.mindmapToolsPanel.node_attributes_panel.attributes_update_value.text = '';
    }
    
       
    public function onClick_Icon(event:MouseEvent):void {
      addIconToNode(event.currentTarget as Image);
    }
    
    
    public function addIconToNode(icon:Image):void {
      if (!NodeViewController.activeNode) return;
      
      NodeViewController.activeNode.addIcon(icon.source.toString());
    }
    
    
  }
  
}
