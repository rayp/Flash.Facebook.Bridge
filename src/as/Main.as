package
{
	import com.akqa.api.facebook.Facebook;
	import com.akqa.api.facebook.events.FacebookEvent;
	import com.akqa.utils.JSBridge;
	import com.akqa.views.MainView;
	import flash.display.Sprite;
	import flash.events.Event;

	public class Main extends Sprite
	{
		private var _view : MainView;

		public function Main()
		{
			addEventListener( Event.ADDED_TO_STAGE, function( event : Event ) : void
			{
				initJSBridge();
			} );
		}

		private function initJSBridge() : void
		{
			JSBridge.gi.addEventListener( JSBridge.E_READY, function( event : Event ) : void
			{
				initFacebook();
			} );

			JSBridge.gi.initialize( loaderInfo );
		}

		private function initFacebook() : void
		{
			Facebook.gi.addEventListener( FacebookEvent.READY, function( event : Event ) : void
			{
				initViews();
			} );

			Facebook.gi.init();
		}

		private function initViews() : void
		{
			_view = new MainView();

			addChild( _view );
		}
	}
}
