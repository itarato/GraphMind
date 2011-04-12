package com.graphmind.event {
  
  import flash.events.Event;

  public class EventCenterEvent extends Event {
    
    public static var NODE_IS_SELECTED:String    = 'nodeSelected';
    public static var NODE_IS_UNSELECTED:String  = 'nodeUnselected';
    public static var NODE_WILL_BE_MOVED:String  = 'nodeWillBeMoved';
    public static var NODE_DID_MOVED:String      = 'nodeDidMoved';
    public static var NODE_START_DRAG:String     = 'nodeStartDrag';
    public static var NODE_PREPARE_DRAG:String   = 'nodePrepareDrag';
    public static var NODE_FINISH_DRAG:String    = 'nodeFinishDrag';
    public static var NODE_CREATED:String        = 'nodeCreated';
    public static var NODE_DID_ADDED_TO_PARENT:String = 'nodeDidAddedToParent';
    public static var NODE_IS_KILLED:String      = 'nodeIsKilled';
    public static var NODE_TITLE_CHANGED:String  = 'nodeTitleChanged';
    
    public static var ACTIVE_NODE_TITLE_IS_CHANGED:String = 'activeNodeTitleIsChanged';
    public static var ACTIVE_NODE_LINK_IS_CHANGED:String  = 'activeNodeLinkIsChanged';
    public static var ACTIVE_NODE_TOGGLE_CLOUD:String     = 'activeNodeToggleCloud';
    public static var ACTIVE_NODE_SAVE_ATTRIBUTE:String   = 'activeNodeSaveAttribute';
    public static var ACTIVE_NODE_REMOVE_ATTRIBUTE:String = 'activeNodeRemoveAttribute';
    public static var ACTIVE_NODE_ADD_ICON:String         = 'activeNodeAddIcon';
    
    public static var MAP_UPDATED:String = 'mapUpdated';
    public static var MAP_SAVED:String   = 'mapSaved';
    public static var MAP_SCALE_CHANGED:String = 'mapScaleChanged';
    public static var MAP_TREE_IS_COMPLETE:String = 'mapTreeIsComplete';
    public static var MAP_LOCK:String = 'mapLock';
    public static var MAP_UNLOCK:String = 'mapUnlock';

    public static var REQUEST_FOR_FREEMIND_XML:String = 'appFormRequestForFreemindXml';
    public static var REQUEST_TO_SAVE:String = 'requestToSave';
    
    public static var LOAD_DRUPAL_ITEM:String = 'loadDrupalItem';
    public static var LOAD_DRUPAL_VIEWS:String = 'loadDrupalViews';
        
    /**
    * Data.
    */
    public var data:Object;
    
    
    /**
    * Constructor.
    */
    public function EventCenterEvent(type:String, data:Object = null) {
      this.data   = data;
      super(type);
    }
    
  }

}
