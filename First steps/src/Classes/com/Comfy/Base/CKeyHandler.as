package
{
	import flash.display.Sprite;
    import flash.display.DisplayObject;
	import flash.events.*;
	import flash.display.Stage;
	import flash.system.*;
	
	public class CKeyHandler extends Sprite
	{
		
		private var _Keys:Array;					//Keys
		private var _DKey:CDefaultKey;				//Default key = Any Key On Keyboard
		private var _Ready:Boolean;
		//private var _Handler_MC:MovieClip;
		private var _LangsXML:XML;
		private var _KeyBardLang:String;
		private var datReader:CXmlReader;
		private var CharCodesHeb:Array = new Array (84,67,68,83,86,85,90,74,89,72,76,70,75,79,78,73,66,88,71,0,0,0,0,69,82,65)
		private var CharCodesArb:Array = new Array (72,70,0,74,69,0,0,79,86,67,78,66,83,65,0,0,88,90,85,89,0,0,0,0,0,0,84,82,0,71,76,75,73,0,0,68)
		
		
		
		/*
		
		private var keyInterval:Number
		*/
		public function CKeyHandler(){
		
			
			_Keys = new Array();
			//_Handler_MC = _root.createEmptyMovieClip("_Handler_MC",9999);
			//_Handler_MC.onEnterFrame = Delegate.create(this,CheckKey);
			_DKey  = new CDefaultKey(null,null,null);
			_Ready = false;
			//addEventListener(Event.ADDED,Init);
			/*
			//ssCore.Keyboard.setNotify({event:"OnKey", keyName:"Escape"}, {callback:Delegate.create(this,Escape)})
			*/
		}
		
		public function GetKeyboardLang():void
		{
			_KeyBardLang = App.Projector.SystemLanguage(); //Capabilities.language // that should move from here! ---> move to CexeCantroller
			CDebug.Trace (">>>>>>>>>>>>>_KeyBardLang ="+_KeyBardLang )
			ReadKeyboardXML();
		}	
		
		public function ReadKeyboardXML():void
		{
		
			trace(this  + ".ReadKeyboardXML was called");
			
			//getting the keyboard Array
			_LangsXML = new XML();
			datReader  = new CXmlReader() //this,_LangsXML);
			if (App.Projector.Type == "Studio")
			{
				datReader.addEventListener("OnLoad" ,LoadXMLStudio);
			}
			else
			{
				datReader.addEventListener("OnLoad" ,LoadXML);
			}
			
			datReader.Load(App.StartDirURL+"Langs.xml"); 
		}	
		
		public function AddKey(k:int,n:String):void
		{
		
			var newKey:CKey = new CKey(k,n,null,null);
			_Keys.push(newKey);
			//trace(this + " Key Added "+ newKey.Name + " Code:"+newKey.Code);
			
		}
		
		public function Listen(flag:Boolean):void
		{
			
			if(flag == true)
			{
				trace(this + " Start Listen");
				stage.addEventListener(KeyboardEvent.KEY_DOWN,OnKeyDown)
			}
			else
			{
			
				trace(this + " Stop Listen");
				stage.removeEventListener(KeyboardEvent.KEY_DOWN,OnKeyDown)
			}
		}	
		
		
		
		private function CheckKey(){
		
			_Ready = true;
		}
		
		private function SearchKeyByName(n:String):CKey
		{
		
			for(var i:uint=0;i< _Keys.length;i++)
			{
				if(_Keys[i].Name == n.toUpperCase())
					return _Keys[i];
			}
			return null;
		}	
		
		private function SearchKeyByKey(k:Number):CKey
		{
			for(var i:uint=0;i< _Keys.length;i++)
			{
				if(_Keys[i].Code == k)
					return _Keys[i];
				}
			return null;		
		}	
		
		public  function RegisterKey(KeyName:String,p:Object,Func:Function,Arg:Object=null):void
		{
		
			if(KeyName.toUpperCase() == "ANYKEY")
			{
				_DKey.Set(p,Func,Arg);
				return;
			}
			var _key:CKey = SearchKeyByName(KeyName);
			if(_key != null)
			{
				_key.Set(p,Func,Arg);
			}
		}	
		
		public  function UnRegisterAllKeys(){
		
			for(var i:uint=0; i< _Keys.length;i++)
				_Keys[i].UnRegister();
		}
		
		public function UnRegisterKey(KeyName:String){
		
			var _key:CKey = SearchKeyByName(KeyName);
			if(_key.Name != "AnyKey")
				_key.UnRegister() //null,null,null);
		}	
		
		
		public override function toString():String {return "CKeyHandler";}
		
		// ----------Events Hnadler ------------------------
		
		private function LoadXML(event:Event){
			
			_LangsXML = datReader.Data as XML
			var DefaultLang:String = _LangsXML.DefaultLanguage.@locale.toString() // Defualt Lang was X1033 - English now is en-US
			var NumLangs:uint = _LangsXML.child("Lang").length();  //Number of Langs
			var tKey:Object = new Object()
					
			for (var i:uint=0; i<NumLangs; i++)
			{
				
				var LangHolder:XML = _LangsXML.child("Lang")[i];
				
				if((LangHolder.@locale.toString() == DefaultLang) || (LangHolder.@locale.toString().substr(0,2) == _KeyBardLang ))
				{
						
					for (var j:uint=0; j<LangHolder.children().length();j++)
					{
						//trace(LangHolder.children()[j].@name.toString().toUpperCase(),LangHolder.children()[j].@code.toString())
						CDebug.Trace(LangHolder.children()[j].@name.toString().toUpperCase()+","+LangHolder.children()[j].@code.toString())
						tKey[LangHolder.children()[j].@name.toString().toUpperCase()] =  LangHolder.children()[j].@code.toString()
					}
				}
			}	
			
			for (var str:String in tKey){
//				CDebug.Trace(int(tKey[str]),str)
				AddKey(int(tKey[str]),str)
			}
			CDebug.Trace("_Keys.length="+_Keys.length)
			_LangsXML = null;
			E_OnReady();
			
		}	
		
		
		private function LoadXMLStudio(event:Event){
			
			_LangsXML = datReader.Data as XML
			CDebug.Trace ("##### LoadXMLStudio Sucsses "+ _LangsXML.DefaultLanguage)
			var DefaultLang:String = _LangsXML.DefaultLanguage.toString() // Defualt Lang was X1033 - English now is en-US
			var NumLangs:uint = _LangsXML.child("Lang").length();  //Number of Langs
			var tKey:Object = new Object()
					
			for (var i:uint=0; i<NumLangs; i++)
			{
				
				var LangHolder:XML = _LangsXML.child("Lang")[i];
				
				if((LangHolder.@code.toString() == DefaultLang) || ( LangHolder.@code.toString().toUpperCase() == _KeyBardLang.toUpperCase() ))
				{
					//CDebug.Trace("------------->LangHolder.@code.toString()="+LangHolder.@code.toString()+"<------------------")
					for (var j:uint=0; j<LangHolder.children().length();j++)
					{
						
						//CDebug.Trace(LangHolder.children()[j].@name.toString().toUpperCase()+","+LangHolder.children()[j].@code.toString())
						tKey[LangHolder.children()[j].@name.toString().toUpperCase()] =  LangHolder.children()[j].@code.toString()
					}
				}
			}	
			
			for (var str:String in tKey){
//				CDebug.Trace(int(tKey[str]),str)
				AddKey(int(tKey[str]),str)
			}
			CDebug.Trace("_Keys.length="+_Keys.length)
			_LangsXML = null;
			E_OnReady();
			
		}
		
		private function OnKeyDown(event:KeyboardEvent):void
		{
			var key = event.keyCode;
			//
			var CharCode:int = event.charCode
			
			if (!key)
			{
				key  = CharToKey(CharCode);
			}
			//
			trace(this + " onKeyDown: key = " + key+ " _Ready="+_Ready);
			
			if(_Ready ) //&& key !=27
			{
				/*_Ready=false
				//keyInterval=setInterval(function(){clearInterval(keyInterval);_Ready=true},50)
				//keyInterval=setInterval(Delegate.create(this,ClearInterval) ,85)*/
				var _k:CKey = SearchKeyByKey(key);
				if((_k != null)) // && (_k.Name !="ESCAPE"))
					_k.Activate();
				else 
					_DKey.Action(key);
			}
		
		}
		
		public function Activate(key:String):void
		{
		
			var _key:CKey = SearchKeyByName(key);
			if(_key != null)
			{
				trace(this +".Activate " + key );
				_key.Activate();
			}
		}	
		
		private function CharToKey(cCode:uint):uint
		{

			
			if (cCode<1575)
			{
				return CharCodesHeb[cCode-1488];
			}
			else
			{
				return CharCodesArb[cCode-1575];
			}
		}
		// ----------Events Dispachers ------------------------
		
		
		public function E_OnReady(){
			CheckKey() // only temp
			//var EventObject:Object = {target:this, type:'OnReady'}; 
			dispatchEvent(new Event("OnReady"));
		}
		
	}
}