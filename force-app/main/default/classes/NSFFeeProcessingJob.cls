/**
 * Class Name  : NSFFeeProcessingJob
 * Description : This batch job created the NSF Fee for 
 * Author      : Financial Spectra
 *
 */
global with sharing class NSFFeeProcessingJob extends fsCore.BatchQueryableBase implements Schedulable{
    private static final String CLASS_NAME = 'NSFFeeProcessingJob';

    global NSFFeeProcessingJob(){
        setJobQuery(getDefaultQuery());
    }

    private fsCore.DynamicQueryBuilder getQuery(){
        fsCore.DynamicQueryBuilder jobQuery = fsCore.DynamicQueryFactory.createQuery(Schema.SObjectType.fsServ__Inbound_Payment__c.getName())
               .addField('Id')
               .addField('Name')
               .addField('Is_NSF_Fee_Applied__c')
               .addField('fsServ__Branch_Code__c')
               .addField('fsServ__Lending_Contract_Number__c')
               .addField('fsServ__Lending_Contract_Number__r.fsServ__Branch_Code__c')
               .addWhereConditionWithValue(1, 'fsServ__Lending_Contract_Number__r.fsServ__Is_Active__c', '=', true)
               .addWhereConditionWithValue(2, 'fsServ__Payment_Status__c', '=', 'Reversed')
               .addWhereConditionWithValue(3, 'fsServ__Is_Processed__c', '=', true)
               .addWhereConditionWithValue(4, 'Is_NSF_Fee_Applied__c', '=', false)
               .addWhereConditionWithValue(5, 'Is_Eligible_For_Reject_Actions__c', '=', true);
        return jobQuery;
    }        

    private String getDefaultQuery(){
        return getQuery().getQueryString();
    }

    global override void setParameterizedJobQuery(){
        if (String.isNotBlank(getBranchCode())){
            getQuery().addWhereConditionWithValue(7,'fsServ__Branch_Code__c', '=', getBranchCode());
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
        
        List<fsServ.QueuedTransactionObject> nsfFeeTxnInputList = new List<fsServ.QueuedTransactionObject>();
        Map<Id, fsServ__Inbound_Payment__c> paymentMap = new Map<Id, fsServ__Inbound_Payment__c>();
        for (fsServ__Inbound_Payment__c pmt : (List<fsServ__Inbound_Payment__c>)pScope){
            fsServ.QueuedTransactionObject txnObj = new fsServ.QueuedTransactionObject();
            txnObj.lendingContractID = String.valueOf(pmt.fsServ__Lending_Contract_Number__c);
            txnObj.relatedRecordID = String.valueOf(pmt.Id);
            txnObj.relatedRecordName = pmt.Name;
            txnObj.transactionCode = 'NSF_FEE';
            txnObj.branchCode = (pmt.fsServ__Branch_Code__c != null)?pmt.fsServ__Branch_Code__c:pmt.fsServ__Lending_Contract_Number__r.fsServ__Branch_Code__c;
            txnObj.creationMethod = fsServ.Constants.CREATED_BY_APEX_JOB;
            txnObj.saveAsDraft = false;
            txnObj.parameters = new List<fsServ.QueuedTransactionObject.ParameterObject>();
            nsfFeeTxnInputList.add(txnObj);
            paymentMap.put(pmt.Id, pmt);
        }
        
        //create queued transactions
        fsServ.QueuedTransactionProcessor txnProcessor = new fsServ.QueuedTransactionProcessor(nsfFeeTxnInputList);
        txnProcessor.create();
        Set<Id> queuedTxnIds = txnProcessor.getQueuedTransactionIDs();
        
        //process queued transactions
        txnProcessor.process();
        
        List<fsCore.ErrorObject> errors = txnProcessor.getErrors();
        
        //check processing result and update related payment records
        List<fsServ__Transaction_Processing_Queue__c> processedTxns 
            = [SELECT Id, fsServ__Related_Record_ID__c
                 FROM fsServ__Transaction_Processing_Queue__c
                WHERE Id IN :queuedTxnIds
                  AND fsServ__Processing_Status__c = 'Processed'];
        
        List<fsServ__Inbound_Payment__c> pmtToBeUpdated = new List<fsServ__Inbound_Payment__c>();
        for (fsServ__Transaction_Processing_Queue__c nsfTxn : processedTxns){
            if (String.isNotBlank(nsfTxn.fsServ__Related_Record_ID__c)){
                Id pmtId = Id.valueOf(nsfTxn.fsServ__Related_Record_ID__c);
                if (paymentMap.containsKey(pmtId)){
                    fsServ__Inbound_Payment__c reversedPmt = paymentMap.get(pmtId);
                    reversedPmt.Is_NSF_Fee_Applied__c = true;
                    pmtToBeUpdated.add(reversedPmt);
                }
            }
        }
        
        fsCore.DMLResult pmtDMLRslt = fsServ.InboundPaymentDMLWrapper.getInstance().updateData(pmtToBeUpdated);
        if (pmtDMLRslt.hasErrors()){ errors.addAll(pmtDMLRslt.getErrorList()); }
        
        return errors;
    }
    
    global override void finishJob(Database.BatchableContext pContext){}

    global void execute(SchedulableContext SC) {
        fsCore.BatchJobObject bJobObj = fsCore.BatchJobUtil.getBatchJobRecord('Payment_Failure_Email');
        Id jobId = fsCore.BatchJobUtil.submitBatchJob(bJobObj);
    }    

}