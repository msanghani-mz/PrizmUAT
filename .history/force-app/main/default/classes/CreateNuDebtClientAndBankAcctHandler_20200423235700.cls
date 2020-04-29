/**
 * @File Name          : CreateNuDebtClientAndBankAcctHandler.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : abhinav@fsDev
 * @Last Modified On   : 4/19/2020, 11:20:47 PM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    9/22/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class CreateNuDebtClientAndBankAcctHandler {

    Map<String, List<nu_dse__Field_mapping__c>> mDataFieldMappingMap = new Map<String, List<nu_dse__Field_mapping__c>>();
    
    List<nu_dse__Field_mapping__c> mFieldMappingNuDebtList = new List<nu_dse__Field_mapping__c>();
    List<nu_dse__Field_mapping__c> mFieldMappingProgramList = new List<nu_dse__Field_mapping__c>();
    List<nu_dse__Field_mapping__c> mFieldMappingCoClientList = new List<nu_dse__Field_mapping__c>();
    List<nu_dse__Field_mapping__c> mFieldMapAccCoClientList = new List<nu_dse__Field_mapping__c>();
    List<nu_dse__Field_mapping__c> mFieldMapBankAccList = new List<nu_dse__Field_mapping__c>();
    
    Set<Id> mProgramIds = new Set<Id>();
    List<fsCore__Lending_Application__c> mLendingApplicationList = new List<fsCore__Lending_Application__c>();
    

    private void init(Map<String, List<nu_dse__Field_mapping__c>> pDataFieldMappingMap){
       mDataFieldMappingMap = pDataFieldMappingMap;
        
        system.debug(logginglevel.error,mDataFieldMappingMap);
        mFieldMappingNuDebtList = mDataFieldMappingMap.get('PrizmAccountToNuDebtAccount');
        mFieldMappingProgramList = mDataFieldMappingMap.get('PrizmAccountToNuDebtProgram');
        mFieldMappingCoClientList = mDataFieldMappingMap.get('PrizmCoClientAccountToNuDebtAccount');
        mFieldMapBankAccList = mDataFieldMappingMap.get('PrizmBankAccountToNuDebtBankAccount');
        
        //adding two dataMappingList in single list
        mFieldMapAccCoClientList.addAll(mFieldMappingNuDebtList);
        mFieldMapAccCoClientList.addAll(mFieldMappingCoClientList);
        mFieldMapAccCoClientList.addAll(mFieldMappingProgramList);
        
    }
    public CreateNuDebtClientAndBankAcctHandler(List<fsCore__Lending_Application__c> pLendingApplicationList,Map<String, List<nu_dse__Field_mapping__c>> pDataFieldMappingMap) {
        init(pDataFieldMappingMap);
        mLendingApplicationList = pLendingApplicationList;        
    }

    public Set<Id> getProgramIds(){
        return mProgramIds;
    }
    
    public void process() {
        system.debug(logginglevel.error,'mLendingApplicationList::::'+mLendingApplicationList);
        
        Set<Id> fsCoreLendingApplicationIdSet = new Set<Id>();
        Set<Id> accPrizmIdPrimaryCustomerSet = new Set<Id>();
        
        Map<Id, Account> lenIdNuDebtaccMap = new Map<Id, Account>();
        Map<Id, Account> lenAppIdNuDebtaccMap = new Map<Id, Account>();
        Map<Id, nu_dse__Program__c> lenIdProgramMap = new Map<Id, nu_dse__Program__c>();
        Map<Id, Id> prizmIdLenAppIdMap = new Map<Id, Id>();
        Map<Id, Account> ClientIdClientMap = new Map<Id, Account>();
        Map<Id, nu_dse__Bank_Account__c> prizmAccIdNuDebtBankAccMap = new Map<Id, nu_dse__Bank_Account__c>();
        Map<Id, Id> prizmAccIdLenAppId = new Map<Id, Id>();
        Map<String, nu_dse__Fee_Template__c> feeTemplateMap = new Map<String, nu_dse__Fee_Template__c>();
        
        List<nu_dse__Error_log__c> errLogList = new List<nu_dse__Error_log__c>(); 
        List<fsCore__Lending_Application__c> lenAppUpdateList = new List<fsCore__Lending_Application__c>();
        
        try {
            
            Map<Id, nu_dse__Processor__c> processorMap = new Map<Id, nu_dse__Processor__c>();
            Map<String, nu_dse__Processor__c> processorNameMap = new Map<String, nu_dse__Processor__c>();
            for (nu_dse__Processor__c processor: [SELECT Id, Name FROM nu_dse__Processor__c]) {
                processorMap.put(processor.Id, processor);
                processorNameMap.put(processor.Name, processor);
            }
            
            List<nu_dse__Fee_Template__c> feeTemplates = [Select Id, Name, nu_dse__GCS_Fee_Group_Id__c, nu_dse__RAMS_Fee_Group_Id__c From nu_dse__Fee_Template__c];
            for (nu_dse__Fee_Template__c feeTemplate: feeTemplates) {
                feeTemplateMap.put(feeTemplate.Name, feeTemplate);    
            }
            
            for (fsCore__Lending_Application__c fsCoreLendingApplicationInstance : mLendingApplicationList) {
            
                fsCoreLendingApplicationIdSet.add(fsCoreLendingApplicationInstance.Id);
            }
             
            String lenAppQuery = 'SELECT Id, name, fsCore__Account_Name__c, fsCore__Customer_Type__c, fsCore__Lending_Application_Number__c, fsCore__Lending_Application_Number__r.Portfolio_Type__c,'+
                                +' fsCore__Lending_Application_Number__r.Loan_Type__c, fsCore__Account_Name__r.Payment_Account_Number__c, fsCore__Lending_Application_Number__r.Investor_Name__c';
                            
            for (nu_dse__Field_mapping__c fieldMapInstance : mFieldMapAccCoClientList) {
            
                if (fieldMapInstance.nu_dse__Source_Field__c != null && lenAppQuery.indexOf('fsCore__Account_Name__r.'+fieldMapInstance.nu_dse__Source_Field__c) == -1 &&
                    fieldMapInstance.nu_dse__Source_Field__c != 'Id' && fieldMapInstance.nu_dse__Source_Field__c != 'name' &&
                    fieldMapInstance.nu_dse__Source_Field__c != 'fsCore__Account_Name__c' && fieldMapInstance.nu_dse__Source_Field__c != 'fsCore__Customer_Type__c' &&
                    fieldMapInstance.nu_dse__Source_Field__c != 'fsCore__Lending_Application_Number__c') {
                
                    lenAppQuery += ', fsCore__Account_Name__r.'+fieldMapInstance.nu_dse__Source_Field__c;
                }
            }
            //this is used to query lendingApplication
            lenAppQuery += ' FROM fsCore__Lending_Application_Customer__c WHERE '+ 
                           'fsCore__Lending_Application_Number__c IN :fsCoreLendingApplicationIdSet ORDER BY CreatedDate ';
                           
                           
            
            Set<Id> applicantAccIdSet = new Set<Id>();
            Set<Id> lendingApplicationIdSet = new Set<Id>();

            List<fsCore__Lending_Application_Customer__c> fsCoreLendingApplicationCustomerList = Database.query(lenAppQuery); 

            for (fsCore__Lending_Application_Customer__c fsCoreLendingApplicationCustomer : fsCoreLendingApplicationCustomerList) {
                
                applicantAccIdSet.add(fsCoreLendingApplicationCustomer.fsCore__Account_Name__c);
            }
            
            Id clientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();

            Map<Id, Account> clientIdMap = new Map<Id, Account> ([SELECT Id 
                                                                    FROM Account 
                                                                   WHERE Prizm_External_Id__c IN : applicantAccIdSet 
                                                                     AND recordTypeId = :clientRecordTypeId]);
            //to prevent same Applicant to be processed From different NEW Loan instance.
            Set<Id> processedApplicantIdSet = new Set<Id>();
            Map<Id, List<Id>> applicantAndItsLoanMap = new Map<Id, List<Id>>();
            
            //lendingApplicationCustomer instance is looped
            for (fsCore__Lending_Application_Customer__c fsCoreLendingApplicationCustomer : fsCoreLendingApplicationCustomerList) {

                //system.debug(logginglevel.error,'clientIdMap :'+clientIdMap);
                system.debug(logginglevel.error,'fsCoreLendingApplicationCustomer.fsCore__Account_Name__c :'+fsCoreLendingApplicationCustomer.fsCore__Account_Name__c);
                if (clientIdMap.containsKey(fsCoreLendingApplicationCustomer.fsCore__Account_Name__c) == False) {
                  
                    if (processedApplicantIdSet.contains(fsCoreLendingApplicationCustomer.fsCore__Account_Name__c) == False) {
                      
                        processedApplicantIdSet.add(fsCoreLendingApplicationCustomer.fsCore__Account_Name__c);
                        
                        Account acc = (Account)fsCoreLendingApplicationCustomer.getSobject('fsCore__Account_Name__r'); 

                        //Account clientAccInstance = new Account();  // PDI-920 - FS No need to create the new account use the existing one.
                        Account clientAccInstance = acc;//PDI-920 

                        
                        nu_dse__Program__c clientProgramInstance;
                        String errMsg = '';
                        nu_dse__Error_log__c errLog = new nu_dse__Error_log__c();
                        
                        //when errorFlag=0(no error) 
                        Integer errorFlag = 1;
                        
                        //getting Account(Applicant) Instance 
                        
                        
                        prizmAccIdLenAppId.put(acc.Id, fsCoreLendingApplicationCustomer.fsCore__Lending_Application_Number__c);
                        
                        if (fsCoreLendingApplicationCustomer.fsCore__Customer_Type__c == 'Primary') {
                        
                            clientAccInstance.Prizm_External_Id__c = fsCoreLendingApplicationCustomer.fsCore__Account_Name__c;
                            clientAccInstance.RecordTypeId = clientRecordTypeId;//Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
                            clientProgramInstance = new nu_dse__Program__c();
                            
                            for (String dataMappingName : mDataFieldMappingMap.keySet()) {
                                    
                                if (dataMappingName == 'PrizmAccountToNuDebtAccount' || dataMappingName == 'PrizmAccountToNuDebtProgram') {
                                        
                                    List<nu_dse__Field_mapping__c> mFieldMappingList = mDataFieldMappingMap.get(dataMappingName);
                                
                                    for (nu_dse__Field_mapping__c fieldMapInstance : mFieldMappingList) {
                                        
                                        if (fieldMapInstance.nu_dse__Target_Field__c !=null) {
                                        
                                            if (((fieldMapInstance.nu_dse__setDefaultValue__c == TRUE && String.isBlank(fieldMapInstance.nu_dse__Default_Value__c))
                                                            || (fieldMapInstance.nu_dse__setDefaultValue__c == FALSE && (fieldMapInstance.nu_dse__Source_Field__c == null 
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
                                                    
                                                    } else if (fieldMapInstance.nu_dse__Source_Field__c != null) {
                                                    
                                                        clientProgramInstance.put(fieldMapInstance.nu_dse__Target_Field__c, acc.get(fieldMapInstance.nu_dse__Source_Field__c));
                                                    }  
                                                }                                          
                                            }
                                            errorFlag = 0;
                                        } 
                                    } 
                                }
                            }
                            lenAppIdNuDebtaccMap.put(fsCoreLendingApplicationCustomer.fsCore__Lending_Application_Number__c , clientAccInstance);
                            
                            system.debug(logginglevel.error,'lenAppIdNuDebtaccMap::'+lenAppIdNuDebtaccMap);
                            
                        
                        } else if (fsCoreLendingApplicationCustomer.fsCore__Customer_Type__c != 'Primary' &&
                                   lenAppIdNuDebtaccMap.get(fsCoreLendingApplicationCustomer.fsCore__Lending_Application_Number__c) != null) {
                        
                            clientAccInstance = lenAppIdNuDebtaccMap.get(fsCoreLendingApplicationCustomer.fsCore__Lending_Application_Number__c);
                            
                            if (mFieldMappingCoClientList.isEmpty() == false) {
                            
                                for (nu_dse__Field_mapping__c fieldMapInstance : mFieldMappingCoClientList) {
                                
                                   system.debug(logginglevel.error,'ffff::'+fieldMapInstance.nu_dse__Source_Field__c+'::::::'+fieldMapInstance.nu_dse__Target_Field__c+':::'+fieldMapInstance.nu_dse__Default_Value__c);    
                                    if (fieldMapInstance.nu_dse__Target_Field__c !=null) {
                                    
                                        if (((fieldMapInstance.nu_dse__setDefaultValue__c == TRUE && String.isBlank(fieldMapInstance.nu_dse__Default_Value__c))
                                                        || (fieldMapInstance.nu_dse__setDefaultValue__c == FALSE && (fieldMapInstance.nu_dse__Source_Field__c == null 
                                                        || acc.get(fieldMapInstance.nu_dse__Source_Field__c) == null)))
                                                        && fieldMapInstance.nu_dse__Is_Required__c == TRUE) {
                                                
                                                    errMsg += fieldMapInstance.nu_dse__Target_Field__c + ' is Required. ';
                                                    errorFlag = 1;
                                                    
                                        } else {
                                                    
                                            if (fieldMapInstance.nu_dse__setDefaultValue__c == TRUE) {
                                                
                                                clientAccInstance.put(fieldMapInstance.nu_dse__Target_Field__c, fieldMapInstance.nu_dse__Default_Value__c);
                                            
                                            } else if (fieldMapInstance.nu_dse__Source_Field__c!=null){
                                            
                                                clientAccInstance.put(fieldMapInstance.nu_dse__Target_Field__c, acc.get(fieldMapInstance.nu_dse__Source_Field__c));
                                                                               
                                            }
                                            errorFlag = 0;
                                        }
                                    }
                                }
                            }
                            
                        }
                        if (String.isNotBlank(errMsg)) {
                                    
                            errLog.nu_dse__Class_Method__c = 'Batch_CreateClientAndBnkAccFromApplicant(mFieldMappingError11)';
                            errLog.nu_dse__Error_Causing_Record_Id__c = acc.Id;
                            errLog.nu_dse__User_Context__c = UserInfo.getName();
                            errLog.nu_dse__Message__c = errMsg;
                            errLogList.add(errLog);    
                            
                            lenAppIdNuDebtaccMap.remove(fsCoreLendingApplicationCustomer.fsCore__Lending_Application_Number__c);
                            lenIdNuDebtaccMap.remove(fsCoreLendingApplicationCustomer.fsCore__Lending_Application_Number__c);
                            lenIdProgramMap.remove(fsCoreLendingApplicationCustomer.fsCore__Lending_Application_Number__c);
                            errorFlag = 1;
                        
                        } else if(errorFlag == 0) {  
                               
                            if (clientAccInstance != null) {
                                
                                system.debug(logginglevel.error,'::::'+lenIdNuDebtaccMap+':::::'+clientAccInstance);
                                lenIdNuDebtaccMap.put(fsCoreLendingApplicationCustomer.fsCore__Lending_Application_Number__c,clientAccInstance);
                                
                            }
                            
                            if (clientProgramInstance != null) {                      
                                
                                system.debug('++++++processorMap+++++'+processorMap);
                                system.debug('++++++processorNameMap+++++'+)processorNameMap;
                                system.debug('++++++feeTemplateMap+++++'+feeTemplateMap);
                                
                                if (fsCoreLendingApplicationCustomer.fsCore__Lending_Application_Number__r.Loan_Type__c == 'VCL') {
                                    // VF-13
                                    if (fsCoreLendingApplicationCustomer.fsCore__Lending_Application_Number__r.Investor_Name__c == 'Monja A0 Portfolio') {
                                        clientAccInstance.Processor__c = processorNameMap.get('RAM-VCL-A0').Id;
                                        clientProgramInstance.nu_dse__Processor__c = processorNameMap.get('RAM-VCL-A0').Id;
                                        nu_dse__Fee_Template__c ramFeeTemplate = feeTemplateMap.get('RAM-VCL-A0');
                                        clientProgramInstance.nu_dse__Fee_Template__c = ramFeeTemplate.Id;
                                    } else if (fsCoreLendingApplicationCustomer.fsCore__Lending_Application_Number__r.Investor_Name__c == 'Monja Prime Portfolio') {
                                        clientAccInstance.Processor__c = processorNameMap.get('RAM-VCL-Prime').Id;
                                        clientProgramInstance.nu_dse__Processor__c = processorNameMap.get('RAM-VCL-Prime').Id;
                                        nu_dse__Fee_Template__c ramFeeTemplate = feeTemplateMap.get('RAM-VCL-Prime');
                                        clientProgramInstance.nu_dse__Fee_Template__c = ramFeeTemplate.Id;
                                    } else if (fsCoreLendingApplicationCustomer.fsCore__Lending_Application_Number__r.Investor_Name__c == 'Monja Near Prime Portfolio') {
                                        clientAccInstance.Processor__c = processorNameMap.get('RAM-VCL-Near Prime').Id;
                                        clientProgramInstance.nu_dse__Processor__c = processorNameMap.get('RAM-VCL-Near Prime').Id;
                                        nu_dse__Fee_Template__c ramFeeTemplate = feeTemplateMap.get('RAM-VCL-Near Prime');
                                        clientProgramInstance.nu_dse__Fee_Template__c = ramFeeTemplate.Id;
                                    } else {
                                        nu_dse__Fee_Template__c ramFeeTemplate = feeTemplateMap.get('RAM Versara');                                   
                                        clientProgramInstance.nu_dse__Processor__c = processorMap.get(acc.Processor__c).Id;
                                        clientProgramInstance.nu_dse__GCS_Fee_Group_Id__c = ramFeeTemplate != null && !String.isEmpty(ramFeeTemplate.nu_dse__RAMS_Fee_Group_Id__c) ? ramFeeTemplate.nu_dse__RAMS_Fee_Group_Id__c :'2461';
                                        clientProgramInstance.nu_dse__Fee_Template__c = ramFeeTemplate != null ? ramFeeTemplate.Id : null;
                                    }
                                } else if (fsCoreLendingApplicationCustomer.fsCore__Lending_Application_Number__r.Loan_Type__c == 'DNL') {
                                    if (fsCoreLendingApplicationCustomer.fsCore__Lending_Application_Number__r.Portfolio_Type__c == 'Attorney') {
                                        nu_dse__Processor__c processor = processorMap.get(acc.Processor__c);                                       
                                        if (processor != null && processor.Name == 'RAM') {
                                            nu_dse__Fee_Template__c ramFeeTemplate = feeTemplateMap.get('RAM Versara');
                                            clientProgramInstance.nu_dse__Fee_Template__c = ramFeeTemplate.Id;
                                            clientProgramInstance.nu_dse__GCS_Fee_Group_Id__c = ramFeeTemplate != null && !String.isEmpty(ramFeeTemplate.nu_dse__RAMS_Fee_Group_Id__c) ? ramFeeTemplate.nu_dse__RAMS_Fee_Group_Id__c :'2461';
                                        } else if (processor != null && processor.Name == 'GCS') {
                                            nu_dse__Fee_Template__c gcsFeeTemplate = feeTemplateMap.get('GCS Versara - Attorney');
                                            clientProgramInstance.nu_dse__Fee_Template__c = gcsFeeTemplate.Id;
                                            clientProgramInstance.nu_dse__GCS_Fee_Group_Id__c = gcsFeeTemplate != null && !String.isEmpty(gcsFeeTemplate.nu_dse__GCS_Fee_Group_Id__c) ? gcsFeeTemplate.nu_dse__GCS_Fee_Group_Id__c :'80958';
                                        }
                                    } else if (fsCoreLendingApplicationCustomer.fsCore__Lending_Application_Number__r.Portfolio_Type__c == 'Timberline') {
                                        // DV-535
                                        clientAccInstance.nu_dse__External_GCS_ID__c = clientAccInstance.Payment_Account_Number__c;
                                        clientAccInstance.nu_dse__GCS_Synced__c = true;
                                        clientAccInstance.Processor__c = processorNameMap.get('GCS - Timberline - Nudebt').Id;
                                        
                                        clientProgramInstance.nu_dse__Processor__c = processorNameMap.get('GCS - Timberline - Nudebt').Id;
                                        nu_dse__Fee_Template__c gcsTimberlineFeeTemplate = feeTemplateMap.get('GCS Versara - Timberline');
                                        clientProgramInstance.nu_dse__Fee_Template__c = gcsTimberlineFeeTemplate.Id;
                                        clientProgramInstance.nu_dse__GCS_Fee_Group_Id__c = gcsTimberlineFeeTemplate != null && !String.isEmpty(gcsTimberlineFeeTemplate.nu_dse__GCS_Fee_Group_Id__c) ? gcsTimberlineFeeTemplate.nu_dse__GCS_Fee_Group_Id__c :'80408';
                                    }
                                }        
                                lenIdProgramMap.put(fsCoreLendingApplicationCustomer.fsCore__Lending_Application_Number__c,clientProgramInstance);
                            }
                        }
                        //this map is used for setting Is_Client_Created__c = true
                        prizmIdLenAppIdMap.put(acc.Id, fsCoreLendingApplicationCustomer.fsCore__Lending_Application_Number__c);
                        
                   
                        
                        //add all the Prizm Account Id which have primary customer type in lenAppcustomer
                        if(fsCoreLendingApplicationCustomer.fsCore__Customer_Type__c == 'Primary') {
                        
                            accPrizmIdPrimaryCustomerSet.add(acc.Id);
                        }
                    
                    } else {
                        
                        if (applicantAndItsLoanMap.containsKey(fsCoreLendingApplicationCustomer.fsCore__Account_Name__c) == False) {
                            
                            applicantAndItsLoanMap.put(fsCoreLendingApplicationCustomer.fsCore__Account_Name__c, new List<Id>());
                        }
                        applicantAndItsLoanMap.get(fsCoreLendingApplicationCustomer.fsCore__Account_Name__c).add(fsCoreLendingApplicationCustomer.fsCore__Lending_Application_Number__c);
                    }
                
                } else {
                    
                    lendingApplicationIdSet.add(fsCoreLendingApplicationCustomer.fsCore__Lending_Application_Number__c);
                }
            }
            
            //-----BankAccount process starts------------     
            if (lenIdNuDebtaccMap.isEmpty() == false && lenIdProgramMap.isEmpty() == false) {
               
                String queryBankAcc = 'SELECT Id, fsCore__Account_Name__c ';
                
                for (nu_dse__Field_mapping__c fieldMapInstance : mFieldMapBankAccList) {
                    
                    if (fieldMapInstance.nu_dse__Source_Field__c !=null && queryBankAcc.indexOf('fsCore__Account_Name__r.'+fieldMapInstance.nu_dse__Source_Field__c) == -1 &&
                        fieldMapInstance.nu_dse__Source_Field__c != 'Id' && fieldMapInstance.nu_dse__Source_Field__c != 'fsCore__Account_Name__c') {
                    
                        queryBankAcc += ', '+fieldMapInstance.nu_dse__Source_Field__c;
                    }
                }
                
                //this is used to query prizmBankAccount
                queryBankAcc += ' FROM fsCore__Bank_Account__c WHERE fsCore__Account_Name__c IN :accPrizmIdPrimaryCustomerSet';
                system.debug(logginglevel.error,'queryBankAcc :'+queryBankAcc);
                
                for(fsCore__Bank_Account__c prizmBankAccInstance : Database.query(queryBankAcc)) {
                
                    accPrizmIdPrimaryCustomerSet.remove(prizmBankAccInstance.fsCore__Account_Name__c);
                    String errMsg = '';
                    nu_dse__Error_log__c errLog = new nu_dse__Error_log__c();
                    nu_dse__Bank_Account__c nuDebtBankAccInstance = new nu_dse__Bank_Account__c();
                    nuDebtBankAccInstance.Prizm_External_Id__c = prizmBankAccInstance.Id;
                    for (nu_dse__Field_mapping__c fieldMapInstance : mFieldMapBankAccList) {

                        if (fieldMapInstance.nu_dse__Target_Field__c !=null) {
                        
                        /*
                        Commented by FS for DV-111
                        if (((fieldMapInstance.nu_dse__setDefaultValue__c == TRUE && String.isBlank(fieldMapInstance.nu_dse__Default_Value__c))
                                                || (fieldMapInstance.nu_dse__setDefaultValue__c == FALSE && (fieldMapInstance.nu_dse__Source_Field__c == null 
                                                || prizmBankAccInstance.get(fieldMapInstance.nu_dse__Source_Field__c) == null)))
                                                && fieldMapInstance.nu_dse__Is_Required__c == TRUE) {*/

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
                              
                        errLog.nu_dse__Class_Method__c = 'Batch_CreateClientAndBnkAccFromApplicant(BankAccFieldMAppingError)';
                        errLog.nu_dse__Error_Causing_Record_Id__c = prizmBankAccInstance.Id;
                        errLog.nu_dse__User_Context__c = UserInfo.getName();
                        errLog.nu_dse__Message__c = errMsg;
                        errLogList.add(errLog);    
                        
                        lenIdNuDebtaccMap.remove(prizmAccIdLenAppId.get(prizmBankAccInstance.fsCore__Account_Name__c));
                        lenIdProgramMap.remove(prizmAccIdLenAppId.get(prizmBankAccInstance.fsCore__Account_Name__c));
                    } else {
                    
                        prizmAccIdNuDebtBankAccMap.put(prizmBankAccInstance.fsCore__Account_Name__c, nuDebtBankAccInstance);
                    }
                }
            }
            
            //if prizmBankAcc is not there for particular prizmAcc then clientAcc,prgm,NuDebtBankacc will not be inserted
            for (Id accPrizmId : accPrizmIdPrimaryCustomerSet) {
            
                system.debug(logginglevel.error,'accPrizmId:::'+accPrizmId);
                nu_dse__Error_log__c errLog = new nu_dse__Error_log__c();
                errLog.nu_dse__Class_Method__c = 'Batch_CreateClientAndBnkAccFromApplicant(NO bankAccont)';
                errLog.nu_dse__Error_Causing_Record_Id__c = accPrizmId;
                errLog.nu_dse__User_Context__c = UserInfo.getName();
                errLog.nu_dse__Message__c = 'No prizmBankAcc for '+accPrizmId+' prizmAccount';
                errLogList.add(errLog);    
                
            //    lenIdNuDebtaccMap.remove(prizmAccIdLenAppId.get(accPrizmId));
            //    lenIdProgramMap.remove(prizmAccIdLenAppId.get(accPrizmId));
            }
            
            //-----------------------BankAccount process ends  --------------------------------------     
            
            if (lenIdNuDebtaccMap.isEmpty() == false) { 
            
                List<Account> clientaccList = lenIdNuDebtaccMap.values();
                Integer accClientCount = 0;
            
                system.debug(logginglevel.error,'lenIdNuDebtaccMap.values()::::'+lenIdNuDebtaccMap.values());
                
                SyncBetweenPrizmAndNuDebt.executeClientToApplicant = FALSE;
                SyncBetweenPrizmAndNuDebt.executeApplicantToClient = FALSE;
                //PDI-920  commented by FS
                //List<Database.UpsertResult> clientUpsertResultList = Database.upsert(lenIdNuDebtaccMap.values(),Account.Prizm_External_Id__c,false);
                //PDI-920  added by FS
                List<Database.UpsertResult> clientUpsertResultList = Database.upsert(lenIdNuDebtaccMap.values(),false);
                SyncBetweenPrizmAndNuDebt.executeClientToApplicant = TRUE;
                SyncBetweenPrizmAndNuDebt.executeApplicantToClient = TRUE;
                if (clientUpsertResultList != null && clientUpsertResultList.isEmpty() == False) {
                
                    for (Database.UpsertResult clientUpsertResult : clientUpsertResultList) {
                                
                        accClientCount++;
                        if (clientUpsertResult.isSuccess() == FALSE) {
                                
                            nu_dse__Error_log__c errLog = new nu_dse__Error_log__c();
                            List<String> errMsgs = new List<String>();
                                                
                            for (Database.Error err: clientUpsertResult.getErrors()) {
                        
                                errMsgs.add(err.getStatusCode() + ' | Fields : ' + String.join(err.getFields(),', ') + ' | Message : ' + err.getMessage());
                            }
                            
                            errLog.nu_dse__Class_Method__c = 'Batch_CreateClientAndBnkAccFromApplicant(clientUpsertFailure)';
                            errLog.nu_dse__Error_Causing_Record_Id__c = clientUpsertResult.getId();
                            errLog.nu_dse__User_Context__c = UserInfo.getName();
                            errLog.nu_dse__Error_Causing_Record_Id__c = clientUpsertResult.getId();
                            errLog.nu_dse__Message__c = String.join(errMsgs, '\n');
                            errLogList.add(errLog);      
                        } else {
                                    
                            ClientIdClientMap.put(clientUpsertResult.getId(), clientaccList[accClientCount-1]);
                        }
                    }
                }
            }
            //this loop is used to set AccountId in program
            for (Id lenAppId : lenIdProgramMap.keySet()) {
            
                Id clientId = lenIdNuDebtaccMap.get(lenAppId).Id;
                
                if (clientId != null) {
                            
                    lenIdProgramMap.get(lenAppId).nu_dse__Account__c = clientId;
                } else {
                
                    lenIdProgramMap.remove(lenAppId);
                }
            }
            
            system.debug(logginglevel.error,'111111::::'+lenIdProgramMap);
            if (lenIdProgramMap.isEmpty() == false) {
            
                List<nu_dse__Program__c> prgmList = lenIdProgramMap.values();
                SyncBetweenPrizmAndNuDebt.executeNuDebtProgramToApplicant = False;
                List<Database.UpsertResult> programUpsertResultList = Database.upsert(lenIdProgramMap.values(), false);
                SyncBetweenPrizmAndNuDebt.executeNuDebtProgramToApplicant = True;
                
                Integer count = 0;
                
                for (Database.UpsertResult result : programUpsertResultList) {
                          
                    count++;      
                    if (result.isSuccess() == FALSE) {
                        
                        nu_dse__Error_log__c errLog = new nu_dse__Error_log__c();
                        List<String> errMsgs = new List<String>();
                                            
                        for (Database.Error err: result.getErrors()) {
                    
                            errMsgs.add(err.getStatusCode() + ' | Fields : ' + String.join(err.getFields(),', ') + ' | Message : ' + err.getMessage());
                        }
                        
                        errLog.nu_dse__Class_Method__c = 'Batch_CreateClientAndBnkAccFromApplicant(programUpsertFailure)';
                        errLog.nu_dse__Error_Causing_Record_Id__c = result.getId();
                        errLog.nu_dse__User_Context__c = UserInfo.getName();
                        errLog.nu_dse__Message__c = String.join(errMsgs, '\n');
                        
                        errLogList.add(errLog);
                    } else  {
                         
                        mProgramIds.add(result.getId());
                        
                        //to get Accountclient  instance
                        //ClientIdClientMap.get(prgmList[count-1].nu_dse__Account__c)
                        
                        //1st place -- To check Lending Application If an client Account is successfully created...
                        Id lenAppId = prizmIdLenAppIdMap.get(ClientIdClientMap.get(prgmList[count-1].nu_dse__Account__c).Prizm_External_Id__c);
                        
                        fsCore__Lending_Application__c LendingApplicationInstance = new fsCore__Lending_Application__c();
                        LendingApplicationInstance.Id = lenAppId;
                        LendingApplicationInstance.Is_Client_Created__c = TRUE;
                        lenAppUpdateList.add(LendingApplicationInstance);
                        
                        //2nd place -- To check Lending Application If an client Account is successfully created, Also this client is for mulitiple Lending Applicant (More than 1)...
                        if (applicantAndItsLoanMap.containsKey(ClientIdClientMap.get(prgmList[count-1].nu_dse__Account__c).Prizm_External_Id__c) == True) {
                            
                            for (Id lendingApplicationId : applicantAndItsLoanMap.get(ClientIdClientMap.get(prgmList[count-1].nu_dse__Account__c).Prizm_External_Id__c)) {
                                
                                fsCore__Lending_Application__c LendingApplicationInst = new fsCore__Lending_Application__c();
                                LendingApplicationInst.Id = lendingApplicationId;
                                LendingApplicationInst.Is_Client_Created__c = TRUE;
                                lenAppUpdateList.add(LendingApplicationInst);
                            }
                        }
                        
                        if(prizmAccIdNuDebtBankAccMap.containsKey(ClientIdClientMap.get(prgmList[count-1].nu_dse__Account__c).Prizm_External_Id__c)) {
                        
                            nu_dse__Bank_Account__c nuDebtBankAcc = prizmAccIdNuDebtBankAccMap.get(ClientIdClientMap.get(prgmList[count-1].nu_dse__Account__c).Prizm_External_Id__c);
                            nuDebtBankAcc.nu_dse__Program__c = result.getId();
                            prizmAccIdNuDebtBankAccMap.put((ClientIdClientMap.get(prgmList[count-1].nu_dse__Account__c).Prizm_External_Id__c), nuDebtBankAcc);
                        }
                    }
                }
            }
            
            if (prizmAccIdNuDebtBankAccMap.isEmpty() == FALSE) {
            
                SyncBetweenPrizmAndNuDebt.executeNuDebtBankAccountToPrizmBankAccount = False;
                List<Database.UpsertResult> nuDebtBankAccUpsertResultList = Database.upsert(prizmAccIdNuDebtBankAccMap.values(),nu_dse__Bank_Account__c.Prizm_External_Id__c, false);
                SyncBetweenPrizmAndNuDebt.executeNuDebtBankAccountToPrizmBankAccount = True;
                
                for (Database.UpsertResult result : nuDebtBankAccUpsertResultList) {
                
                    if (result.isSuccess() == FALSE) {
                        
                        nu_dse__Error_log__c errLog = new nu_dse__Error_log__c();
                        List<String> errMsgs = new List<String>();
                                            
                        for (Database.Error err: result.getErrors()) {
                            errMsgs.add(err.getStatusCode() + ' | Fields : ' + String.join(err.getFields(),', ') + ' | Message : ' + err.getMessage());
                        }
                        
                        errLog.nu_dse__Class_Method__c = 'Batch_CreateClientAndBnkAccFromApplicant(BankAccUpsertFailure)';
                        errLog.nu_dse__Error_Causing_Record_Id__c = result.getId();
                        errLog.nu_dse__User_Context__c = UserInfo.getName();
                        errLog.nu_dse__Message__c = String.join(errMsgs, '\n');
                        
                        errLogList.add(errLog);
                    }
                }
            }
            
            //Third place -- To check Lending Application If there is already an client Account Exists...
            if (lendingApplicationIdSet.isEmpty() == False) {
            
                for (Id lendingApplicationId : lendingApplicationIdSet) {
                    
                    fsCore__Lending_Application__c  lendingApplicationInst = new fsCore__Lending_Application__c ();
                    lendingApplicationInst.Id = lendingApplicationId;
                    lendingApplicationInst.Is_Client_Created__c = TRUE;
                    lenAppUpdateList.add(lendingApplicationInst);
                }
            }
            
            if (lenAppUpdateList.size() != 0) {
            
                List<Database.UpsertResult> lenAppUpsertResultList = Database.upsert(lenAppUpdateList, false);
                for (Database.UpsertResult result : lenAppUpsertResultList) {
                
                    if (result.isSuccess() == FALSE) {
                        
                        nu_dse__Error_log__c errLog = new nu_dse__Error_log__c();
                        List<String> errMsgs = new List<String>();
                                            
                        for (Database.Error err: result.getErrors()) {
                    
                            errMsgs.add(err.getStatusCode() + ' | Fields : ' + String.join(err.getFields(),', ') + ' | Message : ' + err.getMessage());
                        }
                        
                        errLog.nu_dse__Class_Method__c = 'Batch_CreateClientAndBnkAccFromApplicant(lenAppUpdateFailure)';
                        errLog.nu_dse__Error_Causing_Record_Id__c = result.getId();
                        errLog.nu_dse__User_Context__c = UserInfo.getName();
                        errLog.nu_dse__Message__c = String.join(errMsgs, '\n');
                        
                        errLogList.add(errLog);
                    }
                }
            }
        } catch(Exception e) {
        
            nu_dse__Error_log__c errLog = new nu_dse__Error_log__c();
            errLog.nu_dse__Class_Method__c = 'Batch_CreateClientAndBnkAccFromApplicant';
            errLog.nu_dse__User_Context__c = UserInfo.getName();
            errLog.nu_dse__Stack_Trace__c = e.getStackTraceString();
            errLog.nu_dse__Message__c = e.getMessage();
            
            errLogList.add(errLog);
        }
        if (errLogList.isEmpty() == FALSE) {
        
            insert errLogList;
        }
        system.debug(logginglevel.error,'mProgramIds ::: execute :::: ' + mProgramIds);
    }
}