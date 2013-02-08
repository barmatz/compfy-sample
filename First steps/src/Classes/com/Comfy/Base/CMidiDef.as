
package
{


	public class CMidiDef extends CBaseFile{
	
		private var _cVolume:Number;
	
		public function CMidiDef(SName:String,SFile:String,SVolume:Number){
	
			super(SName,SFile);		
				_cVolume = SVolume;
	}
	
		public function get Volume():Number{return _cVolume;}
		public function set Volume(vol:Number):void{ _cVolume=vol}
		//public override function Clone():CMidiDef{return new CMidiDef(Name,File,_cVolume);}
		public override function toString():String{return "CMidiDef";}	
	}
}