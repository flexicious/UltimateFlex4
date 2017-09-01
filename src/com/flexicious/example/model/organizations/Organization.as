package com.flexicious.example.model.organizations
{
	import com.flexicious.example.model.BaseEntity;
	import com.flexicious.example.model.common.Address;
	import com.flexicious.example.model.persons.CommercialContact;
	import com.flexicious.example.model.transactions.Deal;
	
	import mock.FlexiciousMockGenerator;
	
	import mx.collections.ArrayCollection;

	[Bindable()]
	public class Organization extends BaseEntity
	{
		public function get orgIndex():Number {
			return FlexiciousMockGenerator.simpleList.getItemIndex(this);
		}
			
		public var headquarterAddress:Address;
		public var mailingAddress:Address;
		public var legalName:String;
		public var url:String;
		
		public var billingContact:CommercialContact;
		public var salesContact:CommercialContact;
		
		public var annualRevenue:Number;
		public var numEmployees:Number;
		public var earningsPerShare:Number;
		public var lastStockPrice:Number;
		public var chartUrl:String;
		
		public var deals:ArrayCollection=new ArrayCollection();
		public var isActive:Boolean=true;
		public function Organization()
		{
		}
		public var headQuartersSameAsMailing:Boolean;
		public function get relationshipAmount():Number{
			var total:Number=0;
			for each(var deal:Deal in deals){
				total+= deal.dealAmount;
			}
			return total;
		}
		public override function createNew():BaseEntity{
			return new Organization();
		}
		public function get name():String{
			return this.legalName;
		}
		//HierarchicalData Support.
		public function get children():*{
			return deals;
		}
		
	}
}