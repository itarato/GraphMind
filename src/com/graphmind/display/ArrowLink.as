package com.graphmind.display {
	
	import mx.core.UIComponent;
	
	public class ArrowLink extends UIComponent {
	
		public var sourceNode:NodeItem;
		public var destinationNode:NodeItem;
		private var _destinationID:String;
		public var isReady:Boolean = false;
		
		public function ArrowLink(node:NodeItem, destinationID:String) {
			this.sourceNode = node;
			this._destinationID = destinationID;
			node.addArrowLink(this);
		}
		
		public function findTargetNode():Boolean {
			for each (var node:NodeItem in NodeItem.nodes) {
				if (node.nodeItemData.id.toString() == _destinationID) {
					destinationNode = node;
					return isReady = true;
				}
			}
			return false;
		}
		
	}
}
