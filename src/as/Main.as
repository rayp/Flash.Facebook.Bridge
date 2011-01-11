package
{
	import com.akqa.api.facebook.FacebookAPI;
	import com.akqa.utils.DrawUtil;
	import com.akqa.utils.JSBridge;
	import com.facebook.graph.Facebook;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class Main extends Sprite
	{
		private var _connect : Sprite;
		private var _disconnect : Sprite;

		public function Main()
		{
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}

		private function initJSBridge() : void
		{
			JSBridge.gi.addEventListener( JSBridge.E_READY, onJSBridgeReady );
			JSBridge.gi.initialize( loaderInfo );
		}

		private function addButtons() : void
		{
			_connect = getButton( "CONNECT" );
			_disconnect = getButton( "DISCONNECT" );
			_disconnect.visible = false;
		}

		private function addDisplayObjects() : void
		{
			addButtons();
		}

		private function getButton( label : String ) : Sprite
		{
			var s : Sprite = new Sprite();
			s.mouseChildren = false;
			s.mouseEnabled = true;
			s.buttonMode = true;
			s.useHandCursor = true;
			s.addEventListener( MouseEvent.CLICK, onButtonClickEvent );

			DrawUtil.drawWireFrame( s, 200, 50, label );

			addChild( s );

			return s;
		}

		private function onAddedToStage( event : Event ) : void
		{
			initJSBridge();
		}

		private function onJSBridgeReady( event : Event ) : void
		{
			initFacebook();
			addDisplayObjects();
		}

		private function initFacebook() : void
		{
			trace( "Main.initFacebook()" );

			FacebookAPI.gi.init();
		}

		private function onButtonClickEvent( event : MouseEvent ) : void
		{
			if ( _connect.visible )
			{
				FacebookAPI.gi.login();
				// Facebook.login( onFacebookLogin );
			}
			else
			{
				FacebookAPI.gi.logout();
				// Facebook.logout( onFacebookLogout );
			}

			_connect.visible = !_connect.visible;
			_disconnect.visible = !_connect.visible;
		}

		private function onFacebookLogin( response : Object, fail : Object ) : void
		{
			if ( response )
			{
				trace( "Login successful" );
			}
			else
			{
				trace( "Login unsuccessful" );
			}
		}

		private function onFacebookLogout( response : Object, fail : Object ) : void
		{
			if ( response )
			{
				trace( "Logout successful" );
			}
			else
			{
				trace( "Logout unsuccessful" );
			}
		}
	}
}
