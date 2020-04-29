/**
 * Class Name  : PaymentFailureEmailJob
 * Description : This batch job sends Payment failure email to the borrowers
 * Author      : Financial Spectra
 *
 */
global with sharing class PaymentFailureEmailJob extends fsCore.BatchQueryableBase implements Schedulable{
    private static final String CLASS_NAME = 'PaymentFailureEmailJob';

    global PaymentFailureEmailJob(){
        setJobQuery(getDefaultQuery());
    }

    private fsCore.DynamicQueryBuilder getQuery(){
        fsCore.DynamicQueryBuilder jobQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsServ__Inbound_Payment__c.getName())
               .addField('Id')
               .addWhereConditionWithValue(1, 'fsServ__Lending_Contract_Number__r.fsServ__Is_Active__c', '=', true)
               .addWhereConditionWithValue(2, 'fsServ__Payment_Status__c', '=', 'Reversed')
               .addWhereConditionWithValue(3, 'fsServ__Is_Processed__c', '=', true)
               .addWhereConditionWithValue(4, 'Is_Reject_Notification_Sent__c', '=', false)
               .addWhereConditionWithValue(5, 'Is_Eligible_For_Reject_Actions__c', '=', true);
        return jobQuery;
    }        

    private String getDefaultQuery(){
        fsCore.DynamicQueryBuilder jobQuery = getQuery();
        jobQuery.addWhereConditionWithValue(6, 'Reversed_Date__c', '=', System.today());
        return jobQuery.getQueryString();
    }

    global override void setParameterizedJobQuery(){
        fsCore.DynamicQueryBuilder jobQuery = getQuery();
        jobQuery.addWhereConditionWithValue(6,'Reversed_Date__c', '=', System.today());
        if (String.isNotBlank(getBranchCode())){
            jobQuery.addWhereConditionWithValue(7,'fsServ__Branch_Code__c', '=', getBranchCode());
        }
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
        
        Set<Id> paymentIdSet = new Set<Id>();
        for (fsServ__Inbound_Payment__c pmt : (List<fsServ__Inbound_Payment__c>)pScope){
            paymentIdSet.add(pmt.Id);
        }
        
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(paymentIdSet);
        
        ContractNotificationAction notifyAction = new ContractNotificationAction();
        notifyAction.setInput(acInput);
        notifyAction.setNotificationType(ContractNotificationUtil.PAYMENT_FAILURE);
        notifyAction.process();
        
        return notifyAction.getOutput().getErrors();
    }
    
    global override void finishJob(Database.BatchableContext pContext){}

    global void execute(SchedulableContext SC) {
        fsCore.BatchJobObject bJobObj = fsCore.BatchJobUtil.getBatchJobRecord('Payment_Failure_Email');
        Id jobId = fsCore.BatchJobUtil.submitBatchJob(bJobObj);
    }    

}