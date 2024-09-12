public with sharing class ForecastingExtractController {
    //------- Added by GAURISH on 21st May 2021 ------START
    public Map<String,Decimal> monthlyTotalSalesMap{get;set;}
    public Map<String,Decimal> monthlyTotalPriorMap{get;set;}
  //  public Map<String,Decimal> monthlyTotalPriorMonthMap{get;set;}    // 12th july/////
    public Map<String,Decimal> monthlyTotalMktgMap{get;set;}
    public Map<String,Decimal> monthlyTotalAveMap{get;set;}
     public Map<String,Decimal> monthlyTotalAllocMap{get;set;}
    public Decimal total_totalSales{get;set;}
    public Decimal total_totalPrior{get;set;}
  //  public Decimal total_totalPriorMonth{get;set;}      ///// 12th july/////
    public Decimal total_totalMktg{get;set;}
    //------- Added by GAURISH on 21st May 2021 ------END
    public Boolean showSales{get;set;}
    public Boolean showMktg{get;set;}
    public Boolean showAlloc{get;set;}
    
    public ForecastingExtractController() {
        ForecastingGridController.preventLoadDml = true;
        String tnoOfMonths = ApexPages.currentPage().getParameters().get('months');
        String tstartMonth = ApexPages.currentPage().getParameters().get('stmonth');
        String tstartYear = ApexPages.currentPage().getParameters().get('styear');
        String tview = ApexPages.currentPage().getParameters().get('view');
        String showAllocation = ApexPages.currentPage().getParameters().get('showAlloc');
        if(tnoOfMonths != null) noOfMonths = Integer.valueOf(tnoOfMonths);
        if(tstartMonth != null) startMonth = Integer.valueOf(tstartMonth);
        if(tstartYear != null) startYear = Integer.valueOf(tStartYear);
        if(tview != null) view = tview;
        /*******Added By Ajay Choudhary on 11th June 2021 **********Start*********/
        if(view == 'rep'){
            showSales = true; 
        }
        else if(view == 'mgr'){
            showMktg = true;
        }
        else if(view == 'rep_mgr' || view == 'all'){
            showSales = true;
            showMktg = true;
        }
        if(showAllocation == 'true'){
            showAlloc = true;
        }
        else{
            showAlloc = false;
        }
        /*******Added By Ajay Choudhary on 11th June 2021 **********End*********/
        ForecastingGridController.DEFAULT_PAGE_SIZE = 300;
        
        //------- Added by GAURISH on 21st May 2021 ------START
        monthlyTotalSalesMap = new Map<String,Decimal>();
        monthlyTotalPriorMap = new Map<String,Decimal>();
        monthlyTotalAllocMap = new Map<String,Decimal>();
      //  monthlyTotalPriorMonthMap = new Map<String,Decimal>();         ////// 12th july/////
        monthlyTotalMktgMap = new Map<String,Decimal>();
        monthlyTotalAveMap = new Map<String,Decimal>();
        total_totalSales = 0;
        total_totalPrior = 0;
     //   total_totalPriorMonth = 0;       ////// 12th july/////
        total_totalMktg = 0;
        //------- Added by GAURISH on 21st May 2021 ------END
        //
        List<ForecastingGridController.ForecastWrapper> forecastList = ForecastingGridController.toggle(null,1,Date.today().year()).lstObject;
        System.debug('forecastList=='+forecastList);
        fixMonthly(forecastList);
    }
    
    public List<String> fieldDisplayList {get;set;}
    public List<String> monthDisplayList {get;set;}
    
    public Map<String, FinalDataCollect> finalList = new Map<String, FinalDataCollect>();
    public Map<String, FinalDataCollect> getFinalList() {
        return this.finalList;
    }
    
    public Integer startMonth = System.today().month() -1;
    public Integer startYear = System.today().year();
    public Integer noOfMonths = 12;
    public Integer noOfMonthsCounter = 0;
    public String view = 'all';
    
    private void fixMonthly(List<ForecastingGridController.ForecastWrapper> forecastList ) {
        List<String> monthStrList = new List<String>{'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};
            monthDisplayList = new List<String>();
        
        Integer monDisp = startMonth;
        Integer yrDisp = startYear;
        for(Integer i = 0; i < noOfMonths; i+=1) {
            monthDisplayList.add(monthStrList[monDisp] + ' ' + yrDisp);
            //------- Added by GAURISH on 21st May 2021 ------START
            monthlyTotalSalesMap.put(monthStrList[monDisp] + ' ' +yrDisp, 0);
            monthlyTotalPriorMap.put(monthStrList[monDisp] + ' ' +yrDisp, 0);
          //  monthlyTotalPriorMonthMap.put(monthStrList[monDisp] + ' ' +yrDisp, 0); ////// 12th july/////
            monthlyTotalMktgMap.put(monthStrList[monDisp] + ' ' +yrDisp, 0);
            monthlyTotalAveMap.put(monthStrList[monDisp] + ' ' +yrDisp, 0);
            monthlyTotalAllocMap.put(monthStrList[monDisp] + ' ' +yrDisp, 0);
            
            //------- Added by GAURISH on 21st May 2021 ------END
            monDisp += 1;
            if(monDisp == 12) {
                monDisp = 0;
                yrDisp += 1;
            }
        }
        for(ForecastingGridController.ForecastWrapper fw : forecastList) {
            Integer mon = startMonth;
            Integer yr = startYear;
            Integer currentYr = yr;
            noOfMonthsCounter = 0;
            
            Decimal tp = 0;Decimal ts = 0;Decimal tm = 0;
           // Decimal tpm=0; // 12th july////
            //------- Added by GAURISH on 21st May 2021 ------
            
            if(!finalList.containsKey(fw.key)) finalList.put(fw.key, new FinalDataCollect(fw));
            
            for(Integer i = 0; i < noOfMonths; i+=1) {
                Decimal mgrMonth = (fw.forecastsPerYear.containsKey(currentYr) ? fw.forecastsPerYear.get(currentYr).mgrMonthly[mon] : 0);
                Decimal repMonth = (fw.forecastsPerYear.containsKey(currentYr) ? fw.forecastsPerYear.get(currentYr).repMonthly[mon] : 0);
                Decimal priorMonth = (fw.forecastsPerYear.containsKey(currentYr) ? fw.forecastsPerYear.get(currentYr).priorMonthly[mon] : 0);
             //   Decimal priorMonthAct = (fw.forecastsPerYear.containsKey(currentYr) ? fw.forecastsPerYear.get(currentYr).priorActMonthly[mon] : 0); ////// 12th july/////
                Decimal average = (fw.forecastsPerYear.containsKey(currentYr) ? fw.forecastsPerYear.get(currentYr).aveMonthly[mon] : 0);
                Decimal alloc = (fw.forecastsPerYear.containsKey(currentYr) ? fw.forecastsPerYear.get(currentYr).allocationMonthly[mon] : 0);
                 finalList.get(fw.key).forecastData.add(new FinalData(repMonth, mgrMonth, priorMonth, average, alloc));
              //  finalList.get(fw.key).forecastData.add(new FinalData(repMonth, mgrMonth, priorMonth, priorMonthAct, average)); ////// 12th july/////
                
                
                //------- Added by GAURISH on 21st May 2021 ------START
                monthlyTotalSalesMap.put(monthStrList[mon] + ' ' +yr, monthlyTotalSalesMap.get(monthStrList[mon] + ' ' +yr)+repMonth);
                monthlyTotalPriorMap.put(monthStrList[mon] + ' ' +yr, monthlyTotalPriorMap.get(monthStrList[mon] + ' ' +yr)+priorMonth);
              //  monthlyTotalPriorMonthMap.put(monthStrList[mon] + ' ' +yr, monthlyTotalPriorMonthMap.get(monthStrList[mon] + ' ' +yr)+priorMonthAct);  ////// 12th july/////
                monthlyTotalMktgMap.put(monthStrList[mon] + ' ' +yr, monthlyTotalMktgMap.get(monthStrList[mon] + ' ' +yr)+mgrMonth);
                monthlyTotalAveMap.put(monthStrList[mon] + ' ' +yr, monthlyTotalAveMap.get(monthStrList[mon] + ' ' +yr)+average);
                monthlyTotalAllocMap.put(monthStrList[mon] + ' ' +yr, monthlyTotalAllocMap.get(monthStrList[mon] + ' ' +yr)+alloc);
                //------- Added by GAURISH on 21st May 2021 ------END
                
                mon += 1;
                if(mon == 12) {
                    mon = 0;
                    yr += 1;
                }
                tp += priorMonth;//------- Added by GAURISH on 21st May 2021 ------
               // tpm += priorMonthAct;  //------- 12th july 2021 ------
                ts += repMonth;//------- Added by GAURISH on 21st May 2021 ------
                tm += mgrMonth;//------- Added by GAURISH on 21st May 2021 ------
            }
            //------- Added by GAURISH on 21st May 2021 ------START
            finalList.get(fw.key).totalPrior = tp;
         //   finalList.get(fw.key).totalPriorMonth = tpm;
            finalList.get(fw.key).totalSales = ts;
            finalList.get(fw.key).totalMktg = tm; 
            total_totalMktg += tm;
            total_totalSales += ts;
            total_totalPrior += tp;
          //  total_totalPriorMonth += tpm;        //------- 12th july 2021 ------
            //------- Added by GAURISH on 21st May 2021 ------END
        }
    }
    private class FinalDataCollect {
        public List<String> data {get;set;}
        public List<FinalData> forecastData {get;set;}
        public Decimal totalPrior{get;set;}//------- Added by GAURISH on 21st May 2021 ------
     //   public Decimal totalPriorMonth{get;set;}//------- 12th july 2021 ------
        public Decimal totalSales{get;set;}//------- Added by GAURISH on 21st May 2021 ------
        public Decimal totalMktg{get;set;}//------- Added by GAURISH on 21st May 2021 ------
        
        public FinalDataCollect(ForecastingGridController.ForecastWrapper fw) {
            this.data = new List<String>();
            this.forecastData = new List<FinalData>();
            //{ fw.fieldSetValues.Sold_To_Forecast__r.Name, fw.fieldSetValues.Ship_To_Forecast__r.Name};
            Map<String, Object> objMap = ((sObject)fw.fieldSetValues).getPopulatedFieldsAsMap();
            this.data.add(objMap.get('Parent_Account__c') == null ? '' : objMap.get('Parent_Account__c') + '');
            this.data.add( ((sObject) objMap.get('Sold_To_Forecast__r')).get('Name') + '');
            this.data.add( ((sObject) objMap.get('Ship_To_Forecast__r')).get('Name') + '');
            this.data.add(objMap.get('Ship_To_Shipping_City__c') == null ? ' ' : objMap.get('Ship_To_Shipping_City__c')  + '');
            this.data.add( ((sObject) objMap.get('Product_Forecast__r')).get('Name') + '');
            this.data.add(objMap.get('Sold_To_Owner__c') + '');
            this.data.add(objMap.get('Ship_To_Billing_City__c') + '');
            this.data.add(objMap.get('Ship_To_Billing_Country__c') + '');
            this.data.add(objMap.get('Ship_To_Shipping_Country__c') + '');
            this.data.add(objMap.get('Ship_from_source_fx__c') == null ? ' ' : objMap.get('Ship_from_source_fx__c') + '');
            this.data.add(objMap.get('Shipping_mode_fx__c') == null ? ' ' : objMap.get('Shipping_mode_fx__c') + '');
            this.data.add(objMap.get('Unit_Of_Measure__c') == null ? ' ' : objMap.get('Unit_Of_Measure__c') + '');
            this.data.add(objMap.get('Purchased_Product__r') == null ? '' : ((sObject) objMap.get('Purchased_Product__r')).get('Name') + '');
        }
    }
    
    private class FinalData {
        public Decimal rep {get;set;}
        public Decimal mgr {get;set;}
        public Decimal prior {get;set;}
    //    public Decimal priorAct {get;set;}  //12th july/////////////
        public Decimal average {get;set;}
        public Decimal alloc {get;set;}
     //   public FinalData(Decimal r, Decimal m, Decimal p, Decimal pm, Decimal a) {  //12th july/////////////
           public FinalData(Decimal r, Decimal m, Decimal p,  Decimal a, Decimal al) { 
            this.rep = (r != null ? r : 0);
            this.mgr = (m != null ? m : 0);
            this.prior = (p != null ? p : 0);
        //    this.priorAct = (pm != null ? pm : 0);  //12th july/////////////
            this.average = (a != null ? a : 0);
               this.alloc = (al != null ? al : 0);
        }
    }
}