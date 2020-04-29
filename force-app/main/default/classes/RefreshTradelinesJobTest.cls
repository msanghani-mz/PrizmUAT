/*
 * Class Name   - RefreshTradelinesJobTest
 * Description  - Test class for RefreshTradelinesJob
 */
@isTest
private class RefreshTradelinesJobTest{
    
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
        testProduct.fsCore__Active_Application_Record_Type__c = 'DNL_Loan';
        testProduct.fsServ__Active_Contract_Record_Type__c = 'DNL_Active_Contract';        

        insert testProduct;
        System.assert(testProduct.Id != null, 'Test product created assert');

        SFS_System_Settings__c sysSetting = TestHelperData.createSFSSystemSettings();
        sysSetting.Default_Branch_ID_DNL__c = testBranch.Id;
        sysSetting.Default_Product_ID_DNL__c = testProduct.Id;
        sysSetting.Default_Company_Code_DNL__c = testCompany.fsCore__Company_Code__c;
        sysSetting.Default_Company_ID_DNL__c = testCompany.Id;
        sysSetting.DNL_Funds_To_Creditor_Itm__c = 'FUNDS_TO_CREDITOR';
        sysSetting.DNL_Cash_In_Dedicated_Itm__c = 'DEDICATED_AMOUNT_CASH';
        sysSetting.DNL_One_Mth_Payment_Itm__c = 'DRP_PAYMENT_ONE_MTH';
        sysSetting.DNL_Rem_Fee_Due_DRP_Itm__c = 'REM_FEE_DUE_DRP';  
        Database.upsert(sysSetting);
        System.assert(sysSetting.Id != null, 'Test SFS System Settings created assert');        
        
        //
        //create balance, transaction and itemization setup
        //
        Map<String, fsCore__Balance_Setup__c> testBalanceSetupMap = fsCore.TestHelperFinancial.getTestBalanceSetupMap();
        System.assert(testBalanceSetupMap.size() > 0, 'Test Balance setup created assert');        

        Map<String, fsCore__Transaction_Setup__c> testTxnSetupMap = fsCore.TestHelperFinancial.getTestTransactionSetupMap();
        System.assert(testTxnSetupMap.size() > 0, 'Test Transaction setup created assert');       

        Map<String, fsCore__Itemization_Setup__c> testItmzSetupMap = fsCore.TestHelperFinancial.getTestItemizationSetupMap();

        System.assert(testItmzSetupMap.size() > 0, 'Test Itemization setup created assert');    
        
        String dnlFundsToCreditorItmzCode = SFS_System_Settings__c.getInstance().DNL_Funds_To_Creditor_Itm__c;
        String dedicatedAmountCash = SFS_System_Settings__c.getInstance().DNL_Cash_In_Dedicated_Itm__c;

        //create Itemization Setup
        List<fsCore__Itemization_Setup__c> ItemizationSetUpList = new List<fsCore__Itemization_Setup__c>();

        fsCore__Itemization_Setup__c testItemizationSetUp = fsCore.TestHelperFinancial.getTestItemizationSetup(dnlFundsToCreditorItmzCode
                                                                                                               ,'Financed Amount'
                                                                                                               ,testTxnSetupMap.get('Funding Cash Advance Transaction').Id);

        fsCore__Itemization_Setup__c testItemizationSetUp1 = fsCore.TestHelperFinancial.getTestItemizationSetup(dedicatedAmountCash
                                                                                                               ,'Financed Amount'
                                                                                                               ,testTxnSetupMap.get('Funding Down Payment Transaction').Id);
        

        testItemizationSetUp.fsCore__Itemization_Code__c =dnlFundsToCreditorItmzCode;
        testItemizationSetUp.name =dnlFundsToCreditorItmzCode;

        testItemizationSetUp1.fsCore__Itemization_Code__c =dedicatedAmountCash;
        testItemizationSetUp1.name =dedicatedAmountCash;

