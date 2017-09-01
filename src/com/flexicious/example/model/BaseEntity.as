package com.flexicious.example.model
{
	import com.flexicious.example.model.persons.SystemUser;
	import com.flexicious.nestedtreedatagrid.utils.ExtendedUIUtils;
	import com.flexicious.utils.UIUtils;
	
	import flash.system.System;
	
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectUtil;

	[Bindable()]
	
	public class BaseEntity
	{
		public var addedBy:SystemUser;
		public var addedDate:Date;
		public var updatedBy:SystemUser;
		public var updatedDate:Date;
		public var id:Number;
		
		public function BaseEntity()
		{
		}
		public function clone(deepClone:Boolean=true):BaseEntity{
			var entity:BaseEntity=createNew();
			entity.addedBy=addedBy;
			for each(var levelProp:String in ObjectUtil.getClassInfo(this,null,{"includeReadOnly":false}).properties) //we're cloning columns here so as to not upset the orignial grid
			{
				if(UIUtils.isPrimitive(this[levelProp])){
					entity[levelProp]=this[levelProp];
				}
				else if(this[levelProp] is BaseEntity){
					entity[levelProp]=(this[levelProp] as BaseEntity);
				}
				else if(deepClone&&this[levelProp] is ArrayCollection)
				{
					entity[levelProp]=new ArrayCollection();
					for each(var item:BaseEntity in this[levelProp])
					{
						entity[levelProp].addItem(item.clone(deepClone));
					}	
				}
			}
			return entity;
		}
		public function createNew():BaseEntity{
			throw new Error("Psuedo abstract method, need to override");
		}
	}
}