global class DuplicateConsumptionRecordsBatch implements Database.Batchable<sObject>
{
    global final Consumption_Year__mdt customMetadataType =
    [
        SELECT
            Id,
            DeveloperName,
            MasterLabel,
            Share_of_Wallet_Duplicate_Date__c,
            Share_of_Wallet_Close_Out_Date__c,
            Year__c,
            Purchased_Product_ID_for_testing__c
        FROM Consumption_Year__mdt
        WHERE DeveloperName = 'Test_Batch_Job'
        LIMIT 1
    ];
    
    global final String query = 'SELECT ' +
        'Id,' +
        'Product__c,' +
        'Ship_To__c,' +
        'Year__c,' +
        'Consumption__c,' +
        'Purchased_Product__c,' +
        	'(SELECT ' + 
                'Id,' +
                'Consumption_ShareOfWallet__c,' +
                'Seller_Account_SOW__c,' +
                'Share_Amount__c,' +
                'Share_Percent__c,' +
                'Contact_Expiration_Date__c ' +
        	'FROM Share_Of_Wallets__r) ' +
        'FROM Total_Consumption__c ' +
        'WHERE Year__c =: sourceYearStr ' +
        (customMetadataType.Purchased_Product_ID_for_testing__c != null ? 'AND Id = \'' + customMetadataType.Purchased_Product_ID_for_testing__c + '\'' : '');
        
    private Integer sourceYear;
    private String sourceYearStr;
    private Integer destinationYear;
    private String destinationYearStr;
    
    //Constructor with no parameters
    public DuplicateConsumptionRecordsBatch()
    {
        sourceYear = System.today().year() - 1;
        sourceYearStr = string.valueOf(sourceYear);
        destinationYear = System.today().year();
        destinationYearStr = string.valueOf(destinationYear);
        
        system.debug('DuplicateConsumptionRecordsBatch:: QUERY with no parameters -- ' + query);
    }

    //Constructor with 2 parameters for sourceYear and destinationYear
    public DuplicateConsumptionRecordsBatch(Integer pSourceYear, Integer pDestinationYear)
    {
        sourceYear = pSourceYear;
        sourceYearStr = string.valueOf(sourceYear);
        destinationYear = pDestinationYear;
        destinationYearStr = string.valueOf(destinationYear);

        system.debug('DuplicateConsumptionRecordsBatch:: QUERY with Source and Destination years -- ' + query);
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        system.debug('DuplicateConsumptionRecordsBatch::QUERY results on Start method -- ' + Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Total_Consumption__c> scope)
    {
        system.debug('DuplicateConsumptionRecordsBatch::EXECUTE -- ' + scope);
        DuplicateConsumptionRecordsApex.duplicateConsumption(scope, sourceYearStr, destinationYearStr);
    }
    
    global void finish(Database.BatchableContext BC)
    {
        //Nothing yet
    }
}