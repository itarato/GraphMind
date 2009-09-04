package com.graphmind.util
{
	import com.graphmind.StageManager;
	
	import mx.controls.Alert;
	
	public class Log
	{
		public function Log()
		{
		}
		
		public static function log(text:String, level:String = 'INFO'):void {
			var date:Date = new Date();
			trace(text);	
//			StageManager.getInstance().stage.debugTextarea.text = 
//				StageManager.getInstance().stage.debugTextarea.text + 
//				"\n" + 
//				level + 
//				" -- " + date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds() + " -- " + 
//				text;
		}
		
		public static function info(text:String):void {
			log(text, "INFO");
		}
		
		public static function warning(text:String):void {
			Alert.show(text, 'Warning');
		}

	}
}