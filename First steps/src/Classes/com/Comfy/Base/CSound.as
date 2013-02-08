//CSound
//THE Sound Object !
//writen by Asaf Kuller 16/2/2009 based on Miko.A  20/12/06
package

{
	
	import flash.events.*;
	import flash.media.*;
	import flash.display.MovieClip;
	import org.osflash.signals.natives.*;
	import org.osflash.signals.Signal;
	import org.assetloader.*;
	import org.assetloader.core.*;
	import org.assetloader.loaders.*;
	import org.assetloader.signals.*;
	
	public class CSound extends CSoundDef
	{
		
		private var _Playing:Boolean;
		//private var _cSound:CSoundFile;
		private var _InterID:Number;
		private var _ID:Number;
		private var _Loop:Number;
		//private var _Path:String;
		private var _CallBackFunc:Function;
		private var _CallbackParams:Array;
		private var currVolume:Number;
		private var _Channel:SoundChannel;
		
		private var _SWF:MovieClip;
		private var _Sound:Sound;
		
		//private var SoundCompleteSignal:NativeSignal;
		
		public var OnReady:Signal;
		public var OnUnLoad:Signal;
		
	
		/**
	 	* @author Asaf Kuller
	 	*/
		public function CSound(Id:uint,SName:String,SFile:String,SVolume:Number=100,SCallBackF:Function=null,SType:String=".mp3",SLocal:Boolean=false)
		{
	
		
			super(SName,SFile,SVolume,SCallBackF,SType,SLocal);
			_ID = Id;
			_InterID = 0;
			//_Path = getPath();
			Type = SType;
			
			if(Type== ".mp3")
			{
				_Sound = new Sound();
			}
			//_SoundList = CSoundsFilesCollection.getInstance()
			//_cSound = _SoundList.Add(_Path,SType) //new CSoundFile("0",_Path,Type)//
			
			if(Name == null)
				trace(this,"Sound File Not Found");
			_Playing = false;
			OnReady = new Signal();
			OnUnLoad  = new Signal();
			
		}
		
		
		/**
		 * @private
		
		private function getPath():String
		{
			
			var UserLang:String = App.UserLang;
			var localSndFileExt:String = "_"+UserLang;   	// this consturcts the ending of the filename for localized versions.
			var localSndFolder:String = UserLang ; 		// local sound folder inside the sounds folder.
			//var path:String = App.FolderPath(App.SoundFolder) + "/"; // change by Asaf for reading sounds from CD
			var path:String = App.StartDirURL + App.SoundFolder + "/";
			path += (Local) ? localSndFolder +"/"+ File+localSndFileExt + Type : App.GLSoundFolder + "/" + File + Type;
			
			//trace("~~~~~~~~~~~~> App.UserLang=",App.UserLang,"App.FolderPath(App.SoundFolder) ", App.FolderPath(App.SoundFolder) )
			return path //File+Type
		}
		 */
		 
		/**
		*
		* Start The loading of resource through the SoundFile object
		*
		
		public function Load()
		{
		
			//trace("CSound: Loading sound:"+Name + "   File:"+File+ "  Type:" + Type + " Local:" + Local + " Volume:"+Volume) //+ "    in  lanugugage "+ UserLang));
			
			InitSound();
			if (Loaded)
			{
				 E_OnReady();
			}
			else
			{
				_cSound.Load();
			}
		
		}
		
		
		public function InitSound():ILoader
		{
			if (_cSound == null)
			{
				_Path = getPath();
				_cSound = _SoundList.Add(_Path,Type) //new CSoundFile(_Path,Type)
			}
			if (Loaded)
			{
				 E_OnReady();
			}
			else
			{
				_cSound.OnReady.addOnce(OnLoadHandler);
				_cSound.OnFault.addOnce(OnLoadError);
				_cSound.SndLoader.onRemovedFromParent.addOnce(E_OnUnLoad)
			}
			return _cSound.SndLoader;
		}
		*/
		
		
		
		public function SetAssets(dataObj:*):void
		{
			trace(this,Name,Type,"SetAssets",dataObj,typeof(dataObj))
			switch(Type)
			{
				case ".swf":
					_SWF = dataObj as MovieClip;
					addChild(_SWF);
					break;
				case ".mp3":
					_Sound = dataObj as Sound;
					break;
			}
			E_OnReady();
		}
		
		public function RemoveAssets():void
		{
			switch(Type)
			{
				case ".swf":
					if( _SWF != null)
						removeChild(_SWF);
					_SWF = null;
					break;
				case ".mp3":
					_Sound = null
					break;
			}
			E_OnUnLoad();
		}
		
		public function HasAssets():Boolean
		{
			if (_SWF==null && _Sound==null)
				return false;
			return true;
		}
		
		public function OnLoadError():void
		{
			trace ("CSound",Name,"Load Failed")
			E_OnReady()
		}
		
		/**
		* Play the Sound
		*	
		*	<ul>
		*		<li><strong>Parent</strong> - The object where the callback function resident.</li>
		*		<li><strong>Funcs</strong> - The callback function </li>
		*		<li><strong>StartFrom</strong> - The point to strart the sound from in milisecounds </li>
		*		<li><strong>Loop</strong> - How many time to loop the sound, the defualt is 0 which mean play the sound only once </li>
		*		<li><strong>inCallbackParams</strong> - Array of parameters to pass to the callback function </li>
		* 	</ul>
		*
		*/		
		public function Play(Parent:Object=null,Funcs:Function=null,StartFrom:Number=0,Loop:int=0,inCallbackParams:Array=null):void
		{
		
			if (HasAssets())
			{
				_CallBackFunc   = Funcs;
				_CallbackParams = inCallbackParams;
				_Loop = Loop;
				
				if(_Playing == true){
						Stop();
				}
						
				switch(Type)
				{
					case ".swf":
						if(_SWF != null){_SWF.gotoAndPlay(2);}
						break;
					case ".mp3":
						_Channel = _Sound.play(StartFrom,Loop) //,sndTransform); //_cSound.Play(StartFrom,Loop);
						//SoundCompleteSignal = new NativeSignal(_Channel,Event.SOUND_COMPLETE,Event)
						if (_CallBackFunc != null)
						{
							_Channel.addEventListener(Event.SOUND_COMPLETE,_CallBackFunc); 
							//SoundCompleteSignal.addOnce(_CallBackFunc);
						}
						_Channel.addEventListener(Event.SOUND_COMPLETE,SoundComplete);
						//SoundCompleteSignal.addOnce(SoundComplete);
						var transform:SoundTransform = _Channel.soundTransform;
						transform.volume = Volume/100;
						_Channel.soundTransform = transform;
						break;
					default:
						trace(this +".Play: Err Type file is not Right ! type= "+Type + " "+typeof(Type));
						break;
				}
				
				
				_Playing = true;
			}
			else
			{
				trace("Name:"+Name+ " File:"+File+" sound was not loaded!");
			}
		
		}
		
		/**
		*
		* Stop the sound and remove listener for the sound complete event
		*
		*/
		public function Stop():void
		{
			if (HasAssets())
			{
				_Playing  = false;
				switch(Type)
				{
					case ".swf":
						if(_SWF != null){_SWF.gotoAndStop(1);}
						break;
				
					case ".mp3":
						if (_Channel != null){
							
							//SoundCompleteSignal.removeAll()
							if (_CallBackFunc != null)
							{
								_Channel.removeEventListener(Event.SOUND_COMPLETE,_CallBackFunc); 
							}
							_Channel.removeEventListener(Event.SOUND_COMPLETE,SoundComplete);
							_Channel.stop();
						}
					break;
				}
			}
		}
	
		
	
		public function Clear():void
		{

			UnLoad();
			OnReady.removeAll();
			
			
		}
		
		public function UnLoad():void
		{	
			
			//trace(this,"UnLoad _cSound="+_cSound)
			Stop();
			RemoveAssets()
					
		}
				
		
		//--------------------------- Evennts Handlers ----------------------------------
		// No matter what happened with loading sound collection need to know this object is done with loading.
		
		/**
		 * @private
		 */
		 /*
		private function OnLoadHandler(event:Event = null):void
		{
			//trace ("CSound",Name,"Load is sucsses")
			if (Type==".swf" && _cSound.loaded)
			{
				addChild(_cSound.SWF)
			}
			
			E_OnReady()
		}
		*/
		
		
		/**
		 * @private
		 */
		private function SoundComplete(event:Event){
			//_Channel.removeEventListener(Event.SOUND_COMPLETE,SoundComplete);
			_Playing = false;
		
		}
		
		//--------------------------- Events Dispatchers ----------------------------------
		
		
		/**
		 * @private
		 */
		private function E_OnReady()
		{			
			//trace ("CSound dispatch onReady!")
			
			OnReady.dispatch();
		}
		
		/**
		 * @private
		 */
		 private function E_OnUnLoad():void //signal:LoaderSignal, prnt:IAssetLoader)
		{			
			trace(this, "~E_OnUnLoad~")
			OnUnLoad.dispatch();
		}
	//---------------------------Getter and Setter ------------------------------------------
		
		
		public function get IsPlaying():Boolean{ return _Playing;}
		
		public function get Position():Number
		{
					
			switch(Type)
			{
				case ".mp3":
					return _Channel.position;
					break;
				case ".swf":
					return 0;// _cSound_MC._currentframe;
					break;
				default:
					return 0;
				
			}
		}
		
		public function get Duration():Number
		{
			
			switch(Type)
			{
				case ".mp3":
					//trace ("_Sound.length="+_Sound.length);
					return _Sound.length;
					break;
				case ".swf":
					return _SWF.totalFrames*(1000/12); // the value this function return is the length of sound in miliscounds 													// and with compute it for 12 FPS.
					break;
				default:
					return 0;
					
			}	
		}
		//public function get SndLoader():ILoader { if (_cSound == null){ return null } else {	return _cSound.SndLoader;}}
		//public function get Duration():Number{ if (_cSound == null){ return 0 } else {	return _cSound.Duration;}};
		//public function get Loaded():Boolean{if (_cSound == null){ return false} else {return _cSound.loaded;}};
		public override function toString():String{return "CSound";} //+ Name+"]"
		
	}
}	
	
	