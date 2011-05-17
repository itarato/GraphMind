package plugins {
  
  import com.graphmind.ConnectionController;
  import com.graphmind.NodeViewController;
  import com.graphmind.data.NodeDataObject;
  import com.graphmind.data.NodeType;
  import com.graphmind.util.OSD;
  
  import flash.events.ContextMenuEvent;
  
  
  public class FlagsPlugin {

    /**
    * Alters the node context menu.
    */  
    public static function alter_context_menu(cm:Array):void {
      cm.push({title: 'Load flagged content', event: onContextMenuSelected_loadFlaggedContent, separator: true});
    }    

    
    /**
    * Callback when user clicks on the get flagged content context menu.
    */
    private static function onContextMenuSelected_loadFlaggedContent(e:ContextMenuEvent):void {
      ConnectionController.mainConnection.call(
        'graphmindFlags.getContent',
        onSuccess_getContent,
        onFailure_getContent
      );
    }
    
    
    /**
    * Callback event when the content is arrived from Drupal.
    */
    private static function onSuccess_getContent(result:Object):void {
      if ((result as Array).length == 0) {
        onFailure_getContent(result);
      }
      
      for (var idx:* in result) {
        var node:NodeViewController = new NodeViewController(new NodeDataObject(result[idx], NodeType.NODE, ConnectionController.mainConnection));
        NodeViewController.activeNode.addChildNode(node);
      }
    }
    
    
    /**
    * Error callback when request for the content fails.
    */
    private static function onFailure_getContent(result:Object):void {
      OSD.show('There is no new marked nodes.', OSD.WARNING);
    }

  }
  
}
