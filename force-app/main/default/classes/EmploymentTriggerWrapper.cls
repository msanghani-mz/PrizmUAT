/*
 * Copyright (c) 2017 FinancialSpectra Pty Ltd
 * All rights reserved.
 * 
 * Class Name    - EmploymentTriggerWrapper
 * 
 * Description   - This is a wrapper class for all the trigger events of 
 *                 ContractBalanceTrigger (Object : fsCore__Employment__c)
 * 
 * Developer(s)  - System Generated
 * 
 */
public with sharing class EmploymentTriggerWrapper extends fsCore.TriggerWrapperBase{
    private static final String CLASS_NAME = 'EmploymentTriggerWrapper';
    private static final String TRIGGER_NAME = 'EmploymentTrigger';


    private EmploymentTriggerWrapper(){
        super.setTriggerDetails(TRIGGER_NAME);
    }

    private static EmploymentTriggerWrapper mInstance = null;

    /* Method to get the only instance available */
    public static EmploymentTriggerWrapper getInstance(){
        if (mInstance == null) mInstance = new EmploymentTriggerWrapper();
        return mInstance;
    }


    public override void beforeInsert(List<sObject> pNewRecList) {}

    public override void beforeUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap) {}

    public override void beforeDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap) {}
    public override void afterInsert(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap) {}
    public override void afterUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap) {
        populateInformationToFinancial(pNewRecList,pOldRecMap);
    }
    public override void afterDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap) {}
    public override void afterUndelete(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap) {}

    
    private void populateInformationToFinancial(List<sObject> pNewRecList,Map<Id, sObject> pOldRecMap){
        Set<Id> empIds = new Set<Id>();
        list<fsCore__Financial__c> updFinList = new List<fsCore__Financial__c>();
        for (fsCore__Employment__c employment: (List<fsCore__Employment__c>)pNewRecList){
            if ((employment.fsCore__Salary__c <> ((fsCore__Employment__c)pOldRecMap.get(employment.Id)).fsCore__Salary__c)
                ||(employment.fsCore__Start_Date__c <> ((fsCore__Employment__c)pOldRecMap.get(employment.Id)).fsCore__Start_Date__c)){
                    empIds.add(employment.id);
            }
        }
        Map<ID, fsCore__Employment__c> employmentMap = new Map<ID, fsCore__Employment__c>([SELECT Id, 
                                                                                                  fsCore__Start_Date__c,
                                                                                                  fsCore__Salary__c,
                                                                                                  (SELECT Id,
                                                                                                           Start_Date__c,
                                                                                                           fsCore__Stated_Amount__c
                                                                                                      FROM Financial__r)
                                                                                              FROM fsCore__Employment__c where id in :empIds]);


        for (Id empId: employmentMap.KeySet()){
                fsCore__Employment__c emp = employmentMap.get(empId);
                for (fsCore__Financial__c financial: emp.Financial__r){
                    financial.Start_Date__c = emp.fsCore__Start_Date__c;
                    financial.fsCore__Stated_Amount__c = emp.fsCore__Salary__c;
                    updFinList.add(financial);
                }
        }

        update updFinList;
    }

}