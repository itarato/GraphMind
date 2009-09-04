package com.graphmind.data {
	
	import com.graphmind.net.SiteConnection;
	import com.graphmind.util.Log;
	
	import mx.collections.ArrayCollection;
	
	public class ViewsCollection {
		private var _name:String;
		private var _source:SiteConnection;
		private var _id:int;
		private var _baseTable:String;
		
		[Bindable]
		public static var collection:ArrayCollection = new ArrayCollection();
		
		public function ViewsCollection(data:Object, sc:SiteConnection) {
			ViewsCollection.collection.addItem(this);
			this._source = sc;
			this._id = ++_id;
			this._name = data.name;
			this._baseTable = data.baseTable;
		}
		
		public function get siteConnectionID():int {
			return this._source.id;
		}
		
		public function get name():String {
			return this._name;
		}
		
		public function get baseTable():String {
			return this._baseTable;
		}

		public function handleDataGridSelection():void {
			Log.info('click on views table: ' + this._name);
		}
		
		public function get sourceURL():String {
			return _source.url;
		}
		
		public function get sourceSessionID():String {
			return _source.sessionID;
		}
		
		public function get source():SiteConnection {
			return _source;
		}
	}
}
