package com.graphmind.display
{
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
	import mx.core.UIComponent;
	
	//public class NodeItem extends DraggableItem {
	public class NodeItem extends DisplayItem {
		
		public static const WIDTH:int = 160;
		public static const HEIGHT:int = 18;
		public static const MARGIN_RIGHT:int = 32;
		public static const MARGIN_BOTTOM:int = 4;
		
		protected var _displayComponent:ItemBaseComponent = new ItemBaseComponent();
		protected var _connections:UIComponent = new UIComponent();
		protected var _nodeItemData:NodeItemData;
		protected var _childs:ArrayCollection = new ArrayCollection();
		protected var _isCollapsed:Boolean = false;
		protected var _isForcedCollapsed:Boolean = false;
		protected var _parentNode:NodeItem = null;
		protected var _background:Sprite = new Sprite();
		protected var _hasPath:Boolean = false;		
		
		
		private var _mouseSelectionTimeout:uint;
		
		public function NodeItem(viewItem:NodeItemData) {
			super();
			this._nodeItemData = viewItem;
			
			_initDisplayElements();
			
			_initAttachEvents();
			
			_initCreateContextMenu();
		}
		
		private function _initDisplayElements():void {
			this.addChild(_background);
			
			this.addChild(_displayComponent);
			
			_connections.graphics.lineStyle(2, 0x333333, 1);
			StageManager.getInstance().stage.desktop.addChild(_connections);
			
			this._displayComponent.title_label.text = this._nodeItemData.title;
			
			this._background.graphics.beginFill(getTypeColor(), .4);
			this._background.graphics.drawRoundRect(0, 0, 160, 18, 10, 10);
			this._background.graphics.endFill();
		
			_hasPath = _nodeItemData.getDrupalPath().length > 0;
			
			this.buttonMode = true;
		}
			
		private function _initAttachEvents():void {
			this._displayComponent.addEventListener(MouseEvent.CLICK, onClick);
			this._displayComponent.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			this._displayComponent.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			this._displayComponent.title_label.doubleClickEnabled = true;
			this._displayComponent.title_label.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
			this._displayComponent.title_new.addEventListener(KeyboardEvent.KEY_UP, onNewTitleKeyUp);
			this._displayComponent.title_new.addEventListener(FocusEvent.FOCUS_OUT, onNewTitleFocusOut);
			this._displayComponent.icon_has_child.addEventListener(MouseEvent.CLICK, onIconHasChildClick);
			this._displayComponent.icon_add.addEventListener(MouseEvent.CLICK, onLoadNodeClick);
			this._displayComponent.icon_anchor.addEventListener(MouseEvent.CLICK, onIconAnchorClick);
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
			_mouseSelectionTimeout = setTimeout(selectNode, 400);
			_displayComponent.icon_add.visible = true;
			_displayComponent.icon_anchor.visible = true && _hasPath;
		}
		
		private function onMouseOut(event:MouseEvent):void {
			clearTimeout(_mouseSelectionTimeout);
			_displayComponent.icon_add.visible = false;
			_displayComponent.icon_anchor.visible = false ;
		}
		
		private function onDoubleClick(event:MouseEvent):void {
			_displayComponent.currentState = 'edit_title';
			_displayComponent.title_new.setFocus();
		}
		
		private function onNewTitleKeyUp(event:KeyboardEvent):void {
			if (event.keyCode == Keyboard.ENTER) {
				_displayComponent.currentState = '';
				_nodeItemData.title = _displayComponent.title_label.text = _displayComponent.title_new.text;
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
			var ur:URLRequest = new URLRequest(_nodeItemData.getDrupalPath());
			navigateToURL(ur, '_blank');
		}
		
		public function addNodeChild(node:NodeItem):void {
			this._childs.addItem(node);
			Log.info('new child: ' + this._childs.length);
			StageManager.getInstance().addChildToStage(node);
			this.uncollapseChilds();
			this._displayComponent.icon_has_child.visible = true;
			node._parentNode = this;
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
				child.x = x + NodeItem.WIDTH + NodeItem.MARGIN_RIGHT;
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
			_displayComponent.title_label.setStyle('fontWeight', 'bold');
			_displayComponent.title_label.setStyle('color', '#FFFFFF');
		}
		
		public function unselectNode():void {
			_displayComponent.title_label.setStyle('fontWeight', 'normal');
			_displayComponent.title_label.setStyle('color', '#DDDDDD');
		}
		
		public function exportToFreeMindFormat():String {
			var output:String = '<node ' + 
				'CREATED="'  + _nodeItemData.created   + '" ' + 
				'MODIFIED="' + _nodeItemData.modified  + '" ' + 
				'ID="ID_'    + _nodeItemData.id        + '" ' + 
				'FOLDED="'   + (_isForcedCollapsed ? 'true' : 'false') + '" ' + 
				'TEXT="'     + _nodeItemData.title     + '">' + "\n";
			
			var attributes:Object = Object(_nodeItemData.data);
			if (_nodeItemData.source) {
				attributes.__site_url      = escape(_nodeItemData.source.url);
				attributes.__site_username = escape(_nodeItemData.source.username);
			}
			attributes.__node_type = _nodeItemData.type;
			for (var key:* in attributes) {
				output = output + '<attribute NAME="' + escape(key) + '" VALUE="' + escape(_nodeItemData.data[key]) + '"/>' + "\n";
			}
			
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
	}
}