/**
 * Class Name  : PreTILANOIEmailJob
 * Description : This batch job sends email notifications to the applicant/co-applicant of 
 *               the applications that have not signed the Pre TILA till Pre-TILA Due Date
 * Author      : Financial Spectra
 *
 */
global with sharing class PreTILANOIEmailJob extends fsCore.BatchQueryableBase implements Schedulable{
    private static final String CLASS_NAME = 'PreTILANOIEmailJob';

    global PreTILANOIEmailJob(){
        setJobQuery(getDefaultQuery());
    }

    private fsCore.DynamicQueryBuilder getQuery(){
        fsCore.DynamicQueryBuilder jobQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Lending_Application__c.getName())
                                                    .addField('Id')
                                                    .addField('Name')
                                                    .addField('RecordType.DeveloperName')
                                                    .addField('Loan_Officer__c')
                                                    .addField('Pre_TILA_Sent_Date__c')
                                                    .addField('Pre_TILA_Sign_Due_Date__c')
                                                    .addField('Pre_Tila_NOI_Sent_Date__c')
                                                    .addField('Loan_Type__c')
                                                    .addWhereConditionWithValue(1, 'RecordType.DeveloperName', '!=', fsCore.Constants.RECORD_TYPE_INACTIVE)
                                                    .addWhereConditionWithValue(2, 'Pre_TILA_Sent_Date__c ', '!=', null)
                                                    .addWhereConditionWithValue(3, 'Is_PreTILA_Signed__c', '=', false)
                                                    .addWhereConditionWithValue(4, 'Pre_TILA_Sign_Due_Date__c', '<=', System.today());
        return jobQuery;
    }        

    private String getDefaultQuery(){
        fsCore.DynamicQueryBuilder jobQuery = getQuery();
        return jobQuery.getQueryString();
    }

    global override void setParameterizedJobQuery(){
        fsCore.DynamicQueryBuilder jobQuery = getQuery();
        setJobQuery(jobQuery.getQueryString());
    }

    global override String getClassName(){
        return CLASS_NAME;
    }
    
    global override void startJob(Database.BatchableContext pContext){}

    global override List<fsCore.ErrorObject> executeJob(Database.BatchableContext pContext, List<sObject> pScope) {
        System.debug(loggingLevel.DEBUG, 'Executing Job ' + CLASS_NAME + '...');
        System.debug(loggingLevel.DEBUG, 'Scope Count : ' + pScope.size());
        
        if (pScope.size() == 0){ return null; }
        
        Map<Id, fsCore__Lending_Application__c> applicationMap = new Map<Id, fsCore__Lending_Application__c>();
        for (fsCore__Lending_Application__c app : (List<fsCore__Lending_Application__c>)pScope){
            applicationMap.put(app.Id, app);
        }
        
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(applicationMap.keySet());
        
        ApplicationNotificationAction notifyAction = new ApplicationNotificationAction();
        notifyAction.setInput(acInput);
        notifyAction.setApplicationMap(applicationMap);
        notifyAction.setNotificationType(ApplicationNotificationUtil.PRE_TILA_NOI);
        notifyAction.process();
        
        return notifyAction.getOutput().getErrors();
    }
    
    global override void finishJob(Database.BatchableContext pContext){}

    global void execute(SchedulableContext SC) {
        fsCore.BatchJobObject bJobObj = fsCore.BatchJobUtil.getBatchJobRecord('Pre_TILA_NOI_Email');
        Id jobId = fsCore.BatchJobUtil.submitBatchJob(bJobObj);
    }    

}