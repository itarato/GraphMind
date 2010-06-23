package com.graphmind.display {
	
	import mx.core.UIComponent;
	
	public class TreeArrowLink extends UIComponent {
	
		public var sourceNode:TreeNodeController;
		public var destinationNode:TreeNodeController;
		private var _destinationID:String;
		public var isReady:Boolean = false;
		
		public function TreeArrowLink(node:TreeNodeController, destinationID:String) {
			this.sourceNode = node;
			this._destinationID = destinationID;
			node.addArrowLink(this);
		}
		
		public function findTargetNode():Boolean {
			for each (var node:TreeNodeController in NodeController.nodes) {
				if (node.getNodeItemData().id.toString() == _destinationID) {
					destinationNode = node;
					return isReady = true;
				}
			}
			return false;
		}
		
	}
}
