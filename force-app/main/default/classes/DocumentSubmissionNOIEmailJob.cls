/**
 * Class Name  : DocumentSubmissionNOIEmailJob
 * Description : This batch job sends email notifications with the list of pending
 *               documents to applicant/co-applicant of the applications on the Document Submission Due Date
 * Author      : Financial Spectra
 *
 */
global with sharing class DocumentSubmissionNOIEmailJob extends fsCore.BatchQueryableBase implements Schedulable{
    private static final String CLASS_NAME = 'DocumentSubmissionNOIEmailJob';

    global DocumentSubmissionNOIEmailJob(){
        setJobQuery(getDefaultQuery());
    }

    private fsCore.DynamicQueryBuilder getQuery(){
        fsCore.DynamicQueryBuilder jobQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsCore__Lending_Application__c.getName())
                                                    .addField('Id')
                                                    .addField('Name')
                                                    .addField('RecordType.DeveloperName')
                                                    .addField('Loan_Officer__c')
                                                    .addField('Document_Submission_Due_Date__c')
                                                    .addField('Document_NOI_Sent_Date__c')
                                                    .addField('Loan_Type__c')
                                                    .addWhereConditionWithValue(1, 'fsCore__Is_Application_Read_Only__c', '=',false)
                                                    .addWhereConditionWithValue(2, 'Pending_Document_Checklist_Count__c', '>', 0)
                                                    .addWhereConditionWithValue(3, 'Document_Submission_Due_Date__c ', '<=', System.today());
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
        notifyAction.setNotificationType(ApplicationNotificationUtil.DOCUMENT_SUBMISSION_NOI);
        notifyAction.process();
        
        return notifyAction.getOutput().getErrors();
    }
    
    global override void finishJob(Database.BatchableContext pContext){}

    global void execute(SchedulableContext SC) {
        fsCore.BatchJobObject bJobObj = fsCore.BatchJobUtil.getBatchJobRecord('Document_Submission_NOI_Email');
        Id jobId = fsCore.BatchJobUtil.submitBatchJob(bJobObj);
    }    

}