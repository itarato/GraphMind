package com.graphmind.util {
	import com.graphmind.StageManager;
	import com.graphmind.display.NodeItem;
	
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	
	public class NodeGraphicsHelper {
		
		public static function drawConnection(target:UIComponent, fromNode:NodeItem,  toNode:NodeItem):void {
			target.graphics.lineStyle(2, 0x777777);
			var pFrom:Point = new Point(fromNode.x + fromNode.getWidth(), fromNode.y + NodeItem.HEIGHT / 2);
			var pTo:Point   = new Point(toNode.x, toNode.y + NodeItem.HEIGHT / 2);
			target.graphics.moveTo((pFrom.x + pTo.x) / 2, (pFrom.y + pTo.y) / 2);
			target.graphics.curveTo(
				pFrom.x + (pTo.x - pFrom.x) / 4,
				pFrom.y,
				pFrom.x,
				pFrom.y
			);
			target.graphics.moveTo((pFrom.x + pTo.x) / 2, (pFrom.y + pTo.y) / 2);
			target.graphics.curveTo(
				pTo.x - (pTo.x - pFrom.x) / 4,
				pTo.y,
				pTo.x,
				pTo.y
			);
		}
		
		public static function drawCloud(node:NodeItem, target:UIComponent):void {
			var points:Array = getSubtreePointsInOrdered(node);
			
			var p0:Point = new Point(int.MAX_VALUE, int.MAX_VALUE);
			var idx:*;
			trace(points);
			for (idx in points) {
				if (points[idx][1] < p0.y || (points[idx][1] == p0.y && points[idx][0] < p0.x)) {
					p0.x = points[idx][0];
					p0.y = points[idx][1];
				}
			}
			trace(p0);
			
			var orderedPoints:Object = {};
			for (idx in points) {
				var angle:int = getCurrentAngle(
					p0.x - points[idx][0],
					p0.y - points[idx][1]
				);
				//trace('angle: ' + angle);
				if (!orderedPoints.hasOwnProperty('angle_' + angle) || isBiggerDistance(p0, orderedPoints['angle_' + angle], points[idx])) {
					orderedPoints['angle_' + angle] = points[idx];
				}
			}
			//trace(orderedPoints);
			
			var stack:Array = [];
			var j:int = 0;
			
			for (var i:int = 0; i <= 180 && j < 3; i++) {
				if (!orderedPoints.hasOwnProperty('angle_' + i)) continue;
				stack.push(orderedPoints['angle_' + i]);
				j++;
			}
			//trace(i);
			
			for (var k:int = i; k <= 180; k++) {
				if (!orderedPoints.hasOwnProperty('angle_' + k)) continue;
				while (ifPointOnTheRight(
					stack[stack.length - 2],
					stack[stack.length - 1],
					orderedPoints['angle_' + k]
				)) stack.pop(); 
				stack.push(orderedPoints['angle_' + k]);
			}
			
			//trace('result');
			target.graphics.lineStyle(1, 0x0072B9, .3);
			target.graphics.beginFill(0x0072B9, .1);
			target.graphics.moveTo(stack[0][0], stack[0][1]);
			for each (var p:Array in stack) {
				//trace(p);
				target.graphics.lineTo(p[0], p[1]);
			}
			target.graphics.lineTo(stack[0][0], stack[0][1]);
			target.graphics.endFill();
		}
		
		public static function getSubtreePointsInOrdered(node:NodeItem):Array {
			var points:Array = [];
			
			points = points.concat(node.getBoundingPoints());
			
			if (!node.isCollapsed) {
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
	}
	
}