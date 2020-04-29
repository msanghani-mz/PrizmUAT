/**
* Class Name  : GenerateCustomChkLstActionProcessorTest
* Description : This class has test method for  GenerateCustomChkLstActionProcessor
* Author      : Financial Spectra
*
*/
@isTest
public with sharing class  GenerateCustomChkLstActionProcessorTest {
    @testSetup
    static void createTestData(){
        TestHelperData.createTriggerExecutionTestData();
        //create company and branch
        fsCore__Company_Setup__c testCompany = fsCore.TestHelperCompany.getTestCompanySetup('Test Company'
                                                                                            , 'TESTCO'
                                                                                            , '123456789');
        insert testCompany;
        System.assert(testCompany.Id != null, 'Test company created assert');
        
        fsCore__Branch_Setup__c testBranch = fsCore.TestHelperCompany.getTestBranchSetup('Test Branch'
                                                                                         , 'VLB'
                                                                                         , testCompany.Id
                                                                                         , null
                                                                                         , null);
        insert testBranch;
        System.assert(testBranch.Id != null, 'Test branch created assert'); 
        
       //Create Product
        fsCore__Product_Setup__c testProduct = fsCore.TestHelperProduct.getTestProductSetup('Test Product'
                                                                                            , 'VCL'
                                                                                            , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                                            , fsCore.Constants.CYCLE_MONTHLY
                                                                                            , 1);
        testProduct.fsCore__Customer_Name_Format__c='Account Only';
        testProduct.fsCore__Customer_Type__c= 'Account';
        testProduct.Credit_Pull_Report_Record_Type_Name__c ='VCL';
        insert testProduct;
        System.assert(testProduct.Id != null, 'Test product created assert');   
        
        //create contract template
        fsCore__Payment_Allocation_Method_Setup__c testPaymentAlloc = fsCore.TestHelperFinancial.getTestPaymentAllocMethod('Test Payment Allocation');
        insert testPaymentAlloc;
        
        //create Contract Template
        fsCore__Contract_Template_Setup__c testContractTemplate = fsCore.TestHelperProduct.getTestContractTemplateSetup
            ('Test Contract Template'
             , fsCore.Constants.PRODUCT_FAMILY_LOAN
             , testPaymentAlloc.Id
             , 1);
        insert testContractTemplate;    
        System.assert(testContractTemplate.Id != null, 'Test contract template created assert');        
        
        //create Account
        Account nAccount = TestHelperData.createAccount();
        Database.insert(nAccount);
        System.assert(nAccount.Id != null, 'Test Account created assert');
        
        Account testAccount = [select id, personcontactId from Account where id = :nAccount.id limit 1];
        system.debug(logginglevel.error,'testAccount.personcontactId :'+testAccount.personcontactId);
        
        //Create Lending Application
        List<fsCore__Lending_Application__c> testAppsList = fsCore.TestHelperLendingApplication.getTestApplicationBulk(testCompany
                                                                                                                       , testBranch
                                                                                                                       , testProduct
                                                                                                                       , testContractTemplate
                                                                                                                       , 200);
        
        fsCore__Lending_Application__c testApp = testAppsList[0];
        testApp.fsCore__Primary_Customer_Account__c = testAccount.Id;
        
        Database.insert(testApp);
        System.assert(testApp.Id != null, 'Test Lending Application created assert');
        
        //create Opportunity
        Opportunity testOpportunity = TestHelperData.createDNLOpportunity(testAccount.Id);
        testOpportunity.Related_Lending_Application__c = testApp.Id;
        testOpportunity.Import_Id__c = testApp.Id;
        Database.insert(testOpportunity);
        System.assert(testOpportunity.Id != null, 'Test Opportunity created assert');
        
        testApp.Opp_Import_Id__c = testOpportunity.Id;
        Database.update(testApp);
        
        //create Checklist Setup
        List<fsCore__Checklist_Setup__c> testCheckList = TestHelperData.createcheckList();
        insert testCheckList;
        
        //create Checklist Detail Setup
        List<fsCore__Checklist_Detail_Setup__c> testChecklistDetailSetUp = TestHelperData.createcheckListDetail(testCheckList);
        insert testChecklistDetailSetUp;
        
        //create Employment
        fsCore__Employment__c   testEmployment = fsCore.TestHelperMaster.getTestEmployment(testAccount.PersonContactId
                                                                                           ,'Test Employment'
                                                                                           , Date.today()
                                                                                           ,100000);
        insert testEmployment;
        System.assert(testEmployment.Id != null, 'Test Employment  created assert');
        
        //create Financials
        List<fsCore__Financial__c> testFinancialSetUp = TestHelperData.createFinancials(testAccount.Id, testAccount.PersonContactId, testEmployment.Id);
        insert testFinancialSetUp;
        System.assert(testFinancialSetUp[0].Id != null, 'Test Financials  created assert');
        
        //create Lending Application Customer Secondary
        fsCore__Lending_Application_Customer__c  testAppCustomer1 = fsCore.TestHelperLendingApplication.getTestCustomer(testApp
                                                                                                                        ,testAccount.Id
                                                                                                                        ,testAccount.PersonContactId
                                                                                                                        ,'Primary');
        insert testAppCustomer1;
        System.assert(testAppCustomer1.Id != null, 'Test Lending Application Customer1 created assert');
        
        fsCore__Lending_Application_Customer__c  testAppCustomer2 = fsCore.TestHelperLendingApplication.getTestCustomer(testApp
                                                                                                                        ,testAccount.Id
                                                                                                                        ,testAccount.PersonContactId
                                                                                                                        ,'Secondary');
        insert testAppCustomer2;
        System.assert(testAppCustomer2.Id != null, 'Test Lending Application Customer2 created assert');
        
    }
    
    /**
* 
*/
    private static testMethod void testActionProcessor(){
        
        fsCore__Lending_Application__c testApplication = [SELECT id, name 
                                                          FROM fsCore__Lending_Application__c
                                                          LIMIT 1];   
        
        fsCore.ActionInput acrInput = new fsCore.ActionInput();
        acrInput.addRecord(testApplication.Id);
        
        Test.startTest(); 
        GenerateCustomChkLstActionProcessor analysisAction = new  GenerateCustomChkLstActionProcessor();
        analysisAction.setInput(acrInput);
        analysisAction.process();
        Test.stopTest();        
    }
    
    private static testMethod void addError(){
        
        fsCore__Lending_Application__c testApplication = [SELECT id, name 
                                                          FROM fsCore__Lending_Application__c
                                                          LIMIT 1];  
        
        GenerateCustomChkLstActionProcessor analysisAction = new  GenerateCustomChkLstActionProcessor();
        analysisAction.addError('Test','Test','Test',testApplication.Id,' Dummy');
        
        
    }
    
    
    private static testMethod void testGenerateIncomeDocumentChecklist(){
        fsCore__Lending_Application__c testApplication = [SELECT id, name 
                                                          FROM fsCore__Lending_Application__c
                                                          LIMIT 1];        
        Test.startTest(); 
        GenerateCustomChkLstActionProcessor.generateIncomeDocumentChecklist(testApplication.Id);
        Test.stopTest();        
    }
}