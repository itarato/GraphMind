package com.graphmind.display {
	
	import com.graphmind.ConnectionManager;
	import com.graphmind.PluginManager;
	import com.graphmind.StageManager;
	import com.graphmind.data.NodeData;
	import com.graphmind.data.NodeType;
	import com.graphmind.event.NodeEvent;
	import com.graphmind.event.StageEvent;
	import com.graphmind.factory.NodeFactory;
	import com.graphmind.temp.TempItemLoadData;
	import com.graphmind.util.Log;
	import com.graphmind.util.StringUtility;
	import com.graphmind.view.NodeUI;
	
	import flash.events.ContextMenuEvent;
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Image;
	import mx.events.FlexEvent;


  [Event(name="updateData",           type="com.graphmind.event.NodeEvent")]
  [Event(name="updateGraphics",       type="com.graphmind.event.NodeEvent")]
  [Event(name="moved",                type="com.graphmind.event.NodeEvent")]
  [Event(name="deleted",              type="com.graphmind.event.NodeEvent")]
  [Event(name="created",              type="com.graphmind.event.NodeEvent")]
  [Event(name="attributeChanged",     type="com.graphmind.event.NodeEvent")]
  [Event(name="dragAndDropFinished",  type="com.graphmind.event.NodeEvent")]
  [Event(type="com.graphmind.event.NodeEvent", name="click")]
  [Event(type="com.graphmind.event.NodeEvent", name="mouseOver")]
  [Event(type="com.graphmind.event.NodeEvent", name="mouseOut")]
  [Event(type="com.graphmind.event.NodeEvent", name="doubleClick")]
  [Event(type="com.graphmind.event.NodeEvent", name="keyUpTitleTextField")]
  [Event(type="com.graphmind.event.NodeEvent", name="focusOutTitleTextField")]
  [Event(type="com.graphmind.event.NodeEvent", name="itemLoaderSelectorClick")]
  [Event(type="com.graphmind.event.NodeEvent", name="clickAddSimpleNode")]
  [Event(type="com.graphmind.event.NodeEvent", name="clickAddDrupalItem")]
  [Event(type="com.graphmind.event.NodeEvent", name="clickAddDrupalViews")]
  [Event(type="com.graphmind.event.NodeEvent", name="clickNodeLink")]
  [Event(type="com.graphmind.event.NodeEvent", name="mouseDown")]
  [Event(type="com.graphmind.event.NodeEvent", name="mouseUp")]
  [Event(type="com.graphmind.event.NodeEvent", name="mouseMove")]
  [Event(type="com.graphmind.event.NodeEvent", name="contextMenuAddSimpleNode")]
  [Event(type="com.graphmind.event.NodeEvent", name="contextMenuAddDrupalItem")]
  [Event(type="com.graphmind.event.NodeEvent", name="contextMenuAddDrupalViews")]
  [Event(type="com.graphmind.event.NodeEvent", name="contextMenuRemoveNode")]
  [Event(type="com.graphmind.event.NodeEvent", name="contextMenuRemoveChilds")]
	public class NodeController extends EventDispatcher implements IHasUI, ITreeItem, ICloud {
		
		// Node access caches
		public static var nodes:ArrayCollection = new ArrayCollection();
		
		public static const HOOK_NODE_CONTEXT_MENU:String  = 'node_context_menu';
		public static const HOOK_NODE_MOVED:String         = 'node_moved';
		public static const HOOK_NODE_DELETE:String		     = 'node_delete';
		public static const HOOK_NODE_CREATED:String	     = 'node_created';
		public static const HOOK_NODE_TITLE_CHANGED:String = 'node_title_changed';
		
		public static const UP_TIME:uint       = 1;
		public static const UP_NODE_UI:uint    = 2;
		public static const UP_SUBTREE_UI:uint = 4;
    public static const UP_TREE_UI:uint    = 8;
		public static const UP_STAGE_NODE_DATA:uint = 16;
		
		// Time delay until selecting a node on mouseover
		protected var _mouseSelectionTimeout:uint;

    // Drag and drop info.    
    public static var dragAndDrop_sourceNode:NodeController;
    public static var isNodeDragAndDrop:Boolean = false;
    public static var isPrepairedNodeDragAndDrop:Boolean = false;

    /**
     * Various background effects.
     */
    public static var _nodeGlowFilter:GlowFilter = new GlowFilter(0x0072B9, .8, 6, 6);
    public static var _nodeInnerGlowFilter:GlowFilter = new GlowFilter(0xFFFFFF, .8, 20, 20, 2, 1, true);
    
    /**
     * Related names of background effects.
     */
    public static const EFFECT_NORMAL:int = 0;
    public static const EFFECT_HIGHLIGHT:int = 1;
    
    /**
     * Model.
     */
    public var nodeData:NodeData;
    
    /**
     * View.
     */
    public var nodeView:NodeUI;
    
    /**
     * Child nodes.
     */
    protected var _childs:ArrayCollection = new ArrayCollection();
        
    /**
     * Subtree is collapsed.
     */
    protected var _isCollapsed:Boolean = false;
   
    /**
     * Collapsed directly - means not collapsed by folding a parent node.
     */
    protected var _isForcedCollapsed:Boolean = false;
    
    /**
     * Parent node.
     * For the root it's null.
     */
    public var parent:NodeController = null;
    
    /**
     * ArrowLinks
     */
    protected var _arrowLinks:ArrayCollection = new ArrayCollection();
    
    /**
     * Constructor.
     */ 
		public function NodeController(nodeData:NodeData, newNodeView:NodeUI = null):void {
			super();
			
			this.nodeData = nodeData;
			
			if (newNodeView == null) {
			  newNodeView = new NodeUI();
			}
			
      // Event listeners
      newNodeView._displayComp.title_label.addEventListener(MouseEvent.DOUBLE_CLICK,   onDoubleClick);
      newNodeView._displayComp.title_new.addEventListener(KeyboardEvent.KEY_UP,        onKeyUp_TitleTextField);
      newNodeView._displayComp.title_new.addEventListener(FocusEvent.FOCUS_OUT,        onFocusOut_TitleTextField);
      newNodeView._displayComp.icon_add.addEventListener(MouseEvent.CLICK,             onClick_AddSimpleNodeButton);
      newNodeView._displayComp.addEventListener(MouseEvent.MOUSE_DOWN,                 onMouseDown);
      newNodeView._displayComp.addEventListener(MouseEvent.MOUSE_UP,                   onMouseUp);
      newNodeView._displayComp.addEventListener(MouseEvent.MOUSE_MOVE,                 onMouseMove);
      newNodeView._displayComp.addEventListener(MouseEvent.MOUSE_OVER,                 onMouseOver);
      newNodeView._displayComp.addEventListener(MouseEvent.MOUSE_OUT,                  onMouseOut);
      newNodeView._displayComp.title_label.addEventListener(FlexEvent.UPDATE_COMPLETE, onUpdateComplete_TitleLabel);
      newNodeView._displayComp.icon_anchor.addEventListener(MouseEvent.CLICK,          onClick_NodeLinkButton);
      newNodeView._displayComp.icon_has_child.addEventListener(MouseEvent.CLICK,       onClick_ToggleSubtreeButton);
  
      newNodeView._displayComp.contextMenu = getContextMenu();
			
			nodeView = newNodeView;
			
			nodeData.recalculateTitle(true);
			setTitle(nodeData.title);
			
			nodeData.recalculateDrupalID();
			
			nodeView.backgroundColor = nodeData.color;
			
			nodes.addItem(this);
		}
		
		/**
		 * Create a simple empty child node.
		 * Don't use it for creating nodes. Use NodeFactory instead.
		 */
    public function createSimpleNodeChild():void {
      var node:NodeController = NodeFactory.createNode({}, NodeType.NORMAL);
      addChildNode(node);
      node.selectNode();
    }
    
		/**
		 * Get a complete context menu for the UI.
		 */	
		public function getContextMenu():ContextMenu {
			var contextMenu:ContextMenu = new ContextMenu();
			contextMenu.customItems = [];
			contextMenu.hideBuiltInItems();
			
			var cms:Array = [
				{title: 'Add node',        event: onContextMenuSelected_AddSimpleNode,    separator: false},
				{title: 'Add Drupal item', event: onContextMenuSelected_AddDrupalItem, 	  separator: false},
				{title: 'Add Views list',  event: onContextMenuSelected_AddDrupalViews,   separator: false},
				{title: 'Remove node',     event: onContextMenuSelected_RemoveNode,       separator: true},
				{title: 'Remove childs',   event: onContextMenuSelected_RemoveNodeChilds, separator: false},
				{title: 'Open subtree',    event: onContextMenuSelected_OpenSubtree,      separator: true},
				{title: 'Toggle cloud',    event: onContextMenuSelected_ToggleCloud,      separator: false}
			];
			
			if (NodeType.updatableTypes.indexOf(nodeData.type) >= 0) {
				cms.push({title: 'Update node', event: onContextMenuSelected_UpdateDrupalItem, separator: false});
			}
			
			// Extend context menu items by Plugin provided menu items
			PluginManager.callHook(HOOK_NODE_CONTEXT_MENU, {data: cms});
			Log.debug('contextmenu: ' + cms.length);
			
			for each (var cmData:Object in cms) {
				var cmi:ContextMenuItem = new ContextMenuItem(cmData.title,	cmData.separator);
				cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(_event:ContextMenuEvent):void {
					selectNode();
				});
				cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, cmData.event);
				contextMenu.customItems.push(cmi);
			}
			
			return contextMenu;
		}
    
    /**
     * Check if the node is selected.
     * @return Boolean
     */
    public function isSelected():Boolean {
      return GraphMind.i.stageManager.activeNode == this;
    }
		
		/**
		 * Select a single node on the mindmap stage.
		 * Only one node can be active at a time.
		 * Accessing to this node: TreeManager.getInstance().activeNode():NodeItem.
		 */
		public function selectNode():void {
			var isTheSameSelected:Boolean = isSelected();
			
			// Not to lose focus from textfield
			if (!isTheSameSelected) nodeView.setFocus();
			
			// @TODO mystery bug steal highlight somethimes from nodes
			if (GraphMind.i.stageManager.activeNode) {
				GraphMind.i.stageManager.activeNode.deselectNode();
			}
			GraphMind.i.stageManager.activeNode = this;
			GraphMind.i.stageManager.selectedNodeData = new ArrayCollection();
			for (var key:* in nodeData.data) {
				GraphMind.i.stageManager.selectedNodeData.addItem({
					key: key,
					value: nodeData.data[key]
				});
			}
			
			GraphMind.i.mindmapToolsPanel.node_info_panel.nodeLabelRTE.htmlText = nodeView._displayComp.title_label.htmlText || nodeView._displayComp.title_label.text;
				
			if (!isTheSameSelected) {
				GraphMind.i.mindmapToolsPanel.node_info_panel.link.text = nodeData.link;
				GraphMind.i.mindmapToolsPanel.node_attributes_panel.attributes_update_param.text = '';
				GraphMind.i.mindmapToolsPanel.node_attributes_panel.attributes_update_value.text = '';
			}
				
			_setBackgroundEffect(EFFECT_HIGHLIGHT);
		}
		
		/**
		 * Deselect node.
		 */
		public function deselectNode():void {
		  GraphMind.i.stageManager.activeNode = null;
			_setBackgroundEffect(EFFECT_NORMAL);
		}
		
		/**
		 * Create Freemind compatible XML string output.
		 * For the full XML call it in StageManager.
		 */
		public function exportToFreeMindFormat():String {
			//var titleIsHTML:Boolean = _displayComponent.title_label.text != _displayComponent.title_label.htmlText;
			var titleIsHTML:Boolean = nodeData.title.toString().indexOf('<') >= 0;
			
			// Base node information
			var output:String = '<node ' + 
				'CREATED="'  + nodeData.created   + '" ' + 
				'MODIFIED="' + nodeData.modified  + '" ' + 
				'ID="'       + nodeData.id        + '" ' + 
				'FOLDED="'   + (_isForcedCollapsed ? 'true' : 'false') + '" ' + 
				(titleIsHTML ? '' : 'TEXT="' + escape(nodeData.title) + '" ') + 
				(nodeData.link.length > 0 ? ('LINK="' + escape(nodeData.link) + '" ') : '') + 
				'TYPE="' + nodeData.type + '" ' +
				">\n";
			
			if (titleIsHTML) {
				output = output + "<richcontent TYPE=\"NODE\"><html><head></head><body>" + 
					nodeData.title + 
					"</body></html></richcontent>";
			}
			
			var key:*;
			for (key in nodeData.data) {
				output = output + '<attribute NAME="' + escape(key) + '" VALUE="' + escape(nodeData.data[key]) + '"/>' + "\n";
			}
			
			if (nodeData.source) {
				output = output + '<site URL="' + escape(nodeData.source.url) + '" USERNAME="' + escape(nodeData.source.username) + '"/>' + "\n";
			}
			
			for each (var iconName:* in nodeData._icons) {
				output = output + '<icon BUILTIN="' + iconName + '"/>' + "\n";
			}
			
			if (hasCloud()) {
				output = output + '<cloud/>' + "\n";
			}
			
			// Add childs
			for each (var child:NodeController in _childs) {
				output = output + child.exportToFreeMindFormat();
			}
			
			return output + '</node>' + "\n";
		}
		
		/**
		 * Show the dialog for loading a Drupal item.
		 */
		protected function loadItem():void {
			selectNode();
			GraphMind.i.currentState = 'load_item_state';
		}
		
		/**
		 * Show the dialog for loading a Drupal Views list.
		 */
		protected function loadViews():void {
			selectNode();
			GraphMind.i.currentState = 'load_view_state';
			GraphMind.i.panelLoadView.view_arguments.text = nodeData.drupalID.toString();
		}
		
		/**
		 * Remove each child of the node.
		 */
		protected function _removeNodeChilds(killedDirectly:Boolean = false):void {
			while (_childs.length > 0) {
				(_childs.getItemAt(0) as NodeController).kill(killedDirectly);
			}
		}
		
		/**
		 * Kill a node and each childs.
		 */
		public function kill(killedDirectly:Boolean = true):void {
		  // Root can't be deleted.
			if (GraphMind.i.stageManager.rootNode === this) return;
			
			// @HOOK
			PluginManager.callHook(HOOK_NODE_DELETE, {node: this, directKill: killedDirectly});
			
			// Remove all children the same way.
			_removeNodeChilds(false);
			
			if (parent) {
				// Remove parent's child (this child).
				parent._childs.removeItemAt(parent._childs.getItemIndex(this));
				// Check parent's toggle-subtree button. With no child it should be hidden.
				parent.nodeView._displayComp.icon_has_child.visible = parent._childs.length > 0;
			}
			// Remove main UI element.
			nodeView._displayComp.parent.removeChild(nodeView._displayComp);
			// Remove the whole UI.
			nodeView.parent.removeChild(this.nodeView);
			
			// Remove from the global storage
			nodes.removeItemAt(nodes.getItemIndex(this));
			
			// Update tree.
			GraphMind.i.stageManager.setMindmapUpdated();
			GraphMind.i.stageManager.dispatchEvent(new NodeEvent(NodeEvent.UPDATE_GRAPHICS));
			
			update(UP_SUBTREE_UI);
			
			delete this; // :.(
		}
		
		/**
		 * Check if the giveth node is a child of the self node.
		 */
		public function isChild(node:NodeController):Boolean {
			for each (var child:NodeController in _childs) {
				if (child == node) {
					return true;
				}
				if (child.isChild(node)) return true;
			}
			
			return false;
		}
		
		/**
		 * Move a node.
		 */
		public static function move(source:NodeController, target:NodeController, callEvent:Boolean = true):Boolean {
			// No parent can detach child.
			if (!source || !source.parent || !target) return false;
			// Target is an ascendant of the source.
			if (source.isChild(target)) return false;
			// Source is equal to target
			if (source == target) return false;
			
			// Remove source from parents childs
			source.removeFromParentsChilds();
			// Add source to target
			target.addChildNode(source);
			// Refresh display
			
			if (callEvent) {
				// Call hook
				PluginManager.callHook(HOOK_NODE_MOVED, {node: source});
				GraphMind.i.stageManager.dispatchEvent(new NodeEvent(NodeEvent.MOVED, source));
			}
			
			source.update(UP_TREE_UI);

			return true;
		}
		
		/**
		 * Move a node to a next sibling.
		 */
		public static function moveToPrevSibling(source:NodeController, target:NodeController):void {
			if (move(source, target.parent, false)) {
				var siblingIDX:int = target.parent._childs.getItemIndex(target);
				if (siblingIDX == -1) {
					return;
				}
				
				for (var i:int = target.parent._childs.length - 1; i > siblingIDX; i--) {
					target.parent._childs[i] = target.parent._childs[i - 1];
				}
				
				target.parent._childs.setItemAt(source, siblingIDX);
				
				// Refresh after reordering
				GraphMind.i.stageManager.setMindmapUpdated();
				GraphMind.i.stageManager.dispatchEvent(new NodeEvent(NodeEvent.UPDATE_GRAPHICS));
				
				// Call hook
				PluginManager.callHook(HOOK_NODE_MOVED, {node: source});
				GraphMind.i.stageManager.dispatchEvent(new NodeEvent(NodeEvent.MOVED, source));
			}
		}
		
		/**
		 * Remove this node from it's parent's child collection.
		 * It doesn't do any delete or kill.
		 */
		protected function removeFromParentsChilds():void {
			var childIDX:int = parent._childs.getItemIndex(this);
			if (childIDX >= 0) {
				this.parent._childs.removeItemAt(childIDX);
			}
			
			parent.nodeView._displayComp.icon_has_child.visible = parent._childs.length > 0;
		}
 		
 		protected function onDoubleClick_icon(event:MouseEvent):void {
 		  removeIcon(event.currentTarget as Image);
 		}
 		
 		/**
 		 * Remove an icon.
 		 */
 		public function removeIcon(icon:Image):void {
      var iconName:String = StringUtility.iconUrlToIconName(icon.source.toString());
      nodeData._icons.removeItemAt(nodeData._icons.getItemIndex(iconName));
      nodeView.removeIcon(icon.source.toString());
      update(UP_TIME | UP_SUBTREE_UI);
 		}
 		
 		/**
 		 * Set a link.
 		 */
		public function setLink(link:String):void {
			nodeData.link = link;
			nodeView._displayComp.icon_anchor.visible = (link.length > 0);
			update(UP_TIME | UP_NODE_UI);
		}
		
		/**
		 * Toggle cloud.
		 */
		public function toggleCloud():void {
			nodeData.hasCloud ? disableCloud() : enableCloud();
		}
		
		/**
		 * Enable cloud.
		 */
		public function enableCloud():void {
		  nodeData.hasCloud = true;
		  update(UP_TIME | UP_TREE_UI);
		}
		
		/**
		 * Disable cloud.
		 */
		public function disableCloud():void {
		  nodeData.hasCloud = false;
		  update(UP_TIME | UP_TREE_UI);
		}
		
		/**
		 * Refresh only the subtree and redraw the stage.
		 */
