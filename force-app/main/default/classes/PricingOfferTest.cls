/*
 * FinancialSpectra Pty Ltd
 * 
 * Class Name   - PricingOfferTest
 *
 * Description  - Test class for PricingOfferGenerator
 *
 *
 */
@isTest(seeAllData=false)
private class PricingOfferTest{

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
        
        insert testApplication;
        System.assert(testApplication.Id != null, 'Test Lending Application created assert');        

        //
        //create lending application pricing
        //
        fsCore__Lending_Application_Pricing_Offer__c testOffer = fsCore.TestHelperLendingApplication.getTestPricingOffer(testApplication, testPricing, 10000);
        insert testOffer;
        System.assert(testOffer.Id != null, 'Test Lending Application Pricing Offer created assert');        
    }
    
    private static fsCore__Lending_Application_Pricing_Offer__c getTestPricingOffer(Id pApplicationId){
        return [SELECT Id, fsCore__Is_Accepted__c
                  FROM fsCore__Lending_Application_Pricing_Offer__c
                 WHERE fsCore__Lending_Application_Number__c = :pApplicationId
                 LIMIT 1];
    }
    
    @isTest
    private static void testPricingOfferGenerator(){
        Account testAccount = fsCore.TestHelperData.getAccount('Stark Corporation');
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperData.getApplicationByAccount(testAccount.Id);
        fsCore__Pricing_Setup__c testPricing = fsCore.TestHelperData.getPricingsMap().get('Test Pricing');
                
        fsCore__Pricing_Rate_Preference_Setup__c pricingRatePref = new fsCore__Pricing_Rate_Preference_Setup__c();
        pricingRatePref.fsCore__Pricing_Name__c = testPricing.Id;
        pricingRatePref.fsCore__Rate__c = 3.5;
        pricingRatePref.fsCore__Term__c = 3;
        pricingRatePref.fsCore__Term_Units__c = 'Months';
        insert pricingRatePref;
        System.assert(pricingRatePref.Id != null, 'Pricing Rate Preference created');
        
        fsCore__Pricing_Predefined_Payment_Setup__c pricingPredefPmt = new fsCore__Pricing_Predefined_Payment_Setup__c();
        pricingPredefPmt.fsCore__Pricing_Name__c = testPricing.Id;
        pricingPredefPmt.fsCore__Start_Payment_Number__c = 1;
        pricingPredefPmt.fsCore__Number_Of_Payments__c = 2;
        pricingPredefPmt.fsCore__Payment_Amount__c = 500;
        insert pricingPredefPmt;
        System.assert(pricingPredefPmt.Id != null, 'Pricing Predefined Payment created');

        testPricing = fsCore.TestHelperData.getPricingsMap().get('Test Pricing');
        
        Test.startTest();
        fsCore.PricingOfferGenerator poGen = new fsCore.PricingOfferGenerator(testApplication, testPricing);
        poGen.setDefaultInputParameters();
        
        fsCore.PricingOfferInputObject poInputObj = new fsCore.PricingOfferInputObject();
        poInputObj.setBranchCode(testApplication.fsCore__Branch_Code_Formula__c);
        poInputObj.financedAmount = 10000;
        poInputObj.rate = 4;
        poInputObj.numberOfPayments = 12;
        poInputObj.paymentCycle = fsCore.Constants.CYCLE_MONTHLY;
        poInputObj.paymentAmount = 878.00;
        poInputObj.contractStartDate = poInputObj.getBusinessDate().addDays(1);
        poInputObj.firstPaymentDate = poInputObj.getBusinessDate().addMonths(1);
        
        poGen.setInputParameters(poInputObj);
        poGen.generateOffer();

        System.assertEquals(true, poGen.getCalculatorObject().getIsSuccess());
        poGen.saveOffer();
        System.assert(poGen.getPricingOffer().Id != null);
        poGen.acceptOffer();
        poGen.calculateAPR();
        
        Test.stopTest();
    }
 }