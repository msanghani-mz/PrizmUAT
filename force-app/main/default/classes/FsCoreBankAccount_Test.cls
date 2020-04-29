@isTest
public class FsCoreBankAccount_Test {

    @testSetup static void setup() {
        
        List<Account> accountList = new List<Account>();
        Account accountInstance = new Account();
        accountInstance.LastName = 'Test1';
        accountList.add(accountInstance); 
        
        Account accountInstance1 = new Account();
        accountInstance1.LastName = 'Test2';
        accountList.add(accountInstance1); 
        insert accountList;
        
        List<fsCore__Bank_Account__c> fsCoreBankAcctList = new List<fsCore__Bank_Account__c>();
        fsCore__Bank_Account__c fsCoreBankAcctInstance1 = new fsCore__Bank_Account__c();
        fsCoreBankAcctInstance1.fsCore__Bank_Account_Number__c = '12345';
        fsCoreBankAcctInstance1.fsCore__Bank_Account_Holder_Name__c = 'XXXXXXXXXXX';
        fsCoreBankAcctInstance1.fsCore__Bank_Account_Type__c = 'Saving';
        fsCoreBankAcctInstance1.fsCore__Bank_Identification_Code__c = '1197879687';
        fsCoreBankAcctInstance1.fsCore__Account_Name__c = accountInstance.Id;
        fsCoreBankAcctList.add(fsCoreBankAcctInstance1);
        
        fsCore__Bank_Account__c fsCoreBankAcctInstance2 = new fsCore__Bank_Account__c();
        fsCoreBankAcctInstance2.fsCore__Bank_Account_Number__c = '12345';
        fsCoreBankAcctInstance2.fsCore__Bank_Account_Holder_Name__c = 'YYYYYYYYYYY';
        fsCoreBankAcctInstance2.fsCore__Bank_Account_Type__c = 'Saving';
        fsCoreBankAcctInstance2.fsCore__Bank_Identification_Code__c = '1197879687';
        fsCoreBankAcctInstance2.fsCore__Account_Name__c = accountInstance1.Id;
        fsCoreBankAcctList.add(fsCoreBankAcctInstance2);
        
        insert fsCoreBankAcctList;
        /*List<Account> accountList = new List<Account>();
        Account accountInstance = new Account();
        accountInstance.LastName = 'Test1';
        accountList.add(accountInstance);  
        
        Account accountInstance2 = new Account();
        accountInstance2.LastName = 'Test2';
        accountList.add(accountInstance2);            
        insert accountList;*/
    }
    @isTest
    static void errorCheckingInFieldMapping() {
    
        List<Account> accountList = new List<Account>();
        Account accountInstance = new Account();
        accountInstance.LastName = 'Test saravanan1';
        accountList.add(accountInstance);
        
        Account accountInstance1 = new Account();
        accountInstance1.LastName = 'Test Saravanan2';
        accountList.add(accountInstance1);
        
        insert accountList;
        
        //update AccountInstance 
        List<Account> accountLists = new List<Account>();
        Account accountUpdateInstance = new Account();
        accountUpdateInstance.Id = accountInstance.Id;
        accountUpdateInstance.Prizm_External_Id__c = accountInstance.Id;
        accountUpdateInstance.LastName = 'Test saravanan';
        accountLists.add(accountUpdateInstance);
        
        accountInstance1.Prizm_External_Id__c = accountInstance1.Id;
        accountLists.add(accountInstance1);
        update accountLists;       
        
        List<nu_dse__Data_Mapping__c>  dataMappingList = new List<nu_dse__Data_Mapping__c>();
        nu_dse__Data_Mapping__c dataMappingInstance = new nu_dse__Data_Mapping__c();
        dataMappingInstance.Name = 'PrizmBankAccountToNuDebtBankAccount';
        dataMappingList.add(dataMappingInstance);
        insert dataMappingList;
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
        
        nu_dse__Field_mapping__c fieldMappingInstance = new nu_dse__Field_mapping__c();
        fieldMappingInstance.nu_dse__Data_Mapping__c = dataMappingInstance.Id;
        fieldMappingInstance.nu_dse__Source_Field__c = 'fsCore__Bank_Account_Number__c';
        fieldMappingInstance.nu_dse__Target_Field__c = 'nu_dse__Bank_Account_Number__c';
        fieldMappingList.add(fieldMappingInstance);
        
        nu_dse__Field_mapping__c fieldMappingInstance1 = new nu_dse__Field_mapping__c();
        fieldMappingInstance1.nu_dse__Data_Mapping__c = dataMappingInstance.Id;
        fieldMappingInstance1.nu_dse__Source_Field__c = 'fsCore__Bank_Account_Holder_Name__c';
        fieldMappingInstance1.nu_dse__Target_Field__c = 'nu_dse__Holder_s_Name__c';
        fieldMappingInstance1.nu_dse__Is_Required__c = true;
        fieldMappingInstance1.nu_dse__Default_Value__c = null;
        fieldMappingInstance1.nu_dse__setDefaultValue__c = true;        
        fieldMappingList.add(fieldMappingInstance1);
        
        nu_dse__Field_mapping__c fieldMappingInstance2 = new nu_dse__Field_mapping__c();
        fieldMappingInstance2.nu_dse__Data_Mapping__c = dataMappingInstance.Id;
        fieldMappingInstance2.nu_dse__Source_Field__c = 'fsCore__Bank_Identification_Code__c';
        fieldMappingInstance2.nu_dse__Target_Field__c = 'nu_dse__Routing_Number__c';
        fieldMappingInstance2.nu_dse__setDefaultValue__c = true;
        fieldMappingList.add(fieldMappingInstance2);
        
        nu_dse__Field_mapping__c fieldMappingInstance3 = new nu_dse__Field_mapping__c();
        fieldMappingInstance3.nu_dse__Data_Mapping__c = dataMappingInstance.Id;
        fieldMappingInstance3.nu_dse__Source_Field__c = 'Id';
        fieldMappingInstance3.nu_dse__Target_Field__c = 'Prizm_External_Id__c';
        //fieldMappingInstance3.nu_dse__Is_Required__c = true;
        fieldMappingList.add(fieldMappingInstance3);
        
        nu_dse__Field_mapping__c fieldMappingInstance4 = new nu_dse__Field_mapping__c();
        fieldMappingInstance4.nu_dse__Data_Mapping__c = dataMappingInstance.Id;
        fieldMappingInstance4.nu_dse__Source_Field__c = 'fsCore__Bank_Account_Type__c';
        fieldMappingInstance4.nu_dse__Target_Field__c = 'nu_dse__Account_Type__c';
        fieldMappingInstance4.nu_dse__Is_Required__c = true;
        fieldMappingList.add(fieldMappingInstance4);
        
        insert fieldMappingList; 
              
        List<nu_dse__Program__c> nuDseProgramList = new List<nu_dse__Program__c>();
        nu_dse__Program__c nuDseProgramInstance = new nu_dse__Program__c();
        nuDseProgramInstance.nu_dse__Account__c = accountUpdateInstance.Id;
        nuDseProgramList.add(nuDseProgramInstance);
        
        nu_dse__Program__c nuDseProgramInstance1 = new nu_dse__Program__c();
        nuDseProgramInstance1.nu_dse__Account__c = accountInstance1.Id;
        nuDseProgramList.add(nuDseProgramInstance1);
        insert nuDseProgramList;
                
        List<fsCore__Bank_Account__c> fsCoreBankAcctList = new List<fsCore__Bank_Account__c>();
        fsCore__Bank_Account__c fsCoreBankAcctInstance1 = new fsCore__Bank_Account__c();
        fsCoreBankAcctInstance1.Name = 'XXXX';
        fsCoreBankAcctInstance1.fsCore__Bank_Account_Number__c = '12345';
        fsCoreBankAcctInstance1.fsCore__Bank_Account_Holder_Name__c = 'XXXX';
        //fsCoreBankAcctInstance1.fsCore__Bank_Account_Type__c = 'Saving';
        fsCoreBankAcctInstance1.fsCore__Bank_Identification_Code__c = '1197';
        fsCoreBankAcctInstance1.fsCore__Account_Name__c = accountUpdateInstance.Id;
        fsCoreBankAcctList.add(fsCoreBankAcctInstance1);
        
        fsCore__Bank_Account__c fsCoreBankAcctInstance2 = new fsCore__Bank_Account__c();
        fsCoreBankAcctInstance2.Name = 'YYYY';
        fsCoreBankAcctInstance2.fsCore__Bank_Account_Number__c = '12456';
        fsCoreBankAcctInstance2.fsCore__Bank_Account_Holder_Name__c = 'YYYY';
        fsCoreBankAcctInstance2.fsCore__Bank_Account_Type__c = 'Saving';
        fsCoreBankAcctInstance2.fsCore__Bank_Identification_Code__c = '1197';
        fsCoreBankAcctInstance2.fsCore__Account_Name__c = accountInstance1.Id;
        fsCoreBankAcctList.add(fsCoreBankAcctInstance2);                         
        insert fsCoreBankAcctList;
        
        List<nu_dse__Error_Log__c> errorLogList = [SELECT Id,nu_dse__Message__c  FROM  nu_dse__Error_Log__c WHERE nu_dse__Class_Method__c = 'FsCoreBankAccountHandler.createBankAccount'];
        for (nu_dse__Error_Log__c errorLogInstance : errorLogList ) {
            System.debug('For Loop');
            System.debug('ErrorMessage'+errorLogInstance.nu_dse__Message__c );
        } 
        System.assertEquals(2,errorLogList.size());
      /*  
        
        for(nu_dse__Bank_Account__c nuDsebankAccount : [SELECT nu_dse__Bank_Account_Number__c, nu_dse__Holder_s_Name__c, nu_dse__Program__c, nu_dse__Routing_Number__c 
                                                        FROM nu_dse__Bank_Account__c 
                                                        WHERE nu_dse__Program__c =: nuDseProgramInstance1.Id]) {
        
            System.assertEquals(fsCoreBankAcctInstance2.fsCore__Bank_Account_Number__c, nuDsebankAccount.nu_dse__Bank_Account_Number__c);
            System.assertEquals(fsCoreBankAcctInstance2.fsCore__Bank_Account_Holder_Name__c , nuDsebankAccount.nu_dse__Holder_s_Name__c);
            System.assertEquals(fsCoreBankAcctInstance2.fsCore__Bank_Identification_Code__c, nuDsebankAccount.nu_dse__Routing_Number__c);
            System.assertEquals(nuDseProgramInstance1.Id, nuDsebankAccount.nu_dse__Program__c);
        } */
    }
    
