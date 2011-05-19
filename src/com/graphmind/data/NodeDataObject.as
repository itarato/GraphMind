package com.graphmind.data {
	
	import com.kitten.network.Connection;
	
	import mx.collections.ArrayCollection;
	
	
	public class NodeDataObject {
	  
		/**
		 * Gobal node ID tracker.
		 */
		private static var uniqueID:uint = 0;
		
		/**
		 * Original data comes from Drupal.
		 * Node data, File data, User data, Term data ... etc.
		 */
		public var drupalData:Object;
		
		/**
		 * Origin that data comes from.
		 * If it's a normal node, that it's null.
		 */
		public var connection:Connection;
		
		/**
		 * Associated Drupal type: one from NodeType.
		 */
		public var type:String = NodeType.NORMAL;
		
		/**
		 * 'Unique' string ID for nodes: ID_#.
		 */
		private var _id:String = 'ID_' + String(NodeDataObject.uniqueID++);
		
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
		public var updated:Number;
		
		/**
		 * Title.
		 * This title overrides the default Drupal title.
		 */
		private var _title:String;
    
    /**
     * True if has cloud.
     */
    public var hasCloud:Boolean = false;
    
    /**
     * UI icons.
     */
    public var icons:ArrayCollection = new ArrayCollection();
		
		
		/**
		 * Contructor.
		 */
		public function NodeDataObject(_data:Object = null, _type:String = NodeType.NORMAL, _conn:Connection = null) {
		  // Data.
			updated = created = new Date().time;
			drupalData = _data || {};
			connection = _conn;
			type = _type;
			
			// Get title from arbitrary data.
			_recalculateTitle();
			_recalculateColor();
			_recalculateLink();
			_recalculateDrupalID();
		}
		
		
		public function get title():String {
		  return _title || ' ';
		}
		
		
		public function set title(title:String):void {
			this._title = title;
		}
		
		
		public function set drupalID(id:int):void {
			this._drupalID = id;
		}
		
		
		public function get drupalID():int {
		  _recalculateDrupalID();
			return _drupalID;
		}
		
		
		private function _recalculateLink():void {
			if (_link.length > 0) return;
			
			var newLink:String = '';
			
			if (connection && connection.basePath && drupalID) {
				var url:String = connection.basePath;
				switch (type) {
					case NodeType.NODE: 
					  newLink = url + 'node/' + drupalID;
					  break;
					case NodeType.USER: 
					  newLink = url + 'user/' + drupalID;
					case NodeType.COMMENT:
						if (drupalData.cid && drupalData.comments_nid) {
							newLink = url + 'node/' + drupalData.comments_nid + '#comment-' + drupalData.cid;
						}
						break;
					case NodeType.TERM: 
            newLink = url + 'taxonomy/term/' + drupalID;
				}
			}
			
			_link = newLink;
		}


		public function dataDelete(param:String):void {
			var new_data:Object = {};
			for (var key:* in drupalData) {
				if (key.toString() != param) {
					new_data[key] = drupalData[key];
				}
			}
			drupalData = new_data;
		}
		
		
		public function dataAdd(attribute:String, value:String):void {
			drupalData[attribute] = value;
		}
		
		
		public function equalTo(attributes:Object, nodeType:String):Boolean {
			// @TODO add node source site filtering
			return nodeType == type && getDrupalIDFromData(nodeType, attributes) == drupalID;
		}
		
		
		private function _recalculateDrupalID():void {
		  _drupalID = Number(getDrupalIDFromData(type, drupalData));
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
      return drupalData;
    } 
    
    
    public function addIcon(iconName:String):void {
      icons.addItem(iconName);
    }
    
    
    protected function getColor():uint {
      if (color) {
        return color;
      }
      
      return NodeType.getNodeTypeColor(type);
    }
    
    
    /**
     * Recalculate title;
     */
    private function _recalculateTitle():void {
      if (_title && _title.length > 0) {
        return void;
      }
      
      switch (type) {
        case NodeType.NODE:
          _title = drupalData.title || drupalData.node_title || '';
          break;
        case NodeType.USER:
          _title = drupalData.name  || drupalData.users_name || '';
          break;
        case NodeType.COMMENT:
          _title = drupalData.comments_subject || drupalData.title || drupalData.comments_title || '';
          break;
        case NodeType.FILE:
          _title = drupalData.files_filename || drupalData.filename || '';
          break;
        case NodeType.TERM:
          _title = drupalData.term_data_name || '';
          break;
      }         
    }
    
    
    public function set link(value:String):void {
      _link = value;
    }
    
    
    public function get link():String {
      _recalculateLink();
      return _link;
    }
    
    
    private function _recalculateColor():void {
      color = getColor();
    }
    
    
    public function set id(id:String):void {
      if (id.match(/\d+/gi)) {
        var num:int = Number(id.replace(/[^\d]/gi, ''));
        if (num >= NodeDataObject.uniqueID) {
          NodeDataObject.uniqueID = num + 1;
        }
      }
      
      _id = id;
    }
    
    
    public function get id():String {
      return _id;
    }
    
    
    public function recalculateData():void {
      _recalculateColor();
      _recalculateDrupalID();
      _recalculateLink();
      _recalculateTitle();
    }
    
	}
	
}