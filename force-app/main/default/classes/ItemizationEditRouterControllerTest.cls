/*
 * Copyright (c) 2017 FinancialSpectra Pty Ltd
 * All rights reserved.
 * 
 * Class Name   - ItemizationEditRouterControllerTest
 * 
 * Description  - Test class for Controller for visualforce page - editItemizationRouter
 * 
 *
 */
@isTest
Private class ItemizationEditRouterControllerTest {
 @testSetup
    static void createTestData(){
        TestHelperData.createTriggerExecutionTestData();
        
        //create custom settings
        fsCore.SeedCustomSettings.createCustomSettings(new Set<String>{fsCore.Constants.CUSTOM_SETTING_CUSTOM_NUMBER_FORMAT
            , fsCore.Constants.CUSTOM_SETTING_CALCULATOR_PREFERENCE});
        
        //create company and branch
        fscore__Company_Setup__c testCompany = fsCore.TestHelperCompany.getTestCompanySetup('Test Company', 'TESTCO', '123456789');
        insert testCompany;
        System.assert(testCompany.Id != null, 'Test company created assert');        
        
        fsCore__Branch_Setup__c testBranch = fsCore.TestHelperCompany.getTestBranchSetup('Test Branch', 'TBRCH', testCompany.Id, null, null);
        insert testBranch;
        System.assert(testBranch.Id != null, 'Test branch created assert');        
        
        //
        //create balance, transaction and itemization setup
        //
        Map<String, fsCore__Balance_Setup__c> testBalanceSetupMap = fsCore.TestHelperFinancial.getTestBalanceSetupMap();
        System.assert(testBalanceSetupMap.size() > 0, 'Test Balance setup created assert');  
        System.debug(testBalanceSetupMap);
        
        Map<String, fsCore__Transaction_Setup__c> testTxnSetupMap = fsCore.TestHelperFinancial.getTestTransactionSetupMap();
        System.assert(testTxnSetupMap.size() > 0, 'Test Transaction setup created assert');        
        System.debug('txn'+testTxnSetupMap);
        
        
        Map<String, fsCore__Itemization_Setup__c> testItmzSetupMap = fsCore.TestHelperFinancial.getTestItemizationSetupMap();
        System.assert(testItmzSetupMap.size() > 0, 'Test Itemization setup created assert');  
 
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
        //create product itemizations
        //
        List<fsCore__Product_Itemization_Setup__c> testProductItzms = new List<fsCore__Product_Itemization_Setup__c>();
        testProductItzms.add(fsCore.TestHelperProduct.getTestProductItemizationSetup(testProduct.Id
                                                                                     , testItmzSetupMap.get('Funds to Customer')
                                                                                     , 'Yes'
                                                                                     , 1, fsCore.Constants.PLUS));
        testProductItzms.add(fsCore.TestHelperProduct.getTestProductItemizationSetup(testProduct.Id
                                                                                     , testItmzSetupMap.get('Down Payment')
                                                                                     , 'No'
                                                                                     , 2, fsCore.Constants.MINUS));
        
        fsCore__Product_Itemization_Setup__c testPpdFeeItzm = fsCore.TestHelperProduct.getTestProductItemizationSetup(
            testProduct.Id
            , testItmzSetupMap.get('Application Fee')
            , 'No'
            , 3, fsCore.Constants.PLUS);
        testPpdFeeItzm.fsCore__Fee_Category__c = 'Origination Fee';
        testProductItzms.add(testPpdFeeItzm);
        
        fsCore__Product_Itemization_Setup__c testFinFeeItzm = fsCore.TestHelperProduct.getTestProductItemizationSetup(
            testProduct.Id
            , testItmzSetupMap.get('Financed Fee')
            , 'No'
            , 4, fsCore.Constants.PLUS);
        testFinFeeItzm.fsCore__Fee_Category__c = 'Prepaid Finance Charge';
        testProductItzms.add(testFinFeeItzm);

        insert testProductItzms;
        System.assert(testProductItzms.size() > 0, 'Test product itemizations created assert');        
        
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
        
        fsCore__Contract_Template_Itemization_Setup__c testCTItmz = fsCore.TestHelperProduct.getTestContractTemplateItemizationSetup(
            testContractTemplate.Id
            , testItmzSetupMap.get('Funds to Customer')
            , 'Yes'
            , 1, fsCore.Constants.PLUS);
        insert testCTItmz;
        System.assert(testCTItmz.Id != null, 'Test contract template itemization created assert');        
        
        
        //
        //create Lending Application by populating company, branch, product
        //
        fsCore__Lending_Application__c testApplication 
            = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                               , testBranch
                                                                               , testProduct
                                                                               , testContractTemplate
                                                                               , 'Test Application');
        insert testApplication;
        System.assert(testApplication.Id != null, 'Test Lending Application created assert');        
        
        //
        //create Lending Application itemizations
        //
        List<fsCore__Lending_Application_Itemization__c> testAppItemizations 
            = fsCore.TestHelperLendingApplication.getTestApplicationItemizations(testApplication, testProductItzms);
        insert testAppItemizations;
        System.assert(testAppItemizations.size() > 0, 'Test Lending Application itemizations created assert');
        
    }
    @isTest
    Static void testtMethod1(){
       fsCore__Lending_Application__c testApp  = [Select Id ,Name from fsCore__Lending_Application__c Limit 1];
      test.startTest();
            ApexPages.StandardController stdCntrl = new ApexPages.StandardController(testApp);
            ItemizationEditRouterController  testEditCntrl = new ItemizationEditRouterController(stdCntrl);
            testEditCntrl.redirectToComponent();
   test.stopTest();

    }
}