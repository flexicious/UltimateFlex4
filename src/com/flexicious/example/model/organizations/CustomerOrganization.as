package com.flexicious.example.model.organizations
{
	import com.flexicious.example.model.BaseEntity;
	import com.flexicious.example.model.common.Address;

	[Bindable()]
	public class CustomerOrganization extends Organization
	{
		public var billingAddress:Address;
		public function CustomerOrganization()
		{
		}
		public override function createNew():BaseEntity{
			return new CustomerOrganization();
		}
	}
}