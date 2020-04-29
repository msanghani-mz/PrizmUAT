public class ProgramHandler {
    
    public static void programToprizmAccountSync() {
        
        if (Trigger.new.isEmpty() == False && SyncBetweenPrizmAndNuDebt.executeNuDebtProgramToApplicant == True) {
            
            Set<Id> nudebtAccountIdSet = new Set<Id>();
            List<nu_dse__Program__c> programUpdatedList = new List<nu_dse__Program__c>();
            List<Account> prizmAccountUpsertedList = new List<Account>();
            Map<Id, Id> nudebtAccountIdAndPrizmAccountId = new Map<Id, Id>();
            List<nu_dse__Error_log__c> errorLogList = new List<nu_dse__Error_log__c>();
            List<nu_dse__Program__c> programToProcessList = new List<nu_dse__Program__c>();
            
            try {
                
                String applicantRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
                
                for (nu_dse__Program__c programInstance : (List<nu_dse__Program__c>)Trigger.new) {
                    
                    if (programInstance.nu_dse__Account__c != null && SyncBetweenPrizmAndNuDebt.processorProgramIdSet.contains(programInstance.Id) == False) {
                        
                        nudebtAccountIdSet.add(programInstance.nu_dse__Account__c);
                        programUpdatedList.add(programInstance);
                        SyncBetweenPrizmAndNuDebt.processorProgramIdSet.add(programInstance.Id);
                    }
                }
                
                if (nudebtAccountIdSet != null) {
                    
                    for (Account clientAccount : [SELECT Id, Prizm_External_Id__c FROM Account WHERE Id IN :nudebtAccountIdSet AND Prizm_External_Id__c != null]) {
                        
                        nudebtAccountIdAndPrizmAccountId.put(clientAccount.Id, clientAccount.Prizm_External_Id__c);
                    }
                }
                
                List<nu_dse__Field_mapping__c> programToPrizmAccntFieldMappingList = AccountHandler.returnFieldMappingMap().get('NuDebtProgramToPrizmAccount');
                system.debug('programToPrizmAccntFieldMappingList--->'+programToPrizmAccntFieldMappingList);    
                for (nu_dse__Program__c programInstance : programUpdatedList) {
                    
                    if (nudebtAccountIdAndPrizmAccountId.containsKey(programInstance.nu_dse__Account__c) == True) {
                        
                        for(nu_dse__Field_mapping__c fieldMapInstance : programToPrizmAccntFieldMappingList) {
                    
                            System.debug('*fieldMapInstance-->'+fieldMapInstance);
                            
                            if(fieldMapInstance.nu_dse__Target_Field__c != null 
                                && (Trigger.isInsert || (Trigger.isUpdate && (fieldMapInstance.nu_dse__Source_Field__c != null  && programInstance.get(fieldMapInstance.nu_dse__Source_Field__c) != Trigger.oldMap.get(programInstance.Id).get(fieldMapInstance.nu_dse__Source_Field__c))))) {
                                
                                programToProcessList.add(programInstance);
                                break;
                            }
                        }
                    }
                }
                
                if (programToProcessList.isEmpty() == False) {
                    
                    for (nu_dse__Program__c programInstance : programToProcessList) {
                        
                        Account prizmAccountInstance = new Account();
                        prizmAccountInstance.Id = nudebtAccountIdAndPrizmAccountId.get(programInstance.nu_dse__Account__c);
                        prizmAccountInstance.RecordTypeId = applicantRecordId;
                        
                        String errorMessage = '';
                        //error obj instance
                        nu_dse__Error_log__c errorLog = new nu_dse__Error_log__c();
                    
                        for(nu_dse__Field_mapping__c fieldMapInstance : programToPrizmAccntFieldMappingList) {
                            
                            System.debug('*fieldMapInstance---->'+fieldMapInstance);
                            
                            if (fieldMapInstance.nu_dse__Is_Required__c == TRUE &&((fieldMapInstance.nu_dse__setDefaultValue__c == TRUE && String.isBlank(fieldMapInstance.nu_dse__Default_Value__c))||
                                (fieldMapInstance.nu_dse__setDefaultValue__c == FALSE && 
                                    (fieldMapInstance.nu_dse__Source_Field__c == null  || programInstance.get(fieldMapInstance.nu_dse__Source_Field__c) == null)))) {
                           
                                errorMessage += fieldMapInstance.nu_dse__Target_Field__c + ' is Required. ';
                                
                            } else {
                                
                                if (fieldMapInstance.nu_dse__setDefaultValue__c == TRUE) {
                                    
                                    System.debug('*prizmAccountInstance-def->'+prizmAccountInstance);
                                    prizmAccountInstance.put(fieldMapInstance.nu_dse__Target_Field__c, fieldMapInstance.nu_dse__Default_Value__c);
                                    
                                } else if (fieldMapInstance.nu_dse__Source_Field__c !=null) {
                                    
                                    System.debug('*prizmAccountInstance-->'+prizmAccountInstance);
                                    prizmAccountInstance.put(fieldMapInstance.nu_dse__Target_Field__c,programInstance.get(fieldMapInstance.nu_dse__Source_Field__c));
                                }
                            }
                        }
                    
                        if(String.isNotBlank(errorMessage)) {
                        
                            errorLog.nu_dse__Class_Method__c = 'ProgramHandler.programToprizmAccountSync';
                            errorLog.nu_dse__Error_Causing_Record_Id__c = programInstance.Id;
                            errorLog.nu_dse__User_Context__c = UserInfo.getUserName();
                            errorLog.nu_dse__Message__c = errorMessage;
                            errorLogList.add(errorLog);    
                        
                        } else {
                            
                            //If no error log create for particular Account, then DML it.
                            prizmAccountUpsertedList.add(prizmAccountInstance);
                        }  
                    }
                    
                    System.debug('prizmAccountUpsertedList-->'+ prizmAccountUpsertedList);
                        
                    if (prizmAccountUpsertedList.isEmpty() == False) {
                            
                        SyncBetweenPrizmAndNuDebt.executeApplicantToClient = False;
                        
                        List<Database.SaveResult> upsertprizmAccountResult = Database.update(prizmAccountUpsertedList,false); 
                        
                        SyncBetweenPrizmAndNuDebt.executeApplicantToClient = True;
                        
                        System.debug('*result-->'+upsertprizmAccountResult);
                        
                        for (Database.SaveResult result : upsertprizmAccountResult) {
                    
                            if (result.isSuccess() == FALSE) {
                                
                                nu_dse__Error_log__c errorLog = new nu_dse__Error_log__c();
                                List<String> errMsgs = new List<String>();
                                                    
                                for (Database.Error err: result.getErrors()) {
                            
                                    errMsgs.add(err.getStatusCode() + ' | Fields : ' + String.join(err.getFields(),', ') + ' | Message : ' + err.getMessage());
                                }
                                
                                errorLog.nu_dse__Class_Method__c = 'ProgramHandler.programToprizmAccountSync-updatingprizmAccount';
                                errorLog.nu_dse__Error_Causing_Record_Id__c = result.getId();
                                errorLog.nu_dse__User_Context__c = UserInfo.getUserName();
                                errorLog.nu_dse__Message__c = String.join(errMsgs, '\n');
                                
                                errorLogList.add(errorLog);
                            }
                        }
                    }
                }
                
            } catch (Exception e) {
                
                nu_dse__Error_log__c errorLog = new nu_dse__Error_log__c();
                errorLog.nu_dse__Class_Method__c = 'ProgramHandler.nuDebtAccountToprizmAccountSync';
                errorLog.nu_dse__User_Context__c = UserInfo.getUserName();
                errorLog.nu_dse__Message__c = e.getMessage();
                errorLogList.add(errorLog);
            }
            
            if (errorLogList.isEmpty() == false) {
                
                insert errorLogList;
            }
        }
    }
}