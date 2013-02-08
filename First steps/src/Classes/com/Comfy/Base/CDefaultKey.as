

package
{
	
	import flash.events.*;
	

	//writen by Asaf Kuller 26/1/09 based on Miko.A as2 class from 22/1/07
	// happy birthday Chumby!
	
	public class CDefaultKey extends EventDispatcher
	{
		public var _KeyName:String;
		public var _Arg:Object;
		public var _Func:Function;
		public var _Obj:Object;
			
		public function CDefaultKey(n:String,f:Function,arg:Object)
		{
			if(n == null)
				n = "AnyKey";
			_KeyName = n;
			if (f==null)
				f=DefualtListner
			_Func = f;
			_Arg = arg;
			_Obj = this;
			
		}	
		
		public function UnRegister():void
		{
			
			//trace ("function UnRegister was called for = ",_KeyName);
			if (_Func != null){
				
				//_Obj.removeEventListener('OnKeyPress',_Func);
				this.removeEventListener('OnKeyPress',_Func);
				_Func = null;
			}
		}	
		public function Set(obj:Object,f:Function,arg:Object):void
		{
			//trace ("function set was called with obj = ",obj,"f=",f,"arg=",arg)
			UnRegister();
			//this.removeEventListener('OnKeyPress',_Func);
			if (f != null)
			{
				_Obj = obj;
				_Func = f;
				_Arg = arg;
				this.addEventListener('OnKeyPress',_Func);
			}
		}	
		
		public function Action(_Code:int):void
		{
		
			trace("Key > " +_KeyName);
			//EventObject.key = _Code; 
			dispatchEvent(new CKeyEventObject('OnKeyPress',_Code,_Arg));
		}
		
		private function DefualtListner():void
		{
			trace ("DefualtListner was called in",this)
		}
		
		public function get Name():String{return _KeyName;}
		public override function toString():String{return "CDefaultKey";}
	}
}