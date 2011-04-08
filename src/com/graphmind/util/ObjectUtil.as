package com.graphmind.util {
  
  public class ObjectUtil {

    /**
    * Return true if the given object has the given attribute, and it's true.
    */
    public static function isObjectAttributeTrue(o:Object, attr:String):Boolean {
      return o && o.hasOwnProperty(attr) && o[attr] === true;
    }
    
    
    /**
    * Return true if the given object has the given attribute, and it's true.
    */
    public static function isObjectAttributeFalse(o:Object, attr:String):Boolean {
      return o && o.hasOwnProperty(attr) && o[attr] === false;
    }
    
  }
  
}
