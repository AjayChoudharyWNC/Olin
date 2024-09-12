global class DuplicateConsumptionRecordsSched implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        List<Consumption_Year__mdt> lstCustomMetadataType =
        [
            SELECT
                Id,
                DeveloperName,
                MasterLabel,
                Share_of_Wallet_Duplicate_Date__c,
                Share_of_Wallet_Close_Out_Date__c,
                Year__c 
            FROM Consumption_Year__mdt
            WHERE DeveloperName = 'Test_Batch_Job'
        ];

        for(Consumption_Year__mdt scheduleBatch : lstCustomMetadataType)
        {
            System.debug('Schedule: ' + scheduleBatch.Share_of_Wallet_Duplicate_Date__c + ' =? ' + date.today());

            /*
            if(scheduleBatch.Share_of_Wallet_Duplicate_Date__c == date.today() || test.isRunningTest())
            {
                DuplicateConsumptionRecordsBatch b = new DuplicateConsumptionRecordsBatch();
                database.executebatch(b,200);
            }
            */


            if(
                /*
                * 11/09/2020: Jose Aguilar Tlaseca: Changed logic to only use the day and month values from the Custom metadata type and ignore the year.
                * This way the "Consumption Year" metadata type does not need to be updated every year.
                * It will always try to run on the month/day defined at the Share_of_Wallet_Duplicate_Date__c field
                * Logic: If today's date is the one defined at the Share_of_Wallet_Duplicate_Date__c in day and month
                */
                (scheduleBatch.Share_of_Wallet_Duplicate_Date__c.day() == date.today().day() && scheduleBatch.Share_of_Wallet_Duplicate_Date__c.month() == date.today().month())
                || test.isRunningTest()
            )
            {
                DuplicateConsumptionRecordsBatch b = new DuplicateConsumptionRecordsBatch();
                database.executebatch(b,200);
            }
        }
    }
}