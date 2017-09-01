package com.flexicious.example.view.functional
{
	import com.flexicious.grids.filters.Filter;
	import com.flexicious.nestedtreedatagrid.FlexDataGrid;
	import com.flexicious.nestedtreedatagrid.FlexDataGridCheckBoxColumn;
	import com.flexicious.nestedtreedatagrid.FlexDataGridColumn;
	import com.flexicious.nestedtreedatagrid.FlexDataGridColumnGroup;
	import com.flexicious.nestedtreedatagrid.FlexDataGridColumnLevel;
	import com.flexicious.nestedtreedatagrid.cells.CellUtils;
	import com.flexicious.nestedtreedatagrid.valueobjects.ToolbarAction;
	import com.flexicious.utils.*;
	
	import flash.utils.getDefinitionByName;
	
	import mx.core.ClassFactory;

	public class MyDataGrid extends FlexDataGrid
	{
		public function MyDataGrid()
		{
			
		}
		
		public function buildFromXml(strXml:String):void{
			parse(strXml,this);
		}
		
		public function parse(strXml:String,grid:FlexDataGrid):void{
			
			strXml=strXml.replace(new RegExp("\"","g"),"'");
			grid.columnLevel = new FlexDataGridColumnLevel();
			//try
			{
				var xml:XML = new XML(strXml);
			}
			/*catch(e:Error)
			{
			UIUtils.showError("Error parsing XML" + e.message);
			return;
			}*/
			for each(var gridItem:* in xml){
				for each(var attr:* in gridItem.attributes()){
					
					applyAttribute(grid,attr,gridItem);
				}
				for each(var gridChildNode:* in gridItem.children()){
					if(gridChildNode.name().localName=='level'){
						//try{	
						extractLevel(gridChildNode,grid.columnLevel);
						/*}
						catch(e:Error)
						{
						UIUtils.showError("Error parsing level: "+ e.message);
						return;
						}*/
					}
					else if(gridChildNode.name().localName=='filters'){
						//try
						{
							extractFilters(gridChildNode,grid);
						}
						/*catch(e:Error)
						{
						UIUtils.showError("Error parsing filters: "+ e.message);
						return;
						}*/
					}
					else if(gridChildNode.name().localName=='actions'){
						//try{
						extractActions(gridChildNode,grid);
						/*}
						catch(e:Error)
						{
						UIUtils.showError("Error parsing filters: "+ e.message);
						return;
						}*/
					}
				}
			}
			grid.columnLevel.initializeLevel(grid);
			grid.rebuild();
		}
		
		private function applyAttribute(target:Object, attr:*,node:*):void
		{
			
			
			//try
			{
				var attrName:String=attr.name().localName;
				var val:* = node["@"+attrName]
				var valStr:String = new String(val.toString());
				//in here, values could be class factories or functions, which 
				//need additional processing before we can apply them.
				if(val=="false") 
				{
					val=false;
				}
				if(attrName=="height" || attrName=="width") 
				{
					if(valStr.indexOf("%")>0){
						attrName = "percent" + CellUtils.doCap(attrName);
						val=parseInt(valStr.substring(0,valStr.length-1));
					}
				}
				else if(attrName=="itemEditor" || attrName=="itemRenderer" ){
					val=new ClassFactory( getDefinitionByName(val) as Class)
				}else if (attrName.indexOf("Function")>0){
					//parse out the class, get the class def, and then use the 
					//function property on the class to get the function
					var qualifiedName:Array= val.split(".");
					var funcName:String=qualifiedName.pop();
					var cls:Class=getDefinitionByName(qualifiedName.join(".")) as Class;
					val=cls[funcName];
				}else if (attrName.toLowerCase().indexOf("iconurl")>=0 ){//for iconUrl and disable icon url.
					//val=IconRepository[val.toString()];
					if(!val)val=valStr;
				}
				if(target.hasOwnProperty(attrName))
					target[attrName] = val;
				else if(target.setStyle) //this means there was no attribute that matched the property, so that means it is a style
					target.setStyle(attrName,valStr)
				trace(attr.name().localName+":"+node["@"+attr.name().localName])
			}
			/*catch(e:Error)
			{
			UIUtils.showError("Error applying grid attribute: "+ attrName +":"+ e.message);
			return;
			}*/
		}
		
		private function extractActions(actionsNode:*, grid:FlexDataGrid):void
		{
			var actions:Array=[];
			for each(var actionNode:* in actionsNode.children()){
				actions.push(
					grid.hasOwnProperty("toolbarAction" + CellUtils.doCap(actionNode.@code))?
					extractAction(actionNode, grid["toolbarAction" + CellUtils.doCap(actionNode.@code)]):
					extractAction(actionNode)
				);
				
			}	
			grid.setToolbarActions(actions);
		}
		private function extractAction(actionNode:*,action:ToolbarAction=null ):ToolbarAction
		{
			if(!action)
				action = new ToolbarAction(actionNode.@name);
			for each(var actionAttr:* in actionNode.attributes()){
				applyAttribute(action,actionAttr,actionNode);
			}
			return action;
		}
		private function extractFilters(filtersNode:*, grid:FlexDataGrid):void
		{
			var filters:Array=[];
			for each(var filterNode:* in filtersNode.children()){
				if(filterNode.@type=="date"){
					filters.push(UIUtils.createDateFilter(
						filterNode.@description,filterNode.@fld,
						filterNode.@dateRange,
						filterNode.@dateRange==DateRange.DATE_RANGE_CUSTOM?new Date(filterNode.@start):null,
						filterNode.@dateRange==DateRange.DATE_RANGE_CUSTOM?new Date(filterNode.@end):null
					));
				}else if (filterNode.@type=="list"){
					filters.push(UIUtils.createListFilter(
						filterNode.@description,filterNode.@fld,
						filterNode.@values.split(",")
					));
				}else{
					var filter:Filter = new Filter();
					filter.filterDescrption = filterNode.@description;
					filters.push(filter);
				}
			}	
			grid.setPredefinedFilters(filters);
		}
		
		private function extractLevel(levelNode:*, lvl:FlexDataGridColumnLevel):void
		{
			for each(var levelAttr:* in levelNode.attributes()){
				applyAttribute(lvl,levelAttr,levelNode);
			}
			for each(var levelNodeChild:* in levelNode.children()){
				if(levelNodeChild.name().localName=='nextLevel'){
					lvl.nextLevel = new FlexDataGridColumnLevel();
					extractLevel(levelNodeChild.children()[0],lvl.nextLevel);
				}
				else if(levelNodeChild.name().localName=='columns'){
					var cols:Array=[];
					var hasColumnGroups:Boolean=false;
					for each(var colNode:* in levelNodeChild.children()){
						if(colNode.name().localName=="columnGroup"){
							hasColumnGroups=true;
							cols.push(extractColGroup(colNode));
						}
						else
							cols.push(extractCol(colNode));
					}
					if(hasColumnGroups)
						lvl.groupedColumns=cols;
					else
						lvl.columns=cols;
				}
			}
		}
		private function extractColGroup(cgNode:*):FlexDataGridColumnGroup
		{
			
			var cg:FlexDataGridColumnGroup = new FlexDataGridColumnGroup();
			for each(var colAttr:* in cgNode.attributes()){
				applyAttribute(cg,colAttr,cgNode);
			}
			var cols:Array=[];
			var hasColumnGroups:Boolean=false;
			for each(var colNode:* in cgNode.children()[0].children()){
				if(colNode.name().localName=="columnGroup"){
					hasColumnGroups=true;
					cols.push(extractColGroup(colNode));
				}
				else
					cols.push(extractCol(colNode));
			}
			if(hasColumnGroups)
				cg.columnGroups=cols;
			else
				cg.columns=cols;
			return cg;
		}
		private function extractCol(colNode:*):FlexDataGridColumn
		{
			var col:FlexDataGridColumn = new FlexDataGridColumn();
			if(colNode.@type=="checkbox")
				col=new FlexDataGridCheckBoxColumn();
			
			for each(var colAttr:* in colNode.attributes()){
				if(colAttr.name().localName!="type")
					applyAttribute(col,colAttr,colNode);
			}
			return col;
		}
		
	}
}