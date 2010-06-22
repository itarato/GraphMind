package com.graphmind.display {
	
	import com.graphmind.ConnectionManager;
	import com.graphmind.GraphMindManager;
	import com.graphmind.PluginManager;
	import com.graphmind.TreeManager;
	import com.graphmind.data.NodeData;
	import com.graphmind.event.NodeEvent;
	import com.graphmind.temp.TempItemLoadData;
	import com.graphmind.util.Log;
	import com.graphmind.util.StringUtility;
	import com.graphmind.view.TreeNodeUI;
	
	import flash.events.ContextMenuEvent;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
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

	public class TreeNodeController extends NodeController implements ITreeItem, ICloud {
		
		// Node access caches
		public static var nodes:ArrayCollection = new ArrayCollection();
		
		public static const HOOK_NODE_CONTEXT_MENU:String  = 'node_context_menu';
		public static const HOOK_NODE_MOVED:String         = 'node_moved';
		public static const HOOK_NODE_DELETE:String		   = 'node_delete';
		public static const HOOK_NODE_CREATED:String	   = 'node_created';
		public static const HOOK_NODE_TITLE_CHANGED:String = 'node_title_changed';
		
		protected var _childs:ArrayCollection 		 = new ArrayCollection();
		protected var _isCollapsed:Boolean 		 	 = false;
		protected var _isForcedCollapsed:Boolean 	 = false;
		protected var _parentNode:TreeNodeController = null;
		protected var _hasPath:Boolean 				 = false;
		protected var _isCloud:Boolean				 = false;
		
		// Time delay until selecting a node on mouseover
		protected var _mouseSelectionTimeout:uint;
		
		// UI icons
		public var _icons:ArrayCollection = new ArrayCollection();
		
		// ArrowLinks
		protected var _arrowLinks:ArrayCollection = new ArrayCollection(); 
		
		public function TreeNodeController(nodeData:NodeData) {
			super(nodeData);
			
			_nodeUI = new TreeNodeUI(this);
			
			// Attach data object
			this._nodeItemData = nodeData;
			
			getUI().initGraphics();
			
			TreeManager.getInstance().dispatchEvent(new NodeEvent(NodeEvent.CREATED, this));
			
			_hasPath = _nodeItemData.getPath().length > 0;
			
			TreeNodeController.nodes.addItem(this);
		}
		
		public function onClick_ToggleSubtreeButton(event:MouseEvent):void {
			if (!this._isCollapsed) {
				collapse();
			} else {
				uncollapse();
			}
			TreeManager.getInstance().setMindmapUpdated();
			TreeManager.getInstance().dispatchEvent(new NodeEvent(NodeEvent.UPDATE_GRAPHICS, this));
			event.stopPropagation();
		}
		
		public function onMouseDown(event:MouseEvent):void {
			if (!GraphMindManager.getInstance().isEditable()) return;
			
			TreeManager.getInstance().prepaireDragAndDrop();
			event.stopImmediatePropagation();
		}
		
		public function onMouseUp(event:MouseEvent):void {
			if (!GraphMindManager.getInstance().isEditable()) return;
			
			if ((!TreeManager.getInstance().isPrepairedNodeDragAndDrop) && TreeManager.getInstance().isNodeDragAndDrop) {
				
				if (_nodeUI.mouseX / getUI().getWidth() > (1 - _nodeUI.mouseY / getUI().getHeight())) {
					TreeNodeController.move(TreeManager.getInstance().dragAndDrop_sourceNode, this);
				} else {
					TreeNodeController.moveToPrevSibling(TreeManager.getInstance().dragAndDrop_sourceNode, this);
				}
				TreeManager.getInstance().onMouseUp_MindmapStage();
				
				TreeManager.getInstance().dispatchEvent(new NodeEvent(NodeEvent.DRAG_AND_DROP_FINISHED, this));
			}
		}
		
		public function onMouseMove(event:MouseEvent):void {
			if (!GraphMindManager.getInstance().isEditable()) return;
			
			if ((!TreeManager.getInstance().isPrepairedNodeDragAndDrop) && TreeManager.getInstance().isNodeDragAndDrop) {
				if (getTreeNodeUI().mouseX / getUI().getWidth() > (1 - getTreeNodeUI().mouseY / TreeNodeUI.HEIGHT)) {
					getTreeNodeUI()._displayComp.insertLeft.visible = true;
					getTreeNodeUI()._displayComp.insertUp.visible = false;
				} else {
					getTreeNodeUI()._displayComp.insertLeft.visible = false;
					getTreeNodeUI()._displayComp.insertUp.visible = true;
				}
			}
		}
		
		public function onContextMenuSelected_AddSimpleNode(event:ContextMenuEvent):void {
			addSimpleChildNode();
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
		
		public function onClick(event:MouseEvent):void {
		}
		
		public function onMouseOver(event:MouseEvent):void {
			_mouseSelectionTimeout = setTimeout(selectNode, 400);
			getTreeNodeUI()._displayComp.icon_add.visible = true && GraphMindManager.getInstance().isEditable();
			getTreeNodeUI()._displayComp.icon_anchor.visible = true && _hasPath;
		}
		
		public function onMouseOut(event:MouseEvent):void {
			clearTimeout(_mouseSelectionTimeout);
			getTreeNodeUI()._displayComp.icon_add.visible = false;
			getTreeNodeUI()._displayComp.icon_anchor.visible = false;
			
			if (TreeManager.getInstance().isPrepairedNodeDragAndDrop) {
				TreeManager.getInstance().openDragAndDrop(this);
			}
			
			getTreeNodeUI()._displayComp.insertLeft.visible = false;
			getTreeNodeUI()._displayComp.insertUp.visible = false;
		}
		
		public function onDoubleClick(event:MouseEvent):void {
			if (!GraphMindManager.getInstance().isEditable()) return;
			
			getTreeNodeUI()._displayComp.currentState = 'edit_title';
			getTreeNodeUI()._displayComp.title_new.text = getTreeNodeUI()._displayComp.title_label.text;
			getTreeNodeUI()._displayComp.title_new.setFocus();
		}
		
		public function onKeyUp_TitleTextField(event:KeyboardEvent):void {
			if (!GraphMindManager.getInstance().isEditable()) return;
			
			if (event.keyCode == Keyboard.ENTER) {
				getTreeNodeUI()._displayComp.currentState = '';
				setTitle(getTreeNodeUI()._displayComp.title_new.text);
				GraphMind.instance.setFocus();
				selectNode();
			} else if (event.keyCode == Keyboard.ESCAPE) {
				getTreeNodeUI()._displayComp.currentState = '';
				getTreeNodeUI()._displayComp.title_new.text = getTreeNodeUI()._displayComp.title_label.text;
			}
		}
		
		public function onFocusOut_TitleTextField(event:FocusEvent):void {
			if (!GraphMindManager.getInstance().isEditable()) return;
			
			// @TODO this is a duplication of the onNewTitleKeyUp() (above)
			getTreeNodeUI()._displayComp.currentState = '';
			_nodeItemData.title = getTreeNodeUI()._displayComp.title_label.text = getTreeNodeUI()._displayComp.title_new.text;
			GraphMind.instance.setFocus();
		}
		
		public function onItemLoaderSelectorClick(event:MouseEvent):void {
			event.stopPropagation();
			selectNode();
			GraphMind.instance.panelLoadView.view_arguments.text = _nodeItemData.getDrupalID();
		}
		
		public function onClick_AddSimpleNodeButton(event:MouseEvent):void {
			if (!GraphMindManager.getInstance().isEditable()) return;
			
			event.stopPropagation();
			event.stopImmediatePropagation();
			event.preventDefault();
			addSimpleChildNode();
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
			var ur:URLRequest = new URLRequest(_nodeItemData.getPath());
			navigateToURL(ur, '_blank');
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
		
		public function addChildNodeWithStageRefresh(node:TreeNodeController):void {
			addChildNode(node);
			
			// Add UI to the stage
			TreeManager.getInstance().addNodeToStage(node.getUI().getUIComponent());
		}
		
		/**
		 * Add a new child node to the node
		 */
		public function addChildNode(node:ITreeNode):void {
			// Add node as a new child
			this._childs.addItem(node);
			(node as TreeNodeController)._parentNode = this;
			
			// Open subtree.
			this.uncollapseChilds();
			// Showing toggle-subtree button.
			getTreeNodeUI()._displayComp.icon_has_child.visible = true;
			
			// Not necessary to fire NODE_ATTCHED event. MOVED and CREATED covers this.
		}
		
		public function collapse():void {
			_isForcedCollapsed = true;
			collapseChilds();
		}
		
		public function collapseChilds():void {
			_isCollapsed = true;
			getTreeNodeUI()._displayComp.icon_has_child.source = getTreeNodeUI()._displayComp.image_node_uncollapse;
			for each (var nodeItem:TreeNodeController in _childs) {
				nodeItem.getTreeNodeUI().visible = false;
				nodeItem.collapseChilds();
			}
			TreeManager.getInstance().setMindmapUpdated();
			TreeManager.getInstance().dispatchEvent(new NodeEvent(NodeEvent.UPDATE_GRAPHICS, this));
		}
		
		public function uncollapse():void {
			_isForcedCollapsed = false;
			uncollapseChilds();
		}
		
		public function uncollapseChilds(forceOpenSubtree:Boolean = false):void {
			_isCollapsed = false;
			getTreeNodeUI()._displayComp.icon_has_child.source = getTreeNodeUI()._displayComp.image_node_collapse;
			for each (var nodeItem:TreeNodeController in _childs) {
				nodeItem.getTreeNodeUI().visible = true;
				if (!nodeItem._isForcedCollapsed || forceOpenSubtree) {
					nodeItem.uncollapseChilds(forceOpenSubtree);
				}
			}
			TreeManager.getInstance().setMindmapUpdated();
			TreeManager.getInstance().dispatchEvent(new NodeEvent(NodeEvent.UPDATE_GRAPHICS, this));
		}
		
			
		public override function getContextMenu():ContextMenu {
			var contextMenu:ContextMenu = new ContextMenu();
			contextMenu.customItems = [];
			contextMenu.hideBuiltInItems();
			
			var cms:Array = [
				{title: 'Add node',        event: onContextMenuSelected_AddSimpleNode,    separator: false},
				{title: 'Add Drupal item', event: onContextMenuSelected_AddDrupalItem, 	 separator: false},
				{title: 'Add Views list',  event: onContextMenuSelected_AddDrupalViews,   separator: false},
				{title: 'Remove node',     event: onContextMenuSelected_RemoveNode,       separator: true},
				{title: 'Remove childs',   event: onContextMenuSelected_RemoveNodeChilds, separator: false},
				{title: 'Open subtree',    event: onContextMenuSelected_OpenSubtree,      separator: true},
				{title: 'Toggle cloud',    event: onContextMenuSelected_ToggleCloud,      separator: false}
			];
			
			if (NodeData.updatableTypes.indexOf(_nodeItemData.type) >= 0) {
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
		public override function selectNode():void {
			super.selectNode();
			
			var isTheSameSelected:Boolean = isSelected();
			
			// Not to lose focus from textfield
			if (!isTheSameSelected) getUI().getUIComponent().setFocus();
			
			// @TODO mystery bug steal highlight somethimes from nodes
			if (TreeManager.getInstance().activeNode) {
				TreeManager.getInstance().activeNode.unselectNode();
			}
			TreeManager.getInstance().activeNode = this;
			TreeManager.getInstance().selectedNodeData = new ArrayCollection();
			for (var key:* in _nodeItemData.data) {
				TreeManager.getInstance().selectedNodeData.addItem({
					key: key,
					value: _nodeItemData.data[key]
				});
			}
			
			GraphMind.instance.mindmapToolsPanel.node_info_panel.nodeLabelRTE.htmlText = getTreeNodeUI()._displayComp.title_label.htmlText || getTreeNodeUI()._displayComp.title_label.text;
				
			if (!isTheSameSelected) {
				GraphMind.instance.mindmapToolsPanel.node_info_panel.link.text = _nodeItemData.getPath();
				GraphMind.instance.mindmapToolsPanel.node_attributes_panel.attributes_update_param.text = '';
				GraphMind.instance.mindmapToolsPanel.node_attributes_panel.attributes_update_value.text = '';
			}
				
			getTreeNodeUI()._setBackgroundEffect(TreeNodeUI.EFFECT_HIGHLIGHT);
		}
		
		public override function unselectNode():void {
			super.unselectNode();
			
			getTreeNodeUI()._setBackgroundEffect(TreeNodeUI.EFFECT_NORMAL);
		}
		
		public function exportToFreeMindFormat():String {
			//var titleIsHTML:Boolean = _displayComponent.title_label.text != _displayComponent.title_label.htmlText;
			var titleIsHTML:Boolean = _nodeItemData.title.toString().indexOf('<') >= 0;
			
			// Base node information
			var output:String = '<node ' + 
				'CREATED="'  + _nodeItemData.created   + '" ' + 
				'MODIFIED="' + _nodeItemData.modified  + '" ' + 
				'ID="'       + _nodeItemData.id        + '" ' + 
				'FOLDED="'   + (_isForcedCollapsed ? 'true' : 'false') + '" ' + 
				(titleIsHTML ? '' : 'TEXT="' + escape(_nodeItemData.title) + '" ') + 
				(_nodeItemData.getPath().toString().length > 0 ? ('LINK="' + escape(_nodeItemData.getPath()) + '" ') : '') + 
				'TYPE="' + _nodeItemData.type + '" ' +
				">\n";
			
			if (titleIsHTML) {
				output = output + "<richcontent TYPE=\"NODE\"><html><head></head><body>" + 
					_nodeItemData.title + 
					"</body></html></richcontent>";
			}
			
			var key:*;
			for (key in _nodeItemData.data) {
				output = output + '<attribute NAME="' + escape(key) + '" VALUE="' + escape(_nodeItemData.data[key]) + '"/>' + "\n";
			}
			
			if (_nodeItemData.source) {
				output = output + '<site URL="' + escape(_nodeItemData.source.url) + '" USERNAME="' + escape(_nodeItemData.source.username) + '"/>' + "\n";
			}
			
			for each (var icon:* in _icons) {
				output = output + '<icon BUILTIN="' + StringUtility.iconUrlToIconName((icon as Image).source.toString()) + '"/>' + "\n";
			}
			
			if (_isCloud) {
				output = output + '<cloud/>' + "\n";
			}
			
			// Add childs
			for each (var child:TreeNodeController in _childs) {
				output = output + child.exportToFreeMindFormat();
			}
			
			return output + '</node>' + "\n";
		}
		
		protected function loadItem():void {
			selectNode();
			GraphMind.instance.currentState = 'load_item_state';
		}
		
		protected function loadViews():void {
			selectNode();
			GraphMind.instance.currentState = 'load_view_state';
			GraphMind.instance.panelLoadView.view_arguments.text = _nodeItemData.getDrupalID();
		}
		
		protected function addSimpleChildNode():void {
			selectNode();
			TreeManager.getInstance().createSimpleChildNode(this);
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
		public override function kill(killedDirectly:Boolean = true):void {
			if (TreeManager.getInstance().rootNode === this) return;
			
			// @HOOK
			PluginManager.callHook(HOOK_NODE_DELETE, {node: this, directKill: killedDirectly});
			
			// Remove all children the same way.
			_removeNodeChilds(false);
			
			if (_parentNode) {
				// Remove parent's child (this child).
				_parentNode._childs.removeItemAt(_parentNode._childs.getItemIndex(this));
				// Check parent's toggle-subtree button. With no child it should be hidden.
				_parentNode.getTreeNodeUI()._displayComp.icon_has_child.visible = _parentNode._childs.length > 0;
			}
			// Remove main UI element.
			getTreeNodeUI()._displayComp.parent.removeChild(getTreeNodeUI()._displayComp);
			// Remove the whole UI.
			getTreeNodeUI().parent.removeChild(this.getTreeNodeUI());
			
			// Remove from the global storage
			nodes.removeItemAt(nodes.getItemIndex(this));
			
			// Update tree.
			TreeManager.getInstance().setMindmapUpdated();
			TreeManager.getInstance().dispatchEvent(new NodeEvent(NodeEvent.UPDATE_GRAPHICS, this));
			
			delete this; // :.(
		}
		
		public function isChild(node:TreeNodeController):Boolean {
			for each (var child:TreeNodeController in _childs) {
				if (child == node) {
					return true;
				}
				if (child.isChild(node)) return true;
			}
			
			return false;
		}
		
		public static function move(source:TreeNodeController, target:TreeNodeController, callEvent:Boolean = true):Boolean {
			// No parent can detach child.
			if (!source || !source._parentNode || !target) return false;
			// Target is an ascendant of the source.
			if (source.isChild(target)) return false;
			// Source is equal to target
			if (source == target) return false;
			
			// Remove source from parents childs
			source.removeFromParentsChilds();
			// Add source to target
			target.addChildNode(source);
			// Refresh display
			TreeManager.getInstance().setMindmapUpdated();
			// Calling event with the value of NULL indicates that a full update is needed.
			TreeManager.getInstance().dispatchEvent(new NodeEvent(NodeEvent.UPDATE_GRAPHICS));
			
			if (callEvent) {
				// Call hook
				PluginManager.callHook(HOOK_NODE_MOVED, {node: source});
				TreeManager.getInstance().dispatchEvent(new NodeEvent(NodeEvent.MOVED, source));
			}
			
			return true;
		}
		
		public static function moveToPrevSibling(source:TreeNodeController, target:TreeNodeController):void {
			if (move(source, target._parentNode, false)) {
				var siblingIDX:int = target._parentNode._childs.getItemIndex(target);
				if (siblingIDX == -1) {
					return;
				}
				
				for (var i:int = target._parentNode._childs.length - 1; i > siblingIDX; i--) {
					target._parentNode._childs[i] = target._parentNode._childs[i - 1];
				}
				
				target._parentNode._childs.setItemAt(source, siblingIDX);
				
				// Refresh after reordering
				TreeManager.getInstance().setMindmapUpdated();
				TreeManager.getInstance().dispatchEvent(new NodeEvent(NodeEvent.UPDATE_GRAPHICS));
				
				// Call hook
				PluginManager.callHook(HOOK_NODE_MOVED, {node: source});
				TreeManager.getInstance().dispatchEvent(new NodeEvent(NodeEvent.MOVED, source));
			}
		}
		
		protected function removeFromParentsChilds():void {
			// Fix source's old parent's has_child icon
			var parentNode:TreeNodeController = _parentNode;
			
			var childIDX:int = _parentNode._childs.getItemIndex(this);
			if (childIDX >= 0) {
				this._parentNode._childs.removeItemAt(childIDX);
			}
			
			parentNode.getTreeNodeUI()._displayComp.icon_has_child.visible = parentNode._childs.length > 0;
		}
		
		public function addIcon(source:String):void {
			// Icon is already exists
			for each (var ico:Image in _icons) {
				if (ico.source == source) return;
			}
			
			// Getting the normal icon name only
			var iconName:String = StringUtility.iconUrlToIconName(source);
			
			var icon:Image = new Image();
			icon.source = source;
			icon.y = 2;
			getTreeNodeUI()._displayComp.addChild(icon);
			_icons.addItem(icon);
			if (GraphMindManager.getInstance().isEditable()) {
				icon.doubleClickEnabled = true;
				icon.addEventListener(MouseEvent.DOUBLE_CLICK, removeIcon);
			}
		
			getUI().refreshGraphics();
			redrawParentsClouds();
			
			updateTime();
 		}
 		
 		public function removeIcon(event:MouseEvent):void {
 			var iconIDX:int = _icons.getItemIndex(event.currentTarget as Image);
 			if (iconIDX == -1) return;
 			_icons.removeItemAt(iconIDX);
 			getTreeNodeUI()._displayComp.removeChild(event.currentTarget as Image);
			_nodeUI.refreshGraphics();
 			redrawParentsClouds();
 			
 			updateTime();
 		}
 		
		public function onUpdateComplete_TitleLabel(event:FlexEvent):void {
			getUI().refreshGraphics();
			// @TODO refreshing subtree is enough
			TreeManager.getInstance().dispatchEvent(new NodeEvent(NodeEvent.UPDATE_GRAPHICS, this));
			redrawParentsClouds();
		}
		
		public function setLink(link:String):void {
			_nodeItemData.link = link;
			getTreeNodeUI()._displayComp.icon_anchor.visible = _hasPath = link.length > 0;
			updateTime();
			TreeManager.getInstance().setMindmapUpdated();
		}
		
		public function onContextMenuSelected_OpenSubtree(event:ContextMenuEvent):void {
			uncollapseChilds(true);
		}
		
		public function toggleCloud():void {
			_isCloud ? disableCloud() : enableCloud();
		}
		
		public function enableCloud():void {
		  _isCloud = true;
		  
      TreeManager.getInstance().setMindmapUpdated();
      TreeManager.getInstance().dispatchEvent(new NodeEvent(NodeEvent.UPDATE_GRAPHICS, this));
		}
		
		public function disableCloud():void {
		  _isCloud = false;
          
      TreeManager.getInstance().setMindmapUpdated();
      TreeManager.getInstance().dispatchEvent(new NodeEvent(NodeEvent.UPDATE_GRAPHICS, this));
		}
		
		public function onContextMenuSelected_ToggleCloud(event:ContextMenuEvent):void {
			toggleCloud();
			updateTime();
		}
	
		public function onContextMenuSelected_UpdateDrupalItem(event:ContextMenuEvent):void {
			updateDrupalItem();
		}
		
		/**
		 * Refresh only the subtree and redraw the stage.
		 */
		public function redrawParentsClouds():void {
			_redrawParentsClouds();
			TreeManager.getInstance().dispatchEvent(new NodeEvent(NodeEvent.UPDATE_GRAPHICS, this));
		}
		
		protected function _redrawParentsClouds():void {
			if (_isCloud) {
				toggleCloud();
				toggleCloud();
			}
			
			if (_parentNode) _parentNode._redrawParentsClouds();
		}
		
		public function isCollapsed():Boolean {
			return _isCollapsed;
		}
		
		public function updateDrupalItem():void {
			var tild:TempItemLoadData = new TempItemLoadData();
			tild.nodeItemData = _nodeItemData;
			tild.success = updateDrupalItem_result;
			ConnectionManager.getInstance().itemLoad(tild);
		}
		
		public function updateDrupalItem_result(result:Object, tild:TempItemLoadData):void {
			for (var key:* in result) {
				_nodeItemData.data[key] = result[key];
			}
			_nodeItemData.title = null;
			_updateTitleLabel();
			selectNode();
		}
		
		public function getParentNode():ITreeNode {
			return _parentNode;
		}
		
		public function getArrowLinks():ArrayCollection {
			return _arrowLinks;
		}
		
		public function addArrowLink(arrowLink:TreeArrowLink):void {
			this._arrowLinks.addItem(arrowLink);
		}
		
		public function hasCloud():Boolean {
			return _isCloud;
		}
		
		public function getEqualChild(data:Object, type:String):TreeNodeController {
			for each (var child:TreeNodeController in _childs) {
				if (child._nodeItemData.equalTo(data, type)) return child;
			}
			return null;
		}
		
		public function getTitle():String {
			return _nodeItemData.title;
		}
		
		protected function _updateTitleLabel():void {
			getTreeNodeUI()._displayComp.title_label.text = _nodeItemData.title;
		}
		
		public function setTitle(title:String):void {
			_nodeItemData.title = getTreeNodeUI()._displayComp.title_label.htmlText = title;
			PluginManager.callHook(HOOK_NODE_TITLE_CHANGED, {node: this});
			updateTime();
		}
		
		public function hasChild():Boolean {
			return _childs.length > 0;
		}
		
		public function getTreeNodeUI():TreeNodeUI {
			return _nodeUI as TreeNodeUI;
		}
		
		public static function getLastSelectedNode():TreeNodeController {
			return TreeManager.getInstance().activeNode;
		}
		
		public function getTypeColor():uint {
			if (_nodeItemData.color) {
				return _nodeItemData.color;
			}
			
			switch (this._nodeItemData.type) {
				case NodeData.NODE:
					return 0xC2D7EF;
				case NodeData.COMMENT:
					return 0xC2EFD9;
				case NodeData.USER:
					return 0xEFD2C2;
				case NodeData.FILE:
					return 0xE9C2EF;
				case NodeData.TERM:
					return 0xD9EFC2;
				default:
					return 0xDFD9D1;
			}
		}
	}
}