package com.graphmind.data {
	
	import com.graphmind.event.NodeEvent;
	import com.graphmind.net.SiteConnection;
	import com.graphmind.util.StringUtility;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Image;
	
	public class NodeData {
		/**
		 * Gobal node ID tracker.
		 */
		public static var id:uint = 0;
		
		/**
		 * Original data comes from Drupal.
		 * Node data, File data, User data, Term data ... etc.
		 */
		public var data:Object;
		
		/**
		 * Origin that data comes from.
		 * If it's a normal node, that it's null.
		 */
		public var source:SiteConnection = SiteConnection.createSiteConnection();
		
		/**
		 * Associated Drupal type: one from NodeType.
		 */
		public var type:String = NodeType.NORMAL;
		
		/**
		 * 'Unique' string ID for nodes: ID_#.
		 * @TODO making it really unique.
		 */
		public var id:String = 'ID_' + String(NodeData.id++);
		
		/**
		 * URL.
		 * For Drupal items by default the object's path. Can be overwriten.
		 */
		public var link:String = '';
		
		/**
		 * Extra color for the node. GM has it's own colors, but with this
		 * variable plugins can add their own colors.
		 */ 
		public var color:uint;
		
		/**
		 * ID in Drupal.
		 */
		protected var _drupalID:int;
		
		/**
		 * FreeMind data - timestamp of creation.
		 */
		public var created:Number;
		
		/**
		 * Timestamp of modification.
		 */
		public var modified:Number;
		
		/**
		 * Title.
		 * This title overrides the default Drupal title.
		 */
		public var _title:String;
    
    /**
     * True if has cloud.
     */
    public var hasCloud:Boolean = false;
    
    /**
     * UI icons.
     */
    public var _icons:ArrayCollection = new ArrayCollection();
		
		/**
		 * Contructor.
		 */
		public function NodeData(data:Object, type:String = NodeType.NORMAL, source:SiteConnection = null) {
		  // Data.
			this.modified = this.created = new Date().time;
			this.data   = data;
			this.source = source;
			this.type   = type;
		}
		
		public function get title():String {
		  return _title;
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
					case NodeType.NODE: return url + '/node/' + getDrupalID();
					case NodeType.USER: return url + '/user/' + getDrupalID();
					case NodeType.COMMENT:
						if (data.cid && data.comments_nid) {
							return url + '/node/' + data.comments_nid + '#comment-' + data.cid;
						}
						break;
					case NodeType.TERM: return url + '/taxonomy/term/' + getDrupalID();
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
				case NodeType.NODE:
					return data.nid || data.id || data.node_id || '';
				case NodeType.USER:
					return data.userid || data.uid || data.id || data.users_id || '';
				case NodeType.COMMENT:
					return data.cid || data.id || data.comments_id || '';
				case NodeType.FILE:
					return data.fid || ''; 
				case NodeType.TERM:
					return data.tid || '';
				default:
					return '';
			}
		}
	
	  /**
	   * Get the custom data object.
	   */ 
    public function getData():Object {
      return data;
    } 
    
    public function addIcon(iconName:String):void {
      _icons.addItem(iconName);
    }
    
    public function getTypeColor():uint {
      if (color) {
        return color;
      }
      
      switch (type) {
        case NodeType.NODE:
          return 0xC2D7EF;
        case NodeType.COMMENT:
          return 0xC2EFD9;
        case NodeType.USER:
          return 0xEFD2C2;
        case NodeType.FILE:
          return 0xE9C2EF;
        case NodeType.TERM:
          return 0xD9EFC2;
        default:
          return 0xDFD9D1;
      }
    }

    /**
     * Recalculate title;
     */    
    public function recalculateTitle():void {
      if (_title && _title.length > 0) {
        return void;
      } else {
        switch (type) {
          case NodeType.NODE:
            _title = data.title || data.node_title || '';
            break;
          case NodeType.USER:
            _title = data.name  || data.users_name || '';
            break;
          case NodeType.COMMENT:
            _title = data.comments_subject || data.title || data.comments_title || '';
            break;
          case NodeType.FILE:
            _title = data.files_filename || data.filename || '';
            break;
          case NodeType.TERM:
            _title = data.term_data_name || '';
            break;
        }
        
        if (!_title || !_title.length) {
          _title = 'node #' + id;
        }
      }
       
    }
    
	}
	
}