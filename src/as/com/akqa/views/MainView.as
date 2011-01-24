package com.akqa.views
{
	import com.akqa.api.facebook.Facebook;
	import com.akqa.api.facebook.events.FacebookEvent;
	import com.akqa.api.facebook.events.NativeFacebookEvent;
	import com.akqa.api.facebook.helpers.FacebookPost;
	import com.akqa.api.facebook.helpers.FacebookPublish;
	import com.akqa.utils.JSBridge;
	import com.bit101.components.HBox;
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
		private static const DUMMY_URL : String = "http://akqa.com";
		private static const CONNECT : String = "Connect";
		private static const DISCONNECT : String = "Disconnect";
		private var _connectionBtn : PushButton;
		private var _mePanel : ProfilePanel;
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
			var vBox : VBox = new VBox( this );
			vBox.spacing = PAD;

			var buttonBox : HBox = new HBox( vBox );
			buttonBox.spacing = PAD;

			_connectionBtn = new PushButton( buttonBox, 0, 0, CONNECT, onConnectionClick );
			_connectionBtn.toggle = true;

			new PushButton( buttonBox, 0, 0, "Share", onShareClick );
			new PushButton( buttonBox, 0, 0, "Publish Feed", onPublishFeedClick );
			new PushButton( buttonBox, 0, 0, "Publish Stream", onPublishStreamClick );
			new PushButton( buttonBox, 0, 0, "Post", onPostClick );

			_mePanel = new ProfilePanel( vBox );
			_mePanel.visible = false;

			_friendsList = new List( vBox, 0, 0, [] );
			_friendsList.visible = false;
			_friendsList.listItemClass = FriendListItem;
			_friendsList.listItemHeight = TEXT_HEIGHT + PADx2;
			_friendsList.setSize( IMAGE_SIZE + TEXT_WIDTH + PAD + PADx2, ( TEXT_HEIGHT + PADx2 ) * 5 );
		}

		private function onShareClick( event : MouseEvent ) : void
		{
			Facebook.gi.share( DUMMY_URL, function( response : Object ) : void
			{
				trace( formatObject( response ) );
			} );
		}

		private function onPublishFeedClick( event : MouseEvent ) : void
		{
			Facebook.gi.publishFeed( "AKQA", DUMMY_URL, null, function( response : Object ) : void
			{
				trace( formatObject( response ) );
			} );
		}

		private function onPublishStreamClick( event : MouseEvent ) : void
		{
			var options : Object = new FacebookPublish( "CNN", "http://cnn.com" )
			.setCaption( "This is..." )
			.setDescription( "... CNN!" )
			.addMedia( "image", "http://www.seeklogo.com/images/C/CNN-logo-6DA92A5BFF-seeklogo.com.gif", "http://cnn.com" )
			.addProperty( "Category", { text:"This is news.", href:"http://cnn.com" } )
			.addProperty( "Rating", "5 Star" )
			.addActionLink( "Read News", "http://cnn.com" )
			.getData();

			Facebook.gi.publishStream( options, function( response : Object ) : void
			{
				trace( formatObject( response ) );
			} );
		}

		private function onPostClick( event : MouseEvent ) : void
		{
			var options : Object = new FacebookPost( "Hey look at the news!", "http://cnn.com" )
			.setName( "CNN" )
			.setDescription( "This is CNN!" )
			.setPicture( "http://www.seeklogo.com/images/C/CNN-logo-6DA92A5BFF-seeklogo.com.gif" )
			.setCaption( "This is some news." )
			.getData();

			Facebook.gi.post( options, function( response : Object, error : Object ) : void
			{
				trace( formatObject( response ) );
			} );
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
		}

		private function onFacebookLoginCallback( response : Object ) : void
		{
			// JSBridge.log( response );
			// trace( formatObject( response ) );
		}

		private function onFacebookLogoutCallback( response : Object ) : void
		{
			// JSBridge.log( response );
			// trace( formatObject( response ) );
		}

		private function onFacebookLoggedIn( event : FacebookEvent ) : void
		{
			JSBridge.log( event.response );
			trace( formatObject( event.response ) );

			// ---- BEGIN NOTE ----
			// Adding Facebook style callback will require handler signature in Facebook style.
			// E.g.
			// onGetUserCallback( response : Object, error : Object ) : void {}
			// It may be more intuitive to use the Event model for routine API requests.
			// E.g.
			// Facebook.gi.addEventListener( FacebookEvent.OBJECT, onGetUserEvent );
			// private function onGetUserEvent( event : FacebookEvent ) : void {}
			// ---- END NOTE ----
			Facebook.gi.getObject( null, onGetUserCallback, { fields:"id,name,picture" } );
			Facebook.gi.getFriends( null, onGetFriendsCallback, { fields:"id,name,picture" } );
		}

		private function onFacebookLoggedOut( event : FacebookEvent ) : void
		{
			JSBridge.log( event.response );
			trace( formatObject( event.response ) );

			_mePanel.visible = false;
			_friendsList.visible = false;
		}

		private function onGetUserCallback( response : Object, error : Object ) : void
		{
			// JSBridge.log( response );
			// trace( formatObject( response ) );

			_mePanel.data = new ProfileData( response );
			_mePanel.visible = true;
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

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Shape;
import flash.events.Event;

internal class ProfileData
{
	private var _id : String;
	private var _name : String;
	private var _pictureUrl : String;
	private var _pictureImage : DisplayObject;

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

	public function get pictureImage() : DisplayObject
	{
		return _pictureImage;
	}

	public function set pictureImage( value : DisplayObject ) : void
	{
		_pictureImage = value;
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

		if ( _data.pictureImage )
		{
			updatePicture( _data.pictureImage );
		}
		else
		{
			new SWFLoader( _data.pictureUrl, { onError:function( event : LoaderEvent ) : void
			{
				var shape : Shape = new Shape();
				shape.graphics.beginFill( 0xEEEEEE );
				shape.graphics.drawRect( 0, 0, 50, 50 );
				shape.graphics.endFill();

				_data.pictureImage = shape;
			}, onComplete:function( event : LoaderEvent ) : void
			{
				_data.pictureImage = SWFLoader( event.target ).rawContent;

				updatePicture( _data.pictureImage );
			} } ).load();
		}
	}

	private function updatePicture( image : DisplayObject ) : void
	{
		if ( _picture.content.numChildren == 1 )
			_picture.content.removeChildAt( 0 );
		_picture.content.addChild( image );
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
