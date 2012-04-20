package plugins {
  
  import com.graphmind.ApplicationController;
  import com.graphmind.ConnectionController;
  import com.graphmind.ExportController;
  import com.graphmind.MainMenuController;
  import com.graphmind.NodeContextMenuController;
  import com.graphmind.NodeViewController;
  import com.graphmind.TreeMapViewController;
  import com.graphmind.data.NodeContextMenu;
  import com.graphmind.data.NodeContextMenuSection;
  import com.graphmind.data.NodeDataObject;
  import com.graphmind.data.NodeType;
  import com.graphmind.display.ConfigPanelController;
  import com.graphmind.event.EventCenter;
  import com.graphmind.event.EventCenterEvent;
  import com.graphmind.temp.DrupalItemRequestParamObject;
  import com.graphmind.util.GlobalLock;
  import com.graphmind.util.Log;
  import com.graphmind.util.OSD;
  import com.graphmind.view.NodeActionIcon;
  
  import flash.events.ContextMenuEvent;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.external.ExternalInterface;
  import flash.utils.clearTimeout;
  import flash.utils.setTimeout;
  
  import mx.collections.ArrayCollection;
  import mx.core.Application;
  import mx.events.FlexEvent;
  
  import plugins.relationship.RelationshipSettingsPanel;
  
  
  public class Relationship {
    
    /**
    * Default relationship type.
    */
    private static var DEFAULT_RELATIONSHIP:String = 'default';
    
    /**
    * Unique string for the refresh update warning OSD message.
    */
    private static var UPDATE_WARNING_OSD:String = 'updateWarningOSD';
    
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
    * Refresh icon.
    */
    [Embed(source="assets/images/arrow_refresh.png")]
    private static var refreshImage:Class;

    /**
    * Add icon.
    */
    [Embed(source="assets/images/add.png")]
    private static var addImage:Class;
    
    private static var addDrupalNodeActionIcon:NodeActionIcon;
    
    /**
    * View node image.
    */
    [Embed(source="assets/images/application_view_gallery.png")]
    private static var viewNodeImage:Class;
    
    private static var viewNodeActionIcon:NodeActionIcon;
    
    /**
    * Edit node image.
    */
    [Embed(source="assets/images/application_form_edit.png")]
    private static var editNodeImage:Class;
    
    private static var editNodeActionIcon:NodeActionIcon; 
    
    /**
    * Default maximum depth for loading relationships.
    */
    [Bindable]
    public static var depth:uint = 3;
    
    /**
    * Settings panel component.
    */
    private static var settingsComponent:RelationshipSettingsPanel;
    private static var settingsPanel:ConfigPanelController;
    
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
    public static var updateFrequencies:Array = ['5 seconds', '15 seconds', '1 minute', '5 minutes'];
    private static var updateFrequenciesSeconds:Array = [5, 15, 60, 300];
    private static var updateFrequency:uint = updateFrequenciesSeconds[0];
    
    /**
    * Update frequency - 10 seconds.
    */
    [Bindable]
    public static var saveFrequencies:Array = ['3 seconds', '5 seconds', '10 seconds', '30 seconds'];
    public static var saveFrequenciesSeconds:Array = [3000, 5000, 10000, 30000];
    public static var saveFrequency:uint = saveFrequenciesSeconds[1];
    private static var saveTimeout:uint;
    
    /**
    * User color storage.
    */
    private static var userColors:Object = {};
    
    private static var focusNodeBackupInfo:Array = [];
    
    /**
    * On hard refresh store the nodes have to be collapsed.
    */
    private static var collapseStateCache:Array = [];
    
    
    /**
    * Implemrentation of init().
    */
    public static function init():void {
      Log.info('Relationship plugin is live.');

      refreshFlag = true;
      
      if (Application.application.parameters.hasOwnProperty('graphmindRelationshipDepth')) {
        depth = Application.application.parameters.graphmindRelationshipDepth;
        Log.info('Relationship depth: ' + depth);
      }
      
      NodeViewController.canHasNormalChild = false;
      NodeViewController.canHasAnchor = false;
      NodeViewController.canHasAttributes = false;
      NodeViewController.canHasTitleEditing = false;
      
      EventCenter.subscribe(EventCenterEvent.NODE_DID_ADDED_TO_PARENT, onNodeDidAddedToParent);
      EventCenter.subscribe(EventCenterEvent.NODE_IS_KILLED, onNodeIsKilled);
      EventCenter.subscribe(EventCenterEvent.NODE_WILL_BE_MOVED, onNodeWillBeMoved);
      EventCenter.subscribe(EventCenterEvent.NODE_CREATED, onNodeCreated);
      EventCenter.subscribe(EventCenterEvent.MAP_TREE_IS_COMPLETE, onMapTreeIsComplete);
      EventCenter.subscribe(EventCenterEvent.ALTER_SETTINGS_PANEL, onAlterSettingsPanel);
      EventCenter.subscribe(EventCenterEvent.NODE_IS_SELECTED, onNodeIsSelected);
      
      ExternalInterface.addCallback('sendCreationRequestBackToFlex', onReturnCreationRequest);
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
    public static function alter_context_menu(contextMenuController:NodeContextMenuController):void {
      // Deleteing the first item: creating normal node.
      var section:NodeContextMenuSection = NodeContextMenuSection.getSection('default');
      for (var idx:* in section.contextMenus) {
        if ((section.contextMenus[idx] as NodeContextMenu).name == 'Add node') {
          delete section.contextMenus[idx];
          break;
        }
      }
      
      contextMenuController.addItem('View details', onMouseClick_viewNodeActionIcon, 2, 'data');
      contextMenuController.addItem('Create node', onMouseClick_addDrupalNodeIcon, 1, 'data');
    }
    
    
    /**
    * Event callback when a new node is created.
    */
    private static function onNodeCreated(event:EventCenterEvent):void {
      var node:NodeViewController = event.data as NodeViewController;
      
      // Get user colors -> background colors.
      if (node.nodeData.drupalData.hasOwnProperty('userid') && node.nodeData.connection.isConnected) {
        var uid:uint = node.nodeData.drupalData.userid;
        if (!userColors.hasOwnProperty(uid)) {
          userColors[uid] = null;
          node.nodeData.connection.call(
            'graphmindRelationship.getUserColor',
            function(result:Object):void{
              onSuccess_userColorRequest(result, uid);
            },
            ConnectionController.defaultRequestErrorHandler,
            uid
          );
        } else if (userColors[uid]) {
          node.setColor(userColors[uid]);
        }
      }
    }
    
    
    /**
    * Adds a list of items to a node recursively.
    * Returns all the node IDs that are connected.
    */
    private static function addSubtree(parent:NodeViewController, children:Array, mapDataCache:Object):void {
      var idx:*;
      var cachedOrder:Array = [];
      var notCached:Array = [];
      
      for each (var icon:String in mapDataCache['icons']) {
        parent.addIcon(ApplicationController.getIconPath() + icon + '.png');
      }
      if (mapDataCache['collapsed']) {
        collapseStateCache.push(parent);
      }
      if (mapDataCache['cloud']) {
        parent.toggleCloud();
      }
      
      for (idx in children) {
        var node:NodeViewController = new NodeViewController(new NodeDataObject(children[idx].node, NodeType.NODE, ConnectionController.mainConnection));
        parent.addChildNode(node);
        var nodeCachedData:Object;
        if (mapDataCache && mapDataCache.hasOwnProperty('children') && mapDataCache['children'].hasOwnProperty(node.nodeData.drupalID)) {
          nodeCachedData = mapDataCache['children'][node.nodeData.drupalID] as Object;
          nodeCachedData['node'] = node;
          cachedOrder.push(nodeCachedData);
        } else {
          // Node is not in the cache
          notCached.push(node);
        }
        addSubtree(node, children[idx].children, nodeCachedData ? nodeCachedData : {});
      }
      
      cachedOrder.sort(function(a:Object, b:Object):int{
        return (a['position'] < b['position']) ? -1 : 1;
      });
      
      // Fix order from cache
      parent.getChildNodeAll().removeAll();
      for (idx in cachedOrder) {parent.getChildNodeAll().addItem(cachedOrder[idx]['node']);}
      for (idx in notCached)   {parent.getChildNodeAll().addItem(notCached[idx]);}
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
    * Event callback when a subtree refresh info is arrived.
    */
    private static function onSuccess_refreshSubtreeRequest(result:Object):void {
      refreshFlag = true;
      
      focusNodeBackupInfo = [];
      var parent:NodeViewController = NodeViewController.activeNode;
      while (parent) {
        focusNodeBackupInfo.push(parent.nodeData.drupalID);
        parent = parent.parent;
      }
      
      var mapDataCache:Object = mapDataSnapshot(TreeMapViewController.rootNode);
      collapseStateCache = [];
      
      // Remove old tree
      TreeMapViewController.rootNode.kill(true);
      
      var node:NodeViewController = new NodeViewController(new NodeDataObject(result.node, NodeType.NODE, ConnectionController.mainConnection));
      TreeMapViewController.rootNode = node;
      addSubtree(node, result.children, mapDataCache);
      
      for each (var nodeToCollapse:NodeViewController in collapseStateCache) {
        nodeToCollapse.collapse();
      }
      
      var currentNID:uint = focusNodeBackupInfo.pop();
      var currentNode:NodeViewController = 
        currentNID == TreeMapViewController.rootNode.nodeData.drupalID ?
          TreeMapViewController.rootNode :
          null;
      while (focusNodeBackupInfo.length > 0 && currentNode) {
        currentNID = focusNodeBackupInfo.pop();
        var foundChild:Boolean = false; 
        for each (var child:NodeViewController in currentNode.getChildNodeAll()) {
          if (child.nodeData.drupalID == currentNID) {
            currentNode = child;
            foundChild = true;
            break;
          }
        }
        if (!foundChild) {
          break;
        }
      }
      if (currentNode) {
        currentNode.view.addEventListener(FlexEvent.CREATION_COMPLETE, function(e:Event):void{
          setTimeout(function():void {
            currentNode.select();
            ApplicationController.i.treeMapViewController.centerMapTo(currentNode.view.x, currentNode.view.y);
          }, 100);
        });
      }
      
      refreshFlag = false;
      
      OSD.removeNamedMessages(UPDATE_WARNING_OSD);
      
      refreshRequestPending = false;
      GlobalLock.unlock(REFRESH_LOCK);
      if (!GlobalLock.isLocked(REFRESH_LOCK)) {
        EventCenter.notify(EventCenterEvent.MAP_UNLOCK);
      }
    }
    
    
    /**
    * Send a request to check if relationships are changed at the backend.
    */
    public static function checkForChanges():void {
      checkForChangesWithCallback(function(result:Object):void{
        onSuccess_refreshInfoArrived(result);
        if (result) {
          OSD.show('Map is up to date.');
        }
      });
    }
    
    
    /**
    * Update check request - called periodically.
    */
    private static function checkForChangesWithLoop():void {
      setTimeout(function():void{
        if (refreshRequestPending) {
          checkForChangesWithLoop();
        } else {
          checkForChangesWithCallback(function(result:Object):void{
            onSuccess_refreshInfoArrived(result);
            checkForChangesWithLoop();
          });
        }
      }, updateFrequency * 1000);
    }
    
    
    /**
    * Same as checkForChanges - sends a request to know if backend is changed - it accepts a callback.
    */
    private static function checkForChangesWithCallback(callback:Function):void {
      if (refreshRequestPending) return;
      var tree:Object = {};
      tree['nid'] = TreeMapViewController.rootNode.nodeData.drupalID;
      tree['node'] = {title: TreeMapViewController.rootNode.nodeData.drupalData.title};
      tree['children'] = collectSubtreeIDs(TreeMapViewController.rootNode, depth);
      ConnectionController.mainConnection.call(
        'graphmindRelationship.checkUpdate',
        callback,
        ConnectionController.defaultRequestErrorHandler,
        tree,
        depth
      );
    }
    
    
    /**
    * Event callback - request for getting the update info arrived.
    */
    private static function onSuccess_refreshInfoArrived(result:Object):void {
      if (!result) {
        // Structure is changed at the backend.
        OSD.removeNamedMessages(UPDATE_WARNING_OSD);
        OSD.show('The map has new data - click Refresh Map to refresh.', OSD.WARNING, true, UPDATE_WARNING_OSD);
        refreshRequestPending = true; 
      }
    }
    
    
    /**
    * Creates a structured ID array object from the tree as a parameter.
    */
    private static function collectSubtreeIDs(node:NodeViewController, depth:uint):Array {
      var children:ArrayCollection = node.getChildNodeAll();
      var data:Array = [];
      if (depth > 0) {
        for (var idx:* in children) {
          var child:Object = {};
          child['nid'] = (children[idx] as NodeViewController).nodeData.drupalID;
          child['node'] = {title: (children[idx] as NodeViewController).nodeData.drupalData.title};
          child['children'] = collectSubtreeIDs(children[idx], depth - 1);
          data.push(child);
        }
      }
      return data;
    }
    
    
    /**
    * Set the update check frequency.
    */
    public static function setUpdateCheckFrequency(idx:uint):void {
      updateFrequency = updateFrequenciesSeconds[idx];
    }
    
    
    /**
    * Event callback - map is ready with the node tree.
    */
    private static function onMapTreeIsComplete(event:EventCenterEvent):void {
      // Start checking the updates.
      checkForChangesWithLoop();
      startAutoSave();
      refreshFlag = false;
      
      MainMenuController.createIconMenuItem(refreshImage, 'Refresh map', onMenuClick_RefreshMap);
    }
    
    
    /**
    * Event handler - click on the create and attach Drupal node icon.
    */ 
    private static function onMouseClick_addDrupalNodeIcon(e:ContextMenuEvent):void {
      if (!ExternalInterface.available) {
        OSD.show('Can\'t create a node from here. Use Drupal and refresh your map.');
        return;
      }
      
      var node:NodeViewController = NodeViewController.activeNode;
      var type:String = Application.application.parameters.hasOwnProperty('graphmindRelationshipDefaultCreatedNodeType') ?
        Application.application.parameters.graphmindRelationshipDefaultCreatedNodeType : '';
	    var htmlObjectID:String = 'graphmind_map_' + Application.application.parameters.entity_id + '_' +
		    Application.application.parameters.entity_vid + '_' + Application.application.parameters.delta;

      ExternalInterface.call('GraphmindRelationship.openNodeCreation', node.nodeData.drupalID, type, htmlObjectID);
    }
    
    
    /**
    * Event handler - call from JavaScript with the creation parameters.
    */
    private static function onReturnCreationRequest(parentNid:uint, childNid:uint):void {
      for (var idx:* in NodeViewController.nodes) {
        var node:NodeViewController = NodeViewController.nodes[idx] as NodeViewController;
        if (
          node.nodeData.type == NodeType.NODE &&
          node.nodeData.drupalID == parentNid
        ) {
          var data:DrupalItemRequestParamObject = new DrupalItemRequestParamObject();
          data.conn = ConnectionController.mainConnection;
          data.id = childNid.toString();
          data.parentNode = node;
          data.type = NodeType.NODE;
          EventCenter.notify(EventCenterEvent.LOAD_DRUPAL_ITEM, data);
          return;
        }
      }
      
      OSD.show('Error occured during node attachement. Please refresh your map or try again.', OSD.WARNING);
    }
    
    
    /**
    * Event callback - user color reqest is done.
    */
    private static function onSuccess_userColorRequest(result:Object, userid:uint):void {
      userColors[userid] = uint(result);
      var node:NodeViewController;
      for (var idx:* in NodeViewController.nodes) {
        node = NodeViewController.nodes[idx];
        
        if (node.nodeData.drupalData.hasOwnProperty('userid') && node.nodeData.drupalData.userid == userid) {
          node.setColor(uint(result));
        }
      }
    }
    
    
    /**
    * Event callback - click on the view-node-edit-page action icon.
    */
    private static function onMouseClick_viewNodeActionIcon(e:ContextMenuEvent):void {
      if (!ExternalInterface.available) {
        OSD.show('Popup window is not available.');
      }
      var node:NodeViewController = NodeViewController.activeNode;
      ExternalInterface.call('GraphmindRelationship.openPopupWindow', node.nodeData.link);
    }
    
    
    private static function onClick_RelationshipsMenuItem(e:MouseEvent):void {
      settingsPanel.toggle();
    }
    
    
    private static function onAlterSettingsPanel(e:EventCenterEvent):void {
      (e.data as Array).push(new RelationshipSettingsPanel());
    }
    
    
    /**
    * Checks if the same node already exists among the ancestors.
    * Returns true if it's a loop.
    */ 
    private static function loopCheck(parent:NodeViewController, nid:uint):Boolean {
      if (isNode(parent) && parent.nodeData.drupalID == nid) {
        return true;
      } else if (parent.parent) {
        return loopCheck(parent.parent, nid);
      }
      
      return false;
    }
    
    
    /**
    * Event callback - when a node is selected.
    */
    private static function onNodeIsSelected(e:EventCenterEvent):void {
      if (ExternalInterface.available) {
        var node:NodeViewController = e.data as NodeViewController;
        if (isNode(node)) {
          ExternalInterface.call('GraphmindRelationship.loadNodeInBlock', node.nodeData.drupalID);
        }
      }
    }
    
    
    private static function onMenuClick_RefreshMap(e:MouseEvent):void {
      hardRefreshTree();
    }
    
    
    private static function hardRefreshTree():void {
      
      EventCenter.notify(EventCenterEvent.MAP_LOCK);
      ConnectionController.mainConnection.call(
        'graphmindRelationship.getSubtree',
        function(e:Object):void{
          GlobalLock.lock(REFRESH_LOCK);
          onSuccess_refreshSubtreeRequest(e);
        },
        function(e:Object):void{
          GlobalLock.unlock(REFRESH_LOCK);
          EventCenter.notify(EventCenterEvent.MAP_UNLOCK);
          ConnectionController.defaultRequestErrorHandler(e);
        },
        TreeMapViewController.rootNode.nodeData.drupalID,
        depth
      );
    }
    
    
    /**
    * Begin autosaving.
    */
    private static function startAutoSave():void {
      if (!ApplicationController.i.isEditable()) {
        return;
      }
      
      EventCenter.subscribe(EventCenterEvent.MAP_SAVED_SILENTLY, function(e:Event):void{
        autoSave();
      });
      autoSave();
    }
    
    
    /**
    * Autosave.
    */
    private static function autoSave():void {
      clearTimeout(saveTimeout);
      saveTimeout = setTimeout(function():void{
        var xml:String = ExportController.getFreeMindXML(TreeMapViewController.rootNode);
        ExportController.saveFreeMindXMLToDrupalSilent(xml);
      }, saveFrequency);
    }
    
    
    /**
    * Cache a snapshot of the tree to preserve map info, such as cloud, collapse state, icons.
    */
    private static function mapDataSnapshot(node:NodeViewController):Object {
      var data:Object = {};
      data['cloud'] = node.hasCloud();
      data['collapsed'] = node.isForcedCollapsed();
      data['icons'] = node.nodeData.icons;
      data['children'] = {};
      data['position'] = node.parent ? node.parent.getChildNodeAll().getItemIndex(node) : 0;
      for each (var child:NodeViewController in node.getChildNodeAll()) {
        data['children'][child.nodeData.drupalID] = mapDataSnapshot(child);
      }
      return data;
    }
  }

}
