package com.akqa.api.facebook.events
{
	import flash.events.Event;

	public class FacebookEvent 
	extends Event
	{
		// Auth Events
		public static const READY : String = "com.akqa.api.facebook.events.FacebookEvent.READY";
		public static const LOGGED_IN : String = "com.akqa.api.facebook.events.FacebookEvent.LOGGED_IN";
		public static const LOGIN_CANCEL : String = "com.akqa.api.facebook.events.FacebookEvent.LOGIN_CANCEL";
		public static const LOGGED_OUT : String = "com.akqa.api.facebook.events.FacebookEvent.LOGGED_OUT";
		public static const LOGIN_CHANGE : String = "com.akqa.api.facebook.events.FacebookEvent.LOGIN_CHANGE";
		// Facebook Routines
		public static const OBJECT : String = "com.akqa.api.facebook.events.FacebookEvent.OBJECT";
		public static const PICTURE : String = "com.akqa.api.facebook.events.FacebookEvent.PICTURE";
		public static const STATUSES : String = "com.akqa.api.facebook.events.FacebookEvent.STATUSES";
		public static const PROFILE_FEED : String = "com.akqa.api.facebook.events.FacebookEvent.PROFILE_FEED";
		public static const NEWS_FEED : String = "com.akqa.api.facebook.events.FacebookEvent.NEWS_FEED";
		public static const LIKES : String = "com.akqa.api.facebook.events.FacebookEvent.LIKES";
		public static const FRIENDS : String = "com.akqa.api.facebook.events.FacebookEvent.USER";
		public static const POST : String = "com.akqa.api.facebook.events.FacebookEvent.POST";
		public static const PUBLISH : String = "com.akqa.api.facebook.events.FacebookEvent.PUBLISH";
		public static const SHARE : String = "com.akqa.api.facebook.events.FacebookEvent.SHARE";
		// Payloads
		public var response : Object;
		public var url : String;

		public function FacebookEvent( type : String, response : Object = null, url : String = null, bubbles : Boolean = false, cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );

			this.response = response;
			this.url = url;
		}

		public override function clone() : Event
		{
			return new FacebookEvent( type, response, url, bubbles, cancelable );
		}

		public override function toString() : String
		{
			return formatToString( "FacebookEvent", "type", "response", "url", "bubbles", "cancelable" );
		}
	}
}