/**
 * @Class StageManager
 * 
 * Intention: Provides a top level access to the UI and handles UI related tasks
 * 
 * Responsibilities:
 *  - give access to UI
 *  - manage UI changes
 *    - state changes
 *    - redraw stage
 */
package com.graphmind {
	
	import com.graphmind.data.NodeData;
	import com.graphmind.data.NodeType;
	import com.graphmind.data.ViewsCollection;
	import com.graphmind.data.ViewsServicesParamsVO;
	import com.graphmind.display.TreeNodeController;
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
	import flash.events.MouseEvent;
	import flash.ui.ContextMenu;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Image;
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.events.ListEvent;
	import mx.rpc.events.ResultEvent;
	
	public class TreeManager extends AbstractStageManager {
		
		private static var _instance:TreeManager = null;

		[Bindable]
		public static var DEFAULT_DESKTOP_HEIGHT:int = 2000;
		[Bindable]
		public static var DEFAULT_DESKTOP_WIDTH:int = 3000;
		
		public static var ROOT_NODE_IS_READY:String = 'root_node_is_ready';
		
		// @TODO select base node when it's ready
		// @TODO add timer for normal stage refresh
		public var rootNode:TreeNodeController   = null;
		
		public var dragAndDrop_sourceNode:TreeNodeController;
		public var isNodeDragAndDrop:Boolean = false;
		public var isPrepairedNodeDragAndDrop:Boolean = false;
		
		private var isDesktopDragged:Boolean = false;
		private var _desktopDragInfo:DesktopDragInfo = new DesktopDragInfo();
		
		[Bindable]
		public var isTreeUpdated:Boolean = false;
		[Bindable]
		public var selectedNodeData:ArrayCollection = new ArrayCollection();
		
		/**
		 * Don't call it by hand. It's a singleton pattern.
		 */
		public function TreeManager():void {
			super();
			
//			addEventListener(ROOT_NODE_IS_READY, onRootNodeIsReady);
		}
		
		/**
		 * Singleton pattern.
		 */
		public static function getInstance():TreeManager {
			if (_instance == null) {
				_instance = new TreeManager();
			}
			
			return _instance;
		}
		
		/**
		 * Initialize stage.
		 */
		public override function init(structureDrawer:StructureDrawer):void {
			this.structureDrawer = structureDrawer;
			
			// Scroll mindmap canvas to center
			GraphMind.instance.mindmapCanvas.desktop_wrapper.verticalScrollPosition = (GraphMind.instance.mindmapCanvas.desktop.height - GraphMind.instance.mindmapCanvas.desktop_wrapper.height) / 2;
			
			// Node title RTE editor's default color
			GraphMind.instance.mindmapToolsPanel.node_info_panel.nodeLabelRTE.colorPicker.selectedColor = 0x555555;
			
			// Remove base context menu items (not perfect, though)
			var cm:ContextMenu = new ContextMenu();
			cm.hideBuiltInItems();
			MovieClip(GraphMind.instance.systemManager).contextMenu = cm;
			
			this.addEventListener(NodeEvent.UPDATE_GRAPHICS, function(event:NodeEvent):void{
				redrawMindmapStage();
			});
//			this.structureDrawer.addEventListener(StageEvent.MINDMAP_UPDATED, onMindmapUpdated);
		}
		
		/**
		 * Load base node.
		 */
		public override function loadBaseNode():void {
			ConnectionManager.getInstance().nodeLoad(
				GraphMindManager.getInstance().getHostNodeID(), 
				GraphMindManager.getInstance().baseSiteConnection, 
				onSuccess_BaseNodeLoaded
			);
		}
		
		/**
		 * Load base node - stage 2.
		 */
		private function onSuccess_BaseNodeLoaded(result:ResultEvent):void {
			GraphMindManager.getInstance().setEditMode(result.result.graphmindEditable == '1');
			
			// ! Removed original data object: result.result.
			// This caused a mailformed export string.
			var rootNode:TreeNodeController = NodeFactory.createNode(
				{},
				NodeType.NODE,
				SiteConnection.getBaseSiteConnection(),
				result.result.title
			);
			
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
				var importedBaseNode:TreeNodeController = TreeImportManager.getInstance().importMapFromString(rootNode, body);
				addNodeToStage(importedBaseNode.getUI().getUIComponent());
				this.rootNode = importedBaseNode;
			} else {
				// New node
				addNodeToStage(rootNode.getUI().getUIComponent());
				this.rootNode = rootNode;
			}
			
			dispatchEvent(new NodeEvent(NodeEvent.UPDATE_GRAPHICS, rootNode));
	    dispatchEvent(new StageEvent(StageEvent.MINDMAP_CREATION_COMPLETE));
			isTreeUpdated = false;
			rootNode.selectNode();
		}		
				
		/**
		 * Select a views from datagrid on the views load panel.
		 */
		public function onItemClick_LoadViewDataGrid(event:ListEvent):void {
			var selectedViewsCollection:ViewsCollection = event.itemRenderer.data as ViewsCollection;
			
			GraphMind.instance.panelLoadView.view_name.text = selectedViewsCollection.name;
		}
		
		/**
		 * Event handler for
		 */
		public function onClick_AddNewSiteConnectionButton():void {
			var sc:SiteConnection = SiteConnection.createSiteConnection(
				GraphMind.instance.mindmapToolsPanel.node_connections_panel.connectFormURL.text,
				GraphMind.instance.mindmapToolsPanel.node_connections_panel.connectFormUsername.text,
				GraphMind.instance.mindmapToolsPanel.node_connections_panel.connectFormPassword.text
			);
			ConnectionManager.getInstance().connectToSite(sc);
		}
				
		/**
		 * Add new element to the editor canvas.
		 */
		public function addNodeToStage(node:UIComponent):void {
			structureDrawer.addUIElementToDisplayList(node);
			setMindmapUpdated();
			this.dispatchEvent(new NodeEvent(NodeEvent.UPDATE_GRAPHICS, node as TreeNodeController));
			
			// HOOK
			PluginManager.callHook(TreeNodeController.HOOK_NODE_CREATED, {node: node});
		}
		
		/**
		 * Event for clicking on the view load panel.
		 */
		public function onClick_LoadViewsSubmitButton():void {
			loadAndAttachViewsList(
				getActiveTreeNodeController(),
				GraphMind.instance.panelLoadView.view_arguments.text,
				parseInt(GraphMind.instance.panelLoadView.view_limit.text),
				parseInt(GraphMind.instance.panelLoadView.view_offset.text),
				GraphMind.instance.panelLoadView.view_name.text,
				GraphMind.instance.panelLoadView.view_views_datagrid.selectedItem as ViewsCollection,
				onSuccess_DrupalViewsLoaded
			);
		}
		
		public function loadAndAttachViewsList(node:TreeNodeController, args:String, limit:int, offset:int, viewName:String, viewsInfo:ViewsCollection, onSuccess:Function):void {
			var viewsData:ViewsServicesParamsVO = new ViewsServicesParamsVO();
			viewsData.args   	= args;
			// Fields are not supported in Services for D6
			// viewsData.fields 	= stage.view_fields.text;
			viewsData.limit     = limit;
			viewsData.offset    = offset;
			viewsData.view_name = viewName;
			viewsData.parent    = viewsInfo;
			
			var loaderData:TempViewLoadData = new TempViewLoadData();
			loaderData.viewsData = viewsData;
			loaderData.nodeItem = node;
			loaderData.success  = onSuccess;
			
			ConnectionManager.getInstance().viewListLoad(loaderData);
			
			GraphMind.instance.currentState = '';
		}
		
		/**
		 * Event on cancelling views load panel.
		 */
		public function onClick_LoadViewsCancelButton():void {
			GraphMind.instance.currentState = '';
		}
		
		/**
		 * Event on submitting item loading panel.
		 */
		public function onClick_LoadItemSubmit():void {
			var nodeItemData:NodeData = new NodeData(
				{},
				GraphMind.instance.panelLoadDrupalItem.item_type.selectedItem.data,
				GraphMind.instance.panelLoadDrupalItem.item_source.selectedItem as SiteConnection
			);
			nodeItemData.drupalID = parseInt(GraphMind.instance.panelLoadDrupalItem.item_id.text);
			
			var loaderData:TempItemLoadData = new TempItemLoadData();
			loaderData.nodeItem = getActiveTreeNodeController();
			loaderData.nodeItemData = nodeItemData;
			loaderData.success = onSuccess_DrupalItemLoaded;
			
			ConnectionManager.getInstance().itemLoad(loaderData);
			
			GraphMind.instance.currentState = '';
		}
		
		/**
		 * Event for on item loader cancel.
		 */
		public function onClick_LoadItemCancel():void {
			GraphMind.instance.currentState = '';
		}
		
		public function onSuccess_DrupalViewsLoaded(list:Array, requestData:TempViewLoadData):void {
			if (list.length == 0) {
				OSD.show('Result is empty.', OSD.WARNING);
			}
			for each (var nodeData:Object in list) {
				// @TODO update or append checkbox for the panel?
				var similarNode:TreeNodeController = requestData.nodeItem.getEqualChild(nodeData, requestData.viewsData.parent.baseTable) as TreeNodeController;
				if (similarNode) {
					similarNode.updateDrupalItem_result(nodeData, null);
					continue;
				}
				
				var nodeItemData:NodeData = new NodeData(
					nodeData, 
					requestData.viewsData.parent.baseTable, 
					requestData.viewsData.parent.source
				);
				var nodeItem:TreeNodeController = new TreeNodeController(nodeItemData);
				requestData.nodeItem.addChildNodeWithStageRefresh(nodeItem);
			}
		}
		
		/**
		 * Create a new empty node and add to an existing node as a child.
		 * Call it for creating simple child nodes.
		 */
		public function createSimpleChildNode(parent:TreeNodeController):void {
			var node:TreeNodeController = NodeFactory.createNode({}, NodeType.NORMAL);
			parent.addChildNodeWithStageRefresh(node);
			node.selectNode();
		}
		
		public function onSuccess_DrupalItemLoaded(result:Object, requestData:TempItemLoadData):void {
			requestData.nodeItemData.data = result;
			var nodeItem:TreeNodeController = new TreeNodeController(requestData.nodeItemData);
			requestData.nodeItem.addChildNodeWithStageRefresh(nodeItem);
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
			GraphMind.instance.mindmapToolsPanel.node_save_panel.freemindExportTextarea.text = exportToFreeMindFormat();
		}
		
		public function onClick_NodeAttributeAddOrUpdateButton():void {
			updateNodeAttribute(
				getActiveTreeNodeController(),
				GraphMind.instance.mindmapToolsPanel.node_attributes_panel.attributes_update_param.text,
				GraphMind.instance.mindmapToolsPanel.node_attributes_panel.attributes_update_value.text
			);
		}
		
		public function updateNodeAttribute(node:TreeNodeController, attribute:String, value:String):void {
			if (!node || !attribute) return;
			
			node.addData(attribute, value);
			node.selectNode();
			
			GraphMind.instance.mindmapToolsPanel.node_attributes_panel.attributes_update_param.text = GraphMind.instance.mindmapToolsPanel.node_attributes_panel.attributes_update_value.text = '';
		}
		
		public function onClick_NodeAttributeRemoveButton():void {
			removeNodeAttribute(getActiveTreeNodeController(), GraphMind.instance.mindmapToolsPanel.node_attributes_panel.attributes_update_param.text);
		}
		
		/**
		 * Remove a node's attribute.
		 */
		public function removeNodeAttribute(node:TreeNodeController, attribute:String):void {
			if (!node || attribute.length == 0) return;
			
			node.deleteData(attribute);
			node.selectNode();
			
			GraphMind.instance.mindmapToolsPanel.node_attributes_panel.attributes_update_param.text = GraphMind.instance.mindmapToolsPanel.node_attributes_panel.attributes_update_value.text = '';
		}
		
		public function onClick_FullscreenButton():void {
			toggleFullscreenMode();
		}
		
		/**
		 * Toggle fullscreen mode.
		 */
		private function toggleFullscreenMode():void {
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
			GraphMind.instance.dragAndDrop_shape.visible = false;
			GraphMind.instance.dragAndDrop_shape.x = -GraphMind.instance.dragAndDrop_shape.width;
			GraphMind.instance.dragAndDrop_shape.y = -GraphMind.instance.dragAndDrop_shape.height;
		}
		
		public function prepaireDragAndDrop():void {
			isPrepairedNodeDragAndDrop = true;
		}
		
		public function openDragAndDrop(source:TreeNodeController):void {
			isPrepairedNodeDragAndDrop = false;
			isNodeDragAndDrop = true;
			TreeManager.getInstance().dragAndDrop_sourceNode = source;
			GraphMind.instance.dragAndDrop_shape.visible = true;
			GraphMind.instance.dragAndDrop_shape.x = GraphMind.instance.mouseX - GraphMind.instance.dragAndDrop_shape.width / 2;
			GraphMind.instance.dragAndDrop_shape.y = GraphMind.instance.mouseY - GraphMind.instance.dragAndDrop_shape.height / 2;
			GraphMind.instance.dragAndDrop_shape.startDrag(false);
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
		private function closeNodeDragAndDrop():void {
			isNodeDragAndDrop = false;
			isPrepairedNodeDragAndDrop = false;
			GraphMind.instance.dragAndDrop_shape.visible = false;
			dragAndDrop_sourceNode = null;
		}
		
		/**
		 * Finishes drag and drop session for the mindmap area.
		 */
		private function closeDesktopDragAndDrop():void {
			TreeManager.getInstance().isDesktopDragged = false;
		}
		
		public function onClick_RTESaveButton():void {
			if (!isActiveNodeExists()) return;
			
			getActiveTreeNodeController().setTitle(GraphMind.instance.mindmapToolsPanel.node_info_panel.nodeLabelRTE.htmlText);
		}
		
		public function onClick_SaveNodeLink():void {
			if (!isActiveNodeExists()) return;
			
			getActiveTreeNodeController().setLink(GraphMind.instance.mindmapToolsPanel.node_info_panel.link.text);
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
			
			getActiveTreeNodeController().addIcon(icon.source.toString());
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
		private function startNodeDragAndDrop():void {
			GraphMind.instance.mindmapCanvas.desktop.setFocus();
			
			isDesktopDragged = true;
			
			_desktopDragInfo.oldVPos = GraphMind.instance.mindmapCanvas.desktop_wrapper.mouseY;
			_desktopDragInfo.oldHPos = GraphMind.instance.mindmapCanvas.desktop_wrapper.mouseX;
			_desktopDragInfo.oldScrollbarVPos = GraphMind.instance.mindmapCanvas.desktop_wrapper.verticalScrollPosition;
			_desktopDragInfo.oldScrollbarHPos = GraphMind.instance.mindmapCanvas.desktop_wrapper.horizontalScrollPosition;
		}
		
		private function doNodeDragAndDrop():void {
			if (isDesktopDragged) {
				var deltaV:Number = GraphMind.instance.mindmapCanvas.desktop_wrapper.mouseY - _desktopDragInfo.oldVPos;
				var deltaH:Number = GraphMind.instance.mindmapCanvas.desktop_wrapper.mouseX - _desktopDragInfo.oldHPos;
				GraphMind.instance.mindmapCanvas.desktop_wrapper.verticalScrollPosition   = _desktopDragInfo.oldScrollbarVPos - deltaV;
				GraphMind.instance.mindmapCanvas.desktop_wrapper.horizontalScrollPosition = _desktopDragInfo.oldScrollbarHPos - deltaH;
			}
		}
		
		public function onClick_ToggleCloudButton():void {
			if (!isActiveNodeExists()) return;
			
			getActiveTreeNodeController().toggleCloud();
		}
		
		/**
		 * Indicates mindmap has changed -> needs saving.
		 */
		public function setMindmapUpdated():void {
			isTreeUpdated = true;
		}
		
		/**
		 * Export work to FreeMind XML format
		 * @return string
		 */
		public function exportToFreeMindFormat():String {
			return '<map version="0.9.0">' + "\n" + 
				TreeManager.getInstance().rootNode.exportToFreeMindFormat() + 
				'</map>' + "\n";
		}
		
		/**
		 * Save work into host node
		 */
		public function save():String {
			var mm:String = exportToFreeMindFormat();
			ConnectionManager.getInstance().saveGraphMind(
				GraphMindManager.getInstance().getHostNodeID(),
				mm,
				GraphMindManager.getInstance().lastSaved,
				GraphMindManager.getInstance().baseSiteConnection, 
				GraphMindManager.getInstance()._save_stage_saved
			);
			TreeManager.getInstance().isTreeUpdated = false;
			return mm;
		}
		
		public function getTreeDrawer():TreeDrawer {
			return structureDrawer as TreeDrawer;
		}
		
    public function getActiveTreeNodeController():TreeNodeController {
      return activeNode as TreeNodeController;
    }
				
	}
	
}
