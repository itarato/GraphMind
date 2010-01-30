package com.graphmind
{
	import com.graphmind.data.NodeItemData;
	import com.graphmind.display.ArrowLink;
	import com.graphmind.display.NodeItem;
	import com.graphmind.net.SiteConnection;
	import com.graphmind.util.Log;
	
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
			
			var postProcessObject:Object = new Object();
			postProcessObject.arrowLinks = new Array();
			
			var _baseNode:NodeItem = buildGrapMindNode(xmlData.child('node')[0], postProcessObject);
			
			// Post process arrow links
			for each (var arrowLink:ArrowLink in postProcessObject.arrowLinks) {
				if (!arrowLink.findTargetNode()) {
					Log.error('Import - arrow links - node not found.');
				}
			}
			
			return _baseNode;
		}
		
		public function buildGrapMindNode(nodeXML:XML, postProcessObject:Object):NodeItem {
			// @TODO write node checking - if those are exist
			var attributes:Object = {};
			var information:Object = {};
			for each (var attribute:XML in nodeXML.child('attribute')) {
				attributes[attribute.@NAME] = unescape(attribute.@VALUE);
			}
			
			// Load html node title, if you can
			XML.ignoreWhitespace = true;
			XML.prettyIndent = 0;
			var htmlTitle:String = '';
			if (nodeXML.child('richcontent')[0]) {
				htmlTitle = nodeXML.child('richcontent')[0].html.body.children();
				htmlTitle = htmlTitle.replace(/\n/gi, '');
			}
			// Normal title
			var rawTitle:String  = unescape(String(nodeXML.@TEXT));
			
			// Site connection
			var sc:SiteConnection = null;
			if (nodeXML.site) {
				sc = SiteConnection.createSiteConnection(
					unescape(nodeXML.site.@URL),
					unescape(nodeXML.site.@USERNAME)
				);
			}
			
			var nodeItemData:NodeItemData = new NodeItemData(
				attributes,
				nodeXML.@TYPE ? nodeXML.@TYPE : NodeItemData.NORMAL,
				sc || SiteConnection.createSiteConnection()
			);
			nodeItemData.created  = Number(nodeXML.@CREATED);
			nodeItemData.modified = Number(nodeXML.@MODIFIED);
			nodeItemData.title    = rawTitle.length > 0 ? rawTitle : htmlTitle;
//			nodeItemData.id       = parseInt(String(nodeXML.@ID).replace("ID_", ""));
			nodeItemData.id       = String(nodeXML.@ID);
			nodeItemData.link     = unescape(String(nodeXML.@LINK));
			var nodeItem:NodeItem = new NodeItem(nodeItemData);
			
			// ArrowLinks
			var arrowLinkXMLList:XMLList = nodeXML.elements('arrowlink'); 
			if (arrowLinkXMLList.length() > 0) {
				for each (var arrowLinkXML:Object in arrowLinkXMLList) {
//					trace(arrowLinkXML.@DESTINATION.toString());
					var arrowLink:ArrowLink = new ArrowLink(nodeItem, arrowLinkXML.@DESTINATION.toString());
					(postProcessObject.arrowLinks as Array).push(arrowLink);
				}
			}
			
			// Icons
			for each (var iconsXML:XML in nodeXML.elements('icon')) {
				nodeItem.addIcon(GraphMindManager.getInstance().getIconPath() + iconsXML.@BUILTIN + '.png');
			}
			nodeItem.redrawNodeBody();
			
			var nodeChilds:XMLList = nodeXML.elements('node');
			for each (var childXML:XML in nodeChilds) {
				var childNode:NodeItem = buildGrapMindNode(childXML, postProcessObject);
				nodeItem.addChildNodeWithStageRefresh(childNode);
			}
			
			if (nodeXML.@FOLDED == 'true') {
				nodeItem.collapse();
			}
			
			if (nodeXML.elements('cloud').length() == 1) {
				nodeItem.toggleCloud();
			}
			
			return nodeItem;
		}

	}
}