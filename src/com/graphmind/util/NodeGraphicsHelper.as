package com.graphmind.util {
	import com.graphmind.display.NodeItem;
	
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	
	public class NodeGraphicsHelper {
		
		public static function drawConnection(target:UIComponent, fromNode:NodeItem,  toNode:NodeItem):void {
			target.graphics.lineStyle(2, 0x777777);
			var pFrom:Point = new Point(fromNode.x + fromNode.getWidth(), fromNode.y + (NodeItem.HEIGHT >> 1));
			var pTo:Point   = new Point(toNode.x, toNode.y + (NodeItem.HEIGHT >> 1));
			target.graphics.moveTo((pFrom.x + pTo.x) >> 1, (pFrom.y + pTo.y) >> 1);
			target.graphics.curveTo(
				pFrom.x + ((pTo.x - pFrom.x) >> 2),
				pFrom.y,
				pFrom.x,
				pFrom.y
			);
			target.graphics.moveTo((pFrom.x + pTo.x) >> 1, (pFrom.y + pTo.y) >> 1);
			target.graphics.curveTo(
				pTo.x - ((pTo.x - pFrom.x) >> 2),
				pTo.y,
				pTo.x,
				pTo.y
			);
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
		public static function drawCloud(node:NodeItem, target:UIComponent):void {
			var points:Array = getSubtreePointsInOrdered(node);
			
			// Search for most-bottom-left point
			var p0:Point = convexHull_getMostBottomLeftPoint(points);

			// Order points cw
			var orderedPoints:Object = convexHull_getOrderedPointContainer(points, p0);
			
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
				while (ifPointOnTheRight(
					stack[stack.length - 2],
					stack[stack.length - 1],
					orderedPoints['angle_' + k]
				)) stack.pop(); 
				stack.push(orderedPoints['angle_' + k]);
			}
			
			// Drawing
			target.graphics.lineStyle(1, 0x0072B9, .3);
			target.graphics.beginFill(0x0072B9, .1);
			var v0:Array = [];
			var v1:Array = [];
			var p_cutter_right:Array = [];
			var p_cutter_left:Array  = [];
			var radius:Number = 10;
			target.graphics.moveTo(
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
				var anchors:Array = convexHull_angleHalfCut(v0, v1, 10);
				target.graphics.curveTo(
					anchors[1][0], anchors[1][1],
					stack[pi][0], stack[pi][1]
				);
				target.graphics.curveTo(
					anchors[0][0], anchors[0][1],
					p_cutter_right[0], p_cutter_right[1]
				);
			}
			target.graphics.endFill();
		}
		
		public static function getSubtreePointsInOrdered(node:NodeItem):Array {
			var points:Array = [];
			
			points = points.concat(node.getBoundingPoints());
			
			if (!node.isCollapsed()) {
				for each (var child:NodeItem in node.childs) {
					points = points.concat(getSubtreePointsInOrdered(child));
				}
			}
			
			return points;
		}
		
		public static function getCurrentAngle(relX:Number, relY:Number):int {
			var relDegree:Number = Math.atan(relY / relX) / Math.PI * 180;
			return (360 - (relX < 0 ? 180.0 + relDegree : relDegree)) % 360;
		}
		
		public static function isBiggerDistance(p0:Point, p1:Array, p2:Array):Boolean {
			var d1:Number = Math.pow(p0.x - p1[0], 2) + Math.pow(p0.y - p1[1], 2);
			var d2:Number = Math.pow(p0.x - p2[0], 2) + Math.pow(p0.y - p2[1], 2);
			return d2 > d1;
		}
		
		public static function ifPointOnTheRight(tm2:Array, tm1:Array, p:Array):Boolean {
			return ((tm1[0] - tm2[0]) * (p[1] - tm2[1]) - (p[0] - tm2[0]) * (tm1[1] - tm2[1])) >= 0;
		}
		
		private static function convexHull_getMostBottomLeftPoint(points:Array):Point {
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
		
		private static function convexHull_getOrderedPointContainer(points:Array, p0:Point):Object {
			var orderedPoints:Object = {};
			for (var idx:* in points) {
				var angle:int = getCurrentAngle(
					p0.x - points[idx][0],
					p0.y - points[idx][1]
				);
				if (!orderedPoints.hasOwnProperty('angle_' + angle) || isBiggerDistance(p0, orderedPoints['angle_' + angle], points[idx])) {
					orderedPoints['angle_' + angle] = points[idx];
				}
			}
			return orderedPoints;
		}
		
		private static function convexHull_angleHalfCut(v1:Array, v2:Array, length:Number):Array {
			// Relatice choords
			var rx1:Number = v1[1][0] - v1[0][0];
			var ry1:Number = v1[1][1] - v1[0][1];
			var rx2:Number = v2[1][0] - v2[0][0];
			var ry2:Number = v2[1][1] - v2[0][1];
			trace('r1: ' + rx1 + ':' + ry1);
			trace('r2: ' + rx2 + ':' + ry2);
			
			// Vector lengths
			var l1:Number = Math.sqrt(Math.pow(rx1, 2) + Math.pow(ry1, 2));
			var l2:Number = Math.sqrt(Math.pow(rx2, 2) + Math.pow(ry2, 2));
			var scale:Number = l1 / l2;
			
			rx2 *= scale;
			ry2 *= scale;
			trace('scale; ' + scale);
			trace('new r2: ' + rx2 + ':' + ry2);
			
			// Half cutter vector
			var hcx:Number = (rx1 + rx2) / 2;
			var hcy:Number = (ry1 + ry2) / 2;
			var hcl:Number = Math.sqrt(Math.pow(hcx, 2) + Math.pow(hcy, 2));
			trace('hc: ' + hcx + ':' + hcy);
			
			var hc_scale:Number = length / hcl;
			trace('hc scale: ' + hc_scale);
			var normal_hc_left:Array = [-hc_scale * hcy + v1[0][0], hc_scale * hcx + v1[0][1]];
			var normal_hc_right:Array = [hc_scale * hcy + v1[0][0], -hc_scale * hcx + v1[0][1]];
			
			trace(normal_hc_left);
			trace(normal_hc_right);
			
			return [normal_hc_left, normal_hc_right];
		}
		
	}
	
}