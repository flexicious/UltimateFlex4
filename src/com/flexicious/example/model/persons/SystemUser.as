package com.flexicious.example.model.persons
{
	import com.flexicious.example.model.BaseEntity;

	[Bindable()]
	public class SystemUser extends Person
	{
		public var loginNm:String;
		
		public function SystemUser()
		{
		}
		public override function createNew():BaseEntity{
			return new SystemUser();
		}
	}
}