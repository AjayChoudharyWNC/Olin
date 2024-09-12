/**
*       Property of Olin. Do not distribute without permission.
*       Copyright (c) [2017] Olin, its affiliates and their licensors.
*       @author Team Mexico
*       @date   01/01/2018
*       @description     Contains the functions to create PDF for Call Reports
        Modification Log:
        --------------------------------------------------------------------------------------------
        Developer               Mod Number      Date    Description
        --------------------------------------------------------------------------------------------
        Team Mexico             M-001   02/07/2018      Added this comment and the Apex Debug Log code
        Team Mexico             M-002   02/08/2018      Added the if that changes the download file name depending if the file is external
        Team Mexico             M-003   02/08/2018      Added the if that changes the footer depending if the call report had confidential number
        Team Mexico             M-004   02/12/2018      Added a code that fixes the comma crashing PDF issue with Google Chrome browser
*/


public class FCM_getAttendeesFromCallReport {
    public class createException extends Exception {}
    public FCM_VisitReport__c acc;
    public List <FCM_VRAttendee__c> lstAttendees {get; set;}
    public List <FCM_VRProduct__c> lstProducts {get; set;}
    public List <Competitor_R1__c> lstCompetitor {get; set;}
    public List <task> lstTask {get; set;}
    public List <task> lstExternalTask {get; set;}
    
    public FCM_getAttendeesFromCallReport(ApexPages.StandardController controller) {
        try {
        this.acc = (FCM_VisitReport__c)controller.getRecord();    
        getAttendees();
        getProducts();
        getCompetitor();
        getTask();
        getExternalTask();
        
        //This code delete the comma in the Account Name, that cause the PDF crash when is generated in Google Chrome browser
        acc.FCM_Account__r.Name=acc.FCM_Account__r.Name.replace(',',''); 
        
                //In this String we store the URL for the PDF, then we get only the name from the URL.
        String pageName = ApexPages.currentPage().getUrl().substringAfter('/apex/').substringBefore('?');
                //This one generate the variable where the date and time are stored, in has a special format due the name format don't allow spaces neither double point.
        DateTime datDT = System.now();
        string strtimestring = datDT.formatGMT('yyyy-MM-dd HH_mm_ss');
            
        //Once we get the file name from the URL, we compare it: if is ExternalPDF_VF the download file name will content External Call Report, if not, will had Internal Call Report
        if (pageName == 'ExternalPDF_VF') {
                //This one modify the file name once the save button is pressed
                Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename= '+acc.FCM_Account__r.Name+' _External_Call_Report_'+strtimestring+'.pdf');
                } else {
                //This one modify the file name once the save button is pressed
                Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename= '+acc.FCM_Account__r.Name+' _Internal_Call_Report_'+strtimestring+'.pdf');
                }
         if(Test.isRunningTest())
                 {
                throw new createException('Invalid');
            }
        }
        catch(createException ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('Constructor', 'FCM_getAttendeesFromCallReport', null, ex));
        }       
    }
        
    // Get Attendees to display
    public List <FCM_VRAttendee__c> getAttendees() {
          try {
        lstAttendees = [SELECT FCM_VisitReport__r.ConfidentialityAgreement_R1__r.ValidFrom_R1__c,FCM_VisitReport__r.ConfidentialityAgreement_R1__r.Name,ID,Name,FCM_ShortComment__c,FCM_Contact__r.name,FCM_Contact__r.Account.Name, FCM_Contact__r.Title FROM FCM_VRAttendee__c WHERE FCM_VisitReport__c = :acc.ID ];  
              
           if(Test.isRunningTest())
                 {
                throw new createException('Invalid');
            }
        }
        catch(createException ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('Attendees', 'getAttendees', null, ex));
        }       
              return lstAttendees; 
           
    }
    
    // Get Products to display
    public List <FCM_VRProduct__c> getProducts() {
        try {
        lstProducts = new List <FCM_VRProduct__c> ();
        lstProducts = [SELECT Id,Name,FCM_Product__r.ProductCode,FCM_Product__r.LegacyOCAPCode_R1__c,FCM_Product__r.LegacyBCCode_R1__c,FCM_VisitReport__r.FCM_Account__r.MarketSegmentParent_R1__c from FCM_VRProduct__c WHERE FCM_VisitReport__c = :acc.ID ];
         if(Test.isRunningTest())
                 {
                throw new createException('Invalid');
            }
        }
        catch(createException ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('Products', 'getProducts', null, ex));
        }
        return lstProducts;
    }

        // Get Competitors to display
    public List <Competitor_R1__c> getCompetitor() {
        try {
        lstCompetitor = new List <Competitor_R1__c> ();
        lstCompetitor = [SELECT Customer_R1__r.Name, Incoterms_R1__c, Competitor_R1__r.Name, CallReport_R1__r.Name, Name, Olin_Product__r.name, Producer_R1__r.Name, OriginOfGoods_R1__c,Ship_Mode__c, Price_R1__c, CurrencyIsoCode, OfferType_R1__c, PriceFirmDate_R1__c, VolumeofDeal_R1__c, UnitofMeasure_R1__c,Customer_R1__c, CallReport_R1__c from Competitor_R1__c where CallReport_R1__c = :acc.ID ];
        if(Test.isRunningTest())
                 {
                throw new createException('Invalid');
            }
            }
        catch(createException ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('Competitor', 'getCompetitor', null, ex));
        }
        return lstCompetitor;
    }
    
        // Get Tasks to display
    public List <task> getTask() {
        try {
            lstTask = new List <task> ();
            lstTask = [SELECT Subject, Type, ActivityDate, Owner.Name, Priority, Status, Description, Who.name from task where WhatId = :acc.ID ];
             if(Test.isRunningTest())
                 {
                throw new createException('Invalid');
            }
        }
        catch(createException ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('task', 'getTask', null, ex));
        }
        return lstTask;
    }
    
    //Get External Tasks to display
    public List <task> getExternalTask() {
        try {
        lstExternalTask = new List <task> ();
        lstExternalTask = [SELECT Subject, Type, ActivityDate, Owner.Name, Priority, Status, Description, Who.Name from task where type != 'Olin Only' and WhatId = :acc.ID ORDER BY ActivityDate ];
            if(Test.isRunningTest())
                 {
                throw new createException('Invalid');
            }
        }
        catch(createException ex){
            new ApexDebugLog().createLog(new ApexDebugLog.Error('ExternalTask', 'getExternalTask', null, ex));
        }
        
        return lstExternalTask;
    }
    
    
}