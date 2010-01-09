package com.graphmind.display
{
	import com.graphmind.ConnectionManager;
	import com.graphmind.GraphMindManager;
	import com.graphmind.StageManager;
	import com.graphmind.data.NodeItemData;
	import com.graphmind.display.assets.ItemBaseComponent;
	import com.graphmind.temp.TempItemLoadData;
	import com.graphmind.util.NodeGraphicsHelper;
	import com.graphmind.util.StringUtility;
	
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.Image;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	public class NodeItem extends DisplayItem {
		
		public static const WIDTH_DEFAULT:int = 162;
		public static const WIDTH_MC_DEFAULT:int = 168;
		public static const HEIGHT:int = 20;
		public static const MARGIN_RIGHT:int = 34;
		public static const MARGIN_BOTTOM:int = 4;
		public static const ICON_WIDTH:int = 18;
		public static const CLOUD_MARGIN:int = 8;
		public static const CLOUD_PADDING:int = 6;
		[Bindable]
		public static var TITLE_DEFAULT_WIDTH:int = 120;
		public static var TITLE_MAX_WIDTH:int = 220;
		[Bindable]
		public static var ICON_ADD_DEFAULT_X:int = 140;
		[Bindable]
		public static var ICON_ANCHOR_DEFAULT_X:int = 122;
		[Bindable]
		public static var ICON_BULLET_DEFAULT_X:int = WIDTH_DEFAULT - 4;
		[Bindable]
		public static var ICON_INSERT_LEFT_DEFAULT_X:int = WIDTH_DEFAULT - 2;
		
		private static const EFFECT_NORMAL:int = 0;
		private static const EFFECT_HIGHLIGHT:int = 1;
		
		protected var _displayComp:ItemBaseComponent = new ItemBaseComponent();
		protected var _connectionComp:UIComponent 	 = new UIComponent();
		protected var _nodeItemData:NodeItemData;
		protected var _childs:ArrayCollection 		 = new ArrayCollection();
		protected var _isCollapsed:Boolean 		 	 = false;
		protected var _isForcedCollapsed:Boolean 	 = false;
		protected var _parentNode:NodeItem 			 = null;
		protected var _backgroundComp:Sprite 		 = new Sprite();
		protected var _hasPath:Boolean 				 = false;
		protected var _icons:ArrayCollection		 = new ArrayCollection();
		protected var _isCloud:Boolean				 = false;
		protected var _cloudComp:UIComponent		 = new UIComponent();
		
		// Display effects
		private static var _nodeDropShadow:DropShadowFilter = new DropShadowFilter(1, 45, 0x888888, 1, 1, 1);
		private static var _nodeGlowFilter:GlowFilter = new GlowFilter(0x0072B9, .8, 6, 6);
		private static var _nodeInnerGlowFilter:GlowFilter = new GlowFilter(0xFFFFFF, .8, 20, 20, 2, 1, true); 
		
		private var _mouseSelectionTimeout:uint;

		/**
		 * Constructor
		 */
		public function NodeItem(viewItem:NodeItemData) {
			// Init super class
			super();
			// Attach data object
			this._nodeItemData = viewItem;
			// Init display elements
			_initDisplayElements();
			// Init events
			_initAttachEvents();
		}
		
		private function _initDisplayElements():void {
			// Context menu 
			if (GraphMindManager.getInstance().isEditable()) {
				_initCreateContextMenu();
			}
			
			this.addChild(_backgroundComp);
			
			this.addChild(_displayComp);
			
			_connectionComp.graphics.lineStyle(2, 0x333333, 1);
			StageManager.getInstance().stage.desktop.addChild(_connectionComp);
			StageManager.getInstance().stage.desktop_cloud.addChild(_cloudComp);
			
			this._displayComp.title_label.htmlText = this._nodeItemData.title;
		
			_hasPath = _nodeItemData.getPath().length > 0;
			
			this.buttonMode = true;
			
			this.refactorNodeBody();
		}
			
		private function _initAttachEvents():void {
			if (GraphMindManager.getInstance().isEditable()) {
				this._displayComp.title_label.doubleClickEnabled = true;
				this._displayComp.title_label.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
				
				this._displayComp.title_new.addEventListener(KeyboardEvent.KEY_UP, onNewTitleKeyUp);
				this._displayComp.title_new.addEventListener(FocusEvent.FOCUS_OUT, onNewTitleFocusOut);
				
				this._displayComp.icon_add.addEventListener(MouseEvent.CLICK, onLoadNodeClick);
				
				this._displayComp.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				this._displayComp.addEventListener(MouseEvent.MOUSE_UP,   onMouseUp);
				this._displayComp.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			}
			
			this._displayComp.addEventListener(MouseEvent.CLICK, onClick);
			this._displayComp.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			this._displayComp.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			
			this._displayComp.title_label.addEventListener(FlexEvent.UPDATE_COMPLETE, onTitleUpdateComplete);
			
			this._displayComp.icon_anchor.addEventListener(MouseEvent.CLICK, onIconAnchorClick);
			this._displayComp.icon_has_child.addEventListener(MouseEvent.CLICK, onIconHasChildClick);
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
				{title: 'Remove childs',   event: onRemoveNodeChildsSelect, separator: false},
				{title: 'Open subtree',    event: onOpenSubtree,            separator: true},
				{title: 'Toggle cloud',    event: toggleCloudWithRefresh,   separator: false}
			];
			
			if (NodeItemData.updatableTypes.indexOf(_nodeItemData.type) >= 0) {
				cms.push({title: 'Update node', event: onUpdateNodeSelect, separator: false});
			}
			
			for each (var cmData:Object in cms) {
				var cmi:ContextMenuItem = new ContextMenuItem(cmData.title,	cmData.separator);
				cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, cmData.event);
				contextMenu.customItems.push(cmi);
			}
			
			_displayComp.contextMenu = contextMenu;
		}
		
		private function onMouseDown(event:MouseEvent):void {
			StageManager.getInstance().prepaireDragAndDrop();
			event.stopImmediatePropagation();
		}
		
		private function onMouseUp(event:MouseEvent):void {
			if ((!StageManager.getInstance().isPrepairedDragAndDrop) && StageManager.getInstance().isDragAndDrop) {
				
				if (this.mouseX / this.getWidth() > (1 - this.mouseY / HEIGHT)) {
					NodeItem.move(StageManager.getInstance().dragAndDrop_sourceNodeItem, this);
				} else {
					NodeItem.moveToPrevSibling(StageManager.getInstance().dragAndDrop_sourceNodeItem, this);
				}
				StageManager.getInstance().closeDragAndDrop();
				
				_displayComp.insertLeft.visible = false;
				_displayComp.insertUp.visible = false;
			}
		}
		
		private function onMouseMove(event:MouseEvent):void {
			if ((!StageManager.getInstance().isPrepairedDragAndDrop) && StageManager.getInstance().isDragAndDrop) {
				if (this.mouseX / this.getWidth() > (1 - this.mouseY / HEIGHT)) {
					_displayComp.insertLeft.visible = true;
					_displayComp.insertUp.visible = false;
				} else {
					_displayComp.insertLeft.visible = false;
					_displayComp.insertUp.visible = true;
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
			//Log.info('node-click');
			selectNode();
		}
		
		private function onIconHasChildClick(event:MouseEvent):void {
			StageManager.getInstance().isChanged = true;
			if (!this._isCollapsed) {
				collapse();
			} else {
				uncollapse();
			}
			event.stopPropagation();
		}
		
		private function onMouseOver(event:MouseEvent):void {
			_mouseSelectionTimeout = setTimeout(selectNode, 400);
			_displayComp.icon_add.visible = true && GraphMindManager.getInstance().isEditable();
			_displayComp.icon_anchor.visible = true && _hasPath;
		}
		
		private function onMouseOut(event:MouseEvent):void {
			clearTimeout(_mouseSelectionTimeout);
			_displayComp.icon_add.visible = false;
			_displayComp.icon_anchor.visible = false;
			
			if (StageManager.getInstance().isPrepairedDragAndDrop) {
				StageManager.getInstance().openDragAndDrop(this);
				//trace(StageManager.getInstance().isPrepairedDragAndDrop.toString());
			}
			
			_displayComp.insertLeft.visible = false;
			_displayComp.insertUp.visible = false;
		}
		
		private function onDoubleClick(event:MouseEvent):void {
			_displayComp.currentState = 'edit_title';
			_displayComp.title_new.text = _displayComp.title_label.text;
			_displayComp.title_new.setFocus();
		}
		
		private function onNewTitleKeyUp(event:KeyboardEvent):void {
			if (event.keyCode == Keyboard.ENTER) {
				_displayComp.currentState = '';
				title = _displayComp.title_new.text;
				StageManager.getInstance().stage.setFocus();
			} else if (event.keyCode == Keyboard.ESCAPE) {
				_displayComp.currentState = '';
				_displayComp.title_new.text = _displayComp.title_label.text;
			}
		}
		
		private function onNewTitleFocusOut(event:FocusEvent):void {
			// @TODO this is a duplication of the onNewTitleKeyUp() (above)
			_displayComp.currentState = '';
			_nodeItemData.title = _displayComp.title_label.text = _displayComp.title_new.text;
			StageManager.getInstance().stage.setFocus();
		}
		
		private function onItemLoaderSelectorClick(event:MouseEvent):void {
			event.stopPropagation();
			//Log.info('click on node: ' + this._nodeItemData.title); 
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
		
		public function get childs():ArrayCollection {
			return _childs;
		}
		
		public function addNodeChild(node:NodeItem):void {
			this._childs.addItem(node);
			//Log.info('new child: ' + this._childs.length);
			StageManager.getInstance().addChildToStage(node);
			node._parentNode = this;
			
			// Update display
			this.uncollapseChilds();
			this._displayComp.icon_has_child.visible = true;
			
			updateTime();
		}
		
		public function collapse():void {
			_isForcedCollapsed = true;
			collapseChilds();
		}
		
		public function collapseChilds():void {
			_isCollapsed = true;
			_displayComp.icon_has_child.source = _displayComp.image_node_uncollapse;
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
		
		public function uncollapseChilds(forceOpenSubtree:Boolean = false):void {
			_isCollapsed = false;
			_displayComp.icon_has_child.source = _displayComp.image_node_collapse;
			for each (var nodeItem:NodeItem in _childs) {
				nodeItem.visible = true;
				if (!nodeItem._isForcedCollapsed || forceOpenSubtree) {
					nodeItem.uncollapseChilds(forceOpenSubtree);
				}
			}
			StageManager.getInstance().refreshNodePositions();
		}
		
		/**
		 * Calculates the with of the subtree comes from this node.
		 * @return int
		 */
		private function childSubtreeWidth():int {
			var width:int = 0;
			if (_childs.length == 0 || _isCollapsed) {
				width = HEIGHT + MARGIN_BOTTOM;
			} else {
				for each (var child:NodeItem in _childs) {
					width += child.childSubtreeWidth();
				}
			}
			
			if (_isCloud) width += 2 * CLOUD_MARGIN;
			
			return width;
		}
		
		/**
		 * Position child items.
		 */
		public function refreshChildNodePosition():void {
			this._connectionComp.graphics.clear();
			
			var totalChildWidth:int = childSubtreeWidth();
			var currentY:int = y - totalChildWidth / 2;
			
			if (_isCloud) currentY += CLOUD_MARGIN;
			
			for each (var child:NodeItem in _childs) {
				var subtreeWidth:int = child.childSubtreeWidth();
				child.x = x + getWidth() + NodeItem.MARGIN_RIGHT;
				child.y = currentY + subtreeWidth / 2; 
				child.refreshChildNodePosition();
				
				if (!_isCollapsed) {
					NodeGraphicsHelper.drawConnection(_connectionComp, this, child);
				}
				currentY += subtreeWidth;
			}
			
			if (_isCloud) {
				toggleCloud();
				toggleCloud();
			}
			
			_cloudComp.visible = !_parentNode || !_parentNode._isCollapsed;
		}
		
		private function getTypeColor():uint {
			switch (this._nodeItemData.type) {
				case NodeItemData.NODE:
					return 0xC2D7EF;
				case NodeItemData.COMMENT:
					return 0xC2EFD9;
				case NodeItemData.USER:
					return 0xEFD2C2;
				case NodeItemData.FILE:
					return 0xE9C2EF;
				case NodeItemData.TERM:
					return 0xD9EFC2;
				default:
					return 0xDFD9D1;
			}
		}
		
		public function selectNode():void {
			// Not to lose focus from textfield
			if (!isSelected()) setFocus();
			
			// @TODO mystery bug steal highlight somethimes from nodes
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
			StageManager.getInstance().stage.node_info_panel.nodeLabelRTE.htmlText = _displayComp.title_label.htmlText;
			
			StageManager.getInstance().stage.node_info_panel.link.text = _nodeItemData.getPath();
			
			_setBackgroundEffect(EFFECT_HIGHLIGHT);
		}
		
		public function unselectNode():void {
			_setBackgroundEffect(EFFECT_NORMAL);
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
			kill();
			if (_parentNode) {
				_parentNode._childs.removeItemAt(_parentNode._childs.getItemIndex(this));
				_parentNode._displayComp.icon_has_child.visible = _parentNode._childs.length > 0;
			}
			StageManager.getInstance().refreshNodePositions();
		}
		
		private function removeNodeChilds():void {
			while (_childs.length > 0) {
				var child:NodeItem = _childs.removeItemAt(0) as NodeItem;
				child.kill();
			}
			_displayComp.icon_has_child.visible = false;
		}
		
		private function kill():void {
			removeNodeChilds();
			_displayComp.parent.removeChild(_displayComp);
			_connectionComp.parent.removeChild(_connectionComp);
			_cloudComp.parent.removeChild(_cloudComp);
			parent.removeChild(this);
			StageManager.getInstance().isChanged = true;
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
			
			parentNode._displayComp.icon_has_child.visible = parentNode._childs.length > 0;
		}
			
		
		public function getWidth():int {
			return WIDTH_DEFAULT + _getIconsExtraWidth() + _getTitleExtraWidth(); 
		}
		
		private function _getTitleExtraWidth():int {
			return _displayComp.title_label.measuredWidth <= TITLE_DEFAULT_WIDTH ? 
				0 :
				(_displayComp.title_label.measuredWidth >= TITLE_MAX_WIDTH ? 
					TITLE_MAX_WIDTH - TITLE_DEFAULT_WIDTH :
					_displayComp.title_label.measuredWidth - TITLE_DEFAULT_WIDTH);
		}
		
		private function _getIconsExtraWidth():int {
			return _icons.length * ICON_WIDTH;
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
			_displayComp.addChild(icon);
			_icons.addItem(icon);
			if (GraphMindManager.getInstance().isEditable()) {
				icon.doubleClickEnabled = true;
				icon.addEventListener(MouseEvent.DOUBLE_CLICK, removeIcon);
			}
			
			updateTime();
 		}
 		
 		public function removeIcon(event:MouseEvent):void {
 			var iconIDX:int = _icons.getItemIndex(event.currentTarget as Image);
 			if (iconIDX == -1) return;
 			_icons.removeItemAt(iconIDX);
 			_displayComp.removeChild(event.currentTarget as Image);
 			refactorNodeBody();
 			refreshParentTree();
 			
 			updateTime();
 		}
 		
 		public function refactorNodeBody():void {
 			var titleExtraWidth:int = _getTitleExtraWidth();
 			for (var idx:* in _icons) {
 				Image(_icons[idx]).x = titleExtraWidth + ICON_WIDTH * idx + 158;
 			}
 			
 			var leftOffset:int = _getIconsExtraWidth() + titleExtraWidth;
 				
 			this._backgroundComp.graphics.clear();		
			this._backgroundComp.graphics.beginFill(getTypeColor());
			this._backgroundComp.graphics.drawRoundRect(0, 0, WIDTH_DEFAULT + leftOffset, HEIGHT, 10, 10);
			this._backgroundComp.graphics.endFill();
			
			_setBackgroundEffect(isSelected() ? EFFECT_HIGHLIGHT : EFFECT_NORMAL);
			
			this._displayComp.width = WIDTH_MC_DEFAULT + leftOffset;
			this._displayComp.icon_has_child.x = ICON_BULLET_DEFAULT_X + leftOffset;
			this._displayComp.insertLeft.x = ICON_INSERT_LEFT_DEFAULT_X + leftOffset;
			this._displayComp.title_label.width = TITLE_DEFAULT_WIDTH + titleExtraWidth;
			this._displayComp.icon_add.x = ICON_ADD_DEFAULT_X + titleExtraWidth;
			this._displayComp.icon_anchor.x = ICON_ANCHOR_DEFAULT_X  + titleExtraWidth;
			
			this.refreshChildNodePosition();
 		}
		
		public function set title(title:String):void {
			_nodeItemData.title = _displayComp.title_label.htmlText = title;
			updateTime();
		}
		
		public function onTitleUpdateComplete(event:FlexEvent):void {
			refactorNodeBody();
			refreshChildNodePosition();
			refreshParentTree();
		}
		
		public function set link(link:String):void {
			_nodeItemData.link = link;
			_displayComp.icon_anchor.visible = _hasPath = link.length > 0;
		}
		
		public function updateTime():void {
			_nodeItemData.modified = (new Date()).time;
			StageManager.getInstance().isChanged = true;
		}
		
		public function onOpenSubtree(event:ContextMenuEvent):void {
			uncollapseChilds(true);
		}
		
		public function toggleCloud(forceRedraw:Boolean = false):void {
			if (!_isCloud) {
				_isCloud = true;
				NodeGraphicsHelper.drawCloud(this, _cloudComp);
			} else {
				_isCloud = false;
				_cloudComp.graphics.clear();
			}
			
			if (forceRedraw) StageManager.getInstance().refreshNodePositions();
		}
		
		public function toggleCloudWithRefresh(event:ContextMenuEvent):void {
			toggleCloud(true);
			updateTime();
		}
		
		public function getBoundingPoints():Array {
			return [
				[x - CLOUD_PADDING, y - CLOUD_PADDING],
				[x + getWidth() + CLOUD_PADDING, y - CLOUD_PADDING],
				[x + getWidth() + CLOUD_PADDING, y + HEIGHT + CLOUD_PADDING],
				[x - CLOUD_PADDING, y + HEIGHT + CLOUD_PADDING]
			];
		}
		
		public function refreshParentTree():void {
			if (_isCloud) {
				toggleCloud();
				toggleCloud();
			}
			
			if (_parentNode) _parentNode.refreshParentTree();
		}
		
		public function isSelected():Boolean {
			return StageManager.getInstance().lastSelectedNode == this;
		}
		
		public function isCollapsed():Boolean {
			return _isCollapsed;
		}
	
		public function onUpdateNodeSelect(event:ContextMenuEvent):void {
			updateDrupalItem();
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
		
		private function _updateTitleLabel():void {
			_displayComp.title_label.text = _nodeItemData.title;
		}
		
		private function _setBackgroundEffect(effect:int = EFFECT_NORMAL):void {
			_backgroundComp.filters = (effect == EFFECT_NORMAL) ? [_nodeDropShadow] : [_nodeInnerGlowFilter, _nodeGlowFilter];
		}
		
		public function getEqualChild(data:Object, type:String):NodeItem {
			for each (var child:NodeItem in _childs) {
				if (child._nodeItemData.equalTo(data, type)) return child;
			}
			return null;
		}
	}
}