package com.graphmind.visualizer {
	
	import com.graphmind.StageManager;
	import com.graphmind.display.ArrowLink;
	import com.graphmind.display.ITreeNode;
	import com.graphmind.display.NodeItem;
	import com.graphmind.event.StageEvent;
	
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	
	
	public class TreeDrawer extends StructureDrawer {
		
		public static const MARGIN_BOTTOM:int = 4;
		public static const MARGIN_RIGHT:int = 34;
		
		private var _cloudDrawer:CloudDrawer;
		private var _connectionDrawer:ConnectionDrawer;
		private var _arrowLinkContainer:ArrowLinkDrawer;
		
		// Mindmap stage redraw timer - performance reason
		private var _timer:uint;
		
		public function TreeDrawer(
			target:UIComponent, 
			cloudContainer:UIComponent, 
			connectionContainer:UIComponent,
			arrowLinkContainer:UIComponent
			) 
		{
			super(target, new SimpleNodeDrawer(GraphMind.instance.mindmapCanvas.desktop));
			_cloudDrawer        = new CloudDrawer(cloudContainer);
			_connectionDrawer   = new ConnectionDrawer(connectionContainer);
			_arrowLinkContainer = new ArrowLinkDrawer(arrowLinkContainer);
		}
		
		public override function redraw():void {
			if (_isLocked) return;
			
			clearTimeout(_timer);
			_timer = setTimeout(function():void {
				_connectionDrawer.clearAll();
				_cloudDrawer.clearAll();
				_arrowLinkContainer.clearAll();
				
				// Refresh the whole tree.
				StageManager.getInstance().baseNode.x = 4;
				StageManager.getInstance().baseNode.y = _target.height >> 1;
				var postProcessObjects:Object = new Object();
				postProcessObjects.arrowLinks = new Array();
				_redrawNode(StageManager.getInstance().baseNode, postProcessObjects);
				_redrawArrowLinks(postProcessObjects.arrowLinks);
				dispatchEvent(new StageEvent(StageEvent.MINDMAP_UPDATED));
			}, 10);
		}
		
		protected function _redrawNode(node:ITreeNode, postProcessObjects:Object):void {
			var totalChildWidth:int = _getSubtreeHeight(node);
			var currentY:int = (node as NodeItem).y - totalChildWidth / 2;
			
			if ((node as NodeItem).isHasCloud()) currentY += CloudDrawer.MARGIN;
			
			// Walking through all the children.
			for each (var child:NodeItem in node.getChildNodeAll()) {
				var subtreeWidth:int = _getSubtreeHeight(child);
				child.x = (node as NodeItem).x + (node as NodeItem).getWidth() + MARGIN_RIGHT;
				child.y = currentY + subtreeWidth / 2;
				_redrawNode(child, postProcessObjects);
				
				if (!(node as NodeItem).isCollapsed()) {
					_connectionDrawer.draw((node as NodeItem), child);
				}
				currentY += subtreeWidth;
			}
			
			// Cloud.
			if ((node as NodeItem).isHasCloud() && (!node.getParentNode() || !(node.getParentNode() as NodeItem).isCollapsed())) {
				_cloudDrawer.draw(node as NodeItem);
			}
			
			// ArrowLinks
			//postProcessObjects.arrowLinks = (postProcessObjects.arrowLinks as Array).concat((node as NodeItem).getArrawLinks());
			(postProcessObjects.arrowLinks as Array).push((node as NodeItem).getArrowLinks());
		}
		
		/**
		 * Draw arrow links.
		 */
		private function _redrawArrowLinks(arrowLinkNodes:Array):void {
			for each (var arrowLinks:ArrayCollection in arrowLinkNodes) {
				for each (var arrowLink:ArrowLink in arrowLinks) {
//					trace('Arrow link found');
					_arrowLinkContainer.draw(arrowLink);
				}
			}
		}
		
		private function _getSubtreeHeight(node:ITreeNode):int {
			var height:int = 0;
			if (node.getChildNodeAll().length == 0 || (node as NodeItem).isCollapsed()) {
				height = (node as NodeItem).getHeight() + MARGIN_BOTTOM;
			} else {
				for each (var child:NodeItem in node.getChildNodeAll()) {
					height += _getSubtreeHeight(child);
				}
			}
			
			if ((node as NodeItem).isHasCloud()) height += 2 * CloudDrawer.MARGIN;
			
			return height;
			return 0;
		}
	}
	
}