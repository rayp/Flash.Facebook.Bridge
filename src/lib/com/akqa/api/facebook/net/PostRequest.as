﻿/*
package com.akqa.api.facebook.net
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	/**
	public class PostRequest
	{
		/**
		public var boundary : String = '-----';
		/**
		protected var postData : ByteArray;

		/**
		public function PostRequest()
		{
			createPostData();
		}

		/**
		public function createPostData() : void
		{
			postData = new ByteArray();
			postData.endian = Endian.BIG_ENDIAN;
		}

		/**
		public function writePostData( name : String, value : String ) : void
		{
			var bytes : String;
			writeBoundary();
			writeLineBreak();
			bytes = 'Content-Disposition: form-data; name="' + name + '"';
			var l : uint = bytes.length;
			for (var i : Number = 0; i < l; i++)
			{
				postData.writeByte( bytes.charCodeAt( i ) );
			}
			writeLineBreak();
			writeLineBreak();
			postData.writeUTFBytes( value );
			writeLineBreak();
		}

		/**
		public function writeFileData( filename : String, fileData : ByteArray, contentType : String ) : void
		{
			var bytes : String;
			var l : int;
			var i : uint;
			writeBoundary();
			writeLineBreak();
			bytes = 'Content-Disposition: form-data; filename="';
			l = bytes.length;
			for (i = 0; i < l; i++)
			{
				postData.writeByte( bytes.charCodeAt( i ) );
			}
			postData.writeUTFBytes( filename );
			writeQuotationMark();
			writeLineBreak();
			bytes = contentType;
			l = bytes.length;
			for (i = 0; i < l; i++)
			{
				postData.writeByte( bytes.charCodeAt( i ) );
			}
			writeLineBreak();
			writeLineBreak();
			fileData.position = 0;
			postData.writeBytes( fileData, 0, fileData.length );
			writeLineBreak();
		}

		/**
		public function getPostData() : ByteArray
		{
			postData.position = 0;
			return postData;
		}

		/**
		public function close() : void
		{
			writeBoundary();
			writeDoubleDash();
		}

		/**
		protected function writeLineBreak() : void
		{
			postData.writeShort( 0x0d0a );
		}

		/**
		protected function writeQuotationMark() : void
		{
			postData.writeByte( 0x22 );
		}

		/**
		protected function writeDoubleDash() : void
		{
			postData.writeShort( 0x2d2d );
		}

		/**
		protected function writeBoundary() : void
		{
			writeDoubleDash();
			var l : uint = boundary.length;
			for (var i : uint = 0; i < l; i++)
			{
				postData.writeByte( boundary.charCodeAt( i ) );
			}
		}
	}
}