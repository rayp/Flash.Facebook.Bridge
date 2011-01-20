package com.akqa.api.facebook
{
	import com.akqa.api.facebook.data.FacebookSession;
	import com.akqa.api.facebook.events.FacebookEvent;
	import com.akqa.api.facebook.events.NativeFacebookEvent;
	import com.akqa.api.facebook.helpers.FacebookAPI;
	import com.akqa.api.facebook.helpers.FacebookAuth;
	import com.maccherone.json.JSON;

	import flash.events.EventDispatcher;

	public class Facebook 
	extends EventDispatcher
	{
		protected static var _instance : Facebook;

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
			eventTypes.push( FacebookEvent.OBJECT );
			eventTypes.push( FacebookEvent.PICTURE );
			eventTypes.push( FacebookEvent.STATUSES );
			eventTypes.push( FacebookEvent.PROFILE_FEED );
			eventTypes.push( FacebookEvent.NEWS_FEED );
			eventTypes.push( FacebookEvent.FRIENDS );
			eventTypes.push( FacebookEvent.LIKES );
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

		public function getObject( id : String = null, callback : Function = null, params : * = null ) : void
		{
			callAPI( id, null, callback, FacebookEvent.OBJECT, params );
		}

		public function getStatuses( id : String = null, callback : Function = null, params : * = null ) : void
		{
			callAPI( id, "/statuses", callback, FacebookEvent.STATUSES, params );
		}

		public function getPicture( id : String = null, callback : Function = null, params : * = null ) : void
		{
			callAPI( id, "/picture", callback, FacebookEvent.PICTURE, params );
		}

		public function getProfileFeed( id : String = null, callback : Function = null, params : * = null ) : void
		{
			callAPI( id, "/feed", callback, FacebookEvent.PROFILE_FEED, params );
		}

		public function getNewsFeed( id : String = null, callback : Function = null, params : * = null ) : void
		{
			callAPI( id, "/home", callback, FacebookEvent.NEWS_FEED, params );
		}

		public function getFriends( id : String = null, callback : Function = null, params : * = null ) : void
		{
			callAPI( id, "/friends", callback, FacebookEvent.FRIENDS, params );
		}

		public function getLikes( id : String = null, callback : Function = null, params : * = null ) : void
		{
			callAPI( id, "/likes", callback, FacebookEvent.LIKES, params );
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

		public function api( method : String = null, callbacks : * = null, params : * = null, requestMethod : String = "GET" ) : void
		{
			FacebookAPI.gi.api( method, callbacks, params, requestMethod );
		}

		public function subscribe( event : NativeFacebookEvent, handler : Function ) : void
		{
			FacebookAuth.gi.subscribe( event, handler );
		}

		public function unsubscribe( event : NativeFacebookEvent, handler : Function ) : void
		{
			FacebookAuth.gi.unsubscribe( event, handler );
		}

		/**
		 * 
		 * Internal
		 * 
		 */
		protected function callAPI( id : String = null, routes : String = null, callback : Function = null, event : String = null, params : * = null ) : void
		{
			api( ( id || "/me" ) + ( ( routes ) ? routes : "" ), [ callback, new FacebookEvent( event ) ], params );
		}

		protected function addEventListeners( dispatcher : EventDispatcher, listener : Function, eventTypes : Array ) : void
		{
			var type : String;
			for each ( type in eventTypes )
				dispatcher.addEventListener( type, listener );
		}

		protected function setFacebookSession( response : Object = null ) : void
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
		protected function onFacebookAuthEvent( event : FacebookEvent ) : void
		{
			trace( "Facebook.onFacebookAuthEvent(" + event.type + ")" );
//			trace( JSON.encode( event.response, true, 40 ) );

			setFacebookSession( event.response );

			dispatchEvent( event.clone() );
		}

		protected function onFacebookAPIEvent( event : FacebookEvent ) : void
		{
			trace( "Facebook.onFacebookAPIEvent(" + event.type + ")" );
//			trace( JSON.encode( event.response, true, 40 ) );

			dispatchEvent( event.clone() );
		}

		protected function onFacebookEvent( eventType : String, response : Object ) : void
		{
			trace( "Facebook.onFacebookEvent(" + eventType + ")" );
//			trace( JSON.encode( response, true, 40 ) );
		}
	}
}
internal class SE
{
}
