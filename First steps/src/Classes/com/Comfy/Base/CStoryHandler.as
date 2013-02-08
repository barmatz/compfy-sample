//CStoryHandler
//Rewriten by  Asaf Kuller based on Miko.A  22/2/07
package
{
	public class CStoryHandler
	{
		private var _story:Array;
		private var _StorySn:String;		      //main story Scenes
		private var _CurrentSn:String;		      //Charecters Scenes
		public var Default:String;			      //default main Story Scene
		
		public function CStoryHandler()
		{
			
			_story = new Array();		//the default Scene !
			_StorySn = _CurrentSn = Default = "";
		}
		public function SetStory(scenes:Array):void
		{
			
			_story = scenes;		//the default Scene !
			
		}
		public function ReturnTo():String
		{
			
			var temp:String;
			trace(this +".ReturnTo ="+_CurrentSn )
			if(_CurrentSn != "")
			{
				
				temp = _CurrentSn;
				_CurrentSn = "";
			}
			else 
				temp = ContinueTo();		//mybe it was story scene
			
			return temp;
		}
		public function ContinueTo():String
		{
			
			var temp:String;
			//ssDebug.trace(this + ".ContinueTo ="+_StorySn )
			trace(this + ".ContinueTo ="+_StorySn )
			
			if(_StorySn != "")
			{
				temp = _StorySn;
				_StorySn = "";
				return temp;
			}
			else
			{
				trace (this + ".ContinueTo Default="+Default )
				return Default; //_story[0];
			}
		}
		public function Register(scene:String):void
		{
			
			if(IsStoryScene(scene))
			{
				_StorySn = scene;
				trace(this+".Registering Story Scene "+_StorySn);
			}
			else
			{
				_CurrentSn = scene;
				trace(this+".Registering Charecter Scene "+_CurrentSn);
			}
		}
		
		public function IsStoryScene(scene:String):Boolean
		{
			
			var uper:String = scene.toUpperCase();
			if(_story.length > 0)
			{
				for(var i=0;i< _story.length;i++)
					if(_story[i].toUpperCase() == uper)
						return true;
			}
			return false;
		}
		
		public function toString():String{return "CStoryHandler";}
		public function get storyScenes():Array{return _story;};
		
		// Asaf Kuller 12Oct2008 I added this mathod becouse ContinueTo set _StorySn to ""
		// I needed a mathod that return the story without changing it.
		public function get CurrentStory():String{return _StorySn;}; 
		
		
	}
}