package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.events.MouseEvent;
	import org.osflash.signals.Signal;
	
	
	
	public class Scrollbar extends Sprite{
		
		public var value:Number;
		public var padding:Number = 5;
		
		private var max:Number;
		private var min:Number;
		
		public function Scrollbar() {
			
			min = bar_mc.y
			max = bar_mc.height - drag_mc.height;
			drag_mc.y= min;
			drag_mc.buttonMode = true;
			drag_mc.addEventListener(MouseEvent.MOUSE_DOWN,dragHandle);
			up_btn.addEventListener(MouseEvent.MOUSE_DOWN,btnHandler);
			down_btn.addEventListener(MouseEvent.MOUSE_DOWN,btnHandler);
		}
		
		
		public function UpdateScroll(val:Number)
		{
			value = val;
			drag_mc.y = val*max + min
		}
		
		private function btnHandler(e:MouseEvent = null ):void
		{
			var ypos:Number = drag_mc.y
			if (e.currentTarget == up_btn)
			{
				ypos -=10
			}
			else
			{
				
				ypos +=5
			}
			if (ypos < min){ypos = min}
			if (ypos>max+20){ypos = max+20}
			drag_mc.y  = ypos;
			updateValue();
		}
		
		private function dragHandle(e:MouseEvent = null ):void
		{
			drag_mc.startDrag(false,new Rectangle(0,min,0,max));
			stage.addEventListener(MouseEvent.MOUSE_UP,stopDragging)
			stage.addEventListener(MouseEvent.MOUSE_MOVE,updateValue)
		}
		
		private function stopDragging(e:MouseEvent = null ):void
		{
			drag_mc.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP,stopDragging);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,updateValue);
		}
		private function updateValue(e:MouseEvent = null ):void
		{
			value = (drag_mc.y - min)/max;
			dispatchEvent(new Event(Event.CHANGE))
		}
	}
	
}
