package com.graphmind.data {
	
	import com.graphmind.net.SiteConnection;
	
	public class NodeItemData {
		// Gobal node ID tracker
		public static var id:uint = 0;
		
		public static const NODE:String    = 'node';
		public static const USER:String    = 'users';
		public static const COMMENT:String = 'comments';
		public static const NORMAL:String  = 'normal';
		public static const FILE:String    = 'files';
		public static const TERM:String    = 'term_data';
		public static const updatableTypes:Array = [FILE, NODE, USER];
		
		public var data:Object;
		public var source:SiteConnection = SiteConnection.createSiteConnection();
		public var type:String = NORMAL;
		public var id:uint = NodeItemData.id++;
		public var link:String = '';
		// Extra color for the node. GM has it's own colors, but with this
		// variable plugins can add their own colors. 
		public var color:uint;
		protected var _drupalID:int;
		
		// FreeMind data
		public var created:Number;
		public var modified:Number;
		
		// Hard-coded title
		// This title overrides each other.
		private var _title:String;
		
		public function NodeItemData(data:Object, type:String = NORMAL, source:SiteConnection = null) {
			this.modified = this.created = new Date().time;
			
			this.data   = data;
			this.source = source;
			this.type   = type;
		}
		
		public function get title():String {
			if (_title && _title.length > 0) return _title;
			
			var title:String = '';
			switch (type) {
				case NODE:
					title = data.title || data.node_title || '';
					break;
				case USER:
					title = data.name  || data.users_name || '';
					break;
				case COMMENT:
					title = data.comments_subject || data.title || data.comments_title || '';
					break;
				case FILE:
					title = data.files_filename || data.filename || '';
					break;
				case TERM:
					title = data.term_data_name || '';
					break;
			}
			
			return (title && title.length) ? title : 'node #' + id; 
		}
		
		public function set title(title:String):void {
			this._title = title;
		}
		
		public function set drupalID(id:int):void {
			this._drupalID = id;
		}
		
		public function getDrupalID():String {
			if (_drupalID) return _drupalID.toString();
			
			return getDrupalIDFromData(type, data);
		}
		
		public function getPath():String {
			if (link.length > 0) return link;
			
			if (source && source.url && getDrupalID()) {
				var url:String = source.url.toString().replace(/services\/amfphp/gi, '');
				switch (type) {
					case NODE: return url + '/node/' + getDrupalID();
					case USER: return url + '/user/' + getDrupalID();
					case COMMENT:
						if (data.cid && data.comments_nid) {
							return url + '/node/' + data.comments_nid + '#comment-' + data.cid;
						}
						break;
					case TERM: return url + '/taxonomy/term/' + getDrupalID();
				}
			}
			
			return '';
		}

		public function dataDelete(param:String):void {
			var new_data:Object = {};
			for (var key:* in data) {
				if (key.toString() != param) {
					new_data[key] = data[key];
				}
			}
			data = new_data;
		}
		
		public function dataAdd(attribute:String, value:String):void {
			data[attribute] = value;
		}
		
		public function equalTo(attributes:Object, nodeType:String):Boolean {
			// @TODO add node source site filtering
			return nodeType == type && getDrupalIDFromData(nodeType, attributes) == getDrupalID();
		}
		
		public static function getDrupalIDFromData(type:String, data:Object):String {
			switch (type) {
				case NODE:
					return data.nid || data.id || data.node_id || '';
				case USER:
					return data.userid || data.uid || data.id || data.users_id || '';
				case COMMENT:
					return data.cid || data.id || data.comments_id || '';
				case FILE:
					return data.fid || ''; 
				case TERM:
					return data.tid || '';
				default:
					return '';
			}
		}
		
	}
}