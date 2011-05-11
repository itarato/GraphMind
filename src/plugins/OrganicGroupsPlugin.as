package plugins {
  import com.graphmind.FeatureController;
  import com.graphmind.event.EventCenter;
  import com.graphmind.event.EventCenterEvent;
  
  
  public class OrganicGroupsPlugin {
    
    /**
    * Implementation of the plugin init function.
    */
    public static function init():void {
//      EventCenter.subscribe(EventCenterEvent.FEATURES_CHANGED, onFeaturesChanged);
    }
    
    
    private static function onFeaturesChanged(event:EventCenterEvent):void {
      if (FeatureController.isFeatureEnabled(FeatureController.LOAD_DRUPAL_NODE)) {
        FeatureController.removeFeature(FeatureController.LOAD_DRUPAL_NODE);
      }
    }
    
    
    public static function alter_context_menu(cm:Array):void {
//      cm.push({title: 'Load Drupal Item'});
    }
    
    
  }

}
