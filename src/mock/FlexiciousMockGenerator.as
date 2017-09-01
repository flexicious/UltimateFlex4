package mock
{
	
	import com.flexicious.example.model.BaseEntity;
	import com.flexicious.example.model.billing.Invoice;
	import com.flexicious.example.model.billing.LineItem;
	import com.flexicious.example.model.common.Address;
	import com.flexicious.example.model.common.PagedResult;
	import com.flexicious.example.model.common.ReferenceData;
	import com.flexicious.example.model.common.SystemConstants;
	import com.flexicious.example.model.organizations.CustomerOrganization;
	import com.flexicious.example.model.organizations.Organization;
	import com.flexicious.example.model.persons.CommercialContact;
	import com.flexicious.example.model.persons.SystemUser;
	import com.flexicious.example.model.transactions.Deal;
	import com.flexicious.grids.events.PrintExportOptions;
	import com.flexicious.grids.filters.Filter;
	import com.flexicious.grids.filters.PrintExportFilter;
	import com.flexicious.nestedtreedatagrid.utils.ExtendedUIUtils;
	import com.flexicious.utils.DateUtils;
	import com.flexicious.utils.UIUtils;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.system.System;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	
	import org.alivepdf.pages.Page;

	[Event(name="progress")]
	public class FlexiciousMockGenerator extends EventDispatcher
	{
		public const  DEALS_PER_ORG:int=1;
		public const  INVOICES_PER_DEAL:int=5;
		public const  LINEITEMS_PER_INVOICE:int=5;
		
		private static var _instance:FlexiciousMockGenerator = new FlexiciousMockGenerator();
		public static function instance():FlexiciousMockGenerator
		{
			return _instance;
		} 
		public function FlexiciousMockGenerator()
		{
			
		}
		[Bindable()]
		public static var lineItems:ArrayCollection=new ArrayCollection();
		[Bindable()]
		public static var simpleList:ArrayCollection;
		[Bindable()]
		public static var deepList:ArrayCollection;
		[Bindable()]
		public var progress:Number;
		
		public function getAllLineItems():ArrayCollection{
			if(lineItems.length==0){
				getDeepOrgList()
			}
			return lineItems;
		}
		
		public function getFlatOrgList():ArrayCollection{
			if(!simpleList){
				simpleList=getOrgList(false);
			}
			return new ArrayCollection(simpleList.source);
		}
		public function getDeepOrgList():ArrayCollection{
			if(!deepList){
				deepList=getOrgList(true);
			}
			return deepList;
		}
		private static var _index:int=0;
		public function init():void{
			deepList=new ArrayCollection();
			index=0;
			var timer:Timer=new Timer(100);
			timer.addEventListener(TimerEvent.TIMER,onTimer);
			timer.start();
			
		}
		private var _pageIndex:int=0;
		private var _pageSize:int=30;
		private function onTimer(evt:TimerEvent):void
		{
			for(var i:int=_pageIndex*_pageSize;i<Math.min(companyNames.length,(_pageIndex+1)*_pageSize);i++){
				var nm:String =companyNames[i];
				deepList.addItem(createOrganization(nm,true));
			}
			if((_pageIndex*_pageSize)>=companyNames.length){
				(evt.target as Timer).stop();
				progress=100;
				dispatchEvent(new Event("progress"));
				
				return;
			}else{
				progress=(_pageIndex*_pageSize)*100/companyNames.length;
				_pageIndex++;
				dispatchEvent(new Event("progress"));
				(evt.target as Timer).start();
			}
		}
		
		
		public function getOrgList(deep:Boolean):ArrayCollection {
			var orgs:ArrayCollection=new ArrayCollection();
			for(var i:int=0;i<companyNames.length;i++){
				var nm:String =companyNames[i];
				orgs.addItem(createOrganization(nm,deep));
			}
			return orgs;
		}
		public var index:int=0;
		public function getDeepOrg(orgId:Number):Organization{
			for each(var org:Organization in deepList){
				if(org.id==orgId){
					return org.clone() as Organization;
				}
			}
			throw new Error("Invalid org ID passed in : " + orgId);
		}
		//this method takes a filter object, and returns the set of records that match the filter object.
		//some special things about this method - it is a multipurpose method. Meaning,
		//that it is called by the grid when it is filtered, paged or sorted.
		//it is also called by print and export controllers when user requests all pages or selected pages
		//this is required because the in filterPageSortMode=server, the grid does not load all the data, only the current record
		//So if the user requests data that does not exist on the client, it triggers the PrintExportDataRequest event, that 
		//we hook into, (In FullyLazyLoadedGrid) and call this method with the filter Parameter.
		public function getPagedOrganizationList(filter:Filter):PagedResult
		{
			if(!simpleList){
				simpleList=getOrgList(false);
			}
			if(filter is PrintExportFilter){
				var pef:PrintExportFilter = filter as PrintExportFilter;
				if(pef.printExportOptions.printExportOption == PrintExportOptions.PRINT_EXPORT_ALL_PAGES){
					filter.pageIndex=-1;//so we return all records.
					return new PagedResult(new ArrayCollection(ExtendedUIUtils.filterPageSort(deepList.source,filter)),filter.recordCount);
				}else{
					return new PagedResult(new ArrayCollection(ExtendedUIUtils.filterPageSort(deepList.source,filter,[pef.printExportOptions.pageFrom,pef.printExportOptions.pageTo])),filter.recordCount);
				}
			}
			else
				return new PagedResult(new ArrayCollection(ExtendedUIUtils.filterPageSort(simpleList.source,filter)),filter.recordCount);
		}
		public function getDealsForOrganization(orgId:Number,filter:Filter):PagedResult
		{
			for each(var org:Organization in getDeepOrgList()){
				if(org.id==orgId){
					var arr:ArrayCollection=org.deals;
					return new PagedResult(filter.pageIndex>=0?new ArrayCollection
						(ExtendedUIUtils.filterPageSort(arr.source,filter)):arr,arr.length,
						{"total":UIUtils.sum(org.deals,"dealAmount"),"count":arr.length},false);
				}
			}
			return new PagedResult(new ArrayCollection(),0);
		}
		public function getInvoicesForDeal(dealId:Number,filter:Filter):PagedResult
		{
			for each(var org:Organization in getDeepOrgList()){
				for each(var deal:Deal in org.deals){
					if(deal.id==dealId){
						var arr:ArrayCollection=deal.invoices;
						return new PagedResult(filter.pageIndex>=0?new ArrayCollection
							(ExtendedUIUtils.filterPageSort(arr.source,filter)):arr,arr.length,
							{"total":UIUtils.sum(arr,"invoiceAmount"),"count":arr.length},false);
					}
				}
			}
			return new PagedResult(new ArrayCollection(),0);
		}
		public function getLineItemsForInvoice(invoiceId:Number,filter:Filter):PagedResult
		{
			for each(var org:Organization in getDeepOrgList()){
				for each(var deal:Deal in org.deals){
					for each(var invoice:Invoice in deal.invoices){
						if(invoice.id==invoiceId){
							var arr:ArrayCollection=invoice.lineItems;
							return new PagedResult(filter.pageIndex>=0?new ArrayCollection
								(ExtendedUIUtils.filterPageSort(arr.source,filter)):arr,arr.length,
								{"total":UIUtils.sum(arr,"lineItemAmount"),"count":org.deals.length},false);
						}
					}
				}
			}
			return new PagedResult(new ArrayCollection(),0);
		}
		public function createOrganization(legalName:String,deep:Boolean):Organization{
			if(deep)_index++;
			var org:CustomerOrganization = new CustomerOrganization();
			org.id= 20800 + companyNames.indexOf(legalName);
			org.legalName=legalName;
			org.headquarterAddress = createAddress();
			org.mailingAddress = createAddress();
			org.billingContact=createContact();
			org.salesContact=createContact();
			org.annualRevenue = getRandom(1000,60000)
			org.numEmployees = getRandom(1000,60000)
			org.earningsPerShare = getRandom(1,6) + (getRandom(1,99)/100);
			org.lastStockPrice = getRandom(10,30) + (getRandom(1,99)/100);
			org.url = "http://www.google.com/search?q="+legalName+"";
			org.chartUrl="http://www.flexicious.com/resources/images/chart" + getRandom(1,7)+".png"
			if(deep){
				for(var dealIdx:int=0;dealIdx<DEALS_PER_ORG;dealIdx++){
					org.deals.addItem(createDeal(dealIdx,org,deep));	
				}
			}
			return org;
		}
		
		public function createDeal(idx:int,org:CustomerOrganization,deep:Boolean):Deal
		{
			var deal:Deal = new Deal();
			deal.customer=org;
			deal.dealDate = getRandomDate();
			deal.dealDescription = "Project # "+(org.deals.length+1)+" - " +org.legalName + " - "  + (deal.dealDate.month+1) + "/" +deal.dealDate.fullYear;
			deal.dealStatus= getRandomReferenceData(SystemConstants.dealStatuses).cloneSpecial();
			deal.id = (org.id*10)+(idx);
			if(deep){
				
				for(var invoiceIDx:int=0;invoiceIDx<INVOICES_PER_DEAL;invoiceIDx++){
					deal.invoices.addItem(createInvoice(invoiceIDx,deal,deep));	
				}
			}
			setGlobals(deal);
			return deal;
		}
		public function createInvoice(idx:int,deal:Deal,deep:Boolean):Invoice{
			var invoice:Invoice = new Invoice();
			invoice.deal=deal;
			invoice.invoiceDate = getRandomDate();
			invoice.id = (deal.id*10)+idx;
			invoice.invoiceStatus= getRandomReferenceData(SystemConstants.invoiceStatuses).cloneSpecial();
			invoice.dueDate = DateUtils.dateAdd(DateUtils.DAY_OF_MONTH,30,invoice.invoiceDate);
			invoice.hasPdf = getRandom(1,2)==1;
			if(deep){
				for(var lineItemIDx:int=0;lineItemIDx<LINEITEMS_PER_INVOICE;lineItemIDx++){
					var lineItem:LineItem = createInvoiceLineItem(lineItemIDx,invoice,deep);
					invoice.lineItems.addItem(lineItem);	
				}
			}
			setGlobals(invoice);
			return invoice;
		}
		public function createInvoiceLineItem(lineItemIdx:int,invoice:Invoice,deep:Boolean):LineItem{
			var lineItem:LineItem = new LineItem();
			lineItem.id=(invoice.id*10)+lineItemIdx;
			lineItem.invoice=invoice;
			lineItem.lineItemAmount=getRandom(10000,50000);
			lineItem.lineItemDescription = "Professional Services - " + getRandomReferenceData(SystemConstants.billableConsultants).cloneSpecial().name;
			lineItem.units = lineItem.lineItemAmount/100;
			setGlobals(lineItem);
			lineItems.addItem(lineItem);
			return lineItem;
		}
		public static function getRandomReferenceData(arr:Array):ReferenceData{
			return arr[getRandom(0,arr.length-1)];
		}
		public static function createContact():CommercialContact
		{
			var commercialContact:CommercialContact=new CommercialContact();
			commercialContact.firstName=firstNames[getRandom(0,firstNames.length-1)];
			commercialContact.lastName=lastNames[getRandom(0,lastNames.length-1)];
			commercialContact.homeAddress=createAddress();
			commercialContact.telephone=generatePhone();
			setGlobals(commercialContact);
			return commercialContact;
		}
		public static function setGlobals(entity:BaseEntity):void{
			entity.addedBy=getSystemUser();
			entity.addedDate = getRandomDate();
			entity.updatedDate=entity.addedDate;
			entity.updatedBy=getSystemUser();
				
		}
		public static function getRandomDate():Date{
			return new Date(getRandom(2005,2010),getRandom(0,11),getRandom(1,28));
		}
		public static function generatePhone():String{
			return areaCodes[getRandom(0,3)] + "-" + 
				getRandom(100,999).toString()+ "-" + getRandom(1000,9999).toString();

		}
		private static var sysAdmin:SystemUser;
		public static function getSystemUser():SystemUser{
			if(sysAdmin)return sysAdmin;
			
			var user:SystemUser=new SystemUser();
			user.addedBy=user;
			user.addedDate= new Date(2010,1,1);
			user.updatedBy = user;
			user.updatedDate = new Date(2010,1,1);
			user.id=1;
			user.firstName=firstNames[getRandom(0,firstNames.length-1)];
			user.lastName=lastNames[getRandom(0,lastNames.length-1)];
			user.loginNm ="system_admin";
			sysAdmin=user;
			return user;
		}
		
		public static function createAddress():Address{
			var address:Address =new Address();
			address.line1=getRandom(100,999).toString() + " " +streetNames[getRandom(0,streetNames.length-1)]+ " " + streetTypes[getRandom(0,streetTypes.length-1)];
			address.line2="Suite #" + getRandom(1,1000);
			address.city=SystemConstants.cities[getRandom(0,SystemConstants.cities.length-1)];
			address.state=SystemConstants.states[getRandom(0,SystemConstants.states.length-1)];
			address.country = SystemConstants.usCountry;
			return address;
		}
		public static function getRandom(minNum:Number,maxNum:Number):Number
		{
			return Math.ceil(Math.random() * (maxNum - minNum + 1)) + (minNum - 1);
		}


		
		private static const areaCodes:Array = ['201','732','212','646','800','866'] ;
		private static const streetTypes:Array = ['Ave','Blvd','Rd','St','Lane'];
		private static const streetNames:Array = ['Park','West','Newark','King','Gardner'];
		

		private static var companyNames:Array=['3M Co',
		'Abbott Laboratories',
		'Adobe Systems',
		'Advanced Micro Dev',
		'Aetna Inc',
		'Affiliated Computer Svcs',
		'AFLAC Inc',
		'Air Products & Chem',
		'Airgas Inc',
		'AK Steel Holding',
		'Akamai Technologies',
		'Alcoa Inc',
		'Allegheny Energy',
		'Allegheny Technologies',
		'Allergan, Inc',
		'Allstate Corp',
		'Altera Corp',
		'Altria Group',
		'Amazon.com Inc',
		'Amer Electric Pwr',
		'Amer Express',
		'Amer Tower',
		'Ameren Corp',
		'Ameriprise Financial',
		'AmerisourceBergen Corp',
		'Amgen Inc',
		'Amphenol Corp',
		'Anadarko Petroleum',
		'Aon Corp',
		'Apache Corp',
		'Apartment Investment & Mgmt',
		'Apollo Group',
		'Apple Inc',
		'Archer-Daniels-Midland',
		'Assurant Inc',
		'AT&T Inc',
		'Automatic Data Proc',
		'AutoNation Inc',
		'AutoZone Inc',
		'AvalonBay Communities',
		'Avery Dennison Corp',
		'Avon Products',
		'Baker Hughes Inc',
		'Ball Corp',
		'Bank of America',
		'Bank of New York Mellon',
		'Bard (C.R.)',
		'Baxter Intl',
		'BB&T Corp',
		'Becton, Dickinson',
		'Bed Bath & Beyond',
		'Bemis Co',
		'Best Buy',
		'Biogen Idec',
		'Black & Decker Corp',
		'BMC Software',
		'Boeing Co',
		'Boston Properties',
		'Boston Scientific',
		'Bristol-Myers Squibb',
		'Broadcom Corp',
		'Burlington Northn Santa Fe',
		'C.H. Robinson Worldwide',
		'CA Inc',
		'Cabot Oil & Gas',
		'Cameron Intl',
		'Capital One Financial',
		'Carnival Corp',
		'Caterpillar Inc',
		'CB Richard Ellis Grp',
		'Celgene Corp',
		'CenterPoint Energy',
		'Cephalon Inc',
		'CF Industries Hldgs',
		'Chesapeake Energy',
		'Chevron Corp',
		'Chubb Corp',
		'Cincinnati Financial',
		'Cintas Corp',
		'Cisco Systems',
		'Citigroup Inc',
		'Citrix Systems',
		'Clorox Co',
		'CME Group Inc',
		'CMS Energy',
		'Coach Inc',
		'Coca-Cola Co',
		'Coca-Cola Enterprises',
		'Cognizant Tech Solutions',
		'Colgate-Palmolive',
		'Comcast Cl',
		'Comerica Inc',
		'Compuware Corp',
		'ConAgra Foods',
		'ConocoPhillips',
		'CONSOL Energy',
		'Consolidated Edison',
		'Constellation Brands',
		'Constellation Energy Group',
		'Convergys Corp',
		'Corning Inc',
		'Costco Wholesale',
		'Coventry Health Care',
		'CSX Corp',
		'Cummins Inc',
		'Danaher Corp',
		'Darden Restaurants',
		'DaVita Inc',
		'Dean Foods',
		'DENTSPLY Intl',
		'Devon Energy',
		'DeVry Inc',
		'Diamond Offshore Drilling',
		'Discover Financial Svcs',
		'Dominion Resources',
		'Donnelley(R.R.)& Sons',
		'Dover Corp',
		'Dow Chemical',
		'DTE Energy',
		'Duke Energy',
		'Dun & Bradstreet',
		'duPont(E.I.)deNemours',
		'E Trade Financial',
		'Eastman Chemical',
		'Eastman Kodak',
		'Eaton Corp',
		'eBay Inc',
		'Ecolab Inc',
		'El Paso Corp',
		'EMC Corp',
		'Emerson Electric',
		'ENSCO Intl',
		'Entergy Corp',
		'EQT Corp',
		'Equifax Inc',
		'Equity Residential',
		'Exelon Corp',
		'Expedia Inc',
		'Expeditors Intl,Wash',
		'Express Scripts',
		'Exxon Mobil',
		'Family Dollar Stores',
		'Fastenal Co',
		'Federated Investors ',
		'FedEx Corp',
		'Fidelity Natl Info Svcs',
		'Fifth Third Bancorp',
		'First Horizon Natl',
		'FirstEnergy Corp',
		'Fiserv Inc',
		'FLIR Systems',
		'Flowserve Corp',
		'FMC Corp',
		'FMC Technologies',
		'Ford Motor',
		'Forest Labs',
		'Fortune Brands',
		'FPL Group',
		'Franklin Resources',
		'Freept McMoRan Copper&Gold',
		'Frontier Communications',
		'Gannett Co',
		'Genl Dynamics',
		'Genl Electric',
		'Genl Mills',
		'Genuine Parts',
		'Genworth Financial',
		'Genzyme Corp',
		'Gilead Sciences',
		'Goldman Sachs Group',
		'Goodrich Corp',
		'Goodyear Tire & Rub',
		'Google Inc',
		'Grainger (W.W.)',
		'Halliburton Co',
		'Harley-Davidson',
		'Harman Intl',
		'Harris Corp',
		'Hartford Finl Svcs Gp',
		'Hasbro Inc',
		'HCP Inc',
		'Health Care REIT',
		'Hershey Co',
		'Hess Corp',
		'Honeywell Intl',
		'Hospira Inc',
		'Host Hotels & Resorts',
		'Hudson City Bancorp',
		'Humana Inc',
		'Huntington Bancshares',
		'Illinois Tool Works',
		'IMS Health',
		'Intel Corp',
		'IntercontinentalExchange Inc',
		'Interpublic Grp Cos',
		'Intl Bus. Machines',
		'Intl Flavors/Fragr',
		'Intl Paper',
		'Intuitive Surgical',
		'INVESCO Ltd',
		'Iron Mountain',
		'ITT Corp',
		'Jabil Circuit',
		'Janus Capital Group',
		'Johnson & Johnson',
		'Johnson Controls',
		'JPMorgan Chase & Co',
		'Juniper Networks',
		'KB HOME',
		'Kellogg Co',
		'KeyCorp',
		'Kimberly-Clark',
		'Kimco Realty',
		'KLA-Tencor Corp',
		'Kraft Foods',
		'L-3 Communications Hldgs',
		'Laboratory Corp Amer Hldgs',
		'Lauder (Estee) Co',
		'Legg Mason Inc',
		'Leggett & Platt',
		'Lennar Corp',
		'Lexmark Intl',
		'Life Technologies',
		'Lilly (Eli)',
		'Lincoln Natl Corp',
		'Linear Technology Corp',
		'Lockheed Martin',
		'Loews Corp',
		'Lorillard Inc',
		'LSI Corp',
		'M&T Bank',
		'Marathon Oil',
		'Marriott Intl',
		'Marsh & McLennan',
		'Marshall & Ilsley',
		'Masco Corp',
		'Massey Energy',
		'MasterCard Inc',
		'Mattel, Inc',
		'McAfee Inc',
		'McCormick & Co',
		'McDonalds Corp',
		'McGraw-Hill Companies',
		'McKesson Corp',
		'MeadWestvaco Corp',
		'Medco Health Solutions',
		'MEMC Electronic Materials',
		'Merck & Co',
		'Meredith Corp',
		'MetLife Inc',
		'Microchip Technology',
		'Micron Technology',
		'Microsoft Corp',
		'Molex Inc',
		'Molson Coors Brewing',
		'Monsanto Co',
		'Monster Worldwide',
		'Moodys Corp',
		'Morgan Stanley',
		'Motorola, Inc',
		'Murphy Oil',
		'Mylan Inc',
		'Nabors Indus',
		'Natl Oilwell Varco',
		'Natl Semiconductor',
		'New York Times',
		'Newell Rubbermaid',
		'Newmont Mining',
		'News Corp ',
		'NICOR Inc',
		'NIKE, Inc',
		'NiSource Inc',
		'Noble Energy',
		'Norfolk Southern',
		'Northeast Utilities',
		'Northern Trust',
		'Northrop Grumman',
		'Novellus Systems',
		'Nucor Corp',
		'NYSE Euronext',
		'OReilly Automotive',
		'Occidental Petroleum',
		'Office Depot',
		'Omnicom Group',
		'Oracle Corp',
		'Owens-Illinois',
		'PACCAR Inc',
		'Pactiv Corp',
		'Parker-Hannifin',
		'Paychex Inc',
		'Peabody Energy',
		'Peoples United Financial',
		'Pepco Holdings',
		'Pepsi Bottling Group',
		'PepsiCo Inc',
		'PerkinElmer Inc',
		'Pfizer, Inc',
		'PG&E Corp',
		'Philip Morris Intl',
		'Pinnacle West Capital',
		'Pioneer Natural Resources',
		'Pitney Bowes',
		'Plum Creek Timber',
		'PNC Financial Services Group',
		'Polo Ralph Lauren',
		'PPG Indus',
		'PPL Corp',
		'Praxair Inc',
		'Precision Castparts',
		'Principal Financial Grp',
		'Procter & Gamble',
		'Progress Energy',
		'Progressive Corp,Ohio',
		'ProLogis',
		'Prudential Financial',
		'Public Svc Enterprises',
		'Pulte Homes',
		'QLogic Corp',
		'QUALCOMM Inc',
		'Quanta Services',
		'Quest Diagnostics',
		'Questar Corp',
		'Qwest Communications Intl',
		'RadioShack Corp',
		'Range Resources',
		'Raytheon Co',
		'Red Hat Inc',
		'Regions Financial',
		'Republic Services',
		'Reynolds American',
		'Robert Half Intl',
		'Rockwell Collins',
		'Rowan Cos',
		'Ryder System',
		'Safeway Inc',
		'SanDisk Corp',
		'SCANA Corp',
		'Schering-Plough',
		'Schlumberger Ltd',
		'Schwab(Charles)Corp',
		'Sealed Air',
		'Sherwin-Williams',
		'Sigma-Aldrich',
		'Simon Property Group',
		'SLM Corp',
		'Smith Intl',
		'Snap-On Inc',
		'Southern Co',
		'Southwest Airlines',
		'Southwestern Energy',
		'Sprint Nextel Corp',
		'St. Jude Medical',
		'Stanley Works',
		'Starwood Hotels&Res Worldwide',
		'State Street Corp',
		'Stericycle Inc',
		'Stryker Corp',
		'SunTrust Banks',
		'Supervalu Inc',
		'Symantec Corp',
		'Sysco Corp',
		'T.Rowe Price Group',
		'TECO Energy',
		'Tellabs, Inc',
		'Tenet Healthcare',
		'Teradyne Inc',
		'Texas Instruments',
		'Textron, Inc',
		'Thermo Fisher Scientific',
		'Time Warner',
		'Torchmark Corp',
		'Total System Svcs',
		'Travelers Cos',
		'U.S. Bancorp',
		'U.S. Steel',
		'Union Pacific',
		'United Parcel',
		'United Technologies',
		'UnitedHealth Group',
		'Unum Group',
		'Valero Energy',
		'Varian Medical Systems',
		'Ventas Inc',
		'Verizon Communications',
		'VF Corp',
		'Viacom Inc',
		'Vornado Realty Trust',
		'Vulcan Materials',
		'Walgreen Co',
		'Washington Post',
		'Waste Management',
		'Waters Corp',
		'Watson Pharmaceuticals',
		'WellPoint Inc',
		'Wells Fargo',
		'Western Digital',
		'Western Union',
		'Whirlpool Corp',
		'Whole Foods Market',
		'Williams Cos',
		'Wisconsin Energy Corp',
		'Wyndham Worldwide',
		'Wynn Resorts',
		'Xcel Energy',
		'Xerox Corp',
		'Xilinx Inc',
		'XL Capital Ltd',
		'XTO Energy',
		'Yahoo Inc',
		'Yum Brands',
		'Zimmer Holdings'
		];
		
		private static var lastNames:Array=['SMITH',
			'JOHNSON',
			'WILLIAMS',
			'BROWN',
			'JONES',
			'MILLER',
			'DAVIS',
			'GARCIA',
			'RODRIGUEZ',
			'WILSON',
			'MARTINEZ',
			'ANDERSON',
			'TAYLOR',
			'THOMAS',
			'HERNANDEZ',
			'MOORE',
			'MARTIN',
			'JACKSON',
			'THOMPSON',
			'WHITE',
			'LOPEZ',
			'LEE',
			'GONZALEZ',
			'HARRIS',
			'CLARK',
			'LEWIS',
			'ROBINSON',
			'WALKER',
			'PEREZ',
			'HALL',
			'YOUNG',
			'ALLEN',
			'SANCHEZ',
			'WRIGHT',
			'KING',
			'SCOTT',
		];
		
		private static var firstNames:Array=['LATONYA',
		'CANDY',
		'MORGAN',
		'CONSUELO',
		'TAMIKA',
		'ROSETTA',
		'DEBORA',
		'CHERIE',
		'POLLY',
		'DINA',
		'JEWELL',
		'FAY',
		'JILLIAN',
		'DOROTHEA',
		'NELL',
		'TRUDY',
		'ESPERANZA',
		'PATRICA',
		'KIMBERLEY',
		'FRANK',
		'SCOTT',
		'ERIC',
		'STEPHEN',
		'ANDREW',
		'RAYMOND',
		'GREGORY',
		'JOSHUA',
		'JERRY',
		'DENNIS',
		'WALTER',
		'PATRICK',
		'PETER',
		'HAROLD',
		'DOUGLAS',
		'HENRY',
		'CARL',
		'ARTHUR',
		'RYAN'
		]
		public static function get mockNestedData():Object{
			return [ 
				{
					"employeeName": "Tony Devanthery",
					"title": "Architect",
					"hireDate": "07/08/2008",
					"fileId": "tdony@email.com",
					"emailAddress": "tdony@email.com",
					"department": "IT",
					"employeeId": "EMP_TNY_DVN",
					"items": [
						{
							"identifier": "versionId",
							"comments": "Created By Job",
							"project": "Mapping",
							"roleOnProject": "Lead Developer",
							"createdBy": "6/10/2011",
							"createdBy": "6/3/2012",
							"initialArchiveFlag": true,
							"projectStartDate": "08/08/2008",
							"projectEndDate": "08/08/2010",
							"projectId": "PRJ_MPING",
							"items": [
								{
									"hours": 40,
									"rate": 100,
									"timeSheetTitle": "Time Sheet-1",
									"totalExpense": 4000,
									"timesheetId" : "TD_MP_TS1"
								},
								{
									"hours": 42,
									"rate": 100,
									"timeSheetTitle": "Time Sheet-2",
									"totalExpense": 4200,
									"timesheetId" : "TD_MP_TS2"
								}
							]
						},
						{
							"project": "Network Analysis",
							"roleOnProject": "Lead Developer",
							"projectStartDate": "08/09/2010",
							"projectEndDate": "08/09/2011",
							"projectId": "PRJ_NTA",
							"items": [
								{
									"hours": 46,
									"rate": 100,
									"timeSheetTitle": "Time Sheet-1",
									"totalExpense": 4600,
									"timesheetId" : "TD_NTA_TS1"
								},
								{
									"hours": 48,
									"rate": 100,
									"timeSheetTitle": "Time Sheet-2",
									"totalExpense": 4800,
									"timesheetId" : "TD_NTA_TS2"
								}
							]
						}
					]
				},
				{
					"employeeName": "Jason Parker",
					"title": "Programmer",
					"hireDate": "06/06/2008",
					"department": "Support",
					"emailAddress": "jpason@email.com",
					"employeeId": "EMP_JSN_PRK",
					"items": [
						{
							"project": "Grid Support",
							"roleOnProject": "Developer",
							"projectStartDate": "06/07/2008",
							"projectEndDate": "06/12/2009",
							"projectId": "PRJ_GRD",
							"items": [
								{
									"hours": 42,
									"rate": 100,
									"timeSheetTitle": "Time Sheet-1",
									"totalExpense": 4200,
									"timesheetId" : "TD_GRD_TS1"
								},
								{
									"hours": 49,
									"rate": 100,
									"timeSheetTitle": "Time Sheet-2",
									"totalExpense": 4900,
									"timesheetId" : "TD_GRD_TS2"
								}
							]
						},
						{
							"project": "Mapsharp",
							"roleOnProject": "Architect",
							"projectStartDate": "06/14/2009",
							"projectEndDate": "06/12/2011",
							"projectId": "PRJ_MPSHRP",
							"items": [
								{
									"hours": 40,
									"rate": 100,
									"timeSheetTitle": "Time Sheet-1",
									"totalExpense": 4000,
									"timesheetId" : "TD_MPSH_TS1"
								}
							]
						}
					]
				}
			];	
			
		}
		
		
		public static var  mockNestedXml:String="<grid x='0' y='0' forcePagerRow='true' enableFilters='true' enableMultiColumnSort='true' builtInActions='sort,separator'  width='100%' height='100%' id='dgMain' styleName='FlexiciousGridStyle' enableSelectionCascade='true' enableSelectionBubble='true' enableTriStateCheckbox='true' showSpinnerOnFilterPageSort='true' enableDefaultDisclosureIcon='false'>"+
			"  <level childrenField='items'  enableFilters='false' nestIndent='20' selectedKeyField='employeeId'>"+
			"    <columns>"+
			"      <column sortable='false' headerText='' excludeFromSettings='true' enableExpandCollapseIcon='true' width='25' columnWidthMode='fixed'/>"+
			"      <column type='checkbox'/>"+
			"      <column headerText='Employee Name' dataField='employeeName' filterControl='TextInput' filterOperation='BeginsWith'  />"+
			"      <column headerText='Title' dataField='title' filterControl='TextInput' filterOperation='BeginsWith'/>"+
			"      <column headerText='Email Address' dataField='emailAddress' filterControl='TextInput' filterOperation='BeginsWith'/>"+
			"      <column headerText='Department' dataField='department' filterControl='TextInput' filterOperation='BeginsWith'/>"+
			"      <column headerText='Hire Date' dataField='hireDate' filterControl='TextInput' filterOperation='BeginsWith' />"+
			"      </columns>"+
			"      <nextLevel>"+
			"      <level reusePreviousLevelColumns='false' childrenField='items'   headerVerticalGridLineThickness='1' selectedKeyField='projectId'>"+
			"        <columns>"+
			"	       <column sortable='false' headerText='' excludeFromSettings='true' enableExpandCollapseIcon='true' width='50' columnWidthMode='fixed' expandCollapseIconLeft='25'/>"+
			"   	   <column type='checkbox'/>"+
			"          <column  dataField='project' headerText='Project' />"+
			"          <column dataField='roleOnProject' headerText='Role On Project'  />"+
			"          <column dataField='projectStartDate' headerText='Project Start'  />"+
			"          <column dataField='projectEndDate' headerText='Project End'  />"+
			"        </columns>"+
			"        <nextLevel>"+
			"          <level reusePreviousLevelColumns='false' childrenField='items' headerVerticalGridLineThickness='1'  selectedKeyField='timesheetId'>"+
			"            <columns>"+
			"	       	   <column sortable='false' headerText='' excludeFromSettings='true' width='75' columnWidthMode='fixed'/>"+
			"   	   	   <column type='checkbox'/>"+
			"              <column dataField='timeSheetTitle' headerText='TimeSheet Title' />"+
			"              <column dataField='hours' headerText='Hours'  />"+
			"              <column dataField='rate' headerText='Rate'  />"+
			"              <column dataField='totalExpense' headerText='Total Expense'  />"+
			"            </columns>"+
			"          </level>"+
			"        </nextLevel>"+
			"      </level>"+
			"    </nextLevel>"+
			"  </level>"+
			"</grid>"
	}
}