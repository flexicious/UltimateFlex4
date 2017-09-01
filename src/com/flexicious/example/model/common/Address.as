package com.flexicious.example.model.common
{
	import com.flexicious.example.model.BaseEntity;
	import com.flexicious.example.model.common.ReferenceData;

	[Bindable()]
	public class Address extends BaseEntity
	{
		public var addressType:ReferenceData;
		public var isPrimary:Boolean;
		
		public var line1:String;
		public var line2:String;
		public var line3:String;
		public var city:ReferenceData;
		public var state:ReferenceData;
		public var country:ReferenceData;
		public var postalCode:String;
		
		public function Address()
		{
		}
		public override function createNew():BaseEntity{
			return new Address();
		}
	}
}