package com.graphmind.net
{
	import com.graphmind.data.NodeType;
	
	import mx.collections.ArrayCollection;
	
	public class UniqueItemLoader
	{
		[Bindable]
		public static var itemTypes:ArrayCollection = new ArrayCollection([
			{label: "Node", data: NodeType.NODE},
			{label: "User", data: NodeType.USER},
			{label: "File", data: NodeType.FILE}
		]);
		
		public static function nodeTypeToServiceType(nodeType:String):String {
			var service_name:String = NodeType.NORMAL;
			switch (nodeType) {
				case NodeType.USER:
					service_name = 'user';
					break;
				case NodeType.NODE:
					service_name = 'node';
					break;
				case NodeType.FILE:
					service_name = 'file';
					break;
			}
			return service_name;
		}
		
	}
}