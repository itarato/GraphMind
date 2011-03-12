package com.graphmind.display {
	
	import com.graphmind.ApplicationController;
	import com.graphmind.PluginManager;
	import com.graphmind.data.NodeData;
	import com.graphmind.data.NodeType;
	import com.graphmind.event.EventCenter;
	import com.graphmind.event.EventCenterEvent;
	import com.graphmind.event.NodeEvent;
	import com.graphmind.factory.NodeFactory;
	import com.graphmind.temp.TempItemLoadData;
	import com.graphmind.util.Log;
	import com.graphmind.util.StringUtility;
	import com.graphmind.view.NodeView;
	
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
	public class NodeViewController extends EventDispatcher implements IHasUI, ITreeItem, ICloud {
		
		// Node access caches
		public static var nodes:ArrayCollection = new ArrayCollection();
		
		/**
		 * Active node.
		 */
		public static var activeNode:NodeViewController;
		
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
    public static var dragAndDrop_sourceNode:NodeViewController;
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
    public var view:NodeView;
    
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
    public var parent:NodeViewController = null;
    
    /**
     * ArrowLinks
     */
    protected var _arrowLinks:ArrayCollection = new ArrayCollection();
    
    /**
    * Selection flag - true if the node is selected.
    */
    public var isSelected:Boolean = false;
    
    /**
     * Constructor.
     */ 
		public function NodeViewController(nodeData:NodeData, newNodeView:NodeView = null):void {
			super();
			
			this.nodeData = nodeData;
			
			if (newNodeView == null) {
			  newNodeView = ApplicationController.i.workflowComposite.createNodeView();
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
			
			view = newNodeView;
			
			nodeData.recalculateTitle(true);
			setTitle(nodeData.title);
			
			nodeData.recalculateDrupalID();
			
			view.backgroundColor = nodeData.color;
			
			nodes.addItem(this);
			     
      // HOOK
      PluginManager.callHook(NodeViewController.HOOK_NODE_CREATED, {node: this});
		}
		
		/**
		 * Create a simple empty child node.
		 * Don't use it for creating nodes. Use NodeFactory instead.
		 */
    public function createSimpleNodeChild():void {
      var node:NodeViewController = NodeFactory.createNode({}, NodeType.NORMAL);
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
		 * Select a single node on the mindmap stage.
		 * Only one node can be active at a time.
		 * Accessing to this node: TreeManager.getInstance().activeNode():NodeItem.
		 */
		public function selectNode():void {
		  EventCenter.notify(EventCenterEvent.NODE_SELECTED, this, this);
			var isTheSameSelected:Boolean = isSelected;
			
			// Not to lose focus from textfield
			if (!isTheSameSelected) view.setFocus();
			
			isSelected = true;

			_setBackgroundEffect(EFFECT_HIGHLIGHT);
		}
		
		
		/**
		 * Deselect node.
		 */
		public function deselectNode():void {
		  EventCenter.notify(EventCenterEvent.NODE_UNSELECTED, this, this);
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
//				output = output + '<site URL="' + escape(nodeData.source.target) + '" USERNAME="' + escape(nodeData.source.username) + '"/>' + "\n";
        output = output + '<site URL="' + escape(nodeData.source.target) + '" />' + "\n";
			}
			
			for each (var iconName:* in nodeData._icons) {
				output = output + '<icon BUILTIN="' + iconName + '"/>' + "\n";
			}
			
			for each (var arrowLink:TreeArrowLink in _arrowLinks) {
			  output = output + '<arrowlink DESTINATION="' + arrowLink.destinationNode.nodeData.id + '"/>' + "\n";
			}
			
			if (hasCloud()) {
				output = output + '<cloud/>' + "\n";
			}
			
			// Add childs
			for each (var child:NodeViewController in _childs) {
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
				(_childs.getItemAt(0) as NodeViewController).kill(killedDirectly);
			}
		}
		
		/**
		 * Kill a node and each childs.
		 */
		public function kill(killedDirectly:Boolean = true):void {
		  // Root can't be deleted.
			if (!parent) return;
			
			// @HOOK
			PluginManager.callHook(HOOK_NODE_DELETE, {node: this, directKill: killedDirectly});
			
			// Remove all children the same way.
			_removeNodeChilds(false);
			
			if (parent) {
				// Remove parent's child (this child).
				parent._childs.removeItemAt(parent._childs.getItemIndex(this));
				// Check parent's toggle-subtree button. With no child it should be hidden.
				parent.view._displayComp.icon_has_child.visible = parent._childs.length > 0;
			}

      // Remove arrow links.			
      for each (var arrowLink:TreeArrowLink in TreeArrowLink.arrowLinks) {
        if (arrowLink.destinationNode == this || arrowLink.sourceNode == this) {
          arrowLink.sourceNode.removeArrowLink(arrowLink);
        }
      }
			
			// Remove main UI element.
			view._displayComp.parent.removeChild(view._displayComp);
			// Remove the whole UI.
			view.parent.removeChild(this.view);
			
			// Remove from the global storage
			nodes.removeItemAt(nodes.getItemIndex(this));
			
			// Update tree.
			EventCenter.notify(EventCenterEvent.MAP_UPDATED, this, this);
			
			update(UP_SUBTREE_UI);
			
			delete this; // :.(
		}
		
		/**
		 * Check if the giveth node is a child of the self node.
		 */
		public function isChild(node:NodeViewController):Boolean {
			for each (var child:NodeViewController in _childs) {
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
		public static function move(source:NodeViewController, target:NodeViewController, callEvent:Boolean = true):Boolean {
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
				EventCenter.notify(EventCenterEvent.NODE_MOVED, source, source);
			}
			
			source.update(UP_TREE_UI);

			return true;
		}
		
		/**
		 * Move a node to a next sibling.
		 */
		public static function moveToPrevSibling(source:NodeViewController, target:NodeViewController):void {
			if (move(source, target.parent, false)) {
				var siblingIDX:int = target.parent._childs.getItemIndex(target) + 1;
				if (siblingIDX == -1) {
					return;
				}
				
				for (var i:int = target.parent._childs.length - 1; i > siblingIDX; i--) {
					target.parent._childs[i] = target.parent._childs[i - 1];
				}
				
				target.parent._childs.setItemAt(source, siblingIDX);
				
				// Refresh after reordering
				EventCenter.notify(EventCenterEvent.MAP_UPDATED);
				
				// Call hook
				PluginManager.callHook(HOOK_NODE_MOVED, {node: source});
				EventCenter.notify(EventCenterEvent.NODE_MOVED, source, source);
			}
		}    
		
    /**
     * Move a node to a next sibling.
     */
    public static function moveToNextSibling(source:NodeViewController, target:NodeViewController):void {
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
        EventCenter.notify(EventCenterEvent.MAP_UPDATED);
        
        // Call hook
        PluginManager.callHook(HOOK_NODE_MOVED, {node: source});
        EventCenter.notify(EventCenterEvent.NODE_MOVED, source, source);
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
			
			parent.view._displayComp.icon_has_child.visible = parent._childs.length > 0;
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
      view.removeIcon(icon.source.toString());
      update(UP_TIME | UP_SUBTREE_UI);
 		}
 		
 		/**
 		 * Set a link.
 		 */
		public function setLink(link:String):void {
			nodeData.link = link;
			view._displayComp.icon_anchor.visible = (link.length > 0);
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
			// @todo implement
//			ConnectionManager.itemLoad(tild);
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
			
			arrowLink.doubleClickEnabled = true;
			arrowLink.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick_arrowLink);
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
		public function getEqualChild(data:Object, type:String):NodeViewController {
			for each (var child:NodeViewController in _childs) {
				if (child.nodeData.equalTo(data, type)) return child;
			}
			return null;
		}

    /**
     * Set the title of the node. For title should be called every time!
     * 
     * @param boolean userChange - indicates if the change was done by user interaction.
     */
		public function setTitle(title:String, userChange:Boolean = false):void {
			nodeData.title = view._displayComp.title_label.htmlText = title;
			
			if (userChange) {
			  PluginManager.callHook(HOOK_NODE_TITLE_CHANGED, {node: this});
			}
			
			update(UP_TIME);
		}
		
		public function hasChild():Boolean {
			return _childs.length > 0;
		}
    
    public override function toString():String {
      return '[NodeViewController: ' + this.nodeData.id + ']';
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
        view.isGraphicsUpdated = true;
        view.refreshGraphics();
      }
      
      if (updateSet & (UP_SUBTREE_UI | UP_TREE_UI)) {
        view.isGraphicsUpdated = true;
        view.refreshGraphics();
        EventCenter.notify(EventCenterEvent.MAP_UPDATED);
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
      EventCenter.notify(EventCenterEvent.MAP_UPDATED);
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
      return view;
    }

    public function onMouseOver(event:MouseEvent):void {
      _mouseSelectionTimeout = setTimeout(selectNode, 400);
      view._displayComp.icon_add.visible = ApplicationController.i.isEditable();
      view._displayComp.icon_anchor.visible = nodeData.link.length > 0;
    }
    
    public function onMouseOut(event:MouseEvent):void {
      clearTimeout(_mouseSelectionTimeout);
      view._displayComp.icon_add.visible = false;
      view._displayComp.icon_anchor.visible = false;
      
      if (NodeViewController.isPrepairedNodeDragAndDrop) {
        EventCenter.notify(EventCenterEvent.NODE_START_DRAG, this, this);
      }
      
      view._displayComp.insertLeft.visible = false;
      view._displayComp.insertUp.visible = false;
    }
    
    public function onDoubleClick(event:MouseEvent):void {
      if (!ApplicationController.i.isEditable()) return;
      
      view._displayComp.currentState = 'edit_title';
      view._displayComp.title_new.text = view._displayComp.title_label.text;
      view._displayComp.title_new.setFocus();
    }
    
    public function onKeyUp_TitleTextField(event:KeyboardEvent):void {
      if (!ApplicationController.i.isEditable()) return;
      
      if (event.keyCode == Keyboard.ENTER) {
        view._displayComp.currentState = '';
        setTitle(view._displayComp.title_new.text, true);
        GraphMind.i.setFocus();
        selectNode();
      } else if (event.keyCode == Keyboard.ESCAPE) {
        view._displayComp.currentState = '';
        view._displayComp.title_new.text = view._displayComp.title_label.text;
      }
    }
    
    public function onFocusOut_TitleTextField(event:FocusEvent):void {
      if (!ApplicationController.i.isEditable()) return;
      
      // @TODO this is a duplication of the onNewTitleKeyUp() (above)
      view._displayComp.currentState = '';
      setTitle(view._displayComp.title_new.text, true);
      GraphMind.i.setFocus();
    }
    
    public function onItemLoaderSelectorClick(event:MouseEvent):void {
      event.stopPropagation();
      selectNode();
      GraphMind.i.panelLoadView.view_arguments.text = nodeData.drupalID.toString();
    }
    
    public function onClick_AddSimpleNodeButton(event:MouseEvent):void {
      if (!ApplicationController.i.isEditable()) return;
      
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
      if (!ApplicationController.i.isEditable()) return;
      
      EventCenter.notify(EventCenterEvent.NODE_PREPARE_DRAG, this, this);
      event.stopImmediatePropagation();
    }
    
    public function onMouseUp(event:MouseEvent):void {
      if (!ApplicationController.i.isEditable()) return;
      
      if ((!NodeViewController.isPrepairedNodeDragAndDrop) && NodeViewController.isNodeDragAndDrop) {
        
        if (view.mouseX / view.getWidth() > (1 - view.mouseY / view.getHeight())) {
          NodeViewController.move(NodeViewController.dragAndDrop_sourceNode, this);
        } else {
          NodeViewController.moveToPrevSibling(NodeViewController.dragAndDrop_sourceNode, this);
        }
        EventCenter.notify(EventCenterEvent.NODE_FINISH_DRAG, this, this);
      }
    }
    
    public function onMouseMove(event:MouseEvent):void {
      if (!ApplicationController.i.isEditable()) return;
      
      if ((!NodeViewController.isPrepairedNodeDragAndDrop) && NodeViewController.isNodeDragAndDrop) {
        if (view.mouseX / getUI().getWidth() > (1 - view.mouseY / NodeView.HEIGHT)) {
          view._displayComp.insertLeft.visible = true;
          view._displayComp.insertUp.visible = false;
        } else {
          view._displayComp.insertLeft.visible = false;
          view._displayComp.insertUp.visible = true;
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
      EventCenter.notify(EventCenterEvent.MAP_UPDATED);
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
    
    
    public function onDoubleClick_arrowLink(event:MouseEvent):void {
      removeArrowLink(event.target as TreeArrowLink);
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
    public function addChildNode(node:NodeViewController):void {
      // Add node as a new child
      this._childs.addItem(node);
      node.parent = this;
      
      // Open subtree.
      uncollapseChilds();
      
      // Showing toggle-subtree button.
      view._displayComp.icon_has_child.visible = true;
      
      // Not necessary to fire NODE_ATTCHED event. MOVED and CREATED covers this.
      update(UP_SUBTREE_UI);
    }
    
    public function collapse():void {
      _isForcedCollapsed = true;
      collapseChilds();
    }
    
    public function collapseChilds():void {
      _isCollapsed = true;
      view._displayComp.icon_has_child.source = view._displayComp.image_node_uncollapse;
      for each (var nodeItem:NodeViewController in _childs) {
        nodeItem.view.visible = false;
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
      view._displayComp.icon_has_child.source = view._displayComp.image_node_collapse;
      for each (var nodeItem:NodeViewController in _childs) {
        nodeItem.view.visible = true;
        if (!nodeItem._isForcedCollapsed || forceOpenSubtree) {
          nodeItem.uncollapseChilds(forceOpenSubtree);
        }
      }
      update(UP_TIME | UP_SUBTREE_UI);
    }
    
    public function _setBackgroundEffect(effect:int = EFFECT_NORMAL):void {
      view._backgroundComp.filters = (effect == EFFECT_NORMAL) ? [] : [_nodeInnerGlowFilter, _nodeGlowFilter];
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
      
      view.addIcon(icon);
      nodeData.addIcon(iconName);
      
      if (ApplicationController.i.isEditable()) {
        icon.doubleClickEnabled = true;
        icon.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick_icon);
      }
    
      update(UP_TIME | UP_SUBTREE_UI);
    }
    
    public function removeArrowLink(arrowLink:TreeArrowLink):void {
      TreeArrowLink.arrowLinks.removeItemAt(TreeArrowLink.arrowLinks.getItemIndex(arrowLink));
      _arrowLinks.removeItemAt(_arrowLinks.getItemIndex(arrowLink));
    }
    
	}
	
}
