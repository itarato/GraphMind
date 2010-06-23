package com.graphmind.display {

	import mx.core.UIComponent;
	
	/**
	 * Something that can be drawn on a UIComponent. Can be initialized and
	 * refreshed.
	 */
	public interface IDrawable extends IDisplayItem {
		
		function initGraphics():void;
		
		function refreshGraphics():void;
		
	}
	
}