package com.graphmind {
	import com.graphmind.util.Log;
	
	import flash.system.ApplicationDomain;
	import flash.utils.getDefinitionByName;
	
	import mx.core.Application;
	
	import plugins.*;

	/**
	 * It's necessary to manually add all the plugin classes.
	 */	
//	[Frame(extraClass="plugins.TaxonomyManager")]
	
	public class PluginManager {
		
		private static var _plugins:Array;
		
		/**
		 * Instantiate plugin array.
		 * 
		 * @param array plugins
		 */
		public static function init():void {
			var plugin_array:Array = Application.application.parameters.plugins ? String(Application.application.parameters.plugins).split(',') : []
			PluginManager._plugins = plugin_array ? plugin_array : [];
		}
		
		public static function callHook(hook:String, data:Object = null):void {
			Log.debug('Hook called: ' + hook);
			for each (var plugin:* in PluginManager._plugins) {
				if (ApplicationDomain.currentDomain.hasDefinition('plugins.' + plugin)) {
					var PluginClass:Class = getDefinitionByName('plugins.' + plugin) as Class;
					try {
						(PluginClass as Object)['hook_' + hook](data);
					} catch (error:Error) {}
				}
			}
		}

	}

}
