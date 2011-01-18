package com.akqa.api.facebook
{
	import com.akqa.api.facebook.data.FacebookSession;
	import com.akqa.api.facebook.events.FacebookEvent;
	import com.akqa.api.facebook.events.NativeFacebookEvent;
	import com.akqa.api.facebook.helpers.FacebookAPI;
	import com.akqa.api.facebook.helpers.FacebookAuth;
	import com.maccherone.json.JSON;
	import flash.events.EventDispatcher;

	final public class Facebook 
	extends EventDispatcher
	{
		private static var _instance : Facebook;

		public function Facebook( se : SE )
		{
			super();

			se;
		}

		/**
		 * 
		 * Interface
		 * 
		 */
		public static function get gi() : Facebook
		{
			return _instance || ( _instance = new Facebook( new SE() ) );
		}

		public function init() : void
		{
			var eventTypes : Array;

			// API Events
			eventTypes = [];
			eventTypes.push( FacebookEvent.USER );
			eventTypes.push( FacebookEvent.POST );
			eventTypes.push( FacebookEvent.PUBLISH );
			eventTypes.push( FacebookEvent.SHARE );

			addEventListeners( FacebookAPI.gi, onFacebookAPIEvent, eventTypes ) ;

			// Auth Events
			eventTypes = [];
			eventTypes.push( FacebookEvent.READY );
			eventTypes.push( FacebookEvent.LOGIN_CANCEL );
			eventTypes.push( FacebookEvent.LOGGED_IN );
			eventTypes.push( FacebookEvent.LOGGED_OUT );
			eventTypes.push( FacebookEvent.LOGIN_CHANGE );

			addEventListeners( FacebookAuth.gi, onFacebookAuthEvent, eventTypes ) ;
			
			// Facebook events
			FacebookAPI.gi.subscribe( NativeFacebookEvent.AUTH_LOGIN, onFacebookEvent );

			FacebookAuth.gi.init();
		}

		public function login() : void
		{
			FacebookAuth.gi.login();
		}

		public function logout() : void
		{
			FacebookAuth.gi.logout();
		}

		public function getUser( id : String = null, callback : Function = null ) : void
		{
			api( id || "me", [ callback, new FacebookEvent( FacebookEvent.USER ) ] );
		}

		public function post() : void
		{
		}

		public function publish() : void
		{
		}

		public function share( url : String, callback : Function = null ) : void
		{
		}

		public function api( method : String, callbacks : * = null, params : * = null, requestMethod : String = 'GET' ) : void
		{
			FacebookAPI.gi.api( method, callbacks, params, requestMethod );
		}

		/**
		 * 
		 * Internal
		 * 
		 */
		private function addEventListeners( dispatcher : EventDispatcher, listener : Function, eventTypes : Array ) : void
		{
			var type : String;
			for each ( type in eventTypes )
				dispatcher.addEventListener( type, listener );
		}

		private function setFacebookSession( response : Object = null ) : void
		{
			var session : Object;
			var perms : String = "none";
			var status : String = "unknown";

			if ( response )
			{
				session = response.session;
				perms = response.perms;
				status = response.status;
			}
			else
			{
				// retrieve session data from the FBAS object or FB cookie
				session = FacebookAuth.gi.session;
			}

			// set session data
			FacebookSession.gi.update( session, perms, status );

			// set API access token
			FacebookAPI.gi.accessToken = FacebookSession.gi.accessToken;
		}

		/**
		 * 
		 * Event Handlers
		 * 
		 */
		private function onFacebookAuthEvent( event : FacebookEvent ) : void
		{
			trace( "Facebook.onFacebookAuthEvent(" + event.type + ")" );
			trace( JSON.encode( event.response, true, 40 ) );

			setFacebookSession( event.response );

			dispatchEvent( event.clone() );
		}

		private function onFacebookAPIEvent( event : FacebookEvent ) : void
		{
			trace( "Facebook.onFacebookAPIEvent(" + event.type + ")" );
			trace( JSON.encode( event.response, true, 40 ) );
			
			dispatchEvent( event.clone() );
		}

		private function onFacebookEvent( event : String, response:Object ) : void
		{
			trace( "Facebook.onFacebookAPIEvent(" + event + ")" );
			trace( JSON.encode( response, true, 40 ) );
		}
	}
}
internal class SE
{
}
