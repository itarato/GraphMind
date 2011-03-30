package com.graphmind.data {
	
	import com.kitten.network.Connection;
	
	import mx.collections.ArrayCollection;
	
	public class DrupalViews {
		private var _name:String;
		private var _conn:Connection;
		private var _id:int;
		private var _baseTable:String;
		
		[Bindable]
		public static var availableViews:ArrayCollection = new ArrayCollection();

		
		public function DrupalViews(data:Object, conn:Connection) {
			DrupalViews.availableViews.addItem(this);
			this._conn = conn;
			this._id = ++_id;
			this._name = data.name;
			this._baseTable = data.baseTable;
		}

		
		public function get siteConnectionID():String {
      return _conn.toString().replace(/^([^\/])*.*$/gi, '$1');
		}
		

		public function get name():String {
			return this._name;
		}
		

		public function get baseTable():String {
			return this._baseTable;
		}
		

		public function get sourceURL():String {
      return _conn.target;
		}
		
		
		public function get connection():Connection {
			return _conn;
		}

	}

}
