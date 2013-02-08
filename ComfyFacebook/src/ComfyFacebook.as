package
{
	import barmatz.comfy.facebook.FacebookGameWrapper;
	import barmatz.comfy.facebook.GamePointsManager;
	import barmatz.comfy.facebook.JSBridge;
	import barmatz.comfy.facebook.UIFactory;
	import barmatz.comfy.facebook.display.Prompt;
	import barmatz.comfy.facebook.events.FacebookGameWrapperEvent;
	import barmatz.comfy.facebook.events.GamePointsManagerEvent;
	import barmatz.comfy.facebook.events.UIEvent;
	
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	public class ComfyFacebook extends Sprite
	{
		public static const GAME_URL:String = "FirstSteps2.swf",
							APPLICATION_ID:String = "205761636135007";
		
		private static var header:Header,
						   footer:Footer,
						   loader:Loader,
						   prompt:Prompt;
						   
		public function ComfyFacebook()
		{
			super();
			buildUI();
			stage ? initStage() : addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			FacebookGameWrapper.init(APPLICATION_ID, onFacebookGameWrapperInit);
			GamePointsManager.pointsChangeCallback = onGamePointsManagerPointsChange;
		}
		
		private function buildUI():void
		{
			header = UIFactory.createHeader(this);
			header.userMessage = "Loading...";
			
			footer = UIFactory.createFooter(this);
			footer.points = GamePointsManager.points;
			
			loader = UIFactory.createLoader(this, onLoaderComplete);
			loader.mask = new Shape();
		}
		
		private function updateDisplay():void
		{
			loader.x = header.x + (header.width * .5) - (loader.width * .5);
			loader.y = header.getBounds(this).bottom;
			
			if(loader.mask && loader.mask is Shape)
			{
				Shape(loader.mask).graphics.clear();
				Shape(loader.mask).graphics.beginFill(0xFF0000);
				Shape(loader.mask).graphics.drawRect(loader.x, loader.y, loader.width, loader.height);
			}
			
			JSBridge.log(loader.getBounds(this).bottom);
			
			footer.x = loader.x + (loader.width * .5) - (footer.width * .5);
			footer.y = loader.getBounds(this).bottom + 5;
		}
		
		private function initStage():void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, onStageResize, false, 0, true);
			stage.dispatchEvent(new Event(Event.RESIZE));
		}
		
		private function displayPrompt():void
		{
			if(!prompt)
			{
				prompt = UIFactory.createPrompt(this);
				prompt.addEventListener(UIEvent.INVITE, onPromptInvite, false, 0, true);
				prompt.addEventListener(UIEvent.SHARE, onPromptShare, false, 0, true);
			}
		}
		
		private function inviteFriend():void
		{
			JSBridge.request(JSBridge.addCallback("onInviteFriend", onInviteFriend), "Hello world", null, null, null, 1);
		}
		
		private function loadGame():void
		{
			if(prompt && prompt.parent)
				prompt.parent.removeChild(prompt);
			loader.load(new URLRequest(GAME_URL));
		}

		private function onPromptShare(event:Event):void
		{
		}
		
		private function onPromptInvite(event:Event):void
		{			
			inviteFriend();
		}
		
		private function onInviteFriend(event:Object):void
		{
			if(event && event.to)
				event.to.forEach(function(a:String, b:int, c:Array):void 
				{
					footer.points = GamePointsManager.updateInvite();
					footer.addFriendAt(a, footer.profileThumbnailFilled + b);
				});
			GamePointsManager.validate() ? loadGame() : displayPrompt();
		}
		
		private function onStageResize(event:Event):void
		{
			updateDisplay();
		}
		
		private function onAddedToStage(event:Event):void
		{
			initStage();
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onFacebookGameWrapperInit(event:FacebookGameWrapperEvent):void
		{
			JSBridge.api(JSBridge.addCallback("onGetUserData", onGetUserData), "/me");
			footer.loadCachedFriends();
			switch(event.type)
			{
				case FacebookGameWrapperEvent.HAS_POINTS:
					loadGame();
					break;
				case FacebookGameWrapperEvent.NO_POINTS:
					displayPrompt();
					break;
			}
			updateDisplay();
		}
		
		private function onGetUserData(event:Object):void
		{
			if(event.name)
				header.userName = event.name;
		}
		
		private function onRequest(event:Object):void
		{
			JSBridge.log("onRequest", event);
		}
		
		private function onGamePointsManagerPointsChange(event:GamePointsManagerEvent):void
		{
			const POINTS:Number = event.points;
			footer.points = POINTS;
			if(POINTS < GamePointsManager.MINIMUM_POINTS)
				displayPrompt();
		}
		
		private function onLoaderComplete(event:Event):void
		{
			updateDisplay();
		}
	}
}