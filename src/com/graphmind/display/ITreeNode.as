package com.graphmind.display {
	
	import mx.collections.ArrayCollection;
	
	/**
	 * Tree.
	 */
	public interface ITreeNode {
		
		function getChildNodeAll():ArrayCollection;
		
		function getParentNode():ITreeNode;
		
		function isCollapsed():Boolean;
		
		function hasChild():Boolean;
		
	}
	
}
