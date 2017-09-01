package com.flexicious.example.model.billing
{
	import com.flexicious.example.model.BaseEntity;

	[Bindable()]
	public class Product extends BaseEntity
	{
		public var name:String;
		public var unitPrice:Number;
		public var description:String;
		public var partNumber:String;
		
		public function Product()
		{
		}
		public override function createNew():BaseEntity{
			return new Product();
		}
	}
}