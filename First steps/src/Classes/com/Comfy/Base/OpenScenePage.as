package
{
	
	import flash.display.*;
	
	public class OpenScenePage extends CScene
	{
		private var _Age:Number;
		private var _Level:Number;
		
		public function OpenScenePage(Main_MC:MovieClip,folder:String,level:Number,age:Number,sName:String,Id:Number,sFile:String)
		{
		
			super(Id,sName,sFile,null,folder,[0,1,2,3]);
			_Age = age;
			_Level = level;
		}
	
		public function get Level():Number{return _Level;}
		public function get Age():Number{return _Age;}
		public override function toString():String{return "OpenScenePage";}
	}
	
}