package com.graphmind {

	import com.graphmind.display.NodeViewController;
	import com.graphmind.event.EventCenter;
	import com.graphmind.event.EventCenterEvent;
	import com.graphmind.util.DesktopDragInfo;
	import com.graphmind.util.Log;
	import com.graphmind.util.OSD;
	import com.graphmind.view.TreeDrawer;
	
	import flash.display.MovieClip;
	import flash.ui.ContextMenu;
	
	import mx.controls.Image;
	import mx.core.BitmapAsset;
	
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
    public var dragAndDropImage:Image = new Image();
    
    
		/**
		 * Constructor.
		 */
		public function TreeMapViewController() {
		  super();
		  
//		  view.horizontalScrollPosition = view.container.width  >> 1;
//      view.verticalScrollPosition   = view.container.height >> 1;
//      view.addEventListener(FlexEvent.CREATION_COMPLETE, function(event:FlexEvent):void{
//        var map:MapView = event.currentTarget as MapView;
//        map.horizontalScrollPosition = 1000;
//        map.verticalScrollPosition   = 1000;
//        Log.info("Height: " + map.height + " inner: " + map.container.height + " scroll: " + map.verticalScrollPosition);
//      });
      view.verticalScrollPosition   = 1000;
      view.horizontalScrollPosition = 1000;
		  
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
      view.overlayLayer.addChild(dragAndDropImage);
      
      EventCenter.subscribe(EventCenterEvent.NODE_CREATED, onNodeCreated);
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

    
    /**
     * Check if there is any node selected.
     */
    public function isActiveNodeExists(showError:Boolean = false):Boolean {
      if (!NodeViewController.activeNode) {
        if (showError) OSD.show("Please, select a node first.", OSD.WARNING);
        return false;
      }
      
      return true;
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

    
    public function getTreeDrawer():TreeDrawer {
      return treeDrawer as TreeDrawer;
    }

    
    public function onNodeCreated(event:EventCenterEvent):void {
      com.graphmind.util.Log.info('Node added to stage');
      view.nodeLayer.addChild((event.sender as NodeViewController).view);
    }

	}
	
}
