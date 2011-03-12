package com.graphmind {
  
	import com.graphmind.data.ViewsCollection;
	import com.graphmind.event.ApplicationEvent;
	import com.graphmind.util.Log;
	import com.graphmind.util.OSD;
	import com.kitten.events.ConnectionEvent;
	import com.kitten.network.Connection;
	
	import flash.events.EventDispatcher;
	
	import mx.core.Application;
	import mx.rpc.events.ResultEvent;
	
	import plugins.*;
	
	/**
	 * Emitted events.
	 */
	[Event(name="applicationDataComplete", type="com.graphmind.event.ApplicationEvent")]
	public class ApplicationController extends EventDispatcher {
	  
	  /**
	  * Shared instance.
	  */
	  [Bindable]
	  public static var i:ApplicationController;
	  
		/**
		 * Logging mode is enabled or not.
		 */
		public static var LOG_MODE:Boolean = true;
		
    /**
     * Tree map view controller.
     */
    [Bindable]
    public var treeMapViewController:TreeMapViewController;
		
		/** 
		 * Base site connection.
		 */
		public var baseSiteConnection:Connection;
		
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
		 * Feature array.
		 */
		public var features:Array;
		      
    /**
     * Workflow manager - kinda factory for different composites.
     * For example:
     *  - tree composite creates tree nodes and tree structure...
     *  - futures wheel composite creates f.w. related objects
     */
    public var workflowComposite:IWorkflowComposite; 
    
		/**
		 * Constructor.
		 */
		public function ApplicationController() {
		  ApplicationController.i = this;
		  
      // Edit mode has to be false by default.
      // Editing privileges have to be arrived from the backend with the user object.
      setEditMode(false);
      
      this.treeMapViewController = new TreeMapViewController();
      GraphMind.i.map.addChild(this.treeMapViewController.view);
      
		  // Establish connection to the Drupal site.
      baseSiteConnection = new Connection(this.getBaseDrupalURL());
      baseSiteConnection.isSessionAuthentication = true;
      baseSiteConnection.addEventListener(ConnectionEvent.CONNECTION_IS_READY, onSuccess_siteIsConnected);
      baseSiteConnection.addEventListener(ConnectionEvent.CONNECTION_IS_FAILED, ConnectionManager.defaultErrorHandler);
      baseSiteConnection.connect();
		}
			
		/**
		 * Get the host Drupal site's URL
		 */
		protected function getBaseDrupalURL():String {
			return Application.application.parameters.basePath;
		}
		
		/**
		 * Get hosting node's NID
		 */
		public function getHostNodeID():int {
			return Application.application.parameters.nid;
		}
		
		/**
		 * URL for the icons.
		 */
		public function getIconPath():String {
			return Application.application.parameters.iconDir;
		}

		/**
		 * Site is connected already
		 */
		protected function onSuccess_siteIsConnected(event:ConnectionEvent):void {
		  Log.info("Connection to Drupal is established.");
			// Get all the available features
			baseSiteConnection.call('graphmind.getFeatures', onSuccess_featuresAreLoaded, this.getHostNodeID());
			baseSiteConnection.call('graphmind.getViews', onSuccess_viewsListsAreLoaded);
			baseSiteConnection.call('node.get', onSuccess_rootNodeIsLoaded, this.getHostNodeID());
		}
		
		
		/**
		 * Features are loaded.
		 * Features are disabled by default.
		 */
		protected function onSuccess_featuresAreLoaded(result:Object):void {
		  Log.info("Features are loaded: " + result.toString());
		  this.features = result as Array;
		}
		
		
		/**
		 * Base site's views are loaded already
		 */
		protected function onSuccess_viewsListsAreLoaded(result:Object):void {
		  Log.info("Views lists are loaded: " + (result as Array).length);
		  // Populate Views lists.
      for each (var data:Object in result) {
        new ViewsCollection(data, baseSiteConnection);
      }
		}

  
    /**
    * Root node is loaded.
    */
    protected function onSuccess_rootNodeIsLoaded(result:Object):void {
      Log.info("Root node is loaded: " + result.nid);
//      TreeMapViewController.i.initMapWithBaseNode(result);
      setEditMode(result.graphmindEditable == '1');
      this.treeMapViewController.rootNode = ImportManager.importNodesFromDrupalResponse(result);
      this.treeMapViewController.view.refreshDisplay(); 
      
      // Load base node
      dispatchEvent(new ApplicationEvent(ApplicationEvent.APPLICATION_DATA_COMPLETE));
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

    
    /**
    * Checks if the user has access to edit the mindmap.
    * @TODO if not, it should be only a not-savable mode, not an editless mode.
    */
		public function isEditable():Boolean {
			return _isEditable;
		}
		
		
		/**
		 * Set the edit mode.
		 */
		public function setEditMode(editable:Boolean):void {
			_isEditable = editable;
			if (!_isEditable) {
				GraphMind.i.currentState = 'only_view_mode';
			} else {
				GraphMind.i.currentState = '';
			}
		}
		
		
		/**
		 * Checks is the map is connected to a site.
		 */
		public function isBaseConnectionLive():Boolean {
		  return true;
		}
		
		
		

	}

}
