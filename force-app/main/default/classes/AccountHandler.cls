/**
* @File Name          : AccountHandler.cls
* @Description        : 
* @Author             : selas
* @Group              : 
* @Last Modified By   : fsDev
* @Last Modified On   : 4/23/2020, 7:23:33 PM
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    11/10/2019   selas     Initial Version
**/
public class AccountHandler {
    
    public static void updateNuDebtAccAndPrgm() {
        
        Set<Id> updatedClientIdsSet = new Set<Id>();
        
        List<nu_dse__Error_log__c> errLogList = new List<nu_dse__Error_log__c>(); 
        List<Account> accountsToProcessList = new List<Account>();
        Set<Id> accountsToProcessIdSet = new Set<Id>();
        
        Map<Id, Account> prizmIdNuDebtaccMap = new Map<Id, Account>();
        Map<Id, nu_dse__Program__c> prizmIdProgramMap = new Map<Id, nu_dse__Program__c>();
        Map<Id, Id> clientIdProgramIdMap = new Map<Id, Id>();
        Map<String, List<nu_dse__Field_mapping__c>> dataFieldMappingMap = new Map<String, List<nu_dse__Field_mapping__c>>();
        
        String applicantRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        String clientRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        
        if (SyncBetweenPrizmAndNuDebt.executeApplicantToClient == True) {
            
            try {            
                
                dataFieldMappingMap = returnFieldMappingMap();
                
                for (Account acc : (List<Account>)Trigger.new) {
                    
                    if (acc.recordTypeId == applicantRecordId && SyncBetweenPrizmAndNuDebt.accIdSet.contains(acc.Id) == FALSE) {
                        
                        SyncBetweenPrizmAndNuDebt.accIdSet.add(acc.Id); 
                        
                        for (String dataMappingName : dataFieldMappingMap.keySet()) {
                            
                            Boolean breakDataMapping = False;
                            
                            if (dataMappingName == 'PrizmAccountToNuDebtAccount' || dataMappingName == 'PrizmAccountToNuDebtProgram') {
                                
                                List<nu_dse__Field_mapping__c> fieldMappingList = dataFieldMappingMap.get(dataMappingName);
                                
                                if (fieldMappingList.isEmpty() == false) {
                                    
                                    for (nu_dse__Field_mapping__c fieldMapInstance : fieldMappingList) {
                                        
                                        if (fieldMapInstance.nu_dse__Target_Field__c !=null 
                                            && ((Trigger.isUpdate && String.isNotBlank(fieldMapInstance.nu_dse__Source_Field__c) && acc.get(fieldMapInstance.nu_dse__Source_Field__c) != Trigger.oldMap.get(acc.Id).get(fieldMapInstance.nu_dse__Source_Field__c)))) {
                                                
                                                accountsToProcessList.add(acc);
                                                accountsToProcessIdSet.add(acc.Id); 
                                                breakDataMapping = True;
                                                break;
                                            }
                                    }
                                    
                                    if (breakDataMapping == True) {
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
                
                System.debug('accountsToProcessList'+accountsToProcessList);
                
                if (accountsToProcessList.isEmpty() == False) {
                    
                    Set<Id> clientPrizmExternalIdSet = new Set<Id>();
                    
                    for (Account accountInst : [SELECT Id, Prizm_External_Id__c FROM Account WHERE Prizm_External_Id__c IN :accountsToProcessIdSet]) {
                        
                        clientPrizmExternalIdSet.add(accountInst.Prizm_External_Id__c);
                    }
                    
                    System.debug('clientPrizmExternalIdSet-->'+clientPrizmExternalIdSet);
                    
                    for (Account acc : accountsToProcessList) {
                        
                        if (clientPrizmExternalIdSet.contains(acc.Id) == True) {
                            
                            Account clientAccInstance = new Account();
                            nu_dse__Program__c clientProgramInstance = new nu_dse__Program__c();
                            clientAccInstance.Prizm_External_Id__c = acc.Id;
                            clientAccInstance.RecordTypeId = clientRecordId;
                            
                            String errMsg = '';
                            nu_dse__Error_log__c errLog = new nu_dse__Error_log__c();
                            
                            for (String dataMappingName : dataFieldMappingMap.keySet()) {
                                
                                if (dataMappingName == 'PrizmAccountToNuDebtAccount' || dataMappingName == 'PrizmAccountToNuDebtProgram') {
                                    
                                    List<nu_dse__Field_mapping__c> fieldMappingList = dataFieldMappingMap.get(dataMappingName);
                                    
                                    if (fieldMappingList.isEmpty() == false) {
                                        
                                        for (nu_dse__Field_mapping__c fieldMapInstance : fieldMappingList) {
                                            
                                            if (((fieldMapInstance.nu_dse__setDefaultValue__c == TRUE && String.isBlank(fieldMapInstance.nu_dse__Default_Value__c))
                                                 ||(fieldMapInstance.nu_dse__setDefaultValue__c == FALSE && (fieldMapInstance.nu_dse__Source_Field__c == null 
                                                                                                             || acc.get(fieldMapInstance.nu_dse__Source_Field__c) == null)))
                                                && fieldMapInstance.nu_dse__Is_Required__c == TRUE) {
                                                    
                                                    errMsg += fieldMapInstance.nu_dse__Target_Field__c + ' is Required. ';
                                                    
                                                } else {
                                                    
                                                    if (dataMappingName == 'PrizmAccountToNuDebtAccount') {
                                                        
                                                        if (fieldMapInstance.nu_dse__setDefaultValue__c == TRUE) {
                                                            
                                                            clientAccInstance.put(fieldMapInstance.nu_dse__Target_Field__c, fieldMapInstance.nu_dse__Default_Value__c);
                                                            
                                                        } else if (fieldMapInstance.nu_dse__Source_Field__c!=null){
                                                            
                                                            clientAccInstance.put(fieldMapInstance.nu_dse__Target_Field__c, acc.get(fieldMapInstance.nu_dse__Source_Field__c));
                                                        }                                    
                                                    }
                                                    
                                                    if (dataMappingName == 'PrizmAccountToNuDebtProgram') {
                                                        
                                                        if (fieldMapInstance.nu_dse__setDefaultValue__c == TRUE) {
                                                            
                                                            clientProgramInstance.put(fieldMapInstance.nu_dse__Target_Field__c, fieldMapInstance.nu_dse__Default_Value__c);
                                                            
                                                        } else if (fieldMapInstance.nu_dse__Source_Field__c!=null) {
                                                            
                                                            clientProgramInstance.put(fieldMapInstance.nu_dse__Target_Field__c, acc.get(fieldMapInstance.nu_dse__Source_Field__c));
                                                        }  
                                                    }
                                                }
                                        } 
                                    }
                                }
                            }
                            
                            if(String.isNotBlank(errMsg)) {
                                
                                errLog.nu_dse__Class_Method__c = 'Account.insertNewAccount';
                                errLog.nu_dse__Error_Causing_Record_Id__c = acc.Id;
                                errLog.nu_dse__User_Context__c = UserInfo.getName();
                                errLog.nu_dse__Message__c = errMsg;
                                errLogList.add(errLog);    
                                
                                System.debug('errLogList-->'+errLogList);
                                
                            } else {
                                
                                prizmIdNuDebtAccMap.put(acc.Id,clientAccInstance);
                                prizmIdProgramMap.put(acc.Id,clientProgramInstance);
                            }
                        }
                    }
                    System.debug('prizmIdNuDebtAccMap------>'+prizmIdNuDebtAccMap);
                    
                    if(prizmIdNuDebtAccMap.isEmpty() == false) {
                        
                        SyncBetweenPrizmAndNuDebt.executeClientToApplicant = False;
                        
                        List<Database.UpsertResult> clientUpsertResultList = Database.upsert(prizmIdNuDebtAccMap.values(),Account.Prizm_External_Id__c,false);
                        
                        SyncBetweenPrizmAndNuDebt.executeClientToApplicant = True;
                        
                        if (clientUpsertResultList != null && clientUpsertResultList.isEmpty() == False) {
                            
                            for (Database.UpsertResult clientUpsertResult : clientUpsertResultList) {
                                
                                if (clientUpsertResult.isSuccess() == FALSE) {
                                    
                                    nu_dse__Error_log__c errLog = new nu_dse__Error_log__c();
                                    List<String> errMsgs = new List<String>();
                                    
                                    for (Database.Error err: clientUpsertResult.getErrors()) {
                                        
                                        errMsgs.add(err.getStatusCode() + ' | Fields : ' + String.join(err.getFields(),', ') + ' | Message : ' + err.getMessage());
                                    }
                                    
                                    errLog.nu_dse__Class_Method__c = 'Account.insertNewAccount';
                                    errLog.nu_dse__Error_Causing_Record_Id__c = clientUpsertResult.getId();
                                    errLog.nu_dse__User_Context__c = UserInfo.getName();
                                    errLog.nu_dse__Message__c = String.join(errMsgs, '\n');
                                    
                                    errLogList.add(errLog);
                                    
                                } else {
                                    
                                    if (clientUpsertResult.isCreated() == False && clientUpsertResult.getId() != null) {
                                        
                                        updatedClientIdsSet.add(clientUpsertResult.getId());
                                    }
                                }
                            }
                            
                            if (updatedClientIdsSet.isEmpty() == False) {
                                
                                for (nu_dse__Program__c programRec : [SELECT Id, nu_dse__Account__c FROM nu_dse__Program__c 
                                                                      WHERE nu_dse__Account__c IN :updatedClientIdsSet]) {
                                                                          
                                                                          clientIdProgramIdMap.put(programRec.nu_dse__Account__c, programRec.Id);
                                                                      }
                            }
                        }
                    }
                    
                    for (Id accId : prizmIdProgramMap.keySet()) {
                        
                        Id clientId = prizmIdNuDebtAccMap.get(accId).Id;
                        
                        if (clientId != null) {
                            
                            prizmIdProgramMap.get(accId).nu_dse__Account__c = clientId;
                            
                            if (clientIdProgramIdMap.containsKey(clientId)) {
                                
                                prizmIdProgramMap.get(accId).Id = clientIdProgramIdMap.get(clientId);
                            }
                            
                        } else {
                            
                            prizmIdProgramMap.remove(accId);
                        }
                    }
                    
                    if (prizmIdProgramMap.isEmpty() == false) {
                        
                        SyncBetweenPrizmAndNuDebt.executeNuDebtProgramToApplicant = False;
                        
                        List<Database.UpsertResult> programUpsertResultList = Database.upsert(prizmIdProgramMap.values(), false);
                        
                        SyncBetweenPrizmAndNuDebt.executeNuDebtProgramToApplicant = True;
                        
                        for (Database.UpsertResult result : programUpsertResultList) {
                            
                            if (result.isSuccess() == FALSE) {
                                
                                nu_dse__Error_log__c errLog = new nu_dse__Error_log__c();
                                List<String> errMsgs = new List<String>();
                                
                                for (Database.Error err: result.getErrors()) {
                                    
                                    errMsgs.add(err.getStatusCode() + ' | Fields : ' + String.join(err.getFields(),', ') + ' | Message : ' + err.getMessage());
                                }
                                
                                errLog.nu_dse__Class_Method__c = 'Account.insertNewAccount';
                                errLog.nu_dse__Error_Causing_Record_Id__c = result.getId();
                                errLog.nu_dse__User_Context__c = UserInfo.getName();
                                errLog.nu_dse__Message__c = String.join(errMsgs, '\n');
                                
                                errLogList.add(errLog);
                            }
                        }
                    }
                    System.debug('errLogList'+errLogList);
                    insert errLogList;
                }                
            } catch(Exception e) {
                
                system.debug('eeeee:::'+e);
                nu_dse__Error_log__c errLog = new nu_dse__Error_log__c();
                errLog.nu_dse__Class_Method__c = 'Account.insertNewAccount';
                errLog.nu_dse__User_Context__c = UserInfo.getName();
                errLog.nu_dse__Stack_Trace__c = e.getStackTraceString();
                errLog.nu_dse__Message__c = e.getMessage();
                insert errLog;
            }
        }
    }
    
    /*
    Commented by Aniket as we have the same account record shared between PRIZM and NuPay, so no need to have a sync start
    public static void nuDebtAccountToPrizmAccountSync() {
        
        Map<String, List<nu_dse__Field_mapping__c>> dataMappingNameAndItsFieldMappingMap = new Map<String, List<nu_dse__Field_mapping__c>>();
        String applicantRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        String clientRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        
        List<nu_dse__Error_log__c> errorLogList = new List<nu_dse__Error_log__c>();
        
        try {
            
            if(Trigger.new.isEmpty() == false && SyncBetweenPrizmAndNuDebt.executeClientToApplicant == True) {
                
                List<Account> accountsToUpdateList = new List<Account>();
                List<Id> clientAccountIdList = new List<Id>();
                
                //call returnFieldMappingMap() method
                dataMappingNameAndItsFieldMappingMap = returnFieldMappingMap();
                List<nu_dse__Field_mapping__c> accntToAccntFieldMappingList = dataMappingNameAndItsFieldMappingMap.get('NuDebtAccountToPrizmAccount');
                List<Account> prizmAccountUpsertedList = new List<Account>();
                
                List<Account> accountsToProcessList = new List<Account>();
                
                for(Account clientAccInst : (List<Account>)Trigger.new) {
                    
                    if(clientAccInst.recordTypeId == clientRecordId && SyncBetweenPrizmAndNuDebt.accIdSet.contains(clientAccInst.Id) == false) {
                        
                        SyncBetweenPrizmAndNuDebt.accIdSet.add(clientAccInst.Id); 
                        
                        system.debug('clientAccInst.Id::::::'+clientAccInst.Id);
                        if (accntToAccntFieldMappingList.isEmpty() != null) {
                            
                            for (nu_dse__Field_mapping__c fieldMapInstance : accntToAccntFieldMappingList) {
                                
                                if(fieldMapInstance.nu_dse__Target_Field__c !=null 
                                   && (Trigger.isInsert || (Trigger.isUpdate && (fieldMapInstance.nu_dse__Source_Field__c ==null 
                                                                                 || clientAccInst.get(fieldMapInstance.nu_dse__Source_Field__c) != Trigger.oldMap.get(clientAccInst.Id).get(fieldMapInstance.nu_dse__Source_Field__c))))) {
                                                                                     
                                                                                     accountsToProcessList.add(clientAccInst); 
                                                                                     break;             
                                                                                 }
                            }
                        }
                    }
                }
                
                for(Account clientAccInst : accountsToProcessList) {
                    
                    Account prizmAccountInstance = new Account();
                    prizmAccountInstance.RecordTypeId = applicantRecordId;
                    
                    //Update/Create Prizm account based on Prizm_External_Id__c in Nudebt Client...
                    prizmAccountInstance.Id = clientAccInst.Prizm_External_Id__c;
                    
                    String errorMessage = '';
                    //error obj instance
                    nu_dse__Error_log__c errorLog = new nu_dse__Error_log__c();
                    
                    if (accntToAccntFieldMappingList.isEmpty() != null) {
                        
                        for(nu_dse__Field_mapping__c fieldMapInstance : accntToAccntFieldMappingList) {
                            
                            if(((fieldMapInstance.nu_dse__setDefaultValue__c == TRUE && String.isBlank(fieldMapInstance.nu_dse__Default_Value__c))||
                                (fieldMapInstance.nu_dse__setDefaultValue__c == FALSE && (fieldMapInstance.nu_dse__Source_Field__c == null 
                                                                                          || clientAccInst.get(fieldMapInstance.nu_dse__Source_Field__c) == null))) && fieldMapInstance.nu_dse__Is_Required__c == TRUE) {
                                                                                              
                                                                                              errorMessage += fieldMapInstance.nu_dse__Target_Field__c + ' is Required. ';
                                                                                              
                                                                                          } else {
                                                                                              
                                                                                              if(fieldMapInstance.nu_dse__setDefaultValue__c == TRUE) {
                                                                                                  
                                                                                                  prizmAccountInstance.put(fieldMapInstance.nu_dse__Target_Field__c, fieldMapInstance.nu_dse__Default_Value__c);
                                                                                                  
                                                                                              } else if(fieldMapInstance.nu_dse__Source_Field__c!=null) {
                                                                                                  
                                                                                                  prizmAccountInstance.put(fieldMapInstance.nu_dse__Target_Field__c,clientAccInst.get(fieldMapInstance.nu_dse__Source_Field__c));
                                                                                              }
                                                                                          }
                        }
                    }
                    
                    if(String.isNotBlank(errorMessage)) {
                        
                        errorLog.nu_dse__Class_Method__c = 'Account.insertNewAccount';
                        errorLog.nu_dse__Error_Causing_Record_Id__c = clientAccInst.Id;
                        errorLog.nu_dse__User_Context__c = UserInfo.getName();
                        errorLog.nu_dse__Message__c = errorMessage;
                        errorLogList.add(errorLog);    
                        
                    } else {
                        
                        //If no error log create for particular Account, then DML it.
                        prizmAccountUpsertedList.add(prizmAccountInstance);
                        clientAccountIdList.add(clientAccInst.Id);
                    }       
                }
                
                if (prizmAccountUpsertedList.isEmpty() == False) {
                    
                    SyncBetweenPrizmAndNuDebt.executeApplicantToClient = False;
                    
                    List<Database.UpsertResult> upsertPrizmAccountResult = Database.upsert(prizmAccountUpsertedList, false); 
                    
                    SyncBetweenPrizmAndNuDebt.executeApplicantToClient = True;
                    
                    Integer counter = 0;
                    
                    for (Database.UpsertResult result : upsertPrizmAccountResult) {
                        
                        if(result.isSuccess() == FALSE) {
                            
                            nu_dse__Error_log__c errorLog = new nu_dse__Error_log__c();
                            List<String> errMsgs = new List<String>();
                            
                            for (Database.Error err: result.getErrors()) {
                                
                                errMsgs.add(err.getStatusCode() + ' | Fields : ' + String.join(err.getFields(),', ') + ' | Message : ' + err.getMessage());
                            }
                            
                            errorLog.nu_dse__Class_Method__c = 'Account.insertNewPrizmAccount-upsertingPrizmAccount';
                            errorLog.nu_dse__Error_Causing_Record_Id__c = result.getId();
                            errorLog.nu_dse__User_Context__c = UserInfo.getName();
                            errorLog.nu_dse__Message__c = String.join(errMsgs, '\n');
                            
                            errorLogList.add(errorLog);
                            
                        } else if (result.isSuccess() == TRUE && result.isCreated() == TRUE) {
                            
                            System.debug('Success-->'+result.getId());
                            Account accountNewInstance = new Account();
                            accountNewInstance.Id = clientAccountIdList[counter];
                            accountNewInstance.Prizm_External_Id__c = result.getId();
                            accountsToUpdateList.add(accountNewInstance);
                            System.debug('Success-->'+accountsToUpdateList);
                        }
                        counter++;
                    }
                }
                
                if (accountsToUpdateList.isEmpty() == False) {
                    
                    SyncBetweenPrizmAndNuDebt.executeClientToApplicant = False;
                    
                    List<Database.SaveResult> upsertClientAccountResult = Database.update(accountsToUpdateList, false); 
                    
                    SyncBetweenPrizmAndNuDebt.executeClientToApplicant = True;
                    
                    System.debug('Success-->'+accountsToUpdateList);
                    
                    for (Database.SaveResult result : upsertClientAccountResult) {
                        
                        if(result.isSuccess() == FALSE) {
                            
                            nu_dse__Error_log__c errorLog = new nu_dse__Error_log__c();
                            List<String> errMsgs = new List<String>();
                            
                            for (Database.Error err: result.getErrors()) {
                                
                                errMsgs.add(err.getStatusCode() + ' | Fields : ' + String.join(err.getFields(),', ') + ' | Message : ' + err.getMessage());
                            }
                            
                            errorLog.nu_dse__Class_Method__c = 'Account.insertNewPrizmAccount-updatingClientRecord';
                            errorLog.nu_dse__Error_Causing_Record_Id__c = result.getId();
                            errorLog.nu_dse__User_Context__c = UserInfo.getName();
                            errorLog.nu_dse__Message__c = String.join(errMsgs, '\n');
                            
                            errorLogList.add(errorLog);
                        }
                    }
                }
            }
            
        } catch(Exception e) {
            
            nu_dse__Error_log__c errorLog = new nu_dse__Error_log__c();
            errorLog.nu_dse__Class_Method__c = 'Account.nuDebtAccountToPrizmAccountSync';
            errorLog.nu_dse__User_Context__c = UserInfo.getName();
            errorLog.nu_dse__Message__c = e.getMessage();
            insert errorLog;
        }
        insert errorLogList;
    }Commented by Aniket as we have the same account record shared between PRIZM and NuPay, so no need to have a sync END 
    */
    
    public static Map<String,List<nu_dse__Field_mapping__c>> returnFieldMappingMap() {
        
        Map<String,List<nu_dse__Field_mapping__c>> dataFieldMappingMap = new Map<String,List<nu_dse__Field_mapping__c>>();
        
        if(SyncBetweenPrizmAndNuDebt.queryFieldMapping == true) {
            
            for(nu_dse__Field_mapping__c fieldMapingInstance : [SELECT Id, nu_dse__Source_Field__c, nu_dse__Target_Field__c, 
                                                                nu_dse__setDefaultValue__c, nu_dse__Default_Value__c,nu_dse__Is_Required__c,
                                                                nu_dse__Data_Mapping__r.Name FROM nu_dse__Field_mapping__c
                                                                WHERE nu_dse__Data_Mapping__r.Name IN : SyncBetweenPrizmAndNuDebt.DataMappingNameList]) {
                                                                    
                                                                    if(dataFieldMappingMap.containsKey(fieldMapingInstance.nu_dse__Data_Mapping__r.Name) == false) {
                                                                        
                                                                        dataFieldMappingMap.put(fieldMapingInstance.nu_dse__Data_Mapping__r.Name,new List<nu_dse__Field_mapping__c>());
                                                                    } 
                                                                    dataFieldMappingMap.get(fieldMapingInstance.nu_dse__Data_Mapping__r.Name).add(fieldMapingInstance);
                                                                }
            SyncBetweenPrizmAndNuDebt.FieldMappingStaticMap = dataFieldMappingMap;
            SyncBetweenPrizmAndNuDebt.queryFieldMapping = false;
        }
        return SyncBetweenPrizmAndNuDebt.FieldMappingStaticMap;
    } 
    
    public static void updateBAVClientCreated() {
        system.debug('Inside updateBAVClientCreated :');
        Set<ID> accountWithRamsId = new Set<ID>();
        for (Account acc : (List<Account>)Trigger.new) {
            if ((acc.nu_dse__External_RAMS_ID__c != null)
                && (((Account)Trigger.oldMap.get(acc.Id)).nu_dse__External_RAMS_ID__c == null)){
                    accountWithRamsId.add(acc.Id);
                }
        }
        system.debug(' accountWithRamsId :'+accountWithRamsId);
        Id recordTypeClientCreatedId = SFSUtil.getRecordTypeId('Application_Bank_Account_Verification__c', 'Client_Created');
        List<fsCore__Lending_Application__c> lAppList = [select Id
                                                         , Name
                                                         , Loan_Type__c
                                                         , ( SELECT Id  
                                                            , name
                                                            , Deposit_Status__c
                                                            , Verification_Status__c
                                                            , External_RAMS_ID_Formula__c
                                                            FROM Application_Bank_Account_Verification__r
                                                            WHERE Verification_Status__c != 'Cancelled'
                                                            //AND //Is_Client_Created__c = false
                                                           )
                                                         FROM fsCore__Lending_Application__c
                                                         WHERE fsCore__Record_Type_Formula__c = 'VCL_Loan'
                                                         AND fsCore__Primary_Customer_Account__c IN :accountWithRamsId]; 
        List<Application_Bank_Account_Verification__c> bavListToBeUpdated = new List<Application_Bank_Account_Verification__c>();
        for(fsCore__Lending_Application__c lApp: lAppList){
            system.debug(' lApp :'+lApp.Name);
            for(Application_Bank_Account_Verification__c bav: lApp.Application_Bank_Account_Verification__r){
                system.debug(' bav :'+bav.Name);
                bav.Is_Client_Created__c = true;
                bav.recordTypeId = recordTypeClientCreatedId;
                bavListToBeUpdated.add(bav);
            }
        }
        system.debug(' bavListToBeUpdated :'+bavListToBeUpdated);
        update bavListToBeUpdated;
        
    }
    //SUP-349
    public static void updateUserRegistration(){
        system.debug( 'updateUserRegistration');
        List<Account> accList = new List<Account>();
        for(Account acc : (List<Account>)Trigger.new){
            Account oldAcc = (Account)trigger.oldMap.get(acc.id);
            if((acc.Is_VCL_TILA_Accepted__c == true) && (oldAcc.Is_VCL_TILA_Accepted__c == false)){
                accList.add(acc);
            }
        }
        if(accList.size()>0){
            system.debug( 'updateUserRegistration - 2');
            List<fsCore__Lending_Application_Customer__c> applicantList = [Select id, fsCore__Account_Name__c,
                                                                           fsCore__Lending_Application_Number__c
                                                                           from fsCore__Lending_Application_Customer__c
                                                                           where fsCore__Account_Name__c in :accList];
            
            Set<id> appIds = new Set<id>();
            for(fsCore__Lending_Application_Customer__c customer :applicantList){
                appIds.add(customer.fsCore__Lending_Application_Number__c);
            }
            
            List<fsCore__Lending_Application_Customer__c> appLicantList2 = [Select id , fsCore__Lending_Application_Number__c,
                                                                            fsCore__Account_Name__r.Is_VCL_TILA_Accepted__c,
                                                                            fsCore__Lending_Application_Number__r.Pre_TILA_Signed_Date__c,
                                                                            fsCore__Lending_Application_Number__r.Is_User_Registration_Completed__c 
                                                                            from fsCore__Lending_Application_Customer__c
                                                                            where fsCore__Lending_Application_Number__c in :appIds
                                                                            and fsCore__Lending_Application_Number__r.fsCore__Is_Application_Read_Only__c = false
                                                                            and fsCore__Lending_Application_Number__r.fsCore__Record_Type_Formula__c = 'VCL_Loan']; 
            
            System.debug(loggingLevel.Error ,appLicantList2);
            if(appLicantList2.size()>0){
                 system.debug( 'updateUserRegistration - 3');
                Map<fsCore__Lending_Application__c, List<fsCore__Lending_Application_Customer__c>> mapApptoApplicant = new Map<fsCore__Lending_Application__c, List<fsCore__Lending_Application_Customer__c>>();
                
                for(fsCore__Lending_Application_Customer__c customer : appLicantList2){
                    
                    if(mapApptoApplicant.KeySet().contains(customer.fsCore__Lending_Application_Number__r)){
                        List<fsCore__Lending_Application_Customer__c> appLicantList3 = mapApptoApplicant.get(customer.fsCore__Lending_Application_Number__r);
                        appLicantList3.add(customer);
                        mapApptoApplicant.put(customer.fsCore__Lending_Application_Number__r,appLicantList3);
                    }
                    else{
                        List<fsCore__Lending_Application_Customer__c> appLicantList3 = new List<fsCore__Lending_Application_Customer__c>{customer};
                            mapApptoApplicant.put(customer.fsCore__Lending_Application_Number__r,appLicantList3);
                    }
                }
                List<fsCore__Lending_Application__c> appListToUpdate = new List<fsCore__Lending_Application__c>();
                for(fsCore__Lending_Application__c app : mapApptoApplicant.keySet()){
                    List<fsCore__Lending_Application_Customer__c> appLicantList4 = mapApptoApplicant.get(app);
                    boolean userRegistration;
                    for(fsCore__Lending_Application_Customer__c customer : appLicantList4){
                        if(customer.fsCore__Account_Name__r.Is_VCL_TILA_Accepted__c == false){
                            userRegistration = false;
                            break;
                        }
                        else{
                            userRegistration = true;
                        }
                    }
                    System.debug(loggingLevel.Error ,userRegistration);
                    if(userRegistration == true){
                        system.debug( 'updateUserRegistration - 4');
                        app.Is_User_Registration_Completed__c = true;
                        app.Pre_TILA_Signed_Date__c = System.today();
                        appListToUpdate.add(app);
                    }
                }
                
                if(appListToUpdate.size()>0){
                    system.debug( 'updateUserRegistration - 5');
                    fsCore.LendingApplicationTriggerWrapper.getInstance().reset();
                    Database.update(appListToUpdate);
                }
            }
        }
    }
    
}