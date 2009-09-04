package com.graphmind.display
{
	import flash.events.MouseEvent;
	
	public class DraggableItem extends DisplayItem
	{
		public function DraggableItem()
		{
			super();
			this.addEventListener(MouseEvent.MOUSE_DOWN, _dragStart);
			this.addEventListener(MouseEvent.MOUSE_UP,   _dragEnd);
		}
		
		protected function _dragStart(event:MouseEvent):void {
			event.stopPropagation();
			this.startDrag(false);
		}
		
		protected function _dragEnd(event:MouseEvent):void {
			event.stopPropagation();
			this.stopDrag();
		}
		
	}
}