package
{
	
	
	import flash.net.*;
	import flash.events.*;
	import flash.display.*;
	import flash.utils.ByteArray;
	import flash.system.LoaderContext;
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
	
	import org.assetloader.loaders.BinaryLoader;
	import org.assetloader.signals.LoaderSignal;
	import org.assetloader.core.ILoadStats;
	
	
		
	public class CScene extends CBaseFile
	{
		
		
		private var _LevelUse:Array;
		private var _MC:MovieClip; // a referance to the scene swf.
		private var _cSounds:CSoundCollection;
		private var _Sound_Ready:Boolean;
		private var _Scene_Ready:Boolean;
		private var _Lang:String;
		private var _Ready:Boolean;
		private var _Playing:Boolean;
		private var _ID:int;
		//private var _timer:CTimer;
		
		//private var ByteLoader:URLLoader;
		private var myLoaderContext:LoaderContext;
		
		//private	var ByteLoader:BinaryLoader;

		private var ContentOnComplete:NativeSignal;
		private var ContentOnError:NativeSignal;
		private var ContentOnUnload:NativeSignal;
		public var OnPlay:Signal;
		public var OnReady:Signal;
		public var OnRegister:Signal;
		public var OnEnd:Signal;
		
		
		
		private var _SceneLoader:Loader;
		private var _CurrentLabel:Object;
		private var _Exclusive:Boolean;
		
		/**
		 * Constructor
		 * 
		 * @param Id each scene has it own monovalent identification number
		 * @param sName Name for the scene
		 * @param sFile File name (a swf) of the scene
		 * @param sSounds Array of sounds that are used in the scene
		 * @param folder The location of the scene file: Animation, Menu or somthing else.
		 * @param levels Which levels of the game the scene is used
		 * @param Main_MC a refrence that can be depresed
		 *	
		 *
		 */
		public function CScene(Id:int, sName:String ,sFile:String, sSounds:Array , folder:String  , levels:Array = null, Main_MC:MovieClip = null) 
		
		{
			//(Main_MC:MovieClip,folder:String,levels:Array,sName:String,Id:Number,sFile:String, sSounds:Array)
			
			
			super(sName,folder + "/" + sFile);				//Name,File- Animation
			/*
			ByteLoader = new BinaryLoader(new URLRequest(File))
			ByteLoader.onComplete.add(onBytesLoaded);
			ByteLoader.onStart.add(onBytesLoaderStart);
			*/
			
			myLoaderContext = App.LContext;
			/*
			//sinece myLoaderContext.allowLoadBytesCodeExecution is avialble only for air application 
			//I moved the creation of this object to the projector class (CExeCantrols)
			myLoaderContext = new LoaderContext();
			myLoaderContext.allowLoadBytesCodeExecution = true;
			*/
			_SceneLoader = new Loader(); 
			/*
			_SceneLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, OnCompleteLoading);
			_SceneLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_SceneLoader.contentLoaderInfo.addEventListener(Event.UNLOAD, unLoadHandler);
			*/
			ContentOnComplete = new NativeSignal(_SceneLoader.contentLoaderInfo,Event.COMPLETE,Event);
			ContentOnError= new NativeSignal(_SceneLoader.contentLoaderInfo,IOErrorEvent.IO_ERROR,IOErrorEvent);
			ContentOnUnload =  new NativeSignal(_SceneLoader.contentLoaderInfo,Event.UNLOAD,Event);
			
			ContentOnComplete.add(OnCompleteLoading);
			ContentOnError.add(ioErrorHandler);
			ContentOnUnload.add( unLoadHandler);
			
			_Sound_Ready 	= false;		//Sounds not loaded yet
			_Scene_Ready	= false;		//Movie not Loaded 
			_Ready			= false;		//Animation not Loaded
			_ID				= Id;
			_Lang 			= "";			//By Default
			_Playing = false;
			
			
			if (levels == null)
			{
				_LevelUse = new Array(1,2,3)
			}
			else
			{
				_LevelUse = levels;
			}
			
			_Exclusive=true;
			_CurrentLabel = 2;
			
			if (sSounds != null)
			{
				_cSounds = new CSoundCollection(Name+"_Sounds" ) //tempMC);	//Sounds r loaded with scence
				_cSounds.OnReady.add(S_SoundReady);	
				_cSounds.OnLangUnloded.add(S_SoundsUnLoaded);
				_cSounds.AddSounds(sSounds);
			}else{
				_Sound_Ready = true;
			}
			
			OnPlay = new Signal();
			OnReady = new Signal();
			OnRegister = new Signal();
			OnEnd = new Signal();
			
		}
		
		/**
		*
		* Load the scene if it is part of the current game level
		* If the language change it unload the sounds and reload the new language
		*
		* @param lang The lang that game will play . Could be the current langauge or the lang has been change to new language.
		* @param level The level the game will play
		*
		*/
		/*
		public function Load(lang:String,level:Number):void
		{
			trace(this,"Load function called with lang=",lang," level=",level)//, " _cSounds.Count=",_cSounds.Count);
			if(InLevel(level))
			{
				
				if(_Lang != lang && _cSounds != null)				//need to change Lang
				{
					
					trace(this + ".Load Changing Lang to "+lang +" from "+_Lang, "App.userLang="+App.UserLang)
					_Ready = false;
					_Lang = lang;
					ClearSounds();	
					return;
				}
				
				if(!_Ready)
				{
					
					if(!_Scene_Ready )//!ByteLoader.loaded || !ByteLoader.inProgress 
					{			//no need to realod Animation/
						
						CDebug.Trace("CScene Load, File="+File)
						ByteLoader.start();   //load(new URLRequest(File));
						//_SceneLoader.load(new URLRequest(File));
					}
						
					_cSounds.Load() //lang,_MC);	//Load Sounds
				}
				else
				{
					E_OnSReady();
				}
			}
			else
			{
				Clear();
			}
		}*/
		
		
		public function SetAssets(dataObj:*):void
		{
			trace(this, Name, "SetAssets HasAssets = "+HasAssets())
			if (HasAssets())
			{
				_Scene_Ready = true;
				E_OnSReady();
			}
			else
			{
				var dat: ByteArray = dataObj as ByteArray;
				onBytesLoaded(dat);
			}
			/*
			var type = typeof(dataObj)
			switch(type)
			{
				case "MovieClip":
					_MC = dataObj;
					break;
				case "ByteArray":
					onBytesLoaded(dataObj)
					break;
			}*/
		}
		
		public function RemoveAssets():void
		{
			// diffrent then Clear() becouse it does not unload sounds
			//_MC = null;
			_Scene_Ready = false;	
			_Ready = false;
			_SceneLoader.unload();
			
		}
		
		public function HasAssets():Boolean
		{
			if (_MC==null)
				return false;
			return true;
		}
		
		
		/**
		*
		* Check if the scene is part of a level
		*
		*/
		public function InLevel(level:uint):Boolean
		{
		
		
			if(_LevelUse == null)//all levels
				return true;
			for(var i=0; i< _LevelUse.length;i++)
			{
				if(_LevelUse[i] == level)
					return true;
			}
			return false;
		}
		
		/**
		*
		* Plays the scene's animation
		*
		*@param frameNum the frame label or number to start the animation from
		*@param Whether to play the animation along or as a layer on top other animations
		*
		*/
		public function Play(frameNum:Object=null,exclusive:Boolean = true):void
		{
		
			trace("play was called in", Name ,"frameNum =",frameNum,typeof(frameNum)," exclusive=",exclusive)
			
			if(! _Ready)
			{
				trace("Err " + this+ ".Play, The movie " +Name +" is Not loaded.");
				// TODO: SET HEGHER PRIORETY.
				return;
			}
			
			if (_MC != null) 
			{
				//if the frameNum is null we set it to play frame number 2
				//ssDebug.trace("frameNum="+ frameNum + " type:"+typeof(frameNum) + " _CurrentLabel="+_CurrentLabel)
				if(frameNum==null)
				{
					frameNum = _CurrentLabel;
				}
				_CurrentLabel = frameNum;
				_Exclusive=exclusive
				E_OnPlay();					//event To register the ImOnPLay !*/
				_MC.gotoAndPlay(frameNum);				//play
				
			}
			else
				trace("Err "+this +".Play No movie is loaded with name: "+Name);
		}
		
		/**
		*
		* Stops the scene's animation
		*
		*/
		public function Stop(){
			trace("[CScene]",Name ,"Stop()");
			if (_cSounds != null)
			{
				_cSounds.StopAllSounds();
			}
			_MC.gotoAndStop(1);
			_Playing = false;
		}
		
		/**
		*
		* UnLoad the animation
		*
		*/
		public function Clear():void
		{
			
			
			if(_Sound_Ready)
			{
				_cSounds.OnLangUnloded.remove(S_SoundsUnLoaded);
				ClearSounds()
			}
			_Ready = false;
			_SceneLoader.unload() //AndStop(true) //upgarade to air 1.5 and you can unmark this
			
			
		}
		
		/*
		//Add this function becouse loading need some frame work, this is very dirty quick solution.
		public function PrioritizeSounds():void
		{
			trace("PrioritizeSounds: _Sound_Ready=",_Sound_Ready)
			if (!_Sound_Ready)
			{
				_cSounds.Prioritize();
			}
		}*/
		
		/**
		*
		* unload all sounds animation
		* this will dispatch the unLoad
		*
		*/
		private function ClearSounds():void
		{
			_cSounds.StopAllSounds();
			_Sound_Ready = false;
			_cSounds.Unload();
		}
		
		// -------------- Event Dispachers --------------------------------------
		
		// Should be protected?
		public function E_OnSReady():void
		{
		
			trace(this + " E_OnSReady _Sound_Ready="+_Sound_Ready + " _Scene_Ready="+_Scene_Ready )
			if(_Sound_Ready && _Scene_Ready) //soundCollection and Animation
			{
				_Ready = true;
				//dispatchEvent(new Event("OnReady"));
				OnReady.dispatch(this)
			}
			/*
			else if (!_Sound_Ready && !_cSounds.InProgress && !_cSounds.Loaded)
			{
				//trace("here")
				_cSounds.Load()
			}*/
		}
		
		// Should be protected?
		public function E_OnPlay():void
		{
		
			_Playing = true;
			//dispatchEvent(new Event("OnPlay")); 
			OnPlay.dispatch(this);
		}
		
		
		/**
		*
		* 
		*
		*/
		// Should be protected?
		public function End():void
		{
		
			(this + ".EndScene "+Name);
			//dispatchEvent(new Event("OnEnd")); 
			OnEnd.dispatch(this)
		}
		
		
		/**
		*
		*this function is for game with story, it register the label to return to in the story
		*
		*@param lbl the frame label that scenes animation will start from next time it will be played.
		*
		*/
		public function Register(lbl:String)
		{
		
			trace ("Register was called with "+lbl)
			if(lbl != "" || lbl!= null)
			{
				_CurrentLabel = lbl;
			}
			//dispatchEvent(new Event("OnRegister"));
			OnRegister.dispatch(this)
		}
		
		// -------------- Event Handlers ----------------------------------------
		
		//
		
		//why public?
		public function S_SoundReady():void //(EventObject:Object):void
		{
			trace(this + " S_SoundReady: _Sound_Ready="+_Sound_Ready + " _Scene_Ready="+_Scene_Ready );
			_Sound_Ready = true;
			E_OnSReady();
		}
	 
	 	//why public?
		public function OnCompleteLoading(event:Event):void
		{
		
			//event from the _SceneLoader:MovieClipLoader
			//trace("CScene = Animation Loaded = " + mc);
			trace(this + " onCompleteLoading: _Sound_Ready="+_Sound_Ready + " _Scene_Ready="+_Scene_Ready +"~~~~~~~~~~~~~~~~~~~~~~~");
			trace ("onCompleteLoading",event.target.content);
			//CDebug.Trace("CScene onCompleteLoading");
			_MC = event.target.content
			addChild(_SceneLoader);
			_Scene_Ready = true;
			E_OnSReady();
		}
		
		/*
		private function onBytesLoaderStart(signal:LoaderSignal):void
		{
			CDebug.Trace(this+" onBytesLoaderStart")
			if (_Lang == "" || _Lang != App.UserLang)
			{
				_Lang = App.UserLang;
				if (_cSounds != null)
				{
					_Ready = false;
					ClearSounds();
				}
				
			}
		}*/
		
		/** @private **/
		
		private function onBytesLoaded (data:ByteArray):void//evt:Event):void
		{
			trace(this,Name,"onBytesLoaded")
			_SceneLoader.loadBytes (data,myLoaderContext);
		}
		
		
		/** @private **/
		private function ioErrorHandler(event:IOErrorEvent):void 
		{
			//CDebug.Trace("CScene: ioErrorHandler: " + event);
        }
		/** @private **/
		 private function unLoadHandler(event:Event):void 
		 {
            trace(this, Name, "unLoadHandler: " + event);
			
			//ContentOnComplete.remove(OnCompleteLoading);
			//ContentOnError.remove(ioErrorHandler);
			//ContentOnUnload.remove( unLoadHandler);
			
			removeChild(_SceneLoader);
			_MC = null;
			_Scene_Ready = false;
			//ClearSounds();
			
        }
		
		/** @private **/
		private function S_SoundsUnLoaded():void
		{
			//Load(_Lang,App.Level)
		}
		
		//--------------- GET FUNCTION -------------------------------------------
		
		//public function get SceneLoader():BinaryLoader{return ByteLoader;}
		public function get sceneMC():MovieClip{return _MC};	
		public function get CurrentLabel():Object{return _CurrentLabel;}
		public function get ID():Number{return _ID;}
		public function get Sounds():CSoundCollection{return _cSounds;}
		//public function get Timer():CTimer{return _timer;}
		public function get Levels():Array{return _LevelUse;}
		public function get Exclusive():Boolean{return _Exclusive;}
		public function get IsPlaying():Boolean{return _Playing;}
		public function get Ready():Boolean{return _Ready;}
		public function get Lang():String{return _Lang;}
		public override function toString():String{return "CScene";} //typeof(obj)
		
		
	}
}