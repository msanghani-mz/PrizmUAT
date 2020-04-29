/*
Copyright (c) 2020, Strategic Financial Solutions.
All rights reserved. 
*/
@isTest
public with sharing class LendingApplicationTiggerHandlerTest {
    @testsetup
    static void createTestData(){
        
   TestHelperData.createTriggerExecutionTestData();

        List<nu_dse__Data_Mapping__c> dataMappingList = new List<nu_dse__Data_Mapping__c>();
        
        nu_dse__Data_Mapping__c dataMappingInstance1 = new nu_dse__Data_Mapping__c();
        dataMappingInstance1.Name = 'PrizmAccountToNuDebtAccount';
        dataMappingInstance1.nu_dse__Source_sObject__c = 'Account';
        dataMappingInstance1.nu_dse__Target_sObject__c = 'Account';
        dataMappingList.add(dataMappingInstance1);
        
        nu_dse__Data_Mapping__c dataMappingInstance2 = new nu_dse__Data_Mapping__c();
        dataMappingInstance2.Name = 'PrizmCoClientAccountToNuDebtAccount';
        dataMappingInstance2.nu_dse__Source_sObject__c = 'Account';
        dataMappingInstance2.nu_dse__Target_sObject__c = 'Account';
        dataMappingList.add(dataMappingInstance2);
        
        nu_dse__Data_Mapping__c dataMappingInstance3 = new nu_dse__Data_Mapping__c();
        dataMappingInstance3.Name = 'PrizmBankAccountToNuDebtBankAccount';
        dataMappingInstance3.nu_dse__Source_sObject__c = 'PrizmBankAccount';
        dataMappingInstance3.nu_dse__Target_sObject__c = 'NuDebtBankAccount';
        dataMappingList.add(dataMappingInstance3);
        
        nu_dse__Data_Mapping__c dataMappingInstance4 = new nu_dse__Data_Mapping__c();
        dataMappingInstance4.Name = 'PrizmAccountToNuDebtProgram';
        dataMappingInstance4.nu_dse__Source_sObject__c = 'Account';
        dataMappingInstance4.nu_dse__Target_sObject__c = 'Program';
        dataMappingList.add(dataMappingInstance4);
        
        insert dataMappingList;
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
    
        nu_dse__Field_mapping__c fieldMappingInstance1 = new nu_dse__Field_mapping__c();
        fieldMappingInstance1.nu_dse__Data_Mapping__c = dataMappingInstance1.Id;
        fieldMappingInstance1.nu_dse__Source_Field__c = 'LastName';
        fieldMappingInstance1.nu_dse__Target_Field__c = 'LastName';
        fieldMappingList.add(fieldMappingInstance1);
        
        nu_dse__Field_mapping__c fieldMappingInstance2 = new nu_dse__Field_mapping__c();
        fieldMappingInstance2.nu_dse__Data_Mapping__c = dataMappingInstance1.Id;
        fieldMappingInstance2.nu_dse__setDefaultValue__c = TRUE;
        fieldMappingInstance2.nu_dse__Default_Value__c = '(321) 654-00';
        fieldMappingInstance2.nu_dse__Target_Field__c = 'nu_dse__Work_Phone__c';
        fieldMappingList.add(fieldMappingInstance2);
        
        nu_dse__Field_mapping__c fieldMappingInstance3 = new nu_dse__Field_mapping__c();
        fieldMappingInstance3.nu_dse__Data_Mapping__c = dataMappingInstance1.Id;
        fieldMappingInstance3.nu_dse__Source_Field__c = 'Id';
        fieldMappingInstance3.nu_dse__Target_Field__c = 'Prizm_External_Id__c';
        fieldMappingList.add(fieldMappingInstance3);
        
        nu_dse__Field_mapping__c fieldMappingInstance4 = new nu_dse__Field_mapping__c();
        fieldMappingInstance4.nu_dse__Data_Mapping__c = dataMappingInstance2.Id;
        fieldMappingInstance4.nu_dse__Source_Field__c = 'LastName';
        fieldMappingInstance4.nu_dse__Target_Field__c = 'nu_dse__Co_Last_Name__c';
        fieldMappingList.add(fieldMappingInstance4);
        
        nu_dse__Field_mapping__c fieldMappingInstance5 = new nu_dse__Field_mapping__c();
        fieldMappingInstance5.nu_dse__Data_Mapping__c = dataMappingInstance2.Id;
        fieldMappingInstance5.nu_dse__Source_Field__c = 'Phone';
        fieldMappingInstance5.nu_dse__Target_Field__c = 'nu_dse__Cell_phone__c';
        fieldMappingList.add(fieldMappingInstance5);
        
        nu_dse__Field_mapping__c fieldMappingInstance51 = new nu_dse__Field_mapping__c();
        fieldMappingInstance51.nu_dse__Data_Mapping__c = dataMappingInstance2.Id;
        fieldMappingInstance51.nu_dse__setDefaultValue__c = TRUE;
        fieldMappingInstance51.nu_dse__Default_Value__c = '(321) 654-00';
        fieldMappingInstance51.nu_dse__Target_Field__c = 'nu_dse__Cell_phone__c';
        fieldMappingList.add(fieldMappingInstance51);
        
        nu_dse__Field_mapping__c fieldMappingInstance6 = new nu_dse__Field_mapping__c();
        fieldMappingInstance6.nu_dse__Data_Mapping__c = dataMappingInstance3.Id;
        fieldMappingInstance6.nu_dse__Source_Field__c = 'fsCore__Bank_Account_Number__c';
        fieldMappingInstance6.nu_dse__Target_Field__c = 'nu_dse__Bank_Account_Number__c';
        fieldMappingList.add(fieldMappingInstance6);
        
        nu_dse__Field_mapping__c fieldMappingInstance61 = new nu_dse__Field_mapping__c();
        fieldMappingInstance61.nu_dse__Data_Mapping__c = dataMappingInstance3.Id;
        fieldMappingInstance61.nu_dse__setDefaultValue__c = TRUE;
        fieldMappingInstance61.nu_dse__Default_Value__c = '123123344';
        fieldMappingInstance61.nu_dse__Target_Field__c = 'nu_dse__Bank_Account_Number__c';
        fieldMappingList.add(fieldMappingInstance61);
        
        nu_dse__Field_mapping__c fieldMappingInstance7 = new nu_dse__Field_mapping__c();
        fieldMappingInstance7.nu_dse__Data_Mapping__c = dataMappingInstance3.Id;
        fieldMappingInstance7.nu_dse__Source_Field__c = 'fsCore__Bank_Account_Holder_Name__c';
        fieldMappingInstance7.nu_dse__Target_Field__c = 'nu_dse__Holder_s_Name__c';
        fieldMappingList.add(fieldMappingInstance7);

        nu_dse__Field_mapping__c fieldMappingInstance71 = new nu_dse__Field_mapping__c();
        fieldMappingInstance71.nu_dse__Data_Mapping__c = dataMappingInstance3.Id;
        fieldMappingInstance71.nu_dse__Source_Field__c = 'fsCore__Account_Name__r.PersonMailingCity';
        fieldMappingInstance71.nu_dse__Target_Field__c = 'nu_dse__City__c';
        fieldMappingList.add(fieldMappingInstance71);

        nu_dse__Field_mapping__c fieldMappingInstance72 = new nu_dse__Field_mapping__c();
        fieldMappingInstance72.nu_dse__Data_Mapping__c = dataMappingInstance3.Id;
        fieldMappingInstance72.nu_dse__Source_Field__c = 'fsCore__Account_Name__r.PersonMailingStateCode';
        fieldMappingInstance72.nu_dse__Target_Field__c = 'nu_dse__State__c';
        fieldMappingList.add(fieldMappingInstance72);

        nu_dse__Field_mapping__c fieldMappingInstance73 = new nu_dse__Field_mapping__c();
        fieldMappingInstance73.nu_dse__Data_Mapping__c = dataMappingInstance3.Id;
        fieldMappingInstance73.nu_dse__Source_Field__c = 'fsCore__Account_Name__r.PersonMailingPostalCode';
        fieldMappingInstance73.nu_dse__Target_Field__c = 'nu_dse__Zip__c';
        fieldMappingList.add(fieldMappingInstance73); 

        nu_dse__Field_mapping__c fieldMappingInstance74 = new nu_dse__Field_mapping__c();
        fieldMappingInstance74.nu_dse__Data_Mapping__c = dataMappingInstance3.Id;
        fieldMappingInstance74.nu_dse__Source_Field__c = 'fsCore__Account_Name__r.Phone';
        fieldMappingInstance74.nu_dse__Target_Field__c = 'nu_dse__Telephone__c';
        fieldMappingList.add(fieldMappingInstance74);                        
        
        nu_dse__Field_mapping__c fieldMappingInstance8 = new nu_dse__Field_mapping__c();
        fieldMappingInstance8.nu_dse__Data_Mapping__c = dataMappingInstance4.Id;
        fieldMappingInstance8.nu_dse__Default_Value__c = 'Monthly';
        fieldMappingInstance8.nu_dse__setDefaultValue__c = TRUE;
        fieldMappingInstance8.nu_dse__Target_Field__c = 'nu_dse__Payment_Frequency__c';
        fieldMappingList.add(fieldMappingInstance8);
        
        nu_dse__Field_mapping__c fieldMappingInstance9 = new nu_dse__Field_mapping__c();
        fieldMappingInstance9.nu_dse__Data_Mapping__c = dataMappingInstance4.Id;
        fieldMappingInstance9.nu_dse__Source_Field__c = 'Phone';
        fieldMappingInstance9.nu_dse__Target_Field__c = 'nu_dse__CIP_CFT_Id__c';
        fieldMappingList.add(fieldMappingInstance9);
        
        insert fieldMappingList;
        
        List<Account> accList = new List<Account>();
        
        Account accInstance1 = new Account();
        accInstance1.LastName = 'test 1';
        accInstance1.Phone = '(321) 654-1';
        accInstance1.PersonMailingCity = 'Saint Petersburg';
        accInstance1.PersonMailingStateCode = 'FL';
        accInstance1.PersonMailingState = 'Florida';
        accInstance1.PersonMailingPostalCode = '33716';
        accInstance1.PersonMailingCountry = 'United States';
        accInstance1.PersonMailingCountryCode = 'US';

        accInstance1.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        accList.add(accInstance1);
        
        Test.startTest();
        insert accList;
        Test.stopTest();
        
        fsCore__Bank_Account__c bankAcc = new fsCore__Bank_Account__c();
        bankAcc.Name = 'bank';
        bankAcc.fsCore__Bank_Account_Number__c = '123456';
        bankAcc.fsCore__Account_Name__c = accInstance1.Id;
        bankAcc.fsCore__Bank_Identification_Code__c = '064000059';
        bankAcc.fsCore__Bank_Account_Holder_Name__c  = 'test';
        bankAcc.fsCore__Is_Active__c = TRUE;
        
        insert bankAcc;
      
       
        system.debug('testSetUp:::::');
          //create company and branch
        //create custom settings
        fsCore.SeedCustomSettings.createCustomSettings(new Set<String>{fsCore.Constants.CUSTOM_SETTING_CUSTOM_NUMBER_FORMAT});
       
        //create company and branch
        fsCore__Company_Setup__c testCompany = fsCore.TestHelperCompany.getTestCompanySetup('Test Company', 'TESTCO', '123456789');
        insert testCompany;
        System.assert(testCompany.Id != null, 'Test company created assert');        
            
        fsCore__Branch_Setup__c testBranch = fsCore.TestHelperCompany.getTestBranchSetup('Test Branch', 'TBRCH', testCompany.Id, null, null);
        insert testBranch;
        System.assert(testBranch.Id != null, 'Test branch created assert');        

        //
        //create product
        //
        fsCore__Product_Setup__c testProduct = fsCore.TestHelperProduct.getTestProductSetup('Test Product'
                                                                            , 'VCL'
                                                                            , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                            , fsCore.Constants.CYCLE_MONTHLY
                                                                            , 1);
        testProduct.fsCore__Customer_Type__c = 'Person Account';
        testProduct.fsCore__Active_Application_Record_Type__c = 'VCL_Loan';
        testProduct.fsServ__Active_Contract_Record_Type__c = 'VCL_Active_Contract';
        insert testProduct;
        System.assert(testProduct.Id != null, 'Test product created assert');        
 
        //
        //create contract template
        //
        fsCore__Payment_Allocation_Method_Setup__c testPaymentAlloc = fsCore.TestHelperFinancial.getTestPaymentAllocMethod('Test Payment Allocation');
        insert testPaymentAlloc;

        fsCore__Contract_Template_Setup__c testContractTemplate = fsCore.TestHelperProduct.getTestContractTemplateSetup
                                                                                ('Test Contract Template'
                                                                               , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                               , testPaymentAlloc.Id
                                                                               , 1);
        insert testContractTemplate;    
        System.assert(testContractTemplate.Id != null, 'Test contract template created assert');        
    
        //create Account
        Account testAccount = TestHelperData.createAccount();
        Database.insert(testAccount);
        System.assert(testAccount.Id != null, 'Test Account created assert');

        //create Lending Applications by populating company, branch, product, contract template
    
        List<fsCore__Lending_Application__c> testAppsList = fsCore.TestHelperLendingApplication.getTestApplicationBulk(testCompany
                                                                              , testBranch
                                                                              , testProduct
                                                                              , testContractTemplate
                                                                              , 2);
        Id recTypeId = Schema.SObjectType.fsCore__Lending_Application__c.getRecordTypeInfosByDeveloperName().get('VCL_Loan').getRecordTypeId();
        List<fsCore__Lending_Application_Customer__c> testAppCustomers = new List<fsCore__Lending_Application_Customer__c>();
        for (fsCore__Lending_Application__c apps: testAppsList){
            apps.fsCore__Primary_Customer_Account__c = testAccount.Id;
        	apps.RecordTypeId = recTypeId; 
        }
        
        fsCore.DMLResult saveRslt = fsCore.LendingApplicationDMLWrapper.getInstance().insertData(testAppsList);
        
        if (saveRslt.hasErrors()) { 
            system.debug(logginglevel.error,saveRslt.getErrorList());
        }
        
        System.assertEquals(2, saveRslt.getSuccessRecordList().size());
        testAppCustomers.add(fsCore.TestHelperLendingApplication.getTestCustomer(testAppsList[0]
                                                                                 ,testAccount.Id
                                                                                 ,testAccount.PersonContactId
                                                                                 ,'Primary'));
        testAppCustomers.add(fsCore.TestHelperLendingApplication.getTestCustomer(testAppsList[1]
                                                                                 ,testAccount.Id
                                                                                 ,testAccount.PersonContactId
                                                                                 ,'Secondary'));

        insert testAppCustomers;
        
        fsCore__Bank_Account__c bankAccount = new fsCore__Bank_Account__c();
        bankAccount.Name = 'bank';
        bankAccount.fsCore__Bank_Account_Number__c = '1234567';
        bankAccount.fsCore__Account_Name__c = testAccount.Id;
        bankAccount.fsCore__Bank_Identification_Code__c = '064000059';
        bankAccount.fsCore__Bank_Account_Holder_Name__c  = 'test';
        bankAccount.fsCore__Is_Active__c = TRUE;
        
        insert bankAccount;
        
        system.debug('testAppsList::::'+testAppsList);
        system.debug('testAppCustomers::::'+testAppCustomers);
    } 
    
    @isTest
    private static void testOnAfterUpdate(){
        List<fsCore__Lending_Application__c> testApps = [Select id, Name from fsCore__Lending_Application__c];
        Test.StartTest();
        for (fsCore__Lending_Application__c app: testApps) {
            app.fsCore__Application_Status__c = 'Lead Underwriter Approved';
        }
        update testApps;
        Test.StopTest();
    }
}