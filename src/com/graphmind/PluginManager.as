package com.graphmind {
	import flash.system.ApplicationDomain;
	import flash.utils.getDefinitionByName;
	
	import plugins.*;

	/**
	 * It's necessary to manually add all the plugin classes.
	 */	
	[Frame(extraClass="plugins.TaxonomyManager")]
	
	public class PluginManager {
		
		private static var _plugins:Array;
		
		/**
		 * Instantiate plugin array.
		 * 
		 * @param array plugins
		 */
		public static function initPlugins(plugins:Array = null):void {
			PluginManager._plugins = plugins ? plugins : [];
		}
		
		public static function callHook(hook:String, data:Object = null):void {
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