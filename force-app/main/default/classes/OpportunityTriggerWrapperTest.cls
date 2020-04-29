/**
 * @File Name          : OpportunityTriggerWrapperTest.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 4/2/2020, 1:13:11 PM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    4/2/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
private class OpportunityTriggerWrapperTest{
    @testSetup
    static void createTestData(){
        
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
        
        //create product
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
        
        //create Balance Setup
        fsCore__Balance_Setup__c  testBalanceSetUp = fsCore.TestHelperFinancial.getTestBalanceSetup('Test Balance'
                                                                                                    , 'Principal');
        insert testBalanceSetUp;
        System.assert(testBalanceSetUp.Id != null, 'Test Balance SetUp created assert');
        
        //create Transaction Setup
        fsCore__Transaction_Setup__c  testTransactionSetUp = fsCore.TestHelperFinancial.getTestTransactionSetup('Test Transaction'
                                                                                                                ,testBalanceSetUp.Id
                                                                                                                ,'Post');
        insert testTransactionSetUp;
        System.assert(testTransactionSetUp.Id != null, 'Test Transaction SetUp created assert');
        
        //create Itemization Setup
        fsCore__Itemization_Setup__c testItemizationSetUp = fsCore.TestHelperFinancial.getTestItemizationSetup('Test testItemization'
                                                                                                               ,'Financed Amount'
                                                                                                               ,testTransactionSetUp.Id);
        insert testItemizationSetUp;
        System.assert(testItemizationSetUp.Id != null, 'Test Itemization SetUp created assert');
        
        //create Product Itemization Setup
        fsCore__Product_Itemization_Setup__c  testProductItemizationSetUp = fsCore.TestHelperProduct.getTestProductItemizationSetup(testProduct.Id
                                                                                                                                    ,testItemizationSetUp
                                                                                                                                    ,'Yes'
                                                                                                                                    ,5
                                                                                                                                    ,'+');
        insert testProductItemizationSetUp;
        System.assert(testProductItemizationSetUp.Id != null, 'Test Product Itemization SetUp created assert');
        
        //create custom settings
        fsCore.SeedCustomSettings.createCustomSettings(new Set<String>{fsCore.Constants.CUSTOM_SETTING_CUSTOM_NUMBER_FORMAT});
        
        //create Pricing Setup
        fsCore__Pricing_Setup__c  testPricingSetup = fsCore.TestHelperProduct.getTestPricingSetup('Test Pricing Rule'
                                                                                                  , 'Interest Rate'
                                                                                                  , 10
                                                                                                  , 12
                                                                                                  , 2);
        testPricingSetup.fsCore__Start_Date__c = Date.today();
        testPricingSetup.fsCore__End_Date__c = Date.today().addMonths(2);
        insert testPricingSetup;
        System.assert(testPricingSetup.Id != null, 'Test Pricing Setup created assert');
        
        //create Rule Setup
        fsCore__Rule_Setup__c  testRuleSetup = fsCore.TestHelperProduct.getTestInvestmentRuleSetup('Test Rule','Origination');
        //testRuleSetup.fsCore__Rule_Type__c = 'Selection Rule';
        insert testRuleSetup;
        System.assert(testRuleSetup.Id != null, 'Test Rule Setup created assert');
        
        //create Account, Contact and Opportunity
        Account testAccount = TestHelperData.createAccount();
        Database.insert(testAccount);
        testAccount.Phone = '999-123-9900';
        update testAccount;
        System.assert(testAccount.Id != null, 'Test Account created assert');
        
        Opportunity testOpportunity = TestHelperData.createDNLOpportunity(testAccount.Id);
        Database.insert(testOpportunity);
        System.assert(testOpportunity.Id != null, 'Test Opportunity created assert');
        
        //create ContentDocumentLink
        ContentDocumentLink contentlink = TestHelperData.createContentDocumentLink(testOpportunity.Id);
        Database.insert(contentlink);
        System.assert(contentlink.Id != null, 'Test ContentDocumentLink created assert');
        
        //create SFS System Settings
        SFS_System_Settings__c sysSetting = TestHelperData.createSFSSystemSettings();
        sysSetting.Default_Branch_ID_DNL__c = testBranch.Id;
        sysSetting.Default_Product_ID_DNL__c = testProduct.Id;
        sysSetting.Default_Company_Code_DNL__c = testCompany.fsCore__Company_Code__c;
        sysSetting.Default_Company_ID_DNL__c = testCompany.Id;
        Database.upsert(sysSetting);
        System.assert(sysSetting.Id != null, 'Test SFS System Settings created assert');
    }

    @isTest
    static void testClosedReasonCOVIDCancelled(){
        Opportunity testOpportunity = [SELECT Id, name ,Closed_Lost_Reason__c , StageName FROM Opportunity LIMIT 1];
        System.debug(testOpportunity);
        Test.startTest();

        testOpportunity.StageName = 'Closed Lost';
        testOpportunity.Closed_Lost_Reason__c = 'COVID - Cancelled';
        update testOpportunity;

        Test.stopTest();
    }
     @isTest
    static void testCreateCoApplicantAccount(){
        Opportunity testOpportunity = [SELECT Id, name ,Applicant_s_Email__c FROM Opportunity LIMIT 1];
        System.debug(testOpportunity);
        Test.startTest();
		testOpportunity.Addnl_Months_with_Loan__c= 123;
        update testOpportunity;

        Test.stopTest();
    }
    
}