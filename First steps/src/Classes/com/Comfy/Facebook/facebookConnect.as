/**
* @author Almog Koren "Almog Design" - www.almogdesign.net, almog@almogdesign.net
*/
package com.almogdesign.facebook
{

	/* Flash imports */
	import flash.display.MovieClip;
	import flash.display.LoaderInfo;
	import flash.events.MouseEvent;
	import flash.events.*;
	import flash.utils.*;

	/* Facebook libraries */
	import com.facebook.Facebook;
	import com.facebook.events.*;
	import com.facebook.utils.FacebookSessionUtil;
	import com.facebook.commands.notifications.*;
	import com.facebook.commands.stream.*;
	import com.facebook.commands.users.*;
	import com.facebook.commands.friends.*;
	import com.facebook.data.users.*;
	import com.facebook.data.friends.*;
	import com.facebook.net.FacebookCall;

	/* Custom Events */
	import com.almogdesign.events.validateFacebookLogin;


	/**
	* Constructor, connects to Facebook
	*/
	public class facebookConnect extends MovieClip
	{

		/* param Facebook */
		public var fBook:Facebook;

		/* param FacebookSessionUtil */
		public var fbSession:FacebookSessionUtil;

		/* param FacebookCall */
		private var fbCall:FacebookCall;


		/* param String API and secret keys */
		private var apiKey:String = "58a9af931705a2cd9ad7944306aaca17";
		private var secretKey:String = "ea86f6fa487dace1377130abdaa3b7cd";

		/* param LoaderInfo */
		private var info:LoaderInfo;

		/* param Object will store all variables Facebook will pass to the movie */
		public var passedVars:Object;

		/* param Object callbacks */
		var callbackFunction:Object = { };
		
		/* the session user's data */
		public var userInfo:FacebookUser;
		public var userFriends:Array;


		/**
		* Facebook Connect
		* param loaderInfo
		*/
		public function facebookConnect(loaderInfo)
		{
			info = loaderInfo;
			fbSession = new FacebookSessionUtil(apiKey,secretKey,info);
			fBook = fbSession.facebook;
			
			/* Request the user's info */
			var _this:facebookConnect = this;
			getUser(function (info:FacebookUser):void {
				_this.userInfo = info;
			});
			getFriends(function (info:Array):void {
				_this.userFriends = new Array();
				for (var i:Number = 0; i < info.length; i++) {
					var obj:Object = info[i];
					_this.userFriends.push(obj.uid);
				}
			});
		}

		/**
		* Get vars
		*/
		public function get_vars():String
		{
			var varname:String;
			var varvalue:String;
			var returnText:String;

			passedVars = info.parameters;
			returnText = "DEFAULT VARS PASSED BY FACEBOOK:\n\n";
			for (varname in passedVars)
			{
				varvalue = String(passedVars[varname]);
				returnText += varname + ":\t" + varvalue + "\n";
			}

			return returnText;
		}

		/**
		* Get users 
		*/
		public function getUser(cbFn)
		{
			var call:FacebookCall=fBook.post(new GetInfo([fBook.uid],['uid','name','pic_square']));
			call.addEventListener(FacebookEvent.COMPLETE, handle_getUserComplete);
			callbackFunction['getUser']=cbFn;
		}
		
		/**
		 * Returns a list of user ids, names, and profile pics
		 * @param	cbFn
		 */
		public function getUsersInfo (userids:Array, callback:Function):void {
			var call:FacebookCall = fBook.post(new GetInfo(userids, ['uid', 'name', 'pic_square']));
			call.addEventListener(FacebookEvent.COMPLETE, handle_getUsersInfoComplete);
			callbackFunction['getUsersInfo'] = callback;
		}

		/**
		* Get friends 
		*/
		public function getFriends(cbFn):void
		{
			var call:FacebookCall = fBook.post(new GetFriends());
			call.addEventListener(FacebookEvent.COMPLETE, handle_getFriendsComplete);
			callbackFunction['getFriends']=cbFn;
		}

		/**
		* User id
		*/
		public function getLoggedInUserId():String
		{
			return fBook.uid;
		}
		
		/**
		 * Returns the user's profile pic
		 * @return	String
		 */
		public function getLoggedInUserPicture ():String
		{
			if (userInfo) 
			{
				return userInfo.pic_square;
			} else 
			{
				return '';
			}
		}
		
		/**
		 * Runs when the get many user info function is complete
		 * @param	FacebookEvent
		 */
		private function handle_getUsersInfoComplete (event:FacebookEvent):void {
			var getInfoData:GetInfoData = GetInfoData(event.data);
			callbackFunction['getUsersInfo'](getInfoData);
		}

		/**
		* User complete 
		* param FacebookEvent
		*/
		private function handle_getUserComplete(event:FacebookEvent):void
		{
			var getInfoData:GetInfoData=GetInfoData(event.data);
			var user:FacebookUser=FacebookUser(getInfoData.userCollection.getItemAt(0));
			callbackFunction['getUser'](user);
		}

		/**
		* Friends complete 
		* param FacebookEvent
		*/
		private function handle_getFriendsComplete(event:FacebookEvent)
		{
			var getFriendInfoData:GetFriendsData=GetFriendsData(event.data);

			var len:uint=getFriendInfoData.friends.length;
			var friendIdArray:Array = new Array();

			for (var i:uint = 0; i < len; i++)
			{
				friendIdArray.push(getFriendInfoData.friends.getItemAt(i).uid);
			}

			var call:FacebookCall=fBook.post(new GetInfo(friendIdArray,["name",'pic_square']));
			call.addEventListener(FacebookEvent.COMPLETE, handle_getFriendsInfo);
		}

		/**
		* Get friends info
		* @param FacebookEvent
		*/
		private function handle_getFriendsInfo(event:FacebookEvent)
		{
			var getInfoData:GetInfoData=GetInfoData(event.data);
			var users:Array=[];
			for (var i:uint = 0; i < getInfoData.userCollection.length; i++)
			{
				var user:FacebookUser=FacebookUser(getInfoData.userCollection.getItemAt(i));

				users.push({uid:user.uid, name:user.name, pic:user.pic_square});
			}
			callbackFunction['getFriends'](users);
		}
	}
}