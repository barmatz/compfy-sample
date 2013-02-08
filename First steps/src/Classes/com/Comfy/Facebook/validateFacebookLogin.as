/**
* @author Almog Koren "Almog Design" - www.almogdesign.net, almog@almogdesign.net
*/
package com.almogdesign.events
{

	/* Flash imports */
	import flash.events.*;
	import flash.display.*;


	public class validateFacebookLogin extends Event
	{

		/* static props */
		public static const VALIDATE_FACEBOOK_LOGIN = "validateFacebookLogin";
		
		/* Properties */
		public var login:Boolean;

		/**
		 * Construct
		 * param Boolean 
		 * param Boolean 
		 */
		public function validateFacebookLogin(loginAt:Boolean, bubbles:Boolean = true):void
		{
			//trace("Event validateFacebookLogin");
			super(VALIDATE_FACEBOOK_LOGIN,  bubbles);
			login = loginAt;
		}

	}
}