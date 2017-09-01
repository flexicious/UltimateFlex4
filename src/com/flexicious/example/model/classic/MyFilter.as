package com.flexicious.example.model.classic
{
	import com.flexicious.grids.filters.Filter;
	import com.flexicious.grids.filters.FilterExpression;
	import com.flexicious.grids.filters.FilterSort;
	
	import mx.collections.ArrayCollection;
	[RemoteClass(alias="com.companyname.projectname.pacakge.model.MyFilter")] //this could be a class on the server

  	/**
  	 * A class that can be sent to the server with all the filter criteria, 
  	 * as opposed to sending it as individual parameters 
  	 */
  	public class MyFilter 
	{

		/**
		* Initialize a remotable filter from our the Flexicious filter object.
		*/		
		public function MyFilter(filter:Filter){
			if(filter!=null){
				this.pageSize=filter.pageSize;
				this.pageIndex = filter.pageIndex;
				this.pageCount = filter.pageCount;
				this.recordCount=filter.recordCount;
				for each(var arg:FilterExpression in filter.arguments){
					this.arguments.addItem(new MyFilterExpression(arg));
				}
				for each(var sort:FilterSort in filter.sorts){
					this.sorts.addItem(new MyFilterSort(sort));
				}
			}
		}
		
        public var pageSize:int=20;
		public var pageIndex:int=-1;
		public var pageCount:int;
		public var recordCount:int;
		public var recordType:String;
		
		public var records:Object;
		
		public var arguments:ArrayCollection=new ArrayCollection();
		public var sorts:ArrayCollection=new ArrayCollection();
		
		
	}
}