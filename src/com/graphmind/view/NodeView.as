package com.graphmind.view {
  
	import com.graphmind.event.NodeEvent;
	
	import components.ItemBaseComponent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Image;
	import mx.core.Container;
	import mx.core.UIComponent;
	
	
	public class NodeView extends UIComponent {
		
		public static const WIDTH_MC_DEFAULT:int = 168;
		public static const WIDTH_DEFAULT:int = 126;
		public static const HEIGHT:int = 20;
		public static const ICON_WIDTH:int = 18;
		
		[Bindable]
		public static var TITLE_DEFAULT_WIDTH:int = 122;
		public static var TITLE_MAX_WIDTH:int = 220;
		[Bindable]
		public static var ACTION_ICONS_DEFAULT_X:int = 120;
		[Bindable]
		public static var ICON_BULLET_DEFAULT_X:int = WIDTH_DEFAULT - 4;
		[Bindable]
		public static var ICON_INSERT_LEFT_DEFAULT_X:int = WIDTH_DEFAULT - 2;
		
		/**
		 * Backgroung shape.
		 */
		public var backgroundView:Container = new Container();
		
		/**
		 * Various UI elements.
		 */
		public var nodeComponentView:ItemBaseComponent = new ItemBaseComponent();
		
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
		
		public var actionIcons:Array = [];
		
		
		/**
		 * Constructor.
		 */
		public function NodeView():void {
			super();
			
			addChild(backgroundView);
			addChild(nodeComponentView);
			
      // Background component - what a surprise, huh?
      backgroundView.height = HEIGHT;
      backgroundView.setStyle('cornerRadius', '5');
      backgroundView.setStyle('borderStyle', 'solid');
      
      nodeComponentView.title_label.doubleClickEnabled = true;
      
      buttonMode = true;
      
      height = HEIGHT;
		}
		
		
		public function refreshGraphics():void {
		  if (!isGraphicsUpdated) return;
		  
			var titleExtraWidth:int = _getTitleExtraWidth();
 			for (var idx:* in icons) {
 				Image(icons[idx]).x = titleExtraWidth + ICON_WIDTH * idx + 158;
 			}
 			
 			var leftOffset:int = _getIconsExtraWidth() + titleExtraWidth;
 			var actionIconOffset:uint = actionIcons.length * 18;
      width = WIDTH_DEFAULT + leftOffset + actionIconOffset;

			if (backgroundView.width != width) {
				backgroundView.width = width;
			}
			backgroundView.setStyle('backgroundColor', backgroundColor);
			
			this.nodeComponentView.width = WIDTH_MC_DEFAULT + leftOffset + actionIconOffset;
			this.nodeComponentView.icon_has_child.x = ICON_BULLET_DEFAULT_X + leftOffset + actionIconOffset;
			this.nodeComponentView.insertLeft.x = ICON_INSERT_LEFT_DEFAULT_X + leftOffset + actionIconOffset;
			this.nodeComponentView.title_label.width = TITLE_DEFAULT_WIDTH + titleExtraWidth;
			
			for (var i:* in actionIcons) {
			  (actionIcons[i] as Image).x = ACTION_ICONS_DEFAULT_X + i * 18;
			}
			
			isGraphicsUpdated = false;
		}
		
		
		/**
		 * Event callback when a node drag and drop process ends.
		 */
		protected function onDragAndDropFinished(event:NodeEvent):void {
			nodeComponentView.insertLeft.visible = false;
			nodeComponentView.insertUp.visible = false;
		}
		
		
		protected function _getTitleExtraWidth():int {
			return nodeComponentView.title_label.measuredWidth <= TITLE_DEFAULT_WIDTH ? 
				0 :
				(nodeComponentView.title_label.measuredWidth >= TITLE_MAX_WIDTH ? 
					TITLE_MAX_WIDTH - TITLE_DEFAULT_WIDTH :
					nodeComponentView.title_label.measuredWidth - TITLE_DEFAULT_WIDTH);
		}
		
		
		protected function _getIconsExtraWidth():int {
			return icons.length * ICON_WIDTH;
		}
		
		
		/**
		 * Add icon.
		 */
		public function addIcon(icon:Image):void {
		  icons.addItem(icon);
		  nodeComponentView.addChild(icon);
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
		
		
		public function addActionIcon(actionIcon:NodeActionIcon):void {
		  actionIcons.push(actionIcon);
		  actionIcon.y = 2;
		  nodeComponentView.addChild(actionIcon);
		  refreshGraphics();
		}

	}
	
}
