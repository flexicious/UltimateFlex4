package com.flexicious.example.model.transactions
{
	import com.flexicious.example.model.BaseEntity;
	import com.flexicious.example.model.billing.Invoice;
	import com.flexicious.example.model.common.ReferenceData;
	import com.flexicious.example.model.organizations.CustomerOrganization;
	import com.flexicious.example.model.organizations.ProviderOrganization;
	
	import mx.collections.ArrayCollection;

	[Bindable()]
	public class Deal extends BaseEntity
	{
		public var customer:CustomerOrganization;
		public var invoices:ArrayCollection=new ArrayCollection();;
		public var dealDate:Date;
		public var dealStatus:ReferenceData;
		public var dealDescription:String;
		public var finalized:Boolean=true;
		public function get dealAmount():Number{
			var total:Number=0;
			for each(var inv:Invoice in invoices){
				total+= inv.invoiceAmount;
			}
			return total;
		}
		public var provider:ProviderOrganization;
		public var dealContacts:ArrayCollection;
		
		public function get isBillable():Boolean{
			return dealStatus.code!="Prospect";
		}
		
		
		public function Deal()
		{
		}
		public override function createNew():BaseEntity{
			return new Deal();
		}
		public function get name():String{
			return this.dealDescription;
		}
		//HierarchicalData Support.
		public function get children():*{
			return invoices;
		}
		public function get parent():*{
			return customer;
		}
		public function set parent(val:*):void{
			 customer=val as CustomerOrganization;
		}
	}
}