package com.graphmind.view {
	
	import com.graphmind.StageManager;
	import com.graphmind.display.ICloud;
	import com.graphmind.display.ITreeItem;
	import com.graphmind.display.NodeController;
	import com.graphmind.display.TreeArrowLink;
	import com.graphmind.util.Log;
	
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	
	
	public class TreeDrawer extends StructureDrawer {
		
		public static const MARGIN_BOTTOM:int = 4;
		public static const MARGIN_RIGHT:int = 34;
		
		protected var _cloudDrawer:CloudDrawer;
		protected var _connectionDrawer:TreeConnectionDrawer;
		protected var _arrowLinkContainer:TreeArrowLinkUI;
		
		// Mindmap stage redraw timer - performance reason
		protected var _timer:uint;
//		private var _isRootNodeSet:Boolean = false;
		
		public function TreeDrawer (
			target:UIComponent, 
			cloudContainer:UIComponent, 
			connectionContainer:UIComponent,
			arrowLinkContainer:UIComponent
		) {
			super(target);
			_cloudDrawer        = new CloudDrawer(cloudContainer);
			_connectionDrawer   = new TreeConnectionDrawer(connectionContainer);
			_arrowLinkContainer = GraphMind.i.workflowComposite.createArrowLinkDrawer(arrowLinkContainer);
			
			initGraphics();
		}
		
		public override function initGraphics():void {
		
		}
		
		public override function refreshGraphics():void {
			if (_isLocked) return;
			
			clearTimeout(_timer);
			Log.debug('TreeDrawer.rerfreshGraphics()');
			_timer = setTimeout(function():void {
				
				_connectionDrawer.clearAll();
				_cloudDrawer.clearAll();
				_arrowLinkContainer.clearAll();
				
				// Refresh the whole tree.
				GraphMind.i.stageManager.rootNode.getUI().x = 4;
				GraphMind.i.stageManager.rootNode.getUI().y = _target.height >> 1;
				var postProcessObjects:Object = new Object();
				postProcessObjects.arrowLinks = new Array();
				var totalHeight:Number = _redrawNode(GraphMind.i.stageManager.rootNode, postProcessObjects);
				
				if (totalHeight > (StageManager.DEFAULT_DESKTOP_HEIGHT + (NodeUI.HEIGHT << 2))) {
					StageManager.DEFAULT_DESKTOP_HEIGHT = totalHeight + 200;
				}
				
				_redrawArrowLinks(postProcessObjects.arrowLinks);
			}, 10);
		}
		
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
			//postProcessObjects.arrowLinks = (postProcessObjects.arrowLinks as Array).concat((node as NodeItem).getArrawLinks());
			(postProcessObjects.arrowLinks as Array).push((node as NodeController).getArrowLinks());
			
			return totalChildHeight;
		}
		
		/**
		 * Draw arrow links.
		 */
		protected function _redrawArrowLinks(arrowLinkNodes:Array):void {
			for each (var arrowLinks:ArrayCollection in arrowLinkNodes) {
				for each (var arrowLink:TreeArrowLink in arrowLinks) {
//					trace('Arrow link found');
					_arrowLinkContainer.draw(arrowLink);
				}
			}
		}
		
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
//		
//		public function setRootNode(node:TreeNodeController):void {
//			Log.debug('TreeDrawer.setRootNode()');
//			_root = node;
//			_isRootNodeSet = true;
//		}
	}
	
}