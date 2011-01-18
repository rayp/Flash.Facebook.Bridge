package com.akqa.views
{
	import com.bit101.components.VBox;
	import com.akqa.api.facebook.Facebook;
	import com.akqa.utils.JSBridge;
	import com.bit101.components.PushButton;
	import com.maccherone.json.JSON;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class MainView extends Sprite
	{
		private static const CONNECT : String = "Connect";
		private static const DISCONNECT : String = "Disconnect";
		private var _box : VBox;
		private var _connection : PushButton;
		private var _me : PushButton;

		public function MainView()
		{
			addEventListener( Event.ADDED_TO_STAGE, function() : void
			{
				addDisplayObjects();
			} );
		}

		private function addDisplayObjects() : void
		{
			_box = new VBox( this, 0, 0 );
			_box.spacing = 5;

			_connection = new PushButton( _box, 0, 0, CONNECT, onConnectionClick );
			_connection.toggle = true;

			_me = new PushButton( _box, 0, 0, "Me", onMeClick );
			_me.visible = _connection.selected;
		}

		private function onConnectionClick( event : MouseEvent ) : void
		{
			if ( _connection.selected )
			{
				Facebook.gi.login();

				_connection.label = DISCONNECT;
			}
			else
			{
				Facebook.gi.logout();

				_connection.label = CONNECT;
			}

			_me.visible = _connection.selected;
		}

		private function onMeClick( event : MouseEvent ) : void
		{
			Facebook.gi.getUser( null, onGetMe );
		}

		private function onGetMe( response : Object, error : Object ) : void
		{
			JSBridge.log( response );
			trace( JSON.encode( response, true, 40 ) );
		}
	}
}
