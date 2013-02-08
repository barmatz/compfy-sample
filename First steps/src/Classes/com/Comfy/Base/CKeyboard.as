package
{
	
	import flash.display.Sprite;
    import flash.display.DisplayObject;
	import flash.events.*;
	import flash.display.Stage;
	import flash.system.*;
	
	public class CKeyboard extends CKeyHandler
	{
		public var Scenes:CSceneCollection;		//dont change this pointer !
		public var Menu:CMenu;
	
		public function CKeyboard(SColl:CSceneCollection,menu:CMenu)
		{
			
			super();
			Menu = menu;
			Scenes = SColl;
			//trace ("Scenes = ",Scenes,"<-------------------------------------")
		}
	
		public function RandomNum(fromN:Number,ToN:Number):int
		{
			return  Math.floor( Math.random() * (ToN - fromN +1) + fromN);
		}
		
		public function RegisterGameKeys():void//need to be over lOaded
		{
		}
		public function  RegisterMenuKeys():void//need to be over lOaded
		{
		}
		
		public override function toString():String{return "CKeyboard";}
	}

}