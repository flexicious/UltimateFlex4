package com.flexicious.example.model.billing
{
	import com.flexicious.example.model.BaseEntity;
	import com.flexicious.example.model.common.ReferenceData;
	import com.flexicious.example.model.transactions.Deal;
	
	import mx.collections.ArrayCollection;
	[Bindable()]
	public class Invoice extends BaseEntity
	{
		public var deal:Deal;
		public var invoiceDate:Date;
		public var dueDate:Date;
		public var invoiceStatus:ReferenceData;
		public var lineItems:ArrayCollection=new ArrayCollection();
		public var hasPdf:Boolean=true;
		
		public function get invoiceNumber():Number{
			return id;
		}
		public function get invoiceAmount():Number{
			var total:Number=0;
			for each(var lineItem:LineItem in lineItems){
				total+= lineItem.lineItemAmount;
			}
			return total;
		}
		public function Invoice()
		{
		}
		public override function createNew():BaseEntity{
			return new Invoice();
		}
		//HierarchicalData Support.
		public function get children():*{
			return lineItems;
		}
		public function get parent():*{
			return deal;
		}
		public function set parent(val:*):void{
			deal=val as Deal;
		}
		
		public function get invoiceStatusName():String{
			return invoiceStatus.name;
		}
	}
}