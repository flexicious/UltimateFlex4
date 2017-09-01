package com.flexicious.example.model.classic
{
	import com.flexicious.grids.filters.PrintExportFilter;
	[RemoteClass(alias="com.companyname.projectname.pacakge.model.MyPrintExportFilter")] //this could be a class on the server

  	/**
  	 * Stores user selection for records to print or to export. Only applicable
	 * when the filterPageSortMode of the grid is set to server,
	 * and the user requests to print all pages or specific pages
	 * of data that are not currently loaded.
  	 */
  	public class MyPrintExportFilter extends MyFilter 
	{
		public function MyPrintExportFilter(filter:PrintExportFilter){
			if(filter!=null){
				super(filter);
				this.printExportOptions=new MyPrintExportOptions(filter.printExportOptions);
			}
		}
		
		public var printExportOptions:MyPrintExportOptions;
	}
}