//CCookie
//rewriten Asaf 8 March based on  Miko.A  01/03/07
package
{
	
	import flash.net.SharedObject;
	
	class CCookie
	{
		private var _Name:String;
		private var _Cookie:SharedObject;
		private var _FirstTime:Boolean;
		
		public function CCookie(_Path:String)
		{
			
			_Name = _Path;
			_Cookie = null;
			if(!ReadCookie())
			{
				
				_Cookie.data.UserLang = "EN";
				_Cookie.data.ScreenMode = 2;
				_Cookie.data.Level = 1;
				_FirstTime = true;
				_Cookie.flush();		//write the cookie
			}
			else
				_FirstTime = false;
				
			trace(this  +" FirstTime ="+_FirstTime);
			
		}
		
		private function ReadCookie():Boolean
		{
			
			_Cookie = SharedObject.getLocal(_Name,"/");
			if(_Cookie.data.UserLang != undefined || _Cookie.data.UserLang != null)
				return true;
			return false;
		}	
	
		public function Save(){
			
			_Cookie.data.UserLang = App.UserLang;
			_Cookie.data.UILang = App.UILang;
			_Cookie.data.ScreenMode = App.ScreenMode;
			_Cookie.data.Level = App.Level;
			_Cookie.flush(1000);		
		}	
		public function Load(){
			
			trace(this + " Load FirstTime:" + _FirstTime + "   Level:" +Level + "   UserLang:" +UserLang+"   ScreenMode:" +ScreenMode);
			App.ScreenMode = _Cookie.data.ScreenMode;
			App.UserLang = _Cookie.data.UserLang;
			App.NeedCover = _Cookie.data.NeedCover;
			App.Level = _Cookie.data.Level;
		}
		public function get FirstTime():Boolean{return _FirstTime;}
		public function get Level():Number{return _Cookie.data.Level;}
		public function get UserLang():String{return _Cookie.data.UserLang;}
		
		public function get ScreenMode():Number{return _Cookie.data.ScreenMode;}
		public function toString():String{return "CCookie";}
	}
}