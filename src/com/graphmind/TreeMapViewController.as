package com.graphmind {

	import com.graphmind.data.NodeData;
	import com.graphmind.data.ViewsCollection;
	import com.graphmind.data.ViewsServicesParamsVO;
	import com.graphmind.display.NodeViewController;
	import com.graphmind.factory.NodeFactory;
	import com.graphmind.temp.TempItemLoadData;
	import com.graphmind.temp.TempViewLoadData;
	import com.graphmind.util.DesktopDragInfo;
	import com.graphmind.util.OSD;
	import com.graphmind.view.TreeDrawer;
	import com.graphmind.view.TreeMapView;
	import com.kitten.network.Connection;
	
	import flash.display.MovieClip;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.ContextMenu;
	
	import mx.controls.Image;
	import mx.core.Application;
	import mx.core.BitmapAsset;
	import mx.events.ListEvent;
	
	/**
	 * Stage manager
	 *  - events that happen on the stage's UI elements (general buttons, ...)
	 *  - structure drawer support (tree, graph, ...)
	 *  - stage level hooks
	 */
	public class TreeMapViewController extends MapViewController {
    
    /**
     * Last selected node.
     */
    public var activeNode:NodeViewController = null;
    
    /**
     * Root node. At the creation of the map it's the host Drupal node.
     */
    public var rootNode:NodeViewController  = null;
    
		/** 
		 * Indicates if the stage has a newer state or new elements.
		 */
    [Bindable]
    // @TODO - rename it to: isStageUpdated
    public var isTreeUpdated:Boolean = false;
    
    /**
     * Event that happens when
     */
    // @TODO rename to EVENT_STAGE_UPDATED
		public static var EVENT_MINDMAP_UPDATED:String = 'mindmapUpdated';

    /**
     * Stage UI drag and drop properties.
     */    
    protected var isDesktopDragged:Boolean = false;
    protected var _desktopDragInfo:DesktopDragInfo = new DesktopDragInfo();
    
    /**
    * Image source used for dragging imitation.
    */
    [Embed(source='assets/images/draganddrop.png')]
    private var _dragAndDropImageSource:Class;
    
    /**
    * Drag and drop image.
    */
    public var dragAndDropImage:Image;
    
    
		/**
		 * Constructor.
		 */
		public function TreeMapViewController() {
		  super(false);
		  
		  // Init custom view - tree map view.
		  view = new TreeMapView();
		  
		  // Set the structure drawer.
		  this.treeDrawer = new TreeDrawer(
		    (view as TreeMapView).nodeLayer,
		    (view as TreeMapView).connectionLayer,
		    (view as TreeMapView).cloudLayer
		  );
		  
		  // Event listener - the stage UI is updated
			addEventListener(EVENT_MINDMAP_UPDATED, onMindmapUpdated);
      
      // Node title RTE editor's default color
      GraphMind.i.mindmapToolsPanel.node_info_panel.nodeLabelRTE.colorPicker.selectedColor = 0x555555;
      
      // Remove base context menu items (not perfect, though)
      var cm:ContextMenu = new ContextMenu();
      cm.hideBuiltInItems();
      MovieClip(GraphMind.i.systemManager).contextMenu = cm;
      
      // Add drag and drop iamge.
      var bmd:BitmapAsset = (new _dragAndDropImageSource()) as BitmapAsset;
      dragAndDropImage.source = bmd;
      view.container.addChild(dragAndDropImage);
      
//      trace(GraphMind.i.mindmapCanvas.desktop_wrapper.getChildIndex(GraphMind.i.mindmapCanvas.desktop));
//      trace(GraphMind.i.mindmapCanvas.desktop_wrapper.getChildIndex(GraphMind.i.mindmapCanvas.desktop_arrowlink));
//      GraphMind.i.mindmapCanvas.desktop_wrapper.swapChildrenAt(
//        GraphMind.i.mindmapCanvas.desktop_wrapper.getChildIndex(GraphMind.i.mindmapCanvas.desktop),
//        GraphMind.i.mindmapCanvas.desktop_wrapper.getChildIndex(GraphMind.i.mindmapCanvas.desktop_arrowlink)
//      );
		}
		
		
    /**
     * Event handler: stage is updated.
     */
		protected function onMindmapUpdated(event:Event):void {
			treeDrawer.refreshGraphics();
			setMindmapUpdated();
		}
		

    /**
     * Indicates mindmap has changed -> needs saving.
     */
    public function setMindmapUpdated():void {
      isTreeUpdated = true;
    }
    

    /**
     * Select a views from datagrid on the views load panel.
     */
    public function onItemClick_LoadViewDataGrid(event:ListEvent):void {
      var selectedViewsCollection:ViewsCollection = event.itemRenderer.data as ViewsCollection;
      
      GraphMind.i.panelLoadView.view_name.text = selectedViewsCollection.name;
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
        activeNode,
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
      loaderData.nodeItem = activeNode;
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
    
    /**
     * Refresh the whole mindmap stage.
     * 
     * Since it uses time deferring we can't decide on whether to refresh subtree or the whole tree.
     */
    public function redrawMindmapStage():void {
      if (!rootNode) return;
      
      getTreeDrawer().refreshGraphics();
    }
    
    public function onClick_SaveGraphmindButton():void {
      save();
    }
    
    public function onClick_DumpFreemindXMLButton():void {
      GraphMind.i.mindmapToolsPanel.node_save_panel.freemindExportTextarea.text = exportToFreeMindFormat();
    }
    
    public function onClick_NodeAttributeAddOrUpdateButton():void {
      updateNodeAttribute(
        activeNode,
        GraphMind.i.mindmapToolsPanel.node_attributes_panel.attributes_update_param.text,
        GraphMind.i.mindmapToolsPanel.node_attributes_panel.attributes_update_value.text
      );
    }
    
    public function updateNodeAttribute(node:NodeViewController, attribute:String, value:String):void {
      if (!node || !attribute) return;
      
      node.addData(attribute, value);
      node.selectNode();
      
      GraphMind.i.mindmapToolsPanel.node_attributes_panel.attributes_update_param.text = GraphMind.i.mindmapToolsPanel.node_attributes_panel.attributes_update_value.text = '';
    }
    
    public function onClick_NodeAttributeRemoveButton():void {
      removeNodeAttribute(activeNode, GraphMind.i.mindmapToolsPanel.node_attributes_panel.attributes_update_param.text);
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
    
    public function onClick_FullscreenButton():void {
      toggleFullscreenMode();
    }
    
    /**
     * Toggle fullscreen mode.
     */
    protected function toggleFullscreenMode():void {
      try {
        
        switch (Application.application.stage.displayState) {
          case StageDisplayState.FULL_SCREEN:
            Application.application.stage.displayState = StageDisplayState.NORMAL;
            break;
          case StageDisplayState.NORMAL:
            Application.application.stage.displayState = StageDisplayState.FULL_SCREEN;
            break;
        }
      } catch (e:Error) {}
    }
    
    public function onMouseUp_DragAndDropImage():void {
      dragAndDropImage.visible = false;
      dragAndDropImage.x = -100;
      dragAndDropImage.y = -100;
    }
    
    public function prepaireDragAndDrop():void {
      NodeViewController.isPrepairedNodeDragAndDrop = true;
    }
    
    public function openDragAndDrop(source:NodeViewController):void {
      NodeViewController.isPrepairedNodeDragAndDrop = false;
      NodeViewController.isNodeDragAndDrop = true;
      NodeViewController.dragAndDrop_sourceNode = source;
      dragAndDropImage.visible = true;
      dragAndDropImage.x = view.container.mouseX - dragAndDropImage.width / 2;
      dragAndDropImage.y = view.container.mouseY - dragAndDropImage.height / 2;
      dragAndDropImage.startDrag(false);
    }
    
    public function onMouseUp_MindmapStage():void {
      closeNodeDragAndDrop();
    }
    
    public function onMouseDownOutside_MindmapStage():void {
      closeNodeDragAndDrop();
    }
    
    public function onMouseOut_MindmapStage():void {
      closeDesktopDragAndDrop();
    }
    
    public function onMouseUp_InnerMindmapStage():void {
      closeDesktopDragAndDrop();
    }
    
    /**
     * Finishes drag and drop session for a node.
     */
    public function closeNodeDragAndDrop():void {
      NodeViewController.isNodeDragAndDrop = false;
      NodeViewController.isPrepairedNodeDragAndDrop = false;
      dragAndDropImage.visible = false;
      NodeViewController.dragAndDrop_sourceNode = null;
    }
    
    /**
     * Finishes drag and drop session for the mindmap area.
     */
    protected function closeDesktopDragAndDrop():void {
      isDesktopDragged = false;
    }
    
    public function onClick_RTESaveButton():void {
      if (!isActiveNodeExists()) return;
      
      activeNode.setTitle(GraphMind.i.mindmapToolsPanel.node_info_panel.nodeLabelRTE.htmlText);
    }
    
    public function onClick_SaveNodeLink():void {
      if (!isActiveNodeExists()) return;
      
      activeNode.setLink(GraphMind.i.mindmapToolsPanel.node_info_panel.link.text);
    }
    
    /**
     * Check if there is any node selected.
     */
    public function isActiveNodeExists(showError:Boolean = false):Boolean {
      if (!activeNode) {
        if (showError) OSD.show("Please, select a node first.", OSD.WARNING);
        return false;
      }
      
      return true;
    }
    
    public function onClick_Icon(event:MouseEvent):void {
      addIconToNode(event.currentTarget as Image);
    }
    
    public function addIconToNode(icon:Image):void {
      if (!isActiveNodeExists()) return;
      
      activeNode.addIcon(icon.source.toString());
    }
    
    public function onMouseDown_InnerMindmapStage():void {
      startNodeDragAndDrop();
    }
    
    public function onMouseMove_InnerMindmapStage():void {
      doNodeDragAndDrop();
    }
    
    /**
     * Start the dragged node's drag and drop session.
     */
    protected function startNodeDragAndDrop():void {
      view.container.setFocus();
      
      isDesktopDragged = true;
      
      _desktopDragInfo.oldVPos = view.mouseY;
      _desktopDragInfo.oldHPos = view.mouseX;
      _desktopDragInfo.oldScrollbarVPos = view.verticalScrollPosition;
      _desktopDragInfo.oldScrollbarHPos = view.horizontalScrollPosition;
    }
    
    protected function doNodeDragAndDrop():void {
      if (isDesktopDragged) {
        var deltaV:Number = view.mouseY - _desktopDragInfo.oldVPos;
        var deltaH:Number = view.mouseX - _desktopDragInfo.oldHPos;
        view.verticalScrollPosition   = _desktopDragInfo.oldScrollbarVPos - deltaV;
        view.horizontalScrollPosition = _desktopDragInfo.oldScrollbarHPos - deltaH;
      }
    }
    
    public function onClick_ToggleCloudButton():void {
      if (!isActiveNodeExists()) return;
      
      activeNode.toggleCloud();
    }
    
    /**
     * Export work to FreeMind XML format
     * @return string
     */
    public function exportToFreeMindFormat():String {
      return '<map version="0.9.0">' + "\n" + 
        rootNode.exportToFreeMindFormat() + 
        '</map>' + "\n";
    }
    
    /**
     * Save work into host node
     */
    public function save():String {
      var mm:String = exportToFreeMindFormat();
      // @TODO implement
//      ConnectionManager.saveGraphMind(
//        ApplicationController.i.getHostNodeID(),
//        mm,
//        ApplicationController.i.lastSaved,
//        ApplicationController.i.baseSiteConnection, 
//        ApplicationController.i._save_stage_saved
//      );
      isTreeUpdated = false;
      return mm;
    }
    
    public function getTreeDrawer():TreeDrawer {
      return treeDrawer as TreeDrawer;
    }
    
    public function addNodeToStage(node:NodeViewController):void {
      treeDrawer.addUIElementToDisplayList(node.view);
    }

	}
	
}
