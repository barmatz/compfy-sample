package
{
	
	
	public class MyScenes extends CSceneCollection
	{
		
		
		
		public function MyScenes()
		{
			super();			
		}
		
		override public function CreateStory():void
		{	//overloaded function 
			
			/*  
			/ --this part is not necesary in firat stope storylaess game
			_Story = new CStoryHandler();
			_Story.SetStory(_Clips);		//make this clips the story Clips
			_Story.Default  = "openScene";  
			*/
			RestartStory();
		}
		
		public override function RestartStory():void
		{
			App.Game.snailyPhoneNum = -1
			App.Game.feelyPhoneNum = -1
			
			App.Game.feelyNum = -1
			App.Game.jumpyNum = -1;
			App.Game.buddyNum = -1
			App.Game.snailyNum = 0 ;
			App.Game.comfyNum= -1;
			
			App.Game.moonNum=-1
			App.Game.sunNum=-1
			
			App.Game.drumNum = 0;
			App.Game.fluteNum = 0;
			App.Game.trumpetNum = 0;
			App.Game.pianoNum = -1;
			
			App.Game.pauseNum = 0
			App.Game.gamadimNum = -1;
			
			//App.Game.Scenes.regLabel("openScene","start");
		}
		
		
		
		public override function Load(lang:String,level:Number=0):void
		{
			switch(App.Level)
			{
				case 1:
					SetReadyCondition("SCENES","topframe,song,moon1,sun1");
					break;
				case 2:
					SetReadyCondition("SCENES","topframe,song,moon2,sun2");
					break;
				case 3:
					SetReadyCondition("SCENES","topframe,song,moon3,sun32");
					break;
				default:
					SetReadyCondition("SCENES","topframe,song");

				
			}
			super.Load(lang,level);
			
		}
		
		
		
		public override function toString():String {return "MyScenes";}
		
	}
	
	
}