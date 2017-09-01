package com.flexicious.example.model.common
{
	import com.flexicious.example.model.BaseEntity;

	[Bindable()]
	public class ReferenceData extends BaseEntity
	{
		public var code:String;
		public var name:String;
		
		public function ReferenceData(id:Number,code:String,name:String=null)
		{
			this.code=code;
			this.id=id;
			if(!name)
				name=code;
			this.name=name;
		}
		public function cloneSpecial():ReferenceData{
			var ref:ReferenceData = new ReferenceData(id,code,name);
			return ref;
		}
		public override function createNew():BaseEntity{
			return  cloneSpecial();
		}
	}
}