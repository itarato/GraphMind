package com.graphmind {

	import com.graphmind.data.NodeData;
	import com.graphmind.data.NodeType;
	import com.graphmind.data.ViewsCollection;
	import com.graphmind.data.ViewsServicesParamsVO;
	import com.graphmind.display.NodeController;
	import com.graphmind.event.NodeEvent;
	import com.graphmind.event.StageEvent;
	import com.graphmind.factory.NodeFactory;
	import com.graphmind.net.SiteConnection;
	import com.graphmind.temp.TempItemLoadData;
	import com.graphmind.temp.TempViewLoadData;
	import com.graphmind.util.DesktopDragInfo;
	import com.graphmind.util.OSD;
	import com.graphmind.view.StructureDrawer;
	import com.graphmind.view.TreeDrawer;
	
	import flash.display.MovieClip;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.ui.ContextMenu;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Image;
	import mx.core.Application;
	import mx.events.ListEvent;
	import mx.rpc.events.ResultEvent;
	
	/**
	 * Stage manager
	 *  - events that happen on the stage's UI elements (general buttons, ...)
	 *  - structure drawer support (tree, graph, ...)
	 *  - stage level hooks
	 */
	[Event(name="mindmapUpdated", type="com.graphmind.event.StageEvent")]
	public class StageManager extends EventDispatcher {
		        
    /**
     * Active node's attributes -> to display it as attributes.
     * Sensitive information not included (ie: passwords).
     */ 
    [Bindable]
    public var selectedNodeData:ArrayCollection = new ArrayCollection();
    
    /**
     * Last selected node.
     */
    public var activeNode:NodeController = null;
    
    /**
     * Root node. At the creation of the map it's the host Drupal node.
     */
    public var rootNode:NodeController  = null;
    
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
		 * Drawer of the application (can be TreeDrawer, GraphDrawer, etc.)
		 */
		public var structureDrawer:StructureDrawer;
		
		/**
		 * Desktop UI size.
		 */
    [Bindable]
    public static var DEFAULT_DESKTOP_HEIGHT:int = 2000;
    [Bindable]
    public static var DEFAULT_DESKTOP_WIDTH:int = 3000;

    /**
     * Stage UI drag and drop properties.
     */    
    protected var isDesktopDragged:Boolean = false;
    protected var _desktopDragInfo:DesktopDragInfo = new DesktopDragInfo();

    
		/**
		 * Constructor.
		 */
		public function StageManager(structureDrawer:StructureDrawer) {
		  // Set the structure drawer.
		  this.structureDrawer = structureDrawer;
		  
		  // Event listener - the stage UI is updated
			addEventListener(EVENT_MINDMAP_UPDATED, onMindmapUpdated);
			// Event listener - application ready to load the base node
			GraphMind.i.applicationManager.addEventListener(ApplicationManager.APPLICATION_DATA_COMPLETE, onApplicationDataComplete);
      
      // Scroll mindmap canvas to center
      GraphMind.i.mindmapCanvas.desktop_wrapper.verticalScrollPosition = (GraphMind.i.mindmapCanvas.desktop.height - GraphMind.i.mindmapCanvas.desktop_wrapper.height) / 2;
      
      // Node title RTE editor's default color
      GraphMind.i.mindmapToolsPanel.node_info_panel.nodeLabelRTE.colorPicker.selectedColor = 0x555555;
      
      // Remove base context menu items (not perfect, though)
      var cm:ContextMenu = new ContextMenu();
      cm.hideBuiltInItems();
      MovieClip(GraphMind.i.systemManager).contextMenu = cm;
      
      trace(GraphMind.i.mindmapCanvas.desktop_wrapper.getChildIndex(GraphMind.i.mindmapCanvas.desktop));
      trace(GraphMind.i.mindmapCanvas.desktop_wrapper.getChildIndex(GraphMind.i.mindmapCanvas.desktop_arrowlink));
      GraphMind.i.mindmapCanvas.desktop_wrapper.swapChildrenAt(
        GraphMind.i.mindmapCanvas.desktop_wrapper.getChildIndex(GraphMind.i.mindmapCanvas.desktop),
        GraphMind.i.mindmapCanvas.desktop_wrapper.getChildIndex(GraphMind.i.mindmapCanvas.desktop_arrowlink)
      );
		}

    /**
     * Event handler: stage is updated.
     */
		protected function onMindmapUpdated(event:Event):void {
			structureDrawer.refreshGraphics();
			setMindmapUpdated();
		}
		
		protected function onApplicationDataComplete(event:Event):void {
		  loadBaseNode();
		}
		
		/**
		 * Load the basic information from Drupal.
		 */
		public function loadBaseNode():void {
      ConnectionManager.nodeLoad(
        GraphMind.i.applicationManager.getHostNodeID(), 
        GraphMind.i.applicationManager.baseSiteConnection, 
        onSuccess_BaseNodeLoaded
      );
    }
    
    /**
     * Indicates mindmap has changed -> needs saving.
     */
    public function setMindmapUpdated():void {
      isTreeUpdated = true;
    }
    
    /**
     * Load base node - stage 2.
     */
    protected function onSuccess_BaseNodeLoaded(result:ResultEvent):void {
      GraphMind.i.applicationManager.setEditMode(result.result.graphmindEditable == '1');
      
      // @WTF sometimes body_value is the right value, sometimes not
      var is_valid_mm_xml:Boolean = false;
      var body:String = result.result.body.toString();
      if (body.length > 0) {
        var xmlData:XML = new XML(body);
        var nodes:XML = xmlData.child('node')[0];
        is_valid_mm_xml = nodes !== null;
      }
        
      if (is_valid_mm_xml) {
        // Subtree
        var importedBaseNode:NodeController = ImportManager.importMapFromString(body);
        rootNode = importedBaseNode;
      } else {
        // New node
        // ! Removed original data object: result.result.
        // This caused a mailformed export string.
        rootNode = NodeFactory.createNode(
          {},
          NodeType.NODE,
          SiteConnection.getBaseSiteConnection(),
          result.result.title
        );
      }
      
      dispatchEvent(new NodeEvent(NodeEvent.UPDATE_GRAPHICS, rootNode));
      // It's important to call the event on the main app.
      // Some Plugin event listener should be registrated before the StageManager
      // object exists.
      GraphMind.i.dispatchEvent(new StageEvent(StageEvent.MINDMAP_CREATION_COMPLETE));
      isTreeUpdated = false;
      rootNode.selectNode();
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
      var sc:SiteConnection = SiteConnection.createSiteConnection(
        GraphMind.i.mindmapToolsPanel.node_connections_panel.connectFormURL.text,
        GraphMind.i.mindmapToolsPanel.node_connections_panel.connectFormUsername.text,
        GraphMind.i.mindmapToolsPanel.node_connections_panel.connectFormPassword.text
      );
      ConnectionManager.connectToSite(sc);
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
    
    public function loadAndAttachViewsList(node:NodeController, args:String, limit:int, offset:int, viewName:String, viewsInfo:ViewsCollection, onSuccess:Function):void {
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
      
      ConnectionManager.viewListLoad(loaderData);
      
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
        GraphMind.i.panelLoadDrupalItem.item_source.selectedItem as SiteConnection
      );
      nodeItemData.drupalID = parseInt(GraphMind.i.panelLoadDrupalItem.item_id.text);
      
      var loaderData:TempItemLoadData = new TempItemLoadData();
      loaderData.nodeItem = activeNode;
      loaderData.nodeItemData = nodeItemData;
      loaderData.success = onSuccess_DrupalItemLoaded;
      
      ConnectionManager.itemLoad(loaderData);
      
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
        var similarNode:NodeController = requestData.nodeItem.getEqualChild(nodeData, requestData.viewsData.parent.baseTable) as NodeController;
        if (similarNode) {
          similarNode.updateDrupalItem_result(nodeData);
          continue;
        }
        var nodeItem:NodeController = NodeFactory.createNode(
          nodeData,
          requestData.viewsData.parent.baseTable,
          requestData.viewsData.parent.source
        );
        requestData.nodeItem.addChildNode(nodeItem);
      }
    }
    
    public function onSuccess_DrupalItemLoaded(result:Object, requestData:TempItemLoadData):void {
      requestData.nodeItemData.data = result;
//      var nodeItem:NodeController = NodeFactory.createNode(
      var nodeItem:NodeController = NodeFactory.createNodeWithNodeData(requestData.nodeItemData);
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
    
    public function updateNodeAttribute(node:NodeController, attribute:String, value:String):void {
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
    public function removeNodeAttribute(node:NodeController, attribute:String):void {
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
      GraphMind.i.mindmapCanvas.dragAndDrop_shape.visible = false;
      GraphMind.i.mindmapCanvas.dragAndDrop_shape.x = -100;
      GraphMind.i.mindmapCanvas.dragAndDrop_shape.y = -100;
    }
    
    public function prepaireDragAndDrop():void {
      NodeController.isPrepairedNodeDragAndDrop = true;
    }
    
    public function openDragAndDrop(source:NodeController):void {
      NodeController.isPrepairedNodeDragAndDrop = false;
      NodeController.isNodeDragAndDrop = true;
      NodeController.dragAndDrop_sourceNode = source;
      GraphMind.i.mindmapCanvas.dragAndDrop_shape.visible = true;
      GraphMind.i.mindmapCanvas.dragAndDrop_shape.x = GraphMind.i.mindmapCanvas.desktop.mouseX - GraphMind.i.mindmapCanvas.dragAndDrop_shape.width / 2;
      GraphMind.i.mindmapCanvas.dragAndDrop_shape.y = GraphMind.i.mindmapCanvas.desktop.mouseY - GraphMind.i.mindmapCanvas.dragAndDrop_shape.height / 2;
      GraphMind.i.mindmapCanvas.dragAndDrop_shape.startDrag(false);
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
      NodeController.isNodeDragAndDrop = false;
      NodeController.isPrepairedNodeDragAndDrop = false;
      GraphMind.i.mindmapCanvas.dragAndDrop_shape.visible = false;
      NodeController.dragAndDrop_sourceNode = null;
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
      GraphMind.i.mindmapCanvas.desktop.setFocus();
      
      isDesktopDragged = true;
      
      _desktopDragInfo.oldVPos = GraphMind.i.mindmapCanvas.desktop_wrapper.mouseY;
      _desktopDragInfo.oldHPos = GraphMind.i.mindmapCanvas.desktop_wrapper.mouseX;
      _desktopDragInfo.oldScrollbarVPos = GraphMind.i.mindmapCanvas.desktop_wrapper.verticalScrollPosition;
      _desktopDragInfo.oldScrollbarHPos = GraphMind.i.mindmapCanvas.desktop_wrapper.horizontalScrollPosition;
    }
    
    protected function doNodeDragAndDrop():void {
      if (isDesktopDragged) {
        var deltaV:Number = GraphMind.i.mindmapCanvas.desktop_wrapper.mouseY - _desktopDragInfo.oldVPos;
        var deltaH:Number = GraphMind.i.mindmapCanvas.desktop_wrapper.mouseX - _desktopDragInfo.oldHPos;
        GraphMind.i.mindmapCanvas.desktop_wrapper.verticalScrollPosition   = _desktopDragInfo.oldScrollbarVPos - deltaV;
        GraphMind.i.mindmapCanvas.desktop_wrapper.horizontalScrollPosition = _desktopDragInfo.oldScrollbarHPos - deltaH;
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
      ConnectionManager.saveGraphMind(
        GraphMind.i.applicationManager.getHostNodeID(),
        mm,
        GraphMind.i.applicationManager.lastSaved,
        GraphMind.i.applicationManager.baseSiteConnection, 
        GraphMind.i.applicationManager._save_stage_saved
      );
      isTreeUpdated = false;
      return mm;
    }
    
    public function getTreeDrawer():TreeDrawer {
      return structureDrawer as TreeDrawer;
    }
    
    public function addNodeToStage(node:NodeController):void {
      structureDrawer.addUIElementToDisplayList(node.nodeView);
    }

	}
	
}