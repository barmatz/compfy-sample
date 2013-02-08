package barmatz.comfy.facebook
{
	import barmatz.comfy.facebook.errors.JSError;
	
	import flash.errors.IllegalOperationError;
	import flash.external.ExternalInterface;

	public class JSBridge
	{
		public static var applicationID:String,
						  accessToken:String,
						  userID:String;
		
		public function JSBridge()
		{
			throw new IllegalOperationError("This is a static class and should not be initiated.");
		}
		
		private static function formatToString(object:*):String
		{
			var value:String = "",
				values:Vector.<String> = new Vector.<String>(),
				prefix:String = "", 
				postfix:String = "", 
				key:String;
			if(object is Array || object is Vector)
			{
				prefix = "[";
				postfix = "]";
				object.forEach(function(a:*, b:int, c:*):void 
				{
					values.push(a is Object ? formatToString(a) : a);
				});
			}
			else if(object is String)
				values.push("'" + object + "'");
			else if(object is Number)
				values.push(object);
			else if(object is Object)
			{
				prefix = "{";
				postfix = "}";
				for(key in object)
					values.push(key + ":" + (object[key] is Object ? formatToString(object[key]) : object[key]));
			}
			return prefix + values.join(",") + postfix;
		}
		
		public static function init(applicationID:String, callback:String):void
		{
			if(!applicationID)
				throw new JSError("Missing applicationID", JSError.NO_APPLICATION_ID);
			
			JSBridge.applicationID = applicationID;
			
			call("function()" +
			"{" +
				"try" +
				"{" +
					"if(document.getElementsByTagName('body')[0])" +
					"{" +
						"window.fbAsyncInit = function()" +
						"{" +
							"FB.init({" +
								"appId: '" + applicationID + "'," +
								"channelUrl: 'channel.html'," +
								"status: true," +
								"cookie: true," +
								"xfmbl: true" +
							"});" +
							"swfobject.getObjectById('" + ExternalInterface.objectID + "')." + callback + "();" +
						"};" +
						"(function(d) { if(d.getElementById('fb-root') == null) { var div = d.createElement('div'); div.id = 'fb-root'; d.getElementsByTagName('body')[0].appendChild(div); }})(document);" +
						"(function(d) { var js, id = 'facebook-jssdk'; if(d.getElementById(id)) return; js = d.createElement('script'); js.id = id; js.async = true; js.src = 'http://connect.facebook.net/en_US/all.js'; d.getElementsByTagName('head')[0].appendChild(js); })(document);" +
					"}" +
					"else " +
						"throw new Error('ActionScript error: JSBridge.init must be called after document onload event');" +
				"}" +
				"catch(error)" +
				"{" +
					"console.error(error);" +
				"}" +
			"}");
		}
		
		public static function addCallback(functionName:String, closure:Function):String
		{
			if(ExternalInterface.available)
				ExternalInterface.addCallback(functionName, closure);
			return functionName;
		}
		
		public static function call(functionName:String, ...args:*):void
		{
			if(ExternalInterface.available)
			{
				try
				{
					ExternalInterface.call.apply(JSBridge, [functionName].concat(args));
				}
				catch(error:Error)
				{
					ExternalInterface.call("console.error", "ExternalInterface error: " + error.toString());
				}
			}
			else
				throw new JSError("No external interface available", JSError.NO_EXTERNAL_INTERFACE);
		}
		
		public static function log(...args:*):void
		{
			call.apply(JSBridge, ["console.log"].concat(args));
		}
		
		public static function api(callback:String, method:String):void
		{
			call("function()" +
			"{" +
				"try" +
				"{" +
					"FB.api('" + method + "', function(response)" +
					"{" +
						"swfobject.getObjectById('" + ExternalInterface.objectID + "')." + callback + "(response);" +
					"});" +
				"} " +
				"catch(error)" +
				"{" +
					"console.error(error);" +
				"}" +
			"}");	
		}
		
		public static function ui(params:Object, callback:String = null):void
		{
			call("function()" +
			"{" +
				"try" +
				"{" +
					"FB.ui(" + 
						formatToString(params) + 
						(callback != null ? ", function(response)" +
						"{" +
							"swfobject.getObjectById('" + ExternalInterface.objectID + "')." + callback + "(response);" +
						"}" : "") +
					");" +
				"}" +
				"catch(error)" +
				"{" +
					"console.error(error);" +
				"}" +
			"}");
			
		}
		
		public static function request(callback:String, message:String, to:String = null, filters:Array = null, excludeID:Array = null, maxRecipients:Number = NaN, data:String = null, title:String = null):void
		{
			const PARAMS:Object = {method: "apprequests", message: message};
			if(to)
				PARAMS.to = to;
			if(filters)
				PARAMS.filters = filters;
			if(excludeID)
				PARAMS.exclude_ids = excludeID;
			if(maxRecipients)
				PARAMS.max_recipients = maxRecipients;
			if(data)
				PARAMS.data = data;
			if(title)
				PARAMS.title = title;
			ui(PARAMS, callback);
		}
		
		public static function send(callback:String, to:String, link:String, picture:String = null, name:String = null, description:String = null):void
		{
			const PARAMS:Object = {method: "send", to: to, link: link};
			if(picture)
				PARAMS.picture = picture;
			if(name)
				PARAMS.name = name;
			if(description)
				PARAMS.description = description;
			ui(PARAMS, callback);
		}
		
		public static function feed(callback:String, from:String = null, to:String = null, link:String = null, picture:String = null, source:String = null, name:String = null, caption:String = null, description:String = null):void
		{
			const PARAMS:Object = {method: "feed"};
			if(from)
				PARAMS.from = from;
			if(to)
				PARAMS.to = to;
			if(link)
				PARAMS.link = link;
			if(picture)
				PARAMS.picture = picture;
			if(source)
				PARAMS.source = source;
			if(name)
				PARAMS.name = name;
			if(caption)
				PARAMS.caption = caption;
			if(description)
				PARAMS.description = description;
			ui(PARAMS, callback);
		}
		
		public static function getLoginStatus(callback:String):void
		{
			call("function()" +
			"{" +
				"try" +
				"{" +
					"FB.getLoginStatus(function(response)" +
					"{" +
						"swfobject.getObjectById('" + ExternalInterface.objectID + "')." + callback + "(response);" +
					"});" +
				"}" +
				"catch(error)" +
				"{" +
					"console.error(error);" +
				"}" +
			"}");
		}
		
		public static function login(callback:String, permissions:Array = null):void
		{
			call("function()" +
			"{" +
				"try" +
				"{" +
					"FB.login(function(response)" +
					"{" +
						"swfobject.getObjectById('" + ExternalInterface.objectID + "')." + callback + "(response);" +
					"}," +
					"{scope: '" + (permissions ? permissions.join(",") : "") + "'});" +
				"}" +
				"catch(error)" +
				"{" +
					"console.error(error);" +
				"}" +
			"}");
		}
		
		public static function logout(callback:String):void
		{
			call("function()" +
			"{" +
				"try" +
				"{" +
					"FB.logout(function(response)" +
					"{" +
						"swfobject.getObjectById('" + ExternalInterface.objectID + "')." + callback + "(response);" +
					"});" +
				"}" +
				"catch(error)" +
				"{" +
					"console.error(error);" +
				"}" +
			"}");
		}
	}
}