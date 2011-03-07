package com.graphmind
{
	import com.graphmind.data.ViewsCollection;
	import com.graphmind.net.SiteConnection;
	import com.graphmind.util.Log;
	import com.graphmind.util.OSD;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.core.Application;
	import mx.rpc.events.ResultEvent;
	
	import plugins.*;
	
	[Event(name="applicationDataComplete", type="ApplicationManager")]
	public class ApplicationManager extends EventDispatcher {
	  
	  /**
	   * Event: triggered when application loaded the basic data.
	   */
	  public static var APPLICATION_DATA_COMPLETE:String = 'applicationDataComplete';
		
		public static var LOG_MODE:Boolean = true;
		
		/** 
		 * Base site connection.
		 */
		public var baseSiteConnection:SiteConnection;
		
		/**
		 * Indicates the access permissions.
		 */
		protected var _isEditable:Boolean = false;
		
		/**
		 * Last timestamp of the saved state.
		 * Important when checking multi editing collisions.
		 * If the self's lastSaved is earlier than on the Drupal side, it means
		 * an other client saved a different state. Currently there is no
		 * way for multiediting ;.( - Arms of Sorrow - Killswitch Engage
		 */
		public var lastSaved:Number = new Date().time;
		
		/**
		 */
		public var features:Array;
		
		/**
		 * Constructor.
		 */
		public function ApplicationManager() {
      baseSiteConnection = SiteConnection.createSiteConnection(getBaseDrupalURL());
      
      ConnectionManager.connectToDrupal(baseSiteConnection.url, _init_GM_stage_connected);
      
      setEditMode(false);
		}
			
		/**
		 * Get the host Drupal site's URL
		 */
		protected function getBaseDrupalURL():String {
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
		
		/**
		 * URL for the icons.
		 */
		public function getIconPath():String {
			return Application.application.parameters.iconDir || 'http://localhost/drupal_services/sites/default/modules/graphmind_service/graphmind/icons/';
		}

		/**
		 * Init stage 2
		 * Site is connected already
		 */
		protected function _init_GM_stage_connected(result:ResultEvent):void {
			baseSiteConnection.sessionID = result.result.sessid;
			baseSiteConnection.username  = result.result.user.name;
			
			// Get all the available views
			// @todo Loading views is a feature. So it has to be added later.
			// ConnectionManager.getViews(baseSiteConnection, _init_GM_stage_views_loaded);
			ConnectionManager.loadFeatures(baseSiteConnection, _init_GM_stage_features_loaded, this.getHostNodeID());
		}
		
		
		protected function _init_GM_stage_features_loaded(result:ResultEvent):void {
		  OSD.show('Features are loaded');
		  this.features = result.result as Array;
      
      // Load base node
      dispatchEvent(new Event(APPLICATION_DATA_COMPLETE));
		}
		
		
		/**
		 * Init stage 4
		 * Base site's views are loaded already
		 */
		protected function _init_GM_stage_views_loaded(result:ResultEvent):void {
		  // Populate Views lists.
      for each (var data:Object in result.result) {
        new ViewsCollection(data, baseSiteConnection);
      }
		}
		
		/**
		 * Save event is done.
		 */
		public function _save_stage_saved(result:ResultEvent):void {
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
				GraphMind.i.currentState = 'only_view_mode';
			} else {
				GraphMind.i.currentState = '';
			}
		}

	}
}