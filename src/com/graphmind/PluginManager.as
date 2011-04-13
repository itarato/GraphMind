package com.graphmind {
	import com.graphmind.util.Log;
	
	import flash.system.ApplicationDomain;
	import flash.utils.getDefinitionByName;
	
	import mx.core.Application;
	
	import plugins.*;

	/**
	 * It's necessary to manually add all the plugin classes.
	 */	
	[Frame(extraClass="plugins.TaxonomyManager")]
  [Frame(extraClass="plugins.Relationship")]
  [Frame(extraClass="plugins.Tooltip")]
  
	
	public class PluginManager {
	  
    /**
     * Hook: fired when the application is being initialized.
     */
    public static var HOOK_PRE_INIT:String = 'pre_init';
		
		/**
		 * List of available plugins.
		 */
		private static var _plugins:Array;
		
		
		/**
		 * Instantiate plugin array.
		 * 
		 * @param array plugins
		 */
		public static function init():void {
			var plugin_array:Array = Application.application.parameters.plugins ? String(Application.application.parameters.plugins).split(',') : []
			PluginManager._plugins = plugin_array ? plugin_array : [];
			
			for (var idx:* in _plugins) {
			  var vClass:Class = getDefinitionByName('plugins.' + _plugins[idx].toString()) as Class;
			  try {
			    (vClass as Object)['init']();
			  } catch (error:Error) {}
			}
		}
		
		public static function alter(hook:String, data:Object = null):void {
			Log.debug('Alter hook called: ' + hook);
			for each (var plugin:* in PluginManager._plugins) {
				if (ApplicationDomain.currentDomain.hasDefinition('plugins.' + plugin)) {
					var PluginClass:Class = getDefinitionByName('plugins.' + plugin) as Class;
					try {
						(PluginClass as Object)['alter_' + hook](data);
					} catch (error:Error) {}
				}
			}
		}

	}

}
