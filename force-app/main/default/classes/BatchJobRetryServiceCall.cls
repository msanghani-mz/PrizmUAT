global class BatchJobRetryServiceCall implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id,Retry_Batch__c FROM fsCore__Lending_Application__c WHERE Retry_Batch__c = true';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<fsCore__Lending_Application__c > lendingApp)
    { 
        Set<ID> appIds = new Set<ID>();
        
        for(fsCore__Lending_Application__c app : lendingApp)
        {
            appIds.add(app.Id);
           
        }
        InitiateLobQueueable obj = new InitiateLobQueueable(appIds);
            ID jobID = System.enqueueJob(obj);
    }   
    global void finish(Database.BatchableContext BC)
    {
    }
    
}