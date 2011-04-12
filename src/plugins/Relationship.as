package plugins {
  
  import com.graphmind.ConnectionController;
  import com.graphmind.NodeViewController;
  import com.graphmind.TreeMapViewController;
  import com.graphmind.data.NodeDataObject;
  import com.graphmind.data.NodeType;
  import com.graphmind.event.EventCenter;
  import com.graphmind.event.EventCenterEvent;
  import com.graphmind.util.GlobalLock;
  import com.graphmind.util.Log;
  import com.graphmind.util.OSD;
  import com.graphmind.view.NodeActionIcon;
  
  import flash.events.ContextMenuEvent;
  import flash.events.MouseEvent;
  import flash.utils.setTimeout;
  
  import mx.collections.ArrayCollection;
  import mx.core.Application;
  import mx.core.BitmapAsset;
  
  import plugins.relationship.RelationshipSettingsPanel;
  
  
  public class Relationship {
    
    /**
    * Default relationship type.
    */
    private static var DEFAULT_RELATIONSHIP:String = 'default';
    
    /**
    * Image asset for the relationship action icon.
    */
    [Embed(source="assets/images/chart_organisation.png")]
    private static var relationshipImage:Class; 
    
    /**
    * Relatioship action icon for the node ui.
    */
    private static var relationshipActionIcon:NodeActionIcon;
    
    /**
    * Default maximum depth for loading relationships.
    */
    [Bindable]
    public static var depth:uint = 3;
    
    /**
    * Settings panel component.
    */
    private static var settingsPanel:RelationshipSettingsPanel;
    
    /**
    * True if refreshing happens.
    */
    private static var refreshFlag:Boolean = false;
    
    /**
    * True if update need is filed but no request sent so far.
    */
    private static var refreshRequestPending:Boolean = false;
    
    /**
    * Lock site for refreshing.
    */
    private static var REFRESH_LOCK:String = 'refresh lock';
    
    /**
    * Frequency related vars for the update period.
    */
    [Bindable]
    public static var frequencies:Array = ['5 seconds', '15 seconds', '1 minute', '5 minutes'];
    private static var frequenciesSeconds:Array = [5, 15, 60, 300];
    private static var frequency:uint = frequenciesSeconds[0];
    
    
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
      
      settingsPanel = new RelationshipSettingsPanel;
      GraphMind.i.mindmapToolsPanel.mindmapToolsAccordion.addChild(settingsPanel);
      
      checkForChangesWithLoop();
    }
    
    
    /**
    * Event handler - node is added to a parent.
    */
    private static function onNodeDidAddedToParent(event:EventCenterEvent):void {
      if (refreshFlag) return;
      
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
      if (refreshFlag) return;
      
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
    private static function onNodeWillBeMoved(event:EventCenterEvent):void {
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
    public static function refreshSubtree(node:NodeViewController):void {
      refreshRequestPending = false;
      
      EventCenter.notify(EventCenterEvent.MAP_LOCK);
      GlobalLock.lock(REFRESH_LOCK);
      
      ConnectionController.mainConnection.call(
        'graphmindRelationship.getSubtree',
        function (result:Object):void {
          onSuccess_refreshSubtreeRequest(node, result);
        },
        function(error:Object):void {
          GlobalLock.unlock(REFRESH_LOCK);
          ConnectionController.defaultRequestErrorHandler(error);
        },
        node.nodeData.drupalID,
        1
      );
    }
    
    
    /**
    * Event callback when a subtree refresh info is arrived.
    */
    private static function onSuccess_refreshSubtreeRequest(parent:NodeViewController, result:Object):void {
      refreshFlag = true;
      
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
      
      refreshFlag = false;
      
      GlobalLock.unlock(REFRESH_LOCK);
      if (!GlobalLock.isLocked(REFRESH_LOCK)) {
        EventCenter.notify(EventCenterEvent.MAP_UNLOCK);
      }
    }
    
    
    /**
    * Send a request to check if relationships are changed at the backend.
    */
    public static function checkForChanges():void {
      checkForChangesWithCallback(onSuccess_refreshInfoArrived);
    }
    
    
    /**
    * Update check request - called periodically.
    */
    private static function checkForChangesWithLoop():void {
      trace('LOOP CHECK');
      setTimeout(function():void{
        if (refreshRequestPending) {
          checkForChangesWithLoop();
        } else {
          checkForChangesWithCallback(function(result:Object):void{
            onSuccess_refreshInfoArrived(result);
            checkForChangesWithLoop();
          });
        }
      }, frequency * 1000);
    }
    
    
    /**
    * Same as checkForChanges - sends a request to know if backend is changed - it accepts a callback.
    */
    private static function checkForChangesWithCallback(callback:Function):void {
      if (refreshRequestPending) return;
      var tree:Object = {};
      tree[TreeMapViewController.rootNode.nodeData.drupalID] = collectSubtreeIDs(TreeMapViewController.rootNode, []);
      ConnectionController.mainConnection.call(
        'graphmindRelationship.checkUpdate',
        callback,
        ConnectionController.defaultRequestErrorHandler,
        tree
      );
    }
    
    
    /**
    * Event callback - request for getting the update info arrived.
    */
    private static function onSuccess_refreshInfoArrived(result:Object):void {
      if (!result) {
        // Structure is changed at the backend.
        OSD.show('Structure is changed. Please refresh your map in the \'Relationships\' panel.', OSD.WARNING, true);
        refreshRequestPending = true; 
      }
    }
    
    
    /**
    * Creates a structured ID array object from the tree as a parameter.
    */
    private static function collectSubtreeIDs(node:NodeViewController, cycleCheckArray:Array):Array {
      var ids:Array = [];
      var childs:ArrayCollection = node.getChildNodeAll();
      for (var idx:* in childs) {
        var child:NodeViewController = childs[idx] as NodeViewController;
        if (child.nodeData.type == NodeType.NODE && child.nodeData.drupalID) {
          var subtree:Object = {};
          if (cycleCheckArray.indexOf(child.nodeData.drupalID) == -1) {
            cycleCheckArray.push(child.nodeData.drupalID);
            subtree[child.nodeData.drupalID] = collectSubtreeIDs(child, cycleCheckArray);
          } else {
            subtree[child.nodeData.drupalID] = [];
          }
          ids.push(subtree);
        }
      }
      return ids;
    }
    
    
    /**
    * Set the update check frequency.
    */
    public static function setUpdateCheckFrequency(idx:uint):void {
      frequency = frequenciesSeconds[idx];
    }
    
  }

}
