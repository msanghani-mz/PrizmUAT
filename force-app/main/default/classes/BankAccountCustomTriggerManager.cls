/**
* Class Name  : BankAccountCustomTriggerManager 
* Description : This class handles the custom logic for fsCore.BankAccountTrigger
* Author      : Financial Spectra
* 
*/
global with sharing class BankAccountCustomTriggerManager implements fsCore.TriggerManager {
    private static final String CLASS_NAME = 'BankAccountCustomTriggerManager';
    public static boolean mIsExecuting = false;
    
    global void beforeInsert(List<sObject> pNewRecList){}
    global void beforeUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap){}
    global void beforeDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap){}
    global void afterInsert(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap){
        createBAVTaskOnInsert((List<fsCore__Bank_Account__c>)pNewRecList);
        updateNuDebtBankAccountOnInsert((List<fsCore__Bank_Account__c>)pNewRecList);
    }
    
    global void afterUpdate(List<sObject> pNewRecList, List<sObject> pOldRecList, Map<Id, sObject> pNewRecMap, Map<Id, sObject> pOldRecMap){
        createBAVTaskOnUpdate((List<fsCore__Bank_Account__c>)pNewRecList, (Map<Id, fsCore__Bank_Account__c>)pOldRecMap);
        updateNuDebtBankAccountOnUpdate((List<fsCore__Bank_Account__c>)pNewRecList, (Map<Id, fsCore__Bank_Account__c>)pOldRecMap);
    }
    
    private static void createBAVTaskOnInsert(List<fsCore__Bank_Account__c> pNewRecList){        
        Set<id> newAccountIds     = new Set<id>();   
        for(fsCore__Bank_Account__c bankAcc : pNewRecList){        
            newAccountIds.add(bankAcc.fsCore__Contact_Name__c);            
        }
        if(newAccountIds.size()>0){      
           // BankAccountTriggerHandler.TaskForNewBankAccounts(newAccountIds);
        }           
    }
    
    private static void createBAVTaskOnUpdate(List<fsCore__Bank_Account__c> pNewRecList, Map<Id, fsCore__Bank_Account__c> pOldRecMap){
        Set<id> updatedAccountIds = new Set<id>();
        for(fsCore__Bank_Account__c bankAcc : pNewRecList){               
            if((bankAcc.fsCore__Bank_Account_Number__c != pOldRecMap.get(bankAcc.id).fsCore__Bank_Account_Number__c) ||
               (bankAcc.fsCore__Bank_Account_Holder_Name__c != pOldRecMap.get(bankAcc.id).fsCore__Bank_Account_Holder_Name__c)||
               (bankAcc.fsCore__Bank_Account_Type__c != pOldRecMap.get(bankAcc.id).fsCore__Bank_Account_Type__c)||
               (bankAcc.fsCore__Bank_Branch_Name__c != pOldRecMap.get(bankAcc.id).fsCore__Bank_Branch_Name__c)||
               (bankAcc.fsCore__Bank_Identification_Code__c != pOldRecMap.get(bankAcc.id).fsCore__Bank_Identification_Code__c)||
               (bankAcc.fsCore__Bank_Name__c != pOldRecMap.get(bankAcc.id).fsCore__Bank_Name__c)){
                   updatedAccountIds.add(bankAcc.fsCore__Contact_Name__c);   
               }                    
        }
        
        if(updatedAccountIds.size()>0){      
           // BankAccountTriggerHandler.TaskForUpdatedBankAccounts(updatedAccountIds);
        } 
        
    }
    
    private static void updateNuDebtBankAccountOnInsert(List<fsCore__Bank_Account__c> pNewRecList ){
        
        Set<id> eligibleAccounts   = new Set<id>();
        Map<id,fsCore__Bank_Account__c> mapApplicantToBankAccounts = new Map<id,fsCore__Bank_Account__c>();
        
        for(fsCore__Bank_Account__c bankAcc : pNewRecList){ 
            if(bankAcc.fsCore__Is_Primary__c == true ){
                eligibleAccounts.add(bankAcc.fsCore__Contact_Name__c);
                mapApplicantToBankAccounts.put(bankAcc.fsCore__Contact_Name__c, bankAcc);
            }                   
        }
        
        if(eligibleAccounts.size()>0){
            
            List<fsCore__Lending_Application_Customer__c> applicants  = [Select id ,
                                                                         fsCore__Contact_Name__c,
                                                                         fsCore__Account_Name__c,
                                                                         fsCore__Lending_Application_Number__c,
                                                                         fsCore__Lending_Application_Number__r.Is_Client_Created__c,
                                                                         fsCore__Lending_Application_Number__r.Name
                                                                         from fsCore__Lending_Application_Customer__c
                                                                         where fsCore__Contact_Name__c in :eligibleAccounts
                                                                         and fsCore__Lending_Application_Number__r.Is_Client_Created__c = true];
            
            
            if(applicants.size()>0){
                
                Set<id> accIds = new Set<id>();
                Map<id , fsCore__Lending_Application__c> mapBankAccToApplication = new Map<id , fsCore__Lending_Application__c>();
                Map<id , id> mapConIdsToAccIds = new Map<id,id>();
                for(fsCore__Lending_Application_Customer__c applicant : applicants){
                    accIds.add(applicant.fsCore__Contact_Name__c);
                    mapConIdsToAccIds.put(applicant.fsCore__Contact_Name__c,applicant.fsCore__Account_Name__c );
                    mapBankAccToApplication.put(mapApplicantToBankAccounts.get(applicant.fsCore__Contact_Name__c).id , applicant.fsCore__Lending_Application_Number__r);
                }
                
                List<AggregateResult> aggResult =  [Select count(id) num  ,
                                                    fsCore__Contact_Name__c 
                                                    from fsCore__Bank_Account__c 
                                                    where fsCore__Contact_Name__c in :accIds
                                                    GROUP BY fsCore__Contact_Name__c];
                
                System.debug(loggingLevel.ERROR,'aggResult '+ aggResult );
                
                List<fsCore__Bank_Account__c> finalBankAccounts = new List<fsCore__Bank_Account__c>();
                Set<id> accountIds = new Set<id>();
                for(AggregateResult agg :aggResult){
                    if((Integer)agg.get('num') > 1){
                        System.debug(loggingLevel.ERROR,'inside  '); 
                        accountIds.add(mapConIdsToAccIds.get((Id)agg.get('fsCore__Contact_Name__c')));
                        finalBankAccounts.add(mapApplicantToBankAccounts.get((Id)agg.get('fsCore__Contact_Name__c')));
                    }
                }
                if(finalBankAccounts.size()>0){             
                    updateNuDebtBankAccount(accountIds,finalBankAccounts , mapBankAccToApplication , mapConIdsToAccIds); 
                }                        
            }        
        }
    }
    
    private static void updateNuDebtBankAccountOnUpdate(List<fsCore__Bank_Account__c> pNewRecList , Map<Id, fsCore__Bank_Account__c> pOldRecMap){
        
        Set<id> eligibleAccounts   = new Set<id>();
        Map<id,fsCore__Bank_Account__c> mapApplicantToBankAccounts = new Map<id,fsCore__Bank_Account__c>();
        
        for(fsCore__Bank_Account__c bankAcc : pNewRecList){ 
            if((bankAcc.fsCore__Is_Primary__c) &&  (!pOldRecMap.get(bankAcc.id).fsCore__Is_Primary__c)){
                eligibleAccounts.add(bankAcc.fsCore__Contact_Name__c);
                mapApplicantToBankAccounts.put(bankAcc.fsCore__Contact_Name__c, bankAcc);
            }                   
        }
        
        if(eligibleAccounts.size()>0){
            
            List<fsCore__Lending_Application_Customer__c> applicants =  [Select id , fsCore__Contact_Name__c,
                                                                         fsCore__Account_Name__c,
                                                                         fsCore__Lending_Application_Number__c,
                                                                         fsCore__Lending_Application_Number__r.Is_Client_Created__c,
                                                                         fsCore__Lending_Application_Number__r.Name
                                                                         from fsCore__Lending_Application_Customer__c
                                                                         where fsCore__Contact_Name__c in :eligibleAccounts
                                                                         and fsCore__Lending_Application_Number__r.Is_Client_Created__c = true];
            
            
            if(applicants.size()>0){
                
                System.debug(loggingLevel.ERROR,'applicants '+ applicants );
                Set<id> accountIds = new Set<id>();
                Map<id , id> mapConIdsToAccIds = new Map<id,id>();
                List<fsCore__Bank_Account__c> finalBankAccounts = new List<fsCore__Bank_Account__c>();
                Map<id , fsCore__Lending_Application__c> mapBankAccToApplication = new Map<id , fsCore__Lending_Application__c>();
                for(fsCore__Lending_Application_Customer__c applicant : applicants){
                    finalBankAccounts.add(mapApplicantToBankAccounts.get(applicant.fsCore__Contact_Name__c));
                    mapConIdsToAccIds.put(applicant.fsCore__Contact_Name__c,applicant.fsCore__Account_Name__c );
                    accountIds.add(applicant.fsCore__Account_Name__c);
                    mapBankAccToApplication.put(mapApplicantToBankAccounts.get(applicant.fsCore__Contact_Name__c).id , applicant.fsCore__Lending_Application_Number__r);
                }
                System.debug(loggingLevel.ERROR,finalBankAccounts );
                updateNuDebtBankAccount(accountIds,finalBankAccounts , mapBankAccToApplication, mapConIdsToAccIds);             
            }  
        }        
    }
    
    
    private static void updateNuDebtBankAccount(Set<id> accountIds ,  List<fsCore__Bank_Account__c> finalBankAccounts , Map<id , fsCore__Lending_Application__c> mapBankAccToApplication , Map<id,id> mapContactIdToAccountId ){
        
        Map<String, List<nu_dse__Field_mapping__c>> mDataFieldMappingMap = AccountHandler.returnFieldMappingMap();
        List<nu_dse__Field_mapping__c> mFieldMapBankAccList = mDataFieldMappingMap.get('PrizmBankAccountToNuDebtBankAccount');
        System.debug(loggingLevel.ERROR, accountIds);
        
        String queryBankAcc = 'SELECT Id, fsCore__Account_Name__c ,fsCore__Contact_Name__c  ';
        
        for (nu_dse__Field_mapping__c fieldMapInstance : mFieldMapBankAccList) {
            
            if (fieldMapInstance.nu_dse__Source_Field__c !=null && queryBankAcc.indexOf('fsCore__Account_Name__r.'+fieldMapInstance.nu_dse__Source_Field__c) == -1 &&
                fieldMapInstance.nu_dse__Source_Field__c != 'Id' && fieldMapInstance.nu_dse__Source_Field__c != 'fsCore__Account_Name__c') {
                    
                    queryBankAcc += ', '+fieldMapInstance.nu_dse__Source_Field__c;
                }
        }
        
        //this is used to query prizmBankAccount
        queryBankAcc += '  FROM fsCore__Bank_Account__c WHERE id IN :finalBankAccounts';
        system.debug(logginglevel.error,'queryBankAcc :'+queryBankAcc);
        
        Map<id ,nu_dse__Program__c> nuDebtProgramsMap =  new Map<id,nu_dse__Program__c> ([Select id , nu_dse__Account__c
                                                                                          from nu_dse__Program__c 
                                                                                          where nu_dse__Account__c in :accountIds]);
        
        
        
        
        List< nu_dse__Bank_Account__c> nuDebtBankAccountList =  [Select id , nu_dse__Program__c
                                                                 from nu_dse__Bank_Account__c 
                                                                 where nu_dse__Program__c in :nuDebtProgramsMap.KeySet()];
        System.debug(loggingLevel.ERROR, nuDebtBankAccountList);
        
        
        
        Map<id,nu_dse__Bank_Account__c> mapAccountToNudebtBankAccount = new Map<id,nu_dse__Bank_Account__c>();
        
        for(nu_dse__Bank_Account__c nuDebtAccount : nuDebtBankAccountList){           
            mapAccountToNudebtBankAccount.put(nuDebtProgramsMap.get(nuDebtAccount.nu_dse__Program__c).nu_dse__Account__c,nuDebtAccount);
        }
        
        List<nu_dse__Bank_Account__c> updatedNuDebtBankAccountList = new List<nu_dse__Bank_Account__c>();
        List<fsCore__Diagnostic_Log__c> errorList = new List<fsCore__Diagnostic_Log__c>();
        
        for(fsCore__Bank_Account__c prizmBankAccInstance : Database.query(queryBankAcc)) {
            
            
            String errMsg = '';
            nu_dse__Error_log__c errLog = new nu_dse__Error_log__c();
            System.debug(LoggingLevel.ERROR, prizmBankAccInstance.fsCore__Account_Name__c);
            System.debug(LoggingLevel.ERROR, mapAccountToNudebtBankAccount);
            nu_dse__Bank_Account__c nuDebtBankAccInstance = mapAccountToNudebtBankAccount.get(mapContactIdToAccountId.get(prizmBankAccInstance.fsCore__Contact_Name__c));
            if(nuDebtBankAccInstance != null){
                System.debug(LoggingLevel.ERROR, nuDebtBankAccInstance);
                nuDebtBankAccInstance.Prizm_External_Id__c = prizmBankAccInstance.Id;
                System.debug(LoggingLevel.ERROR, nuDebtBankAccInstance);
                for (nu_dse__Field_mapping__c fieldMapInstance : mFieldMapBankAccList) {
                    
                    System.debug(LoggingLevel.ERROR, fieldMapInstance);
                    if (fieldMapInstance.nu_dse__Target_Field__c !=null) {
                        
                        // Added by FS for DV-111 to support relationships for address
                        if (((fieldMapInstance.nu_dse__setDefaultValue__c == TRUE && String.isBlank(fieldMapInstance.nu_dse__Default_Value__c))
                             || (fieldMapInstance.nu_dse__setDefaultValue__c == FALSE && (fieldMapInstance.nu_dse__Source_Field__c == null 
                                                                                          || ((!(fieldMapInstance.nu_dse__Source_Field__c.containsIgnoreCase('__r.'))) 
                                                                                              && prizmBankAccInstance.get(fieldMapInstance.nu_dse__Source_Field__c) == null)
                                                                                          || ((fieldMapInstance.nu_dse__Source_Field__c.containsIgnoreCase('__r.')) 
                                                                                              && (prizmBankAccInstance.getSobject(fieldMapInstance.nu_dse__Source_Field__c.SubStringBefore('.'))).get(fieldMapInstance.nu_dse__Source_Field__c.SubStringAfter('.'))== null)       
                                                                                         )))
                            && fieldMapInstance.nu_dse__Is_Required__c == TRUE) {
                                
                                errMsg += fieldMapInstance.nu_dse__Target_Field__c + ' is Required. ';
                                System.debug(LoggingLevel.ERROR, errMsg);
                                
                            }
                        
                        else {
                            
                            if (fieldMapInstance.nu_dse__setDefaultValue__c == TRUE) {
                                
                                nuDebtBankAccInstance.put(fieldMapInstance.nu_dse__Target_Field__c, fieldMapInstance.nu_dse__Default_Value__c);
                                
                            } else if (fieldMapInstance.nu_dse__Source_Field__c!=null){
                                // If added by FS for DV-111 to support relationships for address
                                if (fieldMapInstance.nu_dse__Source_Field__c.containsIgnoreCase('__r.')) {
                                    sObject sObj = prizmBankAccInstance.getSobject(fieldMapInstance.nu_dse__Source_Field__c.SubStringBefore('.')); 
                                    
                                    nuDebtBankAccInstance.put(fieldMapInstance.nu_dse__Target_Field__c, sObj.get(fieldMapInstance.nu_dse__Source_Field__c.SubStringAfter('.')));
                                }else{                                   
                                    nuDebtBankAccInstance.put(fieldMapInstance.nu_dse__Target_Field__c, prizmBankAccInstance.get(fieldMapInstance.nu_dse__Source_Field__c));
                                }
                            }
                        }
                    }
                }
                
                
                if (String.isNotBlank(errMsg)) {
                    fsCore__Diagnostic_Log__c error = fsCore.DiagnosticLogUtil.getErrorLog('BankAccountCustomTriggerManager', 'updateNuDebtBankAccount',
                                                                                           mapBankAccToApplication.get(prizmBankAccInstance.id).id,
                                                                                           mapBankAccToApplication.get(prizmBankAccInstance.id).Name, 
                                                                                           fsCore.Constants.PROCESSING_ERROR, 
                                                                                           errMsg , null);   
                    errorList.add(error);
                    
                } else {
                   /* if(prizmBankAccInstance.Zip__c != null){
                        nuDebtBankAccInstance.nu_dse__Zip__c = prizmBankAccInstance.Zip__c;
                    }
                    if(prizmBankAccInstance.City__c != null){
                        nuDebtBankAccInstance.nu_dse__City__c = prizmBankAccInstance.City__c; 
                    }
                    if(prizmBankAccInstance.State__c != null){
                        nuDebtBankAccInstance.nu_dse__State__c = prizmBankAccInstance.State__c; 
                    }
                    */
                    updatedNuDebtBankAccountList.add(nuDebtBankAccInstance);
                    
                }
            }
        }
        
        if(errorList.size()>0){
            insert errorList;   
        }
        
        if(updatedNuDebtBankAccountList.size()>0){
            update updatedNuDebtBankAccountList;
        }       
        
    }
    
    global void afterDelete(List<sObject> pOldRecList, Map<Id, sObject> pOldRecMap){}
    global void afterUndelete(List<sObject> pNewRecList, Map<Id, sObject> pNewRecMap){}
}