    @isTest
    static void upsertErrorChecking_PrismBankAcc_To_NudebtBankAcc() {
    
        List<Account> accountList = new List<Account>();
        Account accountInstance = new Account();
        accountInstance.LastName = 'Test saravanan1';
        accountList.add(accountInstance);    
        insert accountList;
        
        List<Account> updateAccountList = new List<Account>();
        accountInstance.Prizm_External_Id__c = accountInstance.Id;
        updateAccountList.add(accountInstance);
        update updateAccountList;
        
        List<nu_dse__Data_Mapping__c>  dataMappingList = new List<nu_dse__Data_Mapping__c>();
        nu_dse__Data_Mapping__c dataMappingInstance = new nu_dse__Data_Mapping__c();
        dataMappingInstance.Name = 'PrizmBankAccountToNuDebtBankAccount';
        dataMappingList.add(dataMappingInstance);
        insert dataMappingList;
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
        
        nu_dse__Field_mapping__c fieldMappingInstance2 = new nu_dse__Field_mapping__c();//coverage for database error
        fieldMappingInstance2.nu_dse__Data_Mapping__c = dataMappingInstance.Id;
        fieldMappingInstance2.nu_dse__Source_Field__c = 'fsCore__Bank_Identification_Code__c';
        fieldMappingInstance2.nu_dse__Target_Field__c = 'nu_dse__Routing_Number__c';
        fieldMappingInstance2.nu_dse__setDefaultValue__c = true;
        fieldMappingInstance2.nu_dse__Default_Value__c = '1234567890123456789012345678900987342'; 
        fieldMappingList.add(fieldMappingInstance2);
        
        nu_dse__Field_mapping__c fieldMappingInstance3 = new nu_dse__Field_mapping__c();
        fieldMappingInstance3.nu_dse__Data_Mapping__c = dataMappingInstance.Id;
        fieldMappingInstance3.nu_dse__Source_Field__c = 'Id';
        fieldMappingInstance3.nu_dse__Target_Field__c = 'Prizm_External_Id__c';
        //fieldMappingInstance3.nu_dse__Is_Required__c = true;
        fieldMappingList.add(fieldMappingInstance3);
                       
        insert fieldMappingList; 
        
        List<nu_dse__Program__c> nuDseProgramList = new List<nu_dse__Program__c>();
        nu_dse__Program__c nuDseProgramInstance = new nu_dse__Program__c();
        nuDseProgramInstance.nu_dse__Account__c = accountInstance.Id;
        nuDseProgramList.add(nuDseProgramInstance);
        insert nuDseProgramList;
        
        List<fsCore__Bank_Account__c> fsCoreBankAcctList = new List<fsCore__Bank_Account__c>();
        fsCore__Bank_Account__c fsCoreBankAcctInstance1 = new fsCore__Bank_Account__c();
        fsCoreBankAcctInstance1.fsCore__Bank_Account_Number__c = '12345';
        fsCoreBankAcctInstance1.fsCore__Bank_Account_Holder_Name__c = 'SARAVANAN T';
        //fsCoreBankAcctInstance1.fsCore__Bank_Account_Type__c = 'Saving';
        fsCoreBankAcctInstance1.fsCore__Bank_Identification_Code__c = '1197879687';
        fsCoreBankAcctInstance1.fsCore__Account_Name__c = accountInstance.Id;
        fsCoreBankAcctList.add(fsCoreBankAcctInstance1);
        insert fsCoreBankAcctList;
        
        List<nu_dse__Error_Log__c> errorLogList = [SELECT Id,nu_dse__Message__c,nu_dse__Error_Causing_Record_Id__c  FROM  nu_dse__Error_Log__c WHERE nu_dse__Class_Method__c = 'FsCoreBankAccountHandler.createBankAccount'];
        for (nu_dse__Error_Log__c errorLogInstance : errorLogList ) {
            System.debug('For Loop');
            System.debug('ErrorMessage'+errorLogInstance.nu_dse__Message__c );
        } 
        System.assertEquals(1,errorLogList.size());
                             
    }
    
