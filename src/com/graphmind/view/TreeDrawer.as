package com.graphmind.view {
	
	import com.graphmind.MapViewController;
	import com.graphmind.display.ICloud;
	import com.graphmind.display.ITreeItem;
	import com.graphmind.display.NodeViewController;
	import com.graphmind.display.TreeArrowLink;
	import com.graphmind.util.Log;
	
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	
	public class TreeDrawer {
		
		/**
		 * Default display settings.
		 */
		public static const MARGIN_BOTTOM:int = 4;
		public static const MARGIN_RIGHT:int = 34;

    /**
    * Layers.
    */
    protected var _nodeLayer:Canvas;
    protected var _connectionLayer:Canvas;
    protected var _cloudLayer:Canvas;
    		
    /**
    * Drawers.
    */
    protected var _connectionDrawer:TreeConnectionDrawer;	
    protected var _cloudDrawer:CloudDrawer;
    protected var _arrowLinkDrawer:TreeArrowLinkDrawer;
    	
		/**
		 * Mindmap stage redraw timer - performance reason
		 */
		protected var _timer:uint;
		
		
		/**
		 * Constructor.
		 */
		public function TreeDrawer(nodeLayer:Canvas, connectionLayer:Canvas, cloudLayer:Canvas) {
			super();
			
			this._nodeLayer       = nodeLayer;
			this._connectionLayer = connectionLayer;
			this._cloudLayer      = cloudLayer;
			
			_connectionDrawer = new TreeConnectionDrawer(this._connectionLayer);
			_cloudDrawer      = new CloudDrawer(this._cloudLayer);
			_arrowLinkDrawer  = new TreeArrowLinkDrawer(this._connectionLayer);
		}
		

    /**
    * Refresh ui.
    */
		public function refreshGraphics(rootNode:NodeViewController):void {
			clearTimeout(_timer);
			_timer = setTimeout(function():void {
         Log.info('Map drawed.');
         
				_connectionLayer.graphics.clear();
				_cloudLayer.graphics.clear();
				
				// Refresh the whole tree.
				rootNode.view.x = 4;
				rootNode.view.y = _nodeLayer.height >> 1;
				var postProcessObjects:Object = new Object();
				postProcessObjects.arrowLinks = new Array();
				var totalHeight:Number = _redrawNode(rootNode, postProcessObjects);
				
				if (totalHeight > (MapViewController.MAP_DEFAULT_HEIGHT + (NodeView.HEIGHT << 2))) {
					MapViewController.MAP_DEFAULT_HEIGHT = totalHeight + 200;
				}
				
				_redrawArrowLinks(postProcessObjects.arrowLinks);
			}, 10);
		}
		
		
		/**
		 * Refresh a single node's ui.
		 */
		protected function _redrawNode(node:ITreeItem, postProcessObjects:Object):Number {
		  node.getUI().refreshGraphics();
		  
			var totalChildHeight:int = _getSubtreeHeight(node);
			var currentY:int = node.getUI().y - totalChildHeight / 2;
			
			if (node is ICloud && (node as ICloud).hasCloud()) currentY += CloudDrawer.MARGIN;
			
			// Walking through all the children.
			for each (var child:ITreeItem in node.getChildNodeAll()) {
				var subtreeWidth:int = _getSubtreeHeight(child);
				child.getUI().x = node.getUI().x + node.getUI().getWidth() + MARGIN_RIGHT;
				child.getUI().y = currentY + subtreeWidth / 2;
				_redrawNode(child, postProcessObjects);
				
				if (!node.isCollapsed()) {
					_connectionDrawer.draw(node, child);
				}
				currentY += subtreeWidth;
			}
			
			// Cloud.
			if (node is ICloud && (node as ICloud).hasCloud() && (!node.getParentNode() || !node.getParentNode().isCollapsed())) {
				_cloudDrawer.draw(node);
			}
			
			// ArrowLinks
			(postProcessObjects.arrowLinks as Array).push((node as NodeViewController).getArrowLinks());
			
			return totalChildHeight;
		}
		
		
		/**
		 * Draw arrow links.
		 */
		protected function _redrawArrowLinks(arrowLinkNodes:Array):void {
			for each (var arrowLinks:ArrayCollection in arrowLinkNodes) {
				for each (var arrowLink:TreeArrowLink in arrowLinks) {
					_arrowLinkDrawer.draw(arrowLink);
				}
			}
		}
		
		
		/**
		 * Get height of a subtree.
		 */
		protected function _getSubtreeHeight(node:ITreeItem):int {
			var height:int = 0;
			if (node.getChildNodeAll().length == 0 || node.isCollapsed()) {
				height = node.getUI().getHeight() + MARGIN_BOTTOM;
			} else {
				for each (var child:ITreeItem in node.getChildNodeAll()) {
					height += _getSubtreeHeight(child);
				}
			}
			
			if (node is ICloud) {
				if ((node as ICloud).hasCloud()) height += 2 * CloudDrawer.MARGIN;
			}

			return height;
		}

	}
	
}
