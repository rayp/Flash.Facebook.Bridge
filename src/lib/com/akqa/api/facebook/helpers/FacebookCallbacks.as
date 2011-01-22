package com.akqa.api.facebook.helpers
{
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;

	public class FacebookCallbacks extends EventDispatcher
	{
		private static var _instance : FacebookCallbacks;
		protected var _jsCallbacks : Dictionary = new Dictionary();

		public function FacebookCallbacks( se : SE )
		{
			se;

			ExternalInterface.addCallback( "on_fb_event", onEvent );
		}

		public static function get gi() : FacebookCallbacks
		{
			return _instance || ( _instance = new FacebookCallbacks( new SE() ) );
		}

		public function subscribe( type : String, handler : Function ) : Boolean
		{
			trace( "FacebookCallbacks.subscribe(" + type + ")" );
			if ( _jsCallbacks[ type ] == null )
				_jsCallbacks[ type ] = new Dictionary();

			if ( _jsCallbacks[ type ][ handler ] == null )
			{
				_jsCallbacks[ type ][ handler ] = handler;

				return true;
			}
			else
			{
				return false;
			}
		}

		public function unsubscribe( type : String, handler : Function ) : Boolean
		{
			trace( "FacebookCallbacks.unsubscribe(" + type + ")" );
			if ( _jsCallbacks[ type ] == null ) return false;

			if ( _jsCallbacks[ type ][ handler ] )
			{
				delete _jsCallbacks[ type ][ handler ];

				return true;
			}
			else
			{
				return false;
			}
		}

		public function hasCallback( type : String, handler : Function ) : Boolean
		{
			if ( _jsCallbacks[ type ] == null ) return false;
			
			if ( _jsCallbacks[ type ][ handler ] )
			{
				trace( "FacebookCallbacks.hasCallback(" + type + ") : true" );
				return true;
			}
			else
			{
				trace( "FacebookCallbacks.hasCallback(" + type + ") : false" );
				return false;
			}
		}

		protected function onEvent( type : String, response : Object = null ) : void
		{
			trace( "FacebookCallbacks.onEvent(" + type + ")" );
			if ( _jsCallbacks[ type ] )
			{
				var handler : Function;
				for each ( handler in _jsCallbacks[ type ] )
					_jsCallbacks[ type ][ handler ]( response );
			}
		}
	}
}
internal class SE
{
}
