
package
{
	
	
	import flash.net.*;
	import flash.events.*;
	import flash.display.*;
	//import flash.display.Sprite;
	
	public class CSceneCollection extends CSwfCollection
	{		
		
		
		 
		private var _CurrentLevel:Number;
		private var _Lang:String;
		private var _ScenesReady:Boolean;	
		
		
		
		
		public function CSceneCollection()
		{
			trace ("CSceneCollection constractor was called");
			//super();
			//super(MainMC);
			_Lang          = "";					
			_CurrentLevel  = -1;			//no loaded yet so -1	
			
			
		}
		
		public function ReadXmlNode(Main:XMLList):void
		{
		
			trace(this , " ReadXmlNode \n",Main.@Folder);
			
			Folder =  Main.@Folder;
			
			if (App.IsExe){
				Folder  = App.FolderPath(Folder)
			}
			
			for(var i:uint=0; i< Main.children().length(); i++)
			{
				//trace(i,"------------------\n",Main.child("Scene")[i])
				ReadSceneXml(Main.child("Scene")[i]);
			}
			E_XMLLoaded();
		}
		
		private function ReadSceneXml(xScene:XML):void
		{
		
			
			var SoundsA:Array;
			
			var xSceneSounds:XMLList;
			
			var xSceneName:String;
			var xSceneFile:String;
			var xSceneVol:String;
			var xSceneLevel:Array;
			var _xRow:String;
			/*
			var _xSdName:String;
			var _xSdFile:String;
			var _xSdLocal:Boolean;
			var _xSdVol:Number;
			var _xSdType:String;
			*/
			xSceneName = xScene.child("Name").toString();
			xSceneFile = xScene.child("File").toString();
			xSceneLevel =  xScene.child("Levels").toString().split(",");
			xSceneVol = xScene.child("Vol").toString();
			
			xSceneSounds = xScene.Sounds;
			SoundsA = new Array();
			for(var i:uint =0; i <xSceneSounds.children().length() ; i++)
			{
				
				var obj:Object = new Object()
				obj["Name"]= xSceneSounds.child("Sound")[i].child("Name").toString();
				obj["File"] = xSceneSounds.child("Sound")[i].child("File").toString();
				obj["Local"]=(xSceneSounds.child("Sound")[i].child("Local").toString()=="True")?true:false;
				obj["Volume"]=xSceneSounds.child("Sound")[i].child("Vol".toString());
				obj["Type"]=xSceneSounds.child("Sound")[i].child("Type").toString();
				//trace (_xSdName,_xSdFile,_xSdLocal,_xSdVol, _xSdType)
				
				//SoundsA.push(_xSdName); //this is only untill we create sound objects.
				SoundsA.push(obj)//new CSoundDef(_xSdName,_xSdFile,_xSdVol,null,_xSdType,_xSdLocal));
				
				
			}
			
			Add(xSceneLevel,xSceneName,xSceneFile,SoundsA);
		}
		
		public override function Load(lang:String,level:Number=0):void
		{
			if(_CurrentLevel != level || _Lang  != lang)
			{
				_CurrentLevel = level;
				_Lang = lang;
				//super.Load(lang,level);
			}
			super.Load(lang,level);
			/*
			else
			{
				RestartStory() // added by Asaf - 31july08 - i need to restart story even if i don't need to reload land or level.
				_ScenesReady=true;
				E_OnReady();
			}*/
			
		}
		
		public function RestartStory():void
		{
			//to be overridden by myScenes
		}
		
	}
}
