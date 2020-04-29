@isTest
public class BankAccountHandler_Test {
    
    @testSetup
    static void setup() {
    
        List<nu_dse__Data_Mapping__c>  dataMappingList = new List<nu_dse__Data_Mapping__c>();
        nu_dse__Data_Mapping__c dataMappingInstance = new nu_dse__Data_Mapping__c();
        dataMappingInstance.Name = 'NuDebtBankAccountToPrizmBankAccount';
        dataMappingList.add(dataMappingInstance);
        insert dataMappingList;
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();       
        nu_dse__Field_mapping__c fieldMappingInstance = new nu_dse__Field_mapping__c();
        fieldMappingInstance.nu_dse__Data_Mapping__c = dataMappingInstance.Id;
        fieldMappingInstance.nu_dse__Source_Field__c = 'nu_dse__Bank_Account_Number__c';
        fieldMappingInstance.nu_dse__Target_Field__c = 'fsCore__Bank_Account_Number__c';
        fieldMappingList.add(fieldMappingInstance);
        
        nu_dse__Field_mapping__c fieldMappingInstance2 = new nu_dse__Field_mapping__c();
        fieldMappingInstance2.nu_dse__Data_Mapping__c = dataMappingInstance.Id;
        fieldMappingInstance2.nu_dse__Source_Field__c = 'nu_dse__Holder_s_Name__c';
        fieldMappingInstance2.nu_dse__Target_Field__c = 'fsCore__Bank_Account_Holder_Name__c';
        //fieldMappingInstance2.nu_dse__Is_Required__c = true;
        fieldMappingList.add(fieldMappingInstance2);
         
        nu_dse__Field_mapping__c fieldMappingInstance3 = new nu_dse__Field_mapping__c();
        fieldMappingInstance3.nu_dse__Data_Mapping__c = dataMappingInstance.Id;
        fieldMappingInstance3.nu_dse__Source_Field__c = 'nu_dse__Routing_Number__c';
        fieldMappingInstance3.nu_dse__Target_Field__c = 'fsCore__Bank_Identification_Code__c';
        //fieldMappingInstance3.nu_dse__Is_Required__c = true;
        fieldMappingList.add(fieldMappingInstance3);
        insert fieldMappingList;
        
        List<Account> accountList = new List<Account>();
        Account accountInstance = new Account();
        accountInstance.LastName = 'Test1197';
        accountList.add(accountInstance);
        Account accountInstance1 = new Account();
        accountInstance1.LastName = 'Test1198';
        accountList.add(accountInstance1);   
        insert accountList;
        
        List<Account> updateAccountList = new List<Account>();
        Account accountUpdateInstance = new Account();
        accountUpdateInstance.Id = accountInstance.Id;
        accountUpdateInstance.Prizm_External_Id__c = accountInstance.Id;
        accountUpdateInstance.LastName = 'Test1197';              
        updateAccountList.add(accountUpdateInstance);
        Account accountUpdateInstance1 = new Account();
        accountUpdateInstance1.Id = accountInstance1.Id;
        accountUpdateInstance1.Prizm_External_Id__c = accountInstance1.Id;
        accountUpdateInstance1.LastName = 'Test1198';              
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
        
        List<nu_dse__Bank_Account__c> nuDseBankAccList = new List<nu_dse__Bank_Account__c>();
        nu_dse__Bank_Account__c nuDseBankAccInstance = new nu_dse__Bank_Account__c();
        nuDseBankAccInstance.nu_dse__Bank_Account_Number__c = '1234';
        nuDseBankAccInstance.nu_dse__Holder_s_Name__c = 'XXx';
        nuDseBankAccInstance.nu_dse__Routing_Number__c = '1197';
        nuDseBankAccInstance.nu_dse__Program__c = nuDseProgramInstance.Id;
        nuDseBankAccList.add(nuDseBankAccInstance);
        insert nuDseBankAccList;
        
    }
    
    @isTest
    static void insert_NudebtBankAcc_To_PrizmBankAcc() {
        
        List<nu_dse__Program__c> nuDseProgramList  = [SELECT Id FROM nu_dse__Program__c];
        
        List<nu_dse__Bank_Account__c> nuDseBankAccList = new List<nu_dse__Bank_Account__c>(); 
        nu_dse__Bank_Account__c nuDseBankAccInstance = new nu_dse__Bank_Account__c();
        nuDseBankAccInstance.nu_dse__Bank_Account_Number__c = '1234';
        nuDseBankAccInstance.nu_dse__Holder_s_Name__c = 'XX';
        nuDseBankAccInstance.nu_dse__Routing_Number__c = '1197';
        nuDseBankAccInstance.nu_dse__Program__c = nuDseProgramList[0].Id;
        nuDseBankAccList.add(nuDseBankAccInstance);
        
        nu_dse__Bank_Account__c nuDseBankAccInstance1 = new nu_dse__Bank_Account__c();
        nuDseBankAccInstance1.nu_dse__Bank_Account_Number__c = '12345';
        nuDseBankAccInstance1.nu_dse__Holder_s_Name__c = 'YY';
        nuDseBankAccInstance1.nu_dse__Routing_Number__c = '1198';
        nuDseBankAccInstance1.nu_dse__Program__c = nuDseProgramList[1].Id;
        nuDseBankAccList.add(nuDseBankAccInstance1);
        
        //Test.startTest();
        insert nuDseBankAccList;   
        //Test.stopTest();
        
        System.debug(nuDseBankAccList);
        List<nu_dse__Bank_Account__c> nuDseBankAccList1 =[SELECT Id,nu_dse__Holder_s_Name__c,Prizm_External_Id__c,nu_dse__Routing_Number__c FROM nu_dse__Bank_Account__c];
        System.debug('nuDseBankAccList1 '+nuDseBankAccList1);
        System.assertEquals(3,nuDseBankAccList1.size());
                                                         
    }
    
    @isTest
    static void update_NudebtBankAcc_To_PrizmBankAcc() {
    
        List<nu_dse__Bank_Account__c> nuDseBankAccList = [SELECT Id,nu_dse__Holder_s_Name__c,nu_dse__Routing_Number__c,Prizm_External_Id__c  FROM nu_dse__Bank_Account__c]; 
        System.assertEquals(1,nuDseBankAccList.size());
        System.debug(nuDseBankAccList);
        nuDseBankAccList[0].nu_dse__Holder_s_Name__c = 'XXX';
        nuDseBankAccList[0].nu_dse__Routing_Number__c = '11111';
        update nuDseBankAccList;
        
        List<fsCore__Bank_Account__c> fsCoreBankAccountList = [SELECT fsCore__Bank_Account_Number__c,fsCore__Bank_Account_Holder_Name__c,      
                                                               fsCore__Bank_Account_Type__c,fsCore__Bank_Identification_Code__c FROM fsCore__Bank_Account__c];
        System.assertEquals(1,fsCoreBankAccountList.size());
        System.assertEquals('XXX',fsCoreBankAccountList[0].fsCore__Bank_Account_Holder_Name__c);   
        System.assertEquals('11111',fsCoreBankAccountList[0].fsCore__Bank_Identification_Code__c);     
    }
    
    @isTest 
    static void errorCheckingFieldMapping() {
        List<nu_dse__Data_Mapping__c>  dataMappingList = [SELECT Id FROM nu_dse__Data_Mapping__c];
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();       
        nu_dse__Field_mapping__c fieldMappingInstance = new nu_dse__Field_mapping__c();
        fieldMappingInstance.nu_dse__Data_Mapping__c = dataMappingList[0].Id;
        fieldMappingInstance.nu_dse__Source_Field__c = 'nu_dse__City__c';
        fieldMappingInstance.nu_dse__Target_Field__c = 'fsCore__Bank_Branch_Name__c';
        fieldMappingInstance.nu_dse__setDefaultValue__c = true;
        fieldMappingInstance.nu_dse__Is_Required__c = true;
        fieldMappingList.add(fieldMappingInstance);
        
        nu_dse__Field_mapping__c fieldMappingInstance1 = new nu_dse__Field_mapping__c();
        fieldMappingInstance1.nu_dse__Data_Mapping__c = dataMappingList[0].Id;
        fieldMappingInstance1.nu_dse__Source_Field__c = 'nu_dse__City__c';
        fieldMappingInstance1.nu_dse__Target_Field__c = 'fsCore__Bank_Branch_Name__c';
        fieldMappingInstance1.nu_dse__Is_Required__c = true;
        fieldMappingList.add(fieldMappingInstance1);
        insert fieldMappingList;
        
        List<nu_dse__Bank_Account__c> nuDseBankAccList = [SELECT Id,nu_dse__Holder_s_Name__c,nu_dse__Routing_Number__c,Prizm_External_Id__c  FROM nu_dse__Bank_Account__c]; 
        System.assertEquals(1,nuDseBankAccList.size());
        System.debug(nuDseBankAccList);
        nuDseBankAccList[0].nu_dse__Holder_s_Name__c = 'XXX';
        nuDseBankAccList[0].nu_dse__Routing_Number__c = '11111';
        update nuDseBankAccList;
        List<nu_dse__Error_log__c> errorLogList = [SELECT Id,nu_dse__Class_Method__c,nu_dse__Message__c,nu_dse__Stack_Trace__c FROM nu_dse__Error_log__c
                                                   WHERE nu_dse__Class_Method__c = 'BankAccountHandler.syncToPrizmBankAccount'];
        System.debug('errorLogList '+errorLogList);
        System.assertEquals(1,errorLogList.size());
    }
    @isTest
    static void upsertErrorChecking_NudebtBankAcc_To_PrizmBankAcc() {  
         
        List<nu_dse__Data_Mapping__c>  dataMappingList = [SELECT Id FROM nu_dse__Data_Mapping__c];       
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();       
        nu_dse__Field_mapping__c fieldMappingInstance = new nu_dse__Field_mapping__c();
        fieldMappingInstance.nu_dse__Data_Mapping__c = dataMappingList[0].Id;
        fieldMappingInstance.nu_dse__Target_Field__c = 'fsCore__Bank_Identification_Code__c';
        fieldMappingInstance.nu_dse__setDefaultValue__c = true;
        fieldMappingInstance.nu_dse__Default_Value__c = '3454312343212345678909776565487766';
        fieldMappingList.add(fieldMappingInstance);
        insert fieldMappingList;
        
        List<nu_dse__Bank_Account__c> nuDseBankAccList = [SELECT Id,nu_dse__Holder_s_Name__c,nu_dse__Routing_Number__c,Prizm_External_Id__c  FROM nu_dse__Bank_Account__c]; 
        System.assertEquals(1,nuDseBankAccList.size());
        System.debug(nuDseBankAccList);
        nuDseBankAccList[0].nu_dse__Holder_s_Name__c = 'XXX';
        nuDseBankAccList[0].nu_dse__Routing_Number__c = '11111';
        update nuDseBankAccList;
        List<nu_dse__Error_log__c> errorLogList = [SELECT Id,nu_dse__Class_Method__c,nu_dse__Message__c,nu_dse__Stack_Trace__c FROM nu_dse__Error_log__c
                                                   WHERE nu_dse__Class_Method__c = 'BankAccountHandler.syncToPrizmBankAccount'];
        System.debug('errorLogList '+errorLogList);
        System.assertEquals(1,errorLogList.size());
    }
    
    @isTest
    static void catchChecking_NudebtBankAcc_To_PrizmBankAcc() {
        
        List<nu_dse__Data_Mapping__c>  dataMappingList = [SELECT Id FROM nu_dse__Data_Mapping__c];       
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();       
        nu_dse__Field_mapping__c fieldMappingInstance = new nu_dse__Field_mapping__c();
        fieldMappingInstance.nu_dse__Data_Mapping__c = dataMappingList[0].Id;
        fieldMappingInstance.nu_dse__Source_Field__c = 'nu_dse__Holder_s_Name__c';
        fieldMappingInstance.nu_dse__Target_Field__c = 'fsCore__Is_Primary__c';
        fieldMappingList.add(fieldMappingInstance);
        insert fieldMappingList;
        
        List<nu_dse__Bank_Account__c> nuDseBankAccList = [SELECT Id,nu_dse__Holder_s_Name__c,nu_dse__Routing_Number__c,Prizm_External_Id__c  FROM nu_dse__Bank_Account__c]; 
        System.assertEquals(1,nuDseBankAccList.size());
        System.debug(nuDseBankAccList);
        nuDseBankAccList[0].nu_dse__Holder_s_Name__c = 'XXX';
        nuDseBankAccList[0].nu_dse__Routing_Number__c = '11111';
        update nuDseBankAccList;
        
        List<nu_dse__Error_log__c> errorLogList = [SELECT Id,nu_dse__Class_Method__c,nu_dse__Message__c,nu_dse__Stack_Trace__c FROM nu_dse__Error_log__c
                                                   WHERE nu_dse__Class_Method__c = 'BankAccountHandler.syncToPrizmBankAccount'];
        System.debug('errorLogList '+errorLogList);
        System.assertEquals(1,errorLogList.size());
    }
   
}