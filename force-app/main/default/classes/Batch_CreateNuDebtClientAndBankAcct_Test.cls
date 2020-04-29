/**
 * @File Name          : Batch_CreateNuDebtClientAndBankAcct_Test.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 2/2/2020, 9:17:55 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    8/26/2019, 10:08:05 PM   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/  
@isTest
public class Batch_CreateNuDebtClientAndBankAcct_Test {

    @TestSetup
    public static void setup() {

        TestHelperData.createTriggerExecutionTestData();

        TestHelperData.createNuPayDataMappingTestData();
        
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
                                                                            , 'DNL'
                                                                            , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                            , fsCore.Constants.CYCLE_MONTHLY
                                                                            , 1);
        testProduct.fsCore__Customer_Type__c = 'Person Account';
        testProduct.fsCore__Active_Application_Record_Type__c = 'DNL_Loan';
        testProduct.fsServ__Active_Contract_Record_Type__c = 'DNL_Active_Contract';
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


        //
        //create Lending Applications by populating company, branch, product, contract template
        //
        
        List<fsCore__Lending_Application__c> testAppsList = fsCore.TestHelperLendingApplication.getTestApplicationBulk(testCompany
                                                                              , testBranch
                                                                              , testProduct
                                                                              , testContractTemplate
                                                                              , 2);
        for (fsCore__Lending_Application__c apps: testAppsList){
            apps.fsCore__Primary_Customer_Account__c = testAccount.Id;
        }
        
        system.debug('testAppsList::::'+testAppsList);
        fsCore.DMLResult saveRslt = fsCore.LendingApplicationDMLWrapper.getInstance().insertData(testAppsList);
        
        if (saveRslt.hasErrors()) { 
            system.debug(logginglevel.error,saveRslt.getErrorList());
        }
        
        System.assertEquals(2, saveRslt.getSuccessRecordList().size());

        /*
        DO NOT FUND THE APPLICATION HERE ADD CUSTOMER AND THEN FUND THE APP

        for (fsCore__Lending_Application__c apps: testAppsList){
            apps.fsCore__Is_Funded__c = true;
        }
        system.debug('::::::update testAppsList::::');
        fsCore.DMLResult saveUpdRslt = fsCore.LendingApplicationDMLWrapper.getInstance().updateData(testAppsList);
        
        if (saveUpdRslt.hasErrors()) { 
            system.debug(logginglevel.error,saveUpdRslt.getErrorList());
        }
        
        System.assertEquals(2, saveUpdRslt.getSuccessRecordList().size());   */     
        
    }

    @isTest
    static void invalidFieldMappingPrimary() {
    
        List<nu_dse__Data_Mapping__c> dataMappingList = [SELECT Id, Name FROM nu_dse__Data_Mapping__c];
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
        
        nu_dse__Field_mapping__c fieldMappingInstance9 = new nu_dse__Field_mapping__c();
        fieldMappingInstance9.nu_dse__Data_Mapping__c = dataMappingList[0].Id;
        fieldMappingInstance9.nu_dse__Default_Value__c = null;
        fieldMappingInstance9.nu_dse__setDefaultValue__c = TRUE;
        fieldMappingInstance9.nu_dse__Target_Field__c = 'nu_dse__Payment_Frequency__c';
        fieldMappingInstance9.nu_dse__Is_Required__c = TRUE;
        fieldMappingList.add(fieldMappingInstance9);
       
        insert fieldMappingList;
        
        List<Account> accList = [SELECT Id FROM Account];
        
        List<fsCore__Lending_Application__c> lenApp = [SELECT id FROM fsCore__Lending_Application__c];
    
        List<fsCore__Lending_Application_Customer__c> lenAppCustomerList = new List<fsCore__Lending_Application_Customer__c>();
        
        fsCore__Lending_Application_Customer__c lenAppCustomer = new fsCore__Lending_Application_Customer__c();
        lenAppCustomer.fsCore__Account_Name__c = accList[0].Id;
        lenAppCustomer.fsCore__Lending_Application_Number__c = lenApp[0].Id;
        lenAppCustomer.recordTypeId = Schema.SObjectType.fsCore__Lending_Application_Customer__c.getRecordTypeInfosByName().get('Primary').getRecordTypeId();
        lenAppCustomer.fsCore__Customer_Type__c = 'Primary';
        lenAppCustomerList.add(lenAppCustomer);
       
        insert lenAppCustomerList;

        for (fsCore__Lending_Application__c apps: lenApp){
            apps.fsCore__Application_Status__c = SFSConstants.DNL_STATUS_FINAL_SETTLEMENT_REACHED;
            apps.Is_Client_Created__c = False;
        }
        update lenApp;        
        
        Test.StartTest();
        Batch_CreateNuDebtClientAndBankAcct  myBatchObject = new Batch_CreateNuDebtClientAndBankAcct(); 
        Id batchId = Database.executeBatch(myBatchObject,100);       
        Test.StopTest();
        
        List<nu_dse__Error_log__c> errorLogList = [SELECT Id FROM nu_dse__Error_log__c];
        System.assertEquals(4,errorLogList.size());
    }
    
    @isTest
    static void invalidFieldMappingSecondary() {
    
        List<nu_dse__Data_Mapping__c> dataMappingList = [SELECT Id, Name FROM nu_dse__Data_Mapping__c];
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
        
        nu_dse__Field_mapping__c fieldMappingInstance10 = new nu_dse__Field_mapping__c();
        fieldMappingInstance10.nu_dse__Data_Mapping__c = dataMappingList[1].Id;
        fieldMappingInstance10.nu_dse__Default_Value__c = null;
        fieldMappingInstance10.nu_dse__setDefaultValue__c = TRUE;
        fieldMappingInstance10.nu_dse__Target_Field__c = 'nu_dse__Payment_Frequency__c';
        fieldMappingInstance10.nu_dse__Is_Required__c = TRUE;
        fieldMappingList.add(fieldMappingInstance10);
        
        insert fieldMappingList;
        
        List<Account> accList = [SELECT Id FROM Account];
        
        List<fsCore__Lending_Application__c> lenApp = [SELECT id FROM fsCore__Lending_Application__c];
    
        List<fsCore__Lending_Application_Customer__c> lenAppCustomerList = new List<fsCore__Lending_Application_Customer__c>();
        
        fsCore__Lending_Application_Customer__c lenAppCustomer1 = new fsCore__Lending_Application_Customer__c();
        lenAppCustomer1.fsCore__Account_Name__c = accList[0].Id;
        lenAppCustomer1.fsCore__Lending_Application_Number__c = lenApp[0].Id;
        lenAppCustomer1.recordTypeId = Schema.SObjectType.fsCore__Lending_Application_Customer__c.getRecordTypeInfosByName().get('Non-Primary').getRecordTypeId();
        lenAppCustomer1.fsCore__Customer_Type__c = 'Secondary';
        lenAppCustomerList.add(lenAppCustomer1);
        
        insert lenAppCustomerList;

        for (fsCore__Lending_Application__c apps: lenApp){
            apps.fsCore__Application_Status__c = SFSConstants.DNL_STATUS_FINAL_SETTLEMENT_REACHED;
            apps.Is_Client_Created__c = False;
        }
        update lenApp;        
        
        Test.StartTest();
        Batch_CreateNuDebtClientAndBankAcct  myBatchObject = new Batch_CreateNuDebtClientAndBankAcct(); 
        Id batchId = Database.executeBatch(myBatchObject,100);        
        Test.StopTest();
        
        List<nu_dse__Error_log__c> errorLogList = [SELECT Id FROM nu_dse__Error_log__c];
        System.assertEquals(2,errorLogList.size()); 
    }
   
    @isTest
    static void invalidBankAccFieldMapping() {
    
        List<nu_dse__Data_Mapping__c> dataMappingList = [SELECT Id, Name FROM nu_dse__Data_Mapping__c];
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
        
        nu_dse__Field_mapping__c fieldMappingInstance6 = new nu_dse__Field_mapping__c();
        fieldMappingInstance6.nu_dse__Data_Mapping__c = dataMappingList[2].Id;
        fieldMappingInstance6.nu_dse__Default_Value__c = null;
        fieldMappingInstance6.nu_dse__setDefaultValue__c = TRUE;
        fieldMappingInstance6.nu_dse__Target_Field__c = 'nu_dse__Bank_Account_Number__c';
        fieldMappingInstance6.nu_dse__Is_Required__c = TRUE;
        fieldMappingList.add(fieldMappingInstance6);
        
        insert fieldMappingList;
        
        List<Account> accList = [SELECT Id FROM Account];
        
        List<fsCore__Lending_Application__c> lenApp = [SELECT id FROM fsCore__Lending_Application__c];
    
        fsCore__Lending_Application_Customer__c lenAppCustomer = new fsCore__Lending_Application_Customer__c();
        lenAppCustomer.fsCore__Account_Name__c = accList[0].Id;
        lenAppCustomer.fsCore__Lending_Application_Number__c = lenApp[0].Id;
        lenAppCustomer.recordTypeId = Schema.SObjectType.fsCore__Lending_Application_Customer__c.getRecordTypeInfosByName().get('Primary').getRecordTypeId();
        lenAppCustomer.fsCore__Customer_Type__c = 'Primary';
        insert lenAppCustomer;
        
        for (fsCore__Lending_Application__c apps: lenApp){
            apps.fsCore__Application_Status__c = SFSConstants.DNL_STATUS_FINAL_SETTLEMENT_REACHED;
            apps.Is_Client_Created__c = False;
        }
        update lenApp;

        Test.StartTest();
        
        Schedule_CreateNuDebtClientAndBankAcct sch = new Schedule_CreateNuDebtClientAndBankAcct(100);
        sch.execute(null);
        
        Batch_CreateNuDebtClientAndBankAcct  myBatchObject = new Batch_CreateNuDebtClientAndBankAcct(); 
        Id batchId = Database.executeBatch(myBatchObject,100);
        
        
        Test.StopTest();
        
        List<fsCore__Lending_Application__c> lenAppList = [SELECT Id FROM fsCore__Lending_Application__c];
        System.assertEquals(2,lenAppList.size());
    }
   
    @isTest
    static void ResultSuccessTesting() {
    
        List<nu_dse__Data_Mapping__c> dataMappingList = [SELECT Id, Name FROM nu_dse__Data_Mapping__c];
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
        
        nu_dse__Field_mapping__c fieldMappingInstance5 = new nu_dse__Field_mapping__c();
        fieldMappingInstance5.nu_dse__Data_Mapping__c = dataMappingList[0].Id;
        fieldMappingInstance5.nu_dse__Source_Field__c = 'Phone';
        fieldMappingInstance5.nu_dse__Target_Field__c = 'nu_dse__Cell_phone__c';
        fieldMappingList.add(fieldMappingInstance5);
        
        nu_dse__Field_mapping__c fieldMappingInstance4 = new nu_dse__Field_mapping__c();
        fieldMappingInstance4.nu_dse__Data_Mapping__c = dataMappingList[2].Id;
        fieldMappingInstance4.nu_dse__Target_Field__c = 'nu_dse__Bank_Account_Number__c';
        fieldMappingInstance4.nu_dse__setDefaultValue__c = TRUE;
        fieldMappingInstance4.nu_dse__Default_Value__c = 'qwertyuioplkjhgfdsaz';
        fieldMappingList.add(fieldMappingInstance4);
       
        insert fieldMappingList;
        
        List<Account> accList = [SELECT Id FROM Account];
        
        List<fsCore__Lending_Application__c> lenApp = [SELECT id FROM fsCore__Lending_Application__c];
    
        fsCore__Lending_Application_Customer__c lenAppCustomer = new fsCore__Lending_Application_Customer__c();
        lenAppCustomer.fsCore__Account_Name__c = accList[0].Id;
        lenAppCustomer.fsCore__Lending_Application_Number__c = lenApp[0].Id;
        lenAppCustomer.recordTypeId = Schema.SObjectType.fsCore__Lending_Application_Customer__c.getRecordTypeInfosByName().get('Primary').getRecordTypeId();
        lenAppCustomer.fsCore__Customer_Type__c = 'Primary';
        insert lenAppCustomer;

        for (fsCore__Lending_Application__c apps: lenApp){
            apps.fsCore__Application_Status__c = SFSConstants.DNL_STATUS_FINAL_SETTLEMENT_REACHED;
            apps.Is_Client_Created__c = False;
        }
        update lenApp;        
        
        Test.StartTest();
        Batch_CreateNuDebtClientAndBankAcct  myBatchObject = new Batch_CreateNuDebtClientAndBankAcct(); 
        Id batchId = Database.executeBatch(myBatchObject,100);
        Test.StopTest();
        
        List<nu_dse__Error_log__c> errorLogList = [SELECT Id, nu_dse__Class_Method__c, nu_dse__Message__c FROM nu_dse__Error_log__c];
        System.assertEquals(1,errorLogList.size()); 
    }
    
    @isTest
    static void ResultSuccessTestingForPrgm() {
    
        List<nu_dse__Data_Mapping__c> dataMappingList = [SELECT Id, Name FROM nu_dse__Data_Mapping__c];
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
        
        nu_dse__Field_mapping__c fieldMappingInstance4 = new nu_dse__Field_mapping__c();
        fieldMappingInstance4.nu_dse__Data_Mapping__c = dataMappingList[3].Id;
        fieldMappingInstance4.nu_dse__Source_Field__c = 'Phone';
        fieldMappingInstance4.nu_dse__Target_Field__c = 'nu_dse__CIP_CFT_Id__c';
        fieldMappingInstance4.nu_dse__setDefaultValue__c = TRUE;
        fieldMappingInstance4.nu_dse__Default_Value__c = 'qwertyuioplkjhgfd';
        fieldMappingList.add(fieldMappingInstance4);
        
        insert fieldMappingList;
        
        List<Account> accList = [SELECT Id FROM Account];
        
        List<fsCore__Lending_Application__c> lenApp = [SELECT id FROM fsCore__Lending_Application__c];
    
        fsCore__Lending_Application_Customer__c lenAppCustomer = new fsCore__Lending_Application_Customer__c();
        lenAppCustomer.fsCore__Account_Name__c = accList[0].Id;
        lenAppCustomer.fsCore__Lending_Application_Number__c = lenApp[0].Id;
        lenAppCustomer.recordTypeId = Schema.SObjectType.fsCore__Lending_Application_Customer__c.getRecordTypeInfosByName().get('Primary').getRecordTypeId();
        lenAppCustomer.fsCore__Customer_Type__c = 'Primary';
        insert lenAppCustomer;

        for (fsCore__Lending_Application__c apps: lenApp){
            apps.fsCore__Application_Status__c = SFSConstants.DNL_STATUS_FINAL_SETTLEMENT_REACHED;
            apps.Is_Client_Created__c = False;
        }
        update lenApp;        
        
        Test.StartTest();
        Batch_CreateNuDebtClientAndBankAcct  myBatchObject = new Batch_CreateNuDebtClientAndBankAcct(); 
        Id batchId = Database.executeBatch(myBatchObject,100);
        Test.StopTest();
        
        List<nu_dse__Error_log__c> errorLogList = [SELECT Id, nu_dse__Class_Method__c, nu_dse__Message__c FROM nu_dse__Error_log__c];
        System.assertEquals(1,errorLogList.size());  
    }
   
    @isTest
    static void catchTesting() {
    
        List<nu_dse__Data_Mapping__c> dataMappingList = [SELECT Id, Name FROM nu_dse__Data_Mapping__c];
        
        List<nu_dse__Field_mapping__c> fieldMappingList = new List<nu_dse__Field_mapping__c>();
        
        nu_dse__Field_mapping__c fieldMappingInstance5 = new nu_dse__Field_mapping__c();
        fieldMappingInstance5.nu_dse__Data_Mapping__c = dataMappingList[0].Id;
        fieldMappingInstance5.nu_dse__Target_Field__c = 'nu_dse__Payment_Frequency__c';
        fieldMappingInstance5.nu_dse__Source_Field__c = 'Phone';
        fieldMappingList.add(fieldMappingInstance5);
        
        insert fieldMappingList;
        
        List<Account> accList = [SELECT Id FROM Account];
        
        List<fsCore__Lending_Application__c> lenApp = [SELECT id FROM fsCore__Lending_Application__c];
    
        fsCore__Lending_Application_Customer__c lenAppCustomer = new fsCore__Lending_Application_Customer__c();
        lenAppCustomer.fsCore__Account_Name__c = accList[0].Id;
        lenAppCustomer.fsCore__Lending_Application_Number__c = lenApp[0].Id;
        lenAppCustomer.recordTypeId = Schema.SObjectType.fsCore__Lending_Application_Customer__c.getRecordTypeInfosByName().get('Primary').getRecordTypeId();
        lenAppCustomer.fsCore__Customer_Type__c = 'Primary';
        insert lenAppCustomer;

        for (fsCore__Lending_Application__c apps: lenApp){
            apps.fsCore__Application_Status__c = SFSConstants.DNL_STATUS_FINAL_SETTLEMENT_REACHED;
            apps.Is_Client_Created__c = False;
        }
        update lenApp;        
        
        Test.StartTest();
        Batch_CreateNuDebtClientAndBankAcct  myBatchObject = new Batch_CreateNuDebtClientAndBankAcct(); 
        Id batchId = Database.executeBatch(myBatchObject,100);
        Test.StopTest();
        
        List<nu_dse__Error_log__c> errorLogList = [SELECT Id FROM nu_dse__Error_log__c];
        System.assertEquals(1,errorLogList.size());
    }
   
    @isTest
    static void primaryCustomerType() {
    
        List<Account> accList = [SELECT Id FROM Account];
        
        List<fsCore__Lending_Application__c> lenApp = [SELECT id,fsCore__Is_Funded__c FROM fsCore__Lending_Application__c];
    
        fsCore__Lending_Application_Customer__c lenAppCustomer = new fsCore__Lending_Application_Customer__c();
        lenAppCustomer.fsCore__Account_Name__c = accList[0].Id;
        lenAppCustomer.fsCore__Lending_Application_Number__c = lenApp[0].Id;
        lenAppCustomer.recordTypeId = Schema.SObjectType.fsCore__Lending_Application_Customer__c.getRecordTypeInfosByName().get('Primary').getRecordTypeId();
        lenAppCustomer.fsCore__Customer_Type__c = 'Primary';
        insert lenAppCustomer;

        for (fsCore__Lending_Application__c apps: lenApp){
            apps.fsCore__Application_Status__c = SFSConstants.DNL_STATUS_FINAL_SETTLEMENT_REACHED;
            apps.Is_Client_Created__c = False;
        }
        update lenApp;


        
        Test.StartTest();
        
        Schedule_CreateNuDebtClientAndBankAcct sch = new Schedule_CreateNuDebtClientAndBankAcct(null);
        sch.execute(null);
        Test.StopTest();
        Batch_CreateNuDebtClientAndBankAcct  myBatchObject = new Batch_CreateNuDebtClientAndBankAcct(); 
        Id batchId = Database.executeBatch(myBatchObject,100);
        
        
        
        List<fsCore__Bank_Account__c> bankAccInstance = [SELECT Id FROM fsCore__Bank_Account__c]; 
        System.assertEquals(1,bankAccInstance.size());
    }
    
    @isTest
    static void primarySecondaryCustomerType() {
    
        List<Account> accList = [SELECT Id FROM Account];
        
        List<fsCore__Lending_Application__c> lenApp = [SELECT id FROM fsCore__Lending_Application__c];
    
        List<fsCore__Lending_Application_Customer__c> lenAppCustomerList = new List<fsCore__Lending_Application_Customer__c>();
        
        fsCore__Lending_Application_Customer__c lenAppCustomer = new fsCore__Lending_Application_Customer__c();
        lenAppCustomer.fsCore__Account_Name__c = accList[0].Id;
        lenAppCustomer.fsCore__Lending_Application_Number__c = lenApp[0].Id;
        lenAppCustomer.recordTypeId = Schema.SObjectType.fsCore__Lending_Application_Customer__c.getRecordTypeInfosByName().get('Primary').getRecordTypeId();
        lenAppCustomer.fsCore__Customer_Type__c = 'Primary';
        lenAppCustomerList.add(lenAppCustomer);
        
        fsCore__Lending_Application_Customer__c lenAppCustomer1 = new fsCore__Lending_Application_Customer__c();
        lenAppCustomer1.fsCore__Account_Name__c = accList[0].Id;
        lenAppCustomer1.fsCore__Lending_Application_Number__c = lenApp[0].Id;
        lenAppCustomer1.recordTypeId = Schema.SObjectType.fsCore__Lending_Application_Customer__c.getRecordTypeInfosByName().get('Non-Primary').getRecordTypeId();
        lenAppCustomer1.fsCore__Customer_Type__c = 'Secondary';
        lenAppCustomerList.add(lenAppCustomer1);
        
        fsCore__Lending_Application_Customer__c lenAppCustomer2 = new fsCore__Lending_Application_Customer__c();
        lenAppCustomer2.fsCore__Account_Name__c = accList[0].Id;
        lenAppCustomer2.fsCore__Lending_Application_Number__c = lenApp[0].Id;
        lenAppCustomer2.recordTypeId = Schema.SObjectType.fsCore__Lending_Application_Customer__c.getRecordTypeInfosByName().get('Non-Primary').getRecordTypeId();
        lenAppCustomer2.fsCore__Customer_Type__c = 'Secondary';
        lenAppCustomerList.add(lenAppCustomer2);
        
        Account accInstance1 = new Account();
        accInstance1.LastName = 'test 2';
        accInstance1.Phone = '(321) 654-1';
        accInstance1.PersonMailingCity = 'Saint Petersburg';
        accInstance1.PersonMailingStateCode = 'FL';
        accInstance1.PersonMailingState = 'Florida';
        accInstance1.PersonMailingPostalCode = '33716';
        accInstance1.PersonMailingCountry = 'United States';
        accInstance1.PersonMailingCountryCode = 'US';        
        accInstance1.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        
        insert accInstance1;
        
        fsCore__Bank_Account__c bankAcc = new fsCore__Bank_Account__c();
        bankAcc.Name = 'bank';
        bankAcc.fsCore__Bank_Account_Number__c = '123456';
        bankAcc.fsCore__Account_Name__c = accInstance1.Id;
        bankAcc.fsCore__Bank_Identification_Code__c = '064000059';
        bankAcc.fsCore__Bank_Account_Holder_Name__c  = 'test';
        bankAcc.fsCore__Is_Active__c = TRUE;
        
        insert bankAcc;
        
        fsCore__Lending_Application_Customer__c lenAppCustomer3 = new fsCore__Lending_Application_Customer__c();
        lenAppCustomer3.fsCore__Account_Name__c = accInstance1.Id;
        lenAppCustomer3.fsCore__Lending_Application_Number__c = lenApp[1].Id;
        lenAppCustomer3.recordTypeId = Schema.SObjectType.fsCore__Lending_Application_Customer__c.getRecordTypeInfosByName().get('Primary').getRecordTypeId();
        lenAppCustomer3.fsCore__Customer_Type__c = 'Primary';
        lenAppCustomerList.add(lenAppCustomer3);
        
        fsCore__Lending_Application_Customer__c lenAppCustomer4 = new fsCore__Lending_Application_Customer__c();
        lenAppCustomer4.fsCore__Account_Name__c = accInstance1.Id;
        lenAppCustomer4.fsCore__Lending_Application_Number__c = lenApp[1].Id;
        lenAppCustomer4.recordTypeId = Schema.SObjectType.fsCore__Lending_Application_Customer__c.getRecordTypeInfosByName().get('Non-Primary').getRecordTypeId();
        lenAppCustomer4.fsCore__Customer_Type__c = 'Secondary';
        lenAppCustomerList.add(lenAppCustomer4);
        
        insert lenAppCustomerList;


        for (fsCore__Lending_Application__c apps: lenApp){
            apps.fsCore__Application_Status__c = SFSConstants.DNL_STATUS_FINAL_SETTLEMENT_REACHED;
            apps.Is_Client_Created__c = False;
        }
        update lenApp;
 
        
        Test.StartTest();
        
        
        Schedule_CreateNuDebtClientAndBankAcct sch = new Schedule_CreateNuDebtClientAndBankAcct();
        sch.execute(null);
        
        Batch_CreateNuDebtClientAndBankAcct  myBatchObject = new Batch_CreateNuDebtClientAndBankAcct(); 
        Id batchId = Database.executeBatch(myBatchObject,100);
        
        Test.StopTest();
        
        List<fsCore__Lending_Application__c> lenAppInsertList = [SELECT Id FROM fsCore__Lending_Application__c];
        
        System.assertEquals('Secondary',lenAppCustomerList[1].fsCore__Customer_Type__c );
        System.assertEquals(2,lenAppInsertList.size());
        
        List<nu_dse__Bank_Account__c> nuDebtBankAcc = [SELECT id FROM nu_dse__Bank_Account__c];
        
        System.assertEquals(2,nuDebtBankAcc.size());
    }
    
}