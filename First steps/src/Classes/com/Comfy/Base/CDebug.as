
package
{
	
	import flash.text.*;
	
	public class CDebug
	{
		
		public static var On:Boolean;
		public static var Txt:TextField;
		
		public static function Create(flag:Boolean,txtField:TextField = null){
			
			On = false;
			if(flag)
				On = true;
			Txt = txtField;
		}
		
		public static function Trace(err:String){
			
		trace(err);
		if (On)
			{
				/*
				
				if (App.Projector.Type == "Studio")
				{
					//ssDebug.trace(err)
				}*/
				
				
				if (Txt != null)
				{
					Txt.appendText("\n"+err);
				}
			}
		}
		
		public static function toString():String{return "CDebug";}
			
	}
}
