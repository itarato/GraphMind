package com.graphmind.util {
  
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	
	
	public class OSD {
	
		public  static var INFO:String    = 'info';
		public  static var WARNING:String = 'warning';
		public  static var ERROR:String   = 'error';
	
		private static var messages:Array = [];
		private static var container:UIComponent;
		public  static var width:int;
		public  static var padding:int = 12;
		
		
		public static function init(container:UIComponent, width:int = 300):void {
			OSD.container = container;
			OSD.width     = width;
		}
		
		
		public static function show(text:String, level:String = 'info'):void {
			var msg:UIComponent = getMessagePanel(text, level);
			OSD.container.addChild(msg);
		} 
		
		
		private static function getMessagePanel(text:String, level:String):Canvas {
			var osd_msg:OSDMessage;
			if (level == OSD.ERROR) {
				osd_msg = new OSDStaticMessage(text, level);
			} else {
				osd_msg = new OSDMessage(text, level);
				osd_msg.countdown();
			}
			
			return osd_msg;
		}
		
		
		public static function getColorFromLevel(level:String):uint {
			switch (level) {
				case INFO:    return 0x3D8F00;
				case WARNING: return 0xCF4900;
				case ERROR:   return 0xCF0000;
				default:      return 0x2F2F2F;
			}
		}
		
	}
	
}
