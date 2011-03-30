package com.graphmind.display {
	
	import mx.collections.ArrayCollection;
	
	/**
	 * Tree.
	 */
	public interface ITreeNode {
		
		function getChildNodeAll():ArrayCollection;
		
		function getChildNodeAt(index:int):ITreeNode;
		
		function getParentNode():ITreeNode;
		
		function getChildNodeIndex(child:ITreeNode):int;
		
		function isCollapsed():Boolean;
		
		function hasChild():Boolean;
		
	}
	
}
