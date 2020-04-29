@isTest
public class RESTPricingOfferHandler_V1Test{
    
    @testSetup
    static void createTestData(){
        
        TestHelperData.createTriggerExecutionTestData();
        
        //create custom settings
        fsCore.SeedCustomSettings.createCustomSettings(new Set<String>{fsCore.Constants.CUSTOM_SETTING_CUSTOM_NUMBER_FORMAT
            , fsCore.Constants.CUSTOM_SETTING_CALCULATOR_PREFERENCE});
        
        
        //Create Company and Branch
        fscore__Company_Setup__c testCompany = fsCore.TestHelperCompany.getTestCompanySetup('Test Company', 'TESTCO', '123456789');
        insert testCompany;
        System.assert(testCompany.Id != null, 'Test company created assert');  
        
        fsCore__Branch_Setup__c testBranch = fsCore.TestHelperCompany.getTestBranchSetup('Test Branch', 'TBRCH', testCompany.Id, null, null);
        insert testBranch;
        System.assert(testBranch.Id != null, 'Test branch created assert');
        
        
        //Create Product
        fsCore__Product_Setup__c testProduct = fsCore.TestHelperProduct.getTestProductSetup('Test Product'
                                                                                            , 'VCL'
                                                                                            , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                                            , fsCore.Constants.CYCLE_MONTHLY
                                                                                            , 1);
        testProduct.Credit_Pull_Report_Record_Type_Name__c ='VCL';
        testProduct.fsCore__Active_Application_Record_Type__c = 'VCL_Loan';
        
        insert testProduct;
        System.assert(testProduct.Id != null, 'Test product created assert');   
        
        //create Payment Allocation Method
        fsCore__Payment_Allocation_Method_Setup__c testPaymentAlloc = fsCore.TestHelperFinancial.getTestPaymentAllocMethod('Test Payment Allocation');
        insert testPaymentAlloc;
        System.assert(testPaymentAlloc.Id != null, 'Test payment allocation created assert');
        
        //Contract Template 
        fsCore__Contract_Template_Setup__c testContractTemplate = fsCore.TestHelperProduct.getTestContractTemplateSetup
            ('Test Contract Template'
             , fsCore.Constants.PRODUCT_FAMILY_LOAN
             , testPaymentAlloc.Id
             , 1);
        insert testContractTemplate; 
        System.assert(testContractTemplate.Id != null, 'Test contract template created assert');  
        
        //create Account
        List<Account> accountlist = new List<Account>();
        
        Account nAccount = TestHelperData.createAccount();
        Account coAppAccount = TestHelperData.createAccount('TEST','LASTNAME');
        accountlist.add(nAccount);
        accountlist.add(coAppAccount);
        Database.insert(accountlist);
        
        System.assert(nAccount.Id != null, 'Test Account created assert');
        
        List<Account> testAccountList = [select id, personcontactId from Account where id in (:nAccount.id,:coAppAccount.Id) ];
        
        Account testAccount = testAccountList[0];
        Account testCoAccount = testAccountList[1];
        system.debug(logginglevel.error,'testAccount.personcontactId :'+testAccount.personcontactId);
        
        
        //create pricing setup
        
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
        
        
        //Create Lending Application
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                                            , testBranch
                                                                                                                            , testProduct
                                                                                                                            , testContractTemplate
                                                                                                                            , 'Test Application');
        testApplication.fsCore__Pricing_Name__c = testPricing.Id ;
        insert testApplication;
        System.assert(testApplication.Id != null, 'Test Lending Application created assert'); 
        
        //create Lending Application Customer Secondary
        fsCore__Lending_Application_Customer__c  testAppCustomer1 = fsCore.TestHelperLendingApplication.getTestCustomer(testApplication
                                                                                                                        ,testAccount.Id
                                                                                                                        ,testAccount.PersonContactId
                                                                                                                        ,'Primary');
        
        insert testAppCustomer1;
        System.assert(testAppCustomer1.Id != null, 'Test Lending Application Customer1 created assert');
        
        fsCore__Lending_Application_Customer__c  testAppCustomer2 = fsCore.TestHelperLendingApplication.getTestCustomer(testApplication                                                                                                                        ,testCoAccount.Id
                                                                                                                        ,testCoAccount.PersonContactId
                                                                                                                        ,'Secondary');
        insert testAppCustomer2;
        System.assert(testAppCustomer2.Id != null, 'Test Lending Application Customer2 created assert');
    }
    @isTest
    public static void test(){
        fsCore__Lending_Application__c app = [Select id from fsCore__Lending_Application__c];
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/offers';
        req.httpMethod = 'POST'; 
        RestResponse res = new RestResponse();      
        String jsonStr = '{  "application_id":"'+app.id+'",  "start_date":"2019-06-04", "payment_start_date":"2019-06-04",  "number_of_payments":10,  "Approved_amount":14000,  "rate":4,"origination_fee":100,  "include_origination_fee":true,"origination_fee_in_percent":false, "grade":"A", "pull_type":"EQF", "auto_accept_Offer":false,  "model_payment_amount": 646.58,   "model_annual_percent_rate": 20.00,  "model_soft_pull_score": 500,  "model_hard_pull_score": 600,  "model_hard_decline_reason": "TESTING", "hard_pull_pricing_offer":false }';     
        req.requestBody = blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doPost();       
        Test.stopTest(); 
        
    }
    @isTest
    public static void test2(){
        
        fsCore__Lending_Application__c app = [Select id from fsCore__Lending_Application__c];
        fsCore__Pricing_Setup__c testPricing = [Select id,fsCore__Rate_Value__c from fsCore__Pricing_Setup__c];
        //Application Pricing Offer
        fsCore__Lending_Application_Pricing_Offer__c testAppPricingoffer = new fsCore__Lending_Application_Pricing_Offer__c();
        // appPricingoffer.fsCore__Is_Accepted__c = true;
        testAppPricingoffer.fsCore__Pricing_Name__c = testPricing.Id;
        testAppPricingoffer.fsCore__Lending_Application_Number__c = app.Id;
        testAppPricingoffer.fsCore__Payment_Cycle_Pricing__c = 'Monthly';
        testAppPricingoffer.fsCore__Pricing_Method__c = 'Interest Rate';
        testAppPricingoffer.fsCore__Start_Date__c = Date.today();
        testAppPricingoffer.fsCore__Factor_Rate__c = testPricing.fsCore__Rate_Value__c;
        testAppPricingoffer.fsCore__Payment_Amount__c = 2000;
        testAppPricingoffer.fsCore__Financed_Amount__c = 10000;
        testAppPricingoffer.fsCore__Number_Of_Payments__c = 5;
        testAppPricingoffer.fsCore__Pricing_Date__c = system.today().addDays(10);
        testAppPricingoffer.fsCore__Rate__c = 10;
        insert testAppPricingoffer;
        
        fsCore__Lending_Application_Pricing_Offer__c pricingOffer = [Select id from fsCore__Lending_Application_Pricing_Offer__c];
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/offers/'+pricingOffer.id+'/accept';
        req.httpMethod = 'PUT'; 
        RestResponse res = new RestResponse();    
        String jsonStr = '{"offer_id" : "'+pricingOffer.id+'"}';
        req.requestBody = blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doPut();       
        Test.stopTest(); 
        
        RESTPricingOffer.Request  restReq = new RESTPricingOffer.Request();
        restReq.grade = 'grade';
        restReq.pull_type = 'pull';
        restReq.model_annual_percent_rate = 100;
        restReq.model_hard_pull_score = 90;
        restReq.model_soft_pull_score = 90;
        restReq.model_hard_decline_reason = 'reason';
        
        RESTPricingOffer.Response offerResponse = new RESTPricingOffer.Response();
        
        offerResponse.loan_amount = 100;
        offerResponse.financed_amount = 20;
        offerResponse.rate = 10;
        offerResponse.number_of_payments = 5;
        offerResponse.payment_cycle = 'Monthly';
        offerResponse.payment_amount = 78;    
        offerResponse.final_payment_amount = 17;    
        offerResponse.annual_percent_rate = 12;                
        offerResponse.mismatch_in_payment_amount = false;
    }
     @isTest
    public static void test3(){
        fsCore__Lending_Application__c app = [Select id from fsCore__Lending_Application__c];
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/offers';
        req.httpMethod = 'POST'; 
        RestResponse res = new RestResponse();      
        String jsonStr = '{  "application_id":"'+app.id+'",  "start_date":"2019-06-04", "payment_start_date":"2019-06-04",  "number_of_payments":10,  "Approved_amount":14000,  "rate":4,"origination_fee":100,  "include_origination_fee":,"origination_fee_in_percent":, "grade":"A", "pull_type":"EQF", "auto_accept_Offer":false,  "model_payment_amount": ,   "model_annual_percent_rate": 20.00,  "model_soft_pull_score": 500,  "model_hard_pull_score": 600,  "model_hard_decline_reason": "TESTING", "hard_pull_pricing_offer": }';     
        req.requestBody = blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doPost();       
        Test.stopTest();       
    }
    
    
}