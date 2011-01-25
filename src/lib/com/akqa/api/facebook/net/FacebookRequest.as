package com.akqa.api.facebook.net
{
	import com.adobe.images.PNGEncoder;
	import com.maccherone.json.JSON;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.DataEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;

	public class FacebookRequest
	{
		private var _urlLoader : URLLoader;
		private var _fileReference : FileReference;
		private var _urlRequest : URLRequest;
		private var _rawResult : String;
		private var _data : Object;
		private var _success : Boolean;
		private var _url : String;
		private var _requestMethod : String;
		private var _callback : Function;

		public function FacebookRequest( url : String, requestMethod : String = 'GET', callback : Function = null ) : void
		{
			_url = url;
			_requestMethod = requestMethod;
			_callback = callback;
		}

		public function get url() : String
		{
			return _urlRequest ? _urlRequest.url : _url;
		}

		public function get rawResult() : String
		{
			return _rawResult;
		}

		public function get success() : Boolean
		{
			return _success;
		}

		public function get data() : Object
		{
			return _data;
		}

		public function call( method : String, values : * = null, callback : Function = null ) : void
		{
			if ( callback != null )
				_callback = callback;

			var requestUrl : String = _url + method;

			_urlRequest = new URLRequest( requestUrl );
			_urlRequest.method = _requestMethod;

			// If there are no user defined values, just send the request as is.
			if ( !values )
			{
				loadURLLoader();

				return;
			}

			// Check to see if there is a file we can upload.
			var fileData : Object;
			if ( isValueFile( values ) )
			{
				fileData = values;
			}
			else if ( values )
			{
				var n : String;

				for ( n in values )
				{
					if ( isValueFile( values[n] ) )
					{
						fileData = values[n];
						delete values[n];
						break;
					}
				}
			}

			_urlRequest.data = objectToURLVariables( values );

			// There is no fileData, so just send it off.
			if ( fileData == null )
			{
				loadURLLoader();

				return;
			}

			// If the fileData is a FileReference, let it handle this request.
			if ( fileData is FileReference )
			{
				_urlRequest.method = URLRequestMethod.POST;
				_fileReference = fileData as FileReference;
				_fileReference.addEventListener( DataEvent.UPLOAD_COMPLETE_DATA, onFileReferenceComplete, false, 0, true );
				_fileReference.addEventListener( IOErrorEvent.IO_ERROR, onFileReferenceError, false, 0, false );
				_fileReference.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onFileReferenceError, false, 0, false );
				_fileReference.upload( _urlRequest );

				return;
			}

			// There is fileData attached here, need to format it correctly,
			// then send it to Facebook.
			var post : PostRequest = new PostRequest();

			// Write the primitive values first.
			for (n in values)
				post.writePostData( n, values[n] );

			// If we have a Bitmap, extract its BitmapData for upload.
			if (fileData is Bitmap)
				fileData = (fileData as Bitmap).bitmapData;

			if (fileData is ByteArray)
			{
				// If we have a ByteArray, upload as is.
				post.writeFileData( values.fileName, fileData as ByteArray, values.contentType );
			}
			else if (fileData is BitmapData)
			{
				// If we have a BitmapData, create a ByteArray, then upload.
				var ba : ByteArray = PNGEncoder.encode( fileData as BitmapData );
				post.writeFileData( values.fileName, ba, 'image/png' );
			}

			post.close();

			_urlRequest.contentType = 'multipart/form-data; boundary=' + post.boundary;
			_urlRequest.data = post.getPostData();
			_urlRequest.method = URLRequestMethod.POST;

			loadURLLoader();
		}

		public function close() : void
		{
			if ( _urlLoader )
			{
				_urlLoader.removeEventListener( Event.COMPLETE, onLoaderComplete );
				_urlLoader.removeEventListener( IOErrorEvent.IO_ERROR, onLoaderError );
				_urlLoader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, onLoaderError );

				try
				{
					_urlLoader.close();
				}
				catch ( e : * )
				{
				}

				_urlLoader = null;
			}

			if ( _fileReference )
			{
				_fileReference.removeEventListener( DataEvent.UPLOAD_COMPLETE_DATA, onFileReferenceComplete );
				_fileReference.removeEventListener( IOErrorEvent.IO_ERROR, onFileReferenceError );
				_fileReference.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, onFileReferenceError );

				try
				{
					_fileReference.cancel();
				}
				catch ( e : * )
				{
				}

				_fileReference = null;
			}
		}

		/**
		 * 
		 * Internal
		 * 
		 */
		private function loadURLLoader() : void
		{
			_urlLoader = new URLLoader();
			_urlLoader.addEventListener( Event.COMPLETE, onLoaderComplete, false, 0, false );
			_urlLoader.addEventListener( IOErrorEvent.IO_ERROR, onLoaderError, false, 0, true );
			_urlLoader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onLoaderError, false, 0, true );
			_urlLoader.load( _urlRequest );
		}

		private function isValueFile( value : Object ) : Boolean
		{
			return ( value is FileReference || value is Bitmap || value is BitmapData || value is ByteArray );
		}

		private function objectToURLVariables( values : Object ) : URLVariables
		{
			var urlVars : URLVariables = new URLVariables();

			if ( !values )
				return urlVars;

			var n : String;
			for ( n in values )
				urlVars[n] = values[n];

			return urlVars;
		}

		private function handleDataLoad( result : Object, dispatchCompleteEvent : Boolean = true ) : void
		{
			_rawResult = result as String;
			_success = true;

			try
			{
				_data = JSON.decode( _rawResult );
			}
			catch ( e : * )
			{
				_data = _rawResult;
				_success = false;
			}

			if ( dispatchCompleteEvent )
			{
				dispatchComplete();
			}
		}

		private function dispatchComplete() : void
		{
			_callback( this );

			close();
		}

		/**
		 * 
		 * event handlers
		 * 
		 */
		private function onLoaderComplete( event : Event ) : void
		{
			handleDataLoad( _urlLoader.data );
		}

		private function onLoaderError( event : Event ) : void
		{
			_success = false;
			_rawResult = ( event.target as URLLoader ).data;

			if ( _rawResult != '' )
			{
				try
				{
					_data = JSON.decode( _rawResult );
				}
				catch ( e : * )
				{
					_data = { type:'Exception', message:_rawResult };
				}
			}
			else
			{
				_data = event;
			}

			dispatchComplete();
		}

		private function onFileReferenceComplete( event : DataEvent ) : void
		{
			handleDataLoad( event.data );
		}

		private function onFileReferenceError( event : ErrorEvent ) : void
		{
			_success = false;
			_data = event;

			dispatchComplete();
		}

		public function toString() : String
		{
			return _urlRequest.url + ( _urlRequest.data == null ? '' : '?' + unescape( _urlRequest.data.toString() ) );
		}
	}
}