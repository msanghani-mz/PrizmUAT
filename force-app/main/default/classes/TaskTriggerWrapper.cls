/*
* Copyright (c) 2017 FinancialSpectra Pty Ltd
* All rights reserved.
* 
* Class Name    - TaskTriggerWrapper
* 
* Description   - This is a wrapper class for all the trigger events of 
*                 DocusignStatusTrigger (Object : Task)
* 
* Developer(s)  - System Generated
* 
*/
global with sharing class TaskTriggerWrapper extends fsCore.TriggerWrapperBase{
    private static final String CLASS_NAME = 'TaskTriggerWrapper';
    private static final String TRIGGER_NAME = 'TaskTrigger';
    
    private TaskTriggerWrapper(){
        super.setTriggerDetails(TRIGGER_NAME);
    }
    
    private static TaskTriggerWrapper mInstance = null;
    
    /* Method to get the only instance available */
    global static TaskTriggerWrapper getInstance(){
        if (mInstance == null) mInstance = new TaskTriggerWrapper();
        return mInstance;
    }
    
    global override void beforeInsert(List<sObject> pNewRecList) {
         // Added for Lead - DLM
        pNewRecList = Prizm_TaskHandler.setTaskStatusForLeadConvertBeforeInsertUpdate(pNewRecList);
        
        //DV-193
        TaskHandler.updateDueDateToBusinessDate(pNewRecList,false);
        Map<Id,Task> mapContractidsToTask = new Map<Id,Task>();
        Map<Id,Task> mapApplicationidsToTask = new Map<Id,Task>();
        
        for (Task t: (List<Task>)pNewRecList ){

            if (t.WhatId != null){
                
                if (t.WhatId.getSObjectType().getDescribe().getName() == 'fsServ__Lending_Contract__c'){
                    mapContractidsToTask.put(t.WhatId,t);
                }else if(t.WhatId.getSObjectType().getDescribe().getName() == 'fsCore__Lending_Application__c'){
                    mapApplicationidsToTask.put(t.WhatId,t);
                }
            }
        }
        
        if(mapContractidsToTask.size()>0){
            
            List<fsServ__Lending_Contract__c> contractList = [Select id
                                                                   , fsServ__Product_Code__c
                                                              from fsServ__Lending_Contract__c
                                                              where id in :mapContractidsToTask.KeySet()];
            
            for(fsServ__Lending_Contract__c contract : contractList){
                
                if(contract.fsServ__Product_Code__c == 'VCL'){
                    Task t = mapContractidsToTask.get(contract.id);
                    Id recTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('VCL_Task').getRecordTypeId();
                    System.debug(loggingLevel.ERROR, 'recTypeId -' + recTypeId);
                    t.RecordTypeId = recTypeId;  
                    
                }else if(contract.fsServ__Product_Code__c == 'DNL'){
                    Task t = mapContractidsToTask.get(contract.id);
                    Id recTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('DNL_Task').getRecordTypeId();
                    t.RecordTypeId = recTypeId;  
                }
            }
            
        }
        
        if(mapApplicationidsToTask.size()>0){
            
            List<fsCore__Lending_Application__c> applicationList = [Select id , Loan_Type__c
                                                                    from fsCore__Lending_Application__c
                                                                    where id in :mapApplicationidsToTask.KeySet()];
            
            for(fsCore__Lending_Application__c app : applicationList){
                if(app.Loan_Type__c == 'VCL'){
                    Task t = mapApplicationidsToTask.get(app.id);
                    Id recTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('VCL_Task').getRecordTypeId();
                    t.RecordTypeId = recTypeId;  
                    
                }else if(app.Loan_Type__c == 'DNL'){
                    Task t = mapApplicationidsToTask.get(app.id);
                    Id recTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('DNL_Task').getRecordTypeId();
                    t.RecordTypeId = recTypeId;  
                }
            }
            
        }
       
    }
    
    global override void beforeUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap) {
    }
    
    global override void beforeDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap) {}
    
    global override void afterInsert(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap) {
        
        TaskHandler.PushNudebtTask(pNewRecList);
         Prizm_TaskHandler.Prizm_UpdateLeadStatus((List<Task>)pNewRecList); //For Testing - update Lead status - DLM-8
    }
    
    
    global override void afterUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap) {
        
        Boolean PrizmAdmin = [select id, Prizm_admin__c from user where id =: userinfo.getuserid()].Prizm_admin__c;
        if(!PrizmAdmin){
            TaskHandler.UpdateNuDebtTask(pNewRecList,pOldRecMap);
        }
        Prizm_TaskHandler.Prizm_UpdateLeadStatus((List<Task>)pNewRecList); //For Testing - update Lead status - DLM-8
        //Prizm_TaskHandler.Prizm_UpdateLeadStatus((List<Task>)pNewRecList,(Map<Id,task>)pOldRecMap); //For Testing - update Lead status - DLM-8
    }    
    
    global override void afterDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap) {}
    
    global override void afterUndelete(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap) {}
    
}