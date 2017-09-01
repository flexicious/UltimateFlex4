package com.flexicious.example.model.classic
{
	import mx.collections.ArrayCollection;
	[RemoteClass(alias="com.companyname.projectname.pacakge.model.MyFilterResult")] //this could be a class on the server

  	/**
  	 * A class that that our server sends us back with results
  	 */
  	public class MyFilterResult 
	{
		public var records:ArrayCollection;
		public var totalRecords:Number;
	}
}