//		public function redrawParentsClouds():void {
//			_redrawParentsClouds();
//		}
		
		/**
		 * Force to redraw parents' clouds recursively
		 */
//		protected function _redrawParentsClouds():void {
//			if (nodeData.hasCloud) {
//				toggleCloud();
//				toggleCloud();
//			}
//			
//			if (parent) parent._redrawParentsClouds();
//		}
		
		/**
		 * Check if the subtree is collapsed.
		 */
		public function isCollapsed():Boolean {
			return _isCollapsed;
		}
		
		/**
		 * Make a request for updating the node from Drupal.
		 */
		public function updateDrupalItem():void {
			var tild:TempItemLoadData = new TempItemLoadData();
			tild.nodeItemData = nodeData;
			tild.success = updateDrupalItem_result;
			ConnectionManager.itemLoad(tild);
		}
		
		/**
		 * Update from Drupal request is arrived.
		 * @param object placeholder - we're using this as a callback. The second param
		 *  is a node (in this case the same) that has to be updated. We don't need that now.
		 */
		public function updateDrupalItem_result(result:Object, placeholder:Object = null):void {
			for (var key:* in result) {
				nodeData.data[key] = result[key];
			}
			nodeData.recalculateTitle();
			setTitle(nodeData.title);
			selectNode();
			update(UP_TIME | UP_NODE_UI);
		}
		
		/**
		 * Get parent node.
		 */
		public function getParentNode():ITreeNode {
			return parent;
		}
		
		/**
		 * Get the secondary connections - represented by arrow links.
		 */
		public function getArrowLinks():ArrayCollection {
			return _arrowLinks;
		}
		
		/**
		 * Add new secondary connection as an arrow link.
		 */
		public function addArrowLink(arrowLink:TreeArrowLink):void {
			this._arrowLinks.addItem(arrowLink);
			update(UP_TIME | UP_TREE_UI);
		}
		
		/**
		 * Check if the subtree has a cloud.
		 */
		public function hasCloud():Boolean {
			return nodeData.hasCloud;
		}
		
		/**
		 * Get a child node that has equal data.
		 */
		public function getEqualChild(data:Object, type:String):NodeController {
			for each (var child:NodeController in _childs) {
				if (child.nodeData.equalTo(data, type)) return child;
			}
			return null;
		}

		public function setTitle(title:String):void {
			nodeData.title = nodeView._displayComp.title_label.htmlText = title;
			PluginManager.callHook(HOOK_NODE_TITLE_CHANGED, {node: this});
			update(UP_TIME);
		}
		
		public function hasChild():Boolean {
			return _childs.length > 0;
		}
    
    public override function toString():String {
      return '[TreeNodeController: ' + this.nodeData.id + ']';
    }
		
    /**
     * Upadte node's time.
     * Reasons:
     *  - modified title
     *  - changed attributes
     *  - toggled cloud
     * @param uint updateSet - binary flag
     *  UP_TIME | UP_NODE_UI | UP_SUBTREE_UI | UP_TREE_UI
     */
    public function update(updateSet:uint = 0):void {
      if (updateSet & UP_TIME) {
        nodeData.modified = (new Date()).time;
      }
      
      if (updateSet & UP_NODE_UI) {
        nodeView.isGraphicsUpdated = true;
        nodeView.refreshGraphics();
      }
      
      if (updateSet & (UP_SUBTREE_UI | UP_TREE_UI)) {
        nodeView.isGraphicsUpdated = true;
        nodeView.refreshGraphics();
        GraphMind.i.stageManager.dispatchEvent(new StageEvent(StageManager.EVENT_MINDMAP_UPDATED));
      }
      
      if (updateSet & UP_STAGE_NODE_DATA) {
        deselectNode();
        selectNode();
      }
    }
    
    /**
     * Add attribute.
     */
    public function addData(attribute:String, value:String):void {
      nodeData.dataAdd(attribute, value);
      GraphMind.i.stageManager.setMindmapUpdated();
      update(UP_TIME | UP_STAGE_NODE_DATA);
    }
    
    /**
     * Remove attribute.
     */
    public function deleteData(param:String):void {
      nodeData.dataDelete(param);
      update(UP_TIME | UP_STAGE_NODE_DATA);
    }
    
    /**
     * Implementation of getUI().
     */
    public function getUI():IDrawable {
      return nodeView;
    }

    public function onMouseOver(event:MouseEvent):void {
      _mouseSelectionTimeout = setTimeout(selectNode, 400);
      nodeView._displayComp.icon_add.visible = GraphMind.i.applicationManager.isEditable();
      nodeView._displayComp.icon_anchor.visible = nodeData.link.length > 0;
    }
    
    public function onMouseOut(event:MouseEvent):void {
      clearTimeout(_mouseSelectionTimeout);
      nodeView._displayComp.icon_add.visible = false;
      nodeView._displayComp.icon_anchor.visible = false;
      
      if (NodeController.isPrepairedNodeDragAndDrop) {
        GraphMind.i.stageManager.openDragAndDrop(this);
      }
      
      nodeView._displayComp.insertLeft.visible = false;
      nodeView._displayComp.insertUp.visible = false;
    }
    
    public function onDoubleClick(event:MouseEvent):void {
      if (!GraphMind.i.applicationManager.isEditable()) return;
      
      nodeView._displayComp.currentState = 'edit_title';
      nodeView._displayComp.title_new.text = nodeView._displayComp.title_label.text;
      nodeView._displayComp.title_new.setFocus();
    }
    
    public function onKeyUp_TitleTextField(event:KeyboardEvent):void {
      if (!GraphMind.i.applicationManager.isEditable()) return;
      
      if (event.keyCode == Keyboard.ENTER) {
        nodeView._displayComp.currentState = '';
        setTitle(nodeView._displayComp.title_new.text);
        GraphMind.i.setFocus();
        selectNode();
      } else if (event.keyCode == Keyboard.ESCAPE) {
        nodeView._displayComp.currentState = '';
        nodeView._displayComp.title_new.text = nodeView._displayComp.title_label.text;
      }
    }
    
    public function onFocusOut_TitleTextField(event:FocusEvent):void {
      if (!GraphMind.i.applicationManager.isEditable()) return;
      
      // @TODO this is a duplication of the onNewTitleKeyUp() (above)
      nodeView._displayComp.currentState = '';
      nodeData.title = nodeView._displayComp.title_label.text = nodeView._displayComp.title_new.text;
      GraphMind.i.setFocus();
    }
    
    public function onItemLoaderSelectorClick(event:MouseEvent):void {
      event.stopPropagation();
      selectNode();
      GraphMind.i.panelLoadView.view_arguments.text = nodeData.drupalID.toString();
    }
    
    public function onClick_AddSimpleNodeButton(event:MouseEvent):void {
      if (!GraphMind.i.applicationManager.isEditable()) return;
      
      event.stopPropagation();
      event.stopImmediatePropagation();
      event.preventDefault();
      createSimpleNodeChild();
    }
    
    public function onLoadItemClick(event:MouseEvent):void {
      event.stopPropagation();
      loadItem();
    }
    
    public function onLoadViewClick(event:MouseEvent):void {
      event.stopPropagation();
      loadViews();
    }
    
    public function onClick_NodeLinkButton(event:MouseEvent):void {
      var ur:URLRequest = new URLRequest(nodeData.link);
      navigateToURL(ur, '_blank');
    }
    
    public function onMouseDown(event:MouseEvent):void {
      if (!GraphMind.i.applicationManager.isEditable()) return;
      
      GraphMind.i.stageManager.prepaireDragAndDrop();
      event.stopImmediatePropagation();
    }
    
    public function onMouseUp(event:MouseEvent):void {
      if (!GraphMind.i.applicationManager.isEditable()) return;
      
      if ((!NodeController.isPrepairedNodeDragAndDrop) && NodeController.isNodeDragAndDrop) {
        
        if (nodeView.mouseX / nodeView.getWidth() > (1 - nodeView.mouseY / nodeView.getHeight())) {
          NodeController.move(NodeController.dragAndDrop_sourceNode, this);
        } else {
          NodeController.moveToPrevSibling(NodeController.dragAndDrop_sourceNode, this);
        }
        GraphMind.i.stageManager.onMouseUp_MindmapStage();
        
        GraphMind.i.stageManager.dispatchEvent(new NodeEvent(NodeEvent.DRAG_AND_DROP_FINISHED, this));
      }
    }
    
    public function onMouseMove(event:MouseEvent):void {
      if (!GraphMind.i.applicationManager.isEditable()) return;
      
      if ((!NodeController.isPrepairedNodeDragAndDrop) && NodeController.isNodeDragAndDrop) {
        if (nodeView.mouseX / getUI().getWidth() > (1 - nodeView.mouseY / NodeUI.HEIGHT)) {
          nodeView._displayComp.insertLeft.visible = true;
          nodeView._displayComp.insertUp.visible = false;
        } else {
          nodeView._displayComp.insertLeft.visible = false;
          nodeView._displayComp.insertUp.visible = true;
        }
      }
    }
    
    public function onContextMenuSelected_AddSimpleNode(event:ContextMenuEvent):void {
      createSimpleNodeChild();
    }
    
    public function onContextMenuSelected_AddDrupalItem(event:ContextMenuEvent):void {
      loadItem();
    }
    
    public function onContextMenuSelected_AddDrupalViews(event:ContextMenuEvent):void {
      loadViews();
    }
    
    public function onContextMenuSelected_RemoveNode(event:ContextMenuEvent):void {
      kill();
    }
    
    public function onContextMenuSelected_RemoveNodeChilds(event:ContextMenuEvent):void {
      _removeNodeChilds(true);
    }
    
    public function onClick_ToggleSubtreeButton(event:MouseEvent):void {
      if (!this._isCollapsed) {
        collapse();
      } else {
        uncollapse();
      }
      GraphMind.i.stageManager.setMindmapUpdated();
      GraphMind.i.stageManager.dispatchEvent(new NodeEvent(NodeEvent.UPDATE_GRAPHICS, this));
      event.stopPropagation();
    }
    
    public function onContextMenuSelected_OpenSubtree(event:ContextMenuEvent):void {
      uncollapseChilds(true);
    }
    
    public function onContextMenuSelected_ToggleCloud(event:ContextMenuEvent):void {
      toggleCloud();
      update();
    }
  
    public function onContextMenuSelected_UpdateDrupalItem(event:ContextMenuEvent):void {
      updateDrupalItem();
    }
    
    
    public function onUpdateComplete_TitleLabel(event:FlexEvent):void {
      update(UP_SUBTREE_UI);
    }
    
    public function onUpdateGraphics(event:NodeEvent):void {
      //redrawMindmapStage();
      GraphMind.i.stageManager.structureDrawer.refreshGraphics();
    }
        
    public function getChildNodeAll():ArrayCollection {
      return _childs;
    }
    
    public function getChildNodeAt(index:int):ITreeNode {
      return _childs.getItemAt(index) as ITreeNode;
    }
    
    public function getChildNodeIndex(child:ITreeNode):int {
      return _childs.getItemIndex(child);
    }
    
    public function removeChildNodeAll():void {
      _childs.removeAll();
    }
    
    public function removeChildNodeAt(index:int):void {
      _childs.removeItemAt(index);
    }
    
    /**
     * Add a new child node.
     */
    public function addChildNode(node:NodeController):void {
      // Add node as a new child
      this._childs.addItem(node);
      node.parent = this;
      
      // Open subtree.
      uncollapseChilds();
      
      // Showing toggle-subtree button.
      nodeView._displayComp.icon_has_child.visible = true;
      
      // Not necessary to fire NODE_ATTCHED event. MOVED and CREATED covers this.
      update(UP_SUBTREE_UI);
    }
    
    public function collapse():void {
      _isForcedCollapsed = true;
      collapseChilds();
    }
    
    public function collapseChilds():void {
      _isCollapsed = true;
      nodeView._displayComp.icon_has_child.source = nodeView._displayComp.image_node_uncollapse;
      for each (var nodeItem:NodeController in _childs) {
        nodeItem.nodeView.visible = false;
        nodeItem.collapseChilds();
      }
      update(UP_TIME | UP_SUBTREE_UI);
    }
    
    public function uncollapse():void {
      _isForcedCollapsed = false;
      uncollapseChilds();
    }
    
    public function uncollapseChilds(forceOpenSubtree:Boolean = false):void {
      _isCollapsed = false;
      nodeView._displayComp.icon_has_child.source = nodeView._displayComp.image_node_collapse;
      for each (var nodeItem:NodeController in _childs) {
        nodeItem.nodeView.visible = true;
        if (!nodeItem._isForcedCollapsed || forceOpenSubtree) {
          nodeItem.uncollapseChilds(forceOpenSubtree);
        }
      }
      update(UP_TIME | UP_SUBTREE_UI);
    }
    
    public function _setBackgroundEffect(effect:int = EFFECT_NORMAL):void {
      nodeView._backgroundComp.filters = (effect == EFFECT_NORMAL) ? [] : [_nodeInnerGlowFilter, _nodeGlowFilter];
    }

    /**
     * Add icon.
     */
    public function addIcon(source:String):void {
      // Getting the normal icon name only
      var iconName:String = StringUtility.iconUrlToIconName(source);
      
      // Icon is already exists
      for each (var _iconName:String in nodeData._icons) {
        // It already exists.
        if (_iconName == iconName) return;
      }
      
      var icon:Image = new Image();
      icon.source = source;
      icon.y = 2;
      
      nodeView.addIcon(icon);
      nodeData.addIcon(iconName);
      
      if (GraphMind.i.applicationManager.isEditable()) {
        icon.doubleClickEnabled = true;
        icon.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick_icon);
      }
    
      update(UP_TIME | UP_SUBTREE_UI);
    }
    
	}
	
}