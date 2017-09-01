package com.flexicious.example.model.common
{
	import com.flexicious.example.model.BaseEntity;
	
	import mx.collections.ArrayCollection;

	[Bindable()]
	public class PagedResult
	{
		public function PagedResult(collection:ArrayCollection,totalRecords:Number=0,summaryData:Object=null,deepClone:Boolean=true)
		{
			this.collection=new ArrayCollection();
			for each(var entity:BaseEntity in collection){
				this.collection.addItem(entity.clone(deepClone));	
			}
			
			this.totalRecords=totalRecords;
			this.summaryData=summaryData;
		}
		
		public var collection:ArrayCollection;
		public var totalRecords:Number;
		public var summaryData:Object;
	}
}