    @isTest
    static void update_PrismBankAcc_To_NudebtBankAcc() {
    
        List<Account> accountList = new List<Account>();
        Account accountInstance = new Account();
        accountInstance.LastName = 'Test saravanan1';
        accountList.add(accountInstance);  
        
        Account accountInstance1 = new Account();
        accountInstance1.LastName = 'Test Saravanan2';
        accountList.add(accountInstance1);  
        insert accountList;
        
        List<Account> updateAccountList = new List<Account>();
        Account accountUpdateInstance = new Account();
        accountUpdateInstance.Id = accountInstance.Id;
        accountUpdateInstance.Prizm_External_Id__c = accountInstance.Id;
        accountUpdateInstance.LastName = 'Test saravanan1';              
        updateAccountList.add(accountUpdateInstance);
        
        Account accountUpdateInstance1 = new Account();
        accountUpdateInstance1.Id = accountInstance1.Id;
        accountUpdateInstance1.Prizm_External_Id__c = accountInstance1.Id;
        accountUpdateInstance1.LastName = 'Test saravanan2';              
        updateAccountList.add(accountUpdateInstance1);
        update updateAccountList;
        
        List<nu_dse__Program__c> nuDseProgramList = new List<nu_dse__Program__c>();
        nu_dse__Program__c nuDseProgramInstance = new nu_dse__Program__c();
        nuDseProgramInstance.nu_dse__Account__c = accountUpdateInstance.Id;
        nuDseProgramList.add(nuDseProgramInstance);
        
        nu_dse__Program__c nuDseProgramInstance1 = new nu_dse__Program__c();
        nuDseProgramInstance1.nu_dse__Account__c = accountUpdateInstance1.Id;
        nuDseProgramList.add(nuDseProgramInstance1);
        insert nuDseProgramList;
        
        List<nu_dse__Data_Mapping__c>  dataMappingList = new List<nu_dse__Data_Mapping__c>();
        nu_dse__Data_Mapping__c dataMappingInstance = new nu_dse__Data_Mapping__c();
        dataMappingInstance.Name = 'PrizmBankAccountToNuDebtBankAccount';
        dataMappingList.add(dataMappingInstance);
        insert dataMappingList;
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
        
        nu_dse__Field_mapping__c fieldMappingInstance = new nu_dse__Field_mapping__c();
        fieldMappingInstance.nu_dse__Data_Mapping__c = dataMappingInstance.Id;
        fieldMappingInstance.nu_dse__Source_Field__c = 'fsCore__Bank_Account_Number__c';
        fieldMappingInstance.nu_dse__Target_Field__c = 'nu_dse__Bank_Account_Number__c';
        fieldMappingList.add(fieldMappingInstance);
        
        nu_dse__Field_mapping__c fieldMappingInstance1 = new nu_dse__Field_mapping__c();
        fieldMappingInstance1.nu_dse__Data_Mapping__c = dataMappingInstance.Id;
        fieldMappingInstance1.nu_dse__Source_Field__c = 'fsCore__Bank_Account_Holder_Name__c';
        fieldMappingInstance1.nu_dse__Target_Field__c = 'nu_dse__Holder_s_Name__c';
        fieldMappingInstance1.nu_dse__Is_Required__c = true;
        fieldMappingInstance1.nu_dse__Default_Value__c = 'sara';
        fieldMappingInstance1.nu_dse__setDefaultValue__c = true;        
        fieldMappingList.add(fieldMappingInstance1);
        
        nu_dse__Field_mapping__c fieldMappingInstance2 = new nu_dse__Field_mapping__c();
        fieldMappingInstance2.nu_dse__Data_Mapping__c = dataMappingInstance.Id;
        fieldMappingInstance2.nu_dse__Source_Field__c = 'fsCore__Bank_Identification_Code__c';
        fieldMappingInstance2.nu_dse__Target_Field__c = 'nu_dse__Routing_Number__c';
        //fieldMappingInstance2.nu_dse__setDefaultValue__c = true;
        fieldMappingList.add(fieldMappingInstance2);
        
        nu_dse__Field_mapping__c fieldMappingInstance3 = new nu_dse__Field_mapping__c();
        fieldMappingInstance3.nu_dse__Data_Mapping__c = dataMappingInstance.Id;
        fieldMappingInstance3.nu_dse__Source_Field__c = 'Id';
        fieldMappingInstance3.nu_dse__Target_Field__c = 'Prizm_External_Id__c';
        fieldMappingInstance3.nu_dse__Is_Required__c = true;
        fieldMappingList.add(fieldMappingInstance3);
        
        nu_dse__Field_mapping__c fieldMappingInstance4 = new nu_dse__Field_mapping__c();
        fieldMappingInstance4.nu_dse__Data_Mapping__c = dataMappingInstance.Id;
        fieldMappingInstance4.nu_dse__Source_Field__c = 'fsCore__Bank_Account_Type__c';
        fieldMappingInstance4.nu_dse__Target_Field__c = 'nu_dse__Account_Type__c';
        fieldMappingInstance4.nu_dse__Is_Required__c = true;
        fieldMappingList.add(fieldMappingInstance4);
        
        insert fieldMappingList;
        
        
        
        List<fsCore__Bank_Account__c> fsCoreBankAcctList = new List<fsCore__Bank_Account__c>();
        fsCore__Bank_Account__c fsCoreBankAcctInstance1 = new fsCore__Bank_Account__c();
        fsCoreBankAcctInstance1.fsCore__Bank_Account_Number__c = '12345';
        fsCoreBankAcctInstance1.fsCore__Bank_Account_Holder_Name__c = 'SARAVANAN T';
        fsCoreBankAcctInstance1.fsCore__Bank_Account_Type__c = 'Saving';
        fsCoreBankAcctInstance1.fsCore__Bank_Identification_Code__c = '1197879687';
        fsCoreBankAcctInstance1.fsCore__Account_Name__c = accountUpdateInstance.Id;
        fsCoreBankAcctList.add(fsCoreBankAcctInstance1);
        
        fsCore__Bank_Account__c fsCoreBankAcctInstance2 = new fsCore__Bank_Account__c();
        fsCoreBankAcctInstance2.fsCore__Bank_Account_Number__c = '123456';
        fsCoreBankAcctInstance2.fsCore__Bank_Account_Holder_Name__c = 'ASHOK T';
        fsCoreBankAcctInstance2.fsCore__Bank_Account_Type__c = 'Checking';
        fsCoreBankAcctInstance2.fsCore__Bank_Identification_Code__c = '1197';
        fsCoreBankAcctInstance2.fsCore__Account_Name__c = accountUpdateInstance1.Id;
        fsCoreBankAcctList.add(fsCoreBankAcctInstance2);
        Test.startTest();
        insert fsCoreBankAcctList;
        Test.stopTest(); 
        
        List<nu_dse__Bank_Account__c> nuDseBankAcctList = [SELECT nu_dse__Bank_Account_Number__c,Prizm_External_Id__c, nu_dse__Holder_s_Name__c, nu_dse__Program__c, nu_dse__Routing_Number__c 
                                                            FROM nu_dse__Bank_Account__c];                                                 
        System.assertEquals(2,nuDseBankAcctList.size());                                                
        for(nu_dse__Bank_Account__c nuDsebankAccount : nuDseBankAcctList ) {
            System.debug('For Loop');
            if (fsCoreBankAcctInstance1.Id == nuDsebankAccount.Prizm_External_Id__c) {
                System.debug('If::::->');
                System.assertEquals(fsCoreBankAcctInstance1.fsCore__Bank_Account_Number__c, nuDsebankAccount.nu_dse__Bank_Account_Number__c);
                System.assertEquals('sara', nuDsebankAccount.nu_dse__Holder_s_Name__c);
                System.assertEquals(fsCoreBankAcctInstance1.fsCore__Bank_Identification_Code__c, nuDsebankAccount.nu_dse__Routing_Number__c);
                System.assertEquals(nuDseProgramInstance.Id, nuDsebankAccount.nu_dse__Program__c);
                System.assertEquals(fsCoreBankAcctInstance1.Id, nuDsebankAccount.Prizm_External_Id__c);
            } else if(fsCoreBankAcctInstance2.Id == nuDsebankAccount.Prizm_External_Id__c) {
                System.debug('ElseIf::');
                System.assertEquals(fsCoreBankAcctInstance2.fsCore__Bank_Account_Number__c, nuDsebankAccount.nu_dse__Bank_Account_Number__c);
                System.assertEquals('sara', nuDsebankAccount.nu_dse__Holder_s_Name__c);
                System.assertEquals(fsCoreBankAcctInstance2.fsCore__Bank_Identification_Code__c, nuDsebankAccount.nu_dse__Routing_Number__c);
                System.assertEquals(nuDseProgramInstance1.Id, nuDsebankAccount.nu_dse__Program__c);
                System.assertEquals(fsCoreBankAcctInstance2.Id, nuDsebankAccount.Prizm_External_Id__c);
              }
        }  
    }
    
    @isTest
    static void catchChecking_PrismBankAcc_To_NudebtBankAcc() {
    
        List<Account> accountList = new List<Account>();
        Account accountInstance = new Account();
        accountInstance.LastName = 'Test saravanan1';
        accountList.add(accountInstance);    
        insert accountList;
        
        List<Account> updateAccountList = new List<Account>();
        accountInstance.Prizm_External_Id__c = accountInstance.Id;
        updateAccountList.add(accountInstance);
        update updateAccountList;
        
        List<nu_dse__Data_Mapping__c>  dataMappingList = new List<nu_dse__Data_Mapping__c>();
        nu_dse__Data_Mapping__c dataMappingInstance = new nu_dse__Data_Mapping__c();
        dataMappingInstance.Name = 'PrizmBankAccountToNuDebtBankAccount';
        dataMappingList.add(dataMappingInstance);
        insert dataMappingList;
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
        
        nu_dse__Field_mapping__c fieldMappingInstance = new nu_dse__Field_mapping__c();
        fieldMappingInstance.nu_dse__Data_Mapping__c = dataMappingInstance.Id;
        fieldMappingInstance.nu_dse__Source_Field__c = 'fsCore__Bank_Account_Holder_Name__c';
        fieldMappingInstance.nu_dse__Target_Field__c = 'nu_dse__RAMS_Synced__c';
        fieldMappingList.add(fieldMappingInstance);       
        insert fieldMappingList; 
        
        
        List<nu_dse__Program__c> nuDseProgramList = new List<nu_dse__Program__c>();
        nu_dse__Program__c nuDseProgramInstance = new nu_dse__Program__c();
        nuDseProgramInstance.nu_dse__Account__c = accountInstance.Id;
        nuDseProgramList.add(nuDseProgramInstance);
        insert nuDseProgramList;
        
        List<fsCore__Bank_Account__c> fsCoreBankAcctList = new List<fsCore__Bank_Account__c>();
        fsCore__Bank_Account__c fsCoreBankAcctInstance1 = new fsCore__Bank_Account__c();
        fsCoreBankAcctInstance1.fsCore__Bank_Account_Number__c = '12345';
        fsCoreBankAcctInstance1.fsCore__Bank_Account_Holder_Name__c = 'SARAVANAN T';
        //fsCoreBankAcctInstance1.fsCore__Bank_Account_Type__c = 'Saving';
        fsCoreBankAcctInstance1.fsCore__Bank_Identification_Code__c = '1197879687';
        fsCoreBankAcctInstance1.fsCore__Account_Name__c = accountInstance.Id;
        fsCoreBankAcctList.add(fsCoreBankAcctInstance1);
        insert fsCoreBankAcctList;
        
        List<nu_dse__Error_Log__c> errorLogList = [SELECT Id,nu_dse__Message__c,nu_dse__Error_Causing_Record_Id__c,nu_dse__Class_Method__c FROM  nu_dse__Error_Log__c WHERE nu_dse__Class_Method__c = 'FsCoreBankAccountHandler.createBankAccount'];
        System.assertEquals(1,errorLogList.size());
        for (nu_dse__Error_Log__c errorLogInstance : errorLogList ) {
            System.debug('For Loop');
            System.debug('ErrorMessage'+errorLogInstance.nu_dse__Message__c );
            System.assertEquals('FsCoreBankAccountHandler.createBankAccount',errorLogInstance.nu_dse__Class_Method__c);
        }        
    }    
    
    @isTest
    static void syncUpdate_PrismBankAcc_To_NudebtBankAcc() {
    
        List<Account> accountList = new List<Account>();
        Account accountInstance = new Account();
        accountInstance.LastName = 'Test saravanan1';
        accountList.add(accountInstance);  
        
        Account accountInstance1 = new Account();
        accountInstance1.LastName = 'Test Saravanan2';
        accountList.add(accountInstance1);  
        insert accountList;
        
        List<Account> updateAccountList = new List<Account>();
        Account accountUpdateInstance = new Account();
        accountUpdateInstance.Id = accountInstance.Id;
        accountUpdateInstance.Prizm_External_Id__c = accountInstance.Id;
        accountUpdateInstance.LastName = 'Test saravanan1';              
        updateAccountList.add(accountUpdateInstance);
        
        Account accountUpdateInstance1 = new Account();
        accountUpdateInstance1.Id = accountInstance1.Id;
        accountUpdateInstance1.Prizm_External_Id__c = accountInstance1.Id;
        accountUpdateInstance1.LastName = 'Test saravanan2';              
        updateAccountList.add(accountUpdateInstance1);
        update updateAccountList;
        
        List<nu_dse__Program__c> nuDseProgramList = new List<nu_dse__Program__c>();
        nu_dse__Program__c nuDseProgramInstance = new nu_dse__Program__c();
        nuDseProgramInstance.nu_dse__Account__c = accountUpdateInstance.Id;
        nuDseProgramList.add(nuDseProgramInstance);
        
        nu_dse__Program__c nuDseProgramInstance1 = new nu_dse__Program__c();
        nuDseProgramInstance1.nu_dse__Account__c = accountUpdateInstance1.Id;
        nuDseProgramList.add(nuDseProgramInstance1);
        insert nuDseProgramList;
        
        List<nu_dse__Data_Mapping__c>  dataMappingList = new List<nu_dse__Data_Mapping__c>();
        nu_dse__Data_Mapping__c dataMappingInstance = new nu_dse__Data_Mapping__c();
        dataMappingInstance.Name = 'PrizmBankAccountToNuDebtBankAccount';
        dataMappingList.add(dataMappingInstance);
        insert dataMappingList;
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
        
        nu_dse__Field_mapping__c fieldMappingInstance = new nu_dse__Field_mapping__c();
        fieldMappingInstance.nu_dse__Data_Mapping__c = dataMappingInstance.Id;
        fieldMappingInstance.nu_dse__Source_Field__c = 'fsCore__Bank_Account_Number__c';
        fieldMappingInstance.nu_dse__Target_Field__c = 'nu_dse__Bank_Account_Number__c';
        fieldMappingList.add(fieldMappingInstance);
        
        nu_dse__Field_mapping__c fieldMappingInstance1 = new nu_dse__Field_mapping__c();
        fieldMappingInstance1.nu_dse__Data_Mapping__c = dataMappingInstance.Id;
        fieldMappingInstance1.nu_dse__Source_Field__c = 'fsCore__Bank_Account_Holder_Name__c';
        fieldMappingInstance1.nu_dse__Target_Field__c = 'nu_dse__Holder_s_Name__c';
        fieldMappingInstance1.nu_dse__Is_Required__c = true;
        fieldMappingInstance1.nu_dse__Default_Value__c = 'sara';
        fieldMappingInstance1.nu_dse__setDefaultValue__c = true;        
        fieldMappingList.add(fieldMappingInstance1);
        
        nu_dse__Field_mapping__c fieldMappingInstance2 = new nu_dse__Field_mapping__c();
        fieldMappingInstance2.nu_dse__Data_Mapping__c = dataMappingInstance.Id;
        fieldMappingInstance2.nu_dse__Source_Field__c = 'fsCore__Bank_Identification_Code__c';
        fieldMappingInstance2.nu_dse__Target_Field__c = 'nu_dse__Routing_Number__c';
        //fieldMappingInstance2.nu_dse__setDefaultValue__c = true;
        fieldMappingList.add(fieldMappingInstance2);
        
        nu_dse__Field_mapping__c fieldMappingInstance3 = new nu_dse__Field_mapping__c();
        fieldMappingInstance3.nu_dse__Data_Mapping__c = dataMappingInstance.Id;
        fieldMappingInstance3.nu_dse__Source_Field__c = 'Id';
        fieldMappingInstance3.nu_dse__Target_Field__c = 'Prizm_External_Id__c';
        fieldMappingInstance3.nu_dse__Is_Required__c = true;
        fieldMappingList.add(fieldMappingInstance3);
        
        nu_dse__Field_mapping__c fieldMappingInstance4 = new nu_dse__Field_mapping__c();
        fieldMappingInstance4.nu_dse__Data_Mapping__c = dataMappingInstance.Id;
        fieldMappingInstance4.nu_dse__Source_Field__c = 'fsCore__Bank_Account_Type__c';
        fieldMappingInstance4.nu_dse__Target_Field__c = 'nu_dse__Account_Type__c';
        fieldMappingInstance4.nu_dse__Is_Required__c = true;
        fieldMappingList.add(fieldMappingInstance4);
        
        insert fieldMappingList;

    
        List<fsCore__Bank_Account__c> fsCoreBankAcctList = new List<fsCore__Bank_Account__c>();
        fsCoreBankAcctList = [SELECT Id FROM fsCore__Bank_Account__c ];      
        fsCoreBankAcctList[0].fsCore__Bank_Identification_Code__c = '1197';
        fsCoreBankAcctList[0].fsCore__Account_Name__c = accountUpdateInstance.Id;
        fsCoreBankAcctList[1].fsCore__Bank_Account_Type__c = 'Checking';
        fsCoreBankAcctList[1].fsCore__Account_Name__c  = accountUpdateInstance1.Id;
        update fsCoreBankAcctList; 
        List<fsCore__Bank_Account__c> fsCoreBankAccountList = [SELECT fsCore__Bank_Account_Number__c,fsCore__Bank_Account_Holder_Name__c,
                                                               fsCore__Bank_Account_Type__c,fsCore__Bank_Identification_Code__c FROM fsCore__Bank_Account__c];
        System.assertEquals(2,fsCoreBankAccountList.size());                                                       
        List<nu_dse__Bank_Account__c> nuDseBankAcctList = [SELECT nu_dse__Bank_Account_Number__c,Prizm_External_Id__c, nu_dse__Holder_s_Name__c, nu_dse__Program__c, nu_dse__Routing_Number__c, nu_dse__Account_Type__c 
                                                            FROM nu_dse__Bank_Account__c];                                                 
        System.assertEquals(2,nuDseBankAcctList.size());
        
        System.assertEquals('sara',nuDseBankAcctList[0].nu_dse__Holder_s_Name__c);
        System.assertEquals(fsCoreBankAccountList[0].fsCore__Bank_Account_Number__c,nuDseBankAcctList[0].nu_dse__Bank_Account_Number__c);
        System.assertEquals(fsCoreBankAccountList[0].Id,nuDseBankAcctList[0].Prizm_External_Id__c);
        System.assertEquals('1197',nuDseBankAcctList[0].nu_dse__Routing_Number__c);
        
        System.assertEquals('sara',nuDseBankAcctList[1].nu_dse__Holder_s_Name__c);
        System.assertEquals(fsCoreBankAccountList[1].fsCore__Bank_Account_Number__c,nuDseBankAcctList[1].nu_dse__Bank_Account_Number__c);
        System.assertEquals(fsCoreBankAccountList[1].Id,nuDseBankAcctList[1].Prizm_External_Id__c);
        System.assertEquals('1197879687',nuDseBankAcctList[1].nu_dse__Routing_Number__c);
        System.assertEquals('CHECKING',nuDseBankAcctList[1].nu_dse__Account_Type__c);
        }
}