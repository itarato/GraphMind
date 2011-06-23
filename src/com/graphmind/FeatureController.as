package com.graphmind {
  
  import com.graphmind.event.EventCenter;
  import com.graphmind.event.EventCenterEvent;
  
  public class FeatureController {

    /**
    * Available features.
    */  
    public static var LOAD_DRUPAL_NODE:String       = 'loadDrupalNode';
    public static var LOAD_DRUPAL_VIEWS_LIST:String = 'loadDrupalViewsList';
    public static var UPDATE_DRUPAL_VIEWS:String    = 'updateDrupalViews';
    public static var CREATE_MINDMAP_NODE:String    = 'createMindmapNode';
    public static var ATTRIBUTES:String             = 'attributes';
    public static var CONNECTIONS:String            = 'connections';
    public static var TOOLTIPS:String               = 'tooltips';
    public static var NODE_INFO:String              = 'nodeInfo';
    public static var REMOVE_NODE:String            = 'removeNode';
  
    /**
    * Inner feature storage.
    */
    private static var _features:Array = [];
    
    
    /**
    * Add the initial set of features.
    */
    public static function set features(aFeatures:Array):void {
      _features = aFeatures;
      EventCenter.notify(EventCenterEvent.FEATURES_CHANGED);
    }
    
    
    /**
    * Add a single feature.
    */
    public static function addFeature(feature:String):void {
      if (_features.indexOf(feature) == -1) {
        _features.push(feature);
        EventCenter.notify(EventCenterEvent.FEATURES_CHANGED);
      }
    }
    
    
    /**
    * Remove a single feature.
    */
    public static function removeFeature(feature:String):void {
      if (_features.indexOf(feature) !== -1) {
        delete _features[_features.indexOf(feature)];
        EventCenter.notify(EventCenterEvent.FEATURES_CHANGED);
      }
    }
    
    
    /**
    * Check is a feature is enabled.
    */
    public static function isFeatureEnabled(feature:String):Boolean {
      return _features.indexOf(feature) !== -1;
    }
    
    
    /**
    * Check if all the given features are enabled.
    */
    public static function areFeaturesEnabled(features:Array):Boolean {
      for (var idx:* in features) {
        if (!isFeatureEnabled(features[idx])) {
          return false;
        }
      }
      return true;
    }
  
  }
  
}
