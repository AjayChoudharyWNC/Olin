global class ForecastRunningAverageSched implements Schedulable {
    global void execute(SchedulableContext sc){
        ForecastRunningAverageBatch b = new ForecastRunningAverageBatch();
        Database.executebatch(b,200);
    }
}