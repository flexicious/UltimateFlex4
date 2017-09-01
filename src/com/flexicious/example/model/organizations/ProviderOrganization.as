package com.flexicious.example.model.organizations
{
	import com.flexicious.example.model.BaseEntity;
	import com.flexicious.example.model.common.Address;

	[Bindable()]
	public class ProviderOrganization  extends Organization
	{
		public var paymentAddress:Address;
		public function ProviderOrganization()
		{
		}
		public override function createNew():BaseEntity{
			return new ProviderOrganization();
		}
	}
}