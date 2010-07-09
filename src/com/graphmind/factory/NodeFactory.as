package com.graphmind.factory {
  
	import com.graphmind.PluginManager;
	import com.graphmind.data.NodeData;
	import com.graphmind.display.NodeController;
	import com.graphmind.net.SiteConnection;
	
	public class NodeFactory {
	
		public static function createNode(data:Object, type:String, sc:SiteConnection = null, title:String = null):NodeController {
			var nodeData:NodeData = new NodeData(data, type, sc);
			
			// Set extra title
			if (title) {
				nodeData.title = title;
			}
			
			var node:NodeController = createNodeWithNodeData(nodeData); 
			
			return node;
		}
		
		public static function createNodeWithNodeData(nodeData:NodeData):NodeController {
		  var node:NodeController = new (GraphMind.i.workflowComposite.getNodeControllerClass() as Class)(nodeData);
		  GraphMind.i.stageManager.addNodeToStage(node);
		  
      // HOOK
      PluginManager.callHook(NodeController.HOOK_NODE_CREATED, {node: node});
		  return node;
		}
	
	}
	
}