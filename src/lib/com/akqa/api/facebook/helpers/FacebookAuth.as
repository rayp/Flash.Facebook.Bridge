package com.akqa.api.facebook.helpers
{
	import com.akqa.api.facebook.events.FacebookEvent;

	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;

	final public class FacebookAuth 
	extends EventDispatcher
	{
		private static var _instance : FacebookAuth;
		private static var FBAS : String = "$fbas";

		public function FacebookAuth( se : SE )
		{
			super();

			se;
		}

		public static function get gi() : FacebookAuth
		{
			return _instance || ( _instance = new FacebookAuth( new SE() ) );
		}

		public function init() : void
		{
			ExternalInterface.addCallback( "on_ready", onReady );
			ExternalInterface.addCallback( "on_logged_in", onLoggedIn );
			ExternalInterface.addCallback( "on_login_cancel", onLoginCancel );
			ExternalInterface.addCallback( "on_logged_out", onLoggedOut );
			ExternalInterface.addCallback( "on_login_change", onLoginChange );
		}

		public function login() : void
		{
			if ( session[ "access_token" ] )
			{
				onLoggedIn();
			}
			else
			{
				ExternalInterface.call( FBAS + ".login" );
			}
		}

		public function logout() : void
		{
			ExternalInterface.call( FBAS + ".logout" );
		}

		public function get session() : Object
		{
			// retrieve session data from the FBAS object or FB cookie
			return ExternalInterface.call( FBAS + ".get_session" );
		}

		private function onReady( response : Object = null ) : void
		{
			dispatchEvent( new FacebookEvent( FacebookEvent.READY, response ) );
		}

		private function onLoggedIn( response : Object = null ) : void
		{
			dispatchEvent( new FacebookEvent( FacebookEvent.LOGGED_IN, response ) );
		}

		private function onLoginCancel( response : Object = null ) : void
		{
			dispatchEvent( new FacebookEvent( FacebookEvent.LOGIN_CANCEL, response ) );
		}

		private function onLoggedOut( response : Object = null ) : void
		{
			dispatchEvent( new FacebookEvent( FacebookEvent.LOGGED_OUT, response ) );
		}

		private function onLoginChange( response : Object = null ) : void
		{
			dispatchEvent( new FacebookEvent( FacebookEvent.LOGIN_CHANGE, response ) );
		}
	}
}
internal class SE
{
}
