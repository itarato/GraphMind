package com.graphmind.display {
	import mx.core.UIComponent;
	
	
	public interface IDisplayItem {
		
		function getWidth():uint;
		
		function getHeight():uint;
		
		function get x():Number;
		
		function get y():Number;
		
		function set x(value:Number):void;
		
		function set y(value:Number):void;
		
		function getUIComponent():UIComponent;
		
	}
}