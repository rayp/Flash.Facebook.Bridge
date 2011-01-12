/** * * HOW TO USE: * *import com.akqa.utils.JSBridge;private function initBridge () : void{JSBridge.gi.addEventListener(JSBridge.E_READY, onJSBridgeReady);JSBridge.gi.initialize( this.loaderInfo );}private function onJSBridgeReady(e:Event):void{trace("JSBridge Ready");JSBridge.gi.call("alert", "hello from flash!");JSBridge.gi.addCallback("hello_from_js");} * * * */
package com.akqa.utils
{
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;

	/**	 * JSBridge.as (a JS <-> AS/External Interface Helper)	 *	 * @author: AKQA	 * @version: 0.1	 * @date: May 21, 2010	 *	 */
	public class JSBridge extends EventDispatcher
	{
		public static const E_READY : String = "E_READY";
		private static var _instance : JSBridge;
		private var _callback : String;
		private var _debugKey : String;
		private var _debugCallbacks : Array = new Array();

		public function JSBridge( se : SE )
		{
			se;
		}

		// ----------------------------------------------------------------------------
		// Interface
		// ----------------------------------------------------------------------------
		public static function get gi() : JSBridge
		{
			return _instance || ( _instance = new JSBridge( new SE() ) );
		}

		public function initialize( loaderInfo : LoaderInfo ) : void
		{
			_callback = loaderInfo.parameters[ "JSBridge_Callback" ];
			_debugKey = loaderInfo.parameters[ "JSBridge_DebugKey" ];			
			if ( ExternalInterface.available )
			{
				ready();
			}
			else
			{
				trace( "External interface is no bro." );
			}
		}

		// ----------------------------------------------------------------------------
		// Call / AddCallback
		// ----------------------------------------------------------------------------
		public function call( functionName : String, ...args ) : *
		{
			var r : * = ExternalInterface.call( functionName, args );
			return r;
		}

		public function addCallback( functionName : String, closure : Function ) : void
		{
			ExternalInterface.addCallback( functionName, closure );
		}

		public function addDebugCallback( functionName : String, closure : Function ) : void
		{
			_debugCallbacks.push( new DebugCallback( functionName, closure ) );
		}

		public static function log( ob : Object ) : void
		{
			try
			{
				ExternalInterface.call( "console.log", ob );
			}
			catch( error : Error )
			{
				trace( ob );
			}
		}

		// ----------------------------------------------------------------------------
		// 
		// ----------------------------------------------------------------------------
		private function ready() : void
		{
			if ( _callback && _callback.length > 0 )
				ExternalInterface.call( _callback );				
			addDebugLock();			
			dispatchEvent( new Event( JSBridge.E_READY ) );
		}

		private function addDebugLock() : void
		{
			ExternalInterface.addCallback( "unlockDebugInterface", unlockDebugInterface );
		}

		private function unlockDebugInterface( key : String ) : void
		{
			trace( "JSBridge.unlockDebugInterface(" + key + ")" );
			if ( key && key == _debugKey )
			{
				log( "You are now in debug mode." );
				var callback : DebugCallback;
				for each ( callback in _debugCallbacks )
				{
					log( "Adding Debug Call:" + callback.functionName );
					ExternalInterface.addCallback( callback.functionName, callback.closure );
				}
			}
			else
			{
				log( "Your debug key does not match the key that is somehow assigned." );
			}
		}
	}
}
internal class DebugCallback
{
	private var _functionName : String;
	private var _closure : Function;

	public function DebugCallback( functionName : String, closure : Function )
	{
		_closure = closure;
		_functionName = functionName;
	}

	public function get closure() : Function
	{
		return _closure;
	}

	public function get functionName() : String
	{
		return _functionName;
	}
}
internal class SE
{
}