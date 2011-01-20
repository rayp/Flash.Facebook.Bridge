package com.akqa.views
{
	import com.akqa.api.facebook.Facebook;
	import com.akqa.api.facebook.events.FacebookEvent;
	import com.akqa.api.facebook.events.NativeFacebookEvent;
	import com.akqa.utils.JSBridge;
	import com.bit101.components.List;
	import com.bit101.components.PushButton;
	import com.bit101.components.VBox;
	import com.maccherone.json.JSON;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class MainView extends Sprite
	{
		public static const IMAGE_SIZE : int = 50;
		public static const TEXT_WIDTH : int = 150;
		public static const TEXT_HEIGHT : int = IMAGE_SIZE;
		public static const PAD : int = 5;
		public static const PADx2 : int = PAD * 2;
		private static const CONNECT : String = "Connect";
		private static const DISCONNECT : String = "Disconnect";
		private var _connectionBtn : PushButton;
		private var _meBtn : PushButton;
		private var _mePanel : ProfilePanel;
		private var _friendsBtn : PushButton;
		private var _friendsList : List;

		public function MainView()
		{
			addEventListener( Event.ADDED_TO_STAGE, function() : void
			{
				addDisplayObjects();
			} );
		}

		private function formatObject( ob : Object ) : String
		{
			return JSON.encode( ob, true, 40 );
		}

		private function addDisplayObjects() : void
		{
			var vBox : VBox = new VBox( this, 0, 0 );
			vBox.spacing = PAD;

			_connectionBtn = new PushButton( vBox, 0, 0, CONNECT, onConnectionClick );
			_connectionBtn.toggle = true;

			_meBtn = new PushButton( vBox, 0, 0, "Me", onGetUserClick );
			_meBtn.visible = _connectionBtn.selected;

			_mePanel = new ProfilePanel( vBox );
			_mePanel.visible = false;

			_friendsBtn = new PushButton( vBox, 0, 0, "Friends", onFriendsClick );
			_friendsBtn.visible = false;

			_friendsList = new List( vBox, 0, 0, [] );
			_friendsList.visible = false;
			_friendsList.listItemClass = FriendListItem;
			_friendsList.listItemHeight = TEXT_HEIGHT + PADx2;
			_friendsList.setSize( IMAGE_SIZE + TEXT_WIDTH + PAD + PADx2, ( TEXT_HEIGHT + PADx2 ) * 5 );
		}

		private function onGetUserClick( event : MouseEvent ) : void
		{
			// ---- BEGIN NOTE ----
			// Adding Facebook style callback will require handler sinature in Facebook style.
			// E.g.
			// onGetUserCallback( response : Object, error : Object ) : void {};
			// It may be more intuitive to use the Event model for routine API requests.
			// E.g.
			Facebook.gi.addEventListener( FacebookEvent.OBJECT, onGetUserEvent );
			// ---- END NOTE ----

			Facebook.gi.getObject( null, onGetUserCallback, { fields:"id,name,picture" } );
		}

		private function onConnectionClick( event : MouseEvent ) : void
		{
			if ( _connectionBtn.selected )
			{
				// ---- BEGIN NOTE ----
				// The callback for the native Facebook event "auth_login" will not be called when
				// the login process is circumvented by extracting session from the cookie or JS.
				Facebook.gi.subscribe( NativeFacebookEvent.AUTH_LOGIN, onFacebookLoginCallback );
				Facebook.gi.unsubscribe( NativeFacebookEvent.AUTH_LOGOUT, onFacebookLogoutCallback );
				// It is more reliable to listen for the custom JS events for login/logout.
				Facebook.gi.addEventListener( FacebookEvent.LOGGED_IN, onFacebookLoggedIn );
				Facebook.gi.removeEventListener( FacebookEvent.LOGGED_OUT, onFacebookLoggedOut );
				// ---- END NOTE ----

				Facebook.gi.login();

				_connectionBtn.label = DISCONNECT;
			}
			else
			{
				// Native Facebook Events
				Facebook.gi.subscribe( NativeFacebookEvent.AUTH_LOGOUT, onFacebookLoginCallback );
				Facebook.gi.unsubscribe( NativeFacebookEvent.AUTH_LOGIN, onFacebookLoginCallback );
				// Custom Facebook Events
				Facebook.gi.removeEventListener( FacebookEvent.LOGGED_IN, onFacebookLoggedIn );
				Facebook.gi.addEventListener( FacebookEvent.LOGGED_OUT, onFacebookLoggedOut );

				Facebook.gi.logout();

				_connectionBtn.label = CONNECT;
			}

			_meBtn.visible = _connectionBtn.selected;
		}

		private function onFacebookLoginCallback( response : Object ) : void
		{
			JSBridge.log( response );
			trace( formatObject( response ) );
		}

		private function onFacebookLogoutCallback( response : Object ) : void
		{
			JSBridge.log( response );
			trace( formatObject( response ) );
		}

		private function onFacebookLoggedIn( event : FacebookEvent ) : void
		{
			JSBridge.log( event.response );
			trace( formatObject( event.response ) );
		}

		private function onFacebookLoggedOut( event : FacebookEvent ) : void
		{
			JSBridge.log( event.response );
			trace( formatObject( event.response ) );
		}

		private function onGetUserEvent( event : FacebookEvent ) : void
		{
			JSBridge.log( event.response );
			// trace( "MainView.onGetUserEvent : \n" + JSON.encode( event.response, true, 40 ) );
		}

		private function onGetUserCallback( response : Object, error : Object ) : void
		{
			// JSBridge.log( response );
			// trace( formatObject( response ) );

			_mePanel.data = new ProfileData( response );
			_mePanel.visible = true;

			_friendsBtn.visible = true;
		}

		private function onFriendsClick( event : MouseEvent ) : void
		{
			Facebook.gi.getFriends( null, onGetFriendsCallback, { fields:"id,name,picture" } );
		}

		private function onGetFriendsCallback( response : Object, error : Object ) : void
		{
			// JSBridge.log( response );
			// trace( formatObject( response ) );

			var items : Array = new Array();
			var data : Object;

			for each ( data in response )
				items.push( new ProfileData( data ) );

			_friendsList.items = items;
			_friendsList.visible = true;
		}
	}
}
import com.akqa.views.MainView;
import com.bit101.components.Component;
import com.bit101.components.HBox;
import com.bit101.components.ListItem;
import com.bit101.components.Panel;
import com.bit101.components.TextArea;
import com.greensock.events.LoaderEvent;
import com.greensock.loading.SWFLoader;

