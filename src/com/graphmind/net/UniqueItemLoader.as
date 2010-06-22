package com.graphmind.net
{
	import com.graphmind.data.NodeData;
	
	import mx.collections.ArrayCollection;
	
	public class UniqueItemLoader
	{
		[Bindable]
		public static var itemTypes:ArrayCollection = new ArrayCollection([
			{label: "Node", data: NodeData.NODE},
			{label: "User", data: NodeData.USER},
			{label: "File", data: NodeData.FILE}
		]);
		
		public static function nodeTypeToServiceType(nodeType:String):String {
			var service_name:String = NodeData.NORMAL;
			switch (nodeType) {
				case NodeData.USER:
					service_name = 'user';
					break;
				case NodeData.NODE:
					service_name = 'node';
					break;
				case NodeData.FILE:
					service_name = 'file';
					break;
			}
			return service_name;
		}
		
	}
}