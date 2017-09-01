package com.flexicious.example.model.classic
{
	public class Address
	{
		public var street1:String;
		public var street2:String;
		public var city:String;
		public var state:String;
		public var country:String;

		public var apartmentNumber:Number;
		public var validFrom:Date;
		public var validTo:Date;
		
		public function Address()
		{
			
		}
		public function get concatenatedAddress():String{
			return street1+", "+street2 + ", "+ city + ", " + state + ", "+ country; 
		}

	}
}