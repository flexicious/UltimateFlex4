package com.flexicious.example.model.persons
{
	import com.flexicious.example.model.BaseEntity;
	import com.flexicious.example.model.common.Address;
	
	[Bindable()]
	public class Person extends BaseEntity
	{
		public var firstName:String;
		public var lastName:String;
		public function get displayName():String{return firstName + " " +lastName;}
		public var telephone:String;
		public var homeAddress:Address;
		public function Person()
		{
		}
		public override function createNew():BaseEntity{
			return new Person();
		}
	}
}