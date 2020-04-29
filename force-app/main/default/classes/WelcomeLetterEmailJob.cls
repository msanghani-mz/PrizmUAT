/**
 * Class Name  : WelcomeLetterEmailJob
 * Description : This batch job sends Welcome Letter email notifications
 *               to the borrowers
 * Author      : Financial Spectra
 *
 */
global with sharing class WelcomeLetterEmailJob extends fsCore.BatchQueryableBase implements Schedulable{
    private static final String CLASS_NAME = 'WelcomeLetterEmailJob';

    global WelcomeLetterEmailJob(){
        setJobQuery(getDefaultQuery());
    }

    private fsCore.DynamicQueryBuilder getQuery(){
        fsCore.DynamicQueryBuilder jobQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Lending_Application__c.getName())
                                                  .addField('Id')
                                                  .addField('Name')
                                                  .addField('Loan_Officer__c')
                                                  .addField('Loan_Type__c')
                                                  .addField('RecordType.DeveloperName')
                                                  .addWhereConditionWithValue(1, 'fsCore__Is_Application_Read_Only__c', '=',true)
                                                  .addWhereConditionWithValue(2, 'fsCore__Is_Funded__c', '=', true)
                                                  .addWhereConditionWithValue(3, 'fsServ__Is_Contracted__c', '=', true)
                                                  .addWhereConditionWithValue(4, 'Welcome_Letter_Sent_Date__c', '=', null);
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
        
        /*if (pScope.size() == 0){ return null; }
        
        Map<Id, fsCore__Lending_Application__c> applicationMap = new Map<Id, fsCore__Lending_Application__c>();
        for (fsCore__Lending_Application__c app : (List<fsCore__Lending_Application__c>)pScope){
            applicationMap.put(app.Id, app);
        }
        
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(applicationMap.keySet());
        
        ApplicationNotificationAction notifyAction = new ApplicationNotificationAction();
        notifyAction.setInput(acInput);
        notifyAction.setApplicationMap(applicationMap);
        notifyAction.setNotificationType(ApplicationNotificationUtil.WELCOME_LETTER);
        notifyAction.process();
        
        return notifyAction.getOutput().getErrors();*/

        return new List<fsCore.ErrorObject>();
    }
    
    global override void finishJob(Database.BatchableContext pContext){}

    global void execute(SchedulableContext SC) {
        /*fsCore.BatchJobObject bJobObj = fsCore.BatchJobUtil.getBatchJobRecord('Welcome_Letter_Email');
        Id jobId = fsCore.BatchJobUtil.submitBatchJob(bJobObj);*/
    }    

}