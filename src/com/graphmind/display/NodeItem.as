package com.graphmind.display
{
	import com.graphmind.GraphMindManager;
	import com.graphmind.StageManager;
	import com.graphmind.data.NodeItemData;
	import com.graphmind.display.assets.ItemBaseComponent;
	import com.graphmind.util.ConnectionCreator;
	import com.graphmind.util.Log;
	
	import flash.display.Sprite;
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
	import mx.controls.Alert;
	import mx.core.UIComponent;
	
	//public class NodeItem extends DraggableItem {
	public class NodeItem extends DisplayItem {
		
		public static const WIDTH:int = 160;
		public static const HEIGHT:int = 20;
		public static const MARGIN_RIGHT:int = 32;
		public static const MARGIN_BOTTOM:int = 4;
		public static const ICON_WIDTH:int = 20;
		
		protected var _displayComponent:ItemBaseComponent = new ItemBaseComponent();
		protected var _connections:UIComponent = new UIComponent();
		protected var _nodeItemData:NodeItemData;
		protected var _childs:ArrayCollection = new ArrayCollection();
		protected var _isCollapsed:Boolean = false;
		protected var _isForcedCollapsed:Boolean = false;
		protected var _parentNode:NodeItem = null;
		protected var _background:Sprite = new Sprite();
		protected var _hasPath:Boolean = false;
		protected var _icons:ArrayCollection = new ArrayCollection();
		
		
		private var _mouseSelectionTimeout:uint;
		
		public function NodeItem(viewItem:NodeItemData) {
			super();
			this._nodeItemData = viewItem;
			
			_initDisplayElements();
			
			_initAttachEvents();
			
			if (GraphMindManager.getInstance().isEditable()) {
				_initCreateContextMenu();
			}
		}
		
		private function _initDisplayElements():void {
			this.addChild(_background);
			
			this.addChild(_displayComponent);
			
			_connections.graphics.lineStyle(2, 0x333333, 1);
			StageManager.getInstance().stage.desktop.addChild(_connections);
			
			this._displayComponent.title_label.htmlText = this._nodeItemData.title;
			
			this._background.graphics.beginFill(getTypeColor(), .2);
			this._background.graphics.drawRoundRect(0, 0, 160, 20, 10, 10);
			this._background.graphics.endFill();
		
			_hasPath = _nodeItemData.getPath().length > 0;
			
			this.buttonMode = true;
		}
			
		private function _initAttachEvents():void {
			if (GraphMindManager.getInstance().isEditable()) {
				this._displayComponent.title_label.doubleClickEnabled = true;
				this._displayComponent.title_label.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
				this._displayComponent.title_new.addEventListener(KeyboardEvent.KEY_UP, onNewTitleKeyUp);
				this._displayComponent.title_new.addEventListener(FocusEvent.FOCUS_OUT, onNewTitleFocusOut);
				this._displayComponent.icon_add.addEventListener(MouseEvent.CLICK, onLoadNodeClick);
				
				this._displayComponent.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				this._displayComponent.addEventListener(MouseEvent.MOUSE_UP,   onMouseUp);
				
				this._displayComponent.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			}
			
			this._displayComponent.addEventListener(MouseEvent.CLICK, onClick);
			this._displayComponent.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			this._displayComponent.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			this._displayComponent.icon_anchor.addEventListener(MouseEvent.CLICK, onIconAnchorClick);
			this._displayComponent.icon_has_child.addEventListener(MouseEvent.CLICK, onIconHasChildClick);
		}

		private function _initCreateContextMenu():void {
			var contextMenu:ContextMenu = new ContextMenu();
			contextMenu.customItems = [];
			contextMenu.hideBuiltInItems();
			
			var cms:Array = [
				{title: 'Add node',        event: onAddNodeSelect,       	separator: false},
				{title: 'Add Drupal item', event: onAddDrupalItemSelect, 	separator: false},
				{title: 'Add Views list',  event: onAddViewsListSelect,  	separator: false},
				{title: 'Remove node',     event: onRemoveNodeSelect,       separator: true},
				{title: 'Remove childs',   event: onRemoveNodeChildsSelect, separator: false}
			];
			
			for each (var cmData:Object in cms) {
				var cmi:ContextMenuItem = new ContextMenuItem(cmData.title,	cmData.separator);
				cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, cmData.event);
				contextMenu.customItems.push(cmi);
			}
			
			_displayComponent.contextMenu = contextMenu;
		}
		
		private function onMouseDown(event:MouseEvent):void {
			StageManager.getInstance().prepaireDragAndDrop();
		}
		
		private function onMouseUp(event:MouseEvent):void {
			if ((!StageManager.getInstance().isPrepairedDragAndDrop) && StageManager.getInstance().isDragAndDrop) {
				
				if (this.mouseX / this.getWidth() > (1 - this.mouseY / HEIGHT)) {
					NodeItem.move(StageManager.getInstance().dragAndDrop_sourceNodeItem, this);
				} else {
					NodeItem.moveToPrevSibling(StageManager.getInstance().dragAndDrop_sourceNodeItem, this);
				}
				StageManager.getInstance().closeDragAndDrop();
				
				_displayComponent.insertLeft.visible = false;
				_displayComponent.insertUp.visible = false;
			}
		}
		
		private function onMouseMove(event:MouseEvent):void {
			if ((!StageManager.getInstance().isPrepairedDragAndDrop) && StageManager.getInstance().isDragAndDrop) {
				if (this.mouseX / this.getWidth() > (1 - this.mouseY / HEIGHT)) {
					_displayComponent.insertLeft.visible = true;
					_displayComponent.insertUp.visible = false;
				} else {
					_displayComponent.insertLeft.visible = false;
					_displayComponent.insertUp.visible = true;
				}
			}
		}
		
		private function onAddNodeSelect(event:ContextMenuEvent):void {
			selectNode();
			loadNode();
		}
		
		private function onAddDrupalItemSelect(event:ContextMenuEvent):void {
			selectNode();
			loadItem();
		}
		
		private function onAddViewsListSelect(event:ContextMenuEvent):void {
			selectNode();
			StageManager.getInstance().stage.view_arguments.text = _nodeItemData.getDrupalID();
			loadViews();
		}
		
		private function onRemoveNodeSelect(event:ContextMenuEvent):void {
			remove();
		}
		
		private function onRemoveNodeChildsSelect(event:ContextMenuEvent):void {
			removeNodeChilds();
			StageManager.getInstance().refreshNodePositions();
		}
		
		private function onClick(event:MouseEvent):void {
			Log.info('node-click');
			selectNode();
		}
		
		private function onIconHasChildClick(event:MouseEvent):void {
			if (!this._isCollapsed) {
				collapse();
			} else {
				uncollapse();
			}
			event.stopPropagation();
		}
		
		private function onMouseOver(event:MouseEvent):void {
			trace('over');
			_mouseSelectionTimeout = setTimeout(selectNode, 400);
			_displayComponent.icon_add.visible = true;
			_displayComponent.icon_anchor.visible = true && _hasPath;
		}
		
		private function onMouseOut(event:MouseEvent):void {
			clearTimeout(_mouseSelectionTimeout);
			_displayComponent.icon_add.visible = false;
			_displayComponent.icon_anchor.visible = false;
			
			if (StageManager.getInstance().isPrepairedDragAndDrop) {
				StageManager.getInstance().openDragAndDrop(this);
				//trace(StageManager.getInstance().isPrepairedDragAndDrop.toString());
			}
			
			_displayComponent.insertLeft.visible = false;
			_displayComponent.insertUp.visible = false;
		}
		
		private function onDoubleClick(event:MouseEvent):void {
			_displayComponent.currentState = 'edit_title';
			_displayComponent.title_new.setFocus();
		}
		
		private function onNewTitleKeyUp(event:KeyboardEvent):void {
			if (event.keyCode == Keyboard.ENTER) {
				_displayComponent.currentState = '';
				title = _displayComponent.title_new.text;
				StageManager.getInstance().stage.setFocus();
			} else if (event.keyCode == Keyboard.ESCAPE) {
				_displayComponent.currentState = '';
			}
		}
		
		private function onNewTitleFocusOut(event:FocusEvent):void {
			// @TODO this is a duplication of the onNewTitleKeyUp() (above)
			_displayComponent.currentState = '';
			_nodeItemData.title = _displayComponent.title_label.text = _displayComponent.title_new.text;
			StageManager.getInstance().stage.setFocus();
		}
		
		private function onItemLoaderSelectorClick(event:MouseEvent):void {
			event.stopPropagation();
			Log.info('click on node: ' + this._nodeItemData.title); 
			selectNode();
			StageManager.getInstance().stage.view_arguments.text = _nodeItemData.getDrupalID();
		}
		
		private function onLoadNodeClick(event:MouseEvent):void {
			event.stopPropagation();
			event.stopImmediatePropagation();
			event.preventDefault();
			loadNode();
		}
		
		private function onLoadItemClick(event:MouseEvent):void {
			event.stopPropagation();
			loadItem();
		}
		
		private function onLoadViewClick(event:MouseEvent):void {
			event.stopPropagation();
			loadViews();
		}
		
		private function onIconAnchorClick(event:MouseEvent):void {
			var ur:URLRequest = new URLRequest(_nodeItemData.getPath());
			navigateToURL(ur, '_blank');
		}
		
		public function addNodeChild(node:NodeItem):void {
			this._childs.addItem(node);
			Log.info('new child: ' + this._childs.length);
			StageManager.getInstance().addChildToStage(node);
			node._parentNode = this;
			
			// Update display
			this.uncollapseChilds();
			this._displayComponent.icon_has_child.visible = true;
		}
		
		public function collapse():void {
			_isForcedCollapsed = true;
			collapseChilds();
		}
		
		public function collapseChilds():void {
			this._isCollapsed = true;
			for each (var nodeItem:NodeItem in _childs) {
				nodeItem.visible = false;
				nodeItem.collapseChilds();
			}
			StageManager.getInstance().refreshNodePositions();
		}
		
		public function uncollapse():void {
			_isForcedCollapsed = false;
			uncollapseChilds();
		}
		
		public function uncollapseChilds():void {
			this._isCollapsed = false;
			for each (var nodeItem:NodeItem in _childs) {
				nodeItem.visible = true;
				if (!nodeItem._isForcedCollapsed) {
					nodeItem.uncollapseChilds();
				}
			}
			StageManager.getInstance().refreshNodePositions();
		}
		
		/**
		 * Calculates the with of the subtree comes from this node.
		 * @return int
		 */
		private function childSubtreeWidth():int {
			if (_childs.length == 0 || _isCollapsed) {
				return 1;
			} else {
				var sum:int = 0;
				for each (var child:NodeItem in _childs) {
					sum += child.childSubtreeWidth();
				}
				return sum;
			}
		}
		
		/**
		 * Position child items.
		 */
		public function refreshChildNodePosition():void {
			this._connections.graphics.clear();
			
			var totalChildWidth:int = childSubtreeWidth();
			//Log.info('totalC: ' + totalChildWidth);
			var currentY:int = y - (totalChildWidth * (NodeItem.HEIGHT + NodeItem.MARGIN_BOTTOM)) / 2;
			for each (var child:NodeItem in _childs) {
				var childNum:int = child.childSubtreeWidth();
				//Log.info('childC: ' + childNum);
				child.x = x + getWidth() + NodeItem.MARGIN_RIGHT;
				child.y = currentY + (childNum * (NodeItem.HEIGHT + NodeItem.MARGIN_BOTTOM)) / 2; 
				child.refreshChildNodePosition();
				
				if (!_isCollapsed) {
					ConnectionCreator.drawConnection(_connections, this, child);
				}
				currentY += childNum * (NodeItem.HEIGHT + NodeItem.MARGIN_BOTTOM);
			}
		}
		
		private function getTypeColor():uint {
			switch (this._nodeItemData.type) {
				case NodeItemData.NODE:
					return 0x00345F;
				case NodeItemData.COMMENT:
					return 0x3A5F00;
				case NodeItemData.USER:
					return 0x5F0039;
				case NodeItemData.FILE:
					return 0x5F5F41;
				case NodeItemData.TERM:
					return 0x9F1333;
				default:
					return 0x333333;
			}
		}
		
		public function selectNode():void {
			Log.info(_nodeItemData.source.url);
			
			if (StageManager.getInstance().lastSelectedNode) {
				StageManager.getInstance().lastSelectedNode.unselectNode();
			}
			StageManager.getInstance().lastSelectedNode = this;
			StageManager.getInstance().selectedNodeData = new ArrayCollection();
			for (var key:* in _nodeItemData.data) {
				StageManager.getInstance().selectedNodeData.addItem({
					key: key,
					value: _nodeItemData.data[key]
				});
			}
			_displayComponent.selection.visible = true;
			
			StageManager.getInstance().stage.nodeLabelRTE.htmlText = _displayComponent.title_label.htmlText;
			
			_displayComponent.title_new.text = _displayComponent.title_label.text;
			
			StageManager.getInstance().stage.link.text = _nodeItemData.getPath();
		}
		
		public function unselectNode():void {
			_displayComponent.selection.visible = false;
		}
		
		public function exportToFreeMindFormat():String {
			//var titleIsHTML:Boolean = _displayComponent.title_label.text != _displayComponent.title_label.htmlText;
			var titleIsHTML:Boolean = _nodeItemData.title.toString().indexOf('<') >= 0;
			
			// Bade node information
			var output:String = '<node ' + 
				'CREATED="'  + _nodeItemData.created   + '" ' + 
				'MODIFIED="' + _nodeItemData.modified  + '" ' + 
				'ID="ID_'    + _nodeItemData.id        + '" ' + 
				'FOLDED="'   + (_isForcedCollapsed ? 'true' : 'false') + '" ' + 
				(titleIsHTML ? '' : 'TEXT="' + encodeURIComponent(_nodeItemData.title) + '" ') + 
				(_nodeItemData.getPath().toString().length > 0 ? ('LINK="' + encodeURIComponent(_nodeItemData.getPath()) + '"') : '') + 
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
			
			var attributes_confidental:Object = {};
			if (_nodeItemData.source) {
				attributes_confidental.__site_url      = escape(_nodeItemData.source.url);
				attributes_confidental.__site_username = escape(_nodeItemData.source.username);
			}
			attributes_confidental.__node_type = _nodeItemData.type;
			for (key in attributes_confidental) {
				output = output + '<attribute NAME="' + escape(key) + '" VALUE="' + escape(attributes_confidental[key]) + '"/>' + "\n";
			}
			
			// Add childs
			for each (var child:NodeItem in _childs) {
				output = output + child.exportToFreeMindFormat();
			}
			
			return output + '</node>' + "\n";
		}
		
		public function get data():Object {
			return _nodeItemData.data;
		}
		
		private function loadItem():void {
			StageManager.getInstance().stage.currentState = 'load_item_state';
		}
		
		private function loadViews():void {
			StageManager.getInstance().stage.currentState = 'load_view_state';
		}
		
		private function loadNode():void {
			StageManager.getInstance().onNewNormalNodeClick(this);
		}
		
		private function remove():void {
			removeNodeChilds();
			_displayComponent.parent.removeChild(_displayComponent);
			_connections.parent.removeChild(_connections);
			parent.removeChild(this);
			if (_parentNode) {
				_parentNode._childs.removeItemAt(_parentNode._childs.getItemIndex(this));
				_parentNode._displayComponent.icon_has_child.visible = _parentNode._childs.length > 0;
			}
			StageManager.getInstance().refreshNodePositions();
		}
		
		private function removeNodeChilds():void {
			while (_childs.length > 0) {
				var child:NodeItem = _childs.removeItemAt(0) as NodeItem;
				child._displayComponent.parent.removeChild(child._displayComponent);
				child._connections.parent.removeChild(child._connections);
				child.removeNodeChilds();
				child.parent.removeChild(child);
			}
			_displayComponent.icon_has_child.visible = false;
		}
		
		public function dataDelete(param:String):void {
			_nodeItemData.dataDelete(param);
		}
		
		public function isChild(node:NodeItem):Boolean {
			for each (var child:NodeItem in _childs) {
				if (child == node) {
					return true;
				}
				if (child.isChild(node)) return true;
			}
			
			return false;
		}
		
		public static function move(source:NodeItem, target:NodeItem):Boolean {
			// @TODO validation !!!
			// No parent can detach child.
			if (!source || !source._parentNode || !target) return false;
			// Target is an ascendant of the source.
			if (source.isChild(target)) return false;
			// Source is equal to target
			if (source == target) return false;
			
			// Remove source from parents childs
			source.removeFromPatentsChilds();
			// Add source to target
			target.addNodeChild(source);
			// Refresh display
			StageManager.getInstance().refreshNodePositions();
			
			return true;
		}
		
		public static function moveToPrevSibling(source:NodeItem, target:NodeItem):void {
			if (move(source, target._parentNode)) {
				var siblingIDX:int = target._parentNode._childs.getItemIndex(target);
				if (siblingIDX == -1) {
					Alert.show('ERROR');
					return;
				}
				
				for (var i:int = target._parentNode._childs.length - 1; i > siblingIDX; i--) {
					//target._parentNode._childs.setItemAt(target._parentNode._childs.getItemAt(i - 1), i);
					target._parentNode._childs[i] = target._parentNode._childs[i - 1];
				}
				
				target._parentNode._childs.setItemAt(source, siblingIDX);
				
				StageManager.getInstance().refreshNodePositions();
			}
		}
		
		private function removeFromPatentsChilds():void {
			// Fix source's old parent's has_child icon
			var parentNode:NodeItem = _parentNode;
			
			var childIDX:int = _parentNode._childs.getItemIndex(this);
			if (childIDX >= 0) {
				this._parentNode._childs.removeItemAt(childIDX);
			}
			
			parentNode._displayComponent.icon_has_child.visible = parentNode._childs.length > 0;
		}
			
		
		public function getWidth():int {
			return WIDTH + _icons.length * ICON_WIDTH;
		}
		
		public function addIcon():void {
			
		}
		
		public function set title(title:String):void {
			_nodeItemData.title = _displayComponent.title_label.htmlText = title;
		}
		
		public function set link(link:String):void {
			_nodeItemData.link = link;
			_displayComponent.icon_anchor.visible = _hasPath = link.length > 0;
		}
	}
}