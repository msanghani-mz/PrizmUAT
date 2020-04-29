/*
 * Copyright (c) 2017 FinancialSpectra Pty Ltd
 * All rights reserved.
 * 
 * Class Name    - OpportunityTradelinesWrapper
 * 
 * Description   - This is a wrapper class for all the trigger events of 
 *                 OpportunityTradelinesTrigger (Object : Opportunity_Tradelines_Offer__c)
 * 
 * Developer(s)  - System Generated
 * 
 */
global with sharing class OpportunityTradelinesWrapper extends fsCore.TriggerWrapperBase{
    private static final String CLASS_NAME = 'OpportunityTradelinesWrapper';
    private static final String TRIGGER_NAME = 'OpportunityTradelinesTrigger';

    private OpportunityTradelinesWrapper(){
        super.setTriggerDetails(TRIGGER_NAME);
    }

    private static OpportunityTradelinesWrapper mInstance = null;

    /* Method to get the only instance available */
    global static OpportunityTradelinesWrapper getInstance(){
        if (mInstance == null) mInstance = new OpportunityTradelinesWrapper();
        return mInstance;
    }

//
    //DV-246
    private void updateNumberOfTradelinesOnApplication(List<sObject> pNewRecList){
        
        Set<Id> appIds = new Set<Id>();
        for (Opportunity_Tradelines_Offer__c tradeline : (List<Opportunity_Tradelines_Offer__c>)pNewRecList){
            if (tradeline.Lending_Application_Number__c != null){
                  appIds.add(tradeline.Lending_Application_Number__c);
            }
        } 

        if (appIds.size() >0 ){
            Map<Id,Integer> appToTradelineCountMap = new Map<Id,Integer>();
            List<AggregateResult> aggResult = [SELECT count(Id) num
                                                , Lending_Application_Number__c lapp
                                             FROM Opportunity_Tradelines_Offer__c
                                            where Lending_Application_Number__c in :appIds
                                            group by Lending_Application_Number__c];
            for(AggregateResult agg :aggResult){
                appToTradelineCountMap.put((Id)agg.get('lapp'),(Integer)agg.get('num'));
            }

            List<fsCore__Lending_Application__c> lendingApplicationList = [Select id
                                                                            , Number_Of_Tradelines__c
                                                                         from fsCore__Lending_Application__c 
                                                                        where id in :appIds];
            for (fsCore__Lending_Application__c lApp:lendingApplicationList ){
                lApp.Number_Of_Tradelines__c = appToTradelineCountMap.get(lApp.Id);

            }

            update lendingApplicationList;
        }


    }

    global override void beforeInsert(List<sObject> pNewRecList) {}

    global override void beforeUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap) {}

    global override void beforeDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap) {}

    global override void afterInsert(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap) {
        updateNumberOfTradelinesOnApplication(pNewRecList);
    }

    global override void afterUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap) {
        updateNumberOfTradelinesOnApplication(pNewRecList);
    }

    global override void afterDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap) {
        updateNumberOfTradelinesOnApplication(pOldRecList);
    }

    global override void afterUndelete(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap) {
        updateNumberOfTradelinesOnApplication(pNewRecList);
    }

}