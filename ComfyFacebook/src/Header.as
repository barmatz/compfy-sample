package 
{
	import barmatz.comfy.facebook.JSBridge;
	import barmatz.comfy.facebook.display.NavigationBar;
	
	import flash.display.Sprite;
	import flash.external.ExternalInterface;

	[SWF(width="760", height="30")]
	
	public class Header extends Sprite
	{
		private var navigationBar:NavigationBar,
					_userName:String = "";
		
		public function Header()
		{
			super();
			createNavigationBar();
		}
		
		private function createNavigationBar():void
		{
			if(navigationBar)
				destroyNavigationBar();
			navigationBar = new NavigationBar();
			navigationBar.messageField.text = "";
			addChild(navigationBar);
		}
		
		private function destroyNavigationBar():void
		{
			if(navigationBar.parent)
				navigationBar.parent.removeChild(navigationBar);
			navigationBar = null;
		}
		
		private function onGetUser(event:Object):void
		{
			if(event.response && event.response.name)
				userName = event.response.name;				
		}
		
		public function get userName():String
		{
			return _userName;
		}
		
		public function set userName(value:String):void
		{
			_userName = value;
			userMessage = "Hello " + userName;
		}
		
		public function get userMessage():String
		{
			return navigationBar.messageField.text;
		}
		
		public function set userMessage(value:String):void
		{
			navigationBar.messageField.text = value;
		}
	}
}