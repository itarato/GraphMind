package com.graphmind.util {
	import flash.events.MouseEvent;
	
	import mx.controls.Image;
	
	
	public class OSDStaticMessage extends OSDMessage {
		
		[Embed(source='assets/images/cross.gif')]
		private var _crossIcon:Class;
		
		public function OSDStaticMessage(text:String, level:String) {
			super(text, level);
			
			var icon:Image = new Image();
			icon.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void{kill();});
			icon.source = new _crossIcon;
			icon.x = OSD.width - 16;
			icon.y = 4;
			addChild(icon);
		}
		
		public override function countdown():void {}
		
	}
	
}