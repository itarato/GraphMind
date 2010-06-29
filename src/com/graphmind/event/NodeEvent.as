package com.graphmind.event {
	
	import com.graphmind.display.NodeController;
	
	import flash.events.Event;
	
	public class NodeEvent extends Event {
		
		/**
		 * Custom events.
		 */
		public static var UPDATE_DATA:String 	          = 'updateData';
		public static var UPDATE_GRAPHICS:String        = 'updateGraphic';
		public static var MOVED:String 			            = 'moved';
		public static var DELETED:String 		            = 'deleted';
		public static var CREATED:String		            = 'created';
		public static var ATTRIBUTE_CHANGED:String      = 'attributeChanged';
		public static var DRAG_AND_DROP_FINISHED:String = 'dragAndDropFinished';
		
		/**
		 * Transfered events.
		 */
		public static var CLICK:String = 'click';
    public static var MOUSE_OVER:String = 'mouseOver';
    public static var MOUSE_OUT:String = 'mouseOut';
    public static var DOUBLE_CLICK:String = 'doubleClick';
    public static var KEY_UP_TITLE_TEXT_FIELD:String = 'keyUpTitleTextField';
    public static var FOCUS_OUT_TITLE_TEXT_FIELD:String = 'focusOutTitleTextField';
    public static var ITEM_LOADER_SELECTOR_CLICK:String = 'itemLoaderSelectorClick';
    public static var CLICK_ADD_SIMPLE_NODE:String = 'clickAddSimpleNode';
    public static var CLICK_ADD_DRUPAL_ITEM:String = 'clickAddDrupalItem';
    public static var CLICK_ADD_DRUPAL_VIEWS:String = 'clickAddDrupalViews';
    public static var CLICK_NODE_LINK:String = 'clickNodeLink';
    public static var MOUSE_DOWN:String = 'mouseDown';
    public static var MOUSE_UP:String = 'mouseUp';
    public static var MOUSE_MOVE:String = 'mouseMove';
    public static var CONTEXT_MENU_ADD_SIMPLE_NODE:String = 'contextMenuAddSimpleNode';
    public static var CONTEXT_MENU_ADD_DRUPAL_ITEM:String = 'contextMenuAddDrupalItem';
    public static var CONTEXT_MENU_ADD_DRUPAL_VIEWS:String = 'contextMenuAddDrupalViews';
    public static var CONTEXT_MENU_REMOVE_NODE:String = 'contextMenuRemoveNode';
    public static var CONTEXT_MENU_REMOVE_CHILDS:String = 'contextMenuRemoveChilds';
		
		public var node:NodeController;
		
		public var originalEvent:Event;
		
		public function NodeEvent(type:String, node:NodeController = null, originalEvent:Event = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			this.node = node;
			this.originalEvent = originalEvent;
		}

	}
	
}