public class FsCoreBankAccountHandler {

    public static void createBankAccount() {
        
        try {
        
            if (SyncBetweenPrizmAndNuDebt.executePrizmBankAccountToNuDebtBankAccount == TRUE) {
            
                List<fsCore__Bank_Account__c> filteredfsCoreBankAccountList = new List<fsCore__Bank_Account__c>();
                Map<Id, Id> fsCoreBankAcctAndItsAcctIdMap = new Map<Id, Id>();
                Map<Id, Id> accountExternalAndItsBankAcctIdMap = new Map<Id, Id>();
                List<nu_dse__Bank_Account__c> upsertBankAccountList = new List<nu_dse__Bank_Account__c>();
                List<nu_dse__Error_Log__c> errorLogList = new List<nu_dse__Error_Log__c>();
                
                if (SyncBetweenPrizmAndNuDebt.isPrizmBAToNuDebtBA_FieldMappingQueried == FALSE) {
                    
                    SyncBetweenPrizmAndNuDebt.nuDseFieldMappingList =  [SELECT nu_dse__Source_Field__c, nu_dse__setDefaultValue__c, nu_dse__Is_Required__c, nu_dse__Default_Value__c, 
                                                                          nu_dse__Target_Field__c FROM nu_dse__Field_mapping__c 
                                                                          WHERE nu_dse__Field_mapping__c.nu_dse__Data_Mapping__r.Name IN :SyncBetweenPrizmAndNuDebt.PrizmBAToNuDebtBA_dataMappingNamesList];
                    SyncBetweenPrizmAndNuDebt.isPrizmBAToNuDebtBA_FieldMappingQueried = TRUE;
                }
                
                //bankaccountId and accountIntanceId map insert and update
                for (fsCore__Bank_Account__c fsCoreBankAccountInstance : (List<fsCore__Bank_Account__c>)Trigger.new) {
                    
                    if (SyncBetweenPrizmAndNuDebt.newfsCoreBankAccountIdSet.contains(fsCoreBankAccountInstance.Id) == false ) {
                    
                        if (Trigger.isInsert) { 
                            
                            if (fsCoreBankAccountInstance.fsCore__Account_Name__c != null) {
                             
                                fsCoreBankAcctAndItsAcctIdMap.put(fsCoreBankAccountInstance.Id, fsCoreBankAccountInstance.fsCore__Account_Name__c);
                                filteredfsCoreBankAccountList.add(fsCoreBankAccountInstance);
                                SyncBetweenPrizmAndNuDebt.newfsCoreBankAccountIdSet.add(fsCoreBankAccountInstance.Id); 
                            }
                            
                        } else if(Trigger.isUpdate && fsCoreBankAccountInstance.fsCore__Account_Name__c != null) {
                             
                             fsCore__Bank_Account__c oldfsCoreBankAccountInstance = (fsCore__Bank_Account__c)Trigger.oldMap.get(fsCoreBankAccountInstance.Id);
                            
                             for (nu_dse__Field_mapping__c nuDseFieldMappingInstance : SyncBetweenPrizmAndNuDebt.nuDseFieldMappingList) {
                            
                                 if (fsCoreBankAccountInstance.get(nuDseFieldMappingInstance.nu_dse__Source_Field__c) != oldfsCoreBankAccountInstance.get(nuDseFieldMappingInstance.nu_dse__Source_Field__c)) {
                                     
                                     fsCoreBankAcctAndItsAcctIdMap.put(fsCoreBankAccountInstance.Id, fsCoreBankAccountInstance.fsCore__Account_Name__c);//any one field changed break the fieldMap loop
                                     break;     
                                 }                                 
                             }  
                             filteredfsCoreBankAccountList.add(fsCoreBankAccountInstance); 
                             SyncBetweenPrizmAndNuDebt.newfsCoreBankAccountIdSet.add(fsCoreBankAccountInstance.Id); 
                        }
                    }
                }
                                                       
                //Account Id And Program Id Map
                if (fsCoreBankAcctAndItsAcctIdMap.values().isEmpty() == false) {
                    
                    for (nu_dse__Program__c  programInstance : [SELECT Id,nu_dse__Program__c.nu_dse__Account__r.Prizm_External_Id__c FROM nu_dse__Program__c 
                                                                WHERE nu_dse__Program__c.nu_dse__Account__r.Prizm_External_Id__c IN : fsCoreBankAcctAndItsAcctIdMap.values()]) {
                            
                        accountExternalAndItsBankAcctIdMap.put(programInstance.nu_dse__Account__r.Prizm_External_Id__c, programInstance.Id);                         
                    }
                }
                
                //Assign the value to the target field
                if (filteredfsCoreBankAccountList.isEmpty() == false) {
                    
                    for (fsCore__Bank_Account__c fsCoreBankAccountInstance : filteredfsCoreBankAccountList) {
                                     
                        if (fsCoreBankAcctAndItsAcctIdMap.containsKey(fsCoreBankAccountInstance.Id) && accountExternalAndItsBankAcctIdMap.containsKey
                                    (fsCoreBankAcctAndItsAcctIdMap.get(fsCoreBankAccountInstance.Id))) { 
                        
                            nu_dse__Bank_Account__c bankAccountInstance = new nu_dse__Bank_Account__c(nu_dse__Program__c = accountExternalAndItsBankAcctIdMap.get
                                                                              (fsCoreBankAcctAndItsAcctIdMap.get(fsCoreBankAccountInstance.Id)
                                                                              ));
                            String errMessage = '';    
                            Boolean isMapped = FALSE;                                              
                            
                            for (nu_dse__Field_mapping__c nuDseFieldMappingInstance : SyncBetweenPrizmAndNuDebt.nuDseFieldMappingList) {
                                
                                if (String.isNotBlank(nuDseFieldMappingInstance.nu_dse__Target_Field__c)) {  
                                
                                    if (nuDseFieldMappingInstance.nu_dse__setDefaultValue__c == true) {
                                    
                                        if (String.isBlank(nuDseFieldMappingInstance.nu_dse__Default_Value__c) && nuDseFieldMappingInstance.nu_dse__Is_Required__c == true) {
                                        
                                            errMessage += nuDseFieldMappingInstance.nu_dse__Target_Field__c + ' Field is Required. '; 
                                        
                                        } else {
                                         
                                            bankAccountInstance.put(nuDseFieldMappingInstance.nu_dse__Target_Field__c, nuDseFieldMappingInstance.nu_dse__Default_Value__c);
                                            isMapped = TRUE;
                                        }                                      
                                    } else if (String.isNotBlank(nuDseFieldMappingInstance.nu_dse__Source_Field__c)) {
                                        
                                        if (fsCoreBankAccountInstance.get(nuDseFieldMappingInstance.nu_dse__Source_Field__c) == null && nuDseFieldMappingInstance.nu_dse__Is_Required__c == true) {
                                        
                                            errMessage += nuDseFieldMappingInstance.nu_dse__Target_Field__c + ' Field is Required. '; 
                                        
                                        } else {
                                       
                                            bankAccountInstance.put(nuDseFieldMappingInstance.nu_dse__Target_Field__c, fsCoreBankAccountInstance.get(nuDseFieldMappingInstance.nu_dse__Source_Field__c));                                       
                                            isMapped = TRUE;
                                        } 
                                    }   
                                 } 
                            } 
                            System.debug('upsertList ----->'+upsertBankAccountList);                                               
                              
                            if (String.isNotBlank(errMessage)) {
                                
                                nu_dse__Error_Log__c errorLogInstance = new nu_dse__Error_Log__c();
                                errorLogInstance = createErrorLog('FsCoreBankAccountHandler.createBankAccount', errMessage , null);
                                errorLogList.add(errorLogInstance);  
                            } else if(isMapped == TRUE) {
                            
                                upsertBankAccountList.add(bankAccountInstance);
                            }
                        }    
                    } 
                    
                    //Handling error records
                    if (upsertBankAccountList.isEmpty() == false) { 
                        
                       SyncBetweenPrizmAndNuDebt.executeNuDebtBankAccountToPrizmBankAccount = FALSE;
                       
                       Database.UpsertResult[] upsertResults = Database.upsert(upsertBankAccountList, nu_dse__Bank_Account__c.Fields.Prizm_External_Id__c, false);
                       
                       SyncBetweenPrizmAndNuDebt.executeNuDebtBankAccountToPrizmBankAccount = TRUE;
                                            
                       if (upsertResults.isEmpty() == false) {
                            
                            for (Database.UpsertResult upsertResultInstance : upsertResults ) {
                            
                                if (upsertResultInstance.isSuccess() == false) {
                                
                                    String errorMessage = ' ';
                                    nu_dse__Error_Log__c errorLogInstance = new nu_dse__Error_Log__c();                                                                         
                                    for (Database.Error errors : upsertResultInstance.getErrors()) {
                                    
                                        errorMessage += errors.getMessage()+';';
                                    }
                                    errorLogInstance = createErrorLog('FsCoreBankAccountHandler.createBankAccount', errorMessage, null);
                                    errorLogInstance.nu_dse__Error_Causing_Record_Id__c = upsertResultInstance.getId();
                                    errorLogList.add(errorLogInstance);
                                }
                            }                        
                        }  
                    }
                }                       
                System.debug('errorLogList----->'+errorLogList);    
                insert errorLogList;    
            }   
        } 
        
        catch(Exception e) {    
                            
            insert createErrorLog('FsCoreBankAccountHandler.createBankAccount', null, e);
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