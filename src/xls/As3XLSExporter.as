package xls
{
	import com.as3xls.xls.ExcelFile;
	import com.as3xls.xls.Sheet;
	import com.flexicious.export.ExportOptions;
	import com.flexicious.export.exporters.Exporter;
	import com.flexicious.grids.dependencies.IExtendedDataGrid;
	import com.flexicious.nestedtreedatagrid.FlexDataGridColumn;
	import com.flexicious.nestedtreedatagrid.export.ExtendedExportController;

	/**
	 * The default exporter in flexicious is a pure CSV exporter. 
	 * This property lets you hook in a native excel exporter using a libary
	 * like as3xls. Just like Alive PDF, as3xls is not embedded in to the 
	 * core flexicious library, instead it is distributed as a part of the sample.
	 * Just like for pdf, you hook up the AlivePdfPrinter, you use the nativeExcelExporter to 
	 * hookup an implementation of the flexicious expoter that interfaces with the as3xls library
	 * to provide native excel export 
	 */	
	public class As3XLSExporter extends Exporter
	{
		public function As3XLSExporter()
		{
			super();
		}
		
		/**
		 * Writes the header of the grid (columns) in csv format 
		 * @param grid
		 * @return 
		 * 
		 */		
		public override function writeHeader(grid:IExtendedDataGrid):String{
			buildHeader(grid);
			return "";
		}
		/**
		 * @private 
		 * @param grid
		 * @return 
		 * 
		 */		
		private function buildHeader(grid:IExtendedDataGrid):void{
			var colIndex:int=0;
			while(colIndex++<nestDepth)
				sheet.setCell(rowIndex, colIndex, "");
			for each(var col:Object in grid.exportableColumns){
				if(!isIncludedInExport(col))
					continue;
				sheet.setCell(rowIndex, colIndex - 1, Exporter.getColumnHeader(col,colIndex));
				colIndex++;
			}
			rowIndex++;
		}
		
		private var sheet:Sheet;
		
		override public function startDocument(grid:IExtendedDataGrid):void {
			rowIndex =0;
			if(!sheet) {
				sheet = new Sheet(); 
				var totalCount:int=ExtendedExportController.instance().getTotalRecords(this); 
				sheet.resize(totalCount+2, grid.getColumns().length); //plus 1 for header an footer
			}
		}
		
		override public function endDocument(grid:IExtendedDataGrid):void {
			//do nothing now
			
		}
		
		
		override public function uploadForEcho(body:*, exportOptions:ExportOptions):void {
			var xlsFile:ExcelFile = new ExcelFile();
			xlsFile.sheets.addItem(sheet);
			super.uploadForEcho(xlsFile.saveToByteArray(), this.exportOptions);
			sheet=null;
		}
		
		/**
		 * Writes an individual record in csv format 
		 * @param grid
		 * @param record
		 * @return 
		 * 
		 */
		
		private var rowIndex:Number = 0;
		 
		public override function writeRecord(grid:IExtendedDataGrid, record:Object):String{
			var colIndex:int=0;
			if(!reusePreviousLevelColumns){
				while(colIndex++<nestDepth){
					sheet.setCell(rowIndex, colIndex, "");
				}
			}
			
			for each(var col:FlexDataGridColumn in grid.exportableColumns){
				if(!isIncludedInExport(col))
					continue;
				
				var str:String = col.itemToLabel(record);
				sheet.setCell(rowIndex, colIndex-1, str);
				colIndex++;
			}
			rowIndex++;
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
				if(!reusePreviousLevelColumns){
					while(colIndex++<nestDepth){
						sheet.setCell(rowIndex, colIndex, "");
					}
				}
				for each(var col:FlexDataGridColumn in grid.exportableColumns){
					if(!isIncludedInExport(col))
						continue;
					var str:String = col.calculateFooterValue(dataProvider);
					sheet.setCell(rowIndex, colIndex + col.colIndex - 1, str);
				}
				rowIndex++;
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
			return "application/vnd.ms-excel";
		}
		/**
		 * Name of the exporter 
		 * @return 
		 * 
		 */		
		public override function get name():String{
			return "Excel";
		}
		/**
		 * Extension of the download file. 
		 * @return 
		 * 
		 */		
		public override function get extension():String{
			return "xls";	
		}
	}
}