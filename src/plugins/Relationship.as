package plugins {
  
  import com.graphmind.ConnectionController;
  import com.graphmind.NodeViewController;
  import com.graphmind.TreeMapViewController;
  import com.graphmind.data.NodeDataObject;
  import com.graphmind.data.NodeType;
  import com.graphmind.event.EventCenter;
  import com.graphmind.event.EventCenterEvent;
  import com.graphmind.util.Log;
  import com.graphmind.view.NodeActionIcon;
  
  import flash.events.ContextMenuEvent;
  import flash.events.MouseEvent;
  
  import mx.collections.ArrayCollection;
  import mx.core.Application;
  import mx.core.BitmapAsset;
  
  
  public class Relationship {
    
    /**
    * Default relationship type.
    */
    private static var DEFAULT_RELATIONSHIP:String = 'default';
    
    [Embed(source="assets/images/chart_organisation.png")]
    private static var relationshipImage:Class; 
    
    private static var relationshipActionIcon:NodeActionIcon;
    
    private static var depth:uint = 3;
    
    
    /**
    * Implemrentation of init().
    */
    public static function init():void {
      Log.info('Relationship plugin is live.');
      
      if (Application.application.parameters.hasOwnProperty('graphmindRelationshipDepth')) {
        depth = Application.application.parameters.graphmindRelationshipDepth;
        Log.info('Relationship depth: ' + depth);
      }
      
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
          break;
        }
      }
      
      cm.push({title: 'Refresh relationships', event: onMenuItemSelect_RefreshSubtree, separator: true});
    }
    
    
    /**
    * Event callback when a new node is created.
    */
    private static function onNodeCreated(event:EventCenterEvent):void {
      var node:NodeViewController = event.data as NodeViewController;
      relationshipActionIcon = new NodeActionIcon((new relationshipImage()) as BitmapAsset);
      node.view.addActionIcon(relationshipActionIcon);
      
      relationshipActionIcon.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
        onMouseClick_relationshipActionIcon(event, node);
      });
    }
    
    
    /**
    * Event callback when the relationship action icon is clicked.
    */
    private static function onMouseClick_relationshipActionIcon(event:MouseEvent, node:NodeViewController):void {
      ConnectionController.mainConnection.call(
        'graphmindRelationship.getSubtree',
        function (result:Object):void {
          onSuccess_loadRelationshipSubtree(node, result);
        },
        ConnectionController.defaultRequestErrorHandler,
        node.nodeData.drupalID,
        depth
      );
    }
    
    
    /**
    * Event callback when a node's relationships are arrived.
    */
    private static function onSuccess_loadRelationshipSubtree(node:NodeViewController, result:Object):void {
      trace('success of rel subtree');
      addSubtree(node, result as Array);
    }
    
    
    /**
    * Adds a list of items to a node recursively.
    * Returns all the node IDs that are connected.
    */
    private static function addSubtree(parent:NodeViewController, childs:Array):Array {
      var connectedIDs:Array = [];
      for (var idx:* in childs) {
        connectedIDs.push(childs[idx]['node']['nid']);
        var child:NodeViewController = getExistingNodeOfParent(parent, childs[idx]['node']['nid']);
        if (!child) {
          child = new NodeViewController(new NodeDataObject(childs[idx]['node'], NodeType.NODE, ConnectionController.mainConnection));
          parent.addChildNode(child);
        }
        addSubtree(child, childs[idx]['relationships']);
      }
      
      return connectedIDs;
    }
    
    
    /**
    * Get an already existing node of the same ID.
    */
    private static function getExistingNodeOfParent(parent:NodeViewController, nid:int):NodeViewController {
      var childs:ArrayCollection = parent.getChildNodeAll();
      for (var idx:* in childs) {
        var child:NodeViewController = childs[idx];
        if (child.nodeData.type == NodeType.NODE && child.nodeData.drupalID == nid) {
          return child;
        }
      }
      
      return null;
    }
    
    
    /**
    * Event callback - clicking on the refresh subtree context menu item.
    */
    private static function onMenuItemSelect_RefreshSubtree(event:ContextMenuEvent):void {
      refreshSubtree(TreeMapViewController.activeNode);
    }
    
    
    /**
    * Refresh a subtree.
    */ 
    private static function refreshSubtree(node:NodeViewController):void {
      ConnectionController.mainConnection.call(
        'graphmindRelationship.getSubtree',
        function (result:Object):void {
          onSuccess_refreshSubtreeRequest(node, result);
        },
        ConnectionController.defaultRequestErrorHandler,
        node.nodeData.drupalID,
        1
      );
    }
    
    
    /**
    * Event callback when a subtree refresh info is arrived.
    */
    private static function onSuccess_refreshSubtreeRequest(parent:NodeViewController, result:Object):void {
      var connectedIDs:Array = addSubtree(parent, result as Array);
      var childs:ArrayCollection = parent.getChildNodeAll();
      for (var idx:* in childs) {
        var child:NodeViewController = childs[idx] as NodeViewController;
        if (child.nodeData.type != NodeType.NODE || connectedIDs.indexOf(child.nodeData.drupalID.toString()) == -1) {
          // It's a non existing relationship.
          child.kill();
        } else {
          if (child.hasChild()) {
            refreshSubtree(child);
          }
        }
      }
    }
  }

}
