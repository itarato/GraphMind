package plugins {
  import com.graphmind.ConnectionController;
  import com.graphmind.NodeViewController;
  import com.graphmind.data.NodeType;
  import com.graphmind.event.EventCenter;
  import com.graphmind.event.EventCenterEvent;
  import com.graphmind.util.Log;
  
  
  public class Relationship {
    
    /**
    * Default relationship type.
    */
    private static var DEFAULT_RELATIONSHIP:String = 'default';
    
    
    /**
    * Implemrentation of hook_pre_init().
    */
    public static function hook_pre_init(data:Object):void {
      Log.info('Relationship plugin is live.');
      
      EventCenter.subscribe(EventCenterEvent.NODE_DID_ADDED_TO_PARENT, onNodeDidAddedToParent);
    }
    
    
    /**
    * Event handler - node is added to a parent.
    */
    private static function onNodeDidAddedToParent(event:EventCenterEvent):void {
      var child:NodeViewController = event.data as NodeViewController;
      
      Log.debug('Rel: ' + child.parent.nodeData.drupalID + ' -> ' + child.nodeData.drupalID);
      
      if (
        child.parent.nodeData.type == NodeType.NODE &&
        child.nodeData.type == NodeType.NODE &&
        child.parent.nodeData.drupalID && 
        child.nodeData.drupalID
      ) {
        ConnectionController.mainConnection.call(
          'graphmindRelationship.addRelationship',
          onSuccess_nodeRelationshipAdded,
          null,
          child.parent.nodeData.drupalID,
          child.nodeData.drupalID,
          DEFAULT_RELATIONSHIP
        );
      }
    } 
    
    
    /**
    * Callback: relationship is saved.
    */
    private static function onSuccess_nodeRelationshipAdded(result:Object):void {
      Log.info('Relationship added.');
    }

  }

}
