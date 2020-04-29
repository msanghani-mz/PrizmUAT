/*
 * Copyright (c) 2017 FinancialSpectra Pty Ltd
 * All rights reserved.
 * 
 * Class Name    - ContractBalanceTriggerWrapper
 * 
 * Description   - This is a wrapper class for all the trigger events of 
 *                 ContractBalanceTrigger (Object : fsServ__Contract_Balance__c)
 * 
 * Developer(s)  - System Generated
 * 
 */
public with sharing class ContractBalanceTriggerWrapper extends fsCore.TriggerWrapperBase{
    private static final String CLASS_NAME = 'ContractBalanceTriggerWrapper';
    private static final String TRIGGER_NAME = 'ContractBalanceTrigger';


    private ContractBalanceTriggerWrapper(){
        super.setTriggerDetails(TRIGGER_NAME);
    }

    private static ContractBalanceTriggerWrapper mInstance = null;

    /* Method to get the only instance available */
    public static ContractBalanceTriggerWrapper getInstance(){
        if (mInstance == null) mInstance = new ContractBalanceTriggerWrapper();
        return mInstance;
    }


    public override void beforeInsert(List<sObject> pNewRecList) {
    }

    public override void beforeUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap) {
    }

    public override void beforeDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap) {}
    public override void afterInsert(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap) {
        submitContractBalanceRollup(pNewRecMap);
    }
    public override void afterUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap) {
        submitContractBalanceRollup(pNewRecMap);
    }
    public override void afterDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap) {}
    public override void afterUndelete(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap) {}
    
    private void submitContractBalanceRollup(Map<Id, sObject> pNewRecMap){
        Boolean submitQueuableBatchJob = true;
        if (system.IsBatch() || System.isFuture()||System.isQueueable()){
            submitQueuableBatchJob = false;
        }
        if (submitQueuableBatchJob){
            Set<Id> contractIds = new Set<Id>();
            for(Id recordId: pNewRecMap.keySet()){
                contractIds.add(((fsServ__Contract_Balance__c)pNewRecMap.get(recordId)).fsServ__Lending_Contract_Number__c);
            }
            ContractBalancesRollupQueueable updateContractBalancesToContract = new ContractBalancesRollupQueueable(contractIds);
            ID jobID = System.enqueueJob(updateContractBalancesToContract);
        }
    }


}