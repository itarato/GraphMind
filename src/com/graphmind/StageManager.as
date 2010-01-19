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
package com.graphmind
{
	import com.graphmind.data.NodeItemData;
	import com.graphmind.data.ViewsCollection;
	import com.graphmind.data.ViewsList;
	import com.graphmind.display.NodeItem;
	import com.graphmind.factory.NodeFactory;
	import com.graphmind.net.SiteConnection;
	import com.graphmind.temp.TempItemLoadData;
	import com.graphmind.temp.TempViewLoadData;
	import com.graphmind.util.DesktopDragInfo;
	import com.graphmind.util.Log;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.StageDisplayState;
	import flash.events.MouseEvent;
	import flash.ui.ContextMenu;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.Image;
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.events.ListEvent;
	import mx.rpc.events.ResultEvent;
	
	public class StageManager
	{
		private static var _instance:StageManager = null;
		[Bindable]
		public static var DEFAULT_DESKTOP_HEIGHT:int = 2000;
		// Flash Player 9 can handle maximum 2880 pixel width BitmapData:
		// http://livedocs.adobe.com/flex/3/langref/flash/display/BitmapData.html#BitmapData().
		[Bindable]
		public static var DEFAULT_DESKTOP_WIDTH:int = 2880;
		
		// @TODO select base node when it's ready
		// TODO add timer for normal stage refresh
		public var activeNode:NodeItem = null;
		public var baseNode:NodeItem   = null;
		
		public var dragAndDrop_sourceNode:NodeItem;
		public var isNodeDragAndDrop:Boolean = false;
		public var isPrepairedNodeDragAndDrop:Boolean = false;
		
		private var isDesktopDragged:Boolean = false;
		private var _desktopDragInfo:DesktopDragInfo = new DesktopDragInfo();
		
		[Bindable]
		public var isTreeUpdated:Boolean = false;
		[Bindable]
		public var selectedNodeData:ArrayCollection = new ArrayCollection();
		
		// Preview window.
		private var _previewBitmapData:BitmapData = new BitmapData(DEFAULT_DESKTOP_WIDTH, DEFAULT_DESKTOP_HEIGHT, true);
		private var _previewBitmap:Bitmap = new Bitmap(_previewBitmapData);
		private var _previewTimer:uint;
		
		// Mindmap stage redraw timer - performance reason
		private var _mindmapStageTimer:uint;
		
		
		/**
		 * Singleton pattern.
		 */
		public static function getInstance():StageManager {
			if (_instance == null) {
				_instance = new StageManager();
			}
			
			return _instance;
		}
		
		/**
		 * Initialize stage.
		 */
		public function init():void {
			// Scroll mindmap canvas to center
			GraphMind.instance.mindmapCanvas.desktop_wrapper.verticalScrollPosition = (GraphMind.instance.mindmapCanvas.desktop.height - GraphMind.instance.mindmapCanvas.desktop_wrapper.height) / 2;
			
			// Node title RTE editor's default color
			GraphMind.instance.mindmapToolsPanel.node_info_panel.nodeLabelRTE.colorPicker.selectedColor = 0x555555;
			
			// Preview window init
			_previewBitmap.width = 180;
			_previewBitmap.height = 120;
			GraphMind.instance.mindmapCanvas.previewWindow.addChild(_previewBitmap);
			
			// Remove base context menu items (not perfect, though)
			var cm:ContextMenu = new ContextMenu();
			cm.hideBuiltInItems();
			MovieClip(GraphMind.instance.systemManager).contextMenu = cm;
		}
		
		/**
		 * Load base node.
		 */
		public function loadBaseNode():void {
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
			var nodeItem:NodeItem = NodeFactory.createNode(
				{},
				NodeItemData.NODE,
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
				var importedBaseNode:NodeItem = ImportManager.getInstance().importMapFromString(baseNode, body);
				addNodeToStage(importedBaseNode);
				baseNode = importedBaseNode;
			} else {
				// New node
				addNodeToStage(nodeItem);
				baseNode = nodeItem;
			}
			
			redrawMindmapStage();
			isTreeUpdated = false;
			baseNode.selectNode();
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
			GraphMind.instance.mindmapCanvas.desktop.addChild(node);
			setMindmapUpdated();
			redrawMindmapStage();
			
			// HOOK
			PluginManager.callHook(NodeItem.HOOK_NODE_CREATED, {node: node});
		}
		
		/**
		 * Event for clicking on the view load panel.
		 */
		public function onClick_LoadViewsSubmitButton():void {
			loadAndAttachViewsList(
				activeNode,
				GraphMind.instance.panelLoadView.view_arguments.text,
				parseInt(GraphMind.instance.panelLoadView.view_limit.text),
				parseInt(GraphMind.instance.panelLoadView.view_offset.text),
				GraphMind.instance.panelLoadView.view_name.text,
				GraphMind.instance.panelLoadView.view_views_datagrid.selectedItem as ViewsCollection,
				onSuccess_DrupalViewsLoaded
			);
		}
		
		public function loadAndAttachViewsList(node:NodeItem, args:String, limit:int, offset:int, viewName:String, viewsInfo:ViewsCollection, onSuccess:Function):void {
			var viewsData:ViewsList = new ViewsList();
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
			var nodeItemData:NodeItemData = new NodeItemData(
				{},
				GraphMind.instance.panelLoadDrupalItem.item_type.selectedItem.data,
				GraphMind.instance.panelLoadDrupalItem.item_source.selectedItem as SiteConnection
			);
			nodeItemData.drupalID = parseInt(GraphMind.instance.panelLoadDrupalItem.item_id.text);
			
			var loaderData:TempItemLoadData = new TempItemLoadData();
			loaderData.nodeItem = activeNode;
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
				Alert.show('Result is empty.');
			}
			for each (var nodeData:Object in list) {
				// @TODO update or append checkbox for the panel?
				var similarNode:NodeItem = requestData.nodeItem.getEqualChild(nodeData, requestData.viewsData.parent.baseTable)
				if (similarNode) {
					similarNode.updateDrupalItem_result(nodeData, null);
					continue;
				}
				
				var nodeItemData:NodeItemData = new NodeItemData(
					nodeData, 
					requestData.viewsData.parent.baseTable, 
					requestData.viewsData.parent.source
				);
				var nodeItem:NodeItem = new NodeItem(nodeItemData);
				requestData.nodeItem.addChildNode(nodeItem);
			}
		}
		
		/**
		 * Create a new empty node and add to an existing node as a child.
		 * Call it for creating simple child nodes.
		 */
		public function createSimpleChildNode(parent:NodeItem):void {
			var node:NodeItem = NodeFactory.createNode({}, NodeItemData.NORMAL);
			parent.addChildNode(node);
			node.selectNode();
		}
		
		public function onSuccess_DrupalItemLoaded(result:Object, requestData:TempItemLoadData):void {
			requestData.nodeItemData.data = result;
			var nodeItem:NodeItem = new NodeItem(requestData.nodeItemData);
			requestData.nodeItem.addChildNode(nodeItem);
			nodeItem.selectNode();
		}
		
		/**
		 * Refresh the whole mindmap stage.
		 * 
		 * Since it uses time deferring we can't decide on whether to refresh subtree or the whole tree.
		 */
		public function redrawMindmapStage():void {
			if (!baseNode) return;
			
			// Very little time should be enough for increasing performance
			// It prevents bulk refreshes (eg. on massive node creation)
			clearTimeout(_mindmapStageTimer);
			_mindmapStageTimer = setTimeout(function():void {
				// Refresh the whole tree.
				baseNode.x = 4;
				baseNode.y = DEFAULT_DESKTOP_HEIGHT >> 1;
				baseNode._redrawSubtree();
				redrawPreviewWindow();
			}, 10);
		}
		
		public function onClick_SaveGraphmindButton():void {
			GraphMindManager.getInstance().save();
		}
		
		public function onClick_DumpFreemindXMLButton():void {
			GraphMind.instance.mindmapToolsPanel.node_save_panel.freemindExportTextarea.text = GraphMindManager.getInstance().exportToFreeMindFormat();
		}
		
		public function onClick_NodeAttributeAddOrUpdateButton():void {
			updateNodeAttribute(
				activeNode,
				GraphMind.instance.mindmapToolsPanel.node_attributes_panel.attributes_update_param.text,
				GraphMind.instance.mindmapToolsPanel.node_attributes_panel.attributes_update_value.text
			);
		}
		
		public function updateNodeAttribute(node:NodeItem, attribute:String, value:String):void {
			if (!node || !attribute) return;
			
			node.addData(attribute, value);
			node.selectNode();
			
			GraphMind.instance.mindmapToolsPanel.node_attributes_panel.attributes_update_param.text = GraphMind.instance.mindmapToolsPanel.node_attributes_panel.attributes_update_value.text = '';
		}
		
		public function onClick_NodeAttributeRemoveButton():void {
			removeNodeAttribute(activeNode, GraphMind.instance.mindmapToolsPanel.node_attributes_panel.attributes_update_param.text);
		}
		
		/**
		 * Remove a node's attribute.
		 */
		public function removeNodeAttribute(node:NodeItem, attribute:String):void {
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
		
		public function openDragAndDrop(source:NodeItem):void {
			isPrepairedNodeDragAndDrop = false;
			isNodeDragAndDrop = true;
			StageManager.getInstance().dragAndDrop_sourceNode = source;
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
			StageManager.getInstance().isDesktopDragged = false;
		}
		
		public function onClick_RTESaveButton():void {
			if (!isActiveNodeExists()) return;
			
			activeNode.setTitle(GraphMind.instance.mindmapToolsPanel.node_info_panel.nodeLabelRTE.htmlText);
		}
		
		public function onClick_SaveNodeLink():void {
			if (!isActiveNodeExists()) return;
			
			activeNode.setLink(GraphMind.instance.mindmapToolsPanel.node_info_panel.link.text);
		}
		
		/**
		 * Check if there is any node selected.
		 */
		public function isActiveNodeExists(showError:Boolean = false):Boolean {
			if (!activeNode) {
				if (showError) Alert.show("Please, select a node first.", "Graphmind");
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
			
			activeNode.toggleCloud(true);
		}
		
		/**
		 * Upadte preview window.
		 * Don't call it unless it's really necessary.
		 * Calling redrawMindmapStage() will call it.
		 */
		public function redrawPreviewWindow():void {
			// Timeout can help on performance
			clearTimeout(_previewTimer);
			_previewTimer = setTimeout(function():void {
				_previewBitmapData = new BitmapData(StageManager.DEFAULT_DESKTOP_WIDTH, StageManager.DEFAULT_DESKTOP_HEIGHT, false, 0x333333);
				_previewBitmap.bitmapData = _previewBitmapData;
				_previewBitmapData.draw(GraphMind.instance.mindmapCanvas.desktop_cloud);
				_previewBitmapData.draw(GraphMind.instance.mindmapCanvas.desktop);
				Log.debug('Preview window refreshed.');
			}, 400);
		}
		
		/**
		 * Indicates mindmap has changed -> needs saving.
		 */
		public function setMindmapUpdated():void {
			isTreeUpdated = true;
		}
				
	}
}
