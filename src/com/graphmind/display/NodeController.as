package com.graphmind.display {
  
//	import com.graphmind.TreeManager;
	import com.graphmind.data.NodeData;
	import com.graphmind.view.NodeUI;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	public class NodeController extends EventDispatcher implements IHasUI {
		
		// Node access caches
		public static var nodes:ArrayCollection = new ArrayCollection();
		
		// View
		protected var _nodeUI:NodeUI;

		/**
		 * Constructor
		 */
		public function NodeController(nodeData:NodeData) {
			// Init super class
			super(this);
			
			// View and Model
      _nodeItemData = nodeData;
			_nodeUI       = new NodeUI(this);
			
			// Add this to the collection
			NodeController.nodes.addItem(this);
		}
		
		/**
		 * Get String representation.
		 */
		public override function toString():String {
			return '[NodeController: ' + this._nodeItemData.id + ']';
		}
		
		/**
		 * Implementation of getUI().
		 */
		public function getUI():IDrawable {
			return _nodeUI;
		}
		
		/**
		 * Public accessor of the Model.
		 */
		public function getNodeItemData():NodeData {
			return _nodeItemData;
		}
		
		/**
		 * Check if the node is selected.
		 * @return Boolean
		 */
		public function isSelected():Boolean {
      return GraphMind.instance.stageManager.activeNode == this;
		}
		
		/**
		 * Upadte node's time.
		 * Reasons:
		 *  - modified title
		 *  - changed attributes
		 *  - toggled cloud
		 */
		public function updateTime():void {
			getNodeItemData().modified = (new Date()).time;
		}
		
		public function addData(attribute:String, value:String):void {
			_nodeItemData.dataAdd(attribute, value);
			GraphMind.instance.stageManager.setMindmapUpdated();
			updateTime();
		}
		
		public function deleteData(param:String):void {
			_nodeItemData.dataDelete(param);
			GraphMind.instance.stageManager.setMindmapUpdated();
			updateTime();
		}
		
		/**
		 * Kill a node and each childs.
		 */
		public function kill(killedDirectly:Boolean = true):void {
		  getUI().getUIComponent().parent.removeChild(getUI().getUIComponent());
		  delete this.getUI();
		  delete this.getNodeItemData();
		  delete this;
		}
			
		/**
		 * Select a single node on the mindmap stage.
		 * Only one node can be active at a time.
		 * Accessing to this node: StageManager.getInstance().activeNode():NodeItem.
		 */
		public function selectNode():void {
		}
		
		/**
		 * Deselect node.
		 */
		public function deselectNode():void {
		}
		
	}
	
}