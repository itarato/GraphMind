package com.graphmind
{
	import com.graphmind.data.NodeItemData;
	import com.graphmind.data.ViewsCollection;
	import com.graphmind.data.ViewsList;
	import com.graphmind.display.NodeItem;
	import com.graphmind.net.SiteConnection;
	import com.graphmind.temp.TempItemLoadData;
	import com.graphmind.temp.TempViewLoadData;
	import com.graphmind.util.DesktopDragInfo;
	import com.graphmind.util.Log;
	
	import flash.display.StageDisplayState;
	import flash.events.MouseEvent;
	
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
		
		// The stage object
		private var _application:GraphMind = null;
		public var lastSelectedNode:NodeItem = null;
		public var baseNode:NodeItem = null;
		public var dragAndDrop_sourceNodeItem:NodeItem;
		public var isDragAndDrop:Boolean = false;
		public var isPrepairedDragAndDrop:Boolean = false;
		public var isDesktopDragged:Boolean = false;
		private var _desktopDragInfo:DesktopDragInfo = new DesktopDragInfo();
		[Bindable]
		public var isChanged:Boolean = false;
		[Bindable]
		public var selectedNodeData:ArrayCollection = new ArrayCollection();
		
		public function StageManager() {
		}
		
		public static function getInstance():StageManager {
			if (_instance == null) {
				_instance = new StageManager();
			}
			
			return _instance;
		}
		
		/**
		 * Initialize stage.
		 */
		public function initStage(application:GraphMind):void {
			this._application = application;
			
			// Scroll mindmap canvas to center
			_application.desktop_wrapper.verticalScrollPosition = (stage.desktop.height - stage.desktop_wrapper.height) / 2;
			
			// Node title RTE editor's default color
			stage.nodeLabelRTE.colorPicker.selectedColor = 0x555555;
		}
		
		/**
		 * Load base node.
		 */
		public function loadBaseNode():void {
			ConnectionManager.getInstance().nodeLoad(
				GraphMindManager.getInstance().getHostNodeID(), 
				GraphMindManager.getInstance().baseSiteConnection, 
				_loadBaseNode_stage_node_loaded
			);
		}
		
		/**
		 * Load base node - stage 2.
		 */
		private function _loadBaseNode_stage_node_loaded(result:ResultEvent):void {
			// ! Removed original data object: result.result.
			// This caused a mailformed export string.
			var itemData:NodeItemData = new NodeItemData({}, NodeItemData.NODE, GraphMindManager.getInstance().baseSiteConnection);
			itemData.type = NodeItemData.NODE;
			itemData.title = result.result.title;
			var nodeItem:NodeItem = new NodeItem(itemData);
			
			// @WTF sometimes body_value is the right value, sometimes not
			var body:String = result.result.body.toString();
			if (body.length > 0) {
				var importedBaseNode:NodeItem = ImportManager.getInstance().importMapFromString(baseNode, body);
				addChildToStage(importedBaseNode);
				baseNode = importedBaseNode;
			} else {
				addChildToStage(nodeItem);
				baseNode = nodeItem;
			}
			
			refreshNodePositions();
		}		
				
		public function onDataGridItemClick_baseState(event:ListEvent):void {
			if (event.itemRenderer.data is ViewsCollection) {
				(event.itemRenderer.data as ViewsCollection).handleDataGridSelection();
			} else {
				Log.warning('onDataGridItemClick_baseState event is not ViewsCollection.');
			}
		}
		
		/**
		 * Select a views from datagrid on the views load panel.
		 */
		public function onDataGridItemClick_loadViewState(event:ListEvent):void {
			Log.info('onDataGridItemClick_loadViewState');
			var selectedViewsCollection:ViewsCollection = event.itemRenderer.data as ViewsCollection;
			
			stage.view_name.text = selectedViewsCollection.name;
		}
		
		/**
		 * Event handler for
		 */
		public function onConnectFormSubmit():void {
			var sc:SiteConnection = SiteConnection.createSiteConnection(
				_application.connectFormURL.text,
				_application.connectFormUsername.text,
				_application.connectFormPassword.text
			);
			ConnectionManager.getInstance().connectToSite(sc);
		}
		
		/**
		 * Add new element to the editor canvas.
		 */
		public function addChildToStage(element:UIComponent):void {
			_application.desktop.addChild(element);
			refreshNodePositions();
		}
		
		/**
		 * Getter for stage object.
		 * @return GraphMind
		 */
		public function get stage():GraphMind {
			return this._application;
		}
		
		/**
		 * Event for clicking on the view load panel.
		 */
		public function onLoadViewSubmitClick(event:MouseEvent):void {
			//var viewsList:ViewsList = new ViewsList();
			var viewsData:ViewsList = new ViewsList();
			viewsData.args   	= stage.view_arguments.text;
			viewsData.fields 	= stage.view_fields.text;
			viewsData.limit     = parseInt(stage.view_limit.text);
			viewsData.offset    = parseInt(stage.view_offset.text);
			viewsData.view_name = stage.view_name.text;
			viewsData.parent    = stage.view_views_datagrid.selectedItem as ViewsCollection;
			
			var loaderData:TempViewLoadData = new TempViewLoadData();
			loaderData.viewsData = viewsData;
			loaderData.nodeItem = lastSelectedNode;
			loaderData.success  = onViewsItemsLoadSuccess;
			
			ConnectionManager.getInstance().viewListLoad(loaderData);
			
			stage.currentState = '';
		}
		
		/**
		 * Event on cancelling views load panel.
		 */
		public function onLoadViewCancelClick(event:MouseEvent):void {
			stage.currentState = '';
		}
		
		/**
		 * Event on submitting item loading panel.
		 */
		public function onLoadItemSubmitClick(event:MouseEvent):void {
			var nodeItemData:NodeItemData = new NodeItemData(
				{},
				stage.item_type.selectedItem.data,
				stage.item_source.selectedItem as SiteConnection
			);
			nodeItemData.drupalID = parseInt(stage.item_id.text);
			
			var loaderData:TempItemLoadData = new TempItemLoadData();
			loaderData.nodeItem = lastSelectedNode;
			loaderData.nodeItemData = nodeItemData;
			loaderData.success = onItemLoadSuccess;
			
			ConnectionManager.getInstance().itemLoad(loaderData);
			
			stage.currentState = '';
		}
		
		/**
		 * Event for on item loader cancel.
		 */
		public function onLoadItemCancelClick(event:MouseEvent):void {
			stage.currentState = '';
		}
		
		public function onViewsItemsLoadSuccess(list:Array, requestData:TempViewLoadData):void {
			if (list.length == 0) {
				Alert.show('Zero result.');
			}
			for each (var nodeData:Object in list) {
				var nodeItemData:NodeItemData = new NodeItemData(
					nodeData, 
					requestData.viewsData.parent.baseTable, 
					requestData.viewsData.parent.source
				);
				var nodeItem:NodeItem = new NodeItem(nodeItemData);
				requestData.nodeItem.addNodeChild(nodeItem);
			}
		}
		
		public function onNewNormalNodeClick(parent:NodeItem):void {
			var nodeItemData:NodeItemData = new NodeItemData({}, NodeItemData.NORMAL, SiteConnection.createSiteConnection());
			var nodeItem:NodeItem = new NodeItem(nodeItemData);
			parent.addNodeChild(nodeItem);
			nodeItem.selectNode();
		}
		
		public function onItemLoadSuccess(result:Object, requestData:TempItemLoadData):void {
			requestData.nodeItemData.data = result;
			var nodeItem:NodeItem = new NodeItem(requestData.nodeItemData);
			requestData.nodeItem.addNodeChild(nodeItem);
			nodeItem.selectNode();
		}
		
		public function refreshNodePositions():void {
			if (!baseNode) return;
			baseNode.x = 0;
			baseNode.y = DEFAULT_DESKTOP_HEIGHT >> 1;
			baseNode.refreshChildNodePosition();
		}
		
		public function onSaveClick():void {
			GraphMindManager.getInstance().save();
		}
		
		public function onDumpClick():void {
			stage.freemindExportTextarea.text = GraphMindManager.getInstance().exportToFreeMindFormat();
		}
		
		public function onExportClick():void {
			var mm:String = GraphMindManager.getInstance().exportToFreeMindFormat();
			Alert.show('Implement later');
		}
		
		public function onAddOrUpdateClick(event:MouseEvent):void {
			if (!lastSelectedNode) baseNode.selectNode();
			
			lastSelectedNode.data[stage.attributes_update_param.text] = stage.attributes_update_value.text;
			lastSelectedNode.selectNode();
			
			stage.attributes_update_param.text = stage.attributes_update_value.text = '';
		}
		
		public function onRemoveAttributeClick(event:MouseEvent):void {
			if (!lastSelectedNode || stage.attributes_update_param.text.length == 0) return;
			
			lastSelectedNode.dataDelete(stage.attributes_update_param.text);
			lastSelectedNode.selectNode();
			
			stage.attributes_update_param.text = stage.attributes_update_value.text = '';
		}
		
		public function toggleFullScreen():void {
			try {
				
				switch (Application.application.stage.displayState) {
					case StageDisplayState.FULL_SCREEN:
						Application.application.stage.displayState = StageDisplayState.NORMAL;
						break;
					case StageDisplayState.NORMAL:
						Application.application.stage.displayState = StageDisplayState.FULL_SCREEN;
						break;
				}
			} catch (e:Error) {
				
			}
		}
		
		public function onDragAndDropImageMouseUp(event:MouseEvent):void {
			stage.dragAndDrop_shape.visible = false;
			stage.dragAndDrop_shape.x = -stage.dragAndDrop_shape.width;
			stage.dragAndDrop_shape.y = -stage.dragAndDrop_shape.height;
		}
		
		public function prepaireDragAndDrop():void {
			isPrepairedDragAndDrop = true;
		}
		
		public function openDragAndDrop(source:NodeItem):void {
			isPrepairedDragAndDrop = false;
			isDragAndDrop = true;
			StageManager.getInstance().dragAndDrop_sourceNodeItem = source;
			StageManager.getInstance().stage.dragAndDrop_shape.visible = true;
			StageManager.getInstance().stage.dragAndDrop_shape.x = StageManager.getInstance().stage.mouseX - StageManager.getInstance().stage.dragAndDrop_shape.width / 2;
			StageManager.getInstance().stage.dragAndDrop_shape.y = StageManager.getInstance().stage.mouseY - StageManager.getInstance().stage.dragAndDrop_shape.height / 2;
			StageManager.getInstance().stage.dragAndDrop_shape.startDrag(false);
		}
		
		public function closeDragAndDrop():void {
			isDragAndDrop = false;
			isPrepairedDragAndDrop = false;
			stage.dragAndDrop_shape.visible = false;
			dragAndDrop_sourceNodeItem = null;
		}
		
		public function onNodeLabelRTESave():void {
			if (!checkLastSelectedNodeIsExists()) return;
			
			lastSelectedNode.title = stage.nodeLabelRTE.htmlText;
		}
		
		public function onSaveLink():void {
			if (!checkLastSelectedNodeIsExists()) return;
			
			lastSelectedNode.link = stage.link.text;
		}
		
		public function checkLastSelectedNodeIsExists():Boolean {
			if (!lastSelectedNode) {
				Alert.show("Please, select a node first.", "Graphmind");
				return false;
			}
			
			return true;
		}
		
		public function onIconClick(event:MouseEvent):void {
			if (!checkLastSelectedNodeIsExists()) return;
			
			var source:String = (event.currentTarget as Image).source.toString();
			lastSelectedNode.addIcon(source);
			lastSelectedNode.refactorNodeBody();
			lastSelectedNode.refreshParentTree();
		}
		
		public function onDragDesktopStart():void {
			isDesktopDragged = true;
			_desktopDragInfo.oldVPos = stage.desktop_wrapper.mouseY;
			_desktopDragInfo.oldHPos = stage.desktop_wrapper.mouseX;
			_desktopDragInfo.oldScrollbarVPos = stage.desktop_wrapper.verticalScrollPosition;
			_desktopDragInfo.oldScrollbarHPos = stage.desktop_wrapper.horizontalScrollPosition;
		}
		
		public function onDragDesktop(event:MouseEvent):void {
			if (isDesktopDragged) {
				var deltaV:Number = stage.desktop_wrapper.mouseY - _desktopDragInfo.oldVPos;
				var deltaH:Number = stage.desktop_wrapper.mouseX - _desktopDragInfo.oldHPos;
				stage.desktop_wrapper.verticalScrollPosition   = _desktopDragInfo.oldScrollbarVPos - deltaV;
				stage.desktop_wrapper.horizontalScrollPosition = _desktopDragInfo.oldScrollbarHPos - deltaH;
			}
		}
		
		public function onToggleCloudClick():void {
			if (!checkLastSelectedNodeIsExists()) return;
			
			lastSelectedNode.toggleCloud(true);
		}
	}
}
