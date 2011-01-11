/**
 *
 * HOW TO USE:
 *
 *
import com.akqa.utils.FacebookHelper;

// Launch the login window
FacebookHelper.gi.login();

// Launch the publish window
FacebookHelper.gi.publish();

// Subscribe to events relative to Facebook
FacebookHelper.gi.addEventListener(FacebookHelper.E_USER_DATA, this.onFBUserData);

// Listen for the event
private function onFBUserData(e:Event):void {
// We just got the User data (retrieve from FacebookHelper.gi.user)
trace("Facebook - User: ["+FacebookHelper.gi.user_id+"] "+FacebookHelper.gi.user_name, true);
}
 *
 *
 *
 */
package com.akqa.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	/*
	 * FacebookHelper.as (a AS <-> Facebook Interface Helper)
	 *
	 * @author: AKQA
	 * @version: 0.2
	 * @date: May 22, 2010
	 *
	 */
	public class FacebookHelper extends EventDispatcher
	{
		public static const E_LOGGED_IN : String = "E_LOGGED_IN";
		public static const E_LOGIN_CANCEL : String = "E_LOGIN_CANCEL";
		public static const E_LOGGED_OUT : String = "E_LOGGED_OUT";
		public static const E_USER_DATA : String = "E_USER_DATA";
		public static const E_PUBLISH_OK : String = "E_PUBLISH_OK";
		public static const E_PUBLISH_CANCEL : String = "E_PUBLISH_CANCEL";
		private static var _instance : FacebookHelper;
		private static var  _isInitialized : Boolean;

		public function FacebookHelper( se : SingletonEnforcer )
		{
			if ( !_isInitialized )
				this.setupJSListeners( );
		}

		//----------------------------------------------------------------------------
		// Interface
		//----------------------------------------------------------------------------
		public static function get gi( ) : FacebookHelper
		{
			if ( _instance == null ) _instance = new FacebookHelper( new SingletonEnforcer( ) );
			return _instance;
		}

		public static function get isInitialized() : Boolean
		{
			return _isInitialized;
		}

		public function init() : void
		{
			_isInitialized = true;

			this.setupJSListeners( );
		}

		//----------------------------------------------------------------------------
		// USER
		//----------------------------------------------------------------------------
		private var _user : Object = null;

		//private  var user:Object = {id:"2", name:"John Doe", pic_square:""};
		public function get isLoggedIn() : Boolean
		{
			//return false;
			return (user != null);
		}

		public function get user() : Object
		{
			return _user;
		}

		public function get user_id() : String
		{
			return user ? user.id : "";
		}

		public function get user_name() : String
		{
			return user ? user.name : "";
		}

		public function get user_pic_square() : String
		{
			return user ? user.pic_square : "";
		}

		//----------------------------------------------------------------------------
		// Acctions
		//----------------------------------------------------------------------------
		public function login() : void
		{
			JSBridge.gi.call( "fb_login" );
		}

		public function logout() : void
		{
			JSBridge.gi.call( "fb_logout" );

			//callback?
		}

		public function share(url : String) : void
		{
			JSBridge.gi.call( "fb_share", url );
		}

		//----------------------------------------------------------------------------
		// Action - Publish
		//----------------------------------------------------------------------------
		//public function publish():void {
		//	JSBridge.gi.call("fb_publish");
		//}
		public function publish(
				customMessage : String,
				titleText : String,
				titleLinkURL : String,
				descriptionText : String,
				imageURL : String,
				action_links : String,
				user_prompt_message : String
				) : void
		{
			JSBridge.gi.call( "fb_publish", customMessage, titleText, titleLinkURL, descriptionText, imageURL, action_links, user_prompt_message );
		}

		//----------------------------------------------------------------------------
		// Action - Post
		//----------------------------------------------------------------------------
		public function post(
				post_body : String,
            	post_link_url : String,
            	post_link_name : String,
            	post_link_caption : String,
            	post_picture : String,
                post_description : String

				) : void
		{
			JSBridge.gi.call( "fb_post", post_body, post_link_url, post_link_name, post_link_caption, post_picture, post_description );
		}

		//----------------------------------------------------------------------------
		// Listeners
		//----------------------------------------------------------------------------
		private function setupJSListeners( ) : void
		{
			JSBridge.gi.addCallback( "on_logged_in", this.onLoggedIn );
			JSBridge.gi.addCallback( "on_login_cancel", this.onLoginCancel );
			JSBridge.gi.addCallback( "on_get_user", this.onGetUser );
			JSBridge.gi.addCallback( "on_logged_out", this.onLoggedOut );
			JSBridge.gi.addCallback( "on_publish_ok", this.onPublishOk );
			JSBridge.gi.addCallback( "on_publish_cancel", this.onPublishCancel );
		}

		private function onLoggedIn(response : *= null) : void
		{
			this.dispatchEvent( new Event( FacebookHelper.E_LOGGED_IN ) );
		}

		private function onLoginCancel(response : *= null) : void
		{
			this.dispatchEvent( new Event( FacebookHelper.E_LOGIN_CANCEL ) );
		}

		private function onGetUser(response : *= null) : void
		{
			_user = response;

			this.dispatchEvent( new Event( FacebookHelper.E_USER_DATA ) );
		}

		private function onLoggedOut(response : *= null) : void
		{
			_user = null;

			this.dispatchEvent( new Event( FacebookHelper.E_LOGGED_OUT ) );
		}

		private function onPublishOk(response : *= null) : void
		{
			this.dispatchEvent( new Event( FacebookHelper.E_PUBLISH_OK ) );
		}

		private function onPublishCancel(response : *= null) : void
		{
			this.dispatchEvent( new Event( FacebookHelper.E_PUBLISH_CANCEL ) );
		}
	}
}

class SingletonEnforcer
{
}
