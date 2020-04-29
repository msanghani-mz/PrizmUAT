/*
 * Class Name   - PreTILANOIEmailJobTest
 * Description  - Test class for PreTILANOIEmailJob
 */
@isTest
private class PreTILANOIEmailJobTest{
    
    @testSetup
    static void createTestData(){
        
        TestHelperData.createTriggerExecutionTestData();

        //create custom settings
        fsCore.SeedCustomSettings.createCustomSettings(new Set<String>{fsCore.Constants.CUSTOM_SETTING_CUSTOM_NUMBER_FORMAT
                                                              , fsCore.Constants.CUSTOM_SETTING_CALCULATOR_PREFERENCE});
        
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
        testProduct.Credit_Pull_Report_Record_Type_Name__c='DNL';
        testProduct.fsCore__Active_Application_Record_Type__c = 'DNL_Loan';
        testProduct.fsServ__Active_Contract_Record_Type__c = 'DNL_Active_Contract';        

        insert testProduct;
        System.assert(testProduct.Id != null, 'Test product created assert');        

        //
        //create contract template (required for PricingOfferAcceptAction)
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

        //
        //create pricing setup
        //
        fsCore__Pricing_Setup__c testPricing = fsCore.TestHelperProduct.getTestPricingSetup('Test Pricing'
                                                                            , fsCore.Constants.PRICING_METHOD_INTEREST_RATE
                                                                            , 4.00
                                                                            , 12
                                                                            , 1);
        testPricing.Is_Generate_Additional_Pricing__c = true;
        testPricing.Payment_Increase_For_Option_1__c = 10;
        testPricing.Payment_Increase_For_Option_2__c = 20;
        insert testPricing;
        System.assert(testPricing.Id != null, 'Test pricing created assert');        

        //Account and Contact for customer
        Account testAccount = fsCore.TestHelperSystem.getTestAccount('Stark Corporation');
        insert testAccount;
        System.assert(testAccount.Id != null, 'Test Account created assert');

        Contact testContact = fsCore.TestHelperSystem.getTestContact('Tony', 'Stark', testAccount.Id);
        insert testContact;
        System.assert(testContact.Id != null, 'Test Contact created assert');

        //
        //create Lending Application by populating company, branch, product
        //
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplication(testCompany
                                                                              , testBranch
                                                                              , testProduct
                                                                              , 'Test Application');
        testApplication.fsCore__Primary_Customer_Account__c = testAccount.Id;
        testApplication.fsCore__Primary_Customer_Contact__c = testContact.Id;

        testApplication.Pre_TILA_Sent_Date__c = Date.Today().addDays(-10);
        testApplication.Is_PreTILA_Signed__c = false;
        testApplication.Pre_TILA_Sign_Due_Date__c = Date.Today().addDays(-2);
        
        insert testApplication;
        System.assert(testApplication.Id != null, 'Test Lending Application created assert');        

        //
        //create lending application pricing
        //
        fsCore__Lending_Application_Pricing_Offer__c testOffer = fsCore.TestHelperLendingApplication.getTestPricingOffer(testApplication, testPricing, 10000);
        insert testOffer;
        System.assert(testOffer.Id != null, 'Test Lending Application Pricing Offer created assert');        
    }
    
    @isTest
    private static void testJobExecution(){
        Test.startTest();
        PreTILANOIEmailJob testJob = new PreTILANOIEmailJob();
        String jobType = testJob.getBatchJobType();
        
        System.assertEquals(fsCOre.BatchJobUtil.JOB_TYPE_QUERYABLE, jobType, 'Batch job type assert');
        Id testJobId = Database.executeBatch(testJob);
        Test.stopTest();

        
        System.assertNotEquals(null, testJobId, 'Submitted job id assert'); 
    }
    
    @isTest
    private static void testJobScheduling(){
        String CRON_EXP = '0 0 2 * * ?'; //All Months, All Days at 2AM
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('PreTILANOIEmailJobTest',
                                       CRON_EXP, 
                                       new PreTILANOIEmailJob());
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        System.assertEquals(CRON_EXP, ct.CronExpression, 'Cron Experssion assert');
        System.assertEquals(0, ct.TimesTriggered, 'Times Triggered assert');
        
        Test.stopTest();
    }
       
}