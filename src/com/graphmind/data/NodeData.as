package com.graphmind.data {
	
	import com.graphmind.net.SiteConnection;
	
	import mx.collections.ArrayCollection;
	
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
		protected var _link:String = '';
		
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
			
			// Get title from arbitrary data.
			recalculateTitle();
			recalculateColor();
			recalculateLink();
			recalculateDrupalID();
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
		
		public function get drupalID():int {
		  recalculateDrupalID();
			return _drupalID;
		}
		
		public function recalculateLink():void {
			if (_link.length > 0) return;
			
			var newLink:String = '';
			
			if (source && source.url && drupalID) {
				var url:String = source.url.toString().replace(/services\/amfphp/gi, '');
				switch (type) {
					case NodeType.NODE: 
					  newLink = url + '/node/' + drupalID;
					  break;
					case NodeType.USER: 
					  newLink = url + '/user/' + drupalID;
					case NodeType.COMMENT:
						if (data.cid && data.comments_nid) {
							newLink = url + '/node/' + data.comments_nid + '#comment-' + data.cid;
						}
						break;
					case NodeType.TERM: 
            newLink = url + '/taxonomy/term/' + drupalID;
				}
			}
			
			_link = newLink;
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
			return nodeType == type && getDrupalIDFromData(nodeType, attributes) == drupalID;
		}
		
		public function recalculateDrupalID(forceRecalculate:Boolean = false):void {
		  // It already has a good one.
		  if (!forceRecalculate && _drupalID && _drupalID > 0) return;
		  
		  _drupalID = Number(getDrupalIDFromData(type, data));
		}
		
		protected static function getDrupalIDFromData(type:String, data:Object):int {
		  var idString:String;
			switch (type) {
				case NodeType.NODE:
					idString = data.nid || data.id || data.node_id || '';
					break;
				case NodeType.USER:
					idString = data.userid || data.uid || data.id || data.users_id || '';
					break;
				case NodeType.COMMENT:
					idString = data.cid || data.id || data.comments_id || '';
					break;
				case NodeType.FILE:
					idString = data.fid || '';
					break; 
				case NodeType.TERM:
					idString = data.tid || '';
					break;
			}
			
			return Number(idString);
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
    
    protected function getTypeColor():uint {
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
    public function recalculateTitle(forcedRecalculate:Boolean = false):void {
//      if (!forcedRecalculate && _title && _title.length > 0) {
      if (_title && _title.length > 0 && _title != ('node #' + id)) {
        return void;
      }
      
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
    
    public function set link(value:String):void {
      _link = value;
    }
    
    public function get link():String {
      recalculateLink();
      return _link;
    }
    
    public function recalculateColor():void {
      color = getTypeColor();
    }
    
	}
	
}