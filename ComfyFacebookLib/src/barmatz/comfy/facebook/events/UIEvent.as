package barmatz.comfy.facebook.events
{
	import flash.events.Event;
	
	public class UIEvent extends Event
	{
		public static const INVITE:String = "invite",
							SHARE:String = "share";
		
		public function UIEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event
		{
			return new UIEvent(type, bubbles, cancelable);
		}
		
		public override function toString():String
		{
			return formatToString("UIEvent", "type", "bubbles", "cancelable");
		}
	}
}