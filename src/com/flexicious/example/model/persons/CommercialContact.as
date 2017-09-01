package com.flexicious.example.model.persons
{
	import com.flexicious.example.model.BaseEntity;

	[Bindable()]
	public class CommercialContact extends Person
	{
		
		public function CommercialContact()
		{
		}
		public override function createNew():BaseEntity{
			return new CommercialContact();
		}
	}
}