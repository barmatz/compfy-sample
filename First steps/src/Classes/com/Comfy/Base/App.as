//App static Class was created by Miko.A  7/12/07 and upgradete to AS3 by Asaf Kuller 4/2/2009
//APP this class need to hold all the global vars of the Application !
package
{
	
	
	//import AirCantrol.CExeCantrols; //- for publishing AIR Application
	//import StudioCantrol.CExeCantrols;  // - for publishing SWF Studio Application
	import PsaduCantrol.*  // -for debug an d creating swf files
	import flash.system.LoaderContext;
	
	public class App
	{
		public static var Game:*;
		
		public static var SoundFolder:String;
		public static var GLSoundFolder:String;
		public static var IDFolder:String;
		public static var MenuFolder:String;
		public static var Cookie:CCookie;
		public static var NeedCover:Boolean;
		public static var UserLang:String; // sound language
		public static var UILang:String; // interface language
		public static var AniFolder:String;
		public static var KeyboardLang:String;
		public static var LangArray:Array;
		public static var Level:uint;			//current Level Playing (loads from Cookie)
		public static var ScreenMode:Number;
		public static var IsExe:Boolean;
		
		public static var ProdBackgroundColor:Number;
		public static var ScreenHandler:CScreenMode;
		public static var GameName:String;
		public static var UILangObj:Object // this object countaine the exseption when UIlang != UserLang --Asaf,July 2007
							// for example {SP:ES,JP:EN} -we don't have cd menu in Japnese so it stay English
		public static var CDFolders:Array;
		public static var IdentDrive:String;
		public static var StartDir:String;
		public static var StartDirURL:String;
		
		public static var Projector:CExeCantrols;
		public static var ProjType:String;
		
		public static var HasStoty:Boolean;
		
		public static var debugScene:Boolean = false;
		
		
		
		public static function Create(gName:String,LangA:Array,UIObject:Object,prodBGColor:Number,useCover:Boolean,cdFolders:Array,story:Boolean=false)
		{
		
		///if(_global.baseURL==undefined) _global.baseURL = ""; //should be change to nativeApp from air
			
			// for debug:
			//CDebug.Create(true);
			//CDebug.Trace("App created!!!")
			
			
			//default value for lang and Level:
			Level = 1
			UserLang = "EN"
			
			GameName = gName;  
			SoundFolder = "Sounds";
			//AniFolder   = _global.baseURL + "Animations";
			GLSoundFolder = "GL";
			MenuFolder = "Menu";
			IDFolder = "ident/"+gName; 
			//IDFolder = "c:/";//ident/"+gName;
			Cookie = new CCookie(gName);
			Cookie.Load();
			
			Projector = new CExeCantrols();
			ProjType=Projector.Type;// "Studio" for swf studio / "Air" for Adobe Air
				
					
			LangArray = LangA;
			if(LangArray == null)
				LangArray = new Array("EN");
			
			UILangObj = UIObject
			setUILang();
		
			//-----------------------------------
			
			IsExe = Projector.IsExe;
			/*
			if(IsExe)debugScene = false;
			KeyboardLang = "X1033";	
			*/
			if(IsExe)
			{
				Projector.addEventListener ("diskFound",setCDDrive)
				Projector.GetDriveList();
				StartDir = Projector.StartDir;
				
			}
			else
			{
				IdentDrive = "";
				StartDir = "";
			}
			
			//------------------------------------
		
			NeedCover = useCover;
			ProdBackgroundColor = prodBGColor
			
			CDFolders = new Array();
			if (cdFolders != null ){
				CDFolders = cdFolders;
			}
			HasStoty = story;
		
		}
		
		public static function CopyFolder(lang:String,callBack:Function = null,FailedCallBack:Function = null):void
		{
			Projector.CopyLangFolder(lang)
			if (callBack != null)
			{
				Projector.addEventListener("CopyFolderComplete",callBack)
			}
			if (FailedCallBack != null)
			{
				Projector.addEventListener("CopyFolderFail",FailedCallBack)
			}
		}
		
		public static function setCDDrive(event:Object = null):void
		{
			
			IdentDrive = Projector.CDDriver
		}
	
		public static function setUILang():void
		{
	
			var uLang:String = UserLang;
			var exseptions:String
			trace("public static function setUILang, UILangObj:"+UILangObj)
			trace("UserLang: "+UserLang)
			if(UILangObj != null){
	
				for (exseptions in UILangObj){
					if (exseptions == uLang){
						UILang = UILangObj[exseptions]
						return;
					}
				}
			}
			UILang =UserLang
			trace("setUILang: UILang="+UILang)	
	}
		
		public static function IsCDFolder(dirPath:String):Boolean
		{
			/*
			if (IsExe and CDFolders.length>0){
				for (var i:Number = 0 ;i<CDFolders.length;i++){
					if (dirPath.toUpperCase()==CDFolders[i].toUpperCase()){return true;}
				}
				return false;
			}
			else
			{*/
				return false;
			//}
			
			
		}
	
		public static function FolderPath(dir:String):String
		{
			
			if (IsExe && IsCDFolder(dir) && IdentDrive != null){
				return IdentDrive+"/Game/" +dir
			}else{
				
				return StartDirURL+dir
				//return dir
			}
			
			
		}
		/*
		public static function SetActivator():void
		{
			CDebug.Trace("SetActivator was called")
			Projector.SetActivator();
		}
		
		public static function Activate():void
		{
			Projector.Activate();
		}*/
		
		// ---------------------- Screen function -------------------------//
		
		
		
		
		public static function InitScreen():void
		{
			ScreenHandler = new CScreenMode()
		}
		
		public static function changeResMode(mod:Number):void
		{
			if (ScreenHandler != null)
			{
				trace ("ScreenHandler is not null");
				ScreenHandler.changeResMode(mod);
			}
		}
		
		public static function changeRes(screenWidth:Number,screenHeight:Number):void
		{
			//CDebug.Trace("App changeRes was called with screenWidth="+screenWidth + " screenHeight="+screenHeight)
			 Projector.ChangeRes(screenWidth,screenHeight)
		}
		
		
		public static function KioskMode():void
		{
			Projector.KioskMode()
		}
		//-------------------------------------------------------------------------------
		public static function Quit(e:Object = null):void{ Projector.Quit();}
		
		public static function get LContext():LoaderContext{ return Projector.LContext;}
		
		public static function get ColorDepth():String{ return Projector.ColorDepth;}
		
		//-------------------------------------------------------------------------------
		
		public static function get maxScreenMode():Number{CDebug.Trace("maxScreenMode was called in app");return ScreenHandler.maxScreenMode;}	
		public static function get FirstTime():Boolean{return Cookie.FirstTime;}
		public static function toString():String{return "App";}
	}
}