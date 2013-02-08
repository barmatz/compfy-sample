package PsaduCantrol
{
	
	import flash.events.*;
	import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.display.StageDisplayState;
	import flash.system.Capabilities;
	import flash.system.LoaderContext;
	
	public class CExeCantrols extends EventDispatcher
	{
		
		
		private var _AppDir:Object;
		
		private var _Drives:Array;
		private var _DiskFound:Boolean;
		private var _SoundFolderExist:Boolean;
		private var _CDRom:String;
		private static var _Index:int;
		private var _Lang:String;
		
		private var TYPE:String ="Air";
		
		public function CExeCantrols()
		{
			trace("CExeCantrols was called");
			_Index = -1	
			//_AppDir = File.applicationDirectory;
			
		}
		
		public function GetDriveList():void
		{
			
			trace("CAirCantrols: GetDriveList was called");
			_Index = 0;	//restart index of drives
			//ssCore.FileSys.driveList({},{callback:FindDisk, scope:this});
			//_Drives = File.getRootDirectories();
			//NativeApplication.nativeApplication.addEventListener( Event.EXITING, onApplicationExit );
			//FindDisk();
			
		}
		
		public function CheckDirExist(path:String):Boolean
		{
			
				return true;
			
		}	
		
		
		
		private function FindDisk():void
		{
			
			/*
			var RoorDir:File 
			var identFolder:File 
   			
			for(var i:int=0 ; i < _Drives.length ;i++)
			{
				RoorDir=_Drives[i];
				identFolder= RoorDir.resolvePath(App.IDFolder);
				if (  CheckDiskExist(identFolder) )
				{
					
					_Index = i;
					_CDRom = _Drives[_Index].nativePath;
					DiskFound(true);
					return;
				}
			}
			*/
			NoDisk();
		}	
		
		
		
		private function CheckDiskExist(path:*):Boolean
		{
			
			if(path.exists && path.isDirectory)
				return true;
			else
				return false;		//keep searching
			
		}	
		
		
		
		public function CopyLangFolder(lang:String):void
		{
			
			trace ("CopyLangFolder called with:" + lang)
			trace (_CDRom + lang)
			/*
			var sourceFile:File =new File(_CDRom +lang)
			//sourceFile = sourceFile.resolvePath("EN"); ///VALLGRN_EN.mp3
			var destination:File =new File("file:///" + File.applicationDirectory.resolvePath(App.SoundFolder+ "/"+lang).nativePath); //
			trace("sourceFile: "+sourceFile.nativePath+"  destination: "+destination.nativePath)
			trace("sourceFile.exists:"+sourceFile.exists+ " destination.exists:"+destination.exists);
			sourceFile.copyToAsync(destination, false);
			sourceFile.addEventListener(Event.COMPLETE, CopyDone);
			sourceFile.addEventListener(IOErrorEvent.IO_ERROR, CopyFailed);	
			*/
		}
		
	// ----------- Screen Handler --------------------------------//
	
		public function ChangeRes(screenWidth:Number,screenHeight:Number):void
		{
			/*
			trace("------>",window, App.Game.stage.nativeWindow)
			var window:NativeWindow = App.Game.stage.nativeWindow
			if( flash.system.Capabilities.os.match("Windows") != null ){
				
				window.width = screenWidth;
				window.height = screenHeight;
				window.x = 0;
				window.y = 0;;
			} else {
				window.width  = screenWidth;
				window.height  = screenHeight - 23;
				window.x = (screenWidth - window.width) / 2;
				window.y = 23;
			}
			*/
		}
		public function KioskMode():void
		{
			App.Game.stage.scaleMode = StageScaleMode.EXACT_FIT;
			App.Game.stage.displayState = StageDisplayState.FULL_SCREEN;
		}
	
	
	// ------------------------------------------------------------//
		
		public function Quit():void
		{
			
			trace(this +".Quit ...");
			//NativeApplication.nativeApplication.exit();
			
		}
		
		public function onApplicationExit(event:Event = null):void
		{
			throw Error("The Game Is Closing!")
		}
		
		public function SetActivator():void
		{
			
			//NativeApplication.nativeApplication.activate();
		}
		
		public function Activate():void
		{
			
			//NativeApplication.nativeApplication.activate();
		}
		
		public function SystemLanguage():String 
		{
			
			return Capabilities.language;
		}
		
	// ------- Event Handler ---------------------- //
	
		private function CopyDone(event:Event):void
		{
			trace(" CopyDone was called with success");
			dispatchEvent(new Event("CopyFolderComplete"))
		}
		
		private function CopyFailed(event:Event):void
		{
			trace(" CopyFailed");
			dispatchEvent(new Event("CopyFolderFail"))
			
		}
	
	// ------- Event Dispachers ---------------------//
	
		private function DiskFound(found:Boolean):void
		{
			
			if(found)
			{
				_DiskFound = true;
				dispatchEvent(new Event("diskFound"))
				
			}
			else
				_DiskFound = false;
		}
		
		private function NoDisk()
		{
			
			trace(this + ".NoDisk Found");
			dispatchEvent(new Event("diskFoundFail"))
		}
		
		private function CheckFolder(Return_Obj:Object):void
		{
			
			if(Return_Obj.result == "TRUE")
			{
				trace(this + ".SoundFolder Exist "+_Lang);
				dispatchEvent(new Event("FolderExist"))
				// this shold stay in CGAME
				/*
					_SoundFolderExist= true;	
					App.UserLang = _Lang;
					App.Cookie.Save();
					_Menu_MC.LANGUAGE.Animation.doIfDirExist();
				*/
			}
			else
			{
				trace(this + ".SoundFolder Not Exist Copy Files ? =>"+_Lang);
				dispatchEvent(new Event("FolderNotExist"))
				/* should stay on CGame
				_Menu.HideMenuButtons();
				_Menu.Pages("PopUp").Text = "The files are not installed on your computer , Would you like to install them ?";
				_Menu.PlayScene("PopUp","open",false);
				*/
			}
		}	
		
		public function Trace(str:String):void
		{
			trace(">>>"+str)
		}
		
		
	
	// ------- Getter and Setter --------------------//
	
		public function get LContext():LoaderContext
		{
			var myLoaderContext:LoaderContext = new LoaderContext();
			return myLoaderContext;
		}
		
		public function get Type():String{return TYPE; }
		public function get ColorDepth():String{return "";}
		public function get CDDriver():String{return _CDRom;}
		public function get StartDir():String{return "";}
		public function get IsExe():Boolean{return false;} // swf can not run air commands if you use this class then you are running as air application.
		//  ExternalInterface.available = there is chamce this false whaen using Air
		
		
	}
}