package com.akqa.api.facebook.helpers
{
	public class FacebookPublish
	{
		private var _data : Object = {};
		private var _attachment : Object = {};

		public function FacebookPublish( name : String = "", href : String = "", caption : String = "", description : String = "" )
		{
			_data.attachment = _attachment;
			_data.action_links = [];
			_attachment.name = name;
			_attachment.caption = caption;
			_attachment.description = description;
			_attachment.href = href;
			_attachment.media = [];
			_attachment.properties = {};
		}

		public function getData() : Object
		{
			return _data;
		}

		public function setName( name : String ) : FacebookPublish
		{
			_attachment.name = name;

			return this;
		}

		public function setCaption( caption : String ) : FacebookPublish
		{
			_attachment.caption = caption;

			return this;
		}

		public function setDescription( description : String ) : FacebookPublish
		{
			_attachment.description = description;

			return this;
		}

		public function setHref( href : String ) : FacebookPublish
		{
			_attachment.href = href;

			return this;
		}

		public function addMedia( type : String, src : String, href : String ) : FacebookPublish
		{
			( _attachment.media as Array ).push( { type:type, src:src, href:href } );

			return this;
		}

		public function addActionLink( text : String, href : String ) : FacebookPublish
		{
			( _data.action_links as Array ).push( { text:text, href:href } );

			return this;
		}

		public function addProperty( name : String, params : Object ) : FacebookPublish
		{
			_attachment.properties[ name ] = params;

			return this;
		}
	}
}
