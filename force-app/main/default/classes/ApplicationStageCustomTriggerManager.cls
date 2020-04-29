/*
 * Copyright (c) 2017 FinancialSpectra Pty Ltd
 * All rights reserved.
 * 
 * Class Name    - ApplicationStageCustomTriggerManager
 * 
 * Description   - This is a wrapper class for all the trigger events of 
 *                 ApplicationStageTrigger (Object : fsCore__Lending_Application_Stage__c)
 * 
 * Developer(s)  - System Generated
 * 
 */
global with sharing class ApplicationStageCustomTriggerManager implements fsCore.TriggerManager {
    private static final String CLASS_NAME = 'ApplicationStageCustomTriggerManager';

    global void beforeInsert(List<sObject> pNewRecList) {}
    global void beforeUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap) {}
    global void beforeDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap) {}
    global void afterInsert(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap) {}
    global void afterUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap) {
        createTask(pNewRecList,pOldRecList,pNewRecMap,pOldRecMap);
    }
    global  void afterDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap) {}
    global  void afterUndelete(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap) {}


    private void createTask(List<sObject> pNewRecList
                                        , List<sObject> pOldRecList
                                        , Map<Id, sObject> pNewRecMap
                                        , Map<Id, sObject> pOldRecMap) {

        List<fsCore__Lending_Application_Stage__c> preSettlementFailedStages = new List<fsCore__Lending_Application_Stage__c>();
        List<Task> taskList = new List<Task>();
        for (fsCore__Lending_Application_Stage__c newAppRec : (List<fsCore__Lending_Application_Stage__c>)pNewRecList){
            if ((newAppRec.fsCore__Stage_Status__c == 'Failed') &&
                (newAppRec.Stage_Code_Formula__c == 'DNL_PRE_SETTLEMENT') &&
                (newAppRec.fsCore__Stage_Status__c != ((fsCore__Lending_Application_Stage__c)pOldRecMap.get(newAppRec.id)).fsCore__Stage_Status__c)){
                preSettlementFailedStages.add(newAppRec);
            }
        }                            

        if (preSettlementFailedStages.size()>0){
            taskList.addAll(getTaskList(preSettlementFailedStages,'DNL_PRE_SETTLEMENT_STAGE_FAILED'));
        }

        if (taskList.size()>0){
            insert taskList;
        }        

    }

    private list<task> getTaskList(List<fsCore__Lending_Application_Stage__c> pRecList, String pTaskCode){
        Map<String,list<TaskObject>> taskObjectMap = new Map<String,list<TaskObject>>();
        list<TaskObject> taskObjectList = new list<TaskObject>();
        for (fsCore__Lending_Application_Stage__c appStage: pRecList){
            TaskObject tsk =  new TaskObject(appStage);
            taskObjectList.add(tsk);
        }
        taskObjectMap.put(pTaskCode,taskObjectList);
        return TaskHandler.getTasks(taskObjectMap);

    }                                                    

}