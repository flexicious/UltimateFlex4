package com.flexicious.example.utils
{
	import com.flexicious.nestedtreedatagrid.cells.FlexDataGridColumnGroupCell;

	public class MyColumnGroupCell extends FlexDataGridColumnGroupCell
	{
		public function MyColumnGroupCell()
		{
			
		}
		
		public override function getBackgroundColors():*{
			return [0xFFFFFF,0xFFDDEE]
		}
	}
}