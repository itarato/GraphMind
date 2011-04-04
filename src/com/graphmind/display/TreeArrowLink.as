package com.graphmind.display {
	
	import com.graphmind.NodeViewController;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	
	public class TreeArrowLink extends Canvas {
	
	  public static var arrowLinks:ArrayCollection = new ArrayCollection();
	
		public var sourceNode:NodeViewController;
		public var destinationNode:NodeViewController;
		private var _destinationID:String;
		public var isReady:Boolean = false;
		
		public function TreeArrowLink(node:NodeViewController, destinationID:String) {
			this.sourceNode = node;
			this._destinationID = destinationID;
			node.addArrowLink(this);
			arrowLinks.addItem(this);
		}
		
		public function findTargetNode():Boolean {
			for each (var node:NodeViewController in NodeViewController.nodes) {
				if (node.nodeData.id.toString() == _destinationID) {
					destinationNode = node;
					return isReady = true;
				}
			}
			return false;
		}
		
	}
	
}
