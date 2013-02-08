package barmatz.comfy.facebook
{
	import barmatz.comfy.facebook.events.FacebookGameWrapperEvent;
	
	import flash.errors.IllegalOperationError;
	import flash.net.SharedObject;

	public class FacebookGameWrapper
	{
		private static var initCallback:Function;
		
		public function FacebookGameWrapper()
		{
			throw new IllegalOperationError("This is a static class and should not be initiated.");
		}
		
		public static function init(applicationID:String, callback:Function):void
		{
			initCallback = callback;
			JSBridge.init(applicationID, JSBridge.addCallback("onInit", onInit));
		}
		
		private static function saveAuthResponse(response:Object):void
		{
			JSBridge.accessToken = response.accessToken;
			JSBridge.userID = response.userID;
		}
		
		private static function onInit():void
		{
			JSBridge.getLoginStatus(JSBridge.addCallback("onGetLoginStatus", onGetLoginStatus));
		}
		
		private static function onGetLoginStatus(event:Object):void
		{
			switch(event.status)
			{
				default:
					JSBridge.login(JSBridge.addCallback("onLogin", onLogin));
					break;
				case FacebookStatus.CONNECTED:
					onLogin(event);
					break;	
			}
		}
		
		private static function onLogin(event:Object):void
		{
			if(event.authResponse)
				saveAuthResponse(event.authResponse);
			initCallback(new FacebookGameWrapperEvent(GamePointsManager.validate() ? FacebookGameWrapperEvent.HAS_POINTS : FacebookGameWrapperEvent.NO_POINTS));
			 
			GamePointsManager.start();
			
		}
		
		private static function onLogout(event:Object):void {}
		
		public static function get sharedObject():SharedObject
		{
			return SharedObject.getLocal("comfy/facebook");
		}
	}
}