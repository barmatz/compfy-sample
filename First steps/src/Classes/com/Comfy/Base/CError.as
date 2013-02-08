package
{
	import flash.events.*;
	
	public class CError extends EventDispatcher
	{
		public var ErrorMsg:String;
		public var PopUpPage:CScene;
		public var FuncOK:Function;
		public var FuncCancel:Function;
		public var CloseOK:Boolean;
		public var popupOpen:Boolean;
		
		private static var Instance:CError 
		private static var allowInstantiation:Boolean;
		
		public static const DEFUALT:String = "Please Insert Original CD"
		
		public function CError()
		{
			if (!allowInstantiation) {
            	throw new Error("Error: Instantiation failed: Use SingletonDemo.getInstance() instead of new.");
        	  }else{
				PopUpPage = App.Game.Menu.Scene("PopUp");
				CloseOK = true;
				popupOpen = false;
				ErrorMsg = "";
			  }
		}
		
		public static function getInstance():CError
		{
			 if (Instance == null) {
           		 allowInstantiation = true;
           		 Instance = new CError();
           		 allowInstantiation = false;
         	 }
        	 return Instance;
		}
				
		public function OpenPopUp():void
		{
			App.Game.Menu.PlayScene("PopUp","open",false);
		}
		
		public function SetOK(f:Function = null,Close:Boolean = true):void
		{
			if (f != null)
			{
				FuncOK = f;
				this.addEventListener("OK_Press",FuncOK);
			}
			else if (FuncOK != null)
			{
				this.removeEventListener("OK_Press",FuncOK);
			}
			CloseOK = Close;
		}
		
		public function SetCancel(f:Function = null):void
		{
			if (f != null)
			{
				FuncCancel= f;
				this.addEventListener("Cancel_Press",FuncCancel);
			}
			else if (FuncCancel != null)
			{
				this.removeEventListener("Cancel_Press",FuncCancel);
			}
		}
		
		public function ActivateOK():void
		{
			dispatchEvent(new Event ("OK_Press"))
			if (FuncOK != null)
			{
				this.removeEventListener("OK_Press",FuncOK);
			}
			if (CloseOK)
			{
				 ClosePopUp();
			}
		}
		
		public function ActivateCancel():void
		{
			dispatchEvent(new Event ("Cancel_Press"))
			if (FuncCancel != null)
			{
				this.removeEventListener("Cancel_Press",FuncCancel);
			}
			 ClosePopUp();
		}
		
		public function  ThrowErr(msg:String):void
		{
			trace ("ThrowErr:" + msg)
			ErrorMsg = msg;
			dispatchEvent(new Event ("ErrUpdate"));
		}
		
		public  function ClosePopUp():void
		{
			CDebug.Trace("ClosePopUp was called PopUpPage.IsPlaying="+PopUpPage.IsPlaying)
			if(PopUpPage.IsPlaying)
			{
				App.Game.Menu.PlayScene("PopUp","close",false);
			}
		}
			
	}

}
	
	
	