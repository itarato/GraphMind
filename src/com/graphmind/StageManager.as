package com.graphmind
{
	import com.graphmind.data.NodeItemData;
	import com.graphmind.data.ViewsCollection;
	import com.graphmind.data.ViewsList;
	import com.graphmind.display.NodeItem;
	import com.graphmind.net.SiteConnection;
	import com.graphmind.temp.TempItemLoadData;
	import com.graphmind.temp.TempViewLoadData;
	import com.graphmind.util.Log;
	
	import flash.display.StageDisplayState;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.events.ListEvent;
	import mx.rpc.events.ResultEvent;
	
	public class StageManager
	{
		private static var _instance:StageManager = null;
		
		public static var icons:Array = [
			"Mail", "down", "forward", "help", "password", "attach", "edit", 
			"freemind_butterfly", "hourglass", "pencil", "back", "encrypted", 
			"full-0", "idea", "penguin", "bell", "family", "full-1", "info", 
			"prepare", "bookmark", "fema", "full-2", "kaddressbook", "redo", 
			"broken-line", "female1", "full-3", "kmail", "smiley-angry", "button_cancel", 
			"female2", "full-4", "knotify", "smiley-neutral", "button_ok", "flag-black", 
			"full-5", "korn", "smiley-oh", "calendar", "flag-blue", "full-6", "ksmiletris", 
			"smily_bad", "clanbomber", "flag-green", "full-7", "launch", "stop-sign", 
			"clock", "flag-orange", "full-8", "licq", "stop", "clock2", "flag-pink", 
			"full-9", "list", "up", "closed", "flag-yellow", "go", " male1", "wizard", 
			"decrypted", "flag", "gohome", "male2", "xmag", "desktop_new", "folder", 
			"group", "messagebox_warning", "yes"
		];
		
		// The stage object
		private var _application:GraphMind = null;
		public var lastSelectedNode:NodeItem = null;
		public var baseNode:NodeItem = null;
		public var dragAndDrop_sourceNodeItem:NodeItem;
		public var isDragAndDrop:Boolean = false;
		public var isPrepairedDragAndDrop:Boolean = false;
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
			
			//this._application.addEventListener(StateChangeEvent.CURRENT_STATE_CHANGE, onCurrentStateChange);
			
			// Scroll mindmap canvas to center
			_application.desktop_wrapper.verticalScrollPosition = 800;
			stage.nodeLabelRTE.colorPicker.selectedColor = 0xFFFFFF;
			stage.nodeLabelRTE.textArea.setStyle('backgroundColor', '#647177');
			stage.nodeLabelRTE.textArea.setStyle('color', '#FFFFFF');
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
			baseNode.y = stage.desktop.height >> 1;
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
			//var fr:FileReference = new FileReference();
			//fr.save(mm);
			//fr.sa
			//fr.c
			//var f
			//var fr:FileReference = new FileReference();
			//fr.browse();
			//FileReference().
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
	}
}