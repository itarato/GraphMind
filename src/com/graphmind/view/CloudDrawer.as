package com.graphmind.view {
  
	import com.graphmind.display.ITreeItem;
	import flash.geom.Point;
	import mx.core.UIComponent;
	
	public class CloudDrawer extends Drawer {
		
		/**
		 * Default display settings.
		 */
		public static const MARGIN:int = 8;
		public static const PADDING:int = 6;
		
		
		/**
		 * Constructor.
		 */
		public function CloudDrawer(target:UIComponent) {
			super(target);
		}
		
		
		/**
		 * Draw a cloud around a node and it's subtree
		 * 
		 * Implementation of the Graham's scan method (for making convex hull)
		 * Source: Algorithms (Thomas H. Cormen, Charles E. Leiserson, Ronald L. Rivest), 2003
		 * 
		 * @param NodeItem node
		 * @param UIComponent target
		 */
		public function draw(node:ITreeItem):void {
			var points:Array = _getSubtreePointsInOrdered(node);
			
			// Search for most-bottom-left point
			var p0:Point = _convexHull_getMostBottomLeftPoint(points);

			// Order points cw
			var orderedPoints:Object = _convexHull_getOrderedPointContainer(points, p0);
			
			var stack:Array = [];
			
			// Get first 3 points
			var j:int = 0;
			for (var i:int = 0; i <= 180 && j < 3; i++) {
				if (!orderedPoints.hasOwnProperty('angle_' + i)) continue;
				stack.push(orderedPoints['angle_' + i]);
				j++;
			}
			
			// Graham's scan method
			for (var k:int = i; k <= 180; k++) {
				if (!orderedPoints.hasOwnProperty('angle_' + k)) continue;
				while (_ifPointOnTheRight(
					stack[stack.length - 2],
					stack[stack.length - 1],
					orderedPoints['angle_' + k]
				)) stack.pop(); 
				stack.push(orderedPoints['angle_' + k]);
			}
			
			// Drawing
			_target.graphics.lineStyle(1, 0x0072B9, .3);
			_target.graphics.beginFill(0x0072B9, .1);
			var v0:Array = [];
			var v1:Array = [];
			var p_cutter_right:Array = [];
			var p_cutter_left:Array  = [];
			var radius:Number = 10;
			_target.graphics.moveTo(
				(stack[stack.length - 1][0] + stack[0][0]) / 2,
				(stack[stack.length - 1][1] + stack[0][1]) / 2
			);
			
			for (var pi:* in stack) {
				if (pi == 0) {
					v0 = [[stack[pi][0], stack[pi][1]], [stack[pi + 1][0], stack[pi + 1][1]]];
					v1 = [[stack[pi][0], stack[pi][1]], [stack[stack.length - 1][0], stack[stack.length - 1][1]]];
					p_cutter_left = [
						(stack[stack.length - 1][0] + stack[pi][0]) / 2,
						(stack[stack.length - 1][1] + stack[pi][1]) / 2
					];
					p_cutter_right = [
						(stack[pi + 1][0] + stack[pi][0]) / 2,
						(stack[pi + 1][1] + stack[pi][1]) / 2
					];
				} else if (pi == stack.length - 1) {
					v0 = [[stack[pi][0], stack[pi][1]], [stack[0][0], stack[0][1]]];
					v1 = [[stack[pi][0], stack[pi][1]], [stack[pi - 1][0], stack[pi - 1][1]]];
					p_cutter_left = [
						(stack[pi - 1][0] + stack[pi][0]) / 2,
						(stack[pi - 1][1] + stack[pi][1]) / 2
					];
					p_cutter_right = [
						(stack[0][0] + stack[pi][0]) / 2,
						(stack[0][1] + stack[pi][1]) / 2
					];
				} else {
					v0 = [[stack[pi][0], stack[pi][1]], [stack[pi + 1][0], stack[pi + 1][1]]];
					v1 = [[stack[pi][0], stack[pi][1]], [stack[pi - 1][0], stack[pi - 1][1]]];
					p_cutter_left = [
						(stack[pi - 1][0] + stack[pi][0]) / 2,
						(stack[pi - 1][1] + stack[pi][1]) / 2
					];
					p_cutter_right = [
						(stack[pi + 1][0] + stack[pi][0]) / 2,
						(stack[pi + 1][1] + stack[pi][1]) / 2
					];
				}
				
				// curve sandbox
				var anchors:Array = _convexHull_angleHalfCut(v0, v1, 10);
				_target.graphics.curveTo(
					anchors[1][0], anchors[1][1],
					stack[pi][0], stack[pi][1]
				);
				_target.graphics.curveTo(
					anchors[0][0], anchors[0][1],
					p_cutter_right[0], p_cutter_right[1]
				);
			}
			_target.graphics.endFill();
		}
		
		
		private function _getSubtreePointsInOrdered(node:ITreeItem):Array {
			var points:Array = [
				[node.getUI().x - PADDING,
				node.getUI().y - PADDING],
				[node.getUI().x + node.getUI().getWidth() + PADDING,
				node.getUI().y - PADDING],
				[node.getUI().x + node.getUI().getWidth() + PADDING,
				node.getUI().y + node.getUI().getHeight() + PADDING],
				[node.getUI().x - PADDING,
				node.getUI().y + node.getUI().getHeight() + PADDING]
			];
			
			if (!node.isCollapsed()) {
				for each (var child:ITreeItem in node.getChildNodeAll()) {
					points = points.concat(_getSubtreePointsInOrdered(child));
				}
			}
			
			return points;
		}
		
		
		private function _getCurrentAngle(relX:Number, relY:Number):int {
			var relDegree:Number = Math.atan(relY / relX) / Math.PI * 180;
			return (360 - (relX < 0 ? 180.0 + relDegree : relDegree)) % 360;
		}
		
		
		private function _isBiggerDistance(p0:Point, p1:Array, p2:Array):Boolean {
			var d1:Number = Math.pow(p0.x - p1[0], 2) + Math.pow(p0.y - p1[1], 2);
			var d2:Number = Math.pow(p0.x - p2[0], 2) + Math.pow(p0.y - p2[1], 2);
			return d2 > d1;
		}
		
		
		private function _ifPointOnTheRight(tm2:Array, tm1:Array, p:Array):Boolean {
			return ((tm1[0] - tm2[0]) * (p[1] - tm2[1]) - (p[0] - tm2[0]) * (tm1[1] - tm2[1])) >= 0;
		}
		
		
		private function _convexHull_getMostBottomLeftPoint(points:Array):Point {
			// Search for most-bottom-left point
			var p0:Point = new Point(int.MAX_VALUE, int.MAX_VALUE);
			var idx:*;
			for (idx in points) {
				if (points[idx][1] < p0.y || (points[idx][1] == p0.y && points[idx][0] < p0.x)) {
					p0.x = points[idx][0];
					p0.y = points[idx][1];
				}
			}
			return p0;
		}
		
		
		private function _convexHull_getOrderedPointContainer(points:Array, p0:Point):Object {
			var orderedPoints:Object = {};
			for (var idx:* in points) {
				var angle:int = _getCurrentAngle(
					p0.x - points[idx][0],
					p0.y - points[idx][1]
				);
				if (!orderedPoints.hasOwnProperty('angle_' + angle) || _isBiggerDistance(p0, orderedPoints['angle_' + angle], points[idx])) {
					orderedPoints['angle_' + angle] = points[idx];
				}
			}
			return orderedPoints;
		}
		
		
		private function _convexHull_angleHalfCut(v1:Array, v2:Array, length:Number):Array {
			// Relatice choords
			var rx1:Number = v1[1][0] - v1[0][0];
			var ry1:Number = v1[1][1] - v1[0][1];
			var rx2:Number = v2[1][0] - v2[0][0];
			var ry2:Number = v2[1][1] - v2[0][1];
			
			// Vector lengths
			var l1:Number = Math.sqrt(Math.pow(rx1, 2) + Math.pow(ry1, 2));
			var l2:Number = Math.sqrt(Math.pow(rx2, 2) + Math.pow(ry2, 2));
			var scale:Number = l1 / l2;
			
			rx2 *= scale;
			ry2 *= scale;
			
			// Half cutter vector
			var hcx:Number = (rx1 + rx2) / 2;
			var hcy:Number = (ry1 + ry2) / 2;
			var hcl:Number = Math.sqrt(Math.pow(hcx, 2) + Math.pow(hcy, 2));
			
			var hc_scale:Number = length / hcl;
			var normal_hc_left:Array = [-hc_scale * hcy + v1[0][0], hc_scale * hcx + v1[0][1]];
			var normal_hc_right:Array = [hc_scale * hcy + v1[0][0], -hc_scale * hcx + v1[0][1]];
			
			return [normal_hc_left, normal_hc_right];
		}
		
	}
	
}