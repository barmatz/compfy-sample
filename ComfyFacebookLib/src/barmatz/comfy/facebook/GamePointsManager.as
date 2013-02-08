package barmatz.comfy.facebook
{
	import barmatz.comfy.facebook.events.GamePointsManagerEvent;
	
	import flash.errors.IllegalOperationError;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class GamePointsManager
	{
		public static const MINIMUM_POINTS:uint = 100,
							INITIAL_POINTS:uint = 200,
							INVITE_POINTS:uint = 100,
							SHARE_POINTS:uint = 100,
							POINT_LOSS_PER_DAY:uint = 50;
		
		private static var timer:Timer,
						   _pointsChangeCallback:Function;
		
		public function GamePointsManager()
		{
			throw new IllegalOperationError("This is a static class and should not be initiated.");
		}
		
		public static function start():void
		{
			createTimer();
		}
		
		public static function stop():void
		{
			destroyTimer();
		}
		
		private static function createTimer():void
		{
			if(timer)
				destroyTimer();
			timer = new Timer(1000);
			timer.addEventListener(TimerEvent.TIMER, onTimer, false, 0, true);
			timer.start();
		}
		
		private static function destroyTimer():void
		{
			timer.stop();
			timer.addEventListener(TimerEvent.TIMER, onTimer, false, 0, true);
			timer = null
		}
		
		public static function validate():Boolean
		{
			JSBridge.log(points, MINIMUM_POINTS);
			return points >= MINIMUM_POINTS;
		}
		
		public static function updatePoints(points:uint):uint
		{
			return GamePointsManager.points += points;
		}
		
		public static function updateInvite():uint
		{
			return updatePoints(INVITE_POINTS);
		}
		
		public static function updateShare():uint
		{
			return updatePoints(SHARE_POINTS);
		}
		
		private static function onTimer(event:TimerEvent):void
		{
			points -= POINT_LOSS_PER_DAY / ((1000 * 60 * 24) / timer.delay);
		}
		
		public static function get points():Number
		{
			if(FacebookGameWrapper.sharedObject.data.points == null)
				points = INITIAL_POINTS;
			return FacebookGameWrapper.sharedObject.data.points;
		}
		
		public static function set points(value:Number):void
		{
			FacebookGameWrapper.sharedObject.data.points = Math.max(value, 0);
			FacebookGameWrapper.sharedObject.flush();
			if(pointsChangeCallback != null)
				pointsChangeCallback(new GamePointsManagerEvent(GamePointsManagerEvent.POINTS_CHANGE, false, false, points));
		}
		
		public static function get pointsChangeCallback():Function
		{
			return _pointsChangeCallback;
		}
		
		public static function set pointsChangeCallback(value:Function):void
		{
			_pointsChangeCallback = value;
		}
	}
}