	
package
{
	
	import flash.net.SharedObject;
	import com.comfy.App;
	
	public class FSCookie
	{
		
		private static var allowInstantiation:Boolean;
		private static var instance:FSCookie;
		private var NAME:String  //= "FSspcieal";
		private var _Cookie:SharedObject  // this crate an instance var, this is why i use singlton and not static class.
		private var _visits:Number;
		private var _viewMarketing :Boolean; // true = user do NOT want to see marketing materials and parents Tips
		 
		
		public function FSCookie(){
			if (!allowInstantiation) 
			{
				throw new Error("Error: Instantiation failed: Use SingletonDemo.getInstance() instead of new.");
			}
			else
			{
				
				NAME = App.GameName+"_market"
				_Cookie = null;
				if(!ReadCookie())
				{
					_Cookie.data.Visits = 1
					_Cookie.data.ViewMarketing = false;
					_Cookie.flush();		//write the cookie
					_visits=1
					_viewMarketing = false
				}
				else
				{
					_visits = _Cookie.data.Visits+1
					_viewMarketing = _Cookie.data.ViewMarketing
					_Cookie.data.Visits = _visits;
					_Cookie.flush(1000);	
				}
			}
		}
		
		public static function getInstance():FSCookie
		{
			if (instance==null)
			{
				allowInstantiation = true;
				instance = new FSCookie();
				allowInstantiation = false;
			}else{
				trace(" Only one instance of FSCookie is alowed ")
			}
			return instance;
		}
		
		private function ReadCookie():Boolean{
			
			_Cookie = SharedObject.getLocal(NAME,"/");
			if( _Cookie.data.Visits != null)
				return true;
			return false;
		}	
		
		public function get Visits():Number{return _visits}
		public function get ViewMarketing():Boolean{return _viewMarketing}
		public function set ViewMarketing(val:Boolean ){
			_viewMarketing = val
			_Cookie.data.ViewMarketing = _viewMarketing; 
			_Cookie.flush(1000);	
			}
		
		public function toString():String{return "FSCookie";}
	}
	
}