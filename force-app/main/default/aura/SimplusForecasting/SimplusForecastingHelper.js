({
    init : function(component, event, helper) {
        helper.getUserDetails(component, event, helper);
        //helper.getTableFieldSet(component, event, helper, true); //----Changes by Ajay (Added one extra parameter for spinner) --- Moved this line to getColumns method
        //helper.getColumns(component, event, helper);//Commented By Ajay Choudhary On 19th July 2021 --- Moved this line to getUserDetails method
        helper.getDates(component, event, helper);        
        window.addEventListener('resize', $A.getCallback(function(){ 
            helper.dimensionsUpdate(component, event, helper); 
        }));
        window.addEventListener('scroll', $A.getCallback(function(){ 
            helper.handleWindowScroll(component, event, helper); 
        }));
        /*setInterval(
                $A.getCallback(function() {
                    helper.dimensionsUpdate(component, event, helper); 
                })
            , 3000);*/
    },
    
    getTableFieldSet : function(component, event, helper, showSpinner) {//----Changes by Ajay (Added one extra parameter for spinner)
        if(showSpinner){
            //alert('Clik OK button to start the Request');
            component.set('v.startTimer1', helper.getFormattedDate(component,event,new Date()));
            component.set("v.isLoadingList", true);
        }
        var action = component.get("c.getFieldSet");
        action.setParams({
            sObjectName: component.get("v.sObjectName"),
            fieldSets: component.get("v.fieldSets")
        });
        
        action.setCallback(this, function(response) {
            var fieldSetObj = response.getReturnValue();
            console.log(fieldSetObj);
            if(fieldSetObj != null){
                component.set("v.fieldSetValues", fieldSetObj.sortingFieldSet);
                component.set("v.sortingOrderResult", fieldSetObj.sortingOrderResult);
                component.set("v.filteringOrderResult", fieldSetObj.filteringOrderResult);
            }            
            var x = 0;
            var freezeColumns = component.get("v.noOfColumns");
            var fieldSetValues = component.get("v.fieldSetValues");
            var fieldSetValues1 = [];
            var fieldSetValues2 = [];
            
            fieldSetValues.forEach(function(element) {
                if(element.showFieldColumn){ // Added by Ajay Choudhary on 30th Jan 2023 -----> Column Show/Hide functionality
                    x++;
                    if(x <= freezeColumns) {
                        fieldSetValues1.push(element);
                    } else {
                        fieldSetValues2.push(element);
                    }
                }
                
            });
            component.set("v.fieldSetValues1", fieldSetValues1);
            component.set("v.fieldSetValues2", fieldSetValues2);
            
            var list = fieldSetObj.lstObject;
            component.set("v.tableRecords", list);
            component.set("v.tableRecordsUpdated", list);
            helper.buildMonthly(component, event, helper);
            component.set("v.hasPendingMassChange", false);
            component.set("v.isLoadingList", false);
            //alert('Request Completed');
            component.set('v.endTimer1', helper.getFormattedDate(component,event,new Date()));
            component.set("v.pageMax", fieldSetObj.pageMax);
            component.set("v.isBeyond", fieldSetObj.isBeyond);
            window.setTimeout(
                $A.getCallback(function() {
                    helper.dimensionsUpdate(component, event, helper);
                }), 100
            );
            window.setTimeout(
                $A.getCallback(function() {
                    helper.dimensionsUpdate(component, event, helper);
                }), 500
            );
        });
        $A.enqueueAction(action);
    },
    //-------Added by Ajay Choudhary on 7th June 2021--------------Start------------
    getRecordsForTotal : function(component, event, helper){
        component.set("v.isLoadingList", true);
        var action = component.get("c.getRecordTotals");
        var fieldSetValues = component.get("v.fieldSetValues");
        var setfieldNames = new Set();
        for(var c=0, clang=fieldSetValues.length; c<clang; c++){             
            if(!setfieldNames.has(fieldSetValues[c].fieldName)) {                 
                setfieldNames.add(fieldSetValues[c].fieldName);                   
                if(fieldSetValues[c].fieldType == 'REFERENCE') {                     
                    if(fieldSetValues[c].fieldName.indexOf('__c') == -1) {                     	
                        setfieldNames.add(fieldSetValues[c].fieldName.substring(0, fieldSetValues[c].fieldName.indexOf('Id')) + '.Name');                          
                    } else {                     	
                        setfieldNames.add(fieldSetValues[c].fieldName.substring(0, fieldSetValues[c].fieldName.indexOf('__c')) + '__r.Name');                              
                    }                 
                }             
            }         
        }
        
        var arrfieldNames = [];         
        setfieldNames.forEach(v => arrfieldNames.push(v));
        action.setParams({
            //sObjectName: component.get("v.sObjectName"),
            fieldNameJson: JSON.stringify(arrfieldNames),
            sortingOrderResult: component.get("v.sortingOrderResult"),
            filteringOrderResult: component.get("v.filteringOrderResult"),
            page : component.get("v.page")
        });
        action.setCallback(this, function(response) {
            console.log('111',response, response.getReturnValue());
            //var list = JSON.parse(response.getReturnValue());
            helper.buldRecordsForAllTotal(component, event, response.getReturnValue());
            //component.set('v.allRecordsForTotal', list);
            //helper.calculateAllTotals(component, event, helper);
        });
        $A.enqueueAction(action);
    },
    
    buldRecordsForAllTotal : function(component, event, allForecast){
        var forecastMap = new Map();
        for(var i=0;i<allForecast.length;i++){
            var f = allForecast[i];
            var fKey = f.Sold_To_Forecast__r.AccountNumber_R1__c + f.Ship_To_Forecast__r.AccountNumber_R1__c + f.Product_Forecast__r.ProductCode;
            if(!forecastMap.has(fKey)){
                var forecastWrapperObj = new Object();
                forecastWrapperObj.forecastsPerYear = new Map();
                forecastWrapperObj.forecastsPerYear.set(f.Year__c, this.getForecastYear(component, f));
                forecastWrapperObj.key = fKey;
                if(f.Year__c != null) forecastMap.set(fKey, forecastWrapperObj);
            }
            else{
                if(f.Year__c != null) forecastMap.get(fKey).forecastsPerYear.set(f.Year__c, this.getForecastYear(component, f));
            }
        }
        console.log('forecastMap', forecastMap);
        console.log('forecastMap.entries', [ ...forecastMap.values() ]);
        component.set('v.allRecordsForTotal', [ ...forecastMap.values() ]);
        this.calculateAllTotals(component, event);
    },
    
    getForecastYear : function(component, f){
        var year;
        var mgrMonthly = [];
        var repMonthly = [];
        var priorMonthly = [];
      //  var priorActMonthly = [];  // 12 july///////
        var aveMonthly = [];
        var allocationMonthly = [];
        var statisticalMonthly = [];
        year = f.Year__c;
        for(var i = 0; i < 12; i+=1) {
            var mgr =  f['Management_M' + (i+1) + '__c'];
            if(!mgr) mgrMonthly.push(0); else mgrMonthly.push(mgr);
            
            var rep =  f['Acct_Rep_M' + (i+1) + '__c'];
            if(!rep) repMonthly.push(0); else repMonthly.push(rep);
            
            var prior =  f['PriorActuals_M' + (i+1) + '__c'];  // 12th july
            if(!prior) priorMonthly.push(0); else priorMonthly.push(prior);
            
           //  var priorAct =  f['Prior_Month_Act' + (i+1) + '__c'];
           // if(!priorAct) priorActMonthly.push(0); else priorActMonthly.push(priorAct);
             
            var ave =  f['SixMonthRunningAverage_' + (i+1) + '__c'];
            if(!ave) aveMonthly.push(0); else aveMonthly.push(ave);
            
            var alc =  f['Allocation_M' + (i+1) + '__c'];
            if(!alc) allocationMonthly.push(0); else allocationMonthly.push(alc);
            
            var sts =  f['Statistical_M' + (i+1) + '__c'];
            if(!sts) statisticalMonthly.push(0); else this.statisticalMonthly.push(sts);
        }
        var forecastYear = new Object();
        forecastYear.year = year;
        forecastYear.mgrMonthly = mgrMonthly;
        forecastYear.repMonthly = repMonthly;
        forecastYear.priorMonthly = priorMonthly;
      //  forecastYear.priorActMonthly = priorActMonthly; // 12 july
        forecastYear.aveMonthly = aveMonthly;
        forecastYear.allocationMonthly = allocationMonthly;
        forecastYear.statisticalMonthly = statisticalMonthly;
        return forecastYear;
    },
    //-------Added by Ajay Choudhary on 7th June 2021--------------End------------
    getTableRows : function(component, event, helper){
        //alert('Click OK button to start the request');
        component.set('v.startTimer2', helper.getFormattedDate(component,event,new Date()));
        component.set("v.isLoadingList", true);
        var action = component.get("c.getRecords");
        var fieldSetValues = component.get("v.fieldSetValues");
        var setfieldNames = new Set();
        for(var c=0, clang=fieldSetValues.length; c<clang; c++){             
            if(!setfieldNames.has(fieldSetValues[c].fieldName)) {                 
                setfieldNames.add(fieldSetValues[c].fieldName);                   
                if(fieldSetValues[c].fieldType == 'REFERENCE') {                     
                    if(fieldSetValues[c].fieldName.indexOf('__c') == -1) {                     	
                        setfieldNames.add(fieldSetValues[c].fieldName.substring(0, fieldSetValues[c].fieldName.indexOf('Id')) + '.Name');                          
                    } else {                     	
                        setfieldNames.add(fieldSetValues[c].fieldName.substring(0, fieldSetValues[c].fieldName.indexOf('__c')) + '__r.Name');                              
                    }                 
                }             
            }         
        }
        
        var arrfieldNames = [];         
        setfieldNames.forEach(v => arrfieldNames.push(v));
        action.setParams({
            //sObjectName: component.get("v.sObjectName"),
            fieldNameJson: JSON.stringify(arrfieldNames),
            sortingOrderResult: component.get("v.sortingOrderResult"),
            filteringOrderResult: component.get("v.filteringOrderResult"),
            page : component.get("v.page")
        });
        action.setCallback(this, function(response) {
            console.log('result>>>', response.getReturnValue());
            var list = JSON.parse(response.getReturnValue());
            component.set("v.tableRecords", list);
            component.set("v.tableRecordsUpdated", list);
            
            helper.buildMonthly(component, event, helper);
            component.set("v.hasPendingMassChange", false);
            component.set("v.isLoadingList", false);
            //alert('Request completed');
            component.set('v.endTimer2', helper.getFormattedDate(component,event,new Date()));
        });
        $A.enqueueAction(action);
    },
    
    //----Added by Gaurish on 13th Apr 2021------START
    getFormattedDate: function (component,event,date) {
        var hours = date.getHours();
        var minutes = date.getMinutes();
        var seconds = date.getSeconds();
        var ampm = hours >= 12 ? 'pm' : 'am';
        hours = hours % 12;
        hours = hours ? hours : 12;
        minutes = minutes < 10 ? '0'+minutes : minutes;
        var strTime = hours + ':' + minutes +':'+ seconds + ' ' + ampm;
        return (date.getMonth()+1) + "/" + date.getDate() + "/" + date.getFullYear() + "  " + strTime;
    },//----Added by Gaurish on 13th Apr 2021------END
    
    refreshList : function(component, event, helper) {
        var getSort = component.get("c.toggle");
        getSort.setParams({
            sObjectName: component.get("v.sObjectName"),
            mainListSource : component.get("v.mainListSource"),
            page : 1
        });
        getSort.setCallback(this, function(a) {
            var returnValue = a.getReturnValue();
            component.set("v.tableRecords", returnValue.lstObject);
            component.set("v.pageMax", returnValue.pageMax);
            component.set("v.isBeyond", returnValue.isBeyond);
            component.set("v.hasPendingMassChange", false);
            component.set("v.isLoadingList", false);
        });
        $A.enqueueAction(getSort);
    },
    //-------Added by Ajay Choudhary on 7th June 2021--------------Start------------
    calculateAllTotals : function(component, event){
        component.set("v.isLoadingList", true);
        var fullList = component.get("v.allRecordsForTotal");
        var defaultMonth = 12;
        var noOfMonths = component.find("months").get("v.value") ? component.find("months").get("v.value") : defaultMonth;
        var noOfMonthsCounter = 0;
        var selectedView = component.find("views").get("v.value");
        component.set("v.activeView", selectedView ? selectedView : "rep_mgr");
        var defaultDate = component.get("v.selectedDate");
        var selectedDate = component.find("startDate").get("v.value") ? component.find("startDate").get("v.value") : defaultDate[0];
        var splitDate = selectedDate.split(' ');
        var getYear = parseInt(splitDate[1]);
        var getMonth = this.getSelectedDates(splitDate[0]);
        var totalSales = [];
        var totalMktg = [];
        var totalPriorYr = [];
     //   var totalPriorMn = [];  // 12 july//
        var totalAve = [];
        var totalAlloc = [];
        for(var i = 0; i < noOfMonths; i++) {
            totalSales.push(0.00);
            totalMktg.push(0.00);
            totalPriorYr.push(0.00);
          //  totalPriorMn.push(0.00); // 12 july///
            totalAve.push(0.00);
            totalAlloc.push(0.00);
        }
        var total_totalSales=0;var total_totalPrior=0; 
       // var total_totalPriorMonth=0;
        var total_totalMktg=0;  // 12 july///////
        fullList.forEach(function(element) {
            element.colList = [];
            var mon = getMonth;
            var yr = getYear;
            var currentYr = yr;
            noOfMonthsCounter = 0;
            var mgrMonthTotal = 0.00;
            var repMonthTotal = 0.00;
            var priorYearTotal = 0.00;
          //  var priorMonthTotal = 0.00;   // 12 july//
            for(var i = 0; i < noOfMonths; i+=1) {
                if(element.forecastsPerYear.get(currentYr)) {
                    yr = currentYr;
                } else {
                    yr = currentYr-1;
                }
                
                if(element.forecastsPerYear.get(currentYr)) {
                    var mgrMonth = element.forecastsPerYear.get(currentYr).mgrMonthly[mon];
                    var repMonth = element.forecastsPerYear.get(currentYr).repMonthly[mon];
                    var priorMonth = element.forecastsPerYear.get(currentYr).priorMonthly[mon];
                  //  var priorMonthAct = element.forecastsPerYear.get(currentYr).priorActMonthly[mon]; // 12 july//
                    var aveMonth = element.forecastsPerYear.get(currentYr).aveMonthly[mon];
                    var allocMonth = element.forecastsPerYear.get(currentYr).allocationMonthly[mon];
                    var correctMonth = mon+1;
                    priorYearTotal += priorMonth ? parseInt(priorMonth) : 0.00;
                //    priorMonthTotal += priorMonthAct ? parseInt(priorMonthAct) : 0.00; // 12 july//
                    mgrMonthTotal += mgrMonth ? parseInt(mgrMonth) : 0.00;
                    repMonthTotal += repMonth ? parseInt(repMonth) : 0.00;
                    totalSales[i] += repMonth ? parseInt(repMonth) : 0.00;
                    totalMktg[i] += mgrMonth ? parseInt(mgrMonth) : 0.00;
                    totalPriorYr[i] += priorMonth ? parseInt(priorMonth) : 0.00; 
                    totalAlloc[i] += allocMonth ? parseInt(allocMonth) : 0.00;
                 //   totalPriorMn[i] += priorMonthAct ? parseInt(priorMonthAct) : 0.00; // 12 july//
                    totalAve[i] += aveMonth ? parseInt(aveMonth) : 0.00;
                  
                    
                    noOfMonthsCounter++;
                } 
                mon += 1;
                if(mon == 12) {
                    mon = 0;
                    currentYr += 1;
                }
            }
            total_totalSales += repMonthTotal;
            total_totalPrior += priorYearTotal;
            //    total_totalPriorMonth += priorMonthTotal; /////// 12 july////
            total_totalMktg += mgrMonthTotal;
        });
        component.set('v.recordSalesAllTotal', totalSales);
        component.set("v.recordMktgAllTotal", totalMktg);
        component.set("v.recordAllocAllTotal", totalAlloc);
        component.set('v.total_AlltotalSales',total_totalSales);
        component.set('v.total_AlltotalPrior',total_totalPrior);
        //    component.set('v.total_AlltotalPriorMonth',total_totalPriorMonth);  /////// 12 july////
        component.set('v.total_AlltotalMktg',total_totalMktg);
        component.set('v.recordPriorYearAllTotal', totalPriorYr);
        //   component.set('v.recordPriorMonthAllTotal', totalPriorMn);  /////// 12 july////
        component.set('v.recordAveAllTotal', totalAve);
        component.set('v.showAllTotals', true);
        component.set("v.isLoadingList", false);
    },
    //-------Added by Ajay Choudhary on 7th June 2021--------------End------------
    buildMonthly : function(component, event, helper) {
        component.set('v.showTotals', false);
        component.set("v.isLoadingList", true);
        var fullList = component.get("v.tableRecordsUpdated");
        if(fullList){
            var defaultMonth = 12;
            var noOfMonths = component.find("months").get("v.value") ? component.find("months").get("v.value") : defaultMonth;
            var noOfMonthsCounter = 0;
            var isValidMonth = true;
            var selectedView = component.find("views").get("v.value");
            component.set("v.activeView", selectedView ? selectedView : "rep_mgr");
            var defaultDate = component.get("v.selectedDate");
            var selectedDate = component.find("startDate").get("v.value") ? component.find("startDate").get("v.value") : defaultDate[0];
            var splitDate = selectedDate.split(' ');
            var getYear = parseInt(splitDate[1]);
            var getMonth = helper.getSelectedDates(splitDate[0]);
            var forecastIds = [];
            //-------Added by Ajay Choudhary-----------Start------------
            var totalSales = [];
            var totalMktg = [];
            var totalPriorYr = [];
            var totalAlloc = [];
            //     var totalPriorMn = []; // 12 july//
            var totalAve = [];
            for(var i = 0; i < noOfMonths; i++) {
                totalSales.push(0.00);
                totalMktg.push(0.00);
                totalPriorYr.push(0.00);
                //   totalPriorMn.push(0.00); // 12 july//
                totalAve.push(0.00);
                totalAlloc.push(0.00);
            }
            //-------Added by Ajay Choudhary--------------End------------
            var total_totalSales=0;var total_totalPrior=0;
            // var total_totalPriorMonth = 0; /// 12th july/////
            var total_totalMktg=0;//-----Added by Gaurish on 21st May 2021----- 
            for(var j=0;j<fullList.length;j++){
                //fullList.forEach(function(element) {
                fullList[j].colList = [];
                var mon = getMonth;
                var yr = getYear;
                var currentYr = yr;
                var businessGroup = fullList[j].fieldSetValues.Product_Forecast__r.Business_Group__c;
                isValidMonth = true;
                noOfMonthsCounter = 0;
                var mgrMonthTotal = 0.00; //-------Added by Ajay Choudhary
                var repMonthTotal = 0.00; //-------Added by Ajay Choudhary
                var priorYearTotal = 0.00;//-------Added by Ajay Choudhary
                //  var priorMonthTotal = 0.00;//-------Added by Ajay Choudhary // 12th july////
                for(var i = 0; i < noOfMonths; i+=1) {
                    if(fullList[j].forecastsPerYear[currentYr]) { //---------Changed By Ajay
                        yr = currentYr; //---------Changed By Ajay
                    } else {
                        yr = currentYr-1; //---------Changed By Ajay
                        forecastIds.push(fullList[j].fieldSetValues.Id);
                    }
                    
                    if(fullList[j].forecastsPerYear[currentYr]) {
                        var mgrMonth = fullList[j].forecastsPerYear[currentYr].mgrMonthly[mon];
                        var repMonth = fullList[j].forecastsPerYear[currentYr].repMonthly[mon];
                        var priorMonth = fullList[j].forecastsPerYear[currentYr].priorMonthly[mon];
                        //   var priorMonthAct = fullList[j].forecastsPerYear[currentYr].priorActMonthly[mon]; // 12th july/////
                        var aveMonth = fullList[j].forecastsPerYear[currentYr].aveMonthly[mon];
                        var allocMonth = fullList[j].forecastsPerYear[currentYr].allocationMonthly[mon];
                        var chMatrix = fullList[j].forecastsPerYear[currentYr].changeMatrix;
                        var correctMonth = mon+1;
                        priorYearTotal += priorMonth ? parseInt(priorMonth) : 0.00;//-------Added by Ajay Choudhary
                        //   priorMonthTotal += priorMonthAct ? parseInt(priorMonthAct) : 0.00;//-------Added by Ajay Choudhary  // 12th july
                        mgrMonthTotal += mgrMonth ? parseInt(mgrMonth) : 0.00; //-------Added by Ajay Choudhary
                        repMonthTotal += repMonth ? parseInt(repMonth) : 0.00; //-------Added by Ajay Choudhary
                        totalSales[i] += repMonth ? parseInt(repMonth) : 0.00; //-------Added by Ajay Choudhary
                        totalMktg[i] += mgrMonth ? parseInt(mgrMonth) : 0.00; //-------Added by Ajay Choudhary
                        totalPriorYr[i] += priorMonth ? parseInt(priorMonth) : 0.00; //-------Added by Ajay Choudhary on 24 May 2021
                        totalAlloc[i] += allocMonth ? parseInt(allocMonth) : 0.00;
                        //   totalPriorMn[i] += priorMonthAct ? parseInt(priorMonthAct) : 0.00; //-------Added by Ajay Choudhary on 24 May 2021 // 12th july
                        totalAve[i] += aveMonth ? parseInt(aveMonth) : 0.00;//-------Added by Ajay Choudhary on 3 June 2021
                        /*if(selectedView == 'rep') element.colList.push({
                        rep : (repMonth ? repMonth : 0)
                    });
                    else if(selectedView == 'mgr') element.colList.push({
                        mgr : (mgrMonth ? mgrMonth : 0)
                    });
                        else */
                    
                    fullList[j].colList.push({
                        mgr : (mgrMonth ? parseInt(mgrMonth) : 0),
                        rep : (repMonth ? parseInt(repMonth) : 0),
                        alloc : (allocMonth ? parseInt(allocMonth) : '')
                    });
                    
                    noOfMonthsCounter++;
                } else {
                    /*if(selectedView == 'rep') element.colList.push({
                        rep : 0
                    });
                    else if(selectedView == 'mgr') element.colList.push({
                        mgr : 0
                    });
                        else 
                        */
                    fullList[j].colList.push({
                        mgr : 0,
                        rep : 0,
                        alloc : ''
                    });
                }
                
                fullList[j].colList[fullList[j].colList.length -1].priorMonth = priorMonth ? parseInt(priorMonth) : 0;
                //   fullList[j].colList[fullList[j].colList.length -1].priorMonthAct = priorMonthAct ? parseInt(priorMonthAct) : 0; // 12th july
                fullList[j].colList[fullList[j].colList.length -1].aveMonth = aveMonth ? parseInt(aveMonth) : 0;
                fullList[j].colList[fullList[j].colList.length -1].fieldNameAlloc = 'Allocation_M' + correctMonth + '__c';
                fullList[j].colList[fullList[j].colList.length -1].fieldNameRep = 'Acct_Rep_M' + correctMonth + '__c';
                fullList[j].colList[fullList[j].colList.length -1].fieldNameMgr = 'Management_M' + correctMonth + '__c';
                fullList[j].colList[fullList[j].colList.length -1].repIsChanged = parseInt(chMatrix.charAt(mon));
                fullList[j].colList[fullList[j].colList.length -1].mgrIsChanged = parseInt(chMatrix.charAt(mon+ 12));
                fullList[j].colList[fullList[j].colList.length -1].allocIsChanged = parseInt(chMatrix.charAt(mon+ 24));
                fullList[j].colList[fullList[j].colList.length -1].identifier = fullList[j].key + yr + '/' + (mon + 1);
                fullList[j].colList[fullList[j].colList.length -1].chMatrix = chMatrix;
                fullList[j].colList[fullList[j].colList.length -1].year = currentYr;
                fullList[j].colList[fullList[j].colList.length -1].businessGroup = businessGroup;
                
                mon += 1;
                if(mon == 12) {
                    mon = 0;
                    currentYr += 1;
                }
            }
            fullList[j].mgrMonthTotal = mgrMonthTotal; //-------Added by Ajay Choudhary
            fullList[j].repMonthTotal = repMonthTotal; //-------Added by Ajay Choudhary
            fullList[j].priorYearTotal = priorYearTotal;//-------Added by Ajay Choudhary
            //  fullList[j].priorMonthTotal = priorMonthTotal;//-------Added by Ajay Choudhary // 12th july
            total_totalSales += repMonthTotal;//-----Added by Gaurish on 21st May 2021-----
            total_totalPrior += priorYearTotal;//-----Added by Gaurish on 21st May 2021-----
            //  total_totalPriorMonth += priorMonthTotal;//-----Added by Gaurish on 21st May 2021-----   // 12th july
            total_totalMktg += mgrMonthTotal;//-----Added by Gaurish on 21st May 2021-----
            //});
        }
            component.set('v.tableRecordsUpdated', fullList); 
            component.set('v.recordAllocTotal', totalAlloc); //-------Added by Ajay Choudhary
            component.set('v.recordSalesTotal', totalSales); //-------Added by Ajay Choudhary
            component.set("v.recordMktgTotal", totalMktg); //-------Added by Ajay Choudhary
            component.set('v.total_totalSales',total_totalSales);//-----Added by Gaurish on 21st May 2021-----
            component.set('v.total_totalPrior',total_totalPrior);//-----Added by Gaurish on 21st May 2021-----
            //   component.set('v.total_totalPriorMonth',total_totalPriorMonth);//-----Added by Gaurish on 21st May 2021----- // 12 july
            component.set('v.total_totalMktg',total_totalMktg);//-----Added by Gaurish on 21st May 2021-----
            component.set('v.recordPriorYearTotal', totalPriorYr);//-----Added by Ajay Choudhary on 24th May 2021-----   
            //   component.set('v.recordPriorMonthTotal', totalPriorMn);//-----Added by Ajay Choudhary on 24th May 2021----- // 12 july//////
            component.set('v.recordAveTotal', totalAve); //-------Added by Ajay Choudhary on 3 June 2021------
            console.log('totalSales', totalSales);
            console.log('totalMktg', totalMktg);
            console.log('totalPriorYr', totalPriorYr);
            console.log('totalAve', totalAve);
            console.log("fullList >> ", fullList);
            if(forecastIds) {
                helper.createForecast(component, event, helper, forecastIds);
            } else {
                helper.dimensionsUpdate(component, event, helper);
            }
            component.set("v.isLoadingList", false);
            window.setTimeout(
                $A.getCallback(function() {
                    component.set('v.showTotals', true);
                })
                , 2000);
            
        }
        else{
            component.set("v.isLoadingList", false);
        }
    },
    
    getColumns : function(component, event, helper) {
        var currentDate = new Date();
        var currentYear = currentDate.getFullYear();
        var currentMonth = currentDate.getMonth();
        var monthYear = helper.getMonths(currentMonth) + ' ' + currentYear;
        var selectedDate = component.find("startDate").get("v.value") ? component.find("startDate").get("v.value") : monthYear;
        var splitDate = selectedDate.split(' ');
        var getYear = parseInt(splitDate[1]);
        currentYear = getYear;
        var nextYear = currentYear + 1;
        var getMonth = helper.getSelectedDates(splitDate[0]);
        var currentYearMonths = [];
        var nextYearMonths = [];
        var currentYearMonthsStr = [];
        var nextYearMonthsStr = [];
        var isCurrentYear = true;
        var month = getMonth;
        var selectedMonth = component.find("months").get("v.value") ? component.find("months").get("v.value") : 12;
        
        var month_name = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
        
        for(var i = 0; i < selectedMonth; i++) {
            month++;
            if(isCurrentYear == true) {
                currentYearMonths.push(month);
                currentYearMonthsStr.push(month_name[month-1]);
            } else if(isCurrentYear == false) {
                nextYearMonths.push(month);
                nextYearMonthsStr.push(month_name[month-1]);
            }
            
            if(month == 12) {
                isCurrentYear = false;
                month = 0;
            }
        }
        
        component.set("v.forecastColumns", [
            {year : currentYear, list : currentYearMonths, monthList : currentYearMonthsStr}, 
            {year : nextYear, list : nextYearMonths, monthList : nextYearMonthsStr}
        ]);
        helper.getTableFieldSet(component, event, helper, true);//Addedd By Ajay Choudhary On 19th July 2021
    },
    
    getDates : function(component, event, helper) {
        var currentDate = new Date();
        var currentYear = currentDate.getFullYear();
        var currentMonth = currentDate.getMonth();
        //var currentMonth = 0;
        component.set("v.activeDateMonth", currentMonth);
        component.set("v.activeDateYear", currentYear);
        
        var dateList = [];
        var month_name = new Array(12);
        month_name[0] = "January";
        month_name[1] = "February";
        month_name[2] = "March";
        month_name[3] = "April";
        month_name[4] = "May";
        month_name[5] = "June";
        month_name[6] = "July";
        month_name[7] = "August";
        month_name[8] = "September";
        month_name[9] = "October";
        month_name[10] = "November";
        month_name[11] = "December";
        
        var month = currentMonth;
        
        for(var i = 0; i < 12; i++) {
            month++;
            dateList.push(month_name[month-1]+ ' ' + currentYear);
            if(month == 12) {
                month = 0;
                currentYear++;
            }
        }
        component.set("v.selectedDate", dateList);
    },
    
    getSelectedDates : function(month) {
        var month_name = new Array(12);
        month_name["January"] = 0;
        month_name["February"] = 1;
        month_name["March"] = 2;
        month_name["April"] = 3;
        month_name["May"] = 4;
        month_name["June"] = 5;
        month_name["July"] = 6;
        month_name["August"] = 7;
        month_name["September"] = 8;
        month_name["October"] = 9;
        month_name["November"] = 10;
        month_name["December"] = 11;
        return month_name[month];
    },
    
    getMonths : function(month) {
        var month_name = new Array(12);
        month_name[0] = "January";
        month_name[1] = "February";
        month_name[2] = "March";
        month_name[3] = "April";
        month_name[4] = "May";
        month_name[5] = "June";
        month_name[6] = "July";
        month_name[7] = "August";
        month_name[8] = "September";
        month_name[9] = "October";
        month_name[10] = "November";
        month_name[11] = "December";
        return month_name[month];
    },
    
    createForecast : function(component, event, helper, forecastIds) {
        var action = component.get("c.createForecastRecords");
        var fieldSetValues = component.get("v.fieldSetValues");
        var setfieldNames = new Set();
        for(var c=0, clang=fieldSetValues.length; c<clang; c++){             
            if(!setfieldNames.has(fieldSetValues[c].fieldName)) {                 
                setfieldNames.add(fieldSetValues[c].fieldName);                   
                if(fieldSetValues[c].fieldType == 'REFERENCE') {                     
                    if(fieldSetValues[c].fieldName.indexOf('__c') == -1) {                     	
                        setfieldNames.add(fieldSetValues[c].fieldName.substring(0, fieldSetValues[c].fieldName.indexOf('Id')) + '.Name');                          
                    } else {                     	
                        setfieldNames.add(fieldSetValues[c].fieldName.substring(0, fieldSetValues[c].fieldName.indexOf('__c')) + '__r.Name');                              
                    }                 
                }             
            }         
        }
        
        var arrfieldNames = [];         
        setfieldNames.forEach(v => arrfieldNames.push(v));
        
        action.setParams({
            previousForecastId: forecastIds,
            fieldNameJson: JSON.stringify(arrfieldNames),
            sortingOrderResult: component.get("v.sortingOrderResult"),
            filteringOrderResult: component.get("v.filteringOrderResult")
        });
        
        action.setCallback(this, function(response) {
            console.log(response, response.getReturnValue());
            var list = JSON.parse(response.getReturnValue());
            helper.dimensionsUpdate(component, event, helper);
            //component.set("v.tableRecords", list);
            //component.set("v.tableRecordsUpdated", list);
            //helper.buildMonthly(component, event, helper);
        })
        $A.enqueueAction(action);
    },
    
    dimensionsUpdate : function(component, event, helper) {
        try {
            var leftColumns = document.getElementsByClassName("leftTh");
            var leftColsFloat = document.getElementsByClassName("leftThFloat");
            
            for(var i = 0; i < leftColumns.length; i+=1) {
                leftColsFloat[i].style.width = (leftColumns[i].getBoundingClientRect().width - 9) + "px";
                if(i > 0 && leftColsFloat[i].parentNode) leftColsFloat[i].parentNode.style.width = (leftColumns[i].getBoundingClientRect().width) + "px";
                //leftColsFloat[i].style.minWidth = (typeof leftColumns[i] !== 'undefined')?leftColumns[i].getBoundingClientRect().width:0 + "px";
            }
            
            
            var leftFloaterWidth = document.getElementById("fixedColumns").getBoundingClientRect().width;
            
            document.getElementById("fixedColumnsTableFloating").style.width = (leftFloaterWidth) + "px";
            document.getElementById("rightTableFloatContainer").style.width = (leftFloaterWidth - document.getElementById("fullTableContainer").getBoundingClientRect().width) + "px";
            
            document.getElementById("rightTableFloat").style.width = document.getElementById("rightTable").getBoundingClientRect().width + "px";
            
            document.getElementById("floatersContainers").style.width = document.getElementById("fullTableContainer").getBoundingClientRect().width + "px";
            document.getElementById("floatersPositioner").style.width = document.getElementById("fullTableContainer").getBoundingClientRect().width + "px";
            
            
            
            
            var rightColumnDouble = document.getElementsByClassName("rightColumnDouble");
            var rightColumnDoubleFloat = document.getElementsByClassName("rightColumnDoubleFloat");
            
            for(var i = 0; i < rightColumnDouble.length; i+=1) {
                rightColumnDoubleFloat[i].style.width = rightColumnDouble[i].getBoundingClientRect().width + "px";
                rightColumnDoubleFloat[i].style.minWidth = rightColumnDouble[i].getBoundingClientRect().width + "px";
            }
            
            var lowerColumnHeader = document.getElementsByClassName("lowerColumnHeader");
            var lowerColumnHeaderFloat = document.getElementsByClassName("lowerColumnHeaderFloat");
            
            for(var i = 0; i < lowerColumnHeader.length; i+=1) {
                lowerColumnHeaderFloat[i].style.width = lowerColumnHeader[i].getBoundingClientRect().width + "px";
            }
            
        } catch(e) {
            console.log(e);
        }
    },
    
    handleInput : function(component, event, helper, saveId, saveValue) {
        console.log('in input change',saveId);
        //component.set("v.isLoadingList", true);
        var inputId = event.currentTarget.id;
        var row = event.currentTarget.getAttribute("data-rowIndex");
        var col = event.currentTarget.getAttribute("data-colIndex");
        var role = event.currentTarget.getAttribute("data-role");
        var totalSales =  component.get('v.recordSalesTotal'); //-----Added by Ajay on 24th May 2021 ---------
        var totalMktg = component.get("v.recordMktgTotal"); //-----Added by Ajay on 24th May 2021 ---------
        var totalAlloc = component.get("v.recordAllocTotal"); //-----Added by Ajay on 17th August 2021 ---------
        var total_totalSales = component.get('v.total_totalSales');//-----Added by Ajay on 24th May 2021 ---------
        var total_totalMktg =  component.get('v.total_totalMktg');//-----Added by Ajay on 24th May 2021 ---------
        var tableList = component.get("v.tableRecordsUpdated");
        var tempRole = role;
        if(role == 'rep' && tableList[row].colList[col]['mgrIsChanged'] == 0 && (tableList[row].colList[col]['businessGroup'] == 'ALLYLICS & AROMATICS' || tableList[row].colList[col]['businessGroup'] == 'RESINS' || tableList[row].colList[col]['businessGroup'] == 'SYSTEMS & GROWTH')){
            tempRole = 'mgr';
        }
        if(tableList[row].colList[col][role + "Old"] == tableList[row].colList[col][role]) {
            console.log('mgrIsChanges==='+tableList[row].colList[col]['mgrIsChanged']+'==='+tableList[row].colList[col]['mgr'])
            //console.log('363 IF', inputId);
            //do nothing
        } else {
            //-----Added by Ajay on 24th May 2021 ---------Start------------------------
            if(role == 'rep'){
                tableList[row].repMonthTotal = tableList[row].repMonthTotal ? tableList[row].repMonthTotal : 0.00;
                totalSales[col] = totalSales[col] ? totalSales[col] : 0.00;
                total_totalSales = total_totalSales ? total_totalSales : 0.00;
                var row_repMonthTotal = tableList[row].repMonthTotal - tableList[row].colList[col][role];
                tableList[row].repMonthTotal = row_repMonthTotal + parseInt(event.currentTarget.value ? event.currentTarget.value : 0.00);
                totalSales[col] = (totalSales[col] - tableList[row].colList[col][role]) + parseInt(event.currentTarget.value ? event.currentTarget.value : 0.00);
                total_totalSales = (total_totalSales - tableList[row].colList[col][role]) + parseInt(event.currentTarget.value ? event.currentTarget.value : 0.00);
            }
            if(role == 'mgr' || tempRole == 'mgr'){
                tableList[row].mgrMonthTotal = tableList[row].mgrMonthTotal ? tableList[row].mgrMonthTotal : 0.00;
                totalMktg[col] = totalMktg[col] ? totalMktg[col] : 0.00;
                total_totalMktg = total_totalMktg ? total_totalMktg : 0.00;
                var row_mgrMonthTotal = tableList[row].mgrMonthTotal - tableList[row].colList[col][tempRole];
                tableList[row].mgrMonthTotal = row_mgrMonthTotal + parseInt(event.currentTarget.value ? event.currentTarget.value : 0.00);
                totalMktg[col] = (totalMktg[col] - tableList[row].colList[col][tempRole]) + parseInt(event.currentTarget.value ? event.currentTarget.value : 0.00);
                total_totalMktg = (total_totalMktg - tableList[row].colList[col][tempRole]) + parseInt(event.currentTarget.value ? event.currentTarget.value : 0.00);
            }
                else if(role == 'alloc'){
                    totalAlloc[col] = totalAlloc[col] ? totalAlloc[col] : 0.00;
                    totalAlloc[col] = (totalAlloc[col] - tableList[row].colList[col][role]) + parseInt(event.currentTarget.value ? event.currentTarget.value : 0.00);
                }
            //-----Added by Ajay on 24th May 2021 ---------End------------------------------
            tableList[row].colList[col][role + "Old"] = tableList[row].colList[col][role];
            tableList[row].colList[col][role] = parseInt(event.currentTarget.value);
            tableList[row].colList[col][role + "IsChanged"] = 1;
            if(role == 'rep' && tableList[row].colList[col]['mgrIsChanged'] == 0 && (tableList[row].colList[col]['businessGroup'] == 'ALLYLICS & AROMATICS' || tableList[row].colList[col]['businessGroup'] == 'RESINS' || tableList[row].colList[col]['businessGroup'] == 'SYSTEMS & GROWTH')){
                tableList[row].colList[col]['mgrOld'] = tableList[row].colList[col]['mgr'];
                tableList[row].colList[col]['mgr'] = parseInt(event.currentTarget.value);
                tableList[row].colList[col]['mgrIsChanged'] = 1;
                var tempSaveId = saveId.split('/')[0]+'/'+saveId.split('/')[1]+'/mgr';
                this.handleCommitInput(component, tempSaveId, saveValue);
                
            }
            //document.getElementById(inputId).class = "slds-input whiteBg";
            document.getElementById(inputId).style.backgroundColor = "white";
            component.set('v.tableRecordsUpdated', tableList);//-----Added by Ajay on 24th May 2021 ---------
            component.set('v.recordSalesTotal', totalSales); //-----Added by Ajay on 24th May 2021 ---------
            component.set("v.recordMktgTotal", totalMktg); //-----Added by Ajay on 24th May 2021 ---------
            component.set("v.recordAllocTotal", totalAlloc); //------Added by Ajay on 17th August 2021 ---------
            component.set('v.total_totalSales',total_totalSales);//-----Added by Ajay on 24th May 2021 ---------
            component.set('v.total_totalMktg',total_totalMktg);//-----Added by Ajay on 24th May 2021 ---------
            this.dimensionsUpdate(component, event, helper);
            
        }
        component.set('v.showTotals', false);
        window.setTimeout(
            $A.getCallback(function() {
               component.set('v.showTotals', true);
            })
            , 2000);
        
        this.handleCommitInput(component, saveId, saveValue);
    },
    
    handleCommitInput : function(component, saveId, saveValue){
        var saveLine = component.get("c.saveLine");
        saveLine.setParams({
            saveId : saveId,
            saveValue : saveValue ? saveValue : 0
        });
        saveLine.setCallback(this, function(a) {
            console.log('>>>>', a.getReturnValue());
            //helper.getTableFieldSet(component, event, helper, true); //-----Added by Ajay
        });
        $A.enqueueAction(saveLine);
    },
    saveSelections : function(component, helper, selectedDate, selectedMonth) {
        var dateType = new Date(selectedDate);
        component.set("v.activeDateMonth", dateType.getMonth());
        component.set("v.activeDateYear", dateType.getFullYear());
        component.set("v.activeDisplaySize", selectedMonth);
        /****Added By Ajay Choudhary on 19th July 2021**********Start*********/
        var action = component.get("c.saveUserDetail");
        var settings = component.get('v.selectedSDate')+'-'+component.get('v.selectedSMonth')+'-'+component.get('v.selectedSView')+'-'+component.get('v.displayPrior')+'-'+component.get('v.displayAve')+'-'+component.get('v.displayAlloc');
        debugger;
        action.setParams({
            noOfColumns: component.get("v.noOfColumns"),
            settings: settings
        });
        action.setCallback(this, function(response) {
            console.log('User save response', response.getReturnValue()); 
        });
        $A.enqueueAction(action);
        /****Added By Ajay Choudhary on 19th July 2021**********End*********/
    },
    
    handleWindowScroll : function(component, event, helper) {
        //floatersContainers
        var floatersPositioner = document.getElementById("floatersPositioner");
        if(window.innerHeight <= 650 && window.scrollY >= 240) {
        	if(floatersPositioner) floatersPositioner.style.top = "130px";
        	if(floatersPositioner) floatersPositioner.style.position = "fixed";
        } else {
        	if(floatersPositioner) floatersPositioner.style.top = "-" + window.scrollY + "px";
        	if(floatersPositioner) floatersPositioner.style.position = "relative";
        }
    },
    
    getUserDetails : function(component, event, helper){
        var action = component.get("c.fetchUser");
        
        action.setCallback(this, function(response) {
            var userDetail = response.getReturnValue();
            if(userDetail.Forecasting_Lock_Column__c == null || userDetail.Forecasting_Lock_Column__c == '' || userDetail.Forecasting_Lock_Column__c == 0){
                component.set("v.noOfColumns", 3);
            }
            else{
                component.set("v.noOfColumns", userDetail.Forecasting_Lock_Column__c);
            }
            //----16th July 2021----START---
            var month_name = new Array(12);
            month_name["January"] = 0;
            month_name["February"] = 1;
            month_name["March"] = 2;
            month_name["April"] = 3;
            month_name["May"] = 4;
            month_name["June"] = 5;
            month_name["July"] = 6;
            month_name["August"] = 7;
            month_name["September"] = 8;
            month_name["October"] = 9;
            month_name["November"] = 10;
            month_name["December"] = 11;
            var userSettings = userDetail.Forecasting_Settings__c;
            if(userSettings != null && userSettings != undefined && userSettings != ''){
                var settings = userSettings.split('-');
                if(settings[0] != null && settings[0] != '' && settings[0] != undefined){
                    var sMonth = month_name[settings[0].split(' ')[0]];
                    var sYear = parseInt(settings[0].split(' ')[1]);
                    var currentMonth = new Date().getMonth();
                    var currentYear = new Date().getFullYear();
                    if(sYear < currentYear){
                        component.set('v.selectedSDate', helper.getMonths(currentMonth)+' '+currentYear);
                    }
                    else if(sMonth < currentMonth && sYear <= currentYear ){
                        component.set('v.selectedSDate', helper.getMonths(currentMonth)+' '+currentYear);
                    }
                    else{
                        component.set('v.selectedSDate', settings[0]);
                    }
                }
                if(settings[1] != null && settings[1] != '' && settings[1] != undefined){
                    component.set('v.selectedSMonth', settings[1]);
                }
                if(settings[2] != null && settings[2] != '' && settings[2] != undefined){
                    component.set('v.selectedSView', settings[2]);
                }
                if(settings[3] != null && settings[3] != '' && settings[3] != undefined){
                    component.set('v.displayPrior', settings[3] == 'true' ? true : false);//Changed By Ajay Choudhary On 19th July 2021
                }
                if(settings[4] != null && settings[4] != '' && settings[4] != undefined){
                    component.set('v.displayAve', settings[4] == 'true' ? true : false);//Changed By Ajay Choudhary On 19th July 2021
                }
                if(settings[5] != null && settings[5] != '' && settings[5] != undefined){
                    component.set('v.displayAlloc', settings[5] == 'true' ? true : false);//Changed By Ajay Choudhary On 19th July 2021
                }
            }
            helper.getColumns(component, event, helper); //Addedd By Ajay Choudhary On 19th July 2021
        });
        $A.enqueueAction(action);
    }
})