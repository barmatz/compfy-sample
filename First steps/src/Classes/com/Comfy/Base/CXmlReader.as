package
{
	
	import flash.events.*;
	import flash.net.*;
	
	public class CXmlReader extends EventDispatcher
	{
		
		private var _xml:XML;
		//?private var _MainNodes:XMLNode;
		private var _path:String;
		private var _Loader:URLLoader;
		//private var datReader:CDatReader;
		
		public function CXmlReader()
		{
			XML.ignoreComments = true;
			XML.ignoreWhitespace = true;
			_xml= new XML();
			_path = "";
		}
		
		// load data filr from path string;
		public function Load(path:String):void
		{
			if(path!=null)
			{
				_path = path;
				CDebug.Trace(this +" =  LoadXML " + path);
				_Loader =  new URLLoader();
				_Loader.addEventListener(Event.COMPLETE,OnLoad);
				_Loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				/*
				_Loader.addEventListener(ProgressEvent.PROGRESS, ProgressHandler);
				_Loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, StatusHandler);
				*/
				_Loader.load(new URLRequest(path));
						
			}
		}
		
		// I keep this functiuon although  I didn't found any refrence to it in the other classes.
		// I also keep it not case sensative otherwise it could be much simpler.
		public function GetNode(flag:String):XML
		{			
			var _AllxmlScenes:XMLList = _xml.children();
			for (var i:uint; i<_AllxmlScenes.length(); i++){
				
				if (_AllxmlScenes[i].localName().toUpperCase() == flag.toUpperCase())
				{
					return (_AllxmlScenes[i] as XML)
				}
			}
			return null;	
		}
		
		public function Close(){
		
			_xml = null;
		}
		
		public function OnLoad(event:Event):void
		{
		
			CDebug.Trace("CXmlReader: Dispatch OnLoad ")
			_xml = XML(event.target.data);
			dispatchEvent(new Event("OnLoad"));
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void 
		{
           CDebug.Trace("CXmlReader: ioErrorHandler: " + event);
		   CDebug.Trace("CXmlReader: ioErrorHandler: " + event.text);
        }
		/*
		private function ProgressHandler(event:ProgressEvent):void 
		{
           CDebug.Trace("CXmlReader: ProgressHandler: " + event);
		   CDebug.Trace("CXmlReader: ProgressHandler: " + event.text);
        }
		private function StatusHandler(event:HTTPStatusEvent):void 
		{
           CDebug.Trace("CXmlReader: StatusHandler: " + event);
		   CDebug.Trace("CXmlReader: StatusHandler: " + event.text);
        }
		*/
		public function get Data():XML{return _xml as XML}
		public function Nodes(index:uint):XMLList{return _xml.child(index);}
		public function get NodeCount():uint{return _xml.children().length();}
		public override function toString():String {return "CXmlReader";};
	
	}
}