package plugins {
	
	import com.graphmind.display.NodeItem;
	import com.graphmind.net.RPCServiceHelper;
	
	import flash.events.ContextMenuEvent;
	
	public class TaxonomyManager {
		
		public static var i:TaxonomyManager = new TaxonomyManager();
		
		/**
		 * Implementation of hook_node_context_menu_alter().
		 */
		public static function hook_node_context_menu_alter(params:Object = null):void {
			(params.data as Array).push({title: 'Load taxonomy', event: TaxonomyManager.loadFullTaxonomyTree, separator: true});
		}
		
		public static function loadFullTaxonomyTree(event:ContextMenuEvent):void {
			var node:NodeItem = NodeItem.getLastSelectedNode();
			
//			RPCServiceHelper.createRPC(
		}

	}
	
}