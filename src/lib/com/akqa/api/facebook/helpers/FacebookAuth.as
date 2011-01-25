package com.akqa.api.facebook.helpers
{
	import com.akqa.api.facebook.events.FacebookEvent;
	import com.akqa.api.facebook.events.NativeFacebookEvent;

	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;

	public class FacebookAuth 
	extends EventDispatcher
	{
		protected static var _instance : FacebookAuth;
		protected static var FBAS : String = "$fbas";
		private var _isConnected : Boolean;

		// protected var _jsCallbacks : Dictionary = new Dictionary();
		public function FacebookAuth( se : SE )
		{
			super();

			se;

			ExternalInterface.addCallback( "on_fb_ready", onReady );
			ExternalInterface.addCallback( "on_fb_logged_in", onLoggedIn );
			ExternalInterface.addCallback( "on_fb_login_cancel", onLoginCancel );
			ExternalInterface.addCallback( "on_fb_logged_out", onLoggedOut );
			ExternalInterface.addCallback( "on_fb_login_change", onLoginChange );
		}

		/**
		 * 
		 * Interface
		 * 
		 */
		public static function get gi() : FacebookAuth
		{
			return _instance || ( _instance = new FacebookAuth( new SE() ) );
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

		public function get isConnected() : Boolean
		{
			return _isConnected;
		}

		public function subscribe( event : NativeFacebookEvent, handler : Function ) : void
		{
			// trace( "FacebookAuth.subscribe(" + event.type + ")" );

			if ( !FacebookCallbacks.gi.hasCallback( event.type, handler ) )
			{
				FacebookCallbacks.gi.subscribe( event.type, handler );
				ExternalInterface.call( FBAS + ".subscribe", event.type );
			}
		}

		public function unsubscribe( event : NativeFacebookEvent, handler : Function ) : void
		{
			// trace( "FacebookAuth.unsubscribe(" + event.type + ")" );

			if ( FacebookCallbacks.gi.hasCallback( event.type, handler ) )
			{
				FacebookCallbacks.gi.unsubscribe( event.type, handler );
				ExternalInterface.call( FBAS + ".unsubscribe", event.type );
			}
		}

		public function ui( method : String, data : Object, handler : Function = null, display : String = null ) : void
		{
			if ( handler != null && !FacebookCallbacks.gi.hasCallback( method, handler ) )
				FacebookCallbacks.gi.subscribe( method, handler );

			data.method = method;
			if ( display )
				data.display = display;

			ExternalInterface.call( FBAS + ".ui", data );
		}

		/**
		 * 
		 * Callbacks
		 * 
		 */
		protected function onReady( response : Object = null ) : void
		{
			dispatchEvent( new FacebookEvent( FacebookEvent.READY, response ) );
		}

		protected function onLoggedIn( response : Object = null ) : void
		{
			_isConnected = true;
			
			dispatchEvent( new FacebookEvent( FacebookEvent.LOGGED_IN, response ) );
		}

		protected function onLoginCancel( response : Object = null ) : void
		{
			dispatchEvent( new FacebookEvent( FacebookEvent.LOGIN_CANCEL, response ) );
		}

		protected function onLoggedOut( response : Object = null ) : void
		{
			_isConnected = false;
			
			dispatchEvent( new FacebookEvent( FacebookEvent.LOGGED_OUT, response ) );
		}

		protected function onLoginChange( response : Object = null ) : void
		{
			dispatchEvent( new FacebookEvent( FacebookEvent.LOGIN_CHANGE, response ) );
		}
	}
}
internal class SE
{
}
