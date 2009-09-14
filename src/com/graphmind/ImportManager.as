package com.graphmind
{
	import com.graphmind.data.NodeItemData;
	import com.graphmind.display.NodeItem;
	import com.graphmind.net.SiteConnection;
	
	public class ImportManager
	{
		private static var _instance:ImportManager = null 
		
		public function ImportManager()	{}
		
		public static function getInstance():ImportManager {
			if (_instance == null) {
				_instance = new ImportManager();
			}
			
			return _instance;
		}
		
		public function importMapFromString(baseNode:NodeItem, stringData:String):NodeItem {
			var xmlData:XML = new XML(stringData);
			
			return buildGrapMindNode(xmlData.child('node')[0]);
		}
		
		public function buildGrapMindNode(nodeXML:XML):NodeItem {
			var attributes:Object = {};
			var information:Object = {};
			for each (var attribute:XML in nodeXML.child('attribute')) {
				if (String(attribute.@NAME).substring(0, GraphMindManager.EXPORT_ATTRIBUTE_SPECIAL_MARKUP.length) != GraphMindManager.EXPORT_ATTRIBUTE_SPECIAL_MARKUP) {
					attributes[attribute.@NAME] = unescape(attribute.@VALUE);
				} else {
					information[attribute.@NAME] = unescape(attribute.@VALUE);
				}
			}
			
			var sc:SiteConnection = null;
			if (information.hasOwnProperty('__site_url') && information.hasOwnProperty('__site_username')) {
				sc = SiteConnection.createSiteConnection(
					unescape(information.__site_url),
					unescape(information.__site_username)
				);
			}
			
			var nodeItemData:NodeItemData = new NodeItemData(
				attributes,
				information.hasOwnProperty('__node_type') ? unescape(information.__node_type) : NodeItemData.NORMAL,
				sc || SiteConnection.createSiteConnection()
			);
			nodeItemData.created  = Number(nodeXML.@CREATED);
			nodeItemData.modified = Number(nodeXML.@MODIFIED);
			nodeItemData.title    = unescape(String(nodeXML.@TEXT));
			nodeItemData.id       = parseInt(String(nodeXML.@ID).replace("ID_", ""));
			var nodeItem:NodeItem = new NodeItem(nodeItemData);
			
			var nodeChilds:XMLList = nodeXML.elements('node');
			for each (var childXML:XML in nodeChilds) {
				var childNode:NodeItem = buildGrapMindNode(childXML);
				nodeItem.addNodeChild(childNode);
			}
			
			if (nodeXML.@FOLDED == 'true') {
				// @TODO implement manualCollapsed functionality.
				// Now it won't collapse branches because later node addings will open the whole tree.
				nodeItem.collapse();
			}
			
			return nodeItem;
		}

	}
}