import flash.display.Bitmap;
import flash.display.DisplayObjectContainer;
import flash.events.Event;

internal class ProfileData
{
	private var _id : String;
	private var _name : String;
	private var _pictureUrl : String;
	private var _pictureBitmap : Bitmap;

	public function ProfileData( data : Object = null )
	{
		update( data );
	}

	public function get label() : String
	{
		return _id + "\n" + _name;
	}

	public function get pictureUrl() : String
	{
		return _pictureUrl;
	}

	public function get pictureBitmap() : Bitmap
	{
		return _pictureBitmap;
	}

	public function set pictureBitmap( value : Bitmap ) : void
	{
		_pictureBitmap = value;
	}

	public function update( data : Object ) : void
	{
		_id = data.id;
		_name = data.name;
		_pictureUrl = data.picture;
	}
}
internal class ProfilePanel
extends Panel
{
	private var _data : ProfileData;
	private var _hBox : HBox;
	private var _picture : Panel;
	private var _textArea : TextArea;

	public function ProfilePanel( parent : DisplayObjectContainer = null, data : ProfileData = null )
	{
		super( parent );

		this.data = data;
	}

	public function set data( value : ProfileData ) : void
	{
		_data = value;

		if ( !_data ) return;

		_textArea.text = _data.label;

		if ( _data.pictureBitmap )
		{
			updatePicture( _data.pictureBitmap );
		}
		else
		{
			new SWFLoader( _data.pictureUrl, { onComplete:function( event : LoaderEvent ) : void
			{
				_data.pictureBitmap = SWFLoader( event.target ).rawContent;

				updatePicture( _data.pictureBitmap );
			} } ).load();
		}
	}

	private function updatePicture( bitmap : Bitmap ) : void
	{
		if ( _picture.content.numChildren == 1 )
			_picture.content.removeChildAt( 0 );
		_picture.content.addChild( bitmap );
	}

	override protected function init() : void
	{
		super.init();

		var PADx2 : int = MainView.PADx2;

		setSize( _hBox.width + PADx2, _hBox.height + PADx2 );
	}

	protected override function addChildren() : void
	{
		super.addChildren();

		var PAD : int = MainView.PAD;
		var imageSize : int = MainView.IMAGE_SIZE;

		_picture = new Panel();
		_picture.setSize( imageSize, imageSize );

		_textArea = new TextArea();
		_textArea.editable = false;
		_textArea.autoHideScrollBar = true;
		_textArea.setSize( MainView.TEXT_WIDTH, MainView.TEXT_HEIGHT );

		_hBox = new HBox( null, PAD, PAD );
		_hBox.spacing = PAD;
		_hBox.addChild( _picture );
		_hBox.addChild( _textArea );
		_hBox.draw();

		content.addChild( _hBox );
	}
}
internal class FriendListItem
extends ListItem
{
	private var _panel : ProfilePanel;

	public function FriendListItem( parent : DisplayObjectContainer = null, xpos : Number = 0, ypos : Number = 0, data : Object = null )
	{
		super( parent, xpos, ypos, data );
	}

	override public function set data( value : Object ) : void
	{
		_panel.data = value as ProfileData;

		invalidate();
	}

	public override function draw() : void
	{
		_panel.draw();

		dispatchEvent( new Event( Component.DRAW ) );
	}

	protected override function addChildren() : void
	{
		_panel = new ProfilePanel( this );
	}
}
