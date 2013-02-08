package
{
	import flash.display.Sprite;
    import flash.events.*;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.net.URLRequest;	
    import org.assetloader.AssentLoaderPlus;
	
	public class CSoundsFilesCollection extends Sprite
	{
		
		private var LocalSndArray:Array
		private static var instance:CSoundsFilesCollection;
      	private static var allowInstantiation:Boolean;
		
		public var SoundsLoader:AssentLoaderPlus; 
		
		public function CSoundsFilesCollection()
		{
			 //trace ("CSoundsFilesCollection constractor was called")
			  if (!allowInstantiation) {
            	throw new Error("Error: Instantiation failed: Use SingletonDemo.getInstance() instead of new.");
        	  }else{
				 LocalSndArray = new Array();
				 SoundsLoader = new AssentLoaderPlus();
			  }
		
		}
		
		 public static function getInstance():CSoundsFilesCollection
		 {
        	 if (instance == null) {
           		 allowInstantiation = true;
           		 instance = new CSoundsFilesCollection();
           		 allowInstantiation = false;
         	 }
        	 return instance;
      	}
		
		
		public function Add(path:String,type:String = ".mp3"):CSoundFile
		{
			//TempTrace();
			var snd:CSoundFile;
			var pos = searchByPath(path);
			if (pos == -1)
			{
				var index:uint = LocalSndArray.length;
				//var refrences:int = 1;
				snd = new CSoundFile(index.toString(),path,type);
				LocalSndArray[LocalSndArray.length] = new Array(snd,1);
				SoundsLoader.addLoader(snd.SndLoader);
			}
			else 
			{
				LocalSndArray[pos][1] = LocalSndArray[pos][1]+1;
				snd = LocalSndArray[pos][0];
			}
			//var temp:uint =  searchByPath(path)
			return snd;
			
		}
		
		public function Remove(snd:CSoundFile):void
		{
			//TempTrace();
			//trace ("Remove was called in fileCollectiom", snd.path)
			// if there no csound refer to CSound then we can delete it from array
			trace(this,"Remove snd=",snd.Name,snd.File);
			var pos:int = searchByPath(snd.path);
			LocalSndArray[pos][1] = LocalSndArray[pos][1]-1;
			
			
			if (!LocalSndArray[pos][1])
			{
				SoundsLoader.remove(snd.path);
				LocalSndArray.splice(pos,1);
				snd.UnLoad();
								
			}	
		}
		
		
		
		private function searchByPath(newPath:String):int
		{
			for(var i:int=0; i<LocalSndArray.length;i++)
			{	
				if (LocalSndArray[i][0].path == newPath)
				{
					return i //LocalSndArray[i];
				}
			}
			return -1;
		}
		
		
		public function get Count():uint{return LocalSndArray.length;}
		
		
	}
}