package
{
	
	import flash.display.*;
	import flash.events.*;
	
	public class WinActivater extends MovieClip
	{
		
		
		public var Wnd:NativeWindow;
		public var Self:NativeWindow;
		
		public function WinActivater(wn:NativeWindow)
		{
			CDebug.Trace("WinActivater was called "+App.UILang)
			Wnd=wn;
			addEventListener(Event.ADDED_TO_STAGE,onAdded);
			App.Projector.addEventListener("NeedFocus",Activate);
		}
		
		public function Activate(event:Event = null):void
		{
			
			CDebug.Trace("Activate was called")
			Wnd.activate();
			if (Self != null)
			{
				//Self.close();
			}
		}
		
		public function onAdded(event:Event):void
		{
			CDebug.Trace("WinActivater was called ADDED_TO_STAGE")
			Self = this.stage.nativeWindow;
			Self.orderToFront();
			//Activate();
			trace (this.stage.nativeWindow)
			
		}
		
		
	}
	
}