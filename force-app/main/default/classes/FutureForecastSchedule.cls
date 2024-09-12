global class FutureForecastSchedule implements Schedulable{
    
     global void execute(SchedulableContext SC) {
		FutureForecastBatch b = new FutureForecastBatch();
        Database.executeBatch(b, 200);
   }

}