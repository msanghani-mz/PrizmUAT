/*
 * Copyright (c) 2017 FinancialSpectra Pty Ltd
 * All rights reserved.
 * 
 * Class Name    - ContractTxnAllocationTriggerWrapper
 * 
 * Description   - This is a wrapper class for all the trigger events of 
 *                 ContractBalanceTrigger (Object : fsServ__Contract_Transaction_Balance_Allocation__c)
 * 
 * Developer(s)  - System Generated
 * 
 */
public with sharing class ContractTxnAllocationTriggerWrapper extends fsCore.TriggerWrapperBase{
    private static final String CLASS_NAME = 'ContractTxnAllocationTriggerWrapper';
    private static final String TRIGGER_NAME = 'ContractTransactionAllocationTrigger';


    private ContractTxnAllocationTriggerWrapper(){
        super.setTriggerDetails(TRIGGER_NAME);
    }

    private static ContractTxnAllocationTriggerWrapper mInstance = null;

    /* Method to get the only instance available */
    public static ContractTxnAllocationTriggerWrapper getInstance(){
        if (mInstance == null) mInstance = new ContractTxnAllocationTriggerWrapper();
        return mInstance;
    }


    public override void beforeInsert(List<sObject> pNewRecList) {
    }

    public override void beforeUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap) {
    }

    public override void beforeDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap) {}
    public override void afterInsert(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap) {
        submitTransactionAllocationRollup(pNewRecMap);
    }
    public override void afterUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap) {
        submitTransactionAllocationRollup(pNewRecMap);
    }
    public override void afterDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap) {}
    public override void afterUndelete(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap) {}

    private void submitTransactionAllocationRollup(Map<Id, sObject> pNewRecMap){
        Boolean submitQueuableBatchJob = true;
        //IF WE SUBMIT FROM BJ EXECUTION THEN WE WILL GET THE ERROR
        if (system.IsBatch() || System.isFuture()||System.isQueueable()){
            submitQueuableBatchJob = false;
        }
        Set<Id> inboundPaymentIds = new Set<Id>();
        for(Id recordId: pNewRecMap.keySet()){
            inboundPaymentIds.add(((fsServ__Contract_Transaction_Balance_Allocation__c)pNewRecMap.get(recordId)).fsServ__Inbound_Payment_Number__c);
        }        
        if (submitQueuableBatchJob){        
            TransactionAllocationRollupQueueable transactionAllocation = new TransactionAllocationRollupQueueable(inboundPaymentIds);
            ID jobID = System.enqueueJob(transactionAllocation);
        }else{
            fsCore.ActionInput acInput = new fsCore.ActionInput();
            acInput.addRecords(inboundPaymentIds);
    
            TransactionAllocationRollupAction TxnRollupAction = new TransactionAllocationRollupAction();
            TxnRollupAction.setInput(acInput);
            TxnRollupAction.process();
            fsCore.ActionOutput acOutput = TxnRollupAction.getOutput();            

        }
    }
}