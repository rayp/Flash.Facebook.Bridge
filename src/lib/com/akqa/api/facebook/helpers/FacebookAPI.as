package com.akqa.api.facebook.helpers
{
	import com.akqa.api.facebook.events.FacebookEvent;
	import com.akqa.api.facebook.events.NativeFacebookEvent;
	import com.akqa.api.facebook.net.FacebookRequest;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	public class FacebookAPI 
	extends EventDispatcher
	{
		private static var _instance : FacebookAPI;
		public static var GRAPH_URL : String = "https://graph.facebook.com";
		private static var FB_UI : String = "FB.ui";
		private static var FB_EVENT : String = "FB.event";
		private var _accessToken : String = "";
		private var _openRequests : Dictionary = new Dictionary();

		public function FacebookAPI( se : SE )
		{
			se;
		}

		public static function get gi() : FacebookAPI
		{
			return _instance || ( _instance = new FacebookAPI( new SE() ) );
		}

		public function api( method : String, callbacks : * = null, params : * = null, requestMethod : String = 'GET' ) : void
		{
			method = ( method.indexOf( "/" ) != 0 ) ? "/" + method : method;

			if (!params)
				params = {};

			params[ "access_token" ] = _accessToken;

			var req : FacebookRequest = new FacebookRequest( GRAPH_URL, requestMethod );

			// We need to hold on to a reference or the GC might clear this during the load.
			_openRequests[ req ] = callbacks;

			req.call( method, params, onRequestComplete );
		}

		public function ui( params : String, callback : Function ) : void
		{
			ExternalInterface.call( FB_UI, params, callback );
		}

		public function subscribe( event : NativeFacebookEvent, handler : Function ) : void
		{
			ExternalInterface.call( FB_EVENT + ".subscribe", event.type, handler );
		}

		public function unsubscribe( event : NativeFacebookEvent, handler : Function ) : void
		{
			ExternalInterface.call( FB_EVENT + ".unsubscribe", event.type, handler );
		}

		public function set accessToken( value : String ) : void
		{
			_accessToken = value;
		}

		/**
		 * 
		 * internal
		 * 
		 */
		private function parseCallbacks( callbacks : *, result : Object, error : Object ) : void
		{
			if ( callbacks is Array )
			{
				var callback : *;
				for each ( callback in callbacks )
					executeCallback( callback, result, error );
			}
			else
			{
				executeCallback( callbacks, result, error );
			}
		}

		private function executeCallback( callback : *, result : Object, error : Object ) : void
		{
			if ( callback is Event )
			{
				trace( 'callback is Event' );

				if ( callback is FacebookEvent )
					FacebookEvent( callback ).response = result || error;

				dispatchEvent( callback );
			}
			else if ( callback is Function )
			{
				trace( 'callback is Function' );
				callback( result, error );
			}
			else
			{
				trace( "!!! ------------------------------------------------------------" );
				trace( "!!! Error in:" + getQualifiedClassName( this ) );
				trace( "!!! 'callbacks' is not a Function or Event" );
				trace( "!!! ------------------------------------------------------------" );
			}
		}

		/**
		 * 
		 * Event Handlers
		 * 
		 */
		protected function onRequestComplete( req : FacebookRequest ) : void
		{
			var callbacks : * = _openRequests[ req ];

			if ( callbacks === null )
				delete _openRequests[ req ];

			if ( req.success )
			{
				// Copied this from Adobe lib, not sure why it digs into reponses... legacy API support maybe?
				var data : Object = ( "data" in req.data ) ? req.data[ "data" ] : req.data;

				parseCallbacks( callbacks, data, null );
			}
			else
			{
				parseCallbacks( callbacks, null, req.data );
			}

			delete _openRequests[ req ];
		}
	}
}
internal class SE
{
}
