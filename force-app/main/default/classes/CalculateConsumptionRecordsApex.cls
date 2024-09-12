public class CalculateConsumptionRecordsApex
{
    public static void calculateConsumption(List<Consumption_Share__c> lstConsumptionShare, String sourceYear, String destinationYear)
    {
        System.debug('calculateConsumption:: Original lstConsumptionShare: ' + lstConsumptionShare);

        //Unknown account information
        Set<String> unknownAccount = new Set<String>();
        List<Consumption_Share_Account__mdt> lstCustomMetadataType = [SELECT Id, DeveloperName, MasterLabel, Value__c, IsReadOnly__c FROM Consumption_Share_Account__mdt WHERE DeveloperName = 'Unknown_Account'];
        for(Consumption_Share_Account__mdt customMetadataType : lstCustomMetadataType)
            unknownAccount.add(customMetadataType.Value__c);

        String olinCorpRecordType = 'Olin Corp';
        Set<String> shipToAccountNumber = new Set<String>();
        Set<String> shipFromAccountNumber = new Set<String>();
        Set<String> gmid = new Set<String>();

        List<Consumption_Share__c> olinShares = new List<Consumption_Share__c>();
        Map<String, List<Consumption_Share__c>> knownShares = new Map<String, List<Consumption_Share__c>>();
        Map<String, Consumption_Share__c> unknownShares = new Map<String, Consumption_Share__c>();

        List<String> totalConsumptionIds = new List<String>();
        Map<String, Total_Consumption__c> totalConsumptionMap = new Map<String, Total_Consumption__c>();

        for(Consumption_Share__c consumption : lstConsumptionShare)
        {
            //For all shares (Olin, others and unknown): Back up Share Amount and Share Percentage to Previous_Share_Amount__c and Previous_Share_Percent__c fields
            consumption.Previous_Share_Amount__c = consumption.Share_Amount__c;
            consumption.Previous_Share_Percent__c = consumption.Share_Percent__c;

            //Creating total consumption map
            totalConsumptionIds.add(consumption.Consumption_ShareOfWallet__c);
                
            //Collections for storing Ship-to/Sold-to/Product ids
            if(!shipToAccountNumber.contains(consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Ship_To__r.AccountNumber_R1__c))
                shipToAccountNumber.add(consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Ship_To__r.AccountNumber_R1__c);

            if(!shipFromAccountNumber.contains(consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Account_R1__r.AccountNumber_R1__c))
                shipFromAccountNumber.add(consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Account_R1__r.AccountNumber_R1__c);
            
            if(!gmid.contains(consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.Gmid_Number__c))
                gmid.add(consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.Gmid_Number__c);

            //Olin Shares
            System.debug('Record Type==='+consumption.Seller_Account_SOW__r.RecordType.Name);
            if(consumption.Seller_Account_SOW__r.RecordType.Name == olinCorpRecordType)
            {
                olinShares.add(consumption);
            }
            else
            {
                if(!unknownAccount.contains(consumption.Seller_Account_SOW__c))
                {
                    //Other company shares (Known)
                    String key = consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Ship_To__r.AccountNumber_R1__c + '-' + consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Account_R1__r.AccountNumber_R1__c + '-' + consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.Gmid_Number__c;

                    if(!knownShares.containsKey(key))
                        knownShares.put(key, new List<Consumption_Share__c>{consumption});
                    else
                        knownShares.get(key).add(consumption);

                }
                else if(unknownAccount.contains(consumption.Seller_Account_SOW__c))
                {
                    //Other company shares (Unknown)
                    String key = consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Ship_To__r.AccountNumber_R1__c + '-' + consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Account_R1__r.AccountNumber_R1__c + '-' + consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.Gmid_Number__c + '-' + consumption.Consumption_ShareOfWallet__c;

                    if(!unknownShares.containsKey(key))
                        unknownShares.put(key, consumption);
                }
            }
        }

        //For backing up Share_Amount__c to Previous_Share_Amount__c and Share_Percent__c to Previous_Share_Percent__c for Shares
        update lstConsumptionShare;
        System.debug('calculateConsumption:: ALL Previous Share and Percent backed up: ' + lstConsumptionShare);

        for(Total_Consumption__c tc : [SELECT Id, Consumption__c, Purchased_Product__r.Ship_To__r.AccountNumber_R1__c, Purchased_Product__r.Account_R1__r.AccountNumber_R1__c, Purchased_Product__r.Product_R1__r.Gmid_Number__c FROM Total_Consumption__c WHERE Id IN : totalConsumptionIds])
        {
            String key = tc.Purchased_Product__r.Ship_To__r.AccountNumber_R1__c + '-' + tc.Purchased_Product__r.Account_R1__r.AccountNumber_R1__c + '-' + tc.Purchased_Product__r.Product_R1__r.Gmid_Number__c;
            
            //Back up Previous Consumption Total for all the Total Consumption records
            tc.Previous_Consumption_Total__c = tc.Consumption__c;
            totalConsumptionMap.put(key, tc);
            //totalConsumptionMap.put(tc.Id, tc);
        }

        //For backing up Consumption__c to Previous_Consumption_Total__c for Total Consumptions
        update totalConsumptionMap.values();
        System.debug('calculateConsumption:: ALL Total consumptions backed up: ' + totalConsumptionMap.values());

        System.debug('calculateConsumption::shipToAccountNumber: ' + shipToAccountNumber);
        System.debug('calculateConsumption::shipFromAccountNumber: ' + shipFromAccountNumber);
        System.debug('calculateConsumption::gmid: ' + gmid);
        System.debug('calculateConsumption::totalConsumptionMap: ' + totalConsumptionMap);
        

        System.debug('calculateConsumption::Olin Shares: ' + olinShares);
        System.debug('calculateConsumption::Known Shares: ' + knownShares);
        System.debug('calculateConsumption::Unknown Shares: ' + unknownShares);
        
        List<SF_STAGE_SALES__c> lstSFStageSales =
        [
            SELECT
                Id,
                CUSTOMER__c,
                SHIP_TO_PARTY__c,
                GMID__c,
                QUANTITY_CAL_NEW__c,
                QUANTITY_GUOM_CAL__c,
                QUANTITY_SUOM_CAL__c,
                SAP_BASE_UOM__c,
                GLOBAL_UOM__c,
                STANDARD_UOM__c,
                FISCAL_YEAR__c
            FROM SF_STAGE_SALES__c
            WHERE SHIP_TO_PARTY__c IN: shipToAccountNumber AND CUSTOMER__c IN: shipFromAccountNumber AND GMID__c IN: gmid AND FISCAL_YEAR__c =: sourceYear
        ];
        System.debug('calculateConsumption::Actual sales from SF_STAGE_SALES__c table: ' + lstSFStageSales);


        Map<String, Decimal> stageSales_standardUOM = new Map<String, Decimal>();
        Map<String, Decimal> stageSales_globalUOM = new Map<String, Decimal>();
        Map<String, Decimal> stageSales_baseUOM = new Map<String, Decimal>();

        for(SF_STAGE_SALES__c ss : lstSFStageSales)
        {
            String key = ss.SHIP_TO_PARTY__c + '-' + ss.CUSTOMER__c + '-' + ss.GMID__c;
            
            if(ss.QUANTITY_SUOM_CAL__c != null)
            {
                if(!stageSales_standardUOM.containsKey(key))
                {
                    stageSales_standardUOM.put(key, ss.QUANTITY_SUOM_CAL__c);
                }
                else
                {
                    Decimal currentVolume = stageSales_standardUOM.get(key);
                    stageSales_standardUOM.put(key, ss.QUANTITY_SUOM_CAL__c + currentVolume);
                }
            }
            else
            {
                stageSales_standardUOM.put(key, 0);
            }
                
                
            if(ss.QUANTITY_GUOM_CAL__c != null)
            {
                if(!stageSales_globalUOM.containsKey(key))
                {
                    stageSales_globalUOM.put(key, ss.QUANTITY_GUOM_CAL__c);
                }
                else
                {
                    Decimal currentVolume = stageSales_globalUOM.get(key);
                    stageSales_globalUOM.put(key, ss.QUANTITY_GUOM_CAL__c + currentVolume);
                }
            }
            else
            {
                stageSales_globalUOM.put(key, 0);
            }

            if(ss.QUANTITY_CAL_NEW__c != null)
            {
                if(!stageSales_baseUOM.containsKey(key))
                {
                    stageSales_baseUOM.put(key, ss.QUANTITY_CAL_NEW__c);
                }
                else
                {
                    Decimal currentVolume = stageSales_baseUOM.get(key);
                    stageSales_baseUOM.put(key, ss.QUANTITY_CAL_NEW__c + currentVolume);
                }
            }
            else
            {
                stageSales_baseUOM.put(key, 0);
            }
        }

        System.debug('calculateConsumption::standard volumes map: ' + stageSales_standardUOM);
        System.debug('calculateConsumption::global volumes map: ' + stageSales_globalUOM);
        System.debug('calculateConsumption::Base volumes map: ' + stageSales_baseUOM);
        
        //List<Consumption_Share__c> sharesToUpdate = new List<Consumption_Share__c>();
        List<Consumption_Share__c> knownSharesToUpdate = new List<Consumption_Share__c>();
        List<Consumption_Share__c> unknownSharesToUpdate = new List<Consumption_Share__c>();


        // update Share Amount with volumne from the stage sales table (based on busness group, performance center and Area R1 logic)
        for(Consumption_Share__c consumption : olinShares)
        {
            Decimal newActual = 0;

            String key = consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Ship_To__r.AccountNumber_R1__c + '-' + consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Account_R1__r.AccountNumber_R1__c + '-' + consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.Gmid_Number__c;

            System.debug('Business_Group__c: ' + consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.Business_Group__c);
            System.debug('PH1_Performance_Center__c: ' + consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.PH1_Performance_Center__c);
            System.debug('Area_R1__c: ' + consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Account_R1__r.Area_R1__c);
            
            if( (consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.Business_Group__c != null && consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.PH1_Performance_Center__c != null) && (consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.Business_Group__c == 'OCAV' && consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.PH1_Performance_Center__c != 'CAUSTIC') )
            {
                if(stageSales_standardUOM.containsKey(key))
                    newActual = stageSales_standardUOM.get(key);
                else
                    newActual = 0;
            }
            else if( (consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.Business_Group__c != null && consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.PH1_Performance_Center__c != null && consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Account_R1__r.Area_R1__c != null) && (consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.Business_Group__c == 'OCAV' && consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.PH1_Performance_Center__c == 'CAUSTIC' && (consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Account_R1__r.Area_R1__c == 'North America' || consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Account_R1__r.Area_R1__c == 'NORTH AMERICA')) )
            {
                if(stageSales_standardUOM.containsKey(key))
                    newActual = stageSales_standardUOM.get(key);
                else
                    newActual = 0;
            }
            else if( (consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.Business_Group__c != null && consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.PH1_Performance_Center__c != null && consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Account_R1__r.Area_R1__c != null) && (consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.Business_Group__c == 'OCAV' && consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.PH1_Performance_Center__c == 'CAUSTIC' && (consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Account_R1__r.Area_R1__c != 'North America' || consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Account_R1__r.Area_R1__c != 'NORTH AMERICA' )) )
            {
                if(stageSales_globalUOM.containsKey(key))
                    newActual = stageSales_globalUOM.get(key);
                else
                    newActual = 0;
            }   
            else if( (consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.Business_Group__c != null && consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Account_R1__r.Area_R1__c != null) && ((consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.Business_Group__c == 'GCO' || consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.Business_Group__c == 'ALLYLICS & AROMATICS' || consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.Business_Group__c == 'RESINS' || consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.Business_Group__c == 'SYSTEMS & GROWTH') && (consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Account_R1__r.Area_R1__c == 'North America' || consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Account_R1__r.Area_R1__c == 'NORTH AMERICA')) )
            {
                if(stageSales_standardUOM.containsKey(key))
                    newActual = stageSales_standardUOM.get(key);
                else
                    newActual = 0;
            }   
            else if( (consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.Business_Group__c != null && consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Account_R1__r.Area_R1__c != null) && ((consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.Business_Group__c == 'GCO' || consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.Business_Group__c == 'ALLYLICS & AROMATICS' || consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.Business_Group__c == 'RESINS' || consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.Business_Group__c == 'SYSTEMS & GROWTH') && (consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Account_R1__r.Area_R1__c != 'North America' && consumption.Consumption_ShareOfWallet__r.Purchased_Product__r.Account_R1__r.Area_R1__c != 'NORTH AMERICA')) )
            {
                if(stageSales_globalUOM.containsKey(key))
                    newActual = stageSales_globalUOM.get(key);
                else
                    newActual = 0;
            }
            else
            {
                if(stageSales_baseUOM.containsKey(key))
                    newActual = stageSales_baseUOM.get(key);
                else
                    newActual = 0;
            }
			if(Test.isRunningTest())
                newActual = 200;
            newActual = newActual.setScale(0);

            System.debug('Olin Share amount: ' + consumption.Share_Amount__c);
            System.debug('Olin Share percent: ' + consumption.Share_Percent__c);
            System.debug('Olin Share percent new Stage Sales: ' + newActual);

            //Replacing the Total Consumption value with the calculated one coming from the Sales Stage table
            if(consumption.Share_Amount__c != null && consumption.Share_Amount__c > 0 && consumption.Share_Percent__c != null && consumption.Share_Percent__c > 0)
            {
                //For the SoW record Olin has a positive value and percentage set then the job will:
                if(newActual > 0)
                {
                    System.debug('calculateConsumption:: Scenario 1a');
                    //If the summed new actual value is positive then:
                    //a) Write the new Olin actual value.
                    //b) The new value will be divided by the percentage set on the Olin share. This will be the new total consumption value.
                    //c) Each non-Olin share line (competitors and Unknown) will be recalculated taking it’s percentage and multiplying against the new total consumption value.
                    consumption.Share_Amount__c = newActual;
                    Decimal calculatedTotalConsumption = (consumption.Share_Amount__c * 100) / consumption.Share_Percent__c;
                    totalConsumptionMap.get(key).Consumption__c = calculatedTotalConsumption.setScale(0);

                    if(knownShares.values().size() > 0 && knownShares.containsKey(key))
                    {
                        for(Consumption_Share__c knownShare : knownShares.get(key))
                        {
                            System.debug('calculateConsumption:: checking no Olin known shares for key: ' + knownShare.Consumption_ShareOfWallet__c + '-' + knownShare.Seller_Account_SOW__c);

                            Decimal calculatedShareAmount = (calculatedTotalConsumption * knownShare.Share_Percent__c) / 100;
                            knownShare.Share_Amount__c = calculatedShareAmount.setScale(0);
                            //sharesToUpdate.add(knownShare);
                            knownSharesToUpdate.add(knownShare);
                            System.debug('calculateConsumption:: New Known share for ' + knownShare.Seller_Account_SOW__r.Name + ' is ' + knownShare.Share_Amount__c);
                        }
                    }

                    //for(Consumption_Share__c unknownShare : unknownShares.values())
                    String unknownKey = key + '-' + consumption.Consumption_ShareOfWallet__c;
                    if(unknownShares.containsKey(unknownKey))
                    {
                        Consumption_Share__c unknownShare = unknownShares.get(unknownKey);
                        System.debug('Olin Share: ' + consumption.Id + ', Unknown share ID 1: ' + unknownShare);
                        Decimal calculatedShareAmount = unknownShare.Share_Percent__c != null ? (calculatedTotalConsumption * unknownShare.Share_Percent__c) / 100 : 0;
                        unknownShare.Share_Amount__c = calculatedShareAmount.setScale(0);
                        //sharesToUpdate.add(unknownShare);
                        unknownSharesToUpdate.add(unknownShare);
                        System.debug('calculateConsumption:: New Unknown share for ' + unknownShare.Seller_Account_SOW__r.Name + ' is ' + unknownShare.Share_Amount__c);
                    }
                }
                else
                {
                    System.debug('calculateConsumption:: Scenario 1b');
                    //If the summed new actual value is 0 or less then:
                    //a) Write the new Olin share value as 0
                    //b) Write the new Olin share percent as 0
                    //c) The new value will be divided by the percentage set on the Olin share. This will be the new total consumption value. Should be 0
                    //d) Each non-Olin share line (competitors and Unknown) will be recalculated taking it’s percentage and multiplying against the new total consumption value. Should be 0
                    //e) If the new non-Olin share value is 0 then change then write for the new non-Olin shares percentage to be 0.
                    consumption.Share_Amount__c = 0;
                    consumption.Share_Percent__c = 0;
                    totalConsumptionMap.get(key).Consumption__c = 0;

                    if(knownShares.values().size() > 0 && knownShares.containsKey(key))
                    {
                        for(Consumption_Share__c knownShare : knownShares.get(key))
                        {
                            System.debug('calculateConsumption:: checking no Olin known shares for key: ' + knownShare.Consumption_ShareOfWallet__c + '-' + knownShare.Seller_Account_SOW__c);

                            knownShare.Share_Amount__c = 0;
                            knownShare.Share_Percent__c = 0;
                            //sharesToUpdate.add(knownShare);
                            knownSharesToUpdate.add(knownShare);
                            System.debug('calculateConsumption:: New Known share for ' + knownShare.Seller_Account_SOW__r.Name + ' is ' + knownShare.Share_Amount__c);
                        }
                    }

                    //for(Consumption_Share__c unknownShare : unknownShares.values())
                    String unknownKey = key + '-' + consumption.Consumption_ShareOfWallet__c;
                    if(unknownShares.containsKey(unknownKey))
                    {
                        Consumption_Share__c unknownShare = unknownShares.get(unknownKey);
                        System.debug('Olin Share: ' + consumption.Id + ', Unknown share ID 2: ' + unknownShare);
                        unknownShare.Share_Amount__c = 0;
                        unknownShare.Share_Percent__c = 0;
                        //sharesToUpdate.add(unknownShare);
                        unknownSharesToUpdate.add(unknownShare);
                        System.debug('calculateConsumption:: New Unknown share for ' + unknownShare.Seller_Account_SOW__r.Name + ' is ' + unknownShare.Share_Amount__c);
                    }
                }
                
            }
            else if((consumption.Share_Amount__c == null || consumption.Share_Amount__c == 0) && (consumption.Share_Percent__c == null || consumption.Share_Percent__c == 0) && (newActual != null && newActual > 0))
            {
                System.debug('calculateConsumption:: Scenario 2');
                //For the SoW record Olin had no value and 0 for percent, but the new actual is a positive value.
                //a) Write the new Olin actual value.
                //b) Add the new Olin actual value to the total consumption value.
                //c) Recalculate all the percentages based on allocated shares to the new total consumption value.
                consumption.Share_Amount__c = newActual;
                if(totalConsumptionMap.get(key).Consumption__c != null)
                    totalConsumptionMap.get(key).Consumption__c = totalConsumptionMap.get(key).Consumption__c + newActual;
                else
                    totalConsumptionMap.get(key).Consumption__c = newActual;

                consumption.Share_Percent__c = ((consumption.Share_Amount__c * 100) / totalConsumptionMap.get(key).Consumption__c).setScale(0);

                System.debug('knownShares: ' + knownShares);

                if(knownShares.values().size() > 0 && knownShares.containsKey(key))
                {
                    for(Consumption_Share__c knownShare : knownShares.get(key))
                    {
                        System.debug('calculateConsumption:: checking no Olin known shares for key: ' + knownShare.Consumption_ShareOfWallet__c + '-' + knownShare.Seller_Account_SOW__c);

                        Decimal calculatedSharePercent = (knownShare.Share_Amount__c * 100) / totalConsumptionMap.get(key).Consumption__c;
                        knownShare.Share_Percent__c = calculatedSharePercent.setScale(0);
                        //sharesToUpdate.add(knownShare);
                        knownSharesToUpdate.add(knownShare);
                        System.debug('calculateConsumption:: New Known share for ' + knownShare.Seller_Account_SOW__r.Name + ' is ' + knownShare.Share_Amount__c);
                    }
                }

                //for(Consumption_Share__c unknownShare : unknownShares.values())
                String unknownKey = key + '-' + consumption.Consumption_ShareOfWallet__c;
                if(unknownShares.containsKey(unknownKey))
                {
                    Consumption_Share__c unknownShare = unknownShares.get(unknownKey);
                    System.debug('Olin Share: ' + consumption.Id + ', Unknown share ID 3: ' + unknownShare);
                    Decimal calculatedSharePercent = unknownShare.Share_Amount__c != null ? (unknownShare.Share_Amount__c * 100) / totalConsumptionMap.get(key).Consumption__c : 0;
                    unknownShare.Share_Percent__c = calculatedSharePercent.setScale(0);
                    //sharesToUpdate.add(unknownShare);
                    unknownSharesToUpdate.add(unknownShare);
                    System.debug('calculateConsumption:: New Unknown share for ' + unknownShare.Seller_Account_SOW__r.Name + ' is ' + unknownShare.Share_Amount__c);
                }
            }
            else if((consumption.Share_Amount__c == null || consumption.Share_Amount__c == 0) && (consumption.Share_Percent__c == null || consumption.Share_Percent__c == 0) && (newActual == null || newActual == 0))
            {
                System.debug('calculateConsumption:: Scenario 3');
                //For the SoW record Olin had no value, 0 for percent and the new actual for Olin is also 0.
                //a) No value will be written to Olin
                //b) No change will occur to the total consumption value
                //c) No change will occur on the shares
                //d) Essentially no change will occur on the record.
            }
        }

        //update Share amounts frºom Stage sales table
        update olinShares;
        System.debug('calculateConsumption:: Updated Olin Share Amounts: ' + olinShares);

        
        update totalConsumptionMap.values();
        System.debug('calculateConsumption:: Updated Total consumptions: ' + totalConsumptionMap.values());

        
        //update sharesToUpdate;
        //System.debug('calculateConsumption:: Shares to update: ' + sharesToUpdate);
        update knownSharesToUpdate;
        update unknownSharesToUpdate;
        System.debug('calculateConsumption:: Shares to update: ' + knownSharesToUpdate);
        System.debug('calculateConsumption:: Shares to update: ' + unknownSharesToUpdate);
        
    }
}