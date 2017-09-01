package com.flexicious.example.model.billing
{
	import com.flexicious.example.model.BaseEntity;
	
	import mx.messaging.Producer;

	[Bindable()]
	public class LineItem extends BaseEntity
	{
		public var invoice:Invoice;
		public var lineItemAmount:Number;
		public var lineItemDescription:String;
		public var units:Number;

		public function LineItem()
		{
		}
		public override function createNew():BaseEntity{
			return new LineItem();
		}
		public function get parent():*{
			return invoice;
		}
		public function set parent(val:*):void{
			invoice=val as Invoice;
		}
	}
}