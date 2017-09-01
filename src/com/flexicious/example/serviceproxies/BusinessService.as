package com.flexicious.example.serviceproxies
{
	import com.asfusion.mate.testing.MockRemoteObject;
	import com.flexicious.grids.filters.Filter;
	
	import mock.FlexiciousMockGenerator;

	/**
	 * This is a flex interface for a webservice or a remoting servicer. 
	 * @author Flexicious
	 */	
	public class BusinessService extends ServiceProxyBase
	{
		public function BusinessService()
		{
			var mockRo:MockRemoteObject=new MockRemoteObject();
			mockRo.mockGenerator = FlexiciousMockGenerator;
			mockRo.delay=0;
			mockRo.showBusyCursor=true;
			super(mockRo);
		}
		public function setDelay(sec:Number):void{
			(remoteObject as MockRemoteObject).delay=sec;
		}
		private static var instance:BusinessService;
		public static function getInstance():BusinessService
		{
			if (instance == null)
			{
				instance = new BusinessService();
			}
			return instance;
		}
		
		public function getDeepOrgList(resultHandler:Function, faultHandler:Function=null):void
		{
			callServiceMethod(remoteObject.getDeepOrgList(), resultHandler, faultHandler);
		}
		public function getFlatOrgList(resultHandler:Function, faultHandler:Function=null):void
		{
			callServiceMethod(remoteObject.getFlatOrgList(), resultHandler, faultHandler);
		}
		public function getDeepOrg(orgId:Number,resultHandler:Function, faultHandler:Function=null):void
		{
			callServiceMethod(remoteObject.getDeepOrg(orgId), resultHandler, faultHandler);
		}
		
		public function getPagedOrganizationList(filter:Filter,resultHandler:Function, faultHandler:Function=null):void
		{
			callServiceMethod(remoteObject.getPagedOrganizationList(filter), resultHandler, faultHandler);
		}
		
		public function getDealsForOrganization(orgId:Number,filter:Filter,resultHandler:Function, faultHandler:Function=null):void
		{
			callServiceMethod(remoteObject.getDealsForOrganization(orgId,filter), resultHandler, faultHandler);
		}
		public function getInvoicesForDeal(dealId:Number,filter:Filter,resultHandler:Function, faultHandler:Function=null):void
		{
			callServiceMethod(remoteObject.getInvoicesForDeal(dealId,filter), resultHandler, faultHandler);
		}
		public function getLineItemsForInvoice(invoiceId:Number,filter:Filter,resultHandler:Function, faultHandler:Function=null):void
		{
			callServiceMethod(remoteObject.getLineItemsForInvoice(invoiceId,filter), resultHandler, faultHandler);
		}
		
		public function getAllLineItems(resultHandler:Function, faultHandler:Function=null):void
		{
			callServiceMethod(remoteObject.getAllLineItems(), resultHandler, faultHandler);
		}
	}
}