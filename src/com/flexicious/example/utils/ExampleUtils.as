package com.flexicious.example.utils
{
	import mx.formatters.CurrencyFormatter;
	
	public class ExampleUtils
	{
		public function ExampleUtils()
		{
			 
		}
		private static var _currencyFormatter:CurrencyFormatter;
		public static function get globalCurrencyFormatter():CurrencyFormatter{
			if(!_currencyFormatter){
				_currencyFormatter=new CurrencyFormatter();
			}
			return _currencyFormatter;
		}
	}
}