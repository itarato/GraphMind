/**
 * Manager
 * Singleton
 */
package com.graphmind
{
	import com.graphmind.net.RPCServiceHelper;
	import com.graphmind.net.SiteConnection;
	import com.graphmind.net.UniqueItemLoader;
	import com.graphmind.temp.TempItemLoadData;
	import com.graphmind.temp.TempViewLoadData;
	
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	public class ConnectionManager
	{
		private static var _instance:ConnectionManager = null;
		
		
		public function ConnectionManager()	{
			super();
		}
		
		public static function getInstance():ConnectionManager {
			if (_instance == null) {
				_instance = new ConnectionManager();
			}
			
			return _instance;
		}
		
		
		/**
		 * Connect to a site
		 */
		public function connectToDrupal(url:String, success:Function):void {
			RPCServiceHelper.createRPC('system', 'connect', 'amfphp', url, success, function(error:FaultEvent):void{
				Alert.show('Network error: cannot connect to site ' + url + "\n" + error);
			}).send(); 
		}
		
		/**
		 * Logout from a site.
		 */
		public function logout(sc:SiteConnection, success:Function):void {
			RPCServiceHelper.createRPC('user', 'logout', 'amfphp', sc.url, success, function(error:FaultEvent):void{
				Alert.show("Network error: cannot logout with user\n" + sc);
			}).send(sc.sessionID);
		}
		
		/**
		 * Login to a site
		 */
		public function login(sc:SiteConnection, success:Function):void {
			RPCServiceHelper.createRPC('user', 'login', 'amfphp', sc.url, success, function(error:FaultEvent):void{
				Alert.show("Network error: cannot login with user\n" + sc);
			}).send(sc.sessionID, sc.username, sc.password);
		}
		
		/**
		 * Get base sites views list
		 */
		public function getViews(sc:SiteConnection, success:Function):void {
			RPCServiceHelper.createRPC('graphmind', 'getViews', 'amfphp', sc.url, success, function(error:FaultEvent):void{
				Alert.show("Network error: cannot get views list\n" + sc);
			}).send(sc.sessionID);
		}
		
		
		/**
		 * Connect to a Drupal site - multiple steps
		 */
		public function connectToSite(sc:SiteConnection):void {
			connectToDrupal(sc.url, function(_result:ResultEvent):void {
				_connectToSite_phase_connected(_result, sc);
			});
		}
		
		/**
		 * Connect to a site - stage 2
		 */
		private function _connectToSite_phase_connected(result:ResultEvent, sc:SiteConnection):void {
			sc.sessionID = result.result.sessid;
			if (result.result.user.userid == 0) {
				// Not logged in yet
				login(sc, function(_result:ResultEvent):void {
					_connectToSite_phase_logged_in(_result, sc);
				});
			} else if (result.result.user.name != sc.username) {
				// Logged in another account
				// @TODO - BUG: services.module 533, 570
				logout(sc, function(_result:ResultEvent):void {
					sc.sessionID = _result.result.sessid;
					_connectToSite_phase_logged_out(_result, sc);
				});
			} else {
				// Logged in with the requested account
				getViews(sc, function(_result:ResultEvent):void{
					_connectToSite_phase_views_loaded(_result, sc);
				});
			}
		}
		
		/**
		 * Connect to a site - logging out
		 */
		private function _connectToSite_phase_logged_out(result:ResultEvent, sc:SiteConnection):void {
			login(sc, function(_result:ResultEvent):void {
				_connectToSite_phase_logged_in(_result, sc);
			});
		}
		
		/**
		 * Connect to a site - loading views list
		 */
		private function _connectToSite_phase_logged_in(result:ResultEvent, sc:SiteConnection):void {
			trace('login succeeded');
			getViews(sc, function(_result:ResultEvent):void{
				_connectToSite_phase_views_loaded(_result, sc);
			});
		}
		
		/**
		 * Connect to a site - final state, views recieved
		 */
		private function _connectToSite_phase_views_loaded(result:ResultEvent, sc:SiteConnection):void {
			trace('views loaded');
			ViewsManager.getInstance().receiveViewsData(result, sc);
		}
		// END of site connection /////
		
		
		/**
		 * Load a node
		 */
		public function nodeLoad(nid:int, sc:SiteConnection, sucecss:Function):void {
			RPCServiceHelper.createRPC('node', 'get', 'amfphp', sc.url, sucecss, function(error:FaultEvent):void{
				Alert.show("Node " + nid + " is not exists or needs permission.", "GraphMind");
			}).send(sc.sessionID, nid);
		}
		// END of node load ///////////
		
		
		/**
		 * Load items from a views.
		 */
		public function viewListLoad(requestData:TempViewLoadData):void {
			RPCServiceHelper.createRPC(
				'views', 
				'get', 
				'amfphp', 
				requestData.viewsData.parent.sourceURL,
				function(_result:ResultEvent):void {
					requestData.success(_result.result, requestData);
				},
				function(error:FaultEvent):void {
					Alert.show("Views cannot load: " + requestData.viewsData.view_name + requestData.viewsData.parent.source + error, "GraphMind");
				}
			).send(
				requestData.viewsData.parent.sourceSessionID,
				requestData.viewsData.view_name,
				requestData.viewsData.fields,
				[requestData.viewsData.args],
				requestData.viewsData.offset,
				requestData.viewsData.limit
			);
		}
		// END views list load.

		
		/**
		 * Load single item.
		 */
		public function itemLoad(requestData:TempItemLoadData):void {
			RPCServiceHelper.createRPC(
				UniqueItemLoader.nodeTypeToServiceType(requestData.nodeItemData.type),
				'get',
				'amfphp',
				requestData.nodeItemData.source.url,
				function(_result:ResultEvent):void {
					requestData.success(_result.result, requestData);
				},
				function(error:FaultEvent):void {
					Alert.show("Item cannot loaded: " + requestData.nodeItemData.type + ":" + requestData.nodeItemData.getDrupalID(), "GraphMind"); 
				} 
			).send(
				requestData.nodeItemData.source.sessionID,
				requestData.nodeItemData.getDrupalID()
			);
		}
		// END of load item ///////////
		
		
		/**
		 * Save (export) the state of the map in an MM (FreeMind) format.
		 */
		public function saveGraphMind(nid:int, mm:String, lastSaveTimestamp:Number, sc:SiteConnection, success:Function):void {
			RPCServiceHelper.createRPC(
				'graphmind', 
				'saveGraphMind',
				'amfphp',
				sc.url,
				success,
				function(error:FaultEvent):void {
					Alert.show("Saving is failed.", "Error");
				}
			).send(sc.sessionID, nid, mm, lastSaveTimestamp / 1000);
		}
		// END exporting //////////////
		
	}
}