package com.graphmind.view {
	import com.graphmind.AbstractStageManager;
	import com.graphmind.TreeManager;
	import com.graphmind.display.TreeNodeController;
	import com.graphmind.event.NodeEvent;
	import com.graphmind.util.Log;
	
	import components.ItemBaseComponent;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	
	import mx.controls.Image;
	import mx.core.Container;
	import mx.events.FlexEvent;
	
	
	public class TreeNodeUI extends NodeUI {
		
		public static const WIDTH_MC_DEFAULT:int = 168;
		public static const WIDTH_DEFAULT:int = 162;
		public static const HEIGHT:int = 20;
		public static const ICON_WIDTH:int = 18;
		
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
		
		public static const EFFECT_NORMAL:int = 0;
		public static const EFFECT_HIGHLIGHT:int = 1;
		
		public var _backgroundComp:Container = new Container();
		public var _displayComp:ItemBaseComponent = new ItemBaseComponent();
		
		// Display effects
		public static var _nodeDropShadow:DropShadowFilter = new DropShadowFilter(1, 45, 0x888888, 1, 1, 1);
		public static var _nodeGlowFilter:GlowFilter = new GlowFilter(0x0072B9, .8, 6, 6);
		public static var _nodeInnerGlowFilter:GlowFilter = new GlowFilter(0xFFFFFF, .8, 20, 20, 2, 1, true);
		
		public function TreeNodeUI(nodeController:TreeNodeController) {
			super(nodeController);
			
			this.addChild(_backgroundComp);
			this.addChild(_displayComp);
			
			// Event when a drag-and-drop process ends
			TreeManager.getInstance().addEventListener(NodeEvent.DRAG_AND_DROP_FINISHED, onDragAndDropFinished);
		}
		
		public override function initGraphics():void {
			Log.debug('TreeNodeUI.initGraphics()');
			
			// Background component - what a surprise, huh?
			_backgroundComp.height = HEIGHT;
			_backgroundComp.setStyle('cornerRadius', '5');
			_backgroundComp.setStyle('borderStyle', 'solid');
			
			_displayComp.title_label.htmlText = getTreeNodeController().nodeItemData.title;

			_displayComp.title_label.doubleClickEnabled = true;
			
			// Event listeners
			_displayComp.title_label.addEventListener(MouseEvent.DOUBLE_CLICK, getTreeNodeController().onDoubleClick);
			
			_displayComp.title_new.addEventListener(KeyboardEvent.KEY_UP, getTreeNodeController().onKeyUp_TitleTextField);
			_displayComp.title_new.addEventListener(FocusEvent.FOCUS_OUT, getTreeNodeController().onFocusOut_TitleTextField);
			
			_displayComp.icon_add.addEventListener(MouseEvent.CLICK, getTreeNodeController().onClick_AddSimpleNodeButton);
			
			_displayComp.addEventListener(MouseEvent.MOUSE_DOWN, getTreeNodeController().onMouseDown);
			_displayComp.addEventListener(MouseEvent.MOUSE_UP,   getTreeNodeController().onMouseUp);
			_displayComp.addEventListener(MouseEvent.MOUSE_MOVE, getTreeNodeController().onMouseMove);
			
			_displayComp.addEventListener(MouseEvent.CLICK, getTreeNodeController().onClick);
			_displayComp.addEventListener(MouseEvent.MOUSE_OVER, getTreeNodeController().onMouseOver);
			_displayComp.addEventListener(MouseEvent.MOUSE_OUT, getTreeNodeController().onMouseOut);
			
			_displayComp.title_label.addEventListener(FlexEvent.UPDATE_COMPLETE, getTreeNodeController().onUpdateComplete_TitleLabel);
			
			_displayComp.icon_anchor.addEventListener(MouseEvent.CLICK, getTreeNodeController().onClick_NodeLinkButton);
			_displayComp.icon_has_child.addEventListener(MouseEvent.CLICK, getTreeNodeController().onClick_ToggleSubtreeButton);
	
			_displayComp.contextMenu = getTreeNodeController().getContextMenu();
			
			this.buttonMode = true;
			
		}
		
		public override function refreshGraphics():void {
			var titleExtraWidth:int = _getTitleExtraWidth();
 			for (var idx:* in getTreeNodeController()._icons) {
 				Image(getTreeNodeController()._icons[idx]).x = titleExtraWidth + ICON_WIDTH * idx + 158;
 			}
 			
 			var leftOffset:int = _getIconsExtraWidth() + titleExtraWidth;

			if (_backgroundComp.width != WIDTH_DEFAULT + leftOffset) {
				_backgroundComp.width = WIDTH_DEFAULT + leftOffset;
			}
			_backgroundComp.setStyle('backgroundColor', getTreeNodeController().getTypeColor());
			
			_setBackgroundEffect(_sourceNodeController.isSelected() ? EFFECT_HIGHLIGHT : EFFECT_NORMAL);
			
			this._displayComp.width = WIDTH_MC_DEFAULT + leftOffset;
			this._displayComp.icon_has_child.x = ICON_BULLET_DEFAULT_X + leftOffset;
			this._displayComp.insertLeft.x = ICON_INSERT_LEFT_DEFAULT_X + leftOffset;
			this._displayComp.title_label.width = TITLE_DEFAULT_WIDTH + titleExtraWidth;
			this._displayComp.icon_add.x = ICON_ADD_DEFAULT_X + titleExtraWidth;
			this._displayComp.icon_anchor.x = ICON_ANCHOR_DEFAULT_X  + titleExtraWidth;
			
			// @TODO refreshing subtree is enough
			//TreeManager.getInstance().dispatchEvent(new NodeEvent(NodeEvent.UPDATE_GRAPHICS, _sourceNodeController));
			TreeManager.getInstance().dispatchEvent(new Event(AbstractStageManager.EVENT_MINDMAP_UPDATED));
		}
		
		/**
		 * Event callback when a node drag and drop process ends.
		 */
		protected function onDragAndDropFinished(event:NodeEvent):void {
			_displayComp.insertLeft.visible = false;
			_displayComp.insertUp.visible = false;
		}
		
		public override function getHeight():uint {
			return HEIGHT;
		}
		
		public override function getWidth():uint {
			return WIDTH_DEFAULT + _getIconsExtraWidth() + _getTitleExtraWidth(); 
		}
		
		protected function _getTitleExtraWidth():int {
			return _displayComp.title_label.measuredWidth <= TITLE_DEFAULT_WIDTH ? 
				0 :
				(_displayComp.title_label.measuredWidth >= TITLE_MAX_WIDTH ? 
					TITLE_MAX_WIDTH - TITLE_DEFAULT_WIDTH :
					_displayComp.title_label.measuredWidth - TITLE_DEFAULT_WIDTH);
		}
		
		protected function _getIconsExtraWidth():int {
			return getTreeNodeController()._icons.length * ICON_WIDTH;
		}
		
		public function _setBackgroundEffect(effect:int = EFFECT_NORMAL):void {
			_backgroundComp.filters = (effect == EFFECT_NORMAL) ? [] : [_nodeInnerGlowFilter, _nodeGlowFilter];
		}
		
		protected function getTreeNodeController():TreeNodeController {
			return _sourceNodeController as TreeNodeController;
		}

	}
	
}