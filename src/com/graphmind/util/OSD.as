package com.graphmind.util {
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import mx.containers.Canvas;
	import mx.controls.Text;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	
	public class OSD {
	
		public static var INFO:String    = 'info';
		public static var WARNING:String = 'warning';
		public static var ERROR:String   = 'error';
	
		private static var messages:Array = [];
		private static var container:UIComponent;
		private static var width:int;
		private static var padding:int = 12;
		
		public static function init(container:UIComponent, width:int = 300):void {
			OSD.container = container;
			OSD.width     = width;
		}
		
		public static function show(text:String, level:String = 'info'):void {
			var msg:UIComponent = getMessagePanel(text, level); 
			OSD.container.addChild(msg);
		} 
		
		private static function getMessagePanel(text:String, level:String):Canvas {
			var osd_msg:OSDMessage = new OSDMessage();
			
			var tx:Text = new Text();
			
			tx.addEventListener(FlexEvent.UPDATE_COMPLETE, function (event:FlexEvent):void {
				osd_msg.graphics.beginFill(getColorFromLevel(level), 0.8);
				osd_msg.graphics.drawRoundRect(0, 0, OSD.width, tx.measuredHeight + 2 * OSD.padding, 6, 6);
				osd_msg.graphics.endFill();
				osd_msg.width = OSD.width;
				osd_msg.height = tx.measuredHeight + 2 * OSD.padding;
			});
			
			tx.setStyle('color', '#FFFFFF');
			tx.width = OSD.width - 2 * OSD.padding;
			tx.x = tx.y = OSD.padding;
			tx.text = text;
			osd_msg.addChild(tx);
			
			setTimeout(function():void{
				osd_msg.addEventListener(Event.ENTER_FRAME, osd_msg.onEnterFrame);
			}, 3000);
			
			return osd_msg;
		}
		
		private static function getColorFromLevel(level:String):uint {
			switch (level) {
				case INFO:    return 0x00467F;
				case WARNING: return 0xCF4900;
				case ERROR:   return 0xCF0000;
				default:      return 0x2F2F2F;
			}
		}
	}
	
}