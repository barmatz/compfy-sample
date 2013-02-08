package
{
	import flash.utils.Timer;
	import flash.events.*;
	import com.adobe.crypto.*
	import com.cjt.shu.Shu;
	
	import com.comfy.*;
	import com.comfy.utils.*;
	import com.comfy.anim.*;
	import com.comfy.keyboard.CKeyboard;
	
	public class MyKeyboard extends CKeyboard
	{
	
	
	private var toysNum:Number;
	private var phoneTimer:Timer;
	private var galNum:Number;
	
	private var TipsFrames:Array;
	public var Cookie:FSCookie
	private var shu:Object = Shu.GetInstance();
	
	
		public function MyKeyboard(SColl:CSceneCollection,menu:CMenu)
		{
		
			super(SColl,menu);
			trace ( "MyKeyboard was called")
		
			toysNum = RandomNum(0,2) // or random(3)
			galNum = RandomNum(0,2)
			Cookie = FSCookie.getInstance();
			//exitsFromGame = 0
			TipsFrames = new Array("theDifference","FunLearning","Behind","pedagogical") 
		}
	
	
		public override function RegisterMenuKeys():void
		{
			UnRegisterAllKeys();
			trace(this + ".RegisterMenuKeys - FirstSteps");	
			//RegisterKey("Escape",this,Quit);
			RegisterKey("Escape",this,ShowTipsAfter);
			//RegisterKey("Right1",this,ShowTipsAfter);   // this for debug only sun key insted of ESC key
		
			RegisterKey("bottomR",App.Game,App.Game.redMenuButton);
			RegisterKey("bottomY",this,this.playMenu,{Scn:"activityCenter"});
			RegisterKey("bottomB",this,this.playMenu,{Scn:"Language"});
			RegisterKey("bottomG",this,this.playMenu,{Scn:"Level"});
			RegisterKey("bottomO",this,this.playMenu,{Scn:"parentSection"});
			RegisterKey("bottomP",this,this.playMenu,{Scn:"Products",Frame:2});
		}
	
		public override function RegisterGameKeys():void
		{		//this function Is Override
	
			trace(this +".RegisterGameKeys.");
			UnRegisterAllKeys();
		
			RegisterKey("Escape",this,this.ShowMenu);
			//RegisterKey("Stop",this,this.ShowMenu);
			RegisterKey("Stop",this,Pause);
			
			//caracters buttons
			RegisterKey("Left1",this,SnailyAnim);
			RegisterKey("Left2",this,BuddyAnim);
			RegisterKey("Left3",this,jumpyAnim);
			RegisterKey("Left4",this,feelyAnim);
			RegisterKey("Left5",this,ComfyAnim);
			
			//center buttons
			RegisterKey("CenterT",this,pianoAnim); 
			RegisterKey("CenterL",this, trumpetAnim);
			RegisterKey("CenterM",this,drumAnim);
			RegisterKey("CenterR",this,fluteAnim);	
			RegisterKey("CenterB",this,toysAnimation);		
		
			//color buttons
		
			RegisterKey("BottomP",this,colorAnim,"purple"); 
			RegisterKey("BottomO",this,colorAnim,"orange");
			RegisterKey("BottomG",this,colorAnim,"green")
			RegisterKey("BottomB",this,this.colorAnim,"blue")
			RegisterKey("BottomY",this,colorAnim,"yellow");
			RegisterKey("BottomR",this,this.colorAnim,"red");
			
			//sky buttons
			RegisterKey("Right1",this,sunAnim);
			RegisterKey("Right2",this,moonAnim);
			RegisterKey("Right3",this,playScene,{Scene:"cloud"+App.Level});
			
			RegisterKey("Roller",this,galgeletAnim); //galgelet"});
			RegisterKey("Phone",this,phonePlay);
		}
	
		private function registerCharKeyToPhone(event:Event = null):void
		{
			trace("registerCharKeyToPhone was called")
								//Scenes,Scenes.Play,{Scene:"snaily",Frame:"start",ex:true});
			RegisterKey("Left1",this,PhoneCharAnim,{Scene:"snaily"+App.Level,Frame:"phone"});
			RegisterKey("Left2",this,PhoneCharAnim,{Scene:"BuddyAll",Frame:"phone"});
			RegisterKey("Left3",this,PhoneCharAnim,{Scene:"jumpy"+App.Level,Frame:"phone"});
			RegisterKey("Left4",this,PhoneCharAnim,{Scene:"feely"+App.Level,Frame:"phone"});
			RegisterKey("Left5",this,PhoneCharAnim,{Scene:"comfy"+App.Level,Frame:"phone"});
		}
		
		private function registerCharKeyToAnim(event:Event = null):void
		{
			trace("registerCharKeyToAnim was called")
			//clearInterval(phoneInterval)
			RegisterKey("Left1",this,SnailyAnim);
			RegisterKey("Left2",this,BuddyAnim);
			RegisterKey("Left3",this,jumpyAnim);
			RegisterKey("Left4",this,feelyAnim);
			RegisterKey("Left5",this,ComfyAnim);
			
		}
		
		private function ShowMenu(event:Event):void
		{
			
			//App.KioskMode();
			App.Game.ShowMenu(); //.Show();
		}
		
		private function playMenu(event:*):void
		{
			var scn:String = event._Arg.Scn as String;
			if (event._Arg.Frame != undefined){	
				Menu.PlayScene(scn,event._Arg.Frame,true)
			}else{
				Menu.PlayScene(scn,2,true)
			}
			
		}
		
		private function playScene(event:*):void
	
		{			
			var scn:String = event._Arg["Scene"] as String;
			var frm:String = event._Arg["Frame"] as String;
			if (frm == null)
			{
				Scenes.PlayScene(scn,2,true)
			}
			else
			{
				Scenes.PlayScene(scn,frm,true)
			}
		}
		
		private function Quit(event:Event=null):void
	
		{			
			App.Quit();
		}
		
		private function ShowTipsAfter(event:Event):void
		{
			trace(this + " ShowTipsAfter: Cookie,Visits = "+Cookie.Visits )
			if(Cookie.ViewMarketing)
			{
				Quit()
			}
			else
			{
				var visits:Number = Cookie.Visits-1
				trace(this + " ShowTipsAfter: Visits = "+visits + "  " + (visits/2)%TipsFrames.length)
				Menu.HideMenuButtons()
				//Menu.PlayScene("Products","afterGame");
				
				
				if(visits%2 ){ //even number show products, odd number show parent tips
					//odd
					Menu.PlayScene("Products","afterGame");
				}else{
					//even
					var frame:String = TipsFrames [ (visits/2)%TipsFrames.length];
					trace ("frame = "+ frame);
					
					Menu.PlayScene("ParentTips",frame+"_after");
					
				
				}
				
			}
		}
		
		
		// -------------GALGELET AND PAUSE -------------------
		
		private function galgeletAnim(event:Event = null):void
		{
			var animArray = new Array("gamadim","galgelet");
			galNum = (galNum +1) % animArray.length;
			Scenes.PlayScene(animArray[galNum]);
			//Scenes.PlayScene("galgelet");
		}
		
		private function Pause(event:Event = null):void
		{
			App.Game.pauseNum = (App.Game.pauseNum+1)%2
			Scenes.PlayScene("openScene","pause"+App.Game.pauseNum)
			//_root.Comfy.clearMem();
		}
		// ------------ SKY AND WHETHER -----------------------
		
		private function sunAnim(event:Event = null):void
		{
			
			App.Game.sunNum = (App.Game.sunNum+1)%2
			if (App.Game.NewAnimLang && App.Level != 1 && App.Game.sunNum==1){
				if (App.Level == 3 )
				{
					Scenes.PlayScene("sun32");
	
				} else {
					Scenes.PlayScene("sun21") //+App.Level);
				}
				
				
				
			}else{
				Scenes.PlayScene("sun"+App.Level);
			}
		
		}
		
		private function moonAnim(event:Event = null):void
		{
			App.Game.moonNum = (App.Game.moonNum+1)%2
			if (App.Level == 3)
			{
				if (App.Game.NewAnimLang && App.Game.moonNum%2 == 1)
				{
					Scenes.PlayScene("moon3");
				}else{
					Scenes.PlayScene("moon32");
				}
			}else if (App.Level == 2){
				if (App.Game.NewAnimLang && App.Game.moonNum%2 == 1){
					Scenes.PlayScene("moon2","level22");
				}else{
					Scenes.PlayScene("moon2","start");
				}
			} else {
				Scenes.PlayScene("moon1");
			}
			
		}
		
		
		// ------------ CHARECTERS ----------------------------
		
		private function phonePlay(event:Event = null):void
		{
			trace ( "phonePlay was called App.Game.NewAnimLang="+App.Game.NewAnimLang)
			if (App.Game.NewAnimLang){
				//clearInterval(phoneInterval)
				//phoneInterval =  setInterval(Delegate.create(this,registerCharKeyToAnim),5000)
				if (phoneTimer == null)
				{
					phoneTimer=  new Timer(5000, 1);
					phoneTimer.addEventListener(TimerEvent.TIMER, registerCharKeyToAnim);
					
				}
				
				phoneTimer.reset();
				phoneTimer.start();
				trace("phonePlay was called")
				registerCharKeyToPhone();
				if (!Scenes.Scene("openScene").Sounds.IsPlaying("telephone_ring"))
				{
					Scenes.Scene("openScene").Sounds.Play("telephone_ring",null,null,0,3);
				}
			}
		}
		
		private function PhoneCharAnim(event:* = null):void
		{
			trace ( "phonePlay was called App.Game.NewAnimLang="+App.Game.NewAnimLang)
			if (App.Game.NewAnimLang){
				
				Scenes.Scene("openScene").Sounds.Stop("telephone_ring");
				playScene(event);
				
			}

		}
		
	
	
		
		
		private function ComfyAnim(event:Event = null):void
		{
			
			App.Game.comfyNum++ 
			
			if (App.Game.NewAnimLang && (App.Game.comfyNum%2) == 0  && App.Level!=1)
			{
				if (App.Level==3){
					Scenes.PlayScene("comfy3ms");
				}else if (App.Level==2){
					Scenes.PlayScene("comfy2ms");
				} 
			}else{
				Scenes.PlayScene("comfy"+App.Level,"start");
			}		
		}
		
		private function feelyAnim(event:Event = null):void
		{
			
			App.Game.feelyNum++ 
			if (App.Game.NewAnimLang && (App.Game.feelyNum%2) == 0 && App.Level!=1)
			{
				if (App.Level==3){
					Scenes.PlayScene("feely3ms","level3");
				}else if (App.Level==2){
					Scenes.PlayScene("feely2ms","level2");
				} 
			}else{
				Scenes.PlayScene("feely"+App.Level,"start");
			}		
		}
		
		private function jumpyAnim(event:Event = null):void
		{
			
			App.Game.jumpyNum = (App.Game.jumpyNum+1) %2
			if (App.Game.NewAnimLang && App.Game.jumpyNum == 0 && App.Level!=1){
					if(App.Level==3)
					{
						Scenes.PlayScene("jumpy"+App.Level+"ms")
					}else{
						Scenes.PlayScene("jumpy"+App.Level+"ms","level2");
					}
			}else{
				Scenes.PlayScene("jumpy"+App.Level,"start");
			}
				
		}
		
		private function SnailyAnim(event:Event = null):void
		{
			
			App.Game.snailyNum++ 
			
			if (App.Game.NewAnimLang && (App.Game.snailyNum%2) == 0 && App.Level!=1)
			{
				if (App.Level==3){
					Scenes.PlayScene("snaily3ms","level3");
				}else if (App.Level==2){
					Scenes.PlayScene("snaily2ms","level2_"+(App.Game.snailyNum%4/2));
				} 
			}else{
				Scenes.PlayScene("Snaily"+App.Level,"start");
			}
		}
		
		
		private function BuddyAnim(event:Event = null):void
		{
			App.Game.buddyNum++ 
			
			if (App.Game.NewAnimLang && (App.Game.buddyNum%2) == 0 && App.Level!=1){
				if (App.Level==3){
					Scenes.PlayScene("buddy3ms");
				}else if (App.Level==2){
					Scenes.PlayScene("buddy2ms");
				} 
			}else{
				Scenes.PlayScene("buddyAll","start");
			}		
		}
		
		
		// ------------ MUSIC ----------------------------
		
		
		private function toysAnimation(event:Event = null )
		{
			
			var animArray = new Array("song","orchestra");
			toysNum = (toysNum +1) % animArray.length;
			Scenes.PlayScene(animArray[toysNum]);
		
			
			//Scenes.PlayScene("song");
		}
		
		private function trumpetAnim(event:Event = null ):void
		{
			if (App.Game.NewAnimLang){
				App.Game.trumpetNum = (App.Game.trumpetNum+1)%2
			}else{
				App.Game.trumpetNum = (App.Game.trumpetNum+1)%App.Level
			}
			Scenes.PlayScene("trumpet"+App.Level);
		}
		
		private function pianoAnim(event:Event = null ):void
		{
		
			if (App.Level != 1){
				App.Game.pianoNum = (App.Game.pianoNum+1)%App.Level 		
			}
			Scenes.PlayScene("piano"+App.Level);
			
		}
		
		private function fluteAnim(event:Event = null ):void
		{
			if (App.Game.NewAnimLang){
				App.Game.fluteNum = (App.Game.fluteNum+1)%2
			}else{
				App.Game.fluteNum = (App.Game.fluteNum+1)%App.Level
			}
			Scenes.PlayScene("flute"+App.Level);
		}
		
		private function drumAnim(event:Event = null ):void
		{		
			if (App.Game.NewAnimLang){
				App.Game.drumNum = (App.Game.drumNum+1)%2
			}else{
				App.Game.drumNum = (App.Game.drumNum+1)%App.Level
			}
			Scenes.PlayScene("drum"+App.Level );
		}
		
		// ---------- COLOR --------------------------------
		private function colorAnim(event:*):void
		{
			var colorScene:String = event._Arg as String
			if (App.Level==3){
				if(App.Game.NewAnimLang){
					Scenes.PlayScene(colorScene + "3");
				}else{
					Scenes.PlayScene("gen1"+colorScene);
				}
			}else if (App.Level==1){
		
				Scenes.PlayScene("color1",colorScene);
			}else{
			
				Scenes.PlayScene("color2",colorScene);
			}
		}
	
		// ---------------------------------------------
		
		
	
	
	}
	
	
}