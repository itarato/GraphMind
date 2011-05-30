package com.graphmind.util {

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.controls.Image;
	import mx.controls.Text;
	import mx.events.FlexEvent;
	
	
	public class OSDMessage extends Canvas {
	   
    [Embed(source='assets/images/cross.gif')]
    private var _crossIcon:Class;
            
    /**
    * Static store of the named messages.
    * With names messages can be identified and removed through code.
    */
    public static var namedMessages:Object = {};
    
    private var _name:String;

    
		public function OSDMessage(text:String, level:String, sticky:Boolean = false, name:String = null) {
			super();
			
			var tx:Text = new Text();
			
			tx.addEventListener(FlexEvent.UPDATE_COMPLETE, function (event:FlexEvent):void {
				graphics.beginFill(OSD.getColorFromLevel(level), 0.8);
				graphics.drawRoundRect(0, 0, OSD.width, tx.measuredHeight + 2 * OSD.padding, 6, 6);
				graphics.endFill();
				width = OSD.width;
				height = tx.measuredHeight + 2 * OSD.padding;
			});
			
			addEventListener(MouseEvent.CLICK, function(e:Event):void{kill();});
			
			tx.setStyle('color', '#FFFFFF');
			tx.width = OSD.width - 2 * OSD.padding;
			tx.x = tx.y = OSD.padding;
			tx.text = text;
			addChild(tx);
			
			if (sticky) {
			  var icon:Image = new Image();
        icon.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void{kill();});
        icon.source = new _crossIcon;
        icon.x = OSD.width - 16;
        icon.y = 4;
        addChild(icon);
			}
			
			if (!sticky) {
			  countdown();
			}
			
			if (name) {
			  this._name = name;
			  if (!namedMessages.hasOwnProperty(name)) {
			    namedMessages[name] = new ArrayCollection();
			  }
			  (namedMessages[name] as ArrayCollection).addItem(this);
			}
		}
		
		
		/**
		 * On enter frame callback.
		 */
		public function onEnterFrame(event:Event):void {
			alpha -= 0.05;
			if (alpha <= 0.1) {
				kill();
			}
		}
		
		
		/**
		 * Scedule the item to disappear.
		 */
		public function countdown():void {
			setTimeout(function():void{addEventListener(Event.ENTER_FRAME, onEnterFrame);}, 3000);
		}
		
		
		/**
		 * Removes the object.
		 */
		protected function kill():void {
		  if (_name) {
        (namedMessages[_name] as ArrayCollection).removeItemAt((namedMessages[_name] as ArrayCollection).getItemIndex(this));
      }
		  removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			parent.removeChild(this); 
		}
		
		
		/**
		 * Remvoves all the messages with a specific tag.
		 */
		public static function removeNamedMessages(name:String):void {
      if (namedMessages.hasOwnProperty(name)) {
        while ((namedMessages[name] as ArrayCollection).length > 0) {
          var osdm:OSDMessage = (namedMessages[name] as ArrayCollection).getItemAt(0) as OSDMessage;
          osdm.kill();
        }
      }
    }

	}
	
}
