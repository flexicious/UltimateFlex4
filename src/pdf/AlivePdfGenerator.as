package pdf
{
	import com.flexicious.nestedtreedatagrid.FlexDataGrid;
	import com.flexicious.nestedtreedatagrid.utils.ExtendedUIUtils;
	import com.flexicious.print.PrintOptions;
	import com.flexicious.print.printareas.PageSize;
	import com.flexicious.utils.UIUtils;
	
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.controls.Image;
	import mx.events.CloseEvent;
	
	import org.alivepdf.layout.Size;
	import org.alivepdf.layout.Unit;
	import org.alivepdf.pages.Page;
	import org.alivepdf.pdf.PDF;
	import org.alivepdf.saving.Method;

	public class AlivePdfGenerator
	{
		public function AlivePdfGenerator()
		{
		}
		
		public function generate(grid:FlexDataGrid,printOptions:PrintOptions,confirmed:Boolean=false):void{
			if(!printOptions.asynch || confirmed){
			}else{
				UIUtils.showConfirm(printOptions.saveFileMessage,
					function(comp:Object,evt:CloseEvent):void{
						if(evt.detail==Alert.YES)
						generate(grid,printOptions,true)
					}
					,null,"File Download");	
				return;
			}

			var isLandscapse:Boolean=printOptions.pageSize.isLandscape;
			var pdfObject:PDF = new PDF(printOptions.pageSize.isLandscape?PageSize.PAGE_LAYOUT_LANDSCAPE:
				PageSize.PAGE_LAYOUT_POTRAIT,Unit.MM,Size.getSize(printOptions.pageSize.name));
			
			for each(var displayObject:Image in printOptions.printedPages)
			{
				//now that we have the printed images in memory,
				//send them to alivepdf.
				UIUtils.addChild(grid.parent,displayObject);//need to add it to the stage so it renders
				var page:Page=pdfObject.addPage();
				
				var alivePdfSize:Size = Size.getSize(printOptions.pageSize.name);                    
				pdfObject.addImage(displayObject,null,0,0,alivePdfSize.mmSize[isLandscapse?1:0]-(20),
					alivePdfSize.mmSize[isLandscapse?0:1]-(20),0,1,false); //account for pdf page padding of 20 px
			}
			//small script to echo back the bytes of the pdf, you may use the flexicious Echo,
			//but it is recommended that you implement this inside your own firewall for performance.
			//pdfObject.save( Method.REMOTE, "http://www.flexicious.com/Home/EchoPdf", "Report.pdf" );
			
			//For local persistence of PDF - uncomment this section and comment the line above.
			//Ensure that you are targeting Flash Player 10
			//You will also need to pull in the appropriate imports
			var fileReference:FileReference = new FileReference();
			var bytes:ByteArray = pdfObject.save(Method.LOCAL);
			fileReference.save(bytes, "file.pdf");
			
			
			for each( displayObject in printOptions.printedPages)
				UIUtils.removeChild(grid.parent,displayObject);//remove it as soon as possible
			printOptions.printedPages.removeAll();//now that we're done, remove it from memory.

		}
	}
}