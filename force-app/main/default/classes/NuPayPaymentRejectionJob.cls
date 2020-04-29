/**
 * Class Name  : NuPayPaymentRejectionJob
 * Description : This batch job to process the payments marked as rejected by NuPay
 * Author      : Financial Spectra
 *
 */
global with sharing class NuPayPaymentRejectionJob extends fsCore.BatchQueryableBase implements Schedulable{
    private static final String CLASS_NAME = 'NuPayPaymentRejectionJob';

    global NuPayPaymentRejectionJob(){
        setJobQuery(getDefaultQuery());
    }

    private fsCore.DynamicQueryBuilder getQuery(){
        fsCore.DynamicQueryBuilder jobQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsServ__Inbound_Payment__c.getName())
               .addField('Id')
               .addWhereConditionWithValue(1, 'fsServ__Lending_Contract_Number__r.fsServ__Is_Active__c', '=', true)
               .addWhereConditionWithValue(2, 'NuPay_Transaction_Status__c', '=', 'Failed')
               .addWhereConditionWithValue(3, 'NuPay_Transaction_Status__c', '=', 'Cancelled')
               .addWhereConditionWithValue(4, 'fsServ__Payment_Status__c', '!=', 'Reversed')
               .addWhereConditionWithValue(5, 'fsServ__Reverse_Reason__c', '=', null)
               .addWhereConditionWithValue(6, 'fsServ__Reversed_On__c', '=', null)
               .setWhereConditionCriteria('1 AND (2 OR 3) AND 4 AND 5 AND 6');
        return jobQuery;
    }        

    private String getDefaultQuery(){
        return getQuery().getQueryString();
    }

    global override void setParameterizedJobQuery(){
        if (String.isNotBlank(getBranchCode())){
            getQuery().addWhereConditionWithValue(7,'fsServ__Branch_Code__c', '=', getBranchCode());
            getQuery().setWhereConditionCriteria('1 AND (2 OR 3) AND 4 AND 5 AND 6 AND 7');
        }
        setJobQuery(getQuery().getQueryString());
    }

    global override String getClassName(){
        return CLASS_NAME;
    }
    
    global override void startJob(Database.BatchableContext pContext){}

    global override List<fsCore.ErrorObject> executeJob(Database.BatchableContext pContext, List<sObject> pScope) {
        System.debug(loggingLevel.DEBUG, 'Executing Job ' + CLASS_NAME + '...');
        System.debug(loggingLevel.DEBUG, 'Scope Count : ' + pScope.size());
        
        if (pScope.size() == 0){ return null; }
        
        Map<Id, String> paymentToReversalReasonMap = new Map<Id, String>();
        for (fsServ__Inbound_Payment__c pmt : (List<fsServ__Inbound_Payment__c>)pScope){
            paymentToReversalReasonMap.put(pmt.Id, 'Rejected by NuPay');
        }
        
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(paymentToReversalReasonMap.keySet());
        
        fsServ.InboundPaymentReversalProcessor reversalAction = new fsServ.InboundPaymentReversalProcessor();
        reversalAction.setInput(acInput);
        reversalAction.setReversalReasonMap(paymentToReversalReasonMap);
        reversalAction.process();
        
        return reversalAction.getOutput().getErrors();
    }
    
    global override void finishJob(Database.BatchableContext pContext){}

    global void execute(SchedulableContext SC) {
        fsCore.BatchJobObject bJobObj = fsCore.BatchJobUtil.getBatchJobRecord('NuPay_Payment_Rejection');
        Id jobId = fsCore.BatchJobUtil.submitBatchJob(bJobObj);
    }    

}