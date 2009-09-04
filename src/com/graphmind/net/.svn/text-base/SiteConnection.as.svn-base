package com.graphmind.net
{
	import mx.collections.ArrayCollection;
	
	public class SiteConnection
	{
		[Bindable]
		public static var connections:ArrayCollection = new ArrayCollection();
		private static var __id:int = 0;
		
		private var _url:String;
		private var _username:String;
		private var _password:String;
		private var _sessionID:String;
		private var _id:int;
		
		public function SiteConnection(url:String = '', username:String = '', password:String = '') {
			connections.addItem(this);
			this._id = ++__id;
			
			this._url = url;
			this._username = username;
			this._password = password;
		}
		
		public static function createSiteConnection(url:String = '', username:String = '', password:String = ''):SiteConnection {
			for each (var sc:SiteConnection in connections) {
				if (sc._url == url) {
					return sc;
				}
			}
			return new SiteConnection(url, username, password);
		}

		public function get url():String {
			return this._url;
		}
		
		public function set url(url:String):void {
			this._url = url;
		}
		
		public function get username():String {
			return this._username
		}
		
		public function set username(username:String):void {
			this._username = username;
		}
		
		public function get password():String {
			return this._password;
		}
		
		public function set password(password:String):void {
			this._password = password;
		}
		
		public function get sessionID():String {
			return this._sessionID;
		}
		
		public function set sessionID(sessid:String):void {
			this._sessionID = sessid;
		}
		
		public function get id():int {
			return this._id;
		}
		
		public function get shortName():String {
			return this._url.replace(/http:\/\/(.*)\/services.*/gi, '$1');
		}
		
		public function toString():String {
			return "Site connection:\n" + 
				"\turl: " + _url + "\n" +
				"\tsessid: " + _sessionID + "\n" + 
				"\tusername: " + _username;
		}
		

	}
}