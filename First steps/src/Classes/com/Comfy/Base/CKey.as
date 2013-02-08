//CKey
//THE Key Object !
//writen by Asaf Kuller 26/1/09 based on Miko.A as2 class from 22/1/07
	// happy birthday Chumby!
package
{

	import flash.events.*;

	public class CKey extends CDefaultKey
	{
		private var _Code:int;
	
		public function CKey(k:int ,n:String,f:Function,arg:Object){
		
			super(n,f,arg);
			_Code = k;
		}
		
		/*
		public function Set(f:Function,arg:Object){
		
			this.removeEventListener('OnKeyPress',_Func);
			//EventObject = null;
			//EventObject = {target:this, type:'OnKeyPress', key:_Code, Arg:arg};
			_Func = f;
			this.addEventListener('OnKeyPress',_Func);
		}*/
	
		 public function Activate():void
		{
		
			super.Action(_Code);
		}
	
		public function get Code():Number{return _Code;}
		public override function toString():String{return "CKey";}
	}
}