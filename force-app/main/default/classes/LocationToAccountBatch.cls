global class LocationToAccountBatch implements Database.Batchable<sObject>, Database.Stateful {

    global Map<String, List<String>> mapOfCountryAndStateCodes;
    global Map<String, List<String>> mapOfCountryAndState;
    global String dupeAccIds = '';
    global String otherErrorLocs = '';
    global String stateCountryError = '';
    global Map<String, Integer> mapOfLocNameAndCount;
    global Integer numOfConvertedLocations = 0;
    global Integer numOfProcessedLocations = 0;
    global String debugMsg = '';

    global LocationToAccountBatch(Map<String, List<String>> mapOfCountryAndState, 
                                    Map<String, List<String>> mapOfCountryAndStateCodes) {
        this.mapOfCountryAndState = mapOfCountryAndState;
        this.mapOfCountryAndStateCodes = mapOfCountryAndStateCodes;
        mapOfLocNameAndCount = new Map<String, Integer>();
    }

    global Database.QueryLocator start(Database.BatchableContext BC){

        Location_Migration_Filter__c dateFilter = Location_Migration_Filter__c.getValues('Created Date Range Filter');
        Date startDate = dateFilter.Start_Date__c;
        Date endDate = dateFilter.End_Date__c;

        String query = 'SELECT Id, ' + 
                        'Name, ' +
                        'CurrencyIsoCode, ' +
                        'FCM_Account__r.Region__c, ' +
                        'FCM_Account__r.Region_R1__c, ' +
                        'FCM_Account__r.OwnerId, ' +
                        'RecordType.Name, ' + 
                        'FCM_Street__c, ' +
                        'FCM_City__c, ' +
                        'FCM_StateProvince__c, ' +
                        'FCM_ZipPostalCode__c, ' +
                        'FCM_Country__c, ' +
                        'CreatedById, ' +
                        'LastModifiedById, ' +
                        'FCM_Account__c, ' +
                        'Name_2__c, ' +
                        'AccountGroup_R1__c, ' +
                        'FCM_Inco_Term__c, ' +
                        'LineofBusiness_R1__c, ' +
                        'FCM_Status__c, ' +
                        'ExternalDataSource_R1__c, ' +
                        'FCM_ExternalId__c, ' +
                        'SiteType_R1__c' +
                        ' FROM FCM_Address__c WHERE isDeleted = False' +
                        ' AND DAY_ONLY(CreatedDate) >= :startDate AND DAY_ONLY(CreatedDate) <= :endDate';
        System.debug(Database.query(query));
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<FCM_Address__c> scope){
        
        numOfProcessedLocations += scope.size();
        
        //select Account record types
        Map<String, String> mapOfRTNameAndRTId = new Map<String, String>();

        for(RecordType rt: [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account']) {
            mapOfRTNameAndRTId.put(rt.Name, rt.Id);
        }

        List<Schema.PicklistEntry> incoTerms = Schema.SObjectType.Account.fields.Inco_Terms__c.getPicklistValues();

        Map<String, String> mapOfLocAndAccIncoTerms = new Map<String, String>();

        for(Schema.PicklistEntry picklistValue : incoTerms) {
            mapOfLocAndAccIncoTerms.put(
                picklistValue.getLabel().substring(0, 3), 
                picklistValue.getValue()
            );
        }

        AggregateResult[] groupedResultsByAccOwner = [SELECT FCM_Account__r.OwnerId, COUNT(Name) FROM FCM_Address__c GROUP BY FCM_Account__r.OwnerId];

        List<String> listOfAccOwners = new List<String>();

        for (AggregateResult ar : groupedResultsByAccOwner)  {
            listOfAccOwners.add((String)ar.get('OwnerId'));
        }

        Map<Id, User> mapOfAccOwners = new Map<Id, User> ([SELECT Id, isActive FROM User WHERE Id IN :listOfAccOwners]);

        List<User> listOfDefaultOwner = [SELECT Id FROM User WHERE FirstName = 'Simplus' AND LastName = 'Integration'];
        
        Id defaultOwnerId = UserInfo.getUserId();
        
        if(!listOfDefaultOwner.isEmpty()) {
        	defaultOwnerId = listOfDefaultOwner.get(0).Id;    
        }
		
        Map<Id, FCM_Address__c> locationMap = new Map<Id, FCM_Address__c>();

        for(FCM_Address__c location : scope) {
            locationMap.put(location.Id, location);
        }

        List<Account> convertedAccs = [SELECT Id, Location_Record_ID__c FROM Account 
                        WHERE Location_Record_ID__c IN :locationMap.keySet()];

        for(Account acc : convertedAccs) {
            locationMap.remove(acc.Location_Record_ID__c);
        }

        List<Account> newAccounts = new List<Account>();
        
        for(FCM_Address__c location : locationMap.values()) {
            
            String recordTypeId = '';
            Boolean isPendingSapCustomer = false;
            String type = null;
            String accType = null;
            Boolean isShipTo = false;
            String newAccOwnerId = location.FCM_Account__r.OwnerId;
            String locName = location.Name;

            Boolean isAddressCode = false;
            String state = location.FCM_StateProvince__c;
            String country = location.FCM_Country__c;

            String recordTypeName = location.RecordType.Name;

            // Map Location record type to Account Record type
            if(recordTypeName == 'Competitor') {
                recordTypeId = mapOfRTNameAndRTId.get('Competitor Location');
                type = 'Competitor';
            } else if(recordTypeName == 'Pending SAP Customer') {
                recordTypeId = mapOfRTNameAndRTId.get('Customer Location');
                isPendingSapCustomer = true;
                type = 'Customer';
                accType = 'Customer';
            } else if(recordTypeName == 'Plant') {
                recordTypeId = mapOfRTNameAndRTId.get('Olin Location');
                type = 'Olin Corporation';
            } else if(recordTypeName == 'Prospect') {
                recordTypeId = mapOfRTNameAndRTId.get('Prospect Location');
                type = 'Prospect';
                accType = 'Prospect';
            } else if(recordTypeName == 'Standard') {
                recordTypeId = mapOfRTNameAndRTId.get('Customer Location');
                type = 'Customer';
                accType = 'Customer';
            } 

            if((recordTypeName == 'Standard' || recordTypeName == 'Pending SAP Customer') 
                &&
                location.FCM_ExternalId__c != null
            ) {
                isShipTo = true;
            }

            if(!mapOfAccOwners.get(location.FCM_Account__r.OwnerId).isActive) {
                newAccOwnerId = defaultOwnerId;
            }

            if(country == null && state == null) {
                stateCountryError += location.Id + ' - ' 
                                    + location.Name + ' - '
                                    + state + ' - '
                                    + country + ' - '
                                    + 'Blank State and Country' + '\n';
            } else if(country == null) {
                stateCountryError += location.Id + ' - ' 
                                    + location.Name + ' - '
                                    + state + ' - '
                                    + country + ' - '
                                    + 'Blank Country' + '\n';
            } else if(state == null) {
                stateCountryError += location.Id + ' - ' 
                                    + location.Name + ' - '
                                    + state + ' - '
                                    + country + ' - '
                                    + 'Blank State' + '\n';
            }

            Boolean isStateAndCntrySameFormat = (String.isNotBlank(country) && String.isNotBlank(state) &&
                            ((country.length() == 2 && (state.length() <= 3)) || 
                                (country.length() > 2 && state.length() > 3)));

            if((isStateAndCntrySameFormat || String.isBlank(state)) && country != null && country.length() == 2) {
                isAddressCode = true;
            } else if(isStateAndCntrySameFormat && country == 'USA') {

                if(state.length() <= 3) {    
                    country = 'US';
                    isAddressCode = true;
                } else {
                    country = 'United States';
                }

            } else if(isStateAndCntrySameFormat && country != null) {

                String newCountry = '';
                String newState = '';

                for(String word : country.split(' ')) {
                    newCountry += word.capitalize() + ' ';
                }
                
                country = newCountry.trim();

                if(state != null) {
                    
                    for(String word : state.split(' ')) {
                        newState += word.capitalize() + ' ';
                    }

                    state = newState.trim();

                }

            } else if((!isStateAndCntrySameFormat || country == null) && state != null) {

                Map<String, List<String>> searchMap;

                if(state.length() <= 3) {
                    searchMap = mapOfCountryAndStateCodes;
                    isAddressCode = true;
                    state = state.toUpperCase();
                } else {
                    searchMap = mapOfCountryAndState;
                    isAddressCode = false;
                }

                for(String cntry : searchMap.keySet()) {
                    if(searchMap.get(cntry).contains(state)) {
                        country = cntry;
                    }
                }

            }

            /*
                Country code convert to two characters (e.g USA)
                If state and country have different format (name or code), convert state and country to codes 
            */
            if(isAddressCode) {
            	state = (String.isNotBlank(state))? state.toUpperCase() : '';
                country = (String.isNotBlank(country))? country.toUpperCase() : '';
            }
            
            if(isAddressCode && mapOfCountryAndStateCodes.containsKey(country) && 
                !mapOfCountryAndStateCodes.get(country).contains(state)) {
                if(state != null) {
                    stateCountryError += location.Id + ' - ' 
                                    + location.Name + ' - '
                                    + state + ' - '
                                    + country + ' - '
                                    + 'Country doesn\'t have that state' + '\n';
                }
                state = '';
            } else if(!isAddressCode && mapOfCountryAndState.containsKey(country) && 
                !mapOfCountryAndState.get(country).contains(state)) {
                if(state != null) {
                    stateCountryError += location.Id + ' - ' 
                                + location.Name + ' - '
                                + state + ' - '
                                + country + ' - '
                                + 'Country doesn\'t have that state' + '\n';
                }
                state = '';
            }

            if(mapOfLocNameAndCount.containsKey(locName.toLowerCase())) {
                mapOfLocNameAndCount.put(locName.toLowerCase(), mapOfLocNameAndCount.get(locName.toLowerCase()) + 1);
                locName += ' - LOC ' + mapOfLocNameAndCount.get(locName.toLowerCase());
            }

            Account newAcc = new Account(
                Name = locName,
                CurrencyIsoCode = location.CurrencyIsoCode,
                OwnerId = newAccOwnerId,
                ShippingStreet = location.FCM_Street__c,
                ShippingCity = location.FCM_City__c,
                ShippingPostalCode = location.FCM_ZipPostalCode__c,
                /*
                CreatedById = location.CreatedById,
                LastModifiedById = location.LastModifiedById,
                
                ParentId = location.FCM_Account__c,
                */
                Name_2__c = location.Name_2__c,
                AccountGroup_R1__c = location.AccountGroup_R1__c,
                Inco_Terms__c = mapOfLocAndAccIncoTerms.get(location.FCM_Inco_Term__c),
                LineOfBusiness_R1__c = location.LineofBusiness_R1__c,
                Status_R1__c = location.FCM_Status__c,
                //External_Data_Source__c = location.ExternalDataSource_R1__c,
                AccountSource = location.ExternalDataSource_R1__c,
                //SAP_ID__c = location.FCM_ExternalId__c,
                AccountNumber_R1__c = location.FCM_ExternalId__c,
                Site_Type__c = location.SiteType_R1__c,
                RecordTypeId = recordTypeId,
                Pending_SAP_Customer__c = isPendingSapCustomer,
                Type = type,
                //Account_Type__c = accType,
                Ship_To__c = isShipTo,
                Location_Record_ID__c = location.Id,
                Region__c = location.FCM_Account__r.Region__c,
                Region_R1__c = location.FCM_Account__r.Region_R1__c
            );

            if(isAddressCode) {
                newAcc.ShippingStateCode = state;
                newAcc.ShippingCountryCode = country;
            } else {
                newAcc.ShippingState = state;
                newAcc.ShippingCountry = country;
            }
            
            if(recordTypeName == 'Competitor') {
                newAcc.Competitor__c = location.FCM_Account__c;
            }

            newAccounts.add(newAcc);

        }
        
        Database.SaveResult[] sr = Database.insert(newAccounts, false);
        
        List<Account> dupeAccs = new List<Account>(); 
        
        for(Integer i = 0; i < sr.size(); i++) {
            
            if(!sr[i].isSuccess()) {
                
                for(Database.Error error : sr[i].getErrors()) {
                    
                    if (error instanceof Database.DuplicateError) {
                        
                        Account dupeAcc = newAccounts[i];
                          
                        if(dupeAcc.Name.contains(' - LOC')) {
                            dupeAcc.Name = dupeAcc.Name.split(' - LOC', 2)[0];
                        }
                        
                        if(mapOfLocNameAndCount.containsKey(dupeAcc.Name.toLowerCase())) {
                            mapOfLocNameAndCount.put(dupeAcc.Name.toLowerCase(), mapOfLocNameAndCount.get(dupeAcc.Name.toLowerCase()) + 1);
                        } else {
                            mapOfLocNameAndCount.put(dupeAcc.Name.toLowerCase(), 1);
                        }
                      
                        dupeAcc.Name = dupeAcc.Name + ' - LOC ' + mapOfLocNameAndCount.get(dupeAcc.Name.toLowerCase());
                        dupeAccs.add(dupeAcc);
                        
                        //debugMsg += 'Line: 336' + dupeAcc.Name + '\n';
                        
                    } else {
                        
                        otherErrorLocs += newAccounts[i].Location_Record_ID__c + ' - ' +
                            newAccounts[i].Name + ' - ' +
                            newAccounts[i].BillingStateCode + ' - ' +
                            newAccounts[i].BillingCountryCode + ' - ' + 
                            error.getMessage() + '\n';
                        
                    }
                }
            } else {
                numOfConvertedLocations++;
            }
        }
        
       	List<Account> dupeAccsWithLoc = new List<Account>();
        List<String> dupeAccsWithLocNames = new List<String>();
        
        if(!dupeAccs.isEmpty()) {
            sr = Database.insert(dupeAccs, false);
            
            for(Integer i = 0; i < sr.size(); i++) {
                
                if(!sr[i].isSuccess()) {
                    
                    for(Database.Error error : sr[i].getErrors()) {
                        
                        if (error instanceof Database.DuplicateError) {
                            
                            Account dupeAcc = dupeAccs[i];
                            dupeAccsWithLoc.add(dupeAcc);
                            String temp = dupeAcc.Name;
                            temp = temp.substring(0, temp.length() - 2);
                            temp = temp.replace(' - LOC', ' - LOC %').trim();
                            dupeAccsWithLocNames.add(temp);
                            
                            //debugMsg += 'Line: 372' + temp + '\n';
                        }
                    }
                } else {
                    numOfConvertedLocations++;
                }
            }
        }
        
        List<Account> accCheckForDup = [SELECT Name FROM Account WHERE Name LIKE :dupeAccsWithLocNames ORDER BY CreatedDate DESC];
        
        for(Account acc : accCheckForDup) {
            
            String[] split = acc.Name.split(' - LOC ', 2);
            String originalName = split[0].toLowerCase();
            Integer count = Integer.valueOf(split[1]);
            
            if(mapOfLocNameAndCount.containsKey(originalName) && mapOfLocNameAndCount.get(originalName) <= count) {
                mapOfLocNameAndCount.put(originalName, count + 1);
                //debugMsg += 'Line: 390' + acc.Name + ' - ' + (count + 1) + '\n';
                
            }
            
        }
        
        List<Account> lastAccNameChangeList = new List<Account>();
        
        for(Account acc : dupeAccsWithLoc) {
            
            String[] split = acc.Name.split(' - LOC ', 2);
            String originalName = split[0].toLowerCase();
            
            if(mapOfLocNameAndCount.containsKey(originalName)) {
                
                Integer counter = mapOfLocNameAndCount.get(originalName);
                acc.Name = split[0] + ' - LOC ' + counter;
                lastAccNameChangeList.add(acc);
                mapOfLocNameAndCount.put(originalName, counter + 1);
                
            }
            
        }
		
        if(!lastAccNameChangeList.isEmpty()) {
            /*
            for(Account acc : lastAccNameChangeList) {
                dupeAccIds += acc.Location_Record_ID__c + ' - ' +
                                        acc.Name + '\n';
            }*/
        	sr = Database.insert(lastAccNameChangeList, false);
        	
            for(Integer i = 0; i < sr.size(); i++) {
                
                if(!sr[i].isSuccess()) {
                    
                    for(Database.Error error : sr[i].getErrors()) {
                        
                        if (error instanceof Database.DuplicateError) {
                            
                            dupeAccIds += dupeAccs[i].Location_Record_ID__c + ' - ' +
                                        dupeAccs[i].Name + ' - ' + 
                                        error.getMessage() + '\n';
                        }
                    }
                } else {
                    numOfConvertedLocations++;
                }
            }
			
        }
        
    }

   global void finish(Database.BatchableContext BC) {

       	Integer numOfLocations = Database.countQuery('SELECT COUNT() FROM FCM_Address__c');
       	Integer totalNumberOfConvertedLocations = Database.countQuery('SELECT COUNT() FROM Account WHERE Location_Record_ID__c != null');
       
        //Send an email to the User after your batch completes
        Messaging.SingleEmailMessage mailSend = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'raniel.agno@simplus.com'};
        mailSend.setToAddresses(toAddresses);
        mailSend.setSubject('Apex Batch Job has been done.');

        String mapOfLocNameAndCountStr = '';
        for(String locName : mapOfLocNameAndCount.keySet()) {
            mapOfLocNameAndCountStr += locName + ' - ' + mapOfLocNameAndCount.get(locName) + '\n';
        }
       	
        String body = 'The batch Apex job has processed. \n\n' + 
            			'Conversion Result: ' + totalNumberOfConvertedLocations + '/' + numOfLocations +
            			'\n \n Number of Processed Locations: ' + numOfProcessedLocations +  
            			'\n \n Number of Converted Locations: ' + numOfConvertedLocations +
            			'\n \n Debug: ' + debugMsg + 
            			'\n \n Other errors: \n' + otherErrorLocs + 
                        '2nd Duplicate Errors: \n' + dupeAccIds + '\n\n' + 
                        //'Map of Loc Name and Count:\n' + mapOfLocNameAndCountStr + '\n\n' + 
                        'State and Country list of error: \n' + stateCountryError;

        mailSend.setPlainTextBody(body);
        System.debug(body);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mailSend });
        
   }

}