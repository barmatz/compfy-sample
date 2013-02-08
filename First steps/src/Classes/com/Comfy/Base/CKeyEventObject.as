


package
{
	import flash.events.Event;
	
	public class CKeyEventObject extends Event
	{
		public static const ONKEYPRESS:String = "OnKeyPress"
		public var _Key:int;
		public var _Arg:*;
		
		
		//key:0, Arg:arg
		
		public function CKeyEventObject(type:String,key:int,arg:*)
		{
			super(type);
           _Key = key
		   _Arg = arg
		}
		
		public function set key(k:int):void
		{
			_Key=k;
		}
	}
}
/*

package eventsSystem
{

public class CustomEvent extends Event
{
public static const ONLOADED:String = “OnLoaded”; //———– Define your custom Event string constant
public var data:*; //————- Define a data variable of * type to hold any kind of data object
//———— Constructor
public function CustomEvent(type:String, data:*)
{
this.data= data;
super(type);
}
}
}


package Events{
import flash.events.event;
public class MyRemoteEvent extends Event{
public static const LOGIN_SUCCESS:String = "success";
public static const LOGIN_FAIL:String = "fail";
private var _userInf:Array;

public function MyRemoteEvent
(type:String,bubbles:Boolean,cancelable:Boolean,userInf:Array=null){
           super(type,bubbles,cancelable);
           _userInf = userInf;}

public function get userInfo():Array{
           return _userInf;
}
override public function clone():Event{
           return new CartItemEvent(type,bubbles,cancelable,_userInf);
}
}
}*/