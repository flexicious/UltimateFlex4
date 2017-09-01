package xls
{
	import com.flexicious.export.ExportOptions;
	import com.flexicious.export.exporters.Exporter;
	import com.flexicious.grids.dependencies.IExtendedDataGrid;
	import com.flexicious.nestedtreedatagrid.FlexDataGridColumn;

	/**
	 * Exports the grid in CSV format 
	 */	
	public class Excel2007Exporter extends Exporter
	{
		public function Excel2007Exporter()
		{
		}
		/**
		 * Writes the header of the grid (columns) in csv format 
		 * @param grid
		 * @return 
		 * 
		 */		
		
		private var strWorkbook:String;
		
		private var strTable:String;
		
		override public function startDocument(grid:IExtendedDataGrid):void {
			
			//Full list of possible values here: http://msdn.microsoft.com/en-us/library/office/aa140062%28v=office.10%29.aspx#odc_xlsmlinss_excelxml , this is a mircosoft standard.
			strTable = "";
			strWorkbook = "<?xml version='1.0' encoding='ISO-8859-1'?><?mso-application progid='Excel.Sheet'?>" +
				"<Workbook xmlns='urn:schemas-microsoft-com:office:spreadsheet' " +
				"xmlns:ss='urn:schemas-microsoft-com:office:spreadsheet' xmlns:x='urn:schemas-microsoft-com:office:excel' " +
				"xmlns:o='urn:schemas-microsoft-com:office:office' xmlns:html='http://www.w3.org/TR/REC-html40'>" +
				"<Styles>" +
				"<Style ss:Name='Normal' ss:ID='Default'>" +
				"<Alignment ss:Vertical='Bottom' />" +
				"<Borders />" +
				"<Font />" +
				"<Interior />" +
				"<NumberFormat />" +
				"<Protection />" +
				"</Style>" +
				"<Style ss:ID='s68'>" +
				"<Borders>" +
				"<Border ss:Position='Bottom' ss:LineStyle='Continuous' ss:Weight='2'/>" +
				"<Border ss:Position='Top' ss:LineStyle='Continuous' ss:Weight='2'/>" +
				"</Borders>" +
				"<Interior ss:Color='#4F81BD' ss:Pattern='Solid'/>" +
				"</Style>" +
				"</Styles>" +
				"<Worksheet ss:Name='Sheet1'>" +
				"<Table>";
		}
		
		override public function endDocument(grid:IExtendedDataGrid):void {
			//do nothing now
			
		}
		
		public override function writeHeader(grid:IExtendedDataGrid):String{
			buildHeader(grid);
			return  "";
		}
		
		/**
		 * @private 
		 * @param grid
		 * @return 
		 * 
		 */
		
		private function buildHeader(grid:IExtendedDataGrid):void{
			var colIndex:int=0;
			
			strTable += "<Row ss:StyleID='s68'>";
			while(colIndex++<nestDepth)
				strTable += "<Cell><Data ss:Type='String'></Data></Cell>";
			for each(var col:Object in grid.exportableColumns){
				if(!isIncludedInExport(col))
					continue;
				
				strTable += "<Cell><Data ss:Type='String'>" + Exporter.getColumnHeader(col,colIndex) + "</Data></Cell>";
				colIndex++;
			}
			strTable += "</Row>";
		}
		
		override public function uploadForEcho(body:*, exportOptions:ExportOptions):void {
			strWorkbook += strTable + "</Table></Worksheet></Workbook>";
			super.uploadForEcho(strWorkbook, this.exportOptions);
		}
		
		/**
		 * Writes an individual record in csv format 
		 * @param grid
		 * @param record
		 * @return 
		 * 
		 */		
		public override function writeRecord(grid:IExtendedDataGrid, record:Object):String{
			var colIndex:int=0;
			strTable += "<Row>";
			if(!reusePreviousLevelColumns){
				while(colIndex++<nestDepth)
					strTable += "<Cell><Data ss:Type='String'></Data></Cell>";
			}
			for each(var col:FlexDataGridColumn in grid.exportableColumns){
				if(!isIncludedInExport(col))
					continue;
				var str:String = col.itemToLabel(record);
				strTable += "<Cell><Data ss:Type='String'>" + str + "</Data></Cell>";
			}
			strTable += "</Row>";
			return "";
		}
		/**
		 * Writes the footer in CSV format 
		 * @param grid
		 * @return 
		 * 
		 */		
		public override function writeFooter(grid:IExtendedDataGrid, dataProvider:Object/*This was added in 3.1 remove it for prior to 3.1 library*/):String{
			if(exportOptions.includeFooters){
				var colIndex:int=0;
				strTable += "<Row ss:StyleID='s68'>";
				if(!reusePreviousLevelColumns){
					while(colIndex++<nestDepth)
						strTable += "<Cell><Data ss:Type='String'></Data></Cell>";
				}
				for each(var col:FlexDataGridColumn in grid.exportableColumns){
					if(!isIncludedInExport(col))
						continue;
					var str:String = col.calculateFooterValue(dataProvider);
					strTable += "<Cell><Data ss:Type='String'>" + str + "</Data></Cell>";
				}
				strTable += "</Row>";
				
			}
			return "";
		}
		/**
		 * Returns the content type so MS Excel launches
		 * when the exporter is run. 
		 * @return 
		 * 
		 */		
		public override function get contentType():String{
			return "application/vnd.ms-excel"
		}
		/**
		 * Name of the exporter 
		 * @return 
		 * 
		 */		
		public override function get name():String{
			return "Excel"
		}
		/**
		 * Extension of the download file. 
		 * @return 
		 * 
		 */		
		public override function get extension():String{
			return "xml";	
		}
		
	}
}