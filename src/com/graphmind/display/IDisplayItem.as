package com.graphmind.display {
  
	import mx.core.UIComponent;
	
	/**
	 * Object that placed on the screen. Has a position and a UIComponent
	 * that has the graphics on.
	 */
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