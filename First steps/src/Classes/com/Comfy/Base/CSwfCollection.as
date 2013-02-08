package
{
	
	
	import flash.net.*;
	import flash.events.*;
	import flash.display.*;
	import flash.utils.Timer;
    import flash.events.TimerEvent;
	import org.assetloader.*;
	import org.assetloader.core.*;
	import org.assetloader.base.*;
	import org.assetloader.loaders.*;
	import org.osflash.signals.Signal;
	import org.assetloader.signals.*;
	import org.assetloader.base.Param;
	import org.assetloader.core.IParam;
		
	public class CSwfCollection extends Sprite
	{
		
		private var _Scenes:Array;			//Scenes Array
		private var _Folder:String;	
		
		private var _CurrentScene:int;
		private var _LastScene:int;
		//private var _Loaded:Boolean; //depresed by Asaf 21sep2011
		private var _SReady:uint;
		
		private var _ScenesReady:Boolean; 
		private var _ScenesInLevel:uint //Array;
		
		
		//private var _ScenesIndexer:uint;
		//private var _LangToLoad:String;
		//private var _LevelToLoad:Number;
		
		public var _Story:CStoryHandler; //for override
		private var runningDepth:int; // the index of the current scene.
		private var _NotExclusiveRunning:Boolean;
		
		private var _Lang:String;
		private var _Level:int;
		private var _AssetsLists:Array; // [loaderID, Object(Scene or Sound), Object count,Object(Scene or Sound), Object count,...]
		private var _LocalSoundArray:Array
		
		protected var AssetsLoaders : AssentLoaderPlus
		protected var ScenesLoadersMonitor : StatsMonitorPlus;
		
		
		private var _SceneNumberToReady:uint;
		private var _ScenePercentToReady:Number;
		//private var _ScenesToReadyMonitor : StatsMonitorPlus;
		private var _ReadyConditions:Object;
		private var _ReadyConditionsRecorder:Object;
		private var _ScenesToReadyArray:Array;
		private var _failedIds:Array;
		
		private var _time:Date;
		
		public var OnReady:Signal;
		public var OnXmlLoaded:Signal;
		public var OnEnd:Signal;
		public var OnSceneReady:Signal;
		
		/**
		*
		* Constructor
		* 
		*/
		public function CSwfCollection()
		{
			
			_Folder       = "Animations" //    //by default ;/
			_Scenes       = new Array();
			_SReady       = 0;					//Number Scenes Ready 
			_CurrentScene = -1;
			_LastScene	  = _CurrentScene;
			_ScenesReady  = false;
			_NotExclusiveRunning = false; // indicate if there is scene that run over all scene
			//_Loaded       = false;
			
			_Lang = "";
			_Level = -1;
			_AssetsLists = new Array();
			_LocalSoundArray = new Array();
			AssetsLoaders = new AssentLoaderPlus("scenes");
			AssetsLoaders.onChildComplete.add(OnAssetsCompleteLoading);
			AssetsLoaders.onChildError.add(OnAssetsErrorLoading);
			AssetsLoaders.numConnections = 5 ;
			
			ScenesLoadersMonitor = new StatsMonitorPlus();
			ScenesLoadersMonitor.onProgress.add(Monitor_onProgress_handler);
			//ScenesLoadersMonitor.onOpen.add(Monitor_onOpen_handler);
			 
			_ReadyConditions = {ALL: false , SCENES:true , NUMBER:true , PERCENT:true};
			_ReadyConditionsRecorder = {ALL: false , SCENES:true , NUMBER:true , PERCENT:true};
			 
			OnReady = new Signal();
			OnXmlLoaded = new Signal();
			OnEnd = new Signal();
			OnSceneReady = new Signal();
			
		}
		
		/**
		*
		* Adding scene to the collection
		*
		*@param levels the game level which use the scene
		*@param sName scene name that wiil be use in the code during the game
		*
		*
		*/
		public function Add(levels:Array,sName:String,sFile:String,sSounds:Array):void
		{
			
			trace (this,"Add",sFile)
			var S:CScene = CreateNew(levels,sName,sFile,sSounds);
	
			//trace(this + ".Add Scene   Levels:"+ S.Levels +"   Name:"+S.Name+"   File:"+S.File ); //  Sounds:"+S.Sounds.Count);
			
			/*
			S.addEventListener("OnReady",S_SceneReady);
			S.addEventListener("OnPlay",S_ScenePlay);
			S.addEventListener("OnEnd",S_SceneEnd);
			*/
			S.OnReady.add(S_SceneReady);
			S.OnPlay.add(S_ScenePlay);
			S.OnEnd.add(S_SceneEnd);
			
			if (App.HasStoty)
			{
				//S.addEventListener("OnRegister",S_SceneReg);
				S.OnRegister.add(S_SceneReg);
			}
			
			_Scenes.push(S); // you should sort the scene for better searching!*/
		}
		
		/** @private **/
		private function CreateNew(levels:Array,sName:String,sFile:String,sSounds:Array):CScene
		{
		
			return new CScene(_Scenes.length,sName.toUpperCase(),sFile,sSounds,_Folder,levels);
			
			//(Id:Number,sName:String,sFile:String,sSounds:Array=null,folder:String = ".",levels:Array=[1,2,3],Main_MC:MovieClip=null)
		}
		
		
		/**
		*
		*
		*@param type avialble values "ALL","SCENES","PERCENT","NUMBER"
		*
		*/
		public function SetReadyCondition(type:String = "ALL" ,condition:String = ""):void
		{
			
			
			_ReadyConditions[type] = false ;
			_ReadyConditionsRecorder[type]=false;
			if (type != "ALL")
			{
				_ReadyConditions["ALL"] = true;
				_ReadyConditionsRecorder["ALL"]=true;
			}
			switch(type)
			{
				case "SCENES":
					
					_ScenesToReadyArray =  condition.toUpperCase().split(",");
					/*
					_ScenesToReadyMonitor = new StatsMonitorPlus(); 
					_ScenesToReadyMonitor.onComplete.add(Scn2Ready_onComplete_handler);
					
					for(var i:uint; i<_ScenesToReadyArray.length; i++)
					{
						if(ByName(_ScenesToReadyArray[i]) != -1)
						{
							_ScenesToReadyMonitor.add(_Scenes[i].SceneLoader)
						}
					}
					*/
					// need to prioritize all this scenes
					break;
				case "PERCENT":
					_ScenePercentToReady = Number(condition);  
					break;
				case "NUMBER":
					_SceneNumberToReady = uint(condition);
					break;
				case "ALL":
				default:
					_SceneNumberToReady = 0;
					break;
			}
		}
		
		/**
		*
		*start loading the scene acurding to the game current level and language
		*
		*
		*/
		public function Load(lang:String,level:Number=0):void
		{
			CDebug.Trace(this + " Loading Scenes("+_Scenes.length+")...[Lng: "+lang + ", Level: "+level+"]<---------------------");
			_time = new Date();
			
			AssetsLoaders.stop();
			_ScenesReady = false;
			StopAllScenes();
			CreateStory();
			
			
			for (var n:* in _ReadyConditions)
			{
				_ReadyConditions[n] = _ReadyConditionsRecorder[n];
				trace (n,_ReadyConditions[n]);
			}
			
			if(_Scenes.length > 0)		//no empty ?!!
			{
				_SReady = 0;
				var i:uint;
				var j:uint;
				var snd:CSound;
				var pos:uint
				var prio:Boolean = false;
				
				if (_Lang != lang)
				{
					_Lang = lang
					if(_LocalSoundArray.length)
					{
					trace("------------------- removing language----------------------------")
					//remove loader from assetsLoader and remove assets from objects
					
						for(i=0; i< _LocalSoundArray.length ; i++ )
						{
							RemoveLoaderFromQueue(SearchItemLoaderID( _LocalSoundArray[i]))
							if (_Level == level)
							{
								if(_LocalSoundArray[i].Type == ".mp3")
								{
									AddToQueue(_LocalSoundArray[i],"SOUND");
								}
								else
								{
									AddToQueue(_LocalSoundArray[i],"SWF");
								} 
							}
						}
					}
					
				}
				if (_Level != level)
				{
					trace (" -------------- Load: setting scene to for level ---------------")
					_ScenesInLevel = 0;

					for(i=0; i< _Scenes.length ; i++ )
					{
						if (_Scenes[i].InLevel(level))
						{
							_ScenesInLevel++
							CDebug.Trace(_Scenes[i].Name +" is in level "+level+"<---------------------")
							pos = AddToQueue(_Scenes[i],"BINARY")
							
							if(!_ReadyConditions["SCENES"] && _ScenesToReadyArray.indexOf(_Scenes[i].Name) != -1)
							{
								
								AssetsLoaders.prioritize(_AssetsLists[pos][0],false);
								prio = true
							}
							if (_Scenes[i].Sounds != null)
							{
								trace("Adding Scene Sounds to Queqe ")
								for(j = 0 ; j<_Scenes[i].Sounds.Count; j++)
								{
									
									snd = _Scenes[i].Sounds.GetSoundByIndex(j);
									trace(snd.Name)
									if(snd.Local)
										 _LocalSoundArray.push(snd);
									if( snd.Type == ".mp3")
									{
										pos = AddToQueue(snd,"SOUND");
									}
									else
									{
										pos = AddToQueue(snd,"SWF");
									}
									if (prio)
										AssetsLoaders.prioritize(_AssetsLists[pos][0],false);
								}
							}
							
						}
						else if(_AssetsLists.length)
						{
							trace(_Scenes[i].Name ,"is removed from _AssetsLists <---------------------")
							RemoveItemFromQueue(_Scenes[i])
							if (_Scenes[i].Sounds != null)
							{
								for(j = 0 ; j<_Scenes[i].Sounds.Count; j++)
								{
									snd = _Scenes[i].Sounds.GetSoundByIndex(j);
									RemoveItemFromQueue(snd)
									
								}
							}
						}
						prio = false;
						
					}
					_Level = level;
				}
				trace("---------- Load: search for loaded ------------------------")
				//now go over the list of loaders (AssetsLoader and the one that allresy loaded dispatch ready for them)
				
				var strID:String;
				var objArray:Array;
				var ldr:*;
				for(i=0 ; i<AssetsLoaders.loadedIds.length ; i++)
				{
					strID = AssetsLoaders.loadedIds[i];
					objArray = _AssetsLists[SearchLoaerByID(strID)];
					trace (this, "Load: setAssets for = ",strID)
					for (j=1; j<objArray.length ; j++)
					{
						
						if (strID.substr(0,7) == "Scenes.") 
						{
							
							ldr = AssetsLoaders.getLoader(strID) as BinaryLoader;
							objArray[j].SetAssets(ldr.bytes);
						}
						else if (strID.substring(strID.length-4,strID.length) == ".mp3")
						{
							
							ldr = AssetsLoaders.getLoader(strID) as SoundLoader;
							objArray[j].SetAssets(ldr.sound);
						}
						else
						{
							
							ldr = AssetsLoaders.getLoader(strID) as SWFLoader;
							objArray[j].SetAssets(ldr.swf);
						}
					}						
				}
				trace("---------- Load: Activate Failed Sound ------------------------")
				if (_failedIds != null )
				{
					for(i=0 ; i<_failedIds.length ; i++)
					{
						strID = _failedIds[i];
						trace (this, "Load: OnLoadError for = ",strID)
						if (strID.substr(0,7) == "Sounds.") 
						{
							trace (_AssetsLists[SearchLoaerByID(strID)])
							objArray = _AssetsLists[SearchLoaerByID(strID)];
							trace("objArray:",objArray," length=",objArray.length)
							for (j=1; j<objArray.length ; j+=2)
							{
								trace("objArray[j].Name:",objArray[j].Name)
								objArray[j].OnLoadError();
									
							}
						}		
					}
				}

				
				CDebug.Trace("Load "+AssetsLoaders.ids.length+" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"	)
				AssetsLoaders.start();
				
			}
			else
			{
				//_ScenesReady=true;
				_ReadyConditions.ALL = true;
				E_OnReady();
			}		
		}
		
		
		private function ParseLoaderId(obj:*):String // sould be CLoaderManger function
		{
			var str:String;
			switch(obj.toString())
			{
				
					
				case "CSound":
					
					str ="Sounds.";
					str += obj.Local? "local." : "global.";
					str += obj.File + obj.Type;
					break;
				case "CScene":
				default:
					str =  "Scenes."+obj.File;
					break;
			}
			return str;
		}
		
		private function ParsePath(obj:*):String  // sould be CLoaderManger function
		{
			var path:String;
			switch(obj.toString())
			{
				
				case "CSound":
					var UserLang:String = _Lang;
					var localSndFileExt:String = "_"+_Lang;   	// this consturcts the ending of the filename for localized versions.
					var localSndFolder:String = _Lang ; 		// local sound folder inside the sounds folder.
					//var path:String = App.FolderPath(App.SoundFolder) + "/"; // change by Asaf for reading sounds from CD
					path = App.StartDirURL + App.SoundFolder + "/";
					path += (obj.Local) ? localSndFolder +"/"+ obj.File+localSndFileExt + obj.Type : App.GLSoundFolder + "/" + obj.File + obj.Type;
					 //File+Type
					break;
				case "CScene":
				default:
					path = App.StartDirURL + obj.File; //App.FolderPath(_Folder )
					break;
			}
			return path;
		}
		
		
		
		//---------------------function CSoundFileCollection ---------------------------//
		
		public function AddToQueue(obj:*,loaderType:String):uint
		{
			
			
			var id:String = ParseLoaderId(obj);
			var url:String = ParsePath(obj);
			var pos =  SearchLoaerByID(id);
			var i:int;
			//CDebug.Trace (this+ " AddToQueue "+ id+ " URL:"+url)
			if (pos == -1)
			{
				pos = _AssetsLists.length;
				//var objArray:Array = new Array(obj)
				_AssetsLists[pos] = new Array(id,obj);
				AssetsLoaders.addLazy(id,url,loaderType);
				
			}
			else //if(_AssetsLists[pos][1].indexOf(obj) == -1)
			{
				i = _AssetsLists[pos].indexOf(obj)
				if(i == -1)
					_AssetsLists[pos].push(obj);
				/*
				else
					_AssetsLists[pos][i+1]++;*/
			}
			trace ("AddToQueue id=" +id+ "  _AssetsLists[pos]:" +_AssetsLists[pos])
			return pos;
			
			
		}
		
		
		public function RemoveItemFromQueue(obj:*):void
		{
			
			var pos:int = SearchItemLoaderIndex(obj);
			var i:int;
			var count:int;
			var id:String;
			trace ("RemoveItemFromQueue, item:"+obj.Name+" pos=",pos )
			if (pos != -1)
			{
				i = _AssetsLists[pos].indexOf(obj);
				/*
				count = _AssetsLists[pos][i+1];
				count-- 
				_AssetsLists[pos][i+1] = count
				trace ("RemoveItemFromQueue coun",count )*/
				if (count == 0)
				{
					_AssetsLists[pos].splice(i,1);
					obj.RemoveAssets();
				}				
				if (_AssetsLists[pos].length == 1)
				{
					trace ("removing loader",_AssetsLists[pos][0])
					id = _AssetsLists[pos][0]
					AssetsLoaders.remove(id);
					_AssetsLists.splice(pos,1);
					if (_failedIds != null )
					{
						_failedIds.splice(_failedIds.indexOf(id),1)
					}
					
				}
			}
		}
		
		public function RemoveLoaderFromQueue(id:String):void
		{
			
			var pos:int = SearchLoaerByID(id);
			var obj:*;
			//var i:uint = 1
			if (pos != -1)
			{
				while(_AssetsLists[pos].length>1)
				{
					/*
					obj = _AssetsLists[pos][i]
					obj.RemoveAssets();
					_AssetsLists[pos].splice(i,1);*/
					obj = _AssetsLists[pos].pop();
					obj.RemoveAssets();
				}
				_AssetsLists.splice(pos,1);
				AssetsLoaders.remove(id);
				if (_failedIds != null )
				{
					_failedIds.splice(_failedIds.indexOf(id),1)
				}
			}
		}
		
		private function SearchItemLoaderID(obj:*):String
		{
			for(var i:int=0; i<_AssetsLists.length;i++)
			{	
				
				if (_AssetsLists[i].indexOf(obj) != -1)
				{
					return _AssetsLists[i][0]; //LocalSndArray[i];
				}
			}
			return "";
		}
		
		
		private function SearchItemLoaderIndex(obj:*):int
		{
			for(var i:int=0; i<_AssetsLists.length;i++)
			{	
				if (_AssetsLists[i].indexOf(obj) != -1)
				{
					return i //LocalSndArray[i];
				}
			}
			return -1;
		}
		
		
		private function SearchLoaerByID(loaderID:String):int
		{
			for(var i:int=0; i<_AssetsLists.length;i++)
			{	
				if (_AssetsLists[i][0] == loaderID)
				{
					return i //LocalSndArray[i];
				}
			}
			return -1;
		}
		
		
		//------------------------------------------------------------------------------//
		/**
		*
		* this function is to be override by CSceneCollections.
		*
		*/
		public function CreateStory():void //empty function for override. // was public
		{
		}
		
		
		/**
		*
		*Play on of the scene animation if it is ready ealse it will priortize it.
		* 
		*@param nm Name of scene to play
		*@param frame the point to start the animation from could be number or label (string)
		*@param Exclusive this boolean value detriment whether the scene will be play along (true) or a layer over other scenes(false).
		*
		*/
		public function PlayScene(nm:String,frame:*=2,Exclusive:Boolean=true):void
		{
			trace(this, "PlayScene: with",nm ," Ready=",_Scenes[ByName(nm)].Ready )
			if (frame==null){
				frame=2
			}
			var Sceneid:int = ByName(nm);
			if(_Scenes[Sceneid].Ready)
			{
				if (Sceneid != -1){
					if (Sceneid != _CurrentScene)
					{
						if(_CurrentScene != -1 && Exclusive)
						{
							_Scenes[Sceneid].x= _Scenes[_CurrentScene].x;
							_Scenes[Sceneid].y= _Scenes[_CurrentScene].y;
							_Scenes[Sceneid].scaleX= _Scenes[_CurrentScene].scaleX;
							_Scenes[Sceneid].scaleY= _Scenes[_CurrentScene].scaleY;
						}
						addChild(_Scenes[Sceneid])
					}
					_Scenes[Sceneid].Play(frame,Exclusive);
				}
			}
			else 
			{
				var ldr:*
				ldr = AssetsLoaders.getLoader(SearchItemLoaderID(_Scenes[Sceneid]))
				if(!ldr.loaded)
					AssetsLoaders.prioritize( ldr.id);
				if (_Scenes[Sceneid].Sounds != null)
				{
					for(var j:uint = 0 ; j<_Scenes[Sceneid].Sounds.Count; j++)
					{
						ldr = AssetsLoaders.getLoader(SearchItemLoaderID(_Scenes[Sceneid].Sounds.GetSoundByIndex(j)))
						if (!ldr.loaded || !ldr.inProgress)
								AssetsLoaders.prioritize(ldr.id, false)
									
					}
				}
			}
		}
		
		/**
		*
		*
		* Stops the current scene that is playing (Exclusive).
		*
		*/
		public function StopScene():void
		{
			trace("[*CSwfCollection] stopScene");
			_Scenes[_CurrentScene].Stop();
		}
		
		/**
		*
		* Stops the all scene that is playing exclusive and not exclusive.
		*
		*/
		public function StopAllScenes():void
		{
			if (this.numChildren)
			{
				var n:int = this.numChildren-1;
				trace ("StopAllScenes :" ,n)
				while(n>-1)
				{
					if(this.getChildAt(n)is CScene)
					{
						var scn:* = this.getChildAt(n)
						if (scn.IsPlaying)
						{
							scn.Stop();
							trace ("StopAllScenes .Stoping",scn.Name,n)
						}
					trace (" StopAllScenes removing",scn.Name,n)
					this.removeChild(scn)
					}
				n--;
				}
			}
			_CurrentScene = -1 ;
			_LastScene	  = _CurrentScene;
			_NotExclusiveRunning = false;
			AssetsLoaders.stop();
		}
		
		/** @private **/
		private function ByName(sName:String):int // -- need to improve this search!
		{
			//trace ("ByName was called with ",sName," _Scenes.length=",_Scenes.length)
			var upper:String = sName.toUpperCase();
			for(var i:uint=0;i<_Scenes.length;i++)
			{
				if(_Scenes[i].Name.toUpperCase() == upper)
				{
					//trace ("ByName",i,_Scenes[i].Name.toUpperCase())
					return i;
				}
			}
			trace("Err " + this+".ByName("+upper+") Was Not Found !");
			return -1;			
		}
		
		/**
		*
		* Return the index of the heigher scene (visualy).
		* This is base on child attribute of dispaly object.
		*
		*/
		public function getHeightsScene ():int  // why public
		{
			trace ("getHeightsScene was called, numChildren= " + this.numChildren)
			if (this.numChildren)
			{
				var n:int = this.numChildren-1
				while (!(this.getChildAt(n)is CScene) ){
					n--
				}
				return n
			}
			return 0;
		}
		
		private function CheckReadyCondition():Boolean
		{
			for (var n:* in _ReadyConditions)
			{
				trace("CheckReadyCondition:" ,n,_ReadyConditions[n])
				if (!_ReadyConditions[n]) 
				{
					return false;
				}
			}
			return true;
		}
		
		private function CheckScenesReadyCondition():Boolean
		{
			for(var i:uint =0; i<_ScenesToReadyArray.length ;i++)
			{
				if (!_Scenes[ByName(_ScenesToReadyArray[i])].Ready)
					return false;
					
			}
			return true;
		}
		
		// --------------------------- Events Dispachers --------------------------------
		
		// TODO: add signal dispacher which had loading progrees data
		
		/*  !!!deprasing this function!!!
		public function LoadNextScene():void
		{
			trace ("LoadNextScene");
			var myMaxInterval:Timer;
			myMaxInterval =  new Timer(50, 1);
   			myMaxInterval.addEventListener(TimerEvent.TIMER, function(){_Scenes[_ScenesInLevel[_ScenesIndexer]].Load(_LangToLoad,_LevelToLoad);
														_ScenesIndexer++});
   			myMaxInterval.start();

		}*/
		
		/**
		*
		*Dispatch "OnReady" event when all scene is ready.
		*
		*/
		protected function E_OnReady():void // was change from public
		{
			var d:Date = new Date()
			if(CheckReadyCondition() && !_ScenesReady) //_ScenesReady)
			{
				_ScenesReady = true;
				runningDepth = getHeightsScene();
				OnReady.dispatch();
				CDebug.Trace("---------Raedy at : "+(d.time - _time.time)/1000 +"------------------");
			}
		}
		
		/**
		*
		*Dispatch "OnXmlLoaded" event when data recived from xml. to be use in sub-classes
		*
		*/
		protected function E_XMLLoaded():void
		{
		
			trace("Firing XML DONE");
			//var EventObject:Object = {target:this, type:'OnXmlLoaded'}; 
			//dispatchEvent(EventObject);
			//dispatchEvent(new Event("OnXmlLoaded"));
			OnXmlLoaded.dispatch();
		}
		
		
		
		// ---------------------------  Event Handler  ---------------------------------
		//onChildError	OnAssetsErrorLoading
		private function OnAssetsErrorLoading(signal:ErrorSignal = null, loader:ILoader = null):void
		{
			//CDebug.Trace(this+" OnAssetsErrorLoading "+loader.id)
			var pos:int = SearchLoaerByID(loader.id);
			var obj:*;
			var i:uint;
			
			if (_failedIds == null)
				_failedIds = new Array();
			_failedIds.push(loader.id);
			
			if (pos != -1)
			{
				for(i =1; i< _AssetsLists[pos].length;i++)
				{
					obj = _AssetsLists[pos][i]
					if (obj.toString() == "CSound") 
					{
						obj.OnLoadError()
					}
					/*
					else 
					{
						ldr = loader as BinaryLoader;
						obj.SetAssets(ldr.bytes);
					}*/
				}
				
				
			}
		}
		private function OnAssetsCompleteLoading(signal:LoaderSignal = null, loader:ILoader = null):void
		{
			CDebug.Trace(this+" OnAssetsCompleteLoading "+ loader.id)
			
			var pos:int = SearchLoaerByID(loader.id);
			//var AssetsArray:Array;
			var obj:*;
			var i:uint;
			var ldr:*;
			
			if (pos != -1)
			{
				//AssetsArray = _AssetsLists[pos][1]
				
				for(i =1; i< _AssetsLists[pos].length;i++)
				{
					obj = _AssetsLists[pos][i]
					if (obj.toString() == "CSound") 
					{
						if (obj.Type == ".mp3")
						{
							ldr = loader as SoundLoader;
							obj.SetAssets(ldr.sound);
						}
						else
						{
							ldr = loader as SWFLoader;
							obj.SetAssets(ldr.swf);
						}
					}
					else 
					{
						ldr = loader as BinaryLoader;
						obj.SetAssets(ldr.bytes);
					}
				}
				
				
			}
		}
		
		private function  Monitor_onProgress_handler(signal : ProgressSignal) : void
		{
			
			//trace(">>>>>>" + Math.ceil(signal.progress)+ "  "+Math.ceil(AssetsLoadersMonitor.stats.progress)+"  "  +Math.ceil(AssetsLoadersMonitor.stats.bytesTotal/1024 ))// + "% | " + Math.ceil(signal.bytesLoaded / 1024 /1024) + " mb of " + Math.ceil(signal.bytesTotal / 1024 /1024) + " mb")
			/*
			if (!_ReadyConditions.PERCENT)
			{
				if (Math.ceil(signal.progress) >= _ScenePercentToReady )
				{
					_ReadyConditions.PERCENT = true;
					E_OnReady()
				}
			}
			
			*/
		}
		
		/*
		private function Scn2Ready_onComplete_handler(signal : LoaderSignal, stats : ILoadStats) : void
		{
			
			//_ReadyConditions.SCENES = true;
			//E_OnReady();
		}
		*/
		
		protected function onProgress_handler(signal : LoaderSignal) : void
		{
			/*
			var dat:Number;
			var total:Number;
			var loaded:Number;
						
			var obj:Object =  signal.loader.params
			//trace ("bytesLoaded=" ,signal.loader.stats.bytesLoaded );
			//trace ("bytesTotal=" ,signal.loader.stats.bytesTotal );
			//trace ("progress =" ,signal.loader.stats.progress );
			loaded = signal.loader.stats.bytesLoaded
			total = signal.loader.stats.bytesTotal
			dat = signal.loader.stats.progress;
			for(var i:uint=0; i<_bars.length; i++)
			{
				if(_bars[i].ID == signal.loader.id)
				{
					_bars[i].updateBar(dat,loaded,total);
				}
			}
			*/
		}
		
		
		protected function onComplete_handler(signal : LoaderSignal, payload : *) : void
		{
			/*
			var loader : ILoader = signal.loader;
			// Do your clean up!
			removeListenersFromLoader(loader);
			//trace("onComplete_handler",signal.loader.id)
			
			for(var i:uint=0; i<_loaders.length; i++)
			{
				if(_loaders[i] == signal.loader)
				{
					var swf:MovieClip = payload as MovieClip;
					swf.scaleX = swf.scaleY = 0.15;
					//swf.width = 120;
					swf.y=20;
					swf.x=130*i;
					this.addChild(swf);
					swf.play();
				}
				
				
			}
			*/
		}
		
		
		/**
		*
		* Every scene that complete loading is calling this function.
		* we count the scene that are ready untill it equl the number of scenes in the level and 
		* then we call E_OnReady to dispach the "OnReady" Event.
		*
		*/
		protected function S_SceneReady(scn:CScene):void //event:Event):void // was change from public
		{
		
			var d:Date = new Date()
			_SReady++;
			
			OnSceneReady.dispatch(_SReady,_ScenesInLevel);
			CDebug.Trace(scn.Name +" Is Ready ("+_SReady +"/" +_ScenesInLevel+"/"+SceneCount+")")
			
			if ( !_ReadyConditions.SCENES)
			{
				_ReadyConditions.SCENES =  CheckScenesReadyCondition();				
			}
			
			if(!_ReadyConditions.PERCENT)
			{
				if (Math.ceil(_SReady*100/_ScenesInLevel)>=_ScenePercentToReady)
					_ReadyConditions.PERCENT = true;
			}
			
			if ((_SReady == _SceneNumberToReady && _SceneNumberToReady!=0 ) || (_SReady == _ScenesInLevel))
			{
				if(_SReady == _ScenesInLevel)
				{
					//_ScenesReady = true;
					_ReadyConditions.ALL = true;
					CDebug.Trace("---------ALL SCENES LOADED AT : "+(d.time - _time.time)/1000 +"------------------")
				}
				_ReadyConditions.NUMBER = true;
				
			}
			E_OnReady();
			
		}	
		
		/**
		*
		* When a scene start to play this function stops all other scenes. 
		*
		*/
		protected function S_ScenePlay(scn:CScene):void //event:Event)// was change from public
		{
			
			trace (".S_ScenePlay ", "-Name: "+scn.Name, "_CurrentScene=",_CurrentScene," event.target.Exclusive=",scn.Exclusive,typeof(scn.Exclusive)," _NotExclusiveRunning=", _NotExclusiveRunning)
			//var scn = event.target as CScene;
			
			if(_CurrentScene == -1){
				_CurrentScene = ByName(scn.Name) as int;
				//trace (".S_ScenePlay _CurrentScene =",_CurrentScene)
				//this.swapChildren(scn,this.getChildAt(getHeightsScene()))
				return;
			}
			
			if (scn.Exclusive){
				 
				if(scn.Name != _Scenes[_CurrentScene].Name)		//only if its not the same Scene
				{
					trace(".S_ScenePlay ", "swapping scenes!",_Scenes[_CurrentScene].Name )
					_Scenes[_CurrentScene].Stop();
					_LastScene = _CurrentScene;
					removeChild(_Scenes[_CurrentScene]);
					setChildIndex(scn,runningDepth);
					_CurrentScene = ByName(scn.Name) as int;
					
					
					//this.swapChildren(scn,this.getChildAt(runningDepth))
				}
			}else{
				trace (" Exclusive is false!",scn.Exclusive)
				var heighst:int = getHeightsScene() as int;
				
				if (_NotExclusiveRunning && (scn != this.getChildAt(heighst)))
				{
					CDebug.Trace("Swaping top scenes")
					var playingScn = this.getChildAt(heighst) as CScene;
					playingScn.Stop()
					this.swapChildren(scn,this.getChildAt(heighst))
					removeChild(playingScn);
				}
				else if (!(_NotExclusiveRunning))
				{
					
					_NotExclusiveRunning = true;
					runningDepth = heighst -1
					this.swapChildren(scn,this.getChildAt(heighst))
					this.swapChildren(_Scenes[_CurrentScene],this.getChildAt(runningDepth))
				
				}
			}
		
		}
		
		/*
		*
		* This function is handle the "End" event of each event
		* The "End" event helps tell us that an animation has finished and the game reached a point were another scene is needed.
		*
		*/
		public function S_SceneEnd(scn:CScene=null):void//event:Event):void // was change from public
		{		
		
		
			trace(this + ".S_SceneEnd: " +scn.Name);
			//dispatchEvent(new Event("OnEnd"));
			OnEnd.dispatch()
		}
		
		/**
		*
		* This function handle the "Register" event and pass the label name to the Story object
		*
		*/
		protected function S_SceneReg(scn:CScene=null):void // was change from public
		{
			//trace(this + ".S_SceneReg: " +event.target.Name) //+ " label: "+event.target.Label);
			_Story.Register(scn.Name);
		}
		
		// ---------------------- Getter and Setter -------------------------------------
		
		public function get CurrentScene():String{return _Scenes[_CurrentScene].Name;}
		public function get LastScene():String{return _Scenes[_LastScene].Name;}
		public function get ScenesList():Array {return _Scenes;}
		public function get Folder():String {return _Folder;}
		public function set Folder(fld:String):void { _Folder=fld;}
		//public function get Story():CStoryHandler{return _Story;}
		//public  function get CurrentStory(){return _Story.CurrentStory;}; // Added by Asaf Kuller
		public  function Scene(sName:String):CScene{return _Scenes[ByName(sName)];}
		public 	function get SceneCount():Number{return _Scenes.length;}
		public function get StatsSignal():ProgressSignal{return ScenesLoadersMonitor.onProgress;}
		
		// ------------------------------------------------------------------------------
		
		
	}
}