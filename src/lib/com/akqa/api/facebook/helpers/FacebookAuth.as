package com.akqa.api.facebook.helpers
{
	import com.akqa.api.facebook.events.FacebookEvent;
	import com.akqa.api.facebook.events.NativeFacebookEvent;
	import com.maccherone.json.JSON;

	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;

	public class FacebookAuth 
	extends EventDispatcher
	{
		protected static var _instance : FacebookAuth;
		protected static var FBAS : String = "$fbas";
		protected var _jsCallbacks : Dictionary = new Dictionary();

		public function FacebookAuth( se : SE )
		{
			super();

			se;
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

		public function init() : void
		{
			ExternalInterface.addCallback( "on_fb_ready", onReady );
			ExternalInterface.addCallback( "on_fb_logged_in", onLoggedIn );
			ExternalInterface.addCallback( "on_fb_login_cancel", onLoginCancel );
			ExternalInterface.addCallback( "on_fb_logged_out", onLoggedOut );
			ExternalInterface.addCallback( "on_fb_login_change", onLoginChange );
			ExternalInterface.addCallback( "on_fb_event", onEvent );
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

		public function subscribe( event : NativeFacebookEvent, handler : Function ) : void
		{
			// trace( "FacebookAuth.subscribe(" + event.type + ")" );
			if ( _jsCallbacks[ event.type ] == null )
				_jsCallbacks[ event.type ] = new Dictionary();

			if ( _jsCallbacks[ event.type ][ handler ] == null )
			{
				_jsCallbacks[ event.type ][ handler ] = handler;

				ExternalInterface.call( FBAS + ".subscribe", event.type );
			}
		}

		public function unsubscribe( event : NativeFacebookEvent, handler : Function ) : void
		{
			// trace( "FacebookAuth.unsubscribe(" + event.type + ")" );
			if ( _jsCallbacks[ event.type ] == null ) return;

			if ( _jsCallbacks[ event.type ][ handler ] )
				ExternalInterface.call( FBAS + ".unsubscribe", event.type );

			delete _jsCallbacks[ event.type ][ handler ];
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
			dispatchEvent( new FacebookEvent( FacebookEvent.LOGGED_IN, response ) );
		}

		protected function onLoginCancel( response : Object = null ) : void
		{
			dispatchEvent( new FacebookEvent( FacebookEvent.LOGIN_CANCEL, response ) );
		}

		protected function onLoggedOut( response : Object = null ) : void
		{
			dispatchEvent( new FacebookEvent( FacebookEvent.LOGGED_OUT, response ) );
		}

		protected function onLoginChange( response : Object = null ) : void
		{
			dispatchEvent( new FacebookEvent( FacebookEvent.LOGIN_CHANGE, response ) );
		}

		protected function onEvent( eventType : String, response : Object ) : void
		{
//			trace( "FacebookAuth.onEvent(" + eventType + ")" );
			// this should be a valid FB event type
			if ( _jsCallbacks[ eventType ] )
			{
				var handler : Function;
				for each ( handler in _jsCallbacks[ eventType ] )
					_jsCallbacks[ eventType ][ handler ]( response );
			}
		}
	}
}
internal class SE
{
}
