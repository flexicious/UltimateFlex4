package com.flexicious.example.model.classic
{
	import com.flexicious.grids.filters.CollectionManipulator;
	import com.flexicious.grids.filters.Filter;
	import com.flexicious.grids.filters.FilterSort;
	
	import mx.collections.ArrayCollection;
	/**
	 * This is the equivalent of a server API that provides
	 * methods to retrieve data.
	 */	
	public class EmployeeGenerator
	{

		public function getAllDepartments():ArrayCollection{
			return new ArrayCollection(Employee.allDepartments.source);
		}
		/**
		 * This is the equivalent of the Server Side implementation
		 * of data retrieval. Please note, we're passing the entire
		 * filter object, because its assumed that the ActionScript
		 * MyFilter Object is mapped to a corresponding MyFilter class
		 * on the server via the RemoteClass mechanism.
		 */		
		public function getEmployees(filter:Filter):Filter 
		{
			//dummy database call....
			var allEmployees:ArrayCollection = new ArrayCollection(Employee.employees.source);
			
			//code to create sql to filter, page and sort our resultset.... 
			//this could be LINQ, SQL, HIBNERNATE, JDBC, Stored Procs, whatever
			//below is just mock mechanism
			var collectionManipulator:CollectionManipulator=new CollectionManipulator();
			if(filter.arguments && filter.arguments.length>0)
				collectionManipulator.filterArrayCollection(allEmployees,filter.arguments,null);
			var totalRecords:int = allEmployees.length;
			if (filter.sorts.length > 0)
				collectionManipulator.sortArrayCollection(allEmployees, filter.sorts);
			if(filter.pageIndex>-1)
				collectionManipulator.pageArrayCollection(allEmployees,filter.pageIndex,filter.pageSize);
			
			allEmployees.refresh();
			
			var result:ArrayCollection = new ArrayCollection();
			for each(var o:Object in allEmployees)
				result.addItem(o);
			//this is needed on the client side to tell the pager how many
			//pages to draw
			filter.recordCount = totalRecords;
			//this is the actual results to display in the grid (Usually just the first page of data)...
			filter.records = result;
			return filter;
		}
	}
}