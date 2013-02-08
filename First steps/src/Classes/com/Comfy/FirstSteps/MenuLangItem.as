package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import org.osflash.signals.Signal;
	import flash.events.MouseEvent;
	
	public class MenuLangItem extends MovieClip{

		private var _Selected:Boolean;
		private var _Lang:String;
		public var Click:Signal;
		
		public function MenuLangItem (lang:String = "EN", index:Number = 0,select:Boolean=false, self:Boolean = false) {
			
			this.addEventListener(Event.ADDED,Init);
			this.y = this.y + this.height*index;
			Selected = select
			_Lang = lang
			Click = new Signal();
		}
		
		public function Init(e:Event = null)
		{
			
			gotoAndStop(_Lang);
			this.addEventListener(MouseEvent.CLICK,MouseEventHandler);
			this.addEventListener(MouseEvent.MOUSE_OVER,MouseEventHandler);
			this.addEventListener(MouseEvent.MOUSE_OUT,MouseEventHandler);
			this.buttonMode = true;
			
		}
		
		private function MouseEventHandler(event:MouseEvent = null):void
		{
			
			switch(event.type)
			{
				case "mouseOut":
					bg.gotoAndStop("idle")
					break;
				case "mouseOver":
					bg.gotoAndStop("over")
					break;
				case "click":
					Clicked()
					break;
			}
		}
		
		public function Clicked():void
		{
			Click.dispatch(_Lang)
		}
		
		public function set Selected (bl:Boolean):void
		{
			
			_Selected = bl;
			_Selected?checkBox.gotoAndStop("selected"):checkBox.gotoAndStop("idle")
		}
		
		public function get Select():Boolean  {return _Selected}
		
		

	}
	
}
