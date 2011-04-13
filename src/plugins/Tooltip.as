package plugins {
  
  import com.graphmind.ConnectionController;
  import com.graphmind.NodeViewController;
  import com.graphmind.data.NodeType;
  import com.graphmind.event.EventCenter;
  import com.graphmind.event.EventCenterEvent;
  import com.graphmind.util.Log;
  
  public class Tooltip {


    public static function init():void {
      Log.info('Tooltip plugin init');
      
      EventCenter.subscribe(EventCenterEvent.NODE_CREATED, onNodeCreated);
    }
    
    
    private static function onNodeCreated(event:EventCenterEvent):void {
      var node:NodeViewController = event.data as NodeViewController;
      if (node.nodeData.type == NodeType.NODE && node.nodeData.drupalID && node.nodeData.connection.isConnected) {
        node.nodeData.connection.call(
          'graphmindTooltip.getView',
          function(result:Object):void {
            node.view.toolTip = result.toString();
          },
          ConnectionController.defaultRequestErrorHandler,
          node.nodeData.drupalID
        );
      }
    }

  }
  
}
