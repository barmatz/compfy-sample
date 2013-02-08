
package 
{
	
	import flash.events.*;
	import flash.display.Sprite;
	import flash.display.Stage;
	
	public class CGame extends Sprite
	{
		
		
		public  var StartingScene:String;
		
		
		
		
		public var _Scences:CSceneCollection;			// can be override
		public var _Menu:CMenu;						//can be override

		//private var _SoundFolderExist:Boolean;
		private var _XReader:CXmlReader;
		public var _Keyboard:CKeyboard;
		private var _KeysLoaded:Boolean;
		private var _LevelLoaded:Boolean;
		private var _LevelXmlLoaded:Boolean;
		private var _GameXmlLoaded:Boolean;
		private var _MenuLoaded:Boolean;
		private var _Lang:String;
		

		private var cError:CError
		var SoundFiles:CSoundsFilesCollection;
		
		public function CGame()
		{
			trace ("CGame counstractor was called");
			
			_GameXmlLoaded  = false;
			_LevelXmlLoaded = false;
			_KeysLoaded 	= false;
			_LevelLoaded 	= false;
			_MenuLoaded		= false;
		
			CreateScenes(); //CreateScenes(_Game_MC); //so it can be overloaded
			CreateMenu(); //_Menu_MC);		
			CreateKeybord(_Scences,_Menu);	//can be override/*/
			_XReader = new CXmlReader();
			_XReader.addEventListener("OnLoad" ,S_GameXmlLoaded);
			addEventListener(Event.ADDED_TO_STAGE,onAdded);
			
			//SoundFiles = CSoundsFilesCollection.getInstance();
			//addChild(SoundFiles);
		
			
		}
		
		
		
		public function LoadGame():void
		{
			
			CDebug.Trace("LoadGame was called")
			_LevelLoaded = false;
			trace(this + ".LoadGame Lang:"+App.UserLang);
			_Scences.Load(App.UserLang,App.Level);
		}	
		
		
		public function LoadFromXml(path:String):void
		{
			
			trace("LoadFromXml in CGame " + path);
			CDebug.Trace("LoadFromXml in CGame " + path);
			_XReader.Load(path);
		}	
		
		public function CreateScenes():void//(G_MC:MovieClip){	//can be overloaded for personal changes
		{
		
			_Scences = new CSceneCollection() //(G_MC);
			addChild(_Scences);
			
			_Scences.OnReady.add(S_LevelReady);
			_Scences.OnXmlLoaded.add(S_LevelXmlLoaded);
			StartingScene = "OpenScene";		//by Default
		}
		
		
		public function CreateMenu():void
		{	//can be overloaded for personal changes
		
			_Menu = new CMenu();
			addChild(_Menu);
			_Menu.OnReady.add(S_MenuReady);
			_Menu.OnPlay.add(S_MenuPlay);
			_Menu.OnXmlLoaded.add(S_MenuXmlLoaded);
		}
		
		
		
		public function CreateKeybord(_Scences:CSceneCollection,_Menu:CMenu):void //){
		{
		
			_Keyboard = new CKeyboard(_Scences,_Menu);			
			_Keyboard.addEventListener("OnReady",S_KeyboardReady);
			_Keyboard.GetKeyboardLang();		//Load from Xml = Base Path\langs.xml
		
		}
		
		
		
		private function StartMenu():void
		{
			
			CDebug.Trace (this+" StartMenu: _LevelXmlLoaded="+_LevelXmlLoaded+" _GameXmlLoaded="+ _GameXmlLoaded+" _MenuLoaded="+ _MenuLoaded+"  _KeysLoaded="+ _KeysLoaded )
			
			//if(_MenuLoaded && _KeysLoaded && _LevelXmlLoaded && _GameXmlLoaded && _DiskFound)
			if( _LevelXmlLoaded && _GameXmlLoaded && _MenuLoaded && _KeysLoaded   )
			{
				CDebug.Trace("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
				//LoadGame() // --- only for testing
				// once we done with the ,enu we can unnotes this:
				/*
				if(App.debugScene)
				{
					//_Menu.PlayScene("shkufit","Loading");
				}else{*/
					
					cError = CError.getInstance(); // not sure if this is the right place to create the error object
					_Menu.PlayScene("Opening");
				//}
				
			}
		}
		
		public function ShowMenu():void
		{
			_Menu.Show()
		}
		
		public  function StartGame():void
		{			//can be OverRide !!!!  
			trace(this + ".Start Game");
			
			
			
			trace(this + ".Start Game: App.NeedCover = " + App.NeedCover);
			_Menu.HideMenuButtons();
			trace("Starting Game FirstTime? " + App.FirstTime)
			if(App.debugScene){
				_Menu.PlayScene("shkufit","Loading");
			}else{
				if (App.NeedCover)
				{
					_Menu.PlayScene("Cover");    //load the select Level Page
				}
				else
				{
					
					_Menu.PlayScene("shkufit","Loading");
					
				}
			}
		}
		
		
		public function ChangeLang(lang:String):void
		{
			trace(this + ".ChangeLang was called with "+lang);
			CDebug.Trace(this + ".ChangeLang was called with "+lang);
			_Lang = lang;
			
			if(App.IsExe)
			{
				var FPath:String
				if (App.IsCDFolder(App.SoundFolder)){
					FPath = App.FolderPath(App.SoundFolder)+"/"+_Lang;
				}else{
					FPath = App.StartDir +"/"+App.SoundFolder+"/"+_Lang;
				}
				
				App.Projector.addEventListener("FolderExist",LangFolderExist)
				App.Projector.addEventListener("FolderNotExist",LangFolderNotExist)
				App.Projector.CheckDirExist(FPath)
								
			}else{
				ChangeLanguage(_Lang)
			}
		}
		
		private function ChangeLanguage(lang:String):void
		{
				//App.Projector.Trace ("CGame: ChangeLanguage")
				CDebug.Trace ("CGame: ChangeLanguage")
				App.UserLang = lang;
				App.Cookie.Save();
				App.setUILang();
				//MenuXML.Load()
				E_onLangChange()
		}
		
		
		private function DontCopyLangFolder(event:Event = null):void
		{
			
			trace (" DontCopyLangFolder !!!!!");
			trace ( "DontCopyLangFolder App.UserLang",App.UserLang);
			//_Menu.PlayScene("PopUp","close",false);
			//cError.ClosePopUp();
			if(!_Menu.OpenScene)
			{
				_Menu.ShowMenuButtons();
			}
		}
		
		
		private function CopyLangFolder(event:Event = null):void
		{
			trace (" CopyLangFolder!!!!!")
			cError.ThrowErr("Copying files , Please wait...")
			App.CopyFolder(_Lang,CopyDone,CopyFail)
		}
		
		private function CopyDone(event:Event = null)
		{
			trace ( "CopyDone was called with  ",event);
			cError.SetOK(null,true);
			cError.SetCancel();
			ChangeLanguage(_Lang);
			cError.ClosePopUp();
			_Menu.ShowMenuButtons();
		}
		
		private function CopyFail(event:Event = null)
		
		{
			trace ( "CopyFail was called with  ",event);
			trace ( "CopyFail App.UserLang",App.UserLang);
			cError.SetOK(null,true);
			cError.SetCancel();
			cError.ThrowErr("Copying failed "+ event.text)
			_Menu.ShowMenuButtons();	
		}
		
		
		// ------------------ Event Dispacher -----------------------
		
		private function LangFolderExist(event:Event):void
		{
			App.Projector.removeEventListener("FolderExist",LangFolderExist);
			App.Projector.removeEventListener("FolderNotExist",LangFolderNotExist);
			ChangeLanguage(_Lang)
		}
		
		private function LangFolderNotExist(event:Event):void
		{
			App.Projector.removeEventListener("FolderExist",LangFolderExist);
			App.Projector.removeEventListener("FolderNotExist",LangFolderNotExist);
			_Menu.HideMenuButtons();
					/*
					if (!"we have driver letter" || "we dont have cd in drive")
					{
						//enter cd()
						//return ;
					}
					//*/
					
			cError.SetOK(CopyLangFolder,false);
			cError.SetCancel(DontCopyLangFolder);
			cError.ThrowErr("The files are not installed on your computer , Would you like to install them ?");
			cError.OpenPopUp();
		}
		
		
		private function E_onLangChange():void
		{
			CDebug.Trace ("CGame: E_onLangChange")
			dispatchEvent(new Event("LangChange"))
		}
		// ------------------ Event Listners -----------------------------
		
		private function onAdded(event:Event):void
		{
			App.Game = this;
			App.InitScreen();
			trace("event.target",event.target)
			/*
			addChild(_Keys);
			addChild(_Scenes)
			LoadFromXml(GameXmlPath);*/
		}
		
		public function S_LevelXmlLoaded():void
		{
			trace(this + " Scenes XML Loaded!");
			_LevelXmlLoaded = true;
			StartMenu();	
		}	
		
		public function S_GameXmlLoaded(event:Event)
		{
			// this function is a good point to add children
			CDebug.Trace("GameXmlLoaded success");
			
			if (_XReader.Data.hasOwnProperty("Scenes")){
				//trace ('_Scences.ReadXmlNode(_XReader.Data.child("Scenes"))')
				//trace ('_Scences.????',_Scences,"\n-----------------")
				_Scences.ReadXmlNode(_XReader.Data.child("Scenes"))
			}
			
			if (_XReader.Data.hasOwnProperty("Menu")){
				
				_Menu.ReadXmlNode(_XReader.Data.child("Menu"));
			}
			_GameXmlLoaded = true;
			StartMenu();
			trace (" S_GameXmlLoaded, _GameXmlLoaded =",_GameXmlLoaded )
			
		}
		
		public function S_LevelReady():void
		{

			CDebug.Trace(this + ".S_LevelReady (CGAME 366)");
			_LevelLoaded = true;
			_Keyboard.RegisterGameKeys();
			_Menu.Hide();
			_Scences.PlayScene(StartingScene,2,true);			//game start !
			
		}
		
		// --- menu Event handlers 
		
		public function S_MenuXmlLoaded():void
		{
		
			CDebug.Trace(this +" S_MenuXmlLoaded!");
			_Menu.Load(App.UserLang);
		}	
		
		public function S_MenuReady():void
		{
			CDebug.Trace(this +" S_MenuReady!");
			_MenuLoaded = true;
			StartMenu();
			//_Menu.Show();
		}	
	
		public function S_MenuPlay():void
		{
		
			trace(this +".S_MenuPlay Stoped Game.");
			_Keyboard.RegisterMenuKeys();
			_Scences.StopAllScenes();
		}	
		
		// --- keyboard event handlers
		
		public function S_KeyboardReady(EventObject:Object){
		
			trace(this + " Keyboard Is ready");
			addChild(_Keyboard)
			_KeysLoaded = true;
			_Keyboard.Listen(true);
			StartMenu();
		}	
		
		public function redMenuButton(event:Event):void
		{
			trace("redMenuButton +++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
			/*
			this.countinueToGame = true
			if(this.levelChosen){*/
				StartGame();
			/*}else{
				if(_Menu.CurrentScene != "LEVEL"){
					_Menu.PlayScene("Level");
				} 
				_Menu.HideMenuButtons()
			}*/
		}
		
		// ------------------------------------------------------------
		
		public function get Keys():CKeyboard{return _Keyboard;}
		public function get Scenes():CSceneCollection{return _Scences;}
		public function get Menu():CMenu{return _Menu;};
		public override function toString():String{return "CGame";}
		//public function get Ready():Boolean{return _Ready;}
		
	}
	
}