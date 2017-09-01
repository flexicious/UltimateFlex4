package com.flexicious.example.model.classic
{
	import com.flexicious.grids.events.PrintExportOptions;
	
	/**
	 * Stores user selection for records to print or to export. Only applicable
	 * when the filterPageSortMode of the grid is set to server,
	 * and the user requests to print all pages or specific pages
	 * of data that are not currently loaded. 
	 * @return 
	 */		
	[RemoteClass(alias="com.companyname.projectname.pacakge.model.MyPrintExportOptions")] //this could be a class on the server
	public class MyPrintExportOptions
	{
		public function MyPrintExportOptions( options:PrintExportOptions){
			this.printExportOption = options.printExportOption;
			this.pageFrom = options.pageFrom;
			this.pageTo = options.pageTo;
		}
				

		public var printExportOption:String=PrintExportOptions.PRINT_EXPORT_ALL_PAGES;
		
		/**
		 * In conjuntion with printOption/exportOption = PRINT_EXORT_SPECIFIED_PAGES
		 * deterimines which pages of a grid with paging enabled
		 * to print. 
		 */	
		 public var pageFrom:Number=-1;
		/**
		 * In conjuntion with printOption/exportOption = PRINT_EXORT_SPECIFIED_PAGES
		 * deterimines which pages of a grid with paging enabled
		 * to print. 
		 */	
		public var pageTo:Number=-1;

	}
}