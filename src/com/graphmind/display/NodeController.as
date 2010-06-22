package com.graphmind.display
{
	import com.graphmind.TreeManager;
	import com.graphmind.data.NodeData;
	import com.graphmind.view.NodeUI;
	
	import flash.events.EventDispatcher;
	import flash.ui.ContextMenu;
	
	import mx.collections.ArrayCollection;
	
	public class NodeController extends EventDispatcher implements IHasUI {
		
		// Node access caches
		public static var nodes:ArrayCollection = new ArrayCollection();

		// Model
		protected var _nodeItemData:NodeData;
		
		// View
		protected var _nodeUI:NodeUI;

		/**
		 * Constructor
		 */
		public function NodeController(viewItem:NodeData) {
			// Init super class
			super(this);
			
			_nodeUI = new NodeUI(this);
			
			NodeController.nodes.addItem(this);
		}
		
		public function getContextMenu():ContextMenu {
			return null;
		}
		
		public override function toString():String {
			return '[Node: ' + this._nodeItemData.id + ']';
		}
		
		public function getUI():IDrawable {
			return _nodeUI;
		}
		
		public function get nodeItemData():NodeData {
			return _nodeItemData;
		}
		
		public static function getLastSelectedNode():NodeController {
			return TreeManager.getInstance().activeNode;
		}
		
		public function isSelected():Boolean {
			return TreeManager.getInstance().activeNode == this;
		}
		
		/**
		 * Upadte node's time.
		 * Reasons:
		 *  - modified title
		 *  - changed attributes
		 *  - toggled cloud
		 */
		public function updateTime():void {
			_nodeItemData.modified = (new Date()).time;
		}
		
		public function addData(attribute:String, value:String):void {
			_nodeItemData.dataAdd(attribute, value);
			TreeManager.getInstance().setMindmapUpdated();
			updateTime();
		}
		
		public function deleteData(param:String):void {
			_nodeItemData.dataDelete(param);
			TreeManager.getInstance().setMindmapUpdated();
			updateTime();
		}
		
		/**
		 * Kill a node and each childs.
		 */
		public function kill(killedDirectly:Boolean = true):void {
		}
		
		public function getNodeData():Object {
			return _nodeItemData.data;
		}	
			
		/**
		 * Select a single node on the mindmap stage.
		 * Only one node can be active at a time.
		 * Accessing to this node: StageManager.getInstance().activeNode():NodeItem.
		 */
		public function selectNode():void {
		}
		
		public function unselectNode():void {
		}
		
	}
}