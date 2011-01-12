package com.akqa.api.facebook.data
{
	import flash.utils.Dictionary;

	public class FacebookSession
	{
		private static var _instance : FacebookSession;
		private var _uid : String;
		private var _sessionKey : String;
		private var _expireDate : Date;
		private var _accessToken : String;
		private var _secret : String;
		private var _sig : String;
		private var _availablePermissions : Dictionary = new Dictionary();

		public function FacebookSession( se : SE )
		{
			se;
		}

		public static function get gi() : FacebookSession
		{
			return _instance || ( _instance = new FacebookSession( new SE() ) );
		}

		public function setSession( data : * ) : void
		{
			if (data != null)
			{
				_uid = data.uid;
				_accessToken = data.access_token;
				_sessionKey = data.session_key;
				_secret = data.secret;
				_sig = data.sig;
				_expireDate = String( data.expires ).indexOf( " " ) > 0 ? new Date( data.expires ) : new Date( Number( data.expires ) );
			}
		}

		public function setPermissions( perms : * ) : void
		{
			_availablePermissions = new Dictionary();

			var arr : Array = String( perms ).split( "," );
			var perm : String;
			for each ( perm in arr )
				_availablePermissions[ perm ] = true;
		}

		public function hasPermission( perm : String ) : Boolean
		{
			return _availablePermissions[ perm ];
		}

		public function toString() : String
		{
			var s : String = '';
			s += '[ Begin Facebook Session --';
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
			s += '-- End Facebook Session ]';
			return s;
		}
	}
}
internal class SE
{
}