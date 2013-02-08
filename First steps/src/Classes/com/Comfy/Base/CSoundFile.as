package
{
	import flash.display.*;
	import flash.events.*;
    import flash.media.*;
	import flash.net.URLRequest;	
	 
	import org.osflash.signals.*;
	//import org.osflash.signals.natives.*;
	import org.assetloader.signals.ErrorSignal;
	import org.assetloader.signals.LoaderSignal;
	
	import org.assetloader.*;
	import org.assetloader.core.*;
	import org.assetloader.loaders.SWFLoader;
	import org.assetloader.loaders.SoundLoader;
	
	 
	public class CSoundFile extends CBaseFile
	{	
		private var _Type:String;
		private var _SWF:MovieClip;
		private var _Path:String;
		private var _Sound:Sound; // = new Sound;
		private var _Loaded:Boolean;
		private var _IsLoading:Boolean;
		
		//private var _Channel:SoundChannel;
		
		public var SndLoader:ILoader;
		public var OnReady:Signal;
		public var OnFault:Signal;
		
		public function CSoundFile(SName:String,SFile:String,SType:String = ".mp3")
		{
			super(SName,SFile);
			_Path = SFile;
			_Loaded = false;
			_IsLoading = false;
			_Type=SType.toLowerCase();
			OnReady = new Signal();
			OnFault = new Signal();
			initSound();
			
			
		}
		
		public function Load():void
		{
				
				//CDebug.Trace("CSoundFile Load");
				
				if (SndLoader == null) //(_Sound == null && _Type==".mp3")||(_SWF==null && _Type==".swf") )
				{
					initSound();
				}
				
				if(!_Loaded && !_IsLoading)
				{
					_IsLoading = true;
					SndLoader.start();
					/*
					_Req = new URLRequest(_Path)
					
					switch(_Type)
					{
						case ".mp3":
							_Sound.load(_Req);
							break;
						case ".swf":
							SwfLoader.load(_Req);
							break;
					}
					*/
				} 
			
		}
		
		
		public function UnLoad():void
		{
			if(_Loaded && !_IsLoading)
			{
				SndLoader.destroy();
				SndLoader = null;
				switch(_Type)
				{
					case ".mp3":
						/*
						_Sound.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
						_Sound.removeEventListener(Event.COMPLETE,onComplete);*/
						_Sound = null;
						
						break;
					case ".swf":
						/*
						SwfLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
						SwfLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
						SwfLoader.unload();
						*/
						_SWF = null
						break;
				}
				_Loaded = false;
							
			}
		}
		
		//play(startTime:Number = 0, loops:int = 0, sndTransform:SoundTransform = null):SoundChannel
		
		public function Play(startTime:Number = 0, loops:int = 0, sndTransform:SoundTransform = null):SoundChannel
		{
			//trace ("Play at Sound File _Sound =",_Sound," _Path=",_Path)
			if (_Sound == null)
			{
				return null
			}
			else
			{
				return  _Sound.play(startTime,loops,sndTransform);
			}
			
			//return _Channel //_Sound.play(startTime,loops,sndTransform);
			
		
		}
		/*
		public function Stop():void
		{
			switch(_Type)
				{
					case ".mp3":
						_Channel.stop();
						break;
					case ".swf":
						StopSWF();
						break;
				}
		}*/
		
		public function PlaySWF():void
		{
			if(_SWF != null){_SWF.gotoAndPlay(2);}
		}
		
		public function StopSWF():void
		{
			if(_SWF != null){_SWF.gotoAndStop(1);}
		}
		
		private function initSound():void
		{
			//CDebug.Trace("initSound was called "+_Type+" SndLoader="+SndLoader+" Path="+_Path+" Name="+Name )
			switch(_Type)
			{
				case ".mp3":
					_Sound = new Sound();
					SndLoader = new SoundLoader(new URLRequest(_Path),_Path)//,Name);
					SndLoader.onComplete.add(SndOnComplete);
					SndLoader.onError.add(ioErrorHandler);
					
					/*
					_Sound.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
					_Sound.addEventListener(Event.COMPLETE,onComplete);
					*/
					
					break;
				case ".swf":
					SndLoader = new SWFLoader(new URLRequest(_Path),_Path);
					SndLoader.onComplete.add(SwfOnComplete);
					SndLoader.onError.add(ioErrorHandler);
					//SndLoader.onRemovedFromParent.add(unLoadHandler)	
					/*
					SwfLoader = new Loader(); 
					SwfLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
					SwfLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
					SwfLoader.contentLoaderInfo.addEventListener(Event.UNLOAD, unLoadHandler);
					*/
					break;
			}
		}
		
		
		
		//------------ Event Handlers --------------------
		
		private function unLoadHandler(event:Event):void
		{
			_SWF = null
			//SwfLoader.contentLoaderInfo.removeEventListener(Event.UNLOAD, unLoadHandler);
			//SwfLoader=null;
			_Loaded = false;
		}
		
		
		private function SndOnComplete(signal:LoaderSignal, snd:Sound):void
		{
			 _Sound = snd;
			 onComplete()
		}
		
		
		private function SwfOnComplete(signal:LoaderSignal, swf:Sprite):void
		{
			
			
			_SWF = swf as MovieClip;
			//addChild(_MC);
			/*
				if(event.target.content is MovieClip)
				{
					_SWF = event.target.content// as MovieClip;
				}else{
					CDebug.Trace("Swf is not movieClip  =" +  typeof(event.target.content ) )
					return;
				}
			*/
			 onComplete()
			
		}
		
		private function onComplete():void
		{
			_IsLoading = false
			_Loaded = true
			
			//CDebug.Trace(">>>> CSoundFile: " + _Path + " sound is loaded "+_Type);
			OnReady.dispatch();
		}
		
		private function ioErrorHandler(event:ErrorSignal):void 
		{
           _IsLoading = false
			// trace("CSoundFile"+Name+"Error:" + event.message);
		//   CDebug.Trace("!!!  CSoundFile "+ _Path+" Error: " + ErrorSignal);
		   OnFault.dispatch()
        }
		
		
		//
		public function get Duration():Number
		{
			
			switch(_Type)
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
		
		//public function get SwfInfo():LoaderInfo{return SwfLoader.contentLoaderInfo;}
		public function get type():String{return _Type;}
		public function get sound():Sound{return _Sound;}
		public function get path():String{return _Path;}
		public function get loaded():Boolean{return _Loaded;}
		public function get IsLoading():Boolean{return _IsLoading;}
		public function get SWF():MovieClip{return _SWF;}
		public override function toString():String{return "[CSoundFile "+Name+" "+_Path.substring(_Path.lastIndexOf("/"),_Path.length)+"]";}

	}

}