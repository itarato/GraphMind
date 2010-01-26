package com.graphmind.visualizer {
	import com.graphmind.StageManager;
	import com.graphmind.display.ITreeNode;
	import com.graphmind.display.NodeItem;
	
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	
	
	public class TreeDrawer extends Drawer {
		
		public static const MARGIN_BOTTOM:int = 4;
		public static const MARGIN_RIGHT:int = 34;
		
		private var _cloudDrawer:CloudDrawer;
		private var _connectionDrawer:ConnectionDrawer;
		
		// Mindmap stage redraw timer - performance reason
		private var _timer:uint;
		
		public function TreeDrawer(target:UIComponent, cloudContainer:UIComponent, connectionContainer:Canvas) {
			super(target);
			_cloudDrawer = new CloudDrawer(cloudContainer);
			_connectionDrawer = new ConnectionDrawer(connectionContainer);
		}
		
		public override function redraw():void {
			clearTimeout(_timer);
			_timer = setTimeout(function():void {
				_connectionDrawer.clearAll();
				_cloudDrawer.clearAll();
				
//				// Refresh the whole tree.
				StageManager.getInstance().baseNode.x = 4;
				StageManager.getInstance().baseNode.y = _target.height >> 1;
				_redrawNode(StageManager.getInstance().baseNode);
//				redrawPreviewWindow();
			}, 10);
		}
		
		protected function _redrawNode(node:ITreeNode):void {
			var totalChildWidth:int = _getSubtreeHeight(node);
			var currentY:int = (node as NodeItem).y - totalChildWidth / 2;
//			
			if ((node as NodeItem).isHasCloud()) currentY += CloudDrawer.MARGIN;
//			
			for each (var child:NodeItem in node.getChildNodeAll()) {
				var subtreeWidth:int = _getSubtreeHeight(child);
				child.x = (node as NodeItem).x + (node as NodeItem).getWidth() + MARGIN_RIGHT;
				child.y = currentY + subtreeWidth / 2;
				_redrawNode(child);
//				
				if (!(node as NodeItem).isCollapsed()) {
					_connectionDrawer.draw((node as NodeItem), child);
				}
				currentY += subtreeWidth;
			}
//			
//			// Ugly hack for redrawing clouds.
//			// @Todo make better
			if ((node as NodeItem).isHasCloud()) {
//				toggleCloud();
//				toggleCloud();
				_cloudDrawer.draw(node as NodeItem);
			}
//			
//			_cloudComp.visible = !_parentNode || !_parentNode._isCollapsed;
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