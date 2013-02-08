package barmatz.comfy.facebook.events
{
	import flash.events.Event;
	
	public class FacebookGameWrapperEvent extends Event
	{
		public static const HAS_POINTS:String = "hasPoints",
							NO_POINTS:String = "noPoints";
		
		public function FacebookGameWrapperEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event
		{
			return new FacebookGameWrapperEvent(type, bubbles, cancelable);
		}
		
		public override function toString():String
		{
			return formatToString("FacebookGameWrapperEvent", "type", "bubbles", "cancelable");
		}
	}
}