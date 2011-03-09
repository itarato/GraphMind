package com.graphmind.factory {
  
	import com.graphmind.MapController;
	import com.graphmind.PluginManager;
	import com.graphmind.data.NodeData;
	import com.graphmind.display.NodeController;
	import com.kitten.network.Connection;
	import com.graphmind.ApplicationController;
	
	public class NodeFactory {
	
		public static function createNode(data:Object, type:String, conn:Connection = null, title:String = null):NodeController {
			var nodeData:NodeData = new NodeData(data, type, conn);
			
			// Set extra title
			if (title) {
				nodeData.title = title;
			}
			
			var node:NodeController = createNodeWithNodeData(nodeData); 
			
			return node;
		}
		
		public static function createNodeWithNodeData(nodeData:NodeData):NodeController {
		  var node:NodeController = new (ApplicationController.i.workflowComposite.getNodeControllerClass() as Class)(nodeData);
		  // @TODO rethink it -> too many levels
		  MapController.i.addNodeToStage(node);
		  
      // HOOK
      PluginManager.callHook(NodeController.HOOK_NODE_CREATED, {node: node});
		  return node;
		}
	
	}
	
}