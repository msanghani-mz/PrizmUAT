/*
* Copyright (c) 2017 FinancialSpectra Pty Ltd
* All rights reserved.
* 
* Class Name    - BankAccountVerificationTriggerWrapper
* 
* Description   - This is a wrapper class for all the trigger events of 
*                 Application_Bank_Account_Verification__c (Object : Application_Bank_Account_Verification__c)
* 
* Developer(s)  - System Generated
* 
*/
global without sharing class BankAccountVerificationTriggerWrapper extends fsCore.TriggerWrapperBase{
    private static final String CLASS_NAME = 'BankAccountVerificationTriggerWrapper';
    private static final String TRIGGER_NAME = 'BankAccountVerificationTrigger';
    
    
    private BankAccountVerificationTriggerWrapper(){
        super.setTriggerDetails(TRIGGER_NAME);
    }
    
    private static BankAccountVerificationTriggerWrapper mInstance = null;
    
    /* Method to get the only instance available */
    global static BankAccountVerificationTriggerWrapper getInstance(){
        if (mInstance == null) mInstance = new BankAccountVerificationTriggerWrapper();
        return mInstance;
    }
    
    global override void beforeInsert(List<sObject> pNewRecList) {}
    
    global override void beforeUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap) {

        updateRecordType(pNewRecList,pOldRecMap);
    }
    global override void beforeDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap) {}
    
    global override void afterInsert(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap) {
        triggerNuDebtClientCreationProcess((List<Application_Bank_Account_Verification__c>) pNewRecList);  
    }

    private void updateRecordType(List<sObject> pNewRecList,Map<Id, sObject> pOldRecMap){
        Id recordTypCancelled = SFSUtil.getRecordTypeId('Application_Bank_Account_Verification__c', 'Cancelled');
        for (Application_Bank_Account_Verification__c bavVerify: (List<Application_Bank_Account_Verification__c>)pNewRecList){
            if (bavVerify.Verification_Status__c == 'Cancelled' 
                && (bavVerify.Verification_Status__c != ((Application_Bank_Account_Verification__c)pOldRecMap.get(bavVerify.Id)).Verification_Status__c)){
                    bavVerify.recordTypeId = recordTypCancelled;
            }
        }

    }
    
    private void submitBAVVerification(List<sObject> pNewRecList,Map<Id, sObject> pOldRecMap){

        set<ID> accountsToBeVerfied = new set<ID>();
        for (Application_Bank_Account_Verification__c bavVerify: (List<Application_Bank_Account_Verification__c>)pNewRecList){
            system.debug(logginglevel.error,'Verification_Status__c :'+bavVerify.Verification_Status__c);
            system.debug(logginglevel.error,'Deposit_Status__c :'+bavVerify.Deposit_Status__c);
            if ((bavVerify.Is_Client_Created__c) 
                && ((bavVerify.Is_Client_Created__c != ((Application_Bank_Account_Verification__c)pOldRecMap.get(bavVerify.Id)).Is_Client_Created__c))
                && bavVerify.External_RAMS_ID_Formula__c != null 
                && (bavVerify.Deposit_Amount__c == 0)){
                accountsToBeVerfied.add(bavVerify.Id);
            }
        }
        if (accountsToBeVerfied.size()>0){
            //Since callouts from Triggers are not supported. Submitting the Queuable Job
            RAMBankAccountVerifyQueueable bankVerify = new RAMBankAccountVerifyQueueable(accountsToBeVerfied);
            if(!Test.isRunningTest()){  ID jobID = System.enqueueJob(bankVerify); }

        }        
    } 

    private void markBAVVerificationCompleted(List<sObject> pNewRecList, Map<Id, sObject> pOldRecMap) {
        set<ID> verificationCompleted = new set<ID>();
        for (Application_Bank_Account_Verification__c bavVerify: (List<Application_Bank_Account_Verification__c>)pNewRecList){
            system.debug(logginglevel.error,'Verification_Status__c :'+bavVerify.Verification_Status__c);
            system.debug(logginglevel.error,'Verification_Completed_Update_To_RAMS__c :'+bavVerify.Verification_Completed_Update_To_RAMS__c);
            system.debug(logginglevel.error,'pOldRecMap.get(bavVerify.Id).Verification_Status__c :'+((Application_Bank_Account_Verification__c)pOldRecMap.get(bavVerify.Id)).Verification_Status__c);
            if (bavVerify.Verification_Status__c == 'Verified' 
                && (!bavVerify.Verification_Completed_Update_To_RAMS__c)
                && (bavVerify.Is_Deposit_Complete__c)
                && (bavVerify.Verification_Status__c != ((Application_Bank_Account_Verification__c)pOldRecMap.get(bavVerify.Id)).Verification_Status__c)){
                verificationCompleted.add(bavVerify.Id);
            }
        }
        if (verificationCompleted.size()>0){
            //Since callouts from Triggers are not supported. Submitting the Queuable Job
            RAMBankAccountVerifyCompQueueable bankVerify = new RAMBankAccountVerifyCompQueueable(verificationCompleted);
            if(!Test.isRunningTest()){  ID jobID = System.enqueueJob(bankVerify); }

        }          
    }        

    global override void afterUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap) {
        
        submitBAVVerification(pNewRecList,pOldRecMap);
        createTaskAfterBAVVerification(pNewRecList,pOldRecMap);
        markBAVVerificationCompleted(pNewRecList, pOldRecMap);
        
    }

    private void createTaskAfterBAVVerification(List<sObject> pBAVRecList,Map<Id, sObject> pOldRecMap){
        List<Task> taskList = new List<Task>();
        for(Application_Bank_Account_Verification__c bavRec : (List<Application_Bank_Account_Verification__c>)pBAVRecList ){
            if(bavRec.Verification_Status__c == 'Verified' && ((Application_Bank_Account_Verification__c)pOldRecMap.get(bavRec.id)).Verification_Status__c != 'Verified'){    
                
                Task t = new Task();
                t.OwnerId = Id.ValueOf(bavRec.Lending_Application_Owner_Id__c);
                t.Subject = bavRec.Lending_Application_Name_Formula__c + ' ' + bavRec.Primary_Customer_Name_Formula__c + ' has verified their bank account. Please review and initiate hard credit pull.';
                t.Description = 'Please initiate a Hard Pull for this client';
                t.ActivityDate = Date.today().addDays(1);
                
                taskList.add(t);

            }
        }
        if (taskList.size() > 0 ){
            Database.insert(taskList);
        }
    }


    private void triggerNuDebtClientCreationProcess(List<Application_Bank_Account_Verification__c> pBAVRecList){  
        Set<ID> appIds = new Set<ID>();
        map<Id,Id> appToBAVId = new map<Id,Id>();
        for(Application_Bank_Account_Verification__c bavRec : pBAVRecList){
            if (bavRec.Verification_Status__c == 'New' ){
                appIds.add(bavRec.Lending_Application_Name__c);
                appToBAVId.put(bavRec.Lending_Application_Name__c,bavRec.Id);
            }
        }
        List <fsCore__Lending_Application__c> lAppList = [select id, name,fsCore__Primary_Customer_Account__r.nu_dse__External_RAMS_ID__c,Is_Client_Created__c from fsCore__Lending_Application__c where id in :appIds];
        Set<ID> newClientAppIds = new Set<ID>();
        Set<ID> existingClientAppIds = new Set<ID>();
        for(fsCore__Lending_Application__c lApp : lAppList){
            //if (lApp.Is_Client_Created__c && (lApp.fsCore__Primary_Customer_Account__r.nu_dse__External_RAMS_ID__c != null) ){
            if (lApp.fsCore__Primary_Customer_Account__r.nu_dse__External_RAMS_ID__c != null) {    
                //IF CLIENT IS ALREADY CREATED AND RAM EXTERNAL ID IS POPULATED THEN SUBMIT BAV NOW
                existingClientAppIds.add(appToBAVId.get(lApp.Id));
            }else{
                //if (!lApp.Is_Client_Created__c){
                if (lApp.fsCore__Primary_Customer_Account__r.nu_dse__External_RAMS_ID__c == null) {        
                 //IF CLIENT IS NOT EVEN CREATED THEN SUBMIT THE CIENT CREATION PROCESS
                 newClientAppIds.add(lApp.Id);
                }
            }
        }   


        if (newClientAppIds.size() > 0 ){
            CreateNuDebtClientAndBankAcctQueueable createNuDebtClient = new CreateNuDebtClientAndBankAcctQueueable(newClientAppIds);
            if(!Test.isRunningTest()){  ID jobID = System.enqueueJob(createNuDebtClient); }
        }
        if (existingClientAppIds.size()>0){
            //Since callouts from Triggers are not supported. Submitting the Queuable Job
            RAMBankAccountVerifyQueueable bankVerify = new RAMBankAccountVerifyQueueable(existingClientAppIds);
            if(!Test.isRunningTest()){  ID jobID = System.enqueueJob(bankVerify); }
        } 

    }
    
    global override void afterDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap) {}
    
    global override void afterUndelete(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap) {}
    
}