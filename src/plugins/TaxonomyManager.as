package plugins {
	
	import com.graphmind.data.NodeData;
	import com.graphmind.data.NodeType;
	import com.graphmind.display.NodeController;
	import com.graphmind.event.StageEvent;
	import com.graphmind.factory.NodeFactory;
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
		
		public static function hook_pre_init(data:Object):void {
			GraphMind.i.stageManager.addEventListener(StageEvent.MINDMAP_CREATION_COMPLETE, onMindmapCreationComplete);
		}
		
		private static function onMindmapCreationComplete(event:StageEvent):void {
			// Refreshing taxonomy
			var cursor:int = 0;
			var parent:NodeController = null;
			while (NodeController.nodes.length > cursor) {
				var node:NodeController = NodeController.nodes[cursor] as NodeController;
				if (_isTaxonomyPluginNode(node, TAXONOMY_MANAGER_NODE_VOCABULARY_TYPE)) {
					parent = node.getParentNode() as NodeController;
					node.kill();
					cursor = 0;
				} else {
					cursor++;
				}
			}
			
			if (parent !== null) {
				parent.selectNode();
				loadFullTaxonomyTree(null);
			}
		} 
		
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
			var node:NodeController = GraphMind.i.stageManager.activeNode;
			var baseSiteConnection:SiteConnection = SiteConnection.getBaseSiteConnection();
			
			RPCServiceHelper.createRPC(
				'graphmindTaxonomyManager',
				'getAll',
				'amfphp',
				baseSiteConnection.url,
				function(_event:ResultEvent):void {
					onSuccess_TaxonomyRequestReady(_event, baseSiteConnection, node);
				},
				transactionError
			).send(baseSiteConnection.sessionID);
		}
		
		private static function onSuccess_TaxonomyRequestReady(event:ResultEvent, sc:SiteConnection, baseNode:NodeController):void {
			for each (var vocabulary:Object in event.result) {
				vocabulary.plugin = 'TaxonomyManager';
				var vocabularyNodeItemData:NodeData = new NodeData(
					vocabulary,
					NodeType.NORMAL, // @TODO make it as a VOCABULARY
					sc
				);
				vocabularyNodeItemData.title = vocabulary.name;
				vocabularyNodeItemData.type = TAXONOMY_MANAGER_NODE_VOCABULARY_TYPE;
				vocabularyNodeItemData.color = TAXONOMY_MANAGER_NODE_VOCABULARY_COLOR;
				var vocabularyNode:NodeController = NodeFactory.createNodeWithNodeData(vocabularyNodeItemData);
				baseNode.addChildNode(vocabularyNode);
				
				var term_hierarchy:Object = {};
				var term_storage:Object = {0: vocabularyNode};
				
				for each (var term:Object in vocabulary.terms) {
					term.plugin = 'TaxonomyManager';
					var termNodeItemData:NodeData = new NodeData(
						term,
						NodeType.TERM,
						sc
					);
					termNodeItemData.title = term.name;
					termNodeItemData.color = TAXONOMY_MANAGER_NODE_TERM_COLOR;
					var termNodeItem:NodeController = NodeFactory.createNodeWithNodeData(termNodeItemData);
					var parentID:String = term.parents[0] || 'none';
					if (!term_hierarchy.hasOwnProperty(parentID)) {
						term_hierarchy[parentID] = [];
					}
					(term_hierarchy[parentID] as Array).push(termNodeItem);
					term_storage[term.tid] = termNodeItem;
				}
				
				for (var _parentID:* in term_hierarchy) {
					for each (var termNode:NodeController in term_hierarchy[_parentID]) {
						(term_storage[_parentID] as NodeController).addChildNode(termNode);
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
			var node:NodeController = data.node as NodeController;
			var baseConnection:SiteConnection = SiteConnection.getBaseSiteConnection();
			
			// Node is not a TERM.
			if (!_isTaxonomyPluginNode(node, NodeType.TERM)) {
				if (!_isTaxonomyPluginNode(node)) {
					// If it's neither term nor vocabulary
					hook_node_created({node: node});
				}
				return;
			}
			
 			var parentNode:NodeController = node.getParentNode() as NodeController;
			
			// Deleting term
			if (!_isTaxonomyPluginNode(parentNode)) {
				hook_node_delete({node: node});
				_removePluginInfoFromNode(node);
				return;
			}

			var order:Array = [];
			for each (var child:NodeController in parentNode.getChildNodeAll()) {
				if (child.nodeData.data.hasOwnProperty('tid')) {
					order.push(child.nodeData.data.tid);
				}
			}
			
			var childNodes:Array = _changeChildsVocabulary(node, parentNode.nodeData.data.vid || 0);
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
				node.nodeData.data.tid,
				parentNode.nodeData.data.vid || 0,
				parentNode.nodeData.data.tid || 0,
				order.join('|'),
				childNodes.join('|')
			);
		}

		/**
		 * Check if the node created by the TaxonomyManager plugin and has a certain type.
		 */
		private static function _isTaxonomyPluginNode(node:NodeController, type:String = null):Boolean {
			if (!node.nodeData.data.hasOwnProperty('plugin') || node.nodeData.data.plugin !== 'TaxonomyManager') {
				return false;
			}
			return type == null ? true : node.nodeData.type == type;
		}
		
		/**
		 * Change the subtree's VID to a given value.
		 * If a node moved to another vocabulary, all subterms should be adopted.
		 * 
		 * @param NodeItem node
		 * @param integer vid
		 */
		private static function _changeChildsVocabulary(node:NodeController, vid:int):Array {
			node.nodeData.data.vid = vid;
			
			var nodes:Array = [node.nodeData.data.tid || 0];
			for each (var child:NodeController in node.getChildNodeAll()) {
				nodes = nodes.concat(_changeChildsVocabulary(child, vid));
			}
			
			return nodes;
		}
		
		/**
		 * Recount weight values of a term's siblings
		 * 
		 * @param NodeItem node
		 */
		private static function _changeSiblingsWeight(node:NodeController):void {
			var parentNode:NodeController = node.getParentNode() as NodeController;
			var weight:int = 0;
			for each (var child:NodeController in parentNode.getChildNodeAll()) {
				child.nodeData.data.weight = weight++;
			}
		}
		
		/**
		 * Implementation of hook_node_delete().
		 * 
		 * @param Object data
		 */
		public static function hook_node_delete(data:Object):void {
			if (!data.directKill) {
				return;
			}
			
			var node:NodeController = data.node as NodeController;
			var baseSiteConnection:SiteConnection = SiteConnection.getBaseSiteConnection();
			
			if (!_isTaxonomyPluginNode(node, NodeType.TERM)) return;
			
			RPCServiceHelper.createRPC(
				'graphmindTaxonomyManager',
				'deleteTerm',
				'amfphp',
				baseSiteConnection.url,
				onSuccess_TermDeleted,
				transactionError
			).send(baseSiteConnection.sessionID, node.nodeData.data.tid || 0);
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
		private static function _removePluginInfoFromNode(node:NodeController):void {
			node.nodeData.data.plugin = undefined;
			node.nodeData.type = NodeType.NORMAL;
			node.nodeData.color = undefined;
			node.getUI().refreshGraphics();
			
			for each (var child:NodeController in node.getChildNodeAll()) {
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
			
			var node:NodeController = data.node as NodeController;
			if (_isTaxonomyPluginNode(node)) {
				// Recolor taxonomy
				if (_isTaxonomyPluginNode(node, TAXONOMY_MANAGER_NODE_VOCABULARY_TYPE)) {
					node.nodeData.color = TAXONOMY_MANAGER_NODE_VOCABULARY_COLOR;
				} else {
					node.nodeData.color = TAXONOMY_MANAGER_NODE_TERM_COLOR;
				}
				return;
			}
			var parent:NodeController = node.getParentNode() as NodeController;
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
			).send(baseSiteConnection.sessionID, parent.nodeData.data.tid || 0, parent.nodeData.data.vid || 0, subtree);
		}
		
		private static function onSuccess_SubtreeAdded(event:ResultEvent, nodeReference:Array, baseNode:NodeController):void {
			_convertSubtreeToTaxonomy(event.result, nodeReference);
			hook_node_moved({node: baseNode});
			OSD.show('Subtree is added.');
		}
		
		private static function _getSubtreeInfo(node:NodeController, node_reference:Array):Object {
			var info:Object = new Object();
			info.name  = node.nodeData._title;
			info.terms = new Array();
			info.nrid  = node_reference.length;
			node_reference.push(node);
			
			for each (var child:NodeController in node.getChildNodeAll()) {
				(info.terms as Array).push(_getSubtreeInfo(child, node_reference));
			}
			
			return info;
		}
		
		private static function _convertSubtreeToTaxonomy(subtreeInfo:Object, nodeReference:Array):void {
			if (subtreeInfo.hasOwnProperty('nrid')) {
				var node:NodeController = nodeReference[subtreeInfo['nrid']] as NodeController; 
				node.addData('tid', subtreeInfo.tid);
				node.addData('vid', subtreeInfo.vid);
				node.addData('plugin', 'TaxonomyManager');
				node.nodeData.type = NodeType.TERM;
				node.nodeData.color = TAXONOMY_MANAGER_NODE_TERM_COLOR;
				node.nodeView.refreshGraphics();
				
				if (subtreeInfo.hasOwnProperty('terms')) {
					for each (var child:Object in subtreeInfo.terms) {
						_convertSubtreeToTaxonomy(child, nodeReference);
					}
				}
			}
		}
		
		public static function hook_node_title_changed(data:Object):void {
			var baseSiteConnection:SiteConnection = SiteConnection.getBaseSiteConnection();
			var node:NodeController = data.node as NodeController;
			
			// Only for terms.
			if (!_isTaxonomyPluginNode(node, NodeType.TERM)) return;
			
			RPCServiceHelper.createRPC(
				'graphmindTaxonomyManager',
				'renameTerm',
				'amfphp',
				baseSiteConnection.url,
				onSuccess_TermRenamed,
				transactionError
			).send(baseSiteConnection.sessionID, node.nodeData.data.tid, node.nodeData._title);
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
