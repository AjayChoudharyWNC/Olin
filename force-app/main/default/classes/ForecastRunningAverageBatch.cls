public class ForecastRunningAverageBatch implements Database.Batchable<sObject> {
    public Integer yearToRun;
    public Integer monthToRun;
    
    public ForecastRunningAverageBatch(Integer y, Integer m) {
        this.yearToRun = y;
        this.monthToRun = m;
    }
    public ForecastRunningAverageBatch() {
        this.yearToRun = Date.today().year();
        this.monthToRun = Date.today().month();
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, ForecastFindKey__c FROM Forecast__c WHERE Year__c = ' + yearToRun;
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Forecast__c> scope) {
        Integer prevYear = yearToRun - 1;
        Integer nextYear = yearToRun + 1;
        Set<String> findKeys = new Set<String>();
        for(Forecast__c f : scope) {
            findKeys.add(f.ForecastFindKey__c + yearToRun);
            findKeys.add(f.ForecastFindKey__c + prevYear);
            findKeys.add(f.ForecastFindKey__c + nextYear);
        }
        
        Map<String, Decimal> totalPerFindKeyPerYearMonth = new Map<String, Decimal>();
        for(SF_STAGE_SALES__c sale : [SELECT Id, ForecastFindKey__c, YEAR_MONTH__c, VOLUME_ACTUAL_UL__c FROM SF_STAGE_SALES__c WHERE ForecastFindKey__c IN :findKeys AND (YEAR__c = :yearToRun OR YEAR__c = :prevYear OR YEAR__c = :nextYear)]) {
            String s = sale.ForecastFindKey__c + '|' + sale.YEAR_MONTH__c;
            if(!totalPerFindKeyPerYearMonth.containsKey(s)) {
                totalPerFindKeyPerYearMonth.put(s, 0);
            }
            totalPerFindKeyPerYearMonth.put(s, totalPerFindKeyPerYearMonth.get(s) + sale.VOLUME_ACTUAL_UL__c);
        }
        
        for(Forecast__c f : scope) {
            Integer runMonth = monthToRun;
            Integer iteration = 0;
            
            
            while(runMonth < 13) {
                
                String s = f.ForecastFindKey__c + yearToRun;
                String sPrev = f.ForecastFindKey__c + (yearToRun-1);
                Integer year = yearToRun;
                Integer month = runMonth;
                String fieldToUpdateAve = 'SixMonthRunningAverage_' + month + '__c';
                String fieldToUpdatePrior = 'PriorActuals_M' + month + '__c';
                String fieldToUpdateCurrent = 'CurrentActuals_M' + month + '__c';
                
                
                String findPrior = sPrev + '|' + (month < 10 ? '0' + month : ''+month) + '/' + (year - 1);
                String findCurrent = s + '|' + (month < 10 ? '0' + month : ''+month) + '/' + (year);
                
                if(totalPerFindKeyPerYearMonth.containsKey(findPrior )) {
                    f.put(fieldToUpdatePrior, totalPerFindKeyPerYearMonth.get(findPrior));
                    f.put(fieldToUpdateCurrent, totalPerFindKeyPerYearMonth.get(findCurrent));
                }
                
                month -= 1;
                if(month == 0) {
                    year -= 1;
                    month = 12;
                }
                
                Decimal total = 0;
                for(Integer monthly = 6; monthly > 0; monthly -= 1) {
                    if(totalPerFindKeyPerYearMonth.containsKey(s + '|' + (month < 10 ? '0' + month : ''+month) + '/' + year)) {
                        Decimal d = totalPerFindKeyPerYearMonth.get(s + '|' + (month < 10 ? '0' + month : ''+month) + '/' + year);
                        total += d;
                    }
                    
                    month -= 1;
                    if(month == 0) {
                        year -= 1;
                        month = 12;
                    }
                }
                
                f.put(fieldToUpdateAve, total / 6);
                runMonth += 1;
                iteration += 1;
                if(iteration == 50) break;
            }
        }
        update scope;
        
    }

    public void finish(Database.BatchableContext BC) {
    
    
    }
}