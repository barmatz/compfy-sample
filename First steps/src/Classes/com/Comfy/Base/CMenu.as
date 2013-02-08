package{
	
	import flash.net.*;
	import flash.events.*;
	import flash.ui.Mouse;
	import flash.display.*;
	
	import org.osflash.signals.Signal;
	 
	public class CMenu extends CSwfCollection
	{
		
		private var _Lang:String;
		private var _ScenesReady:Boolean;	
		private var _MenuReady:Boolean;
		private var _OpenScene:Boolean;
		private var _Main:CScene;
		private var _MainReady:Boolean;
		//private var _MainMC:MovieClip;
		private var _Folder:String;
		
		public var OnPlay:Signal;
		
		public function CMenu()
		{
			super();			
			_Lang = "EN";				//By Default
			_MainReady = false;
			_OpenScene = true;
			_Main =null;
			OnPlay = new Signal();
			
		}	
		
		public function ReadXmlNode(Main:XMLList):void
		{
			
			Folder =  Main.@Folder;
			//CDebug.Trace("CMENU ReadXmlNode Folder= "+Folder + " type:"+typeof(Folder))
			
			if (App.IsExe){
				//Folder  = App.FolderPath(Folder)
				//Folder  = "app:/"+Folder
			}
			
			for(var i:uint=0; i< Main.children().length(); i++)
			{			
				if (Main.child("Page")[i].@Name.toString().toUpperCase() == "MENU")
				{
					
					ReadMainNode(Main.child("Page")[i])
				}
				else
				{
	
					ReadPageNode(Main.child("Page")[i])
				}
				
			}
			
			_MenuReady = true;
			E_XMLLoaded();
		}	
		
		private function ReadMainNode(xMain:XML):void
		{
			var SoundsA:Array;
			var xMainSounds:XMLList;
			var xSound:XMLList;
			var xMainFile:String;	
			
			var _xSdFile:String;
			var _xSdLocal:Boolean;
			var _xSdVol:Number;
			var _xSdType:String;
			
			xMainFile = xMain.child("File");
			xSound = xMain.child("Sound");
		
			if(xSound != null)
			{
				SoundsA = new Array();
				
				for(var i:uint=0; i< xSound.length(); i++)
				{
					_xSdFile=  xSound[i].child("File").toString();
					_xSdVol=  Number(xSound[i].child("Vol"));
					_xSdType = xSound[i].child("Type").toString();
					SoundsA.push(new CSoundDef(_xSdFile,_xSdFile,_xSdVol,null,_xSdType,false));
				}
				
			}			
			CreateMainPage(Folder,"MENU",xMainFile,SoundsA); //can be overloaded*/
		}	
		
		private function ReadPageNode(xPage:XML):void
		{
		
			//CDebug.Trace("ReadPageNode");
			var xPageName:String;
			var xPageFile:String;
		
			switch(xPage.@Name.toString().toUpperCase())
			{
				case "OPENING":
					AddOpening(xPage);				//opening => age + level
					break;
				default:
					xPageName = xPage.@Name //.childNodes[0].childNodes[0].nodeValue;
					xPageFile = xPage.child("File");
					//(levels:Array,sName:String,sFile:String,sSounds:Array):void
					Add([0,1,2,3],xPageName,xPageFile,null);
					break;
			}
			//trace("ReadPageNode: Page Name:<==============================") //+xPageName+" File:"+xPageFile+" Vol:"+xPageVol + " Sounds:"+SoundsA);
		}
		
		
		
		private function CreateMainPage(fldr:String,sName:String,xMainFile:String,SoundsA:Array):void
		{
			//CDebug.Trace(this+"CreateMainPage");
						
			_Main =  new CScene(SceneCount,sName,xMainFile,SoundsA,fldr,[0,1,2,3]);
			_Main.OnReady.add(S_SceneReady)//S_MainMenuReady);
			_Main.OnPlay.add(S_ScenePlay);
			ScenesList.push(_Main); // <================== need to find out why menu is not part of the scenes array
		}
		
		
		
		private function AddOpening(xPage:XML):void
		{		
			var xPageName:String;
			var xPageFile:String;
			var xAge:Number;
			var xLevel:Number;
			
			xPageName = xPage.@Name.toString().toUpperCase();
			xPageFile = xPage.child("File")[0];
				xAge = Number(xPage.child("Age")[0])+1;
				xLevel = Number(xPage.child("Level")[0])+1;
			
			//
			var S:OpenScenePage = new OpenScenePage(null,Folder,xLevel,xAge,xPageName,ScenesList.length,xPageFile);
			
			trace(this + ".AddOpening   Level:"+ S.Level + "  Age:"+ S.Age +"   Name:"+S.Name+"   File:"+S.File);
			S.OnReady.add(S_SceneReady);
			S.OnPlay.add(S_ScenePlay);
			S.OnEnd.add(S_SceneEnd);
			ScenesList.push(S);
			//trace("AddOpening:<==============================")
		}
		
		public function Hide():void
		{
			//Mouse.hide();
			 StopAllScenes();
			//_Main.Stop();
			//StopScene();
		}	
		
		public  function HideMenuButtons():void
		{
			
			if(_Main.IsPlaying)
			{
				_Main.Stop();
			}
		}	
		
		public  function ShowMenuButtons():void
		{
			
			if(!_Main.IsPlaying)
			{
				_Main.Play(2,false);
			}
		}
		
		public function Pages(page:String):CScene{return Scene(page);}
		
		// ---------------- Event Dispachers -------------------------------
		
		public function Show():void
		{
	
			CDebug.Trace("CMenu Show " + _MainReady +" "+ _OpenScene);
			//if(_MainReady == true && _OpenScene == false)
			if(! _OpenScene )
			{	
			
						//buttons
				CDebug.Trace("Menu: popup Is:"+Pages("PopUp").IsPlaying);
				if(Pages("PopUp").IsPlaying)
				{
					Pages("PopUp").Stop();
				}
				PlayScene("shkufit",2);	//open shkufit
				PlayScene("MENU",2,false)
				Mouse.show();
				//var EventObject:Object = {target:this, type:'OnPlay'}; 
				//dispatchEvent(new Event('OnPlay'));
				OnPlay.dispatch();
			}
		}
		
		
		
		// ---------------- Event Handlers ---------------------------------
		
		/*
		private function S_MainMenuReady(event:Event):void
		{
		
			trace(this + ".S_MainMenuReady.++++++++++++++++++++++++++");
			_MainReady = true;
			Show();
		}*/
		//

		override public function S_SceneEnd(scn:CScene=null):void
		{
		
			CDebug.Trace(".CMENU: S_PageEnd: " +scn.Name + " _OpenScene ="+_OpenScene+" ++++++++++++++++++++++++++" );
			if(_OpenScene == true)
			{
				_OpenScene = false;
				Show();
			} 
		}	
		
		// ---------- Getter and Setter ------------------------------------------
		
		
		public function get Main():CScene {return _Main;}
		public function get OpenScene():Boolean{return _OpenScene;};
		
		public function set OpenScene(Bool:Boolean):void{ _OpenScene=Bool;}
	}
}