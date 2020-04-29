/*
* Copyright (c) 2017-2019 FinancialSpectra Pty Ltd
* All rights reserved.
* 
* Class Name   - DirectDebitScheduleCreator
*
* Description  - This class creates the direct debit schedule 
*                using the Bank Account Object of the primary applicant
*                of the Lending Applications
*
* Developer(s) - Ekta Sharma
*
*/
global class DirectDebitScheduleCreator implements fsCore.ActionProcessor {
    private static final String  CLASS_NAME = 'DirectDebitScheduleCreator';
    
    private fsCore.ActionInput mActionInput;
    private fsCore.ActionOutput mActionOutput;
    private Map<Id, fsCore__Lending_Application__c> mApplicationMap;
    
    global DirectDebitScheduleCreator(){
        mActionInput = new fsCore.ActionInput();
        mActionOutput = new fsCore.ActionOutput();
        mApplicationMap = new Map<Id, fsCore__Lending_Application__c>();
    }
    
    global void setInput(fsCore.ActionInput pInput){
        mActionInput = pInput;        
    }
    
    global String getClassName(){
        return CLASS_NAME;
    }
    
    global fsCore.ActionOutput getOutput(){
        return mActionOutput;
    } 
    
    global void process(){
        //get applications for input records
        mApplicationMap = fsCore.LendingApplicationUtil.getApplications(mActionInput.getRecords());

        //prepare application Id to primary applicant map
        List<fsCore__Lending_Application_Customer__c> applicants 
            = [SELECT Id, fsCore__Account_Name__c, fsCore__Lending_Application_Number__c 
                 FROM fsCore__Lending_Application_Customer__c 
                WHERE fsCore__Lending_Application_Number__c IN :mApplicationMap.keySet()
                  AND fsCore__Is_Primary__c = true
                  AND fsCore__Account_Name__c != null];
        
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id, fsCore__Lending_Application_Customer__c> appToApplicantMap = new Map<Id, fsCore__Lending_Application_Customer__c>();
        for(fsCore__Lending_Application_Customer__c appl : applicants){
            if (!appToApplicantMap.containsKey(appl.fsCore__Lending_Application_Number__c)){
                appToApplicantMap.put(appl.fsCore__Lending_Application_Number__c, appl);
            }
            accountIdSet.add(appl.fsCore__Account_Name__c);
        }
        
        //prepare account Id to bank account Map
        List<fsCore__Bank_Account__c> bankAccounts
            = [SELECT Id, fsCore__Account_Name__c
                 FROM fsCore__Bank_Account__c
                WHERE fsCore__Account_Name__c IN :accountIdSet
                ORDER BY Name];
                
        Map<Id, fsCore__Bank_Account__c> accountToBankAccountMap = new Map<Id, fsCore__Bank_Account__c>();       
        for(fsCore__Bank_Account__c bankAccount : bankAccounts){
            accountToBankAccountMap.put(bankAccount.fsCore__Account_Name__c, bankAccount);
        }

        //prepare application Id to existing direct debit of type recurring and source Repayment Schedule map
        List<fsCore__Lending_Application_Direct_Debit__c> existingDirectDebits
            = [SELECT Id, fsCore__Lending_Application_Number__c 
                 FROM fsCore__Lending_Application_Direct_Debit__c 
                WHERE fsCore__Lending_Application_Number__c IN :mApplicationMap.keySet()
                  AND fsCore__Direct_Debit_Type__c = :fsCore.Constants.DIRECT_DEBIT_TYPE_RECURRING 
                  AND fsCore__Debit_Amount_Source__c = :fsCore.Constants.DIRECT_DEBIT_AMOUT_SOURCE_SCHEDULE]; 
        
        Map<Id, fsCore__Lending_Application_Direct_Debit__c> existingDirectDebitMap = new Map<Id, fsCore__Lending_Application_Direct_Debit__c>();
        for(fsCore__Lending_Application_Direct_Debit__c directDebit : existingDirectDebits){
            existingDirectDebitMap.put(directDebit.fsCore__Lending_Application_Number__c, directDebit);
        }
        
        
        //prepare list of new direct debit schedule for eligible applications
        List<fsCore__Lending_Application_Direct_Debit__c> newDirectDebitList = new List<fsCore__Lending_Application_Direct_Debit__c>();
        
        for(fsCore__Lending_Application__c app : mApplicationMap.values()){
            //if direct debit of type recurring and source Repayment Schedule already exists then skip
            if (existingDirectDebitMap.containsKey(app.Id)){ continue; }
            
            //if application does ho have an applicant then skip
            if (!appToApplicantMap.containsKey(app.Id)){ continue; }
            Id accountId = appToApplicantMap.get(app.Id).fsCore__Account_Name__c;
            
            //if applicant contact does not have split agreement then skip
            if (!accountToBankAccountMap.containsKey(accountId)){ continue; }
             
            
            fsCore__Lending_Application_Direct_Debit__c newDirectDebit = new fsCore__Lending_Application_Direct_Debit__c();
            newDirectDebit.fsCore__Direct_Debit_Type__c = fsCore.Constants.DIRECT_DEBIT_TYPE_RECURRING;
            newDirectDebit.fsCore__Debit_Amount_Source__c = fsCore.Constants.DIRECT_DEBIT_AMOUT_SOURCE_SCHEDULE;
            newDirectDebit.fsCore__Debit_Amount__c = app.fsCore__Payment_Amount__c;
            newDirectDebit.fsCore__Debit_Cycle__c = app.fsCore__Payment_Cycle__c;
            newDirectDebit.fsCore__Debit_Start_Date__c = app.fsCore__Payment_Start_Date__c;
            newDirectDebit.fsCore__Debit_End_Date__c = app.fsCore__Maturity_Date__c; 
            newDirectDebit.fsCore__First_Debit_Date__c = newDirectDebit.fsCore__Debit_Start_Date__c;
            if (newDirectDebit.fsCore__First_Debit_Date__c != null){
                newDirectDebit.fsCore__Debit_Day__c = newDirectDebit.fsCore__First_Debit_Date__c.day();
            }
            newDirectDebit.fsCore__Reason__c = 'Regular Payment';
            
            if (String.IsNotBlank(app.fsCore__Payment_Cycle__c) && app.fsCore__Payment_Cycle__c.equalsIgnoreCase(fsCore.Constants.CYCLE_TWICE_MONTHLY)){
                newDirectDebit.fsCore__Debit_Start_Date_2__c = app.fsCore__Payment_Start_Date_2__c;
                if (newDirectDebit.fsCore__Debit_Start_Date_2__c != null){
                    newDirectDebit.fsCore__Debit_Day_2__c = newDirectDebit.fsCore__Debit_Start_Date_2__c.day();
                }
            }
            
            newDirectDebit.fsCore__Lending_Application_Number__c = app.Id;
            newDirectDebit.fsCore__Customer_Reference_Number__c = appToApplicantMap.get(app.id).Id;
            newDirectDebit.fsCore__Bank_Account_Name__c = accountToBankAccountMap.get(accountId).Id;
            
            newDirectDebitList.add(newDirectDebit);
        }
        
        System.debug(loggingLevel.ERROR, '-- Number of Direct Debit records for insert : ' + newDirectDebitList.size());
        fsCore.DMLResult directDebitDMLRslt = fscore.LendingApplicationDirectDebitDMLWrapper.getInstance().insertData(newDirectDebitList);
        Database.SaveResult[] ddSaveResult = directDebitDMLRslt.getSaveResult();
         System.debug(loggingLevel.ERROR,'ddSaveResult:--'+ddSaveResult);
        for(Integer i=0; i < ddSaveResult.size(); i++){
            fsCore__Lending_Application_Direct_Debit__c directDebit = newDirectDebitList.get(i);
            if (!ddSaveResult.get(i).isSuccess()) {
                for(Database.Error err : ddSaveResult.get(i).getErrors()){
                    addError(directDebit.fsCore__Lending_Application_Number__c, err, JSON.serialize(newDirectDebitList.get(i)), 'process() while inserting direct debit records');
                }
            }
        }
    }
    
    @testVisible
    private void addError(Id pAppId, Database.Error pError, String pErrorRecord, String pMethod){
        fsCore.ErrorObject errObj = new fsCore.ErrorObject();
        errObj.setErrorRecordId(pAppId);
        errObj.setErrorRecordName(mApplicationMap.get(pAppId).Name);
        errObj.setErrorRecord(pErrorRecord);
        if (pError != null){
            errObj.setErrorCode(String.valueOf(pError.getStatusCode()));
            errObj.setErrorMessage(pError.getMessage());
        }
        errObj.setErrorStackTrace(CLASS_NAME + '.' + pMethod);
        System.debug(loggingLevel.ERROR, '-- Error added : ' + errObj);
        mActionOutput.addError(errObj);
    }
}