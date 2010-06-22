package com.graphmind.display {
	import mx.core.UIComponent;
	
	
	public interface IDrawable extends IDisplayItem {
		
		function initGraphics():void;
		
		function refreshGraphics():void;
		
	}
	
}