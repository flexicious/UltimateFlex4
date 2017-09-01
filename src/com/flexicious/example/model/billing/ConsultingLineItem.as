package com.flexicious.example.model.billing
{
	import com.flexicious.example.model.persons.BillableResource;

	[Bindable()]
	public class ConsultingLineItem extends LineItem
	{
		public var billableResource:BillableResource;
		public function ConsultingLineItem()
		{
		}
	}
}