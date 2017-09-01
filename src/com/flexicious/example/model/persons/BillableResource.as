package com.flexicious.example.model.persons
{
	import com.flexicious.example.model.BaseEntity;

	[Bindable()]
	public class BillableResource extends Person
	{
		public var billingRate:Number;
		public var utilization:Number;
		public var isCurrentlyUtilized:Number;
		
		public function BillableResource()
		{
		}
		public override function createNew():BaseEntity{
			return new BillableResource();
		}
	}
}