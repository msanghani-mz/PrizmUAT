/**
 * Class Name  : ApplicationChecklistCustomTriggerManager
 * Description : This class handles the custom logic for fsCore.ApplicationChecklistTrigger
 * Author      : Financial Spectra
 * 
 */
global with sharing class ApplicationChecklistCustomTriggerManager implements fsCore.TriggerManager {

    global void beforeInsert(List<sObject> pNewRecList){}
    global void beforeUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap){
        
        updateLatestDates(pNewRecList,pOldRecMap);
    }
    
    //DV-44 Updating dates upon status change (3 date fields created on application checklist object)
    private void updateLatestDates(List<sObject> pNewRecList, Map<Id, sObject> pOldRecMap){
        for (fsCore__Lending_Application_Checklist__c checkList : (List<fsCore__Lending_Application_Checklist__c>)pNewRecList){
            if (checkList.fsCore__Status__c <> ((fsCore__Lending_Application_Checklist__c)pOldRecMap.get(checkList.Id)).fsCore__Status__c){
                if (checkList.fsCore__Status__c == 'Uploaded'){
                    checkList.Latest_Upload_Date__c = date.today();
                }
                if(checkList.fsCore__Status__c == 'Verified'){
                    checkList.Latest_Verified_Date__c = date.today();
                }
                if(checkList.fsCore__Status__c == 'Rejected'){
                    checkList.Latest_Rejected_Date__c = date.today();
                }
            }
        }
    }
    global void beforeDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap){}
    
    //custom implementation of after trigger event
    global void afterInsert(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap){
        
        //Cannot keep the createFolderASync because this is also called from the future method when the loan application document comes back
        //if I keep it async it fails with the error Future method cannot be called from a future or batch method 
        //If I change it Sync then hit System.CalloutException: Callout from triggers are currently not supported.       
        //CreateBoxFolderHandler.createFolderAsync(pNewRecMap.keySet());
        //So call queable method seems to be the only option
        BoxFolderCreationQueueable createBoxFolder = new BoxFolderCreationQueueable(pNewRecMap.keySet());
        // enqueue the job for processing
        ID jobID = System.enqueueJob(createBoxFolder);
    }
    
    //DV-277
    private void updateEndingBalanceOnApplication(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap){
            Map<Id,Decimal> appToEndingBalanceMap = new Map<Id,Decimal>();
            for (fsCore__Lending_Application_Checklist__c checkList : (List<fsCore__Lending_Application_Checklist__c>)pNewRecList){
                if ((checkList.Is_Bank_Checklist_Type__c)
                    && (checkList.Ending_Balance_of_Bank_Account__c <> ((fsCore__Lending_Application_Checklist__c)pOldRecMap.get(checkList.Id)).Ending_Balance_of_Bank_Account__c)){
                        appToEndingBalanceMap.put(checkList.fsCore__Lending_Application_Number__c,checkList.Ending_Balance_of_Bank_Account__c);            
                }
            } 
            if (appToEndingBalanceMap.size() >0 ){
                updateEndingBalanceOnApplication(appToEndingBalanceMap);
            }
    }

    //final DML is in the future method so that it will have a different execution context
    //to address issue of SUP-379
    @future
    private static void updateEndingBalanceOnApplication(Map<Id,Decimal> pAppToEndingBalanceMap){
        if (pAppToEndingBalanceMap.size() >0 ){
            List<fsCore__Lending_Application__c> lendingApplicationList = [Select id
                                                                            , DNL_Ending_Balance__c
                                                                         from fsCore__Lending_Application__c 
                                                                        where id in :pAppToEndingBalanceMap.keySet()];
            for (fsCore__Lending_Application__c lApp:lendingApplicationList ){
                lApp.DNL_Ending_Balance__c = pAppToEndingBalanceMap.get(lApp.Id);

            }
            update lendingApplicationList;
        }
    }

    private void createBoxFolder(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap){
        Set<ID> eligibleRecsForBox = new Set<ID>();
        for (fsCore__Lending_Application_Checklist__c checkList : (List<fsCore__Lending_Application_Checklist__c>)pNewRecList){
            if (checkList.BoxFolderId__c == null){
                eligibleRecsForBox.add(checkList.Id);
            }
        }
        if (eligibleRecsForBox.size() >0){
            CreateBoxFolderHandler.createFolderAsync(eligibleRecsForBox);
        }

    }

    global void afterUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap){
        //SUP-570
        system.debug(logginglevel.error,'Checking if the lending app is updateable');
        system.debug(logginglevel.error,' Is multi Currency :'+Userinfo.isMultiCurrencyOrganization());
        if (Schema.sObjectType.fsCore__Lending_Application__c.isUpdateable()){
            system.debug(logginglevel.error,' It is updateable');
            createBoxFolder(pNewRecList,pOldRecList,pNewRecMap,pOldRecMap);
            updateEndingBalanceOnApplication(pNewRecList,pOldRecList,pNewRecMap,pOldRecMap);
        }
        
    }


    global void afterDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap){}
    global void afterUndelete(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap){}
}