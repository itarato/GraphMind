package com.graphmind {
  
	import com.graphmind.data.NodeType;
	import com.graphmind.display.NodeController;
	import com.graphmind.display.TreeArrowLink;
	import com.graphmind.factory.NodeFactory;
	import com.graphmind.net.SiteConnection;
	import com.graphmind.util.Log;
	
	
	public class ImportManager {
		
		public static function importMapFromString(stringData:String):NodeController {
			var xmlData:XML = new XML(stringData);
			
			var postProcessObject:Object = new Object();
			postProcessObject.arrowLinks = new Array();
			
			var _baseNode:NodeController = buildGrapMindNode(xmlData.child('node')[0], postProcessObject);
			
			// Post process arrow links
			for each (var arrowLink:TreeArrowLink in postProcessObject.arrowLinks) {
				if (!arrowLink.findTargetNode()) {
					Log.error('Import - arrow links - node not found.');
				}
			}
			
			return _baseNode;
		}
		
		public static function buildGrapMindNode(nodeXML:XML, postProcessObject:Object):NodeController {
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
			
			var node:NodeController = NodeFactory.createNode(
			  attributes,
			  nodeXML.@TYPE ? nodeXML.@TYPE : NodeType.NORMAL,
			  sc || SiteConnection.createSiteConnection(),
			  rawTitle.length > 0 ? rawTitle : htmlTitle
			);
			node.nodeData.created  = Number(nodeXML.@CREATED);
			node.nodeData.modified = Number(nodeXML.@MODIFIED);
			node.nodeData.id       = String(nodeXML.@ID);
			node.nodeData.link     = unescape(String(nodeXML.@LINK));
			
			// ArrowLinks
			var arrowLinkXMLList:XMLList = nodeXML.elements('arrowlink'); 
			if (arrowLinkXMLList.length() > 0) {
				for each (var arrowLinkXML:Object in arrowLinkXMLList) {
					var arrowLink:TreeArrowLink = new TreeArrowLink(node, arrowLinkXML.@DESTINATION.toString());
					node.addArrowLink(arrowLink);
					(postProcessObject.arrowLinks as Array).push(arrowLink);
				}
			}
			
			// Icons
			for each (var iconsXML:XML in nodeXML.elements('icon')) {
				node.addIcon(GraphMind.i.applicationManager.getIconPath() + iconsXML.@BUILTIN + '.png');
			}
			
			var nodeChilds:XMLList = nodeXML.elements('node');
			for each (var childXML:XML in nodeChilds) {
				var childNode:NodeController = buildGrapMindNode(childXML, postProcessObject);
				node.addChildNode(childNode);
			}
			
			if (nodeXML.@FOLDED == 'true') {
				node.collapse();
			}
			
			if (nodeXML.elements('cloud').length() == 1) {
				node.enableCloud();
			}
			
			return node;
		}

	}
	
}