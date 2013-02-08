package
{
	
	import flash.events.*;
	import flash.ui.Mouse;
	
	
	public class MyMenu extends CMenu
	{
		//public var Cookie:FSCookie;  // to get info from *.sol file that is unique for firststeps
		
		public function MyMenu(){
		
			super();
			//_Main = null;
			//Cookie = FSCookie.getInstance();
			//MenuXML=CMenuXML.getInstance();
		}
		
		
		override public function S_SceneEnd(scn:CScene=null):void
		{	//overRide
		
			//here it can be control all pages - what comes before what
			trace(this + "MyMenu.S_PageEnd: " + scn.Name);
			
			
			if(App.debugScene){
				trace("Debug flow: Skipping to Loading");
				//PlayScene("shkufit","Loading");
				switch(scn.Name)		
				{
					case "OPENING":
						PlayScene("Language");
						break;
					case "LANGUAGE":				//if LANGUAGE Page is ended
							
						PlayScene("shkufit","Loading");
						break;
				
				}
			}else{
				
				trace("Non-debug flow");
					
				switch(scn.Name)		
				{

					case "OPENING":
						if(App.FirstTime )
							PlayScene("Language"); //open languge page to select lang for the very first time.
						else 
							super.S_SceneEnd(scn);
						break;
						case "LANGUAGE":				//if LANGUAGE Page is ended
							super.S_SceneEnd(scn);	//show the MainMenu
						break;
					case "SHKUFIT":	
					case "LEVEL":				//if Level Page is ended
						trace("Level Ended..");
						if(App.NeedCover)
							PlayScene("Cover");
						else
							//inMenu = false
							//PlayScene("shkufit","Loading");//show the Loading Page
							App.Game.StartGame();
					break;
					case "COVER":				//if Cover Page is ended
						//inMenu = false
						PlayScene("shkufit","Loading");
						break;
				}
			}
		}
		
		override public function Show():void
		{
	
			CDebug.Trace("MyMenu Show ");
			
			if(!OpenScene )
			{	
			
				if(Pages("PopUp").IsPlaying)
				{
					Pages("PopUp").Stop();
				}
				PlayScene("shkufit",2);	
				//PlayScene("MENU",2,false)
				Mouse.show();
				OnPlay.dispatch();
			}
		}
		
	}
	
	
}