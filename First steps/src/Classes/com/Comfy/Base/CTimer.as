package
{
	import flash.utils.Timer;
    import flash.events.TimerEvent;
    import flash.events.Event;

	public class CTimer
	{
		private var _array:Array;
		//private var _Delegate:Function;
		private var _pointer:Object;
		private var _OnStop:Boolean;
		
		
		public function CTimer()
		{ //p:Object){
			
			
			//_pointer = p;
			//_Delegate 	= null;
			_OnStop = false;
			_array = new Array();
		}
		
		public function New(Func:Function,inter:Number,repeat:int = 0):Timer
		{
			
			if(!_OnStop)
			{
				//_Delegate 	= Delegate.create(_pointer,Func);
				//var _id:Number = setInterval(_Delegate,inter,arguments[2],arguments[3],arguments[4],arguments[5],arguments[6],arguments[7]);
				 
				var timer:Timer =  new Timer(inter, repeat);
				timer.addEventListener(TimerEvent.TIMER, Func);
				_array.push(timer);
				timer.start();
				return timer
			}
			return null;
		}
	
		
		public function Start(_id:uint):void
		{
			if(!_OnStop)
			{
				_array[_id].start();
			}
		}
		
		public function StopAll():void
		{
			
			_OnStop = true;
			var count = _array.length;
			for(var i=0; i< count ;i++)
			{
				_array[0].reset();
				_array.pop();
			}
			_OnStop = false;
		}
		
		public function Stop(_id:uint):void
		{
			
				_array[_id].reset();
				_array.splice(_id,1);
				
			
		}
		public function toString():String{return "CTimer";}
	}



}