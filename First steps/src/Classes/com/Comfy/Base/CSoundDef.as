package
{
	
	public class CSoundDef extends CMidiDef
	{
	
		private var _CallBackFunc:Function;
		private var _cType:String;
		private var _cLocal:Boolean;
	
		public function CSoundDef(SName:String,SFile:String,SVolume:Number,SCallBackF:Function,SType:String,SLocal:Boolean){
		
			super(SName,SFile,SVolume);
			_CallBackFunc = SCallBackF;
			_cType = SType; 
			_cLocal = SLocal;
		}
	
		
		
		/*
		public override function Clone():CSoundDef
		{
			var temp:CSoundDef = new CSoundDef(_cName,_cFile,_cVolume,_CallBackFunc,_cType,_cLocal);
			return temp;
		}*/
	
		public function Set(sound:Object):void
		{
		
			
			Name = sound.Name;
			File = sound.File;
			Volume = sound.Volume;
			CallbackFunc = sound.CallbackFunc as Function;
			Type = sound.Type;
			Local = sound.Local;
			
		}
		
		public override function toString():String{return "CSoundDef";}	
		public function get Type():String{return _cType.toLowerCase();}
		public function set Type(typ:String):void{ _cType= typ.toLowerCase();}
		
		public function get CallbackFunc():Function{return _CallBackFunc;}
		public function set	CallbackFunc( CBFunc:Function):void{_CallBackFunc = CBFunc}
		
		public function get Local():Boolean{return _cLocal;}
		public function set Local(lcl:Boolean):void{_cLocal = lcl}		
	}
}
