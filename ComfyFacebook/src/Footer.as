package 
{
	import barmatz.comfy.facebook.FacebookGameWrapper;
	import barmatz.comfy.facebook.GamePointsManager;
	import barmatz.comfy.facebook.JSBridge;
	import barmatz.comfy.facebook.display.FriendBox;
	import barmatz.comfy.facebook.display.ProfileThumbnail;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.system.Security;

	[SWF(width="760", height="100")]
	
	public class Footer extends Sprite
	{
		private static const FRIEND_EXPIRATION_TIME:uint = 1000 * 60 * 60 * 24,
							 TOTAL_PROFILE_THUMBNAILS:uint = 8;
		
		private var friendBox:FriendBox,
					profileThumbnails:Vector.<ProfileThumbnail> = new Vector.<ProfileThumbnail>(),
					_profileThumbnailFilled:int = 0;
		
		public function Footer()
		{
			super();
			Security.loadPolicyFile("https://fbcdn-profile-a.akamaihd.net/crossdomain.xml");
			createFriendBox();
		}
		
		public function loadCachedFriends():void
		{
			const FRIENDS:Vector.<Object> = FacebookGameWrapper.sharedObject.data.friends ? Vector.<Object>(FacebookGameWrapper.sharedObject.data.friends) : null;
			var newFriends:Vector.<Object>;
			
			if(FRIENDS)
			{
				newFriends = new Vector.<Object>(); 
				FRIENDS.forEach(function(a:Object, b:int, c:Vector.<Object>):void
				{
					if(new Date().time - a.created.time < FRIEND_EXPIRATION_TIME)
						newFriends.push(a);
				});
				setFriends(newFriends);
			}
		}
		
		private function registerFriend(id:String):void
		{
			if(!FacebookGameWrapper.sharedObject.data.friends)
				FacebookGameWrapper.sharedObject.data.friends = new Vector.<Object>();
			FacebookGameWrapper.sharedObject.data.friends.push({id: id, created: new Date()});
			FacebookGameWrapper.sharedObject.flush();
		}
		
		private function setFriends(friends:Vector.<Object>):void
		{
			friends.forEach(function(a:Object, b:int, c:Vector.<Object>):void
			{
				addFriendAt(a.id, b, false);
			});
			FacebookGameWrapper.sharedObject.data.friends = friends;
			FacebookGameWrapper.sharedObject.flush();
		}
		
		private function inviteFriend(index:int):void
		{
			JSBridge.request(JSBridge.addCallback("onInviteFriend", onInviteFriend), "Hello world", null, null, null, 1);
		}

		public function addFriendAt(id:String, index:int,  register:Boolean = true):void
		{
			if(index < TOTAL_PROFILE_THUMBNAILS)
			{
				++_profileThumbnailFilled;
				loadFriend(id, index);
			}
			if(register)
				registerFriend(id);
		}
		
		private function loadFriend(id:String, index:int):void
		{
			const LOADER:ProfileThumbnailLoader = new ProfileThumbnailLoader();
			LOADER.addEventListener(ProfileThumbnailLoaderEvent.DATA_COMPLETE, onLoadFriendDataComplete, false, 0, true);
			LOADER.addEventListener(ProfileThumbnailLoaderEvent.PICTURE_COMPLETE, onLoadFriendPictureComplete, false, 0, true);
			LOADER.load(id, index);
		}
		
		
		private function setFriendName(index:int, name:String):void
		{
			profileThumbnails[index].textField.text = name;
			disableProfileThumbnail(profileThumbnails[index]);
		}
		
		private function setFriendImage(index:int, url:String):void
		{
			profileThumbnails[index].image.addChild(createLoader(url));
			disableProfileThumbnail(profileThumbnails[index]);
		}
		
		private function enableProfileThumbnail(profileThumbnail:ProfileThumbnail):void
		{
			profileThumbnail.buttonMode = true;
			profileThumbnail.addEventListener(MouseEvent.CLICK, onProfileThumbnailClick, false, 0, true);
		}
		
		private function disableProfileThumbnail(profileThumbnail:ProfileThumbnail):void
		{
			profileThumbnail.buttonMode = false;
			profileThumbnail.removeEventListener(MouseEvent.CLICK, onProfileThumbnailClick);
		}
		
		private function createLoader(url:String):Loader
		{
			const LOADER:Loader = new Loader();
			LOADER.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete, false, 0, true);
			LOADER.load(new URLRequest(url));
			return LOADER;
		}	
		
		private function createFriendBox():void
		{
			if(friendBox)
				destroyFriendBox();
			friendBox = new FriendBox();
			friendBox.inviteButton.addEventListener(MouseEvent.CLICK, onFriendBoxInviteButtonClick, false, 0, true);
			friendBox.shareButton.addEventListener(MouseEvent.CLICK, onFriendBoxShareButtonClick, false, 0, true);
			addChild(friendBox);
			parseProfileThumbnails();
		}
		
		private function destroyFriendBox():void
		{
			if(friendBox.parent)
				friendBox.parent.removeChild(friendBox);
			friendBox = null;
		}
		
		private function parseProfileThumbnails():void
		{
			var i:int, object:DisplayObject, profileThumbnail:ProfileThumbnail;
			for(i = 0; i < friendBox.numChildren; ++i)
			{
				object = friendBox.getChildAt(i);
				if(object is ProfileThumbnail)
				{
					profileThumbnail = ProfileThumbnail(object);
					profileThumbnail.mouseChildren = false;
					profileThumbnail.textField.text = "add";
					profileThumbnails.push(profileThumbnail);
					enableProfileThumbnail(profileThumbnail);
				}
			}
		}
		
		private function resizeLoader(loader:Loader):void
		{
			loader.width = loader.height = 0;
			loader.width = loader.parent.width;
			loader.height = loader.parent.height;
		}
		
		private function getProfileThumbnailIndex(profileThumbnail:ProfileThumbnail):Number
		{
			var value:Number;
			profileThumbnails.forEach(function(a:ProfileThumbnail, b:int, c:Vector.<ProfileThumbnail>):void
			{
				if(a == profileThumbnail)
					value = b;
			});
			return value;
		}

		private function updatePoints(points:uint):void
		{
			friendBox.pointsField.text = points.toString();
			GamePointsManager.updatePoints(points);
		}
		
		private function onInviteFriend(event:Object):void
		{
			if(event && event.to)
				event.to.forEach(function(a:String, b:int, c:Array):void 
				{
					points = GamePointsManager.updateInvite();
					addFriendAt(a, profileThumbnailFilled + b);
				});
		}
		
		private function onLoaderComplete(event:Event):void
		{
			const LOADER_INFO:LoaderInfo = LoaderInfo(event.currentTarget);
			LOADER_INFO.removeEventListener(Event.COMPLETE, onLoaderComplete);
			Bitmap(LOADER_INFO.content).smoothing = true;
			resizeLoader(LOADER_INFO.loader);
		}
			
		private function onProfileThumbnailClick(event:MouseEvent):void
		{
			inviteFriend(getProfileThumbnailIndex(ProfileThumbnail(event.currentTarget)));
		}
		
		private function onFriendBoxInviteButtonClick(event:MouseEvent):void 
		{
			inviteFriend(profileThumbnailFilled);
		}
		
		private function onFriendBoxShareButtonClick(event:MouseEvent):void 
		{
			JSBridge.feed(JSBridge.addCallback("onShare", onShare));
		}
		
		private function onShare(event:Object):void
		{
			points = GamePointsManager.updateShare();
		}
		
		private function onLoadFriendDataComplete(event:ProfileThumbnailLoaderEvent):void
		{
			if(event.data.name)
				setFriendName(event.index, event.data.name);
		}
		
		private function onLoadFriendPictureComplete(event:ProfileThumbnailLoaderEvent):void
		{
			setFriendImage(event.index, event.data.toString());
		}
		
		public function get points():uint
		{
			return uint(friendBox.pointsField.text);
		}
		
		public function set points(value:uint):void
		{
			friendBox.pointsField.text = value.toString();
		}
		
		public function get profileThumbnailFilled():int
		{
			return _profileThumbnailFilled;
		}
	}
}

