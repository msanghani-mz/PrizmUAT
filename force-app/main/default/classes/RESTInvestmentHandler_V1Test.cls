/*
* Class Name  : RESTInvestmentHandler_V1Test
* Description : This class has test method for RESTInvestmentHandler_V1
*/
@isTest
private class RESTInvestmentHandler_V1Test {
    
    @testSetup
    public static void createTestData(){
        TestHelperData.createTriggerExecutionTestData();
        fsCore.SeedCustomSettings.createCustomSettings(new Set<String>{fsCore.Constants.CUSTOM_SETTING_CUSTOM_NUMBER_FORMAT});
        //Account
        Account acc = new Account();
        acc.Name = 'John Smith';
        insert acc;
        //Contact
        Contact con = new Contact();
        con.AccountId = acc.id;
        con.FirstName = 'John';
        con.LastName = 'Smith';
        insert con;
        
        //Create Company and Branch
        fscore__Company_Setup__c testCompany = fsCore.TestHelperCompany.getTestCompanySetup('Test Company', 'TESTCO', '123456789');
        insert testCompany;
        System.assert(testCompany.Id != null, 'Test company created assert');  
        
        fsCore__Branch_Setup__c testBranch = fsCore.TestHelperCompany.getTestBranchSetup('Test Branch', 'TBRCH', testCompany.Id, null, null);
        insert testBranch;
        System.assert(testBranch.Id != null, 'Test branch created assert');
        
        //Branch data setup in UserBranchUtil
        Map<String, String> branchParams = new Map<String, String>();
        branchParams.put(fsCore.UserBranchUtil.BRANCH_KEY_NAME,testBranch.Name);
        branchParams.put(fsCore.UserBranchUtil.BRANCH_KEY_CODE,testBranch.fsCore__Branch_Code__c);
        fsCore.UserBranchUtil.setDefaultBranch(UserInfo.getUserId(),branchParams);
        
        //Create Product
        fsCore__Product_Setup__c testProduct = fsCore.TestHelperProduct.getTestProductSetup('Test Product'
                                                                                            , 'VCL'
                                                                                            , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                                            , fsCore.Constants.CYCLE_MONTHLY
                                                                                            , 1);
        testProduct.fsCore__Customer_Name_Format__c='Account Only';
        testProduct.fsCore__Customer_Type__c= 'Account';
        testProduct.Credit_Pull_Report_Record_Type_Name__c ='VCL';
        testProduct.fsCore__Active_Application_Record_Type__c = 'VCL_Loan';
        testProduct.fsServ__Active_Contract_Record_Type__c = 'VCL_Active_Contract';        
        
        insert testProduct;
        System.assert(testProduct.Id != null, 'Test product created assert');   
        
        //Create balance, transaction and itemization setup
        Map<String, fsCore__Balance_Setup__c> testBalanceSetupMap = fsCore.TestHelperFinancial.getTestBalanceSetupMap();
        System.assert(testBalanceSetupMap.size() > 0, 'Test Balance setup created assert');        
        
        Map<String, fsCore__Transaction_Setup__c> testTxnSetupMap = fsCore.TestHelperFinancial.getTestTransactionSetupMap();
        System.assert(testTxnSetupMap.size() > 0, 'Test Transaction setup created assert');        
        
        Map<String, fsCore__Itemization_Setup__c> testItmzSetupMap = fsCore.TestHelperFinancial.getTestItemizationSetupMap();
        System.assert(testItmzSetupMap.size() > 0, 'Test Itemization setup created assert');    
        
        //Create Product Itemization
        List<fsCore__Product_Itemization_Setup__c> testProductItzms = new List<fsCore__Product_Itemization_Setup__c>();
        testProductItzms.add(fsCore.TestHelperProduct.getTestProductItemizationSetup(testProduct.Id
                                                                                     , testItmzSetupMap.get('Funds to Customer')
                                                                                     , 'Yes'
                                                                                     , 1, fsCore.Constants.PLUS));
        testProductItzms.add(fsCore.TestHelperProduct.getTestProductItemizationSetup(testProduct.Id
                                                                                     , testItmzSetupMap.get('Down Payment')
                                                                                     , 'No'
                                                                                     , 2, fsCore.Constants.MINUS));
        fsCore__Product_Itemization_Setup__c testFeeItzm = fsCore.TestHelperProduct.getTestProductItemizationSetup(testProduct.Id
                                                                                                                   , testItmzSetupMap.get('Application Fee')
                                                                                                                   , 'No'
                                                                                                                   , 3, fsCore.Constants.PLUS);
        
        testFeeItzm.fsCore__Fee_Category__c = fsCore.Constants.FEE_CATEG_APPLICATION;
        testProductItzms.add(testFeeItzm);
        System.Debug(loggingLevel.ERROR, 'testProductItzms'+testProductItzms);
        insert testProductItzms;
        System.assert(testProductItzms.size() > 0, 'Test product itemizations created assert'); 
        
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
        
        
        //Create Lending Application
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                                            , testBranch
                                                                                                                            , testProduct
                                                                                                                            , testContractTemplate
                                                                                                                            , 'Test Application');
        testApplication.fsCore__Primary_Customer_Account__c = acc.id;
        testApplication.fsCore__Primary_Customer_Contact__c = con.id;
        insert testApplication;
        System.assert(testApplication.Id != null, 'Test Lending Application created assert'); 
    } 
    @isTest
    private static void testServiceHandlerPostMethod(){
         fsCore__Lending_Application__c testApplication =[SELECT Id, Withdraw_Reason__c
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/investments';
        req.httpMethod = 'POST'; 
        RestResponse res = new RestResponse();      
        String jsonStr = '{"application_id" : "a1kL0000001eZseIAE","contribution_amount" : null,"contribution_percent" : 100,"investor_account_id" : "001L000001Ci0lE","investor_contact_id" : null}';
         Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
        jsonMap.Remove('application_id');
        jsonMap.put('application_id', appId);
        System.debug(loggingLevel.ERROR,'jsonMap'+jsonMap);
        jsonStr=JSON.serialize(jsonMap);
        req.requestBody = blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doPost();       
        Test.stopTest(); 
    } 
        
    @isTest
     private static void testServiceHandlerPost_Error(){
         fsCore__Lending_Application__c testApplication =[SELECT Id, Withdraw_Reason__c
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/investments';
        req.httpMethod = 'POST'; 
        RestResponse res = new RestResponse();      
        String jsonStr = '{"application" : "a1kL0000001eZseIAE","contribution_percent" : 100,"investor_account_id" : "001L000001Ci0lE","investor_contact_id" : null}';
      
        req.requestBody = blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doPost();       
        Test.stopTest(); 
    } 
    
    @isTest
    private static void testServiceHandlerDeleteMethod(){
         //Account
        Account acc = new Account();
        acc.Name = 'Sam Smith';
        acc.fsCore__Is_Investor__c =true;
        insert acc;
        
        fsCore__Lending_Application__c testApp = [select id ,fsCore__Primary_Customer_Account__c, Name,fsCore__Primary_Customer_Contact__c from fsCore__Lending_Application__c];
        fsCore__Lending_Application_Investment__c appInvestment = new fsCore__Lending_Application_Investment__c();
        appInvestment.fsCore__Lending_Application_Number__c = testApp.id;
      //  appInvestment.fsCore__Contact_Name__c =testApp.fsCore__Primary_Customer_Contact__c;
        // appInvestment.fsCore__Contribution_Percent__c = '10';
        // appInvestment.fsCore__Service_Rate__c = '10';
        appInvestment.fsCore__Fixed_Or_Margin_Rate__c = 2.00;
        appInvestment.fsCore__Contribution_Amount__c = 100;
        appInvestment.fsCore__Account_Name__c = acc.id;
        appInvestment.fsCore__Minimum_Rate__c = 1;
        appInvestment.fsCore__Is_Payout_On_Month_End__c = true;
        //appInvestment.fsCore__Payout_Cycle__c = 'Monthly';
        appInvestment.fsCore__Investment_Payout_Cycle__c = 'Monthly';
        appInvestment.fsCore__Payout_Threshold_Amount__c = 100;
        appInvestment.fsCore__Preference_Code__c = 'Dummy';
        appInvestment.fsCore__Rate__c = 2;
        appInvestment.fsCore__Rate_Of_Return_Method__c ='Fixed Rate'; 
        appInvestment.fsCore__Status__c ='Pending';
        insert appInvestment;   
        appInvestment = [select Id,Name,fsCore__Account_Name__c,fsCore__Account_Name_Formula__c,fsCore__Contact_Name__c,fsCore__Contact_Name_Formula__c,fsCore__Contribution_Amount__c,fsCore__Rate__c,fsCore__Status__c from fsCore__Lending_Application_Investment__c Limit 1];
        id investmentId = appInvestment.id;
       
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/investments/'+(String)investmentId;
        req.httpMethod = ' DELETE'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
       // RESTInvestment investment = new RESTInvestment();
        RESTInvestment.Response resp = new RESTInvestment.Response(appInvestment);
        RESTRouter.doDelete();       
        Test.stopTest(); 
    } 
}