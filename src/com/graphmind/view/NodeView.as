package com.graphmind.view {
	import com.graphmind.display.IDisplayItem;
	import com.graphmind.display.IDrawable;
	import com.graphmind.event.NodeEvent;
	import com.graphmind.util.Log;
	
	import components.ItemBaseComponent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Image;
	import mx.core.Container;
	import mx.core.UIComponent;
	
	
	public class NodeView extends UIComponent implements IDisplayItem, IDrawable {
		
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
		
		/**
		 * Backgroung shape.
		 */
		public var _backgroundComp:Container = new Container();
		
		/**
		 * Various UI elements.
		 */
		public var _displayComp:ItemBaseComponent = new ItemBaseComponent();
		
		/**
		 * Images (icons).
		 */
		public var icons:ArrayCollection = new ArrayCollection();
		
		/**
		 * Indicates if the UI was changed and needs an update.
		 */
		public var isGraphicsUpdated:Boolean = true;
		
		/**
		 * Background color.
		 */
		public var backgroundColor:uint = 0xDFD9D1;
		
		public function NodeView():void {
			super();
			
			addChild(_backgroundComp);
			addChild(_displayComp);
			
			initGraphics();
			// Event when a drag-and-drop process ends
//			GraphMind.i.addEventListener(NodeEvent.DRAG_AND_DROP_FINISHED, onDragAndDropFinished);
		}
		
		public function initGraphics():void {
			Log.debug('TreeNodeView.initGraphics()');
			
			// Background component - what a surprise, huh?
			_backgroundComp.height = getHeight();
			_backgroundComp.setStyle('cornerRadius', '5');
			_backgroundComp.setStyle('borderStyle', 'solid');
			
			_displayComp.title_label.doubleClickEnabled = true;
			
			buttonMode = true;
		}
		
		
		public function refreshGraphics():void {
		  if (!isGraphicsUpdated) return;
		  
			var titleExtraWidth:int = _getTitleExtraWidth();
 			for (var idx:* in icons) {
 				Image(icons[idx]).x = titleExtraWidth + ICON_WIDTH * idx + 158;
 			}
 			
 			var leftOffset:int = _getIconsExtraWidth() + titleExtraWidth;

			if (_backgroundComp.width != WIDTH_DEFAULT + leftOffset) {
				_backgroundComp.width = WIDTH_DEFAULT + leftOffset;
			}
			_backgroundComp.setStyle('backgroundColor', backgroundColor);
			
			this._displayComp.width = WIDTH_MC_DEFAULT + leftOffset;
			this._displayComp.icon_has_child.x = ICON_BULLET_DEFAULT_X + leftOffset;
			this._displayComp.insertLeft.x = ICON_INSERT_LEFT_DEFAULT_X + leftOffset;
			this._displayComp.title_label.width = TITLE_DEFAULT_WIDTH + titleExtraWidth;
			this._displayComp.icon_add.x = ICON_ADD_DEFAULT_X + titleExtraWidth;
			this._displayComp.icon_anchor.x = ICON_ANCHOR_DEFAULT_X  + titleExtraWidth;
			
			isGraphicsUpdated = false;
		}
		
		/**
		 * Event callback when a node drag and drop process ends.
		 */
		protected function onDragAndDropFinished(event:NodeEvent):void {
			_displayComp.insertLeft.visible = false;
			_displayComp.insertUp.visible = false;
		}
		
		public function getHeight():uint {
			return HEIGHT;
		}
		
		public function getWidth():uint {
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
			return icons.length * ICON_WIDTH;
		}
		
		public function getUIComponent():UIComponent {
		  return this;
		}
		
		/**
		 * Add icon.
		 */
		public function addIcon(icon:Image):void {
		  icons.addItem(icon);
		  _displayComp.addChild(icon);
		  isGraphicsUpdated = true;
		}
		
		/**
		 * Remove icon.
		 */
		public function removeIcon(source:String):void {
		  for (var idx:* in icons) {
		    if ((icons[idx] as Image).source == source) {
		      (icons[idx] as Image).parent.removeChild(icons[idx] as Image);
		      icons.removeItemAt(idx);
		      isGraphicsUpdated = true;
		      break;
		    }
		  }
		}

	}
	
}
