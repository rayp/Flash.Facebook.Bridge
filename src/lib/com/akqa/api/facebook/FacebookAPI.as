package com.akqa.api.facebook
{
	import com.facebook.graph.Facebook;
	import com.akqa.utils.FacebookHelper;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;

	final public class FacebookAPI 
	extends EventDispatcher
	// implements IFacebookAPI
	{
		private static var _instance : FacebookAPI;
		public static const E_LOGGED_IN : String = "com.akqa.api.facebook.FacebookAPI.E_LOGGED_IN";
		public static const E_LOGIN_CANCEL : String = "com.akqa.api.facebook.FacebookAPI.E_LOGIN_CANCEL";
		public static const E_LOGGED_OUT : String = "com.akqa.api.facebook.FacebookAPI.E_LOGGED_OUT";
		public static const E_LOGIN_CHANGE : String = "com.akqa.api.facebook.FacebookAPI.E_LOGIN_CHANGE";
		public static const E_USER : String = "com.akqa.api.facebook.FacebookAPI.E_USER";
		private var _accessToken : String;

		public function FacebookAPI( se : SE )
		{
			super();

			se;
		}

		public static function get gi() : FacebookAPI
		{
			return _instance || ( _instance = new FacebookAPI( new SE() ) );
		}

		public function init() : void
		{
			ExternalInterface.addCallback( "on_logged_in", onLoggedIn );
			ExternalInterface.addCallback( "on_login_cancel", onLoginCancel );
			ExternalInterface.addCallback( "on_logged_out", onLoggedOut );
			ExternalInterface.addCallback( "on_login_change", onLoginChange );

			Facebook.init();
		}

		public function login() : void
		{
			ExternalInterface.call( "$fb.login" );
		}

		public function logout() : void
		{
			ExternalInterface.call( "$fb.logout" );
		}

		public function getUser() : void
		{
			var call : String = "/me?access_token=" + token;
			trace( 'call: ' + (call) );

			Facebook.api( call, function( response : Object, fail : Object ) : void
			{
				trace( 'response: ' + (response) );
				trace( 'name: ' + (response.name) );
				trace( 'fail: ' + (fail) );
				dispatchEvent( new Event( E_USER ) );
			} );
		}

		private function get token() : String
		{
			return ExternalInterface.call( "$fb.get_access_token" );
		}

		private function traceObject( ob : * ) : void
		{
			var i : *;
			for ( i in ob )
			{
				trace( i + ':' + ob[i] );
			}
		}

		private function onLoggedIn( response : *= null ) : void
		{
			trace( "FacebookAPI.onLoggedIn(response)" );
			traceObject( response );

			getUser();
			dispatchEvent( new Event( E_LOGGED_IN ) );
		}

		private function onLoginCancel( response : *= null ) : void
		{
			trace( "FacebookAPI.onLoginCancel(response)" );
			trace( 'response: ' + (response) );
			dispatchEvent( new Event( E_LOGIN_CANCEL ) );
		}

		private function onLoggedOut( response : *= null ) : void
		{
			trace( "FacebookAPI.onLoggedOut(response)" );
			trace( 'response: ' + (response) );
			dispatchEvent( new Event( E_LOGGED_OUT ) );
		}

		private function onLoginChange( response : *= null ) : void
		{
			trace( "FacebookAPI.onLoginChange(response)" );
			trace( 'response: ' + (response) );
			dispatchEvent( new Event( E_LOGIN_CHANGE ) );
		}
	}
}
internal class SE
{
}
