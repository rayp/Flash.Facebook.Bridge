package com.akqa.api.facebook.data
{
	public class FacebookSession
	{
		private static var _instance : FacebookSession;
		private var _uid : String = "";
		private var _accessToken : String = "";
		private var _sessionKey : String = "";
		private var _secret : String = "";
		private var _sig : String = "";
		private var _status : String = "";
		private var _expireDate : Date;
		private var _availablePermissions : Array = new Array();

		public function FacebookSession( se : SE )
		{
			se;
		}

		public static function get gi() : FacebookSession
		{
			return _instance || ( _instance = new FacebookSession( new SE() ) );
		}

		public function update( session : Object, perms : String = "none", status : String = "unknown" ) : void
		{
			if ( session )
			{
				_uid = session.uid;
				_accessToken = session.access_token;
				_sessionKey = session.session_key;
				_secret = session.secret;
				_sig = session.sig;
				_expireDate = String( session.expires ).indexOf( " " ) > 0 ? new Date( session.expires ) : new Date( Number( session.expires ) );
			}
			else
			{
				_uid = "";
				_accessToken = "";
				_sessionKey = "";
				_secret = "";
				_sig = "";
				_expireDate = null;
			}

			// Update permissions
			var perm : String;
			for each ( perm in _availablePermissions )
				_availablePermissions[ perm ] = false;
			var arr : Array = String( perms ).split( "," );
			for each ( perm in arr )
				_availablePermissions[ perm ] = true;
				
			// Update status
			_status = status;
		}

		public function get uid() : String
		{
			return _uid;
		}

		public function get sessionKey() : String
		{
			return _sessionKey;
		}

		public function get expireDate() : Date
		{
			return _expireDate;
		}

		public function get accessToken() : String
		{
			return _accessToken;
		}

		public function get secret() : String
		{
			return _secret;
		}

		public function get sig() : String
		{
			return _sig;
		}

		public function get isConnected() : Boolean
		{
			return ( _status == "connected" );
		}

		public function getPermissions() : Array
		{
			var arr : Array = [];
			var perm : String;
			for each ( perm in _availablePermissions )
				arr.push( perm );

			return arr;
		}

		public function hasPermission( perm : String ) : Boolean
		{
			return _availablePermissions[ perm ];
		}

		public function toString() : String
		{
			var s : String = '';
			s += '[ --';
			s += '\n';
			s += 'userId:' + _uid;
			s += '\n';
			s += 'accessToken:' + _accessToken;
			s += '\n';
			s += 'sessionKey:' + _sessionKey;
			s += '\n';
			s += 'secret:' + _secret;
			s += '\n';
			s += 'sig:' + _sig;
			s += '\n';
			s += 'expireDate:' + _expireDate;
			s += '\n';
			s += '-- ]';
			return s;
		}
	}
}
internal class SE
{
}