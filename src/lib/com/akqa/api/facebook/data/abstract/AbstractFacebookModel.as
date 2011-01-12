package com.akqa.api.facebook.data.abstract
{
	import com.adobe.serialization.json.JSON;

	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;

	public class AbstractFacebookModel
	{
		private var _source : String;
		private var _object : Object;

		public function AbstractFacebookModel( data : * )
		{
			_source = data;

			revertToOriginalState();
		}

		public function copyOriginalState() : *
		{
			return JSON.decode( _source );
		}

		public function copyCurrentState() : *
		{
			return JSON.decode( JSON.encode( _object ) );
		}

		public function revertToOriginalState() : void
		{
			_object = copyOriginalState();
		}

		public function toString() : *
		{
			var className : String = getQualifiedClassName( this ).split( "::" )[ 1 ];
			var xml : XML = describeType( this );
			var accessor : XML;
			var n : String;
			var s : String = "";
			s += "\n";
			s += "   ::: " + className + " Begin";
			s += "\n";
			for each ( accessor in xml..accessor )
			{
				n = accessor.@name;
				s += "      ::: " + n + " : " + this[ n ];
				s += "\n";
			}
			s += "   ::: " + className + " End";
			return s;
		}

		public function get log() : String
		{
			var className : String = getQualifiedClassName( this ).split( "::" )[ 1 ];
			var s : String = "";
			s += "\n";
			s += "   ::: " + className + " Begin";
			s += "   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!";
			s += "   !!! REMOVE FOR PRODUCTION !!!";
			s += "   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!";
			s += "\n";
			s += copyCurrentState();
			s += "   ::: " + className + " End";
			return s;
		}
	}
}
