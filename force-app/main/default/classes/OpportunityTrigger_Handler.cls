public class OpportunityTrigger_Handler {
    //Static run variables
	private static boolean runAfter = true;

    //Run Singleton
	public static boolean runOnceAfter(){
		if(runAfter){
			runAfter=false;
			return true;
		}else{
			return runAfter;
		}
	}

	//Constructor
	public OpportunityTrigger_Handler(){
		System.debug('Trigger Helper Created');
	}
    /*
    public static void shareOpportunity(List<Team__c> teamList, List<Opportunity> oppList){
        Map<Id,List<Team__c>> teamAccMap = new Map<Id,List<Team__c>>();
        List<OpportunityShare> oppShareList = new List<OpportunityShare>();
        for(Team__c t: teamList){
            if(!teamAccMap.containsKey(t.Account__c)){
                teamAccMap.put(t.Account__c, new List<Team__c>());
            }
            teamAccMap.get(t.Account__c).add(t);
        }
        for(Opportunity opp: oppList){
            if(teamAccMap.containsKey(opp.AccountId)){
                List<Team__c> tList = teamAccMap.get(opp.AccountId);
                for(Team__c t: tList){
                    if(t.Opportunity_Access__c == 'Read Only')
                    	oppShareList.add(TeamTrigger_Utility.createOpportunityShareRecords(t.Team_Member__c, opp.Id, 'Read'));
                    else if(t.Opportunity_Access__c == 'Read/Write')
                        oppShareList.add(TeamTrigger_Utility.createOpportunityShareRecords(t.Team_Member__c, opp.Id, 'Edit'));
                }
            }
        }
        if(oppShareList.size() > 0){
            insert oppShareList;
        }
    }*/

    public static void afterUpdateSharing(List<Opportunity> lstOpportunity, Map<Id, Opportunity> oldMap) {
        List<OpportunityLineItem> lstOppProduct = [SELECT Id, Ship_To__c, OpportunityId, Opportunity.OwnerId, Opportunity.AccountId FROM OpportunityLineItem WHERE OpportunityId IN: lstOpportunity AND Ship_To__c != null];
        
        Map<String, List<String>> mapSoldToIdToShipToIds = new Map<String, List<String>>();
        Map<String, Set<String>> mapShipToIdToOpportunityIds = new Map<String, Set<String>>();
        Map<String, String> mapOppIdToOppOwnerIds = new Map<String, String>();

        Set<String> shipToIds = new Set<String>();
        Set<String> soldToIds = new Set<String>();
        Set<String> opportunityIds = new Set<String>();

        for(OpportunityLineItem oppProduct : lstOppProduct) {
            if(oldMap.get(oppProduct.OpportunityId).OwnerId != oppProduct.Opportunity.OwnerId || oldMap.get(oppProduct.OpportunityId).AccountId != oppProduct.Opportunity.AccountId) {
                if(oppProduct.Ship_To__c != null) {
                    shipToIds.add(oppProduct.Ship_To__c);
                }

                if(mapShipToIdToOpportunityIds.get(oppProduct.Ship_To__c) != null && !mapShipToIdToOpportunityIds.get(oppProduct.Ship_To__c).isEmpty()) {
                    mapShipToIdToOpportunityIds.get(oppProduct.Ship_To__c).add(oppProduct.OpportunityId);
                } else {
                    mapShipToIdToOpportunityIds.put(oppProduct.Ship_To__c, new Set<String>{oppProduct.OpportunityId});
                }
                opportunityIds.add(oppProduct.OpportunityId);
                mapOppIdToOppOwnerIds.put(oppProduct.OpportunityId, oppProduct.Opportunity.OwnerId);
            }
        }

        if(shipToIds != null && !shipToIds.isEmpty()) {
            List<Account_Relationships__c> lstAccountRelationships = [SELECT Id, Sold_To__c, Ship_To__c, Ship_To__r.OwnerId, Relationship_Type__c, Ship_To__r.Ship_To__c
                                                                        FROM Account_Relationships__c 
                                                                        WHERE Ship_To__c IN: shipToIds AND Sold_To__c != null AND Relationship_Type__c = 'Sold To / Ship To' AND Ship_To__r.Ship_To__c = TRUE];
            
            for(Account_Relationships__c acctRelationship : lstAccountRelationships) {
                if(mapSoldToIdToShipToIds.get(acctRelationship.Sold_To__c) != null && !mapSoldToIdToShipToIds.get(acctRelationship.Sold_To__c).isEmpty()) {
                    mapSoldToIdToShipToIds.get(acctRelationship.Sold_To__c).add(acctRelationship.Ship_To__c);
                } else {
                    mapSoldToIdToShipToIds.put(acctRelationship.Sold_To__c, new List<String>{acctRelationship.Ship_To__c});
                }
                soldToIds.add(acctRelationship.Sold_To__c);
            }

            List<AccountTeamMember> lstAccountTeamMember = [SELECT Id, AccountId, UserId, User.Name, User.IsActive, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel 
                                                            FROM AccountTeamMember
                                                            WHERE AccountId IN: soldToIds AND User.IsActive = true];
            
            List<OpportunityShare> existingTeamMember = [SELECT Id, OpportunityId, UserOrGroupId FROM OpportunityShare WHERE OpportunityId IN: opportunityIds AND RowCause != 'Manual'];
            Map<String, Set<String>> mapParentIdToUserId = new Map<String, Set<String>>();
            for(OpportunityShare existingShares : existingTeamMember) {
                if(mapParentIdToUserId.get(existingShares.OpportunityId) != null && !mapParentIdToUserId.get(existingShares.OpportunityId).isEmpty()) {
                    mapParentIdToUserId.get(existingShares.OpportunityId).add(existingShares.UserOrGroupId);
                } else {
                    mapParentIdToUserId.put(existingShares.OpportunityId, new Set<String>{existingShares.UserOrGroupId});
                }
                system.debug('Existing Members: ' + mapParentIdToUserId.get(existingShares.OpportunityId));
            }

            List<OpportunityShare> lstOpportunityShare = new List<OpportunityShare>();

            for(AccountTeamMember teamMember : lstAccountTeamMember) {
                if(mapSoldToIdToShipToIds.get(teamMember.AccountId) != null && !mapSoldToIdToShipToIds.get(teamMember.AccountId).isEmpty()) {
                    for(String shipToAcountId : mapSoldToIdToShipToIds.get(teamMember.AccountId)) {
                        if(mapShipToIdToOpportunityIds.get(shipToAcountId) != null && !mapShipToIdToOpportunityIds.get(shipToAcountId).isEmpty()) {
                            for(String opportunityId : mapShipToIdToOpportunityIds.get(shipToAcountId)) {
                                if(teamMember.UserId != mapOppIdToOppOwnerIds.get(opportunityId) && (mapParentIdToUserId.get(opportunityId) != null && !mapParentIdToUserId.get(opportunityId).isEmpty() && !mapParentIdToUserId.get(opportunityId).contains(teamMember.UserId))) { 
                                    OpportunityShare opportunityShare = new OpportunityShare();
                                    opportunityShare.OpportunityId = opportunityId;
                                    opportunityShare.UserOrGroupId = teamMember.UserId;
                                    if(teamMember.OpportunityAccessLevel == 'Edit') {
                                        opportunityShare.OpportunityAccessLevel = 'Edit';
                                    } else {
                                        opportunityShare.OpportunityAccessLevel = 'Read';
                                    }
                                    lstOpportunityShare.add(opportunityShare);
                                }
                            }
                        }
                    }
                }
            }

            List<OpportunityShare> lstOpportunityShareDel = [SELECT Id, OpportunityId, RowCause FROM OpportunityShare WHERE OpportunityId IN: opportunityIds AND RowCause = 'Manual'];
            
            // Reset the sharing first
            if(lstOpportunityShareDel != null && !lstOpportunityShareDel.isEmpty()) {
                Database.delete(lstOpportunityShareDel);
            }

            // And then re-create them
            if(lstOpportunityShare != null && !lstOpportunityShare.isEmpty()) {
                Database.insert(lstOpportunityShare);
            }
        }
    }
    @InvocableMethod(label='Amend Opportunity' description='Amend opportunity and related contract, quote and quote lines')
    public static List<AmendmentOpportunity> amendOpportunity(List<AmendmentOpportunity>  amend) {
        
        
        Opportunity amendedOpp = amend.get(0).amendedOpp;
        Date startDate = amend[0].agreementStartDate;
        Date endDate = amend[0].agreementEndDate;
        system.debug('startDate :::: '+startDate);
         system.debug('endDate :::: '+endDate);
        system.debug('amend[0].agreementStartDate :::: '+amend[0].agreementStartDate);
         system.debug('amend[0].agreementEndDate :::: '+amend[0].agreementEndDate);
        system.debug('amendedOpp :::: '+amendedOpp);
         system.debug('amend.get(0).amendedOpp :::: '+amend.get(0).amendedOpp);
        system.debug('amendedOpp.SBQQ__PrimaryQuote__c :::: '+amendedOpp.SBQQ__PrimaryQuote__c);
        
        Opportunity clonedOpportunity = amendedOpp.clone(false,false);
        clonedOpportunity.Amended_Opportunity__c = amendedOpp.Id;
        clonedOpportunity.Amendment_Number__c = amendedOpp.Amendment_Number__c + 1;
        clonedOpportunity.CloseDate = startDate;
        clonedOpportunity.Contract_End_Date__c = endDate;
        clonedOpportunity.Contract_Start_Date__c = startDate;
        //clonedOpportunity.Parent_Opportunity__c = amendedOpp.Id;
        clonedOpportunity.SBQQ__Contracted__c = False;
        clonedOpportunity.StageName = 'Negotiation';
        clonedOpportunity.Has_Been_Amended__c = false;
        clonedOpportunity.Originating_Contract_Number__c= amendedOpp.Originating_Contract_Number__c;
        if(String.isBlank(amendedOpp.Originating_Contract_Number__c))
           clonedOpportunity.Originating_Contract_Number__c= amendedOpp.Contract_Number__c;
        clonedOpportunity.Name = ' Amendment '+clonedOpportunity.Amendment_Number__c + ' for Contract ' + + clonedOpportunity.Originating_Contract_Number__c;
        insert clonedOpportunity;
           
           
        SBQQ__Quote__c origPriceRequest = [SELECT Id, ApplyPartnerDiscountFirst__c, SAP_Sales_Org__c, Automatic_Price_Update_Letter__c, Base_Currency__c, Bid_Reference_PO__c, CurrencyIsoCode, 
                                                Cancellation_Period__c, Default_Price_Change_Frequency__c, Default_Price_Change_Mechanism__c, Duplication_Status__c,
                                                Evergreen_Contract__c, Joint_IP_Development__c, Legal_Contact__c, Number_of_Renewals__c, OwnerId, Price_Start_Date__c,
                                                RecordTypeId, Renewal_Frequency_yrs__c, Response_Type__c, SBQQ__BillingCity__c, SBQQ__BillingCountry__c, SBQQ__BillingName__c,
                                                SBQQ__BillingPostalCode__c, SBQQ__BillingState__c, SBQQ__BillingStreet__c, SBQQ__ContractingMethod__c, SBQQ__DefaultTemplate__c,
                                                SBQQ__Distributor__c, SBQQ__DistributorDiscount__c, SBQQ__OriginalQuote__c, SBQQ__Partner__c, SBQQ__PartnerDiscount__c, SBQQ__PaymentTerms__c,
                                                SBQQ__PriceBook__c, SBQQ__Primary__c, SBQQ__PrimaryContact__c, SBQQ__RenewalTerm__c, SBQQ__SalesRep__c, SBQQ__ShippingCity__c,
                                                SBQQ__ShippingCountry__c, SBQQ__ShippingName__c, SBQQ__ShippingPostalCode__c, SBQQ__ShippingState__c, SBQQ__ShippingStreet__c, SBQQ__Source__c,
                                                SBQQ__SubscriptionTerm__c, SBQQ__Type__c, Show_Contract_Details__c, SBQQ__Account__c, SBQQ__PricebookId__c, SBQQ__EndDate__c, Title_Transfer__c,
                                                Ship_To_Any__c, Ship_To_Account__c, Override_Freight__c, Notify_Days_Before__c 
                                       FROM SBQQ__Quote__c
                                       WHERE Id =: amendedOpp.SBQQ__PrimaryQuote__c
                                       LIMIT 1];
        System.debug('origPriceRequest ::::::: ' +origPriceRequest);
        //Clone Price Request
        Id RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft Price Request').getRecordTypeId();
        SBQQ__Quote__c clonedPriceReq = origPriceRequest.clone(false, true, false, false);
        clonedPriceReq.Price_Request_Version__c = 1;
        clonedPriceReq.Price_Start_Date__c = startDate;
        clonedPriceReq.SBQQ__EndDate__c = endDate;
        clonedPriceReq.RecordTypeId = RecordTypeId;
        clonedPriceReq.ApprovalStatus__c = '';
        clonedPriceReq.SBQQ__EndDate__c = endDate;
        clonedPriceReq.SBQQ__Opportunity2__c = clonedOpportunity.Id;
        clonedPriceReq.SBQQ__Source__c = origPriceRequest.Id;
        clonedPriceReq.SBQQ__StartDate__c = startDate;
        clonedPriceReq.SBQQ__Type__c = 'Amendment';
        System.debug('clonedPriceReq ::::::: ' +clonedPriceReq);
        insert clonedPriceReq;
        amend[0].newPriceRequest = clonedPriceReq;
        //Clone Contract Number Mapping
        List<Contract_Number_Mapping__c> cnmList = new List<Contract_Number_Mapping__c>();
        for(Contract_Number_Mapping__c cnm : [SELECT Id, CurrencyIsoCode, Incoterm__c, IsDeleted, Last_SAP_POSEX_Number__c, Name, Original_Quote__c,Originating_Contract_Number__c,OwnerId,Quote_Line__c,
                                              Related_Sold_To__c, SAP_Contract_Number__c, SFDC_Contract_Id__c, SFDC_Contract_Key__c, Ship_To__c,Ship_To_Code__c, Shipping_Condition__c
                                              FROM Contract_Number_Mapping__c
                                              WHERE Original_Quote__c = : origPriceRequest.Id]){
            Contract_Number_Mapping__c clonedCNM =  cnm.clone(false, true, false, false);
            clonedCNM.Original_Quote__c = clonedPriceReq.Id;                               
            cnmList.add(clonedCNM);
        }
        insert cnmList;
       
        List<SBQQ__QuoteLine__c> origQuoteLineList = [SELECT Id, Adj_Floor__c, Adj_Target__c, SAP_Sales_Org__c, Base_Currency__c, Base_Price_USD__c, Base_UOM__c, Base_Volume__c, Exchange_Rate__c, Formula_Name__c, 
                                            Freight_Charge__c, High_Threshold__c, Incoterm__c, Low_Threshold__c, Maximum_Volume__c, Minimum_Volume__c, Net_Back_Target__c, Netback_Min__c,
                                            Outbound_Charges__c, Payment_Method__c, Per_Quantity__c, Price_Change_Frequency__c, Price_Change_Mechanism__c, Price_Start_Date__c, Product_Level__c,
                                            SBQQ__CompoundDiscountRate__c, SBQQ__ContractedPrice__c, SBQQ__CostEditable__c, SBQQ__CustomerPrice__c, SBQQ__DefaultSubscriptionTerm__c, SBQQ__Description__c,
                                            SBQQ__Discount__c, SBQQ__DiscountSchedule__c, SBQQ__DiscountTier__c, SBQQ__EffectiveEndDate__c, SBQQ__EffectiveStartDate__c, SBQQ__EndDate__c,
                                            SBQQ__Hidden__c, SBQQ__ListPrice__c, SBQQ__NetPrice__c, SBQQ__NonDiscountable__c, SBQQ__NonPartnerDiscountable__c, SBQQ__Number__c, 
                                            SBQQ__OptionDiscount__c, SBQQ__OriginalPrice__c, SBQQ__PackageCost__c, SBQQ__PartnerDiscount__c, SBQQ__PriceEditable__c, SBQQ__PricingMethodEditable__c,
                                            SBQQ__PricingMethod__c, SBQQ__Product__c, SBQQ__ProductOption__c, SBQQ__ProratedListPrice__c, SBQQ__Quantity__c, SBQQ__RegularPrice__c, SBQQ__Renewal__c,
                                            SBQQ__SpecialPrice__c, SBQQ__SpecialPriceDescription__c, SBQQ__SpecialPriceType__c, SBQQ__StartDate__c, SBQQ__SubscriptionBase__c, SBQQ__SubscriptionPercent__c, 
                                            SBQQ__SubscriptionPricing__c, SBQQ__SubscriptionScope__c, SBQQ__TermDiscount__c, SBQQ__TermDiscountSchedule__c, SBQQ__UnitCost__c,
                                    		SBQQ__VolumeDiscount__c, Ship_To__c, Ship_To_Account__c, Shipped_Product__c, Shipping_Condition__c, Shipping_Point__c, Through_Charges__c, 
                                    		To_Charges__c, Trade_Product__c, UOM__c, UOM_Conversion_Factor__c, SBQQ__Quote__c, Price_Request_Account__c, Ship_Mode__c, Volume_Period__c,
                                    		Ship_From_Plant_List__c, Avg_Annualize_Volume__c, Base_UOM1__c, Fusion_PH1_Performance_Center__c, Fusion_PH2_Plan_Product__c, Fusion_PH3_Trade_Product__c, 
											PH2_Plan_Product__c, PH1_Performance_Center__c, Freight_Component__c, GCO_Business_Segment__c, Business_Group__c, Inco_Location__c, Inco_Port__c,
                                    		Inco_Code__c, CurrencyIsoCode, Discount_Percent__c, Freight_Discount__c, Validity_Start_Date__c, Validity_End_Date__c, Adjustment_Factor__c, 
                                    		Adjustment_Factor_Pct__c, Price_Period_Volume__c, Status__c, SBQQ__DynamicOptionId__c, SBQQ__OptionLevel__c, SBQQ__OptionType__c, 
											SBQQ__PricebookEntryId__c, SBQQ__ProductSubscriptionType__c, SBQQ__SubscriptionType__c, Adder_Type__c, Display_Options__c, Scale_UOM__c,
                                    		Max_Volume__c, Min_Volume__c, Exempt__c, SBQQ__ProratedPrice__c, SBQQ__PartnerPrice__c, Base_Freight_Overide__c, Display_Price__c, New_Delivered_Price__c, SBQQ__Bundled__c,
                                    		SBQQ__Optional__c, Customer_Product_Code__c, SBQQ__BundledQuantity__c,SBQQ__RequiredBy__c,CUPS_Discount_Percent__c, CUPS_Discount_Percent2__c, 
                                            CUPS_Discount_Percent3__c, CUPS_Discount_Percent4__c, CUPS_Eligible__c, CUPS_End_Date__c, CUPS_End_Date2__c,CUPS_End_Date3__c, CUPS_End_Date4__c,
                                            CUPS_End_User__c, CUPS_End_User2__c, CUPS_End_User3__c,  CUPS_End_User4__c, CUPS_Start_Date__c, CUPS_Start_Date2__c, CUPS_Start_Date3__c, 
                                            CUPS_Start_Date4__c, CUPS_Support_Price__c, CUPS_Support_Price2__c, CUPS_Support_Price3__c, CUPS_Support_Price4__c, Has_CUPS__c, 
                                            New_CUPS_End_Date__c, New_CUPS_End_Date2__c, New_CUPS_End_Date3__c, New_CUPS_End_Date4__c, New_CUPS_Start_Date__c, New_CUPS_Start_Date2__c,
                                            New_CUPS_Start_Date3__c, New_CUPS_Start_Date4__c, New_CUPS_Support_Price__c, New_CUPS_Support_Price2__c, New_CUPS_Support_Price3__c, New_CUPS_Support_Price4__c,
											Competitive_Distributor__c, Competitive_Manufacturer__c, Competitive_Price__c, Competitor_Product__c, New_Competitive_Manufacturer__c, New_Competitive_Price__c, 
                                            New_Competitor__c, New_Competitor_Product__c, Distributor__c, SBQQ__DistributorDiscount__c, Is_Distributor_Relationship__c, Ship_To_Distributor__c, Total_Distributor_Lines__c, PosexNo__c,
                                            Fusion_PH1__c, Fusion_PH2__c, Fusion_PH3__c, Fusion_Profit_Group__c, Fusion_Segment__c, GMID_Number__c, GMID__c, Global_UOM__c, Material_Group_Number__c,
                                            Material_Group__c, Material_Type__c,PH1__c, PH2__c, Profit_Center_Number__c, Profit_Center__c, Profit_Group__c, Standard_UOM__c, Is_default_Standard_UOM_set__c, Fuel_Surcharge_Exemption__c
                                    FROM SBQQ__QuoteLine__c 
                                    WHERE SBQQ__Quote__c =: amendedOpp.SBQQ__PrimaryQuote__c];
         System.debug('origPriceRequest ::::::: ' +origPriceRequest);
        
       
        
        //Map original parent quote line and cloned parent quote line
        Map<Id, SBQQ__QuoteLine__c> origCloneParentQuoteLineMap = new Map<Id, SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c newClonedQuoteLine;
       
        List<SBQQ__QuoteLine__c> clonedParentQuoteLines = new List<SBQQ__QuoteLine__c>();
        
        for(SBQQ__QuoteLine__c ql : origQuoteLineList){  
            if(ql.SBQQ__RequiredBy__c == NULL){
                
                if(!origCloneParentQuoteLineMap.containsKey(ql.Id)){
                    newClonedQuoteLine = new SBQQ__QuoteLine__c();
                    newClonedQuoteLine = ql.clone(false, false, false, false);
                    if(ql.Status__c =='Won'){
                        newClonedQuoteLine.Status__c = 'Negotiation';
                        newClonedQuoteLine.SBQQ__Quote__c = clonedPriceReq.Id;
                    }
                    clonedParentQuoteLines.add(newClonedQuoteLine);
                    
                    origCloneParentQuoteLineMap.put(ql.Id, newClonedQuoteLine);  
                }
            }
            
        }
        insert origCloneParentQuoteLineMap.values();
        system.debug('origCloneParentQuoteLineMap :::::  '+origCloneParentQuoteLineMap);
   
        
        //clone and relate child quote lines to parent quote line
        List<SBQQ__QuoteLine__c> expireOldQuoteLines = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> clonedChildQuoteLines = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c ql : origQuoteLineList){
           if(ql.SBQQ__RequiredBy__c != NULL && origCloneParentQuoteLineMap.containsKey(ql.SBQQ__RequiredBy__c)){
               newClonedQuoteLine = new SBQQ__QuoteLine__c();
               newClonedQuoteLine = ql.clone(false, false, false, false);
               if(ql.Status__c =='Won'){
                   newClonedQuoteLine.Status__c = 'Negotiation';
                   newClonedQuoteLine.SBQQ__Quote__c = clonedPriceReq.Id;
               }
               system.debug('origCloneParentQuoteLineMap.get(ql.SBQQ__RequiredBy__c).Id :::::  '+origCloneParentQuoteLineMap.get(ql.SBQQ__RequiredBy__c).Id); 
               newClonedQuoteLine.SBQQ__RequiredBy__c = origCloneParentQuoteLineMap.get(ql.SBQQ__RequiredBy__c).Id;
               clonedChildQuoteLines.add(newClonedQuoteLine);
           }
            ql.Custom_Expiration_Date__c = EndDate;
            ql.Price_Status__c = 'Expired';
            expireOldQuoteLines.add(ql);
        }
        insert clonedChildQuoteLines;
        update expireOldQuoteLines;
        
        //Update new Opportunity
        clonedOpportunity.SBQQ__PrimaryQuote__c = clonedPriceReq.Id;
        update clonedOpportunity;

        //Expire original Price Request
        origPriceRequest.Expired_Agreement__c = True;
        origPriceRequest.SBQQ__Primary__c = False;
        origPriceRequest.SentToSAP__c = False;
        
        Update origPriceRequest;
        
        //Update original Opportunity
        amendedOpp.Amendment_Opportunity__c = clonedOpportunity.Id;
        amendedOpp.Contract_End_Date__c = endDate;
        amendedOpp.Expired_Agreement__c = True;
        amendedOpp.Has_Been_Amended__c = True;
        update amendedOpp;
        
       List<AmendmentOpportunity> amendList = amend;
       return amendList;   
    }
    
    public class AmendmentOpportunity{
        
        @InvocableVariable
        public Opportunity amendedOpp;

        @InvocableVariable
        public Date agreementStartDate;
        
        @InvocableVariable
        public Date agreementEndDate;
        
        @InvocableVariable
        public SBQQ__Quote__c newPriceRequest;
        
    }
}