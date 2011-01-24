package com.akqa.api.facebook.helpers
{
	public class FacebookPost
	{
		private var _data : Object = {};

		public function FacebookPost( message : String = "", link : String = "", name : String = "", caption : String = "", description : String = "", picture : String = "" )
		{
			_data.message = message;
			_data.link = link;
			_data.name = name;
			_data.caption = caption;
			_data.description = description;
			_data.picture = picture;
		}

		public function getData() : Object
		{
			return _data;
		}

		public function setMessage( message : String ) : FacebookPost
		{
			_data.message = message;

			return this;
		}

		public function setLink( link : String ) : FacebookPost
		{
			_data.link = link;

			return this;
		}

		public function setName( name : String ) : FacebookPost
		{
			_data.name = name;

			return this;
		}

		public function setCaption( caption : String ) : FacebookPost
		{
			_data.caption = caption;

			return this;
		}

		public function setDescription( description : String ) : FacebookPost
		{
			_data.description = description;

			return this;
		}

		public function setPicture( picture : String ) : FacebookPost
		{
			_data.picture = picture;

			return this;
		}
	}
}
