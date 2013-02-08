package barmatz.comfy.facebook
{
	import barmatz.comfy.facebook.display.Prompt;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.Stage;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;

	public class UIFactory
	{
		public function UIFactory()
		{
			throw new IllegalOperationError("This is a static class and should not be initiated.");
		}
		
		public static function createHeader(target:DisplayObjectContainer):Header
		{
			return Header(target.addChild(new Header()));
		}
		
		public static function createFooter(target:DisplayObjectContainer):Footer
		{
			return Footer(target.addChild(new Footer()));
		}
		
		public static function createLoader(target:DisplayObjectContainer, completeHandler:Function = null):Loader
		{
			const LOADER:Loader = Loader(target.addChild(new Loader()));
			if(completeHandler != null)
				LOADER.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler, false, 0, true);
			return LOADER;
		}
		
		public static function createPrompt(target:DisplayObjectContainer):Prompt
		{
			const PROMPT:Prompt = Prompt(target.addChild(new Prompt()));
			PROMPT.addEventListener(Event.ADDED_TO_STAGE, onPromptAddedToStage, false, 0, true);
			if(PROMPT.stage)
				PROMPT.dispatchEvent(new Event(Event.ADDED_TO_STAGE));
			return PROMPT;
		}
		
		private static function onPromptAddedToStage(event:Event):void
		{
			const OBJECT:DisplayObject = DisplayObject(event.currentTarget),
				  STAGE:Stage = OBJECT.stage;
			OBJECT.x = (STAGE.stageWidth * .5) - (OBJECT.width * .5);
			OBJECT.y = (STAGE.stageHeight * .5) - (OBJECT.height * .5);
		}
	}
}