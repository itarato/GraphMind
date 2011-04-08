package plugins {
  import com.graphmind.ConnectionController;
  import com.graphmind.NodeViewController;
  import com.graphmind.data.NodeType;
  import com.graphmind.event.EventCenter;
  import com.graphmind.event.EventCenterEvent;
  import com.graphmind.util.Log;
  import com.graphmind.view.NodeActionIcon;
  
  import mx.core.BitmapAsset;
  
  
  public class Relationship {
    
    /**
    * Default relationship type.
    */
    private static var DEFAULT_RELATIONSHIP:String = 'default';
    
    [Embed(source="assets/images/chart_organisation.png")]
    private static var relationshipImage:Class; 
    
    private static var relationshipActionIcon:NodeActionIcon;
    
    
    /**
    * Implemrentation of init().
    */
    public static function init():void {
      Log.info('Relationship plugin is live.');
      
      NodeViewController.canHasNormalChild = false;
      
      EventCenter.subscribe(EventCenterEvent.NODE_DID_ADDED_TO_PARENT, onNodeDidAddedToParent);
      EventCenter.subscribe(EventCenterEvent.NODE_IS_KILLED, onNodeIsKilled);
      EventCenter.subscribe(EventCenterEvent.NODE_WILL_BE_MOVED, onNodeWillBeMoved);
      EventCenter.subscribe(EventCenterEvent.NODE_CREATED, onNodeCreated);
    }
    
    
    /**
    * Event handler - node is added to a parent.
    */
    private static function onNodeDidAddedToParent(event:EventCenterEvent):void {
      var child:NodeViewController = event.data as NodeViewController;
      
      Log.debug('Rel added: ' + child.parent.nodeData.drupalID + ' -> ' + child.nodeData.drupalID + ' ' + DEFAULT_RELATIONSHIP);
      
      if (isNode(child, child.parent)) {
        ConnectionController.mainConnection.call(
          'graphmindRelationship.addRelationship',
          onSuccess_nodeRelationshipAdded,
          ConnectionController.defaultRequestErrorHandler,
          child.parent.nodeData.drupalID,
          child.nodeData.drupalID,
          DEFAULT_RELATIONSHIP
        );
      }
    }
    
    
    /**
    * Event handler - when a node is getting killed.
    */
    private static function onNodeIsKilled(event:EventCenterEvent):void {
      var child:NodeViewController = event.data as NodeViewController;
      
      Log.debug('Rel delete: ' + child.parent.nodeData.drupalID + ' -> ' + child.nodeData.drupalID + ' ' + DEFAULT_RELATIONSHIP);
      
      if (isNode(child, child.parent)) {
        ConnectionController.mainConnection.call(
          'graphmindRelationship.deleteRelationship',
          onSuccess_nodeRelationshipDeleted,
          ConnectionController.defaultRequestErrorHandler,
          child.parent.nodeData.drupalID,
          child.nodeData.drupalID,
          DEFAULT_RELATIONSHIP
        );
      }
    }
    
    
    /**
    * Event when a node will be moved to another parent.
    */
    public static function onNodeWillBeMoved(event:EventCenterEvent):void {
      onNodeIsKilled(event);
    }

    
    /**
    * Check if all the params are Drupal nodes.
    */
    private static function isNode(...args):Boolean {
      for each (var node:NodeViewController in args) {
        if (node.nodeData.type !== NodeType.NODE || !node.nodeData.drupalID) {
          return false;
        }
      }
      return true;
    }
    
    
    /**
    * Callback: relationship is saved.
    */
    private static function onSuccess_nodeRelationshipAdded(result:Object):void {
      Log.info('Relationship added.');
    }
    
    
    /**
    * Callback: relationship is deleted.
    */
    private static function onSuccess_nodeRelationshipDeleted(result:Object):void {
      Log.info('Relationship deleted.');
    }
    
    
    /**
    * Altering a node's context menu.
    */
    public static function alter_context_menu(cm:Array):void {
      // Deleteing the first item: creating normal node.
      for (var idx:* in cm) {
        if (cm[idx]['title'] == 'Add node') {
          delete cm[idx];
          return;
        }
      }
    }
    
    
    private static function onNodeCreated(event:EventCenterEvent):void {
      var node:NodeViewController = event.data as NodeViewController;
      relationshipActionIcon = new NodeActionIcon((new relationshipImage()) as BitmapAsset);
      node.view.addActionIcon(relationshipActionIcon);
    }
  }

}
