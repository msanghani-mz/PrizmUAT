/**
 * Class Name  : PaymentDueReminderEmailJob
 * Description : This batch job sends Payment Due Reminder email
 *               to the borrowers
 * Author      : Financial Spectra
 *
 */
global with sharing class PaymentDueReminderEmailJob extends fsCore.BatchQueryableBase implements Schedulable{
    private static final String CLASS_NAME = 'PaymentDueReminderEmailJob';

    global PaymentDueReminderEmailJob(){
        setJobQuery(getDefaultQuery());
    }

    private fsCore.DynamicQueryBuilder getQuery(){
        fsCore.DynamicQueryBuilder jobQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsServ__Contract_Due__c.getName())
                                                  .addField('Id')
                                                  .addWhereConditionWithValue(1, 'fsServ__Lending_Contract_Number__r.fsServ__Is_Active__c', '=', true)
                                                  .addWhereConditionWithValue(2, 'Is_Due_Reminder_Email_Sent__c', '=', false);
        return jobQuery;
    }        

    private String getDefaultQuery(){
        fsCore.DynamicQueryBuilder jobQuery = getQuery();
        jobQuery.addWhereConditionWithValue(3, 'fsServ__Transaction_Date__c', '=', System.today());
        return jobQuery.getQueryString();
    }

    global override void setParameterizedJobQuery(){
        fsCore.DynamicQueryBuilder jobQuery = getQuery();
        if (String.isNotBlank(getBranchCode())){
            Date branchDate = fsCore.SpectraCoreUtil.getBusinessDate(getBranchCode());
            branchDate = (branchDate == null) ? System.today() : branchDate;
            jobQuery.addWhereConditionWithValue(3,'fsServ__Transaction_Date__c', '=', branchDate);
        } else {
            jobQuery.addWhereConditionWithValue(3,'fsServ__Transaction_Date__c', '=', System.today());
        }
        setJobQuery(jobQuery.getQueryString());
    }

    global override String getClassName(){
        return CLASS_NAME;
    }
    
    global override void startJob(Database.BatchableContext pContext){}

    global override List<fsCore.ErrorObject> executeJob(Database.BatchableContext pContext, List<sObject> pScope) {
        System.debug(loggingLevel.error, 'Executing Job ' + CLASS_NAME + '...');
        System.debug(loggingLevel.error, 'Scope  ' + pScope );
        System.debug(loggingLevel.error, 'Scope Count : ' + pScope.size());
        
        if (pScope.size() == 0){ return null; }
        
        Set<Id> dueIdSet = new Set<Id>();
        for (fsServ__Contract_Due__c due : (List<fsServ__Contract_Due__c>)pScope){
            dueIdSet.add(due.Id);
        }
        
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(dueIdSet);
        
        ContractNotificationAction notifyAction = new ContractNotificationAction();
        notifyAction.setInput(acInput);
        notifyAction.setNotificationType(ContractNotificationUtil.PAYMENT_DUE_REMINDER);
        notifyAction.process();
        
        return notifyAction.getOutput().getErrors();
    }
    
    global override void finishJob(Database.BatchableContext pContext){}

    global void execute(SchedulableContext SC) {
        fsCore.BatchJobObject bJobObj = fsCore.BatchJobUtil.getBatchJobRecord('Payment_Due_Reminder_Email');
        Id jobId = fsCore.BatchJobUtil.submitBatchJob(bJobObj);
    }    

}