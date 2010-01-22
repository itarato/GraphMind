package plugins {
	
	import com.graphmind.data.NodeItemData;
	import com.graphmind.display.NodeItem;
	import com.graphmind.net.RPCServiceHelper;
	import com.graphmind.net.SiteConnection;
	import com.graphmind.util.Log;
	import com.graphmind.util.OSD;
	
	import flash.events.ContextMenuEvent;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	public class TaxonomyManager {
		
		public static const TAXONOMY_MANAGER_NODE_VOCABULARY_TYPE:String = 'vocabulary';
		// @TODO add color
		public static const TAXONOMY_MANAGER_NODE_VOCABULARY_COLOR:uint = 0xEF95E7;
		public static const TAXONOMY_MANAGER_NODE_TERM_COLOR:uint       = 0xDFC3DC;
		
		/**
		 * Implementation of hook_node_context_menu_alter().
		 */
		public static function hook_node_context_menu(params:Object = null):void {
			(params.data as Array).push({title: 'Load taxonomy', event: TaxonomyManager.loadFullTaxonomyTree, separator: true});
		}
		
		/**
		 * Callback for loading and attaching taxonomy tree.
		 */
		public static function loadFullTaxonomyTree(event:ContextMenuEvent):void {
			var node:NodeItem = NodeItem.getLastSelectedNode();
			var baseSiteConnection:SiteConnection = SiteConnection.getBaseSiteConnection();
			
			RPCServiceHelper.createRPC(
				'taxonomy',
				'getAll',
				'amfphp',
				baseSiteConnection.url,
				function(_event:ResultEvent):void {
					onSuccess_TaxonomyRequestReady(_event, baseSiteConnection, node);
				},
				transactionError
			).send(baseSiteConnection.sessionID);
		}
		
		private static function onSuccess_TaxonomyRequestReady(event:ResultEvent, sc:SiteConnection, baseNode:NodeItem):void {
			for each (var vocabulary:Object in event.result) {
				vocabulary.plugin = 'TaxonomyManager';
				var vocabularyNodeItemData:NodeItemData = new NodeItemData(
					vocabulary,
					NodeItemData.NORMAL, // @TODO make it as a VOCABULARY
					sc
				);
				vocabularyNodeItemData.title = vocabulary.name;
				vocabularyNodeItemData.type = TAXONOMY_MANAGER_NODE_VOCABULARY_TYPE;
				vocabularyNodeItemData.color = TAXONOMY_MANAGER_NODE_VOCABULARY_COLOR;
				var vocabularyNode:NodeItem = new NodeItem(vocabularyNodeItemData);
				baseNode.addChildNode(vocabularyNode);
				
				var term_hierarchy:Object = {};
				var term_storage:Object = {0: vocabularyNode};
				for each (var term:Object in vocabulary.terms) {
					term.plugin = 'TaxonomyManager';
					var termNodeItemData:NodeItemData = new NodeItemData(
						term,
						NodeItemData.TERM,
						sc
					);
					termNodeItemData.title = term.name;
					termNodeItemData.color = TAXONOMY_MANAGER_NODE_TERM_COLOR;
					var termNodeItem:NodeItem = new NodeItem(termNodeItemData);
					var parentID:String = term.parents[0] || 'none';
					if (!term_hierarchy.hasOwnProperty(parentID)) {
						term_hierarchy[parentID] = [];
					}
					(term_hierarchy[parentID] as Array).push(termNodeItem);
					term_storage[term.tid] = termNodeItem;
				}
				
				for (var _parentID:* in term_hierarchy) {
					for each (var termNode:NodeItem in term_hierarchy[_parentID]) {
						(term_storage[_parentID] as NodeItem).addChildNode(termNode);
					}
				}
			}
			OSD.show('Taxonomy tree is loaded.');
		}
		
		/**
		 * Implementation of hook_node_moved.
		 */
		// @FIXME - on move the old footprint stays.
		public static function hook_node_moved(data:Object):void {
			// @TODO revert plan if action cannot be done
			var node:NodeItem = data.node as NodeItem;
			var baseConnection:SiteConnection = SiteConnection.getBaseSiteConnection();
			
			// Node is not a TERM.
			if (!_isTaxonomyPluginNode(node, NodeItemData.TERM)) {
				if (!_isTaxonomyPluginNode(node)) {
					// If it's neither term nor vocabulary
					hook_node_created({node: node});
				}
				return;
			}
			
			var parentNode:NodeItem = node.getParentNode();
			
			// Deleting term
			if (!_isTaxonomyPluginNode(parentNode)) {
				hook_node_delete({node: node});
				_removePluginInfoFromNode(node);
				return;
			}

			var order:Array = [];
			for each (var child:NodeItem in parentNode.getChildNodes()) {
				if (child.getNodeData().hasOwnProperty('tid')) {
					order.push(child.getNodeData().tid);
				}
			}
			
			var childNodes:Array = _changeChildsVocabulary(node, parentNode.getNodeData().vid || 0);
			_changeSiblingsWeight(node);
			
			RPCServiceHelper.createRPC(
				'graphmindTaxonomyManager',
				'moveTerm',
				'amfphp',
				baseConnection.url,
				function(_event:ResultEvent):void{
					OSD.show('Term\'s new position is saved.');
				},
				transactionError
			).send(
				baseConnection.sessionID,
				node.getNodeData().tid,
				parentNode.getNodeData().vid || 0,
				parentNode.getNodeData().tid || 0,
				order.join('|'),
				childNodes.join('|')
			);
		}

		/**
		 * Check if the node created by the TaxonomyManager plugin and has a certain type.
		 */
		private static function _isTaxonomyPluginNode(node:NodeItem, type:String = null):Boolean {
			if (!node.getNodeData().hasOwnProperty('plugin') || node.getNodeData().plugin !== 'TaxonomyManager') {
				return false;
			}
			return type == null ? true : node.nodeItemData.type == type;
		}
		
		/**
		 * Change the subtree's VID to a given value.
		 * If a node moved to another vocabulary, all subterms should be adopted.
		 * 
		 * @param NodeItem node
		 * @param integer vid
		 */
		private static function _changeChildsVocabulary(node:NodeItem, vid:int):Array {
			node.getNodeData().vid = vid;
			
			var nodes:Array = [node.getNodeData().tid || 0];
			for each (var child:NodeItem in node.getChildNodes()) {
				nodes = nodes.concat(_changeChildsVocabulary(child, vid));
			}
			
			return nodes;
		}
		
		/**
		 * Recount weight values of a term's siblings
		 * 
		 * @param NodeItem node
		 */
		private static function _changeSiblingsWeight(node:NodeItem):void {
			var parentNode:NodeItem = node.getParentNode();
			var weight:int = 0;
			for each (var child:NodeItem in parentNode.getChildNodes()) {
				child.getNodeData().weight = weight++;
			}
		}
		
		/**
		 * Implementation of hook_node_delete().
		 * 
		 * @param Object data
		 */
		public static function hook_node_delete(data:Object):void {
			var node:NodeItem = data.node as NodeItem;
			var baseSiteConnection:SiteConnection = SiteConnection.getBaseSiteConnection();
			
			if (!_isTaxonomyPluginNode(node, NodeItemData.TERM)) return;
			
			RPCServiceHelper.createRPC(
				'graphmindTaxonomyManager',
				'deleteTerm',
				'amfphp',
				baseSiteConnection.url,
				onSuccess_TermDeleted,
				transactionError
			).send(baseSiteConnection.sessionID, node.getNodeData().tid || 0);
		}
		
		/**
		 * Callback for delete node service call.
		 */
		private static function onSuccess_TermDeleted(event:ResultEvent):void {
			// Term is deleted with all subterms
			OSD.show('Term is removed.');
		}
		
		/**
		 * De-pluginize a subtree.
		 */
		private static function _removePluginInfoFromNode(node:NodeItem):void {
			node.getNodeData().plugin = undefined;
			node.nodeItemData.type = NodeItemData.NORMAL;
			node.nodeItemData.color = undefined;
			node.redrawNodeBody();
			
			for each (var child:NodeItem in node.getChildNodes()) {
				_removePluginInfoFromNode(child);
			}
		}
		
		/**
		 * Implementation of hook_node_created().
		 * 
		 * @param Object data
		 */
		public static function hook_node_created(data:Object):void {
			var baseSiteConnection:SiteConnection = SiteConnection.getBaseSiteConnection();
			
			var node:NodeItem = data.node as NodeItem;
			if (_isTaxonomyPluginNode(node)) return;
			var parent:NodeItem = node.getParentNode();
			if (!_isTaxonomyPluginNode(parent)) return;
			
			var subtree_node_reference:Array = new Array();
			var subtree:Object = _getSubtreeInfo(node, subtree_node_reference);
			Log.debug('Node reference: ' + subtree_node_reference);
			
			RPCServiceHelper.createRPC(
				'graphmindTaxonomyManager',
				'addSubtree',
				'amfphp',
				baseSiteConnection.url,
				function (_event:ResultEvent):void {
					onSuccess_SubtreeAdded(_event, subtree_node_reference, node);
				},
				transactionError
			).send(baseSiteConnection.sessionID, parent.getNodeData().tid || 0, parent.getNodeData().vid || 0, subtree);
		}
		
		private static function onSuccess_SubtreeAdded(event:ResultEvent, nodeReference:Array, baseNode:NodeItem):void {
			_convertSubtreeToTaxonomy(event.result, nodeReference);
			hook_node_moved({node: baseNode});
			OSD.show('Subtree is added.');
		}
		
		private static function _getSubtreeInfo(node:NodeItem, node_reference:Array):Object {
			var info:Object = new Object();
			info.name  = node.getTitle();
			info.terms = new Array();
			info.nrid  = node_reference.length;
			node_reference.push(node);
			
			for each (var child:NodeItem in node.getChildNodes()) {
				(info.terms as Array).push(_getSubtreeInfo(child, node_reference));
			}
			
			return info;
		}
		
		private static function _convertSubtreeToTaxonomy(subtreeInfo:Object, nodeReference:Array):void {
			if (subtreeInfo.hasOwnProperty('nrid')) {
				var node:NodeItem = nodeReference[subtreeInfo['nrid']] as NodeItem; 
				node.addData('tid', subtreeInfo.tid);
				node.addData('vid', subtreeInfo.vid);
				node.addData('plugin', 'TaxonomyManager');
				node.nodeItemData.type = NodeItemData.TERM;
				node.nodeItemData.color = TAXONOMY_MANAGER_NODE_TERM_COLOR;
				node.redrawNodeBody();
				
				if (subtreeInfo.hasOwnProperty('terms')) {
					for each (var child:Object in subtreeInfo.terms) {
						_convertSubtreeToTaxonomy(child, nodeReference);
					}
				}
			}
		}
		
		public static function hook_node_title_changed(data:Object):void {
			var baseSiteConnection:SiteConnection = SiteConnection.getBaseSiteConnection();
			var node:NodeItem = data.node as NodeItem;
			
			// Only for terms.
			if (!_isTaxonomyPluginNode(node, NodeItemData.TERM)) return;
			
			RPCServiceHelper.createRPC(
				'graphmindTaxonomyManager',
				'renameTerm',
				'amfphp',
				baseSiteConnection.url,
				onSuccess_TermRenamed,
				transactionError
			).send(baseSiteConnection.sessionID, node.getNodeData().tid, node.getTitle());
		}
		
		private static function onSuccess_TermRenamed(event:ResultEvent):void {
			// Term is renamed.
			OSD.show('Term name is set.');
		}
		
		private static function transactionError(event:FaultEvent):void {
			OSD.show(
				"Error occured during the transaction.\n" + 
				"It's very suggested to reload the whole taxonomy tree structure.",
				OSD.ERROR
			);
		}
	}
	
}
