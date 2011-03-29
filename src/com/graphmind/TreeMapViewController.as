package com.graphmind {

	import com.graphmind.display.NodeViewController;
	import com.graphmind.event.EventCenter;
	import com.graphmind.event.EventCenterEvent;
	import com.graphmind.temp.TempItemLoadData;
	import com.graphmind.util.DesktopDragInfo;
	import com.graphmind.util.OSD;
	import com.graphmind.view.TreeDrawer;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.ui.ContextMenu;
	
	import mx.controls.Image;
	import mx.core.BitmapAsset;
	import mx.events.FlexEvent;
	
	/**
	 * Stage manager
	 *  - events that happen on the stage's UI elements (general buttons, ...)
	 *  - structure drawer support (tree, graph, ...)
	 *  - stage level hooks
	 */
	public class TreeMapViewController extends MapViewController {
    
    /**
     * Root node. At the creation of the map it's the host Drupal node.
     */
    public static var rootNode:NodeViewController  = null;
        
    /**
     * Active node.
     */
    public static var activeNode:NodeViewController;
    
		/** 
		 * Indicates if the stage has a newer state or new elements.
		 */
    [Bindable]
    // @TODO - rename it to: isStageUpdated
    public var isTreeUpdated:Boolean = false;
    
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
    public var dragAndDropImage:Image = new Image();
    
    
		/**
		 * Constructor.
		 */
		public function TreeMapViewController() {
		  super();
		  
		  // Set the structure drawer.
		  this.treeDrawer = new TreeDrawer(view.nodeLayer, view.connectionLayer, view.cloudLayer);
		  
		  EventCenter.subscribe(EventCenterEvent.MAP_UPDATED, onMindmapUpdated);
		  
      // Node title RTE editor's default color
      GraphMind.i.mindmapToolsPanel.node_info_panel.nodeLabelRTE.colorPicker.selectedColor = 0x555555;
      
      // Remove base context menu items (not perfect, though)
      var cm:ContextMenu = new ContextMenu();
      cm.hideBuiltInItems();
      MovieClip(GraphMind.i.systemManager).contextMenu = cm;
      
      // Add drag and drop iamge.
      var bmd:BitmapAsset = (new _dragAndDropImageSource()) as BitmapAsset;
      dragAndDropImage.source = bmd;
      dragAndDropImage.x = -100;
      dragAndDropImage.y = -100;
      view.overlayLayer.addChild(dragAndDropImage);
      
      EventCenter.subscribe(EventCenterEvent.NODE_CREATED, onNodeCreated);
      
      // Active node events
      EventCenter.subscribe(EventCenterEvent.ACTIVE_NODE_TITLE_IS_CHANGED, onActiveNodeTitleIsChanged);
      EventCenter.subscribe(EventCenterEvent.ACTIVE_NODE_LINK_IS_CHANGED, onActiveNodeLinkIsChanged);
      EventCenter.subscribe(EventCenterEvent.ACTIVE_NODE_TOGGLE_CLOUD, onActiveNodeToggleCloud);
      EventCenter.subscribe(EventCenterEvent.ACTIVE_NODE_SAVE_ATTRIBUTE, onActiveNodeSaveAttribute);
      EventCenter.subscribe(EventCenterEvent.ACTIVE_NODE_REMOVE_ATTRIBUTE, onActiveNodeRemoveAttribute);
      EventCenter.subscribe(EventCenterEvent.ACTIVE_NODE_ADD_ICON, onActiveNodeAddIcon);
      EventCenter.subscribe(EventCenterEvent.NODE_IS_SELECTED, onNodeIsSelected);
      EventCenter.subscribe(EventCenterEvent.NODE_PREPARE_DRAG, onNodePrepareDrag);
      EventCenter.subscribe(EventCenterEvent.NODE_START_DRAG, onNodeStartDrag);
      EventCenter.subscribe(EventCenterEvent.NODE_FINISH_DRAG, onNodeFinishDrag);
      EventCenter.subscribe(EventCenterEvent.MAP_SCALE_CHANGED, onMapScaleChanged);
      EventCenter.subscribe(EventCenterEvent.MAP_SAVED, onMapSaved);
      EventCenter.subscribe(EventCenterEvent.REQUEST_TO_SAVE, onRequestToSave);
      EventCenter.subscribe(EventCenterEvent.LOAD_DRUPAL_ITEM, onLoadDrupalItem);
      
      view.container.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown_Map);
      view.container.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove_Map);
      view.container.addEventListener(MouseEvent.MOUSE_UP,   onMouseUp_Map);
      view.container.addEventListener(MouseEvent.MOUSE_OUT,  onMouseOut_Map);
		}
		
		
    /**
     * Event handler: stage is updated.
     */
		protected function onMindmapUpdated(event:EventCenterEvent):void {
			redrawMindmapStage();
			setMindmapUpdated();
		}
		

    /**
     * Indicates mindmap has changed -> needs saving.
     */
    public function setMindmapUpdated():void {
      isTreeUpdated = true;
    }


    /**
     * Refresh the whole mindmap stage.
     * 
     * Since it uses time deferring we can't decide on whether to refresh subtree or the whole tree.
     */
    public function redrawMindmapStage():void {
      if (!rootNode) return;
      
      treeDrawer.refreshGraphics(rootNode);
    }

    
    public function onMouseUp_DragAndDropImage():void {
      dragAndDropImage.visible = false;
      dragAndDropImage.x = -100;
      dragAndDropImage.y = -100;
    }
    
    
    public function prepareNodeDragAndDrop():void {
      NodeViewController.isPrepairedNodeDragAndDrop = true;
    }
    
    
    private function startNodeDragAndDrop(source:NodeViewController):void {
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
    
    
    public function onMouseDown_OutsideMindmapStage():void {
      closeNodeDragAndDrop();
    }
    
    
    public function onMouseOut_Map(event:MouseEvent):void {
      closeMapDragAndDrop();
    }
    
    
    public function onMouseUp_Map(event:MouseEvent):void {
      closeMapDragAndDrop();
      closeNodeDragAndDrop();
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
    protected function closeMapDragAndDrop():void {
      isDesktopDragged = false;
    }

    
    public function onMouseDown_Map(event:MouseEvent):void {
      startMapDragAndDrop();
      closeNodeDragAndDrop();
    }
    
    
    public function onMouseMove_Map(event:MouseEvent):void {
      doMapDragAndDrop();
    }
    
    
    /**
     * Start the dragged node's drag and drop session.
     */
    protected function startMapDragAndDrop():void {
      GraphMind.i.map.setFocus();
      
      isDesktopDragged = true;
      
      _desktopDragInfo.oldVPos = view.mouseY;
      _desktopDragInfo.oldHPos = view.mouseX;
      _desktopDragInfo.oldScrollbarVPos = view.verticalScrollPosition;
      _desktopDragInfo.oldScrollbarHPos = view.horizontalScrollPosition;
    }
    
    
    protected function doMapDragAndDrop():void {
      if (isDesktopDragged) {
        var deltaV:Number = view.mouseY - _desktopDragInfo.oldVPos;
        var deltaH:Number = view.mouseX - _desktopDragInfo.oldHPos;
        view.verticalScrollPosition   = _desktopDragInfo.oldScrollbarVPos - deltaV;
        view.horizontalScrollPosition = _desktopDragInfo.oldScrollbarHPos - deltaH;
      }
    }

    
    public function getTreeDrawer():TreeDrawer {
      return treeDrawer as TreeDrawer;
    }

    
    public function onNodeCreated(event:EventCenterEvent):void {
      view.nodeLayer.addChild((event.data as NodeViewController).view);
    }
    
    
    public override function onMapDidLoaded(event:FlexEvent):void {
      super.onMapDidLoaded(event);
      view.verticalScrollPosition = (view.container.height - view.height) >> 1;
    }
    
    
    protected function onActiveNodeTitleIsChanged(event:EventCenterEvent):void {
      if (!activeNode) return;
      activeNode.setTitle(event.data.toString(), true);
    }

    
    protected function onActiveNodeLinkIsChanged(event:EventCenterEvent):void {
      if (!activeNode) return;
      activeNode.setLink(event.data as String);
    }
    
    
    protected function onActiveNodeToggleCloud(event:EventCenterEvent):void {
      if (!activeNode) return;
      activeNode.toggleCloud();
    }
    
    
    protected function onActiveNodeSaveAttribute(event:EventCenterEvent):void {
      if (!activeNode) return;
      activeNode.addData(event.data.param.toString(), event.data.value.toString());
    }
    
    
    protected function onActiveNodeRemoveAttribute(event:EventCenterEvent):void {
      if (!activeNode) return;
      activeNode.deleteData(event.data.toString());
    }
    
    
    protected function onActiveNodeAddIcon(event:EventCenterEvent):void {
      if (!activeNode) return;
      activeNode.addIcon(event.data.toString());
    }
    
    
    protected function onNodeIsSelected(event:EventCenterEvent):void {
      if (activeNode) {
        activeNode.unselect();
      }
      activeNode = event.data as NodeViewController;
    }
    
    
    protected function onMapScaleChanged(event:EventCenterEvent):void {
      view.setScale(event.data as Number);
    }
    
    
    protected function onRequestToSave(event:EventCenterEvent):void {
      var xml:String = ExportController.getFreeMindXML(rootNode);
      ExportController.saveFreeMindXMLToDrupal(ConnectionController.mainConnection, xml, ApplicationController.getHostNodeID());
    }
    
    
    /**
     * Save event is done.
     */
    public function onMapSaved(event:EventCenterEvent):void {
      if (event.data) {
        OSD.show('GraphMind data is saved.');
      } else {
        OSD.show('This content has been modified by another user, changes cannot be saved.', OSD.WARNING);
        // @TODO prevent later savings
      }
    }
    
    
    protected function onNodePrepareDrag(event:EventCenterEvent):void {
      prepareNodeDragAndDrop();
    }
    
    
    protected function onNodeStartDrag(event:EventCenterEvent):void {
      startNodeDragAndDrop(event.data as NodeViewController);
    }
    
    
    protected function onNodeFinishDrag(event:EventCenterEvent):void {
      closeNodeDragAndDrop();
    }
    
    
    protected function onLoadDrupalItem(event:EventCenterEvent):void {
      var data:TempItemLoadData = event.data as TempItemLoadData;
      ConnectionController.mainConnection.call(
        data.type + '.get',
        function(result:Object):void {      
          var node:NodeViewController = new NodeViewController();
          node.nodeData.drupalData = result;
          node.nodeData.type = data.type;
          node.nodeData.recalculateData();
          data.parentNode.addChildNode(node);
          node.select();
          node.update(NodeViewController.UP_UI);
        },
        data.id
      );
    }
    
	}
	
}
