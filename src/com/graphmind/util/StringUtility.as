package com.graphmind.util
{
	public class StringUtility
	{
		public static function iconUrlToIconName(url:String):String {
			return url.replace(/^.*\/([^\/]*)\.png$/gi, '$1');
		}
	}
}