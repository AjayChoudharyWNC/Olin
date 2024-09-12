public class SimplusFormulaJob implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts, Database.Stateful{
    public List<SBQQ__Quote__c> quotes;
	public Integer batchSize;
	public String jobName;
	public Boolean abortAfterRun;
	
	/*
    On demand scheduled job from Quote
	SimplusFormulaJob batchedJob = new SimplusFormulaJob(SBQQ__Quote__c quote, Integer batchSize);
	String sch = '0 35 0/1 1/1 * ? *';
	String jobID = system.schedule('Job Scheduling', sch, batchedJob);
	*/	
	public SimplusFormulaJob(String jobName, SBQQ__Quote__c quote, Integer batchSize){
        this.quotes = new List<SBQQ__Quote__c>();
        this.quotes.add(quote);
		this.batchSize = batchSize;
		this.jobName = jobName;
		this.abortAfterRun = true;
	}

	/*
    Scheduled job constructor
	SimplusFormulaJob batchedJob = new SimplusFormulaJob(Integer batchSize);
	String sch = '0 35 0/1 1/1 * ? *';
	String jobID = system.schedule('Job Scheduling', sch, batchedJob);
	*/	
	public SimplusFormulaJob(Integer batchSize){
        this.quotes = new List<SBQQ__Quote__c>();
		this.batchSize = batchSize;
		this.abortAfterRun = false;
	}

	/*
    Constructor for use when called by Database.executeBatch()
	SimplusFormulaJob batchedJob = new SimplusFormulaJob();
	String sch = '0 35 0/1 1/1 * ? *';
	String jobID = system.schedule('Job Scheduling', sch, batchedJob);
	*/	
	public SimplusFormulaJob(){
        this.quotes = new List<SBQQ__Quote__c>();
		this.abortAfterRun = false;
	}

	/** * * * * * * * * * * * *
	*  Method Name:   start
	*  Purpose:       This method is used to pull all of the Formulas associated with the Quote and process those formulas for each quote line
	*  Company:       Simplus
	*  Created Date:  1-4-2017
	*  Type:          Method
	** * * * * * * * * * * * */
	public Database.QueryLocator start(Database.BatchableContext BC){
        //Query all the formulas that need to be run for all quotes and pass them in a collection to the batchable job.
		
		String queryString = 'SELECT Id, (SELECT Id, Formula_Result__c, Formula_Name__c FROM SBQQ__LineItems__r WHERE Formula_Name__c != null) FROM SBQQ__Quote__c';
		if(this.quotes != null && !this.quotes.isEmpty()) {
			queryString += ' WHERE Id IN: quotes AND SBQQ__LineItemCount__c > 0';
		} else {
			queryString += ' WHERE SBQQ__LineItemCount__c > 0';
		}
		system.debug('Query Result: ' + queryString);
		return Database.getQueryLocator(queryString);
	}
	
	/** * * * * * * * * * * * *
	*  Method Name:   execute
	*  Purpose:       This method is used to process all the qualifying Formulas
	*  Company:       Simplus
	*  Created Date:  1-4-2017
	*  Type:          Method
	** * * * * * * * * * * * */
	public void execute(Database.BatchableContext BC, List<SBQQ__Quote__c> targets){
		try {
			//Select all the formulas associated with each quote line for the quotes associated with this job and process those formulas
			//For each over all the formulas that will be processed and process those based on the quote lines they are associated with
			
			Set<String> quoteLineIds = new Set<String>();
			for(SBQQ__Quote__c result : targets) {
				if(result.SBQQ__LineItems__r != null && !result.SBQQ__LineItems__r.isEmpty()) {
					for(SBQQ__QuoteLine__c quoteLine : result.SBQQ__LineItems__r) {
						if(quoteLine.Formula_Name__c != null) {
							quoteLineIds.add(quoteLine.Id);
						}
					}
				}
			}
			processResult(quoteLineIds);
    	} catch (Exception ex) {
    		System.debug('Error: ' + ex);
    	} finally {
			if (this.abortAfterRun)    		
    			SimplusFormulaJobHelper.abortPreviousJobs(this.jobName);
    	}
	}
	
	public void finish(Database.BatchableContext BC){
		
	}

	/** * * * * * * * * * * * *
	*  Method Name:   execute
	*  Purpose:       This method is used to schedule the batch job.
	*  Company:       Simplus
	*  Created Date:  1-4-2017
	*  Type:          Method
	** * * * * * * * * * * * */
	public void execute(SchedulableContext sc){
		System.debug('execute (scheduled) called in SimplusFormulaJob');
		Database.executeBatch(new SimplusFormulaJob(), this.batchSize);
	}

	/* 
	Copied the method from SimplusFormulaController because @AuraEnabled methods can't support Set as parameter, a lightning component is calling it.
	Used Set as parameter to bulkify.
	*/
	public static void processResult(Set<String> recordId) {
        System.debug('Starting Job Process Result for record: ' + recordId);
        SimplusFormulaController.FormulaSettings setting = new SimplusFormulaController.FormulaSettings('Settings');   
        String query = 'SELECT Id, ' + setting.resultColumn + ', ' + setting.lookupColumn + ', ' + setting.lookupRelated + '.Implementation__c FROM ' + setting.connectedObject + ' WHERE Id IN: recordId ';
        System.debug('Formula process query in job: ' + query);
		List<SObject> ss = Database.query(query);
		System.debug('Query Results: ' + JSON.serialize(ss));
		List<SObject> lstSobject = new List<SObject>();
		for(SObject result : ss) {
			String id = (String)result.get('Id');
			SObject so = result.getSObject(setting.lookupRelated);
			String implementation = (String)so.get('Implementation__c');
			if (implementation != null) {
				String process = SimplusFormulaController.Process(implementation, id);
				result.put(setting.resultColumn, Double.valueof(process));
				lstSobject.add(result);
				system.debug('Result: ' + process);
			}
		}
		update lstSobject;
    }
}