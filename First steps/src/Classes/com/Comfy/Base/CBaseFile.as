//CBaseFile
//the most basic Class
//rewriten by Asaf Kuller 8/2/2009 based on  Miko.A  20/12/06
package
{
	
	import flash.display.*;
	
	public class CBaseFile extends Sprite
	{
		private var _cName:String;
		private var _cFile:String;
	
		public function CBaseFile(bName:String,bFile:String){
		
			_cName = bName.toUpperCase();
			_cFile = bFile;		
		}
	
	
		public function get Name():String {return _cName;}
		public function set Name(nm:String):void{_cName = nm;}
		
		public function get File():String{return _cFile;}
		public function set File(fname:String):void{_cFile = fname;}
		
		public function Clone():CBaseFile{return new CBaseFile(_cName,_cFile);}
		
		public override function toString():String{return "CBaseFile";}
	}
}