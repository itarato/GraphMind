package com.graphmind
{
	import com.graphmind.net.SiteConnection;
	import com.graphmind.util.Log;
	import com.graphmind.util.OSD;
	
	import mx.core.Application;
	import mx.rpc.events.ResultEvent;
	
	import plugins.*;
	
	public class GraphMindManager
	{
		private static var _instance:GraphMindManager = null;
		
		public static var LOG_MODE:Boolean = false;
		
		// Base site connection
		public var baseSiteConnection:SiteConnection;
		private var _isEditable:Boolean = false;
		private var lastSaved:Number = new Date().time;
		
		public function GraphMindManager() {}
		
		public static function getInstance():GraphMindManager {
			if (_instance == null) {
				_instance = new GraphMindManager();
			}
			
			return _instance;
		}
			
			
		/**
		 * Get the host Drupal site's URL
		 */
		private function getBaseDrupalURL():String {
			Log.info('Host url: ' + Application.application.parameters.basePath);
			return Application.application.parameters.basePath || 'http://localhost/drupal_services/?q=services/amfphp';
		}
		
		/**
		 * Get hosting node's NID
		 */
		public function getHostNodeID():int {
			Log.info("Host nid: " + Application.application.parameters.nid);
			return Application.application.parameters.nid || 184;
		}
		
		public function getIconPath():String {
			return Application.application.parameters.iconDir || 'http://localhost/drupal_services/sites/default/modules/graphmind_service/graphmind/icons/';
		}
		
		/**
		 * Init manager
		 */
		public function init():void {
			baseSiteConnection = SiteConnection.createSiteConnection(getBaseDrupalURL());
			
			ConnectionManager.getInstance().connectToDrupal(baseSiteConnection.url, _init_GM_stage_connected);
			
			setEditMode(false);
		}
		
		/**
		 * Init stage 2
		 * Site is connected already
		 */
		private function _init_GM_stage_connected(result:ResultEvent):void {
			baseSiteConnection.sessionID = result.result.sessid;
			baseSiteConnection.username  = result.result.user.name;
			// Get all the available views
			ConnectionManager.getInstance().getViews(baseSiteConnection, _init_GM_stage_views_loaded);
		}
		
		/**
		 * Init stage 3
		 * Base site's views are loaded already
		 */
		private function _init_GM_stage_views_loaded(result:ResultEvent):void {
			ViewsManager.getInstance().receiveViewsData(result, baseSiteConnection);
			
			// Load base node
			StageManager.getInstance().loadBaseNode();
		}
		
		/**
		 * Export work to FreeMind XML format
		 * @return string
		 */
		public function exportToFreeMindFormat():String {
			return '<map version="0.9.0">' + "\n" + 
				StageManager.getInstance().baseNode.exportToFreeMindFormat() + 
				'</map>' + "\n";
		}
		
		/**
		 * Save work into host node
		 */
		public function save():String {
			var mm:String = exportToFreeMindFormat();
			ConnectionManager.getInstance().saveGraphMind(
				getHostNodeID(),
				mm,
				lastSaved,
				baseSiteConnection, 
				_save_stage_saved
			);
			StageManager.getInstance().isTreeUpdated = false;
			return mm;
		}
		
		/**
		 * Save event is done.
		 */
		private function _save_stage_saved(result:ResultEvent):void {
			//MonsterDebugger.trace(this, result.result);
			if (result.result == '1') {
				OSD.show('GraphMind data is saved.');
				lastSaved = new Date().time;
			} else {
				OSD.show('This content has been modified by another user, changes cannot be saved.', OSD.WARNING);
				// @TODO prevent later savings
			}
		}

		public function isEditable():Boolean {
			return _isEditable;
		}
		
		public function setEditMode(editable:Boolean):void {
			_isEditable = editable;
			if (!_isEditable) {
				GraphMind.instance.currentState = 'only_view_mode';
			} else {
				GraphMind.instance.currentState = '';
			}
		}

	}
}