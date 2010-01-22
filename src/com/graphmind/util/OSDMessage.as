package com.graphmind.util {

	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import mx.containers.Canvas;
	import mx.controls.Text;
	import mx.events.FlexEvent;
	
	public class OSDMessage extends Canvas {
	
		public function OSDMessage(text:String, level:String) {
			super();
			
			var tx:Text = new Text();
			
			tx.addEventListener(FlexEvent.UPDATE_COMPLETE, function (event:FlexEvent):void {
				graphics.beginFill(OSD.getColorFromLevel(level), 0.8);
				graphics.drawRoundRect(0, 0, OSD.width, tx.measuredHeight + 2 * OSD.padding, 6, 6);
				graphics.endFill();
				width = OSD.width;
				height = tx.measuredHeight + 2 * OSD.padding;
			});
			
			tx.setStyle('color', '#FFFFFF');
			tx.width = OSD.width - 2 * OSD.padding;
			tx.x = tx.y = OSD.padding;
			tx.text = text;
			addChild(tx);
		}
		
		public function onEnterFrame(event:Event):void {
			alpha -= 0.05;
			if (alpha <= 0.1) {
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				kill();
			}
		}
		
		public function countdown():void {
			setTimeout(function():void{addEventListener(Event.ENTER_FRAME, onEnterFrame);}, 3000);
		}
		
		protected function kill():void {
			parent.removeChild(this);
		}

	}
	
}