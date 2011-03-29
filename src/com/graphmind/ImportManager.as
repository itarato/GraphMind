package com.graphmind {
  
	import com.graphmind.data.NodeType;
	import com.graphmind.display.NodeViewController;
	import com.graphmind.display.TreeArrowLink;
	import com.graphmind.factory.NodeFactory;
	import com.graphmind.util.Log;
	import com.kitten.network.Connection;
	
	
	public class ImportManager {
		
		public static function importNodesFromDrupalResponse(response:Object):NodeViewController {
		  var rootNode:NodeViewController;
		  var is_valid_mm_xml:Boolean = false;
      var body:String = response.body.toString();
      if (body.length > 0) {
        var xmlData:XML = new XML(body);
        var nodes:XML = xmlData.child('node')[0];
        is_valid_mm_xml = nodes !== null;
      }
        
      if (is_valid_mm_xml) {
        // Subtree
        var importedBaseNode:NodeViewController = ImportManager.importMapFromString(body);
        rootNode = importedBaseNode;
      } else {
        // New node
        // ! Removed original data object: result.result.
        // This caused a mailformed export string.
        rootNode = NodeFactory.createNode(
          {},
          NodeType.NODE,
          null,
          response.title
        );
      }
      
      return rootNode;
		}
		
		
		public static function importMapFromString(stringData:String):NodeViewController {
			var xmlData:XML = new XML(stringData);
			
			var postProcessObject:Object = new Object();
			postProcessObject.arrowLinks = new Array();
			
			var _baseNode:NodeViewController = buildGrapMindNode(xmlData.child('node')[0], postProcessObject);
			
			// Post process arrow links
			for each (var arrowLink:TreeArrowLink in postProcessObject.arrowLinks) {
				if (!arrowLink.findTargetNode()) {
					Log.error('Import - arrow links - node not found.');
				}
			}
			
			return _baseNode;
		}
		
		
		public static function buildGrapMindNode(nodeXML:XML, postProcessObject:Object):NodeViewController {
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
			var conn:Connection = null;
			if (nodeXML.site) {
//				conn = SiteConnection.createSiteConnection(
//					unescape(nodeXML.site.@URL),
//					unescape(nodeXML.site.@USERNAME)
//				);
        //trace('Target: <' + unescape(nodeXML.site.@URL) + '>');
        conn = new Connection(unescape(nodeXML.site.@URL));
        ConnectionController.addConnection(conn);
			}
			
			var node:NodeViewController = NodeFactory.createNode(
			  attributes,
			  nodeXML.@TYPE ? nodeXML.@TYPE : NodeType.NORMAL,
			  conn,
			  rawTitle.length > 0 ? rawTitle : htmlTitle
			);
			node.nodeData.created  = Number(nodeXML.@CREATED);
			node.nodeData.updated = Number(nodeXML.@MODIFIED);
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
				node.addIcon(ApplicationController.getIconPath() + iconsXML.@BUILTIN + '.png');
			}
			
			var nodeChilds:XMLList = nodeXML.elements('node');
			for each (var childXML:XML in nodeChilds) {
				var childNode:NodeViewController = buildGrapMindNode(childXML, postProcessObject);
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
