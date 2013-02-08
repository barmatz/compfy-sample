package
{
	
	import flash.display.MovieClip;
	
	public class CUIelement extends MovieClip{

		function CUIelement()
		{
			//constractor
		}
	
		function changeUIlang():void
		{
			this.gotoAndStop(App.UILang)
		}
	

	}
}