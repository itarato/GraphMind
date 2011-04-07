package com.graphmind.data {
  import mx.collections.ArrayCollection;
  
  
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
    
    /**
    * Node types are capable of self updating.
    */
    public static const updatableTypes:Array = [FILE, NODE, USER];
    
    /**
    * Drupal items that are loadable.
    */
    public static const DrupalItemTypes:ArrayCollection = new ArrayCollection([
      {label: "Node", data: NODE},
      {label: "User", data: USER},
      {label: "File", data: FILE}
    ]);
    
    
    /**
    * Get the base views table from a node type string.
    */
    public static function viewsTableOfNodeType(type:String):String {
      switch (type) {
        case NODE:    return NODE_VIEWS;
        case USER:    return USER_VIEWS;
        case FILE:    return FILE_VIEWS;
        case TERM:    return TERM_VIEWS;
        default:      return null;
      }
    };
    
    
    /**
    * Get the node type from a views base table string.
    */
    public static function nodeTypeOfViewsTable(viewsTable:String):String {
      switch (viewsTable) {
        case NODE_VIEWS:    return NODE;
        case USER_VIEWS:    return USER;
        case FILE_VIEWS:    return FILE;
        case TERM_VIEWS:    return TERM;
        case NODE_REVISIONS_VIEWS: return NODE;
        default:            return null;
      }      
    }
    
    
    /**
    * Get the color a special type of node.
    */
    public static function getNodeTypeColor(type:String):uint {
      switch (type) {
        case NodeType.NODE:
          return 0xC2D7EF;
        case NodeType.COMMENT:
          return 0xC2EFD9;
        case NodeType.USER:
          return 0xEFD2C2;
        case NodeType.FILE:
          return 0xE9C2EF;
        case NodeType.TERM:
          return 0xD9EFC2;
        default:
          return 0xDFD9D1;
      }
    }

  }
  
}
