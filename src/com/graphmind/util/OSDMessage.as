package com.graphmind.util {


	import flash.events.Event;
	
	import mx.containers.Canvas;
	
	public class OSDMessage extends Canvas {
	
		public function OSDMessage() {
			super();
		}
		
		public function onEnterFrame(event:Event):void {
			alpha -= 0.05;
			if (alpha <= 0.1) {
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				parent.removeChild(this);
			}
		}

	}
	
}