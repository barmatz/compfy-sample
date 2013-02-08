
//CScreeenMode
//writen by Asaf Kuller 26/07/07 - based on function from flashStudio.as from as1 engine

package
{
	import flash.system.Capabilities;
	
	
	public class CScreenMode{
		 
		private var maxMode:Number;
		private var currentMode:Number;
		private var ColorDepth:String;
		
		public function CScreenMode(){
			trace("screenMode constructor initialized");
			CDebug.Trace("screenMode constructor initialized App.ScreenMode="+App.ScreenMode);
			
			ColorDepth = App.ColorDepth
			switch(Capabilities.screenResolutionX){
				
				case  800:
					trace("user in 800 x 600 mode");
					this.maxMode = 2;
					break;
				case  1024:
					trace("user in 1024 x 768 mode");
					this.maxMode = 3;
					break;
				
				case  1280:
					if(Capabilities.screenResolutionY == 960){
						trace("user in 1280 x 960 mode");
						this.maxMode = 4;
						break;
					}
				default:
					trace("user in res above 1280 x 1024");
					this.maxMode = 6;
					//break;
			}
			
			
			
			
			if( App.ScreenMode != 0 && App.Projector.Type != "Air")
			{
				
				//this.currentMode = App.ScreenMode
				changeResMode(App.ScreenMode)
			}else{
				
				//currentMode = maxMode
				changeResMode(maxMode)
				//CDebug.Trace(">>>>>>> 3. CScreenMode maxMode="+maxMode)
			}
			
		}
	
	
	
		// changeRes method - changes resolution by screenX and screenY parameters
		private function changeRes(screenWidth:Number,screenHeight:Number):void
		{
			//CDebug.Trace("screenMode.changeRes called to: " + screenWidth+" x "+screenHeight+" x "+ColorDepth);
			//CDebug.Trace(">1 changeRes maxMode="+maxMode);
			App.changeRes(screenWidth,screenHeight); 
			//CDebug.Trace(">2 changeRes maxMode="+maxMode)
				
		}
	
		// changeResMode method - changes resolution by mode number (1,2,3)
		public function changeResMode(mode:Number):void
		{
			
			trace("screenMode.changeResMode called with mode: "+mode+", currentMode = "+this.currentMode);
			switch(mode)
			{
				 case  1:
					if(this.currentMode !=1){
						trace("screenMode.changeResMode: user change to  640 x 480 mode");
						this.changeRes(640,480);
						this.currentMode = 1;
					}
					break;
				case  2:
					if(this.currentMode !=2 && this.maxMode>1){ 
						trace("user change to  800 x 600 mode");
						this.changeRes(800,600);
						this.currentMode = 2;
					}
					break;
				case  3:
					if((this.currentMode !=3 && this.maxMode==3) || (this.maxMode>3)){
						trace("user change to  1024 x 768 mode");
						this.changeRes(1024,768);
						this.currentMode = 3;
					}
					break;
				case  4:
					if((this.currentMode !=3 && this.maxMode==4) || (this.maxMode>4)){
						trace("user change to  1280 x 960 mode");
						this.changeRes(1280,960);
						this.currentMode = 4;
					}
					break;
				default:
					CDebug.Trace("> CScreenMode changeResMode maxMode="+maxMode)
					if (App.Projector.Type == "Air")
					{
						CDebug.Trace("> CScreenMode Difinding res for AIR")
						var screenX:Number = Capabilities.screenResolutionX;
						var screenY:Number = Capabilities.screenResolutionY;
						
						if (screenX/4 <= screenY/3)
						{
							screenY = (screenX/4)*3
						}
						else
						{
							screenX = (screenY/3)*4
						}
						
						
						changeRes(screenX,screenY);
						currentMode = 6;
						CDebug.Trace("> CScreenMode App.Projector.Type == Air maxMode="+maxMode)
						CDebug.Trace("> CScreenMode App.Projector.Type == Air currentMode="+currentMode)
					}
					else
					{
						CDebug.Trace("> CScreenMode changeResMode (Non Air) maxMode="+maxMode)
						changeRes(1024,768);
						currentMode = 3;
					}
					trace("user in res above 1280 x 768, change to  1024 x 768 mode");
					//break;
			}
			App.ScreenMode = currentMode
			App.Cookie.Save(); // save to cookie
			CDebug.Trace("> CScreenMode changeResMode App.ScreenMode="+App.ScreenMode)
			
		}
	
	private function changeDefaultMode ()
	{
		//ssDebug.trace("screenMode.changeDefaultMode called");
		if(this.maxMode>1)
		{
			this.changeResMode(App.ScreenMode);
		}	
	}
	public function get maxScreenMode():Number{CDebug.Trace("maxScreenMode was called in CScreenMode");return maxMode;}	
	public function toString():String{return "CScreeenMode";}
		
	}
}