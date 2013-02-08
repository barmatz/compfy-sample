package barmatz.comfy.facebook.events
{
	import flash.events.Event;
	
	public class GamePointsManagerEvent extends Event
	{
		public static const POINTS_CHANGE:String = "pointsChange";
		
		private var _points:Number; 
		
		public function GamePointsManagerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, ...args:*)
		{
			super(type, bubbles, cancelable);
			switch(type)
			{
				case POINTS_CHANGE:
					_points = args[0];
					break;
			}
		}
		
		public override function clone():Event
		{
			switch(type)
			{
				default:
					return new GamePointsManagerEvent(type, bubbles, cancelable);
					break;
				case POINTS_CHANGE:
					return new GamePointsManagerEvent(type, bubbles, cancelable, points);
					break;
			}
		}
		
		public override function toString():String
		{
			switch(type)
			{
				default:
					return formatToString("GamePointsManagerEvent", "type", "bubbles", "cancelable");
					break;
				case POINTS_CHANGE:
					return formatToString("GamePointsManagerEvent", "type", "bubbles", "cancelable", "points");
					break;
			}
		}
		
		public function get points():Number
		{
			return _points;	
		}
	}
}