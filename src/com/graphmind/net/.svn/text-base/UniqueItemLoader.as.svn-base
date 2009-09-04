package com.graphmind.net
{
	import com.graphmind.data.NodeItemData;
	
	import mx.collections.ArrayCollection;
	
	public class UniqueItemLoader
	{
		[Bindable]
		public static var itemTypes:ArrayCollection = new ArrayCollection([
			{label: "Node", data: NodeItemData.NODE},
			{label: "User", data: NodeItemData.USER},
			{label: "File", data: NodeItemData.FILE}
		]);
		
		public static function nodeTypeToServiceType(nodeType:String):String {
			var service_name:String = NodeItemData.NORMAL;
			switch (nodeType) {
				case NodeItemData.USER:
					service_name = 'user';
					break;
				case NodeItemData.NODE:
					service_name = 'node';
					break;
				case NodeItemData.FILE:
					service_name = 'file';
					break;
			}
			return service_name;
		}
		
	}
}