/**
 * Class Name  : EmailNotificationLogPurgeJob
 * Description : This batch job purges the records in Email Notification Log objects
 * Author      : Financial Spectra
 */
global with sharing class EmailNotificationLogPurgeJob extends fsCore.BatchQueryableBase implements Schedulable{
    private static final String CLASS_NAME = 'EmailNotificationLogPurgeJob';
    
    global EmailNotificationLogPurgeJob(){
        setJobQuery(getDefaultQuery()); // this will set the query without branch code parameter
    }

    global EmailNotificationLogPurgeJob(Integer purgeDays){
        setJobQuery(getDefaultQuery(purgeDays)); // this will set the query without branch code parameter
    }    

    global override void setParameterizedJobQuery(){
        // this will set the query with branch code parameter, if branch code is set
        setJobQuery(getDefaultQuery());
    }

    private String getDefaultQuery(){
        Integer purgeDays = fsCore.DataPurgeSettingsUtil.getPurgeDays(Schema.SObjectType.Email_Notification_Log__c.getName());
        return getDefaultQuery(purgeDays);
    }
    
    private String getDefaultQuery(Integer purgeDays){
        Date purgeFromDate = Date.today().addDays(-1 * purgeDays);
        
        fsCore.DynamicQueryBuilder jobQuery = 
                        fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.Email_Notification_Log__c.getName())
                                          .addField('Id')
                                          .addWhereConditionWithValue(1,'Record_Creation_Date__c','<=',purgeFromDate);
        return jobQuery.getQueryString();
    }    

    // Schedule Job  
    global void execute(SchedulableContext SC) {
        fsCore.BatchJobObject bJobObj = fsCore.BatchJobUtil.getBatchJobRecord('Purge_Email_Notification_Logs');
        Id jobId = fsCore.BatchJobUtil.submitBatchJob(bJobObj);
    }

    global override String getClassName(){
        return CLASS_NAME;
    }

    global override void startJob(Database.BatchableContext pContext){}

    global override List<fsCore.ErrorObject> executeJob(Database.BatchableContext pContext, List<sObject> pScope) {
        System.debug('Executing Job ' + CLASS_NAME + '...');
        System.debug('Scope Count : ' + pScope.size());
        
        Database.delete(pScope);
        return null;
    }

    global override void finishJob(Database.BatchableContext pContext) {}

}