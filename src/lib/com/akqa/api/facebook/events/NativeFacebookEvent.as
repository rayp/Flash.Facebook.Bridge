package com.akqa.api.facebook.events
{

	public class NativeFacebookEvent
	{
		// Types
		private static const AUTH_LOGIN_TYPE : String = "auth.login";
		private static const AUTH_LOGOUT_TYPE : String = "auth.logout";
		private static const AUTH_SESSION_CHANGE_TYPE : String = "auth.sessionChange";
		private static const AUTH_STATUS_CHANGE_TYPE : String = "auth.statusChange";
		private static const XFBML_RENDER_TYPE : String = "xfbml.render";
		private static const EDGE_CREATE_TYPE : String = "edge.create";
		private static const EDGE_REMOVE_TYPE : String = "edge.remove";
		private static const COMMENTS_ADD_TYPE : String = "comments.add";
		private static const FB_LOG_TYPE : String = "fb.log";
		// Events
		public static const AUTH_LOGIN : NativeFacebookEvent = new NativeFacebookEvent( AUTH_LOGIN_TYPE );
		public static const AUTH_LOGOUT : NativeFacebookEvent = new NativeFacebookEvent( AUTH_LOGOUT_TYPE );
		public static const AUTH_SESSION_CHANGE : NativeFacebookEvent = new NativeFacebookEvent( AUTH_SESSION_CHANGE_TYPE );
		public static const AUTH_STATUS_CHANGE : NativeFacebookEvent = new NativeFacebookEvent( AUTH_STATUS_CHANGE_TYPE );
		public static const XFBML_RENDER : NativeFacebookEvent = new NativeFacebookEvent( XFBML_RENDER_TYPE );
		public static const EDGE_CREATE : NativeFacebookEvent = new NativeFacebookEvent( EDGE_CREATE_TYPE );
		public static const EDGE_REMOVE : NativeFacebookEvent = new NativeFacebookEvent( EDGE_REMOVE_TYPE );
		public static const COMMENTS_ADD : NativeFacebookEvent = new NativeFacebookEvent( COMMENTS_ADD_TYPE );
		public static const FB_LOG : NativeFacebookEvent = new NativeFacebookEvent( FB_LOG_TYPE );
		private var _type : String;

		public function NativeFacebookEvent( type : String )
		{
			switch( type )
			{
				case AUTH_LOGIN_TYPE:
				case AUTH_LOGOUT_TYPE:
				case AUTH_SESSION_CHANGE_TYPE:
				case AUTH_STATUS_CHANGE_TYPE:
				case XFBML_RENDER_TYPE:
				case EDGE_CREATE_TYPE:
				case EDGE_REMOVE_TYPE:
				case COMMENTS_ADD_TYPE:
				case FB_LOG_TYPE:
					// type checks out
					_type = type;
					break;
				default:
					throw new Error( "!!!! " + type + " is not a valid type." );
			}
		}

		public function get type() : String
		{
			return _type;
		}

		public function toString() : String
		{
			var s : String = "";
			s += "[";
			s += "NativeFacebookEvent : " + type;
			s += "]";
			return s;
		}
	}
}
