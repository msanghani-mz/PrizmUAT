/**
 * Class Name  : InboundPaymentCustomTriggerManager (PDI-409)
 * Description : This class handles the custom logic for fsCore.InboundPaymentTrigger
 * Author      : Financial Spectra
 * 
 */
global with sharing class InboundPaymentCustomTriggerManager implements fsCore.TriggerManager {
    public static boolean mIsExecuting = false;

    global void beforeInsert(List<sObject> pNewRecList){}
    global void beforeUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap){}
    global void beforeDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap){}
    global void afterInsert(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap){
        
        notifyPaymentFailure( pNewRecList);   //SUP-356,Notify Servicing User of Failed Payment
        
        //This is for the NUPay to mark the payments to Pending so that NUPay Can Process it.
        initiateNuPay(pNewRecList);
    }
    global void afterUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap){
        
    	notifyPaymentFailure(pNewRecList);   //SUP-356,Notify Servicing User of Failed Payment
        manageNSFTasks(pNewRecList, pOldRecList, pNewRecMap, pOldRecMap);
        InboundPaymentHandler.syncNudebtPayment(pNewRecList, pOldRecList, pNewRecMap, pOldRecMap);
    }

    private void notifyPaymentFailure(List<sObject> pNewRecList){
        List<fsServ__Lending_Contract__c> contracts = [Select Id, OwnerId, Name from fsServ__Lending_Contract__c];
        Map<Id, Id> contractToOwnerMap = new Map<Id, Id>();
        Map<String, String> contractToNameMap = new Map<String,String>();

	    for(fsServ__Lending_Contract__c contract: contracts){
        	contractToOwnerMap.put(contract.id, contract.OwnerId);
            contractToNameMap.put(contract.id, contract.Name);

        }
        
        List<Task> newTasks = new List<Task>();
        for (fsServ__Inbound_Payment__c paymnt:  (List<fsServ__Inbound_Payment__c>)pNewRecList){
        if (paymnt.NuPay_Transaction_Status__c == 'Failed'){
                newTasks.add(new Task(
                    RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('VCL_Task').getRecordTypeId(),
                  //  ActivityDate = Date.today(),
                    WhatId = paymnt.fsServ__Lending_Contract_Number__c,
                    OwnerId = contractToOwnerMap.get(paymnt.fsServ__Lending_Contract_Number__c),
                    Description = 'A recent payment for '+contractToNameMap.get(paymnt.fsServ__Lending_Contract_Number__c) +' has failed. Please reach out to the client to discuss the issue.',
                    Subject = 'A recent payment has failed, please review.'
                    ));
        }
    }

    insert newTasks;  
    } 
    
    private void manageNSFTasks(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap){
       List<fsServ__Inbound_Payment__c> NSFRescheduleTaskList = new List<fsServ__Inbound_Payment__c>();
        List<fsServ__Inbound_Payment__c> NSFATDTaskList = new List<fsServ__Inbound_Payment__c>();
        List<Task> taskList = new List<Task>();

        for (fsServ__Inbound_Payment__c newAppRec : (List<fsServ__Inbound_Payment__c>)pNewRecList){
            if ((newAppRec.fsServ__Payment_Status__c == fsServ.Constants.TRANSACTION_STATUS_REVERSED)
                &&((newAppRec.Eligible_For_NSF_Reschedule_Task__c)||(newAppRec.Eligible_For_NSF_ATD_Task__c))
                &&((newAppRec.fsServ__Payment_Status__c <> ((fsServ__Inbound_Payment__c)pOldRecMap.get(newAppRec.Id)).fsServ__Payment_Status__c)
                    ||(newAppRec.Rejection_Reason__c <> ((fsServ__Inbound_Payment__c)pOldRecMap.get(newAppRec.Id)).Rejection_Reason__c))
                ){
                    if (newAppRec.Eligible_For_NSF_Reschedule_Task__c ){
                        NSFRescheduleTaskList.add((fsServ__Inbound_Payment__c)newAppRec);
                    }else if(newAppRec.Eligible_For_NSF_ATD_Task__c){
                        NSFATDTaskList.add((fsServ__Inbound_Payment__c)newAppRec);
                    }
            }
        }

        if (NSFRescheduleTaskList.size()>0){
            taskList.addAll(getNSFTaskList(NSFRescheduleTaskList,'DNL_NSF_CONTACT_CLIENT_PMT_RSCH'));
        }   
        if (NSFATDTaskList.size()>0){
            taskList.addAll(getNSFTaskList(NSFATDTaskList,'DNL_NSF_CONTACT_CLIENT_NEW_ATD'));
        }                   
        if (taskList.size()>0){
            system.debug(logginglevel.error,'taskList ************************'+taskList);
            insert taskList;
        }
    }
    
    private void initiateNuPay(List<sObject> pOldRecList){
        set<ID> markInboundPaymentToPendingIds = new set<ID>();
        for (fsServ__Inbound_Payment__c inboundRec : (List<fsServ__Inbound_Payment__c>)pOldRecList){
            if ( (inboundRec.NuPay_Transaction_Status__c == 'Tentative') && (inboundRec.fsServ__Payment_Mode__c == 'ACH')){
                markInboundPaymentToPendingIds.add(inboundRec.Id);
            }
        }
        
        InboundPaymentToPendingQueueable pendingJob = new InboundPaymentToPendingQueueable(markInboundPaymentToPendingIds);
        ID jobID = System.enqueueJob(pendingJob);
    } 


    private list<task> getNSFTaskList(List<fsServ__Inbound_Payment__c> pRecList, String pTaskCode){
        Map<String,list<TaskObject>> taskObjectMap = new Map<String,list<TaskObject>>();
        list<TaskObject> taskObjectList = new list<TaskObject>();
        for (fsServ__Inbound_Payment__c docSignStatus: pRecList){
            TaskObject tsk =  new TaskObject(docSignStatus);
            taskObjectList.add(tsk);
        }
        taskObjectMap.put(pTaskCode,taskObjectList);
        return TaskHandler.getTasks(taskObjectMap);

    }    
    global void afterDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap){}
    global void afterUndelete(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap){}
}