global class CalculateConsumptionRecordsBatch implements Database.Batchable<sObject>
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
            'Share_Amount__c,' +
            'Share_Percent__c,' +
            'Seller_Account_SOW__c,' +
            'Seller_Account_SOW__r.Name,' +
            'Seller_Account_SOW__r.RecordType.Name,' +
            'Consumption_ShareOfWallet__c,' +
            'Consumption_ShareOfWallet__r.Name,' +
            'Consumption_ShareOfWallet__r.Year__c,' +
            'Consumption_ShareOfWallet__r.Consumption__c,' +
            'Consumption_ShareOfWallet__r.Purchased_Product__c,' +
            'Consumption_ShareOfWallet__r.Purchased_Product__r.Ship_To__c,' +
            'Consumption_ShareOfWallet__r.Purchased_Product__r.Account_R1__c,' +
            'Consumption_ShareOfWallet__r.Purchased_Product__r.Ship_To__r.AccountNumber_R1__c,' +
            'Consumption_ShareOfWallet__r.Purchased_Product__r.Ship_From__r.AccountNumber_R1__c,' +
            'Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__c,' +
            'Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.TradeProduct_R1__c,' +
            'Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.Gmid_Number__c,' +
            'Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.Business_Group__c,' +
            'Consumption_ShareOfWallet__r.Purchased_Product__r.Product_R1__r.PH1_Performance_Center__c,' +
            'Consumption_ShareOfWallet__r.Purchased_Product__r.Account_R1__r.Area_R1__c,' +
            'Consumption_ShareOfWallet__r.Purchased_Product__r.Account_R1__r.AccountNumber_R1__c ' + 
        'FROM Consumption_Share__c ' +
        'WHERE ' + 
            'Consumption_ShareOfWallet__r.Year__c =: destinationYearStr ' +
            'AND Consumption_ShareOfWallet__r.Purchased_Product__r.Account_RecordTypeDesc__c = \'Customer\' ' +
            (customMetadataType.Purchased_Product_ID_for_testing__c != null ? 'AND Consumption_ShareOfWallet__r.Purchased_Product__c = \'' + customMetadataType.Purchased_Product_ID_for_testing__c + '\'' : '');



    private Integer sourceYear;
    private String sourceYearStr;
    private Integer destinationYear;
    private String destinationYearStr;

    //Constructor with no parameters
    public CalculateConsumptionRecordsBatch()
    {
        sourceYear = System.today().year();
        sourceYearStr = string.valueOf(sourceYear);
        destinationYear = sourceYear;
        destinationYearStr = string.valueOf(destinationYear);
        
        system.debug('QUERY with no parameters -- ' + query);
    }

    //Constructor with 2 parameters for sourceYear and destinationYear
    public CalculateConsumptionRecordsBatch(Integer pSourceYear, Integer pDestinationYear)
    {
        sourceYear = pSourceYear;
        sourceYearStr = string.valueOf(sourceYear);
        destinationYear = pDestinationYear;
        destinationYearStr = string.valueOf(destinationYear);

        system.debug('QUERY with Source and Destination years -- ' + query);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //system.debug('QUERY results on Start method -- ' + Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Consumption_Share__c> scope)
    {
        system.debug('EXECUTE -- ' + scope);
        CalculateConsumptionRecordsApex.calculateConsumption(scope, sourceYearStr, destinationYearStr);
    }
    
    global void finish(Database.BatchableContext BC)
    {
        //Nothing yet
    }
}