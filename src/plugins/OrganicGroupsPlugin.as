package plugins {
  
  import com.graphmind.ApplicationController;
  import com.graphmind.ConnectionController;
  import com.graphmind.FeatureController;
  import com.graphmind.NodeContextMenuController;
  import com.graphmind.NodeViewController;
  import com.graphmind.data.NodeDataObject;
  import com.graphmind.data.NodeType;
  import com.graphmind.display.ConfigPanelController;
  import com.graphmind.event.EventCenter;
  import com.graphmind.event.EventCenterEvent;
  import com.graphmind.util.OSD;
  
  import flash.events.ContextMenuEvent;
  import flash.events.MouseEvent;
  import flash.external.ExternalInterface;
  
  import plugins.organicgroupsplugin.LoadDrupalNodeComponent;
  
  
  public class OrganicGroupsPlugin {
    
    /**
    * Separate control panel for loading nodes.
    */
    private static var nodeLoadPanel:ConfigPanelController;
    private static var nodeLoadComponent:LoadDrupalNodeComponent;
    
    /**
    * Indicates if the feature was enabled but disabled by this plugin.
    */ 
    private static var nodeLoadFeatureWasEnabled:Boolean = false;
    
    
    /**
    * Implementation of the plugin init function.
    */
    public static function init():void {
      EventCenter.subscribe(EventCenterEvent.FEATURES_CHANGED, onFeaturesChanged);
      
      nodeLoadPanel = new ConfigPanelController('Load Drupal Item');
      nodeLoadComponent = new LoadDrupalNodeComponent();
      nodeLoadPanel.addItem(nodeLoadComponent);
      nodeLoadComponent.submitButton.addEventListener(MouseEvent.CLICK, onClick_drupalItemLoadSubmit);
      
      if (ExternalInterface.available) {
        ExternalInterface.addCallback('sendOGNodeLoadRequestToFlex', onSendOGNodeLoadRequestToFlex);
      }
    }
    
    
    /**
    * Callback - when application's feature set is changed.
    */
    private static function onFeaturesChanged(event:EventCenterEvent):void {
      if (FeatureController.isFeatureEnabled(FeatureController.LOAD_DRUPAL_NODE)) {
        FeatureController.removeFeature(FeatureController.LOAD_DRUPAL_NODE);
        nodeLoadFeatureWasEnabled = true;
      }
    }
    
    
    /**
    * Alters a node's context menu.
    */
    public static function alter_context_menu(contextMenuController:NodeContextMenuController):void {
      if (!nodeLoadFeatureWasEnabled) return;
      
      contextMenuController.addItem('Load Drupal item', onContextMenuSelect_loadDruplaItem, 0, 'data');
    }
    
    
    /**
    * Callback - when the node-load context menu item is selected.
    */
    private static function onContextMenuSelect_loadDruplaItem(e:ContextMenuEvent):void {
      nodeLoadPanel.show();
    }
    
    
    /**
    * Callback - when the node load form is submitted.
    */
    private static function onClick_drupalItemLoadSubmit(e:MouseEvent):void {
      ConnectionController.mainConnection.call(
        'graphmindOG.getNode',
        onNodeGetSuccess,
        onNodeGetFail,
        parseInt(nodeLoadComponent.nodeIDField.text),
        ApplicationController.getHostNodeID()
      );
    }
    
    
    /**
    * Node load success callback.
    */
    private static function onNodeGetSuccess(result:Object):void {
      nodeLoadPanel.hide();
      
      if (!result) {
        onNodeGetFail(result);
        return;
      }
      
      var node:NodeViewController = new NodeViewController(new NodeDataObject(result, NodeType.NODE, ConnectionController.mainConnection));
      NodeViewController.activeNode.addChildNode(node);
    }
    
    
    /**
    * Node load failure callback.
    */
    private static function onNodeGetFail(result:Object):void {
      OSD.show("Sorry, you don\'t have permission to load the node. Maybe it\'s not in the same organic group. \nCheck the node ID again.", OSD.WARNING);
    }
    
    
    /**
    * Callback from JS - request for a node can be sent.
    */
    private static function onSendOGNodeLoadRequestToFlex(nid:uint):void {
      ConnectionController.mainConnection.call(
        'graphmindOG.getNode',
        onNodeGetSuccess,
        onNodeGetFail,
        nid,
        ApplicationController.getHostNodeID()
      );
    }
    
  }

}
