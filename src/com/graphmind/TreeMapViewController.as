package com.graphmind {

	import com.graphmind.data.NodeDataObject;
	import com.graphmind.data.NodeType;
	import com.graphmind.display.ConfigPanelController;
	import com.graphmind.display.TreeDrawer;
	import com.graphmind.event.EventCenter;
	import com.graphmind.event.EventCenterEvent;
	import com.graphmind.temp.DrupalItemRequestParamObject;
	import com.graphmind.temp.DrupalViewsRequestParamObject;
	import com.graphmind.util.DesktopDragInfo;
	import com.graphmind.util.OSD;
	import com.graphmind.view.NodeView;
	
	import components.DrupalItemLoadPanel;
	import components.NodeAttributes;
	import components.NodeIcons;
	import components.NodeInfo;
	import components.ViewLoadPanel;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.ui.ContextMenu;
	
	import mx.collections.ArrayCollection;
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
    protected var dragAndDropImage:Image = new Image();
    
    /**
     * Active node's attributes -> to display it as attributes.
     * Sensitive information not included (ie: passwords).
     */ 
    public static var selectedNodeData:ArrayCollection = new ArrayCollection();

    
		/**
		 * Constructor.
		 */
		public function TreeMapViewController() {
		  super();
		  
		  // Set the structure drawer.
		  this.treeDrawer = new TreeDrawer(view.nodeLayer, view.connectionLayer, view.cloudLayer);
		  
		  EventCenter.subscribe(EventCenterEvent.MAP_UPDATED, onMindmapUpdated);
		  
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
      EventCenter.subscribe(EventCenterEvent.ACTIVE_NODE_TOGGLE_CLOUD, onActiveNodeToggleCloud);
      EventCenter.subscribe(EventCenterEvent.ACTIVE_NODE_ADD_ICON, onActiveNodeAddIcon);
      EventCenter.subscribe(EventCenterEvent.NODE_PREPARE_DRAG, onNodePrepareDrag);
      EventCenter.subscribe(EventCenterEvent.NODE_START_DRAG, onNodeStartDrag);
      EventCenter.subscribe(EventCenterEvent.NODE_FINISH_DRAG, onNodeFinishDrag);
      EventCenter.subscribe(EventCenterEvent.MAP_SCALE_CHANGED, onMapScaleChanged);
      EventCenter.subscribe(EventCenterEvent.MAP_SAVED, onMapSaved);
      EventCenter.subscribe(EventCenterEvent.MAP_LOCK, onMapLock);
      EventCenter.subscribe(EventCenterEvent.MAP_UNLOCK, onMapUnlock);
      EventCenter.subscribe(EventCenterEvent.REQUEST_TO_SAVE, onRequestToSave);
      EventCenter.subscribe(EventCenterEvent.REQUEST_TO_CHANGE_NODE_SIZE, onRequestToChangeNodeSize);
      EventCenter.subscribe(EventCenterEvent.LOAD_DRUPAL_ITEM, onLoadDrupalItem);
      EventCenter.subscribe(EventCenterEvent.LOAD_DRUPAL_VIEWS, onLoadDrupalViews);
      
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
      
      _desktopDragInfo.mouseY = view.mouseY;
      _desktopDragInfo.mouseX = view.mouseX;
      _desktopDragInfo.verticalScrollbarPosition = view.verticalScrollPosition;
      _desktopDragInfo.horizontalScrollbarPosition = view.horizontalScrollPosition;
    }
    
    
    protected function doMapDragAndDrop():void {
      if (isDesktopDragged) {
        var deltaV:Number = view.mouseY - _desktopDragInfo.mouseY;
        var deltaH:Number = view.mouseX - _desktopDragInfo.mouseX;
        view.verticalScrollPosition   = _desktopDragInfo.verticalScrollbarPosition - deltaV;
        view.horizontalScrollPosition = _desktopDragInfo.horizontalScrollbarPosition - deltaH;
      }
    }

    
    public function onNodeCreated(event:EventCenterEvent):void {
      view.nodeLayer.addChild((event.data as NodeViewController).view);
    }
    
    
    public override function onMapDidLoaded(event:FlexEvent):void {
      super.onMapDidLoaded(event);
      view.verticalScrollPosition = (view.container.height - view.height) >> 1;
    }
    
    
    protected function onActiveNodeTitleIsChanged(event:EventCenterEvent):void {
      if (!NodeViewController.activeNode) return;
      NodeViewController.activeNode.setTitle(event.data.toString());
    }

    
    protected function onActiveNodeLinkIsChanged(event:EventCenterEvent):void {
      if (!NodeViewController.activeNode) return;
      NodeViewController.activeNode.setLink(event.data as String);
    }
    
    
    protected function onActiveNodeToggleCloud(event:EventCenterEvent):void {
      if (!NodeViewController.activeNode) return;
      NodeViewController.activeNode.toggleCloud();
    }
    

    protected function onActiveNodeAddIcon(event:EventCenterEvent):void {
      if (!NodeViewController.activeNode) return;
      NodeViewController.activeNode.addIcon(event.data.toString());
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
      var data:DrupalItemRequestParamObject = event.data as DrupalItemRequestParamObject;
      ConnectionController.mainConnection.call(
        data.type + '.retrieve',
        function(result:Object):void {      
          var node:NodeViewController = new NodeViewController(new NodeDataObject(result, data.type, data.conn));
          data.parentNode.addChildNode(node);
          node.select();
          node.update(NodeViewController.UP_UI);
        },
        ConnectionController.defaultRequestErrorHandler,
        data.id
      );
    }
    
    
    protected function onLoadDrupalViews(event:EventCenterEvent):void {
      var data:DrupalViewsRequestParamObject = event.data as DrupalViewsRequestParamObject;
      data.views.views.connection.call(
        'views.retrieve',
        function(res:Object):void{onSuccess_loadDrupalViews(res, data)},
        ConnectionController.defaultRequestErrorHandler,
        data.views.name,
        data.views.fields,
        [data.views.args],
        data.views.offset,
        data.views.limit
      );
    }
    
    
    private function onSuccess_loadDrupalViews(result:Object, requestData:DrupalViewsRequestParamObject):void {
      if (result.length == 0) {
        OSD.show('Result is empty.', OSD.WARNING);
        return;
      }
      
      for each (var nodeData:Object in result) {
        var similarNode:NodeViewController = requestData.parentNode.getEqualChild(nodeData, requestData.views.views.baseTable) as NodeViewController;
        if (similarNode) {
          similarNode.updateDrupalItem(nodeData);
          continue;
        }
        var nodeItem:NodeViewController = new NodeViewController(new NodeDataObject(
          nodeData,
          NodeType.nodeTypeOfViewsTable(requestData.views.views.baseTable),
          requestData.views.views.connection
        ));
        requestData.parentNode.addChildNode(nodeItem);
      }
    }
    
    
    public function onMapLock(event:EventCenterEvent):void {
      lock();
    }
    
    
    public function onMapUnlock(event:EventCenterEvent):void {
      unlock();
    }
    
    
    private function onRequestToChangeNodeSize(event:EventCenterEvent):void {
      switch (event.data as uint) {
        case ApplicationController.NODE_SIZE_SMALL_INDEX:
          NodeView.HEIGHT = NodeView.SMALL_HEIGHT;
          NodeView.LABEL_FONT_SIZE = NodeView.SMALL_LABEL_FONT_SIZE;
          NodeView.LABEL_EDIT_FONT_SIZE = NodeView.SMALL_LABEL_EDIT_FONT_SIZE;
          break;
        default:
          NodeView.HEIGHT = NodeView.LARGE_HEIGHT;
          NodeView.LABEL_FONT_SIZE = NodeView.LARGE_LABEL_FONT_SIZE;
          NodeView.LABEL_EDIT_FONT_SIZE = NodeView.LARGE_LABEL_EDIT_FONT_SIZE;
          break;
      }
      
      for (var idx:* in NodeViewController.nodes) {
        var node:NodeViewController = NodeViewController.nodes[idx];
        node.view.backgroundView.setStyle('cornerRadius', NodeView.HEIGHT / 4);
        node.view.backgroundView.height = NodeView.HEIGHT;
        node.view.height = NodeView.HEIGHT;
      }
      
      EventCenter.notify(EventCenterEvent.MAP_UPDATED);
    }
	}
	
}
