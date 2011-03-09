package com.graphmind.data {
	
	import com.kitten.network.Connection;
	
	import mx.collections.ArrayCollection;
	
	public class ViewsCollection {
		private var _name:String;
		private var _source:Connection;
		private var _id:int;
		private var _baseTable:String;
		
		[Bindable]
		public static var collection:ArrayCollection = new ArrayCollection();
		
		public function ViewsCollection(data:Object, conn:Connection) {
			ViewsCollection.collection.addItem(this);
			this._source = conn;
			this._id = ++_id;
			this._name = data.name;
			this._baseTable = data.baseTable;
		}
		
		public function get siteConnectionID():int {
		  // @todo implement
//			return this._source.id;
      return 0;
		}
		
		public function get name():String {
			return this._name;
		}
		
		public function get baseTable():String {
			return this._baseTable;
		}
		
		public function get sourceURL():String {
		  // @todo implement
//			return _source.url;
      return _source.target;
		}
		
//		public function get sourceSessionID():String {
////			return _source.sessionID;
//      return _source.sessID;
//		}
		
		public function get source():Connection {
			return _source;
		}
	}
}
