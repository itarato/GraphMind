package com.graphmind.view {
	
	import com.graphmind.display.IDrawable;
	
	import flash.errors.IllegalOperationError;
	
	import mx.core.UIComponent;

	public class StructureDrawer extends Drawer implements IDrawable {
		
		public function StructureDrawer(target:UIComponent) {
			super(target);
		}
		
		public function initGraphics():void {
			throw new IllegalOperationError('This is an abstract function.');
		}
		
		public function refreshGraphics():void {
			throw new IllegalOperationError('This is an abstract function.');
		}
		
		public function get x():Number {
			return 0;
		}
		
		public function set x(value:Number):void {
			;
		}
		
		public function get y():Number {
			return 0;
		}
		
		public function set y(value:Number):void {
			;
		}
		
		public function getWidth():uint {
			return 0;
		}
		
		public function getHeight():uint {
			return 0;
		}
		
		public function getUIComponent():UIComponent {
			return _target;
		}
		
		public function addUIElementToDisplayList(item:UIComponent):void {
			_target.addChild(item);
		}
	}
	
}