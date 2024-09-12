public with sharing class SimplusFormulaJobHelper {
    private static final String JobName = 'SimplusFormula_';
	private boolean m_isExecuting = false;
	private static Decimal jobDelay;
    private static Integer batchSize;
    	
	//Static run variable
	private static boolean run = true;
	public static boolean runOnce(){
		if(run){
			run=false;
			return true;
		}else{
			return run;
		}
	}

	//Constructor
	public SimplusFormulaJobHelper(boolean isExecuting){
		System.debug('Trigger Fired');
		m_isExecuting = isExecuting;
		SimplusFormulaController.FormulaSettings setting = new SimplusFormulaController.FormulaSettings('Settings');
		jobDelay = setting.jobDelay;
		batchSize = Integer.valueOf(setting.batchSize);
	}
	
	@AuraEnabled
	public static void RunFormula(String quote){
		System.debug('Record ID: ' + quote);
		SimplusFormulaController.FormulaSettings setting = new SimplusFormulaController.FormulaSettings('Settings');
		jobDelay = setting.jobDelay;
		batchSize = Integer.valueOf(setting.batchSize);

		if (jobDelay == null || batchSize == null) {
			System.debug('Settings for job delay and batch size must be set in Custom Metadata: Simplus_Formula_Settings__mdt');
			return;
		}
		
        //Process all the formulas for the selected Quote.
		List<SBQQ__Quote__c> lstQuote = [SELECT Id FROM SBQQ__Quote__c WHERE Id =: quote];
        String jobName = getJobName(quote);
        SimplusFormulaJob job = new SimplusFormulaJob(quote, lstQuote[0], batchSize);
        String cronString = getJobCronString(jobDelay);  //1 minute
        abortPreviousJobs(quote);
        System.debug('Cleaning up process: ' + jobName);
        //String jobId = System.schedule(jobName, cronString, job);
		Database.executeBatch(job, batchSize);
	}
		
	public void RunFormulas(){
		if (jobDelay == null || batchSize == null) {
			System.debug('Settings for job delay and batch size must be set in Custom Metadata: Simplus_Formula_Settings__mdt');
			return;
		}
		
        //Daily job
        String jobName = getJobName('Daily');
        SimplusFormulaJob job = new SimplusFormulaJob(batchSize);
        String cronString = getJobCronString(jobDelay);  //1 minute
        abortPreviousJobs('Daily');
        System.debug('Cleaning up process: ' + jobName);
        String jobId = System.schedule(jobName, cronString, job);
	}
		
    public static String getJobName(String id) {
		return JobName + ';' + id + ';' + String.valueOf(DateTime.now());
	}
	
	public static String getJobCronString(Decimal minutesUntilJobStarts) {
        Integer secondsBetweenJobs = Math.round(minutesUntilJobStarts * 60);

        DateTime currentDateTime = System.now();
        DateTime dateTimeForNextJob = currentDateTime.addSeconds(secondsBetweenJobs);
        
        // 'Seconds + Minutes + Hours + Day_of_month + Month + Day_of_week + Optional_year'
        // String cronString = '0 15 20 8 10 ?';
        Integer seconds = dateTimeForNextJob.second();
        Integer minutes = dateTimeForNextJob.minute();
        Integer hours = dateTimeForNextJob.hour();
        Integer dayOfMonth = dateTimeForNextJob.day();
        Integer month = dateTimeForNextJob.month();
        return seconds + ' ' + minutes + ' ' + hours + ' ' + dayOfMonth + ' ' + month + ' ?';
    }
    
    public static void abortPreviousJobs(String id) {
    	//SELECT Id, State, NextFireTime, CronJobDetailId FROM CronTrigger WHERE CronJobDetailId IN (SELECT Id FROM CronJobDetail WHERE Name LIKE 'OPPJob;%')    	
		String name = JobName + ';' + id + ';%';
        List<CronTrigger> cronTriggers = [SELECT Id, State, NextFireTime, CronJobDetailId FROM CronTrigger WHERE CronJobDetailId IN (SELECT Id FROM CronJobDetail WHERE Name LIKE :name)];
        if (cronTriggers.size() == 0) return;
        
        for(CronTrigger ct : cronTriggers) {
            System.debug('Cleaning up job....');
            System.abortJob(ct.Id);
        }
    }
}