/**
 * Class Name  : VCLWelcomeLetterEmailJob
 * Description : This batch job sends Welcome Letter email notifications
 *               to the borrowers for VCL
 * Author      : Financial Spectra
 *
 */
global with sharing class VCLWelcomeLetterEmailJob extends fsCore.BatchQueryableBase implements Schedulable{
    private static final String CLASS_NAME = 'VCLWelcomeLetterEmailJob';

    global VCLWelcomeLetterEmailJob(){
        setJobQuery(getDefaultQuery());
    }

    private fsCore.DynamicQueryBuilder getQuery(){
        fsCore.DynamicQueryBuilder jobQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Lending_Application__c.getName())
                                                  .addField('Id')
                                                  .addField('Name')
                                                  .addField('Loan_Officer__c')
                                                  .addField('Loan_Type__c')
                                                  .addField('RecordType.DeveloperName')
                                                  .addField('Welcome_Letter_Sent_Date__c')
                                                  .addWhereConditionWithValue(1, 'fsCore__Is_Application_Read_Only__c', '=',false)
                                                  .addWhereConditionWithValue(2, 'Loan_Type__c', '=', 'VCL')
                                                  .addWhereConditionWithValue(3, 'Is_Withdraw_Requested__c', '=', false)
                                                  .addWhereConditionWithValue(4, 'fsCore__Accepted_Pricing_Offer_Number__c', '!=', null)
                                                  .addWhereConditionWithValue(5, 'Welcome_Letter_Sent_Date__c', '=', null);


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
        notifyAction.setNotificationType(ApplicationNotificationUtil.VCL_WELCOME_LETTER);
        notifyAction.process();
        
        return notifyAction.getOutput().getErrors();

    }
    
    global override void finishJob(Database.BatchableContext pContext){}

    global void execute(SchedulableContext SC) {
        fsCore.BatchJobObject bJobObj = fsCore.BatchJobUtil.getBatchJobRecord('VCL_Welcome_Letter_Email');
        Id jobId = fsCore.BatchJobUtil.submitBatchJob(bJobObj);
    }    

}