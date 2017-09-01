package com.flexicious.example.serviceproxies
{
	import mx.controls.Alert;
	import mx.rpc.AsyncResponder;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.remoting.RemoteObject;
	
	/**
	 * This is a base class that wraps a Webservice/RemoteObject object. Since the concrete classes are 
	 * singletons, we always have a single instance of the webservice wsdl downloaded for efficiency. 
	 * @author Flexicious
	 */	
	public class ServiceProxyBase 
	{
		protected var remoteObject:RemoteObject;
		public function ServiceProxyBase(ro:RemoteObject)
		{
			this.remoteObject=ro;
		}
		/*protected var webSerivce:WebService;
		
		public function ServiceProxyBase(webSerivce:mx.rpc.soap.WebService)
		{
			this.webSerivce=webSerivce;
		}*/
		protected function callServiceMethod(token:AsyncToken, resultFunction:Function, faultFunction:Function=null):void
		{
			if(faultFunction==null)faultFunction=defaultFaultHandler;
			token.addResponder(new AsyncResponder(resultFunction, faultFunction,token));
		}
		
		
		public function defaultFaultHandler(error:FaultEvent, token:Object = null):void{
			Alert.show("Error occured while calling service method" + error.fault.faultString);
		}
	}
}