package com.akqa.api.facebook
{
	import com.adobe.serialization.json.JSON;
	import com.akqa.api.facebook.data.FacebookSession;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;

	final public class FacebookAuth 
	extends EventDispatcher
	{
		private static var _instance : FacebookAuth;
		private static var FBAS : String = "$fbas";
		public static const E_READY : String = "com.akqa.api.facebook.FacebookAPI.E_READY";
		public static const E_LOGGED_IN : String = "com.akqa.api.facebook.FacebookAPI.E_LOGGED_IN";
		public static const E_LOGIN_CANCEL : String = "com.akqa.api.facebook.FacebookAPI.E_LOGIN_CANCEL";
		public static const E_LOGGED_OUT : String = "com.akqa.api.facebook.FacebookAPI.E_LOGGED_OUT";
		public static const E_LOGIN_CHANGE : String = "com.akqa.api.facebook.FacebookAPI.E_LOGIN_CHANGE";

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
			ExternalInterface.call( FBAS + ".login" );
		}

		public function logout() : void
		{
			ExternalInterface.call( FBAS + ".logout" );
		}

		public function setFacebookSession( response : Object = null ) : void
		{
			var session : Object;
			
			if ( response )
			{
				session = response.session;

				if ( response.perms )
					FacebookSession.gi.setPermissions( response.perms );
			}

			FacebookSession.gi.setSession( session || ExternalInterface.call( FBAS + ".get_session" ) );

			trace( FacebookSession.gi );
		}

		private function onReady( response : *= null ) : void
		{
			trace("FacebookAuth.onReady(response)");
			setFacebookSession( );
			dispatchEvent( new Event( E_READY ) );
		}

		private function onLoggedIn( response : *= null ) : void
		{
			trace( "FacebookAPI.onLoggedIn(response)" );
			setFacebookSession( response );
			dispatchEvent( new Event( E_LOGGED_IN ) );
		}

		private function onLoginCancel( response : *= null ) : void
		{
			trace( "FacebookAPI.onLoginCancel(response)" );
			setFacebookSession( response );
			dispatchEvent( new Event( E_LOGIN_CANCEL ) );
		}

		private function onLoggedOut( response : *= null ) : void
		{
			trace( "FacebookAPI.onLoggedOut(response)" );
			setFacebookSession( response );
			dispatchEvent( new Event( E_LOGGED_OUT ) );
		}

		private function onLoginChange( response : *= null ) : void
		{
			trace( "FacebookAPI.onLoginChange(response)" );
			trace( JSON.encode( response ) );
			setFacebookSession( response );
			dispatchEvent( new Event( E_LOGIN_CHANGE ) );
		}
	}
}
internal class SE
{
}
