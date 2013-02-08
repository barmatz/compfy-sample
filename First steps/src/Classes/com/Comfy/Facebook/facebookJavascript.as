/**
 * @author Almog Koren "Almog Design" - www.almogdesign.net, almog@almogdesign.net
 */
package com.almogdesign.facebook 
{
	import flash.net.LocalConnection;
	/**
	 * Wrapper for the javascript interface for facebook
	 */
	public class facebookJavascript {
		
		/* Props */
		private var _connection:LocalConnection;
		private var _connectionName:String;
		
		
		/**
		 * Constructor
		 */
		public function facebookJavascript (connection_name:String) {
			/* Save the connection name and create an connection */
			_connectionName = connection_name;
			_connection = new LocalConnection();
			_connection.allowDomain("apps.facebook.com", "apps.*.facebook.com");
		}
		/**
		 * Calls a method on the connector
		 */
		public function call (function_name:String, params:Array):void {
			/* Send the call over the connector */
			if (_connectionName) {
				_connection.send(_connectionName, 'callFBJS', function_name, params);
			}
		}
		
	}

}