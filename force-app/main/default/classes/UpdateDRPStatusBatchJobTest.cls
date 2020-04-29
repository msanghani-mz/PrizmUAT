/**
 * Class Name  : UpdateDRPStatusBatchJobTest
 * Description : This class has test method for UpdateDRPStatusBatchJob
 * Author      : Financial Spectra
 *
 */
@isTest
private class UpdateDRPStatusBatchJobTest {
    
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
        System.assert(testAccount.Id != null, 'Test Account created assert');
        
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
        testOpportunity.Import_Id__c = testApp.Id;//'0060S000006DRFFds2';
        testOpportunity.Import_Program_Id__c = testApp.Id;
        Database.insert(testOpportunity);
        System.assert(testOpportunity.Id != null, 'Test Opportunity created assert');

        testApp.Opp_Import_Id__c = testOpportunity.Id;
        Database.update(testApp);
        
    }
    
    /**
    * 
    */
    private static testMethod void scheduleClass(){
    
        String sch = '0 0 0 3 9 ? 2022';
        ScheduleUpdateDRPStatusBatchJob sh1 = new ScheduleUpdateDRPStatusBatchJob();
        String jobId =system.schedule('Test', sch, sh1);
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new UpdateDRPStatusBatchJobTest.UpdateDRPStatusMockResponse());
        CronTrigger cornvar = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId LIMIT :(Limits.getLimitQueryRows()-Limits.getQueryRows())]; 
        Test.stopTest(); 
        system.assertEquals(0, cornvar.TimesTriggered); 
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(cornvar.NextFireTime));
        
    }
    

    public without sharing class UpdateDRPStatusMockResponse implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            Opportunity testOpportunity = [SELECT Id, name
                                       FROM Opportunity
                                       LIMIT 1];
            fsCore__Lending_Application__c testApplication = [SELECT id, name 
                                                                FROM fsCore__Lending_Application__c
                                                                LIMIT 1];                           
            HttpResponse res = new HttpResponse();
            try{    

                res.setHeader('Content-Type', 'application/json');
                //res.setBody('[{"ProgramId":"12","ProgramStatus":"Error"},{"ProgramId":"21","ProgramStatus":"Error"}]');
                res.setBody('[{"ProgramId":"'+testOpportunity.Id+'","ProgramStatus":"Error"},{"ProgramId":"'+testApplication.Id+'","ProgramStatus":"Error"}]');
                res.setStatusCode(200);
                return res;
            }catch(Exception e){
                system.debug(e.getMessage()+e.getLineNumber());            
            }
            return res;
        }
    }
}