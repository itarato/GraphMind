package com.graphmind.display {
	
	import mx.core.UIComponent;
	
	public class TreeArrowLink extends UIComponent {
	
		public var sourceNode:NodeController;
		public var destinationNode:NodeController;
		private var _destinationID:String;
		public var isReady:Boolean = false;
		
		public function TreeArrowLink(node:NodeController, destinationID:String) {
			this.sourceNode = node;
			this._destinationID = destinationID;
			node.addArrowLink(this);
		}
		
		public function findTargetNode():Boolean {
			for each (var node:NodeController in NodeController.nodes) {
				if (node.nodeData.id.toString() == _destinationID) {
					destinationNode = node;
					return isReady = true;
				}
			}
			return false;
		}
		
	}
	
}