        ItemizationSetUpList.add(testItemizationSetUp);
        ItemizationSetUpList.add(testItemizationSetUp1);

        insert ItemizationSetUpList;   
        /*system.debug(logginglevel.error,testItemizationSetUp);
        system.debug(logginglevel.error,testItemizationSetUp1);
        insert testItemizationSetUp;
        insert testItemizationSetUp1;*/


        testItmzSetupMap.put(testItemizationSetUp.name,testItemizationSetUp);
        testItmzSetupMap.put(testItemizationSetUp1.name,testItemizationSetUp1);

             


        List<fsCore__Product_Itemization_Setup__c> testProductItzms = new List<fsCore__Product_Itemization_Setup__c>();
        testProductItzms.add(fsCore.TestHelperProduct.getTestProductItemizationSetup(testProduct.Id
                                                                            , testItmzSetupMap.get('Funds to Customer')
                                                                            , 'Yes'
                                                                            , 1, fsCore.Constants.PLUS));

        
        testProductItzms.add(fsCore.TestHelperProduct.getTestProductItemizationSetup(testProduct.Id
                                                                            , testItmzSetupMap.get(dnlFundsToCreditorItmzCode)
                                                                            , 'Yes'
                                                                            , 2, fsCore.Constants.PLUS));


        testProductItzms.add(fsCore.TestHelperProduct.getTestProductItemizationSetup(testProduct.Id
                                                                            , testItmzSetupMap.get('Down Payment')
                                                                            , 'No'
                                                                            , 3, fsCore.Constants.MINUS));

        testProductItzms.add(fsCore.TestHelperProduct.getTestProductItemizationSetup(testProduct.Id
                                                                            , testItmzSetupMap.get(dedicatedAmountCash)
                                                                            , 'Yes'
                                                                            , 4, fsCore.Constants.MINUS));

        insert testProductItzms;
        System.assert(testProductItzms.size() > 0, 'Test product itemizations created assert');         
        
        
        //create custom settings
        fsCore.SeedCustomSettings.createCustomSettings(new Set<String>{fsCore.Constants.CUSTOM_SETTING_CUSTOM_NUMBER_FORMAT});



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

        testApplication.Opp_Import_Id__c = String.valueOf(fsCore.SpectraCoreUtil.getRandomInteger());
        testApplication.fsCore__Is_Funded__c = false;
        testApplication.fsCore__Is_Voided__c = false;
        testApplication.fsCore__Is_Application_Read_Only__c = false;
        testApplication.Opp_Import_Id__c = '00622000002tyGBAAY';
        
        insert testApplication;
        System.assert(testApplication.Id != null, 'Test Lending Application created assert');        

        //
        //create Lending Application itemizations
        //
        List<fsCore__Lending_Application_Itemization__c> testAppItemizations = fsCore.TestHelperLendingApplication.getTestApplicationItemizations(
                                                                                                      testApplication
                                                                                                    , testProductItzms);
        for(fsCore__Lending_Application_Itemization__c itm: testAppItemizations){
            itm.Tradeline_Import_Id__c = testApplication.id; //Just the Dummy ID to pass the test

        }
        insert testAppItemizations;
        System.assert(testAppItemizations.size() > 0, 'Test Lending Application itemizations created assert');        


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
        RefreshTradelinesJob testJob = new RefreshTradelinesJob();

        Id testJobId = Database.executeBatch(testJob);
        Test.stopTest();

        
        System.assertNotEquals(null, testJobId, 'Submitted job id assert'); 
    }
    
    @isTest
    private static void testJobScheduling(){
        String CRON_EXP = '0 0 2 * * ?'; //All Months, All Days at 2AM
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('RefreshTradelinesJobTest',
                                       CRON_EXP, 
                                       new RefreshTradelinesJob());
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        System.assertEquals(CRON_EXP, ct.CronExpression, 'Cron Experssion assert');
        System.assertEquals(0, ct.TimesTriggered, 'Times Triggered assert');
        
        Test.stopTest();
    }
       
}