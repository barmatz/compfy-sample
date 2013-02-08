package
{
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.net.*;
	import flash.events.*;
	import flash.system.LoaderContext;
	
	public class CDMenu extends MovieClip
	{
		
		var SenderConn:LocalConnection ;	
		var ReciverConn:LocalConnection; 
		var Data:Object;	
		var ByteLoader:URLLoader;
		var loader:Loader ;
		var Req:URLRequest;
		var ReqString:String
		var myLoaderContext:LoaderContext;
		var ConnName:String;
		var Target:Sprite;
		
		public function CDMenu()
		{
			SenderConn= new LocalConnection();
			SenderConn.allowDomain('*')
			Target = this;
		}
		

		public function Transmit(event:Event=null):void
		
		{
			//CDebug.Trace("Transmit in parent Section");
			try
			{
				SenderConn.send(ConnName,"SetData",Data);
				ReciverConn.close()
			}
			catch(e:*)
			{
				CDebug.Trace("Catched Transmit"+e)
			}
		}
		
		public function loadAVM1(event:Event=null,trg:Sprite = null):void
		{
			CDebug.Trace("loadAVM1 in CDMENU");
			if (loader==null)
			{
			
				loader = new Loader() ;
				//loader.contentLoaderInfo.addEventListener(Event.INIT, onInit);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);			
			}
			
			if (trg != null)
			{
				Target = trg;
			}
			else
			{
				Target = this;
			}
			Req= new URLRequest(ReqString);
			loader.load(Req);
			
		}
		
		// ------------------------ EVENT HENDLER ---------------------------------------//
		
		private function ioErrorHandler(event:IOErrorEvent):void 
		{
		  
		  //CDebug.Trace("ioErrorHandler in parent Section")
		  if (Req.url == ReqString)
		   {
			   var str:String = "Menu/"+ReqString; //App.StartDirURL //"file:///D:/Development/FirstSteps_4/Menu/parentSection.swf" //
			   CDebug.Trace("ioErrorHandler in "+ this.name+": path to parent section= "+str);
			   Req = new URLRequest(str);
			   loader.load(Req);
		   }
		   else
		   {
				//trace("ioErrorHandler: Req.url=" + Req.url);
				//CDebug.Trace("ioErrorHandler: Req.url=" + Req.url);
		   }			
		}
		
		
		public function completeHandler(event:Event):void 
		{
		
			CDebug.Trace("completeHandler in parent Section");
			//var Clip:AVM1Movie = event.target.content as AVM1Movie;
			//loader.addEventListener(MouseEvent.CLICK,onMenuClick);
			Target.addChild(loader);
			SenderConn.addEventListener(StatusEvent.STATUS, onStatus);
			//SenderConn.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncERROR)
			SenderConn.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			
			ReciverConn  = new LocalConnection();
			ReciverConn.client = this;
			ReciverConn.connect("AVM1"+ConnName);
			ReciverConn.allowDomain('*')
			
			ReciverConn.addEventListener(StatusEvent.STATUS, onStatus);

		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void {
           // CDebug.Trace("securityErrorHandler: " + event);
        }
		
		private function onStatus(event:StatusEvent):void 
		{
			//CDebug.Trace(""+event )
			//CDebug.Trace(" onStatus:target: "+event.target )
			switch (event.level) {
				case "status":
					CDebug.Trace("LocalConnection.send() succeeded");
					break;
				case "error":
				   CDebug.Trace("LocalConnection.send() failed");
					break;
			}
		}
		
		
	
	}	
	
}