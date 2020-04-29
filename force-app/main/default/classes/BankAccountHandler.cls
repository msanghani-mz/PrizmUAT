public class BankAccountHandler {

    public static void syncToPrizmBankAccount() {
    
        List<nu_dse__Bank_Account__c> nuDebtBankAccTobeUpdated = new List<nu_dse__Bank_Account__c>();
        List<fsCore__Bank_Account__c> prizmBAList = new List<fsCore__Bank_Account__c>();
        List<Id> nuDebtBankAccIdList = new List<Id>();
        List<nu_dse__Error_log__c> errLogList = new List<nu_dse__Error_log__c>();
        
        List<nu_dse__Bank_Account__c> bankAccountsToProcessList = new List<nu_dse__Bank_Account__c>();
        Map<Id, Id> nudebtBankAcctIdPrizmAccountIdMap = new Map<Id, Id>();
        
        try {
        
            if (SyncBetweenPrizmAndNuDebt.executeNuDebtBankAccountToPrizmBankAccount == TRUE) {
            
                if (SyncBetweenPrizmAndNuDebt.isNuDebtBAToPrizmBAFieldMappingQueried == FALSE) {
                
                    SyncBetweenPrizmAndNuDebt.nuDebtBAToPrizmBAfieldMappingsList = [SELECT Id, Name, nu_dse__Source_Field__c, nu_dse__Target_Field__c, 
                                                                                    nu_dse__setDefaultValue__c, nu_dse__Default_Value__c, nu_dse__Is_Required__c 
                                                                                    FROM nu_dse__Field_mapping__c
                                                                                    WHERE nu_dse__Data_Mapping__r.Name IN :SyncBetweenPrizmAndNuDebt.NudebtBAToPrizmBA_dataMappingNamesList];
                    SyncBetweenPrizmAndNuDebt.isNuDebtBAToPrizmBAFieldMappingQueried = TRUE;                                                                
                }
                
                for (nu_dse__Bank_Account__c bankAcc : (List<nu_dse__Bank_Account__c>)Trigger.new) {
                
                    if (SyncBetweenPrizmAndNuDebt.nuDebtBankAccIdStaticSet.contains(bankAcc.Id) == FALSE
                             && bankAcc.nu_dse__Program__c != null) {
                    system.debug(SyncBetweenPrizmAndNuDebt.nuDebtBAToPrizmBAfieldMappingsList);
                        for (nu_dse__Field_Mapping__c fieldMapping : SyncBetweenPrizmAndNuDebt.nuDebtBAToPrizmBAfieldMappingsList) {
                        
                             if ((Trigger.isUpdate && String.isNotBlank(fieldMapping.nu_dse__Source_Field__c) && bankAcc.get(fieldMapping.nu_dse__Source_Field__c) != Trigger.oldMap.get(bankAcc.Id).get(fieldMapping.nu_dse__Source_Field__c))
                                    ) {
                                
                                bankAccountsToProcessList.add(bankAcc);
                                SyncBetweenPrizmAndNuDebt.nuDebtBankAccIdStaticSet.add(bankAcc.Id);
                                break;
                             }
                         }
                    }
                }
                
                if (bankAccountsToProcessList.isEmpty() == False) {
                
                    for (nu_dse__Bank_Account__c bankAcct : [SELECT Id, Name, nu_dse__Program__r.nu_dse__Account__r.Prizm_External_Id__c
                                                                FROM nu_dse__Bank_Account__c WHERE Id IN :bankAccountsToProcessList
                                                                AND nu_dse__Program__r.nu_dse__Account__r.Prizm_External_Id__c != null
                                                                AND nu_dse__Program__r.nu_dse__Account__r.Prizm_External_Id__c != '']) {
                    
                        nudebtBankAcctIdPrizmAccountIdMap.put(bankAcct.Id, bankAcct.nu_dse__Program__r.nu_dse__Account__r.Prizm_External_Id__c);
                    }
                }
                
                for (nu_dse__Bank_Account__c bankAcc : bankAccountsToProcessList) {
                
                    if (nudebtBankAcctIdPrizmAccountIdMap.containsKey(bankAcc.Id)) {
                    
                        nu_dse__Error_log__c errLog = new nu_dse__Error_log__c();
                        String errMsg = '';
                        Boolean isMapped = FALSE; 
                            
                        fsCore__Bank_Account__c prizmBA = new fsCore__Bank_Account__c();
                        prizmBA.Id = bankAcc.Prizm_External_Id__c;
                        prizmBA.fsCore__Account_Name__c = nudebtBankAcctIdPrizmAccountIdMap.get(bankAcc.Id);
                        
                        for (nu_dse__Field_Mapping__c fieldMapping : SyncBetweenPrizmAndNuDebt.nuDebtBAToPrizmBAfieldMappingsList) {
                        
                            if (String.isNotBlank(fieldMapping.nu_dse__Target_Field__c)) {
                            
                                if (fieldMapping.nu_dse__setDefaultValue__c == TRUE) {
                                    
                                    if (String.isBlank(fieldMapping.nu_dse__Default_Value__c) && fieldMapping.nu_dse__Is_Required__c == TRUE) {
                                    
                                        errMsg += fieldMapping.nu_dse__Target_Field__c + ' is required. ';
                                    
                                    } else {
                                    
                                         prizmBA.put(fieldMapping.nu_dse__Target_Field__c, fieldMapping.nu_dse__Default_Value__c);
                                         isMapped = TRUE;
                                    }
                                    
                                } else if (String.isNotBlank(fieldMapping.nu_dse__Source_Field__c)) {
                                    
                                    if (bankAcc.get(fieldMapping.nu_dse__Source_Field__c) == null && fieldMapping.nu_dse__Is_Required__c == TRUE) {
                                        
                                        errMsg += fieldMapping.nu_dse__Target_Field__c + ' is required. ';
                                    } else {
                                    
                                        prizmBA.put(fieldMapping.nu_dse__Target_Field__c , bankAcc.get(fieldMapping.nu_dse__Source_Field__c));
                                        isMapped = TRUE;
                                    }
                                }
                            }
                        }
                        
                        if (String.isNotBlank(errMsg)) {
                    
                            errLog =  createErrorLog('BankAccountHandler.syncToPrizmBankAccount', errMsg, null );
                            errLogList.add(errLog);    
                        
                        } else if (isMapped == TRUE) {
                        
                            prizmBAList.add(prizmBA);
                            nuDebtBankAccIdList.add(bankAcc.Id);                    
                        }
                    }
                }
                
                SyncBetweenPrizmAndNuDebt.executePrizmBankAccountToNuDebtBankAccount = FALSE;
                
                List<Database.UpsertResult> upsertResult = Database.upsert(prizmBAList, false);
                
                SyncBetweenPrizmAndNuDebt.executePrizmBankAccountToNuDebtBankAccount = TRUE;
                
                System.debug('upsertResult--->'+upsertResult);
                Integer counter = 0;   
                for (Database.UpsertResult result : upsertResult) {
                    
                    if(result.isSuccess() == FALSE) {
                        
                        nu_dse__Error_log__c errLog = new nu_dse__Error_log__c();
                        List<String> errMsgs = new List<String>();
                                            
                        for (Database.Error err: result.getErrors()) {
                    
                            errMsgs.add(err.getStatusCode() + ' | Fields : ' + String.join(err.getFields(),', ') + ' | Message : ' + err.getMessage());
                        }
                        errLog =  createErrorLog('BankAccountHandler.syncToPrizmBankAccount', String.join(errMsgs, '\n'), null );
                        errLog.nu_dse__Error_Causing_Record_Id__c = result.getId();
                        errLogList.add(errLog);
                    
                    } else if (result.isSuccess() == TRUE && result.isCreated() == TRUE) {
                    
                        nu_dse__Bank_Account__c bankAcc = new nu_dse__Bank_Account__c();
                        bankAcc.Id = nuDebtBankAccIdList[counter];
                        bankAcc.Prizm_External_Id__c = result.getId();
                        nuDebtBankAccTobeUpdated.add(bankAcc);
                    }
                    counter++;
                }
                
                System.debug('nuDebtBankAccTobeUpdated--->'+JSON.serialize(nuDebtBankAccTobeUpdated));
                
                List<Database.SaveResult> updateResult = Database.update(nuDebtBankAccTobeUpdated, false);
                Integer updateListCounter = 0;
                
                for (Database.SaveResult result : updateResult) {
                    
                    if(result.isSuccess() == FALSE) {
                        
                        nu_dse__Error_log__c errLog = new nu_dse__Error_log__c();
                        List<String> errMsgs = new List<String>();
                                            
                        for (Database.Error err: result.getErrors()) {
                    
                            errMsgs.add(err.getStatusCode() + ' | Fields : ' + String.join(err.getFields(),', ') + ' | Message : ' + err.getMessage());
                        }
                        errLog =  createErrorLog('BankAccountHandler.syncToPrizmBankAccount',
                                                 String.join(errMsgs, '\n') + 'Prizm External Id: '+nuDebtBankAccTobeUpdated[updateListCounter].Prizm_External_Id__c , 
                                                 null );
                        errLog.nu_dse__Error_Causing_Record_Id__c = result.getId();
                        errLogList.add(errLog);
                    }
                    updateListCounter++;
                }
                
                insert errLogList;    
            }
        } catch(Exception e) {
        
             insert createErrorLog('BankAccountHandler.syncToPrizmBankAccount', null, e);
        }
    }
        
    public static nu_dse__Error_log__c createErrorLog(String classMethod, String message, Exception e) {
        
        nu_dse__Error_log__c errLog = new nu_dse__Error_log__c();
        
        errLog.nu_dse__Class_Method__c = classMethod;
        errLog.nu_dse__User_Context__c = UserInfo.getUserName();
        if (e != null) {
        
            errLog.nu_dse__Message__c = e.getMessage();
            errLog.nu_dse__Stack_Trace__c = e.getStackTraceString();
        } else if (String.isNotBlank(message)) {
        
            errLog.nu_dse__Message__c = message;
        }
        return errLog;
    }
}