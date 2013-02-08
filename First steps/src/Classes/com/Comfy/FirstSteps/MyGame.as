package {

	import flash.display.Sprite;
    import flash.display.DisplayObject;
	import flash.events.*;
	import flash.display.Stage;
	import flash.system.*;
	import com.adobe.crypto.*
	import org.osflash.signals.Signal;
	
	public class MyGame extends CGame {

		
		/*
		public var Key:Boolean;
		*/
		public var countinueToGame:Boolean;
		public var levelChosen :Boolean;
		protected var _FullScreenPlayMode = false;
		
		
		// -- first steps vars ------
		public var drumNum:Number;
		
		public var fluteNum:Number;
		public var trumpetNum:Number;
		public var pianoNum:Number;
		
		public var pauseNum:Number;
		public var gamadimNum:Number;
		
		public var snailyPhoneNum:Number;
		public var feelyPhoneNum:Number;
		public var jumpyNum:Number;
		public var buddyNum:Number;
		
		public var feelyNum:Number;
		public var comfyNum:Number;
		public var snailyNum:Number;
		
		public var moonNum:Number;
		public var sunNum:Number;
		
		public  var UILayerScene:String;
		public static var MYGAME:String = "f9c28d615" 
		/*
		
		private var loadXMLInterval:Number;
		private var _Path:Number;
		*/
		//------------------------------
		private var newLangArray:Array // the language that have new sonds and animations
		private var ProgreessBar:PBar 
		

		public function MyGame()
		{
			trace("MyGame counstractor was called");
			newLangArray = new Array ("HE","EN","ES","FR","UK","HU","SP","CN","PL","RU");
			countinueToGame = false;
			levelChosen = false;
			ProgreessBar = new PBar("SceneNumberProgress",300,30);
			addChild(ProgreessBar);

		}


		//  ------ Public Mathods --------------------------/
		public override function S_LevelReady():void
		{
		
			//CDebug.Trace(this + ".S_LevelReady (MyGAME)");
			_LevelLoaded = true;
			
			_Keyboard.RegisterGameKeys();
			
			_Menu.Hide();
			
			_Scences.PlayScene(StartingScene,2,true);			//game start !
			_Scences.PlayScene(UILayerScene,2,false);	
			
		}

		public override function LoadFromXml(path:String):void
		{

			trace("LoadFromXml in MyGame" +path);
			CDebug.Trace("LoadFromXml in MyGame "+path);
			/* 
			// this part is useful only with SWF Studio 
			clearInterval(loadXMLInterval);
			if (_CDRom == undefined and App.IsExe){
			loadXMLInterval=setInterval(Delegate.create(this,LoadFromXml) ,250,path)
			
			}else{*/
			//_XReader.Load(_global.baseURL+path);
			if  (App.Projector.Type == "Air" )
			{
				//setGameInfo(MD5.hash(App.Projector.INFO).indexOf(MYGAME));
			}
			
			super.LoadFromXml(path);
			//}

		}
		
		public override function CreateScenes():void
		{ //override ! for personal changes
			trace ("CreateScenes in MyGame was called")
			
			_Scences = new MyScenes();
			addChild(_Scences);
			_Scences.OnReady.add(S_LevelReady);
			_Scences.OnXmlLoaded.add(S_LevelXmlLoaded);
			_Scences.OnSceneReady.add(OnSceneReadyHandler);
			StartingScene = "song"; // "OpenScene";
			UILayerScene = "topFrame";
			_Scences.SetReadyCondition("NUMBER","10");
			
			
			
		}
		
		public override function CreateKeybord(_Scences:CSceneCollection,_Menu:CMenu):void //){ //override !
		{
			_Keyboard = new MyKeyboard(_Scences,_Menu);
			_Keyboard.addEventListener("OnReady",S_KeyboardReady);
			trace ("_Keyboard =",_Keyboard)
			_Keyboard.GetKeyboardLang();		//Load from Xml = Base Path\langs.xml
			
		}
		
		public override function CreateMenu():void
		{	
			trace ("CreateMenu in MyGame was called" )
			_Menu = new MyMenu();
			addChild(_Menu);
			_Menu.OnReady.add(S_MenuReady);
			_Menu.OnPlay.add(S_MenuPlay);
			_Menu.OnXmlLoaded.add(S_MenuXmlLoaded);
			_Menu.OnSceneReady.add(OnSceneReadyHandler);
			_Menu.SetReadyCondition("SCENES","OPENING,SHKUFIT,LANGUAGE");
					
		}
		
		
	
		
		public override function redMenuButton(event:Event):void
		{
			trace("redMenuButton in MyGame +++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
			//trace("redMenuButton in event ="+event)
			trace("redMenuButton in event.target ="+event.target)
			trace("redMenuButton levelChosen = "+levelChosen )
			trace("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
			countinueToGame = true
			
			if(levelChosen)
			{
				StartGame();
				
			}else{
				if(_Menu.CurrentScene != "LEVEL"){
					_Menu.PlayScene("Level");
				} 
				_Menu.HideMenuButtons()
			}
		}
		
		override public  function StartGame():void
		{			//can be OverRide !!!!  
			
			
			
			
			trace(this + ".Start Game: App.NeedCover = " + App.NeedCover);
			_Menu.HideMenuButtons();
			trace("Starting Game FirstTime? " + App.FirstTime)
			if(App.debugScene){
				//addChild(ProgreessBar);
				_Menu.PlayScene("shkufit","Loading");
			}else{
				if (App.NeedCover)
				{
					_Menu.PlayScene("Cover");    //load the select Level Page
				}
				else
				{
					//addChild(ProgreessBar);
					_Menu.PlayScene("shkufit","Loading");
					
				}
			}
		}
		
		override public function ShowMenu():void
		{
			ProgreessBar.Hide();
			super.ShowMenu()
		}
		//------------------ unique function for first steps -------------------/
		
		public function get NewAnimLang():Boolean
		{
			
			for (var i:uint=0;i<newLangArray.length;i++)
			{
				if (App.UserLang == newLangArray[i])
				{
					return true;
				}
			}
			return false;
	
		}
		
		public function OnSceneReadyHandler(ready:uint,total:uint):void
		{
			
			var dat:Number=Math.ceil(ready*100/total); 
			ProgreessBar.updateBar(dat,ready,total);
		}

		
		//----------------------------------------------------/
		
		private function setGameInfo(num:int):void
		{
			
			if (num < 0)
			{
				num-=1
				setGameInfo(num)
			}
			
		}
		
		public function set FullScreenPlayMode(val:Boolean):void
		{
			_FullScreenPlayMode = val;
			dispatchEvent(new Event("FullScreenModeChange"))
			
			

		}
		
		
		public function get FullScreenPlayMode():Boolean
		{
			return _FullScreenPlayMode;
		}
		

	}

}