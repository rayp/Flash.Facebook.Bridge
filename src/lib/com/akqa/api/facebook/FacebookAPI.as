package com.akqa.api.facebook
{
	import flash.events.EventDispatcher;

	public class FacebookAPI 
	extends EventDispatcher
	{
		private static var _instance : FacebookAPI;
		private var _token : String;

		public function FacebookAPI( se : SE )
		{
		}

		public static function get gi() : FacebookAPI
		{
			return _instance || ( _instance = new FacebookAPI( new SE() ) );
		}

		public function getUser( id : String = null ) : void
		{
			var call : String = "/" + ( id || "me" ) + _token;
			trace( 'call: ' + (call) );
		}

		public function set token( token : String ) : void
		{
			_token = token;
		}
	}
}
internal class SE
{
}
