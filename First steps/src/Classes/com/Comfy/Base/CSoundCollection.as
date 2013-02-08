//CSoundCollection
//created Asaf Kuller 17/2/2009 based on Miko.A  20/12/06

package
{

	import flash.display.*;
	import flash.events.*;
	import flash.utils.Dictionary;
	
	import org.osflash.signals.*;
	import org.osflash.signals.natives.*;
	import org.assetloader.*;
	import org.assetloader.core.*;
	import org.assetloader.signals.*;
	
	
	public class CSoundCollection extends Sprite
	{
	
		public var _Sounds:Array;				//CSound
		public var _FCounter:uint;		//File Counter
		public var _SoundIndexser:uint
		public var OnReady:Signal;
		public var OnLangUnloded:Signal;
		private var _Name:String;
		//private var _SoundLoaderMonitor:StatsMonitorPlus;
		//private var _SoundFilesList:CSoundsFilesCollection
		private var _Loaded:Boolean
		private var _InProgress:Boolean
		
		
	
		public function CSoundCollection(CollectionName:String = "Sound Collection") //SceneMC:MovieClip)
		{			
	
			//mx.events.EventDispatcher.initialize(this);
			_FCounter =0;							//Count the files that loaded
			//_Sound_MC = SceneMC.createEmptyMovieClip("SoundsMC",2);
			_Sounds = new Array();
			_Name = CollectionName
			
			_InProgress = false;
			_Loaded = false;
			
			OnReady = new Signal();
			OnLangUnloded = new Signal();
			
			//_SoundLoaderMonitor = new StatsMonitorPlus();
			// _SoundLoaderMonitor.onComplete.add(S_OnReady}); 
			//_SoundLoaderMonitor.onChildComplete.add(S_SoundReady);
			//_SoundLoaderMonitor.onChildError.add(S_SoundReady);
			//_SoundFilesList = CSoundsFilesCollection.getInstance()
			
		}            
		/*
		public function Load():void //lang:String,MC_Sound:MovieClip)
		{			
			trace (this,"Load _Sounds.length=",_Sounds.length," _SoundLoaderMonitor.numLoaders="+ _SoundLoaderMonitor.numLoaders)
			if(_Sounds.length != 0)
			{
				//_SoundLoader.start();
				
				for(var j:uint=0; j<_Sounds.length; j++)
				{
					var loader:ILoader =_Sounds[j].InitSound()
					
					if (!_SoundLoaderMonitor.hasLoader(loader) && loader !=null)
					{
						_SoundLoaderMonitor.add (loader);
					}
					if (loader.loaded)
					{
						S_SoundReady();
					}
				}
				
				
				var startNow:Boolean;
				
				for (var i:int = _SoundLoaderMonitor.numLoaders-1 ; i> -1 ; i-- )
				{
					startNow =  (i==0)?true:false;
					if (!_SoundLoaderMonitor.Loaders[i].loaded || !_SoundLoaderMonitor.Loaders[i].inProgress)
						_SoundFilesList.SoundsLoader.prioritize(_SoundLoaderMonitor.Loaders[i].id, startNow);
					else
						CDebug.Trace("here")
					
				}
				_InProgress = true;
				
			}
			else
			{
				
				E_OnReady();
			}
		}*/

		public function AddSounds(sounds:Array):void
		{
	
			for(var i:uint=0;i<sounds.length;i++)
				Add(sounds[i]);
		}
	
		private function Add(SObj:Object):void
		{
			// TODO: add some way to set priorety of each sound
			//trace ("Add was called","_Sounds.length",_Sounds.length)
			if (SearchByName(SObj.Name) == -1)
			{
				var sound:CSound = new CSound(_Sounds.length,SObj.Name,SObj.File,SObj.Volume,SObj.CallbackFunc,SObj.Type,SObj.Local);		//create the object		
				
				//sound.addEventListener("OnReady",S_SoundReady);	//Listen to it
				sound.OnReady.add(S_SoundReady)
				
				_Sounds.push(sound); //add to list
				
			}
			
		}
		/*
		public function AddLoaderToMonitor(loader:ILoader):void
		{
			if (!_SoundLoaderMonitor.hasLoader(loader))
				{
					_SoundLoaderMonitor.add(loader);
				}
		}
		*/
		 
		public function Clear():void
		{
			while (_Sounds.length)
			{
				var snd:CSound = _Sounds.shift();
				snd.Clear();
				snd=null;
			}
			
			//_SoundLoaderMonitor.destroy();
			_FCounter=0;
 			E_OnLangUnloded();
		}
		
		public function RemoveListners():void
		{
			OnReady.removeAll();
			OnLangUnloded.removeAll();
		}
		
		//Add this function becouse loading need some frame work, this is very dirty quick solution.
		/*
		public function Prioritize():void
		{
			for (var i:int = _SoundLoaderMonitor.numLoaders-1 ; i> -1 ; i-- )
			{
				
				if (!_SoundLoaderMonitor.Loaders[i].loaded || !_SoundLoaderMonitor.Loaders[i].inProgress)
					//_SoundFilesList.SoundsLoader.prioritize(_SoundLoaderMonitor.Loaders[i].id, false)
			}
		}*/
		
		private function DeleteSound(index:uint):void
		{
			if(index< _Sounds.length && index >= 0)
			{
				//if(_Sounds[index].Type != "swf")
				//	delete _Sounds[index].snd;			//delete the Sound 
				_Sounds[index].Clear();			//delete the object
				_Sounds.splice(index,1)
			}
		}
	
		private function SearchByName(SName:String):int
		{
	
			var uper = SName.toUpperCase();
			for(var i:int=0; i<_Sounds.length;i++)
			{
				if(_Sounds[i].Name== uper)
				{
					return i;
				}
			}
			return -1;
		}
	
		public function Play(SName:String,Parent:Object=null,Func:Function=null,StartFrom:Number=0, loop:int = 0, moreArgs:Array = null):void
		{
			// TODO: if sound is not loaded make his pirorety higher
			var sound:CSound = GetSound(SName);
			//trace(this +" Play   Name:"+sound.Name+"   File:"+sound.File );
			if(sound == null)
			{
				trace(this+ ".Play: Cant find Sound File to play "+SName);
				return;
			}
			sound.Play(Parent,Func,StartFrom,loop, moreArgs);
			
		}
	
		public function Stop(SName):void
		{
	
			var index:int = SearchByName(SName);
			if(index == -1)
			{
				trace(this + ".Stop Cant find Sound File to Stop");
				return;
			}
		
			if (_Sounds[index].Type == ".SWF") 
			{
				//_Sound_MC[SName].gotoAndStop(1);
			}
			else
				_Sounds[index].Stop();
		}
	
		public function StopAllSounds():void
		{
			//trace (" StopAllSounds was called")
			for(var i=0;i<_Sounds.length;i++)
				_Sounds[i].Stop();
		}
	
		public function StopAllSoundsExcept(soundToKeep:String):void
		{
		
			for(var i=0;i<_Sounds.length;i++)
				if(_Sounds[i].Name.toUpperCase() != soundToKeep.toUpperCase())_Sounds[i].Stop();
		}
	
		public function GetSound(SName:String):CSound
		{
	
			var index:int = SearchByName(SName);
			if(index == -1)
			{
				trace(this + ".GetSound Did not found sound " + SName);
				return null;
			}
			return _Sounds[index];
		}
	
		
		//Clear the Sounds not the CSound object, this way it ready for lang change.
		public function Unload():void
		{
			//Clear();
			trace("Unload was called _FCounter=" , _FCounter);
			
			if(!_FCounter)
			{
				E_OnLangUnloded();
				return;
			}
				
			for(var i:uint=0 ; i<_Sounds.length; i++)
			{
				
				//trace(i,_Sounds[i].Name )
				//_SoundLoaderMonitor.remove(_Sounds[i].SndLoader)
				_Sounds[i].UnLoad();	
			}
			//_SoundLoaderMonitor.destroy();
			
			
			
			_FCounter=0;
 			E_OnLangUnloded();
			
	
		}
	
		public function IsPlaying(SName:String):Boolean
		{
			var index:int = SearchByName(SName);
			if (index == -1){
				return false;
			}
			return _Sounds[index].IsPlaying;
		
		}
	
	
		public function Position(SName:String):Number
		{
			var index:Number = SearchByName(SName);
			return _Sounds[index].Position	
		}
		
		public function Duration(SName:String):Number
		{
			var index:Number = SearchByName(SName);
			
			if (index != -1)
			{
				return _Sounds[index].Duration;	
			}
			else
			{
				return 0;
			}
		}
		/*
		public function LoadNextSound()
		{
			 //trace ("LoadNextSound()")
			 _Sounds[_SoundIndexser].Load();
			 _SoundIndexser++
		}*/
		
		// ----------------------- Event Dispatchers --------------------------------
		
		public function E_OnReady(signal:LoaderSignal = null, stats:ILoadStats = null):void
		{
	
			
			//dispatchEvent(new Event("OnReady"));
			_InProgress = false;
			_Loaded  = true;
			OnReady.dispatch();
		}
		
		
		public function E_OnLangUnloded():void
		{
			trace ("CSoundCollection: OnLangUnloded")
			//dispatchEvent(new Event("OnLangUnloded"))
			_Loaded = false;
			OnLangUnloded.dispatch();
		
		}
		// ----------------------- Event Hnadlers ----------------------------------
		
		public function S_SoundReady(signal:LoaderSignal=null, child:ILoader=null):void
		{
			
			trace(this + " S_SoundReady _FCounter="+_FCounter + " _Sounds.length="+_Sounds.length);
			_FCounter++;
			if(_FCounter == (_Sounds.length))
			{
				
				E_OnReady();
			}
			
		}
		// -------------------------------------------------------------------------
		
		public function GetSoundByIndex(index:uint):CSound
		{
	
			if (index < _Sounds.length)
				return _Sounds[index];
			
			return null;
		}
		public function get Loaded():Boolean{return _Loaded}
		public function get InProgress():Boolean{return _InProgress}
		public function get Count():Number{return _Sounds.length;}
		public override function toString():String{return "[CSoundCollction "+_Name+"]";}
		
	}
}