import barmatz.comfy.facebook.JSBridge;

import flash.events.Event;
import flash.events.EventDispatcher;

[Event(name="dataComplete", type="ProfileThumbnailLoaderEvent")]
[Event(name="pictureComplete", type="ProfileThumbnailLoaderEvent")]

class ProfileThumbnailLoader extends EventDispatcher
{
	private var _id:String,
				_index:Number;
	
	public function ProfileThumbnailLoader()
	{
		super();	
	}
	
	public function load(id:String, index:Number):void
	{
		_id = id;
		_index = index;
		JSBridge.api(JSBridge.addCallback("onLoadFriend" + index, onLoadFriend), "/" + id);
		JSBridge.api(JSBridge.addCallback("onLoadFriendPicture" + index, onLoadFriendPicture), "/" + id + "/picture?type=small");
	}
		
	private function onLoadFriend(event:Object):void
	{
		dispatchEvent(new ProfileThumbnailLoaderEvent(ProfileThumbnailLoaderEvent.DATA_COMPLETE, id, index, event));
	}
	
	private function onLoadFriendPicture(event:Object):void
	{
		dispatchEvent(new ProfileThumbnailLoaderEvent(ProfileThumbnailLoaderEvent.PICTURE_COMPLETE, id, index, event));
	}
	
	public function get id():String
	{
		return _id;
	}
	
	public function get index():Number
	{
		return _index;
	}
}

class ProfileThumbnailLoaderEvent extends Event
{
	public static const DATA_COMPLETE:String = "dataComplete",
						PICTURE_COMPLETE:String = "pictureComplete";
	
	private var _id:String,
				_index:Number,
				_data:Object;
	
	public function ProfileThumbnailLoaderEvent(type:String, id:String, index:Number, data:Object, bubbles:Boolean=false, cancelable:Boolean=false)
	{
		super(type, bubbles, cancelable);
		_id = id;
		_index = index;
		_data = data;
	}
	
	public override function clone():Event
	{
		return new ProfileThumbnailLoaderEvent(type, id, index, data, bubbles, cancelable);
	}
	
	public override function toString():String
	{
		return formatToString("ProfileThumbnailClientEvent", "type", "id", "index", "data", "bubbles", "cancelable");
	}
	
	public function get id():String
	{
		return _id;
	}
	
	public function get index():Number
	{
		return _index;
	}
	
	public function get data():Object
	{
		return _data;
	}
}