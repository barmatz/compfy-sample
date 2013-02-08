package  {
	
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import fl.controls.ProgressBar;
	import fl.controls.ProgressBarMode;
	import fl.transitions.Tween;
	import	fl.transitions.TweenEvent;
	import fl.transitions.easing.*;
	import org.osflash.signals.natives.*;
	
	public class PBar extends Sprite{

		
		//private var _pb:ProgressBar;
		private var _id:String;
		private var _vis:Boolean;
		private var _alphaTween:Tween;
		private var _percent:Number;
		protected var _progressBar : Sprite;
		protected var _field : TextField;
		public var clicked:NativeSignal;
		
		
		public function PBar(LoaderID:String, xpos:Number = 0, ypos:Number = 0) {
			
			// constructor code
			_id=LoaderID;
			this.x = xpos;
			this.y = ypos;
			this.alpha =0;
			_vis = false;
			clicked  = new NativeSignal(this,MouseEvent.CLICK,MouseEvent);
			 initBar();
			 initField();
		}
		
		protected function initBar():void
		{
		
			
			_pb = new ProgressBar()
			_pb.mode = ProgressBarMode.MANUAL;
			
			_pb.width = 200;
			_pb.height =18;
			
			_pb.setStyle("indeterminateSkin",ProgressBar_ComfyIndeterminateSkin);
			_pb.setStyle("barSkin",ProgressBar_ComfyBarSkin);
			_pb.setStyle("trackSkin",ProgressBar_ComfyTrackSkin);
			/*
			_progressBar = new Sprite();
			_progressBar.graphics.beginFill(0x00FF00);
			_progressBar.graphics.drawRect(0, 0, 20, 20);
			_progressBar.width = 20;			
			addChild(_progressBar);
			*/
			addChild(_pb);
		}
		
		protected function initField():void
		{
			
			txtFont = new _arial();
	
		
	
			
			var txtFormat:TextFormat = new TextFormat();
			txtFormat.font = txtFont.fontName; //"Arial"
			txtFormat.align = "center";
			txtFormat.size = 10;
			txtFormat.color = 0x102010;
			
			
			_field = new TextField();
			_field.defaultTextFormat = txtFormat // new TextFormat("Arial", 10);
			_field.embedFonts = true;
			_field.multiline = true;
			_field.selectable = false;
			_field.wordWrap = false;
			_field.width = 200;
			_field.height = 20;
			_field.y = 1;
			_field.x = 0;


			addChild(_field);
		}
		
		public function updateBar(dat:Number , loaded:Number , total:Number):void
		{
			//trace ("updateBar",dat)
			//var w:Number = Math.round(loaded*100/total)
			//_progressBar.width = w+20
			_pb.setProgress	(loaded,total);
			_percent = dat 
			_field.text = String(int(dat))+ "%"//("+ String(int(loaded)) + "/"+String(int(total)) +")"
			if (!_vis && !IsTweening())
			{
				 FadeIn();
			}
			if (_vis && dat >= 100 && !IsTweening())
			{
				FadeOut();
			}
		}
		
		
		private function FadeIn():void
		{
			_alphaTween = new Tween(this,"alpha",Regular.easeInOut,0,100, 2, true);
			_alphaTween.addEventListener(TweenEvent.MOTION_FINISH,OnTweenFinished);
			
		}
		
		private function FadeOut():void
		{
			_alphaTween = new Tween(this,"alpha",Regular.easeInOut,100,0, 2, true);
			_alphaTween.addEventListener(TweenEvent.MOTION_FINISH,OnTweenFinished);
			
		}
		
		private function OnTweenFinished (event:TweenEvent = null):void
		{
			_vis = !_vis
			if (_alphaTween != null && _alphaTween.hasEventListener(TweenEvent.MOTION_FINISH) )
			{
				_alphaTween.removeEventListener(TweenEvent.MOTION_FINISH,OnTweenFinished);
			}
			if (_vis && _percent == 100)
			{
				FadeOut();
			}
			
			
		
		}
		
		private function IsTweening():Boolean
		{
			if (_alphaTween==null)
			{
				return false;
			}
			
			if (_alphaTween.isPlaying)
			{
				return true;
			}
			
			return false;
		}
		
		public function Hide():void
		{
			trace (this,"Hide was called", _vis)
			if (IsTweening())
			{
				_alphaTween.stop();
			}
			else
			{
				_alphaTween.addEventListener(TweenEvent.MOTION_FINISH,OnTweenFinished);
			}
			
			
			if (this.alpha>0)
			{
				_vis = true;
				_alphaTween = new Tween(this,"alpha",Regular.easeInOut,this.alpha,0, 0.5, true);
				
			}
		}
		
		public function get ID():String{return _id};

	}
	
}
