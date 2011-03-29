package com.graphmind.data {
  
  /**
   * Drupal object types.
   */
  public class NodeType {
    
    public static const NODE:String    = 'node';
    public static const USER:String    = 'user';
    public static const COMMENT:String = 'comments';
    public static const NORMAL:String  = 'normal';
    public static const FILE:String    = 'files';
    public static const TERM:String    = 'term_data';
    
    public static const updatableTypes:Array = [FILE, NODE, USER];

  }
  
}