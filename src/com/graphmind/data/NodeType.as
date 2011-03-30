package com.graphmind.data {
  
  /**
   * Drupal object types.
   */
  public class NodeType {
    
    public static const NODE:String    = 'node';
    public static const USER:String    = 'user';
    public static const COMMENT:String = 'comment';
    public static const NORMAL:String  = 'normal';
    public static const FILE:String    = 'file';
    public static const TERM:String    = 'term';
    
    public static const NODE_VIEWS:String     = 'node';
    public static const USER_VIEWS:String     = 'users';
    public static const FILE_VIEWS:String     = 'files';
    public static const TERM_VIEWS:String     = 'term_data';
    public static const NODE_REVISIONS_VIEWS:String = 'node_revisions';
    
    public static const updatableTypes:Array = [FILE, NODE, USER];
    
    
    public static function viewsTableOfNodeType(type:String):String {
      switch (type) {
        case NODE:    return NODE_VIEWS;
        case USER:    return USER_VIEWS;
        case FILE:    return FILE_VIEWS;
        case TERM:    return TERM_VIEWS;
        default:      return null;
      }
    };
    
    
    public static function nodeTypeOfViewsTable(viewsTable:String):String {
      switch (viewsTable) {
        case NODE_VIEWS:    return NODE;
        case USER_VIEWS:    return USER;
        case FILE_VIEWS:    return FILE;
        case TERM_VIEWS:    return TERM;
        case NODE_REVISIONS_VIEWS: return NODE;
        default:            return null;
      }      
    };

  }
  
}
