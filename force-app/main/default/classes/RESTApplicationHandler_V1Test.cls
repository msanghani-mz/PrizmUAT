/*
* Class Name  : RESTApplicationHandler_V1Test
* Description : This class has test method for RESTApplicationHandler_V1
* Author - Aniket Singh
*/
@isTest
private class RESTApplicationHandler_V1Test{
    
    static void createLendingContracts(Boolean pActiveContracts, Boolean pWithRelatedData){
        TestCustomDataLoader.loadAccounts();
        TestCustomDataLoader.loadContacts();
        
        if (pActiveContracts){
            TestCustomDataLoader.loadLendingContractsActive();
            TestCustomDataLoader.loadContractBalancesActive();
            TestCustomDataLoader.loadContractDues();
            TestCustomDataLoader.loadContractRepayments();
            TestCustomDataLoader.loadContractRepaySchedules();
        } else {
            TestCustomDataLoader.loadLendingContractsPending();
            TestCustomDataLoader.loadContractBalancesPending();
        }
        
        if (pWithRelatedData){
            TestCustomDataLoader.loadBankAccounts();
            TestCustomDataLoader.loadContractCustomers();
            TestCustomDataLoader.loadContractItemizations();
            TestCustomDataLoader.loadContractFees();
            TestCustomDataLoader.loadContractDirectDebits();
            TestCustomDataLoader.loadContractDisbursements();
        }
        
        System.assertEquals(8, [SELECT count() FROM fsServ__Lending_Contract__c]);
    }
    @testSetup
    public static void createTestData(){
        TestHelperData.createTriggerExecutionTestData();
        TestHelperData.createNuPayDataMappingTestData();
        fsServ.TestHelperGlobal.createSetupData();
        createLendingContracts(true, true);
        
        
        fsCore__Branch_Setup__c testBranch = fsServ.TestQueryHelper.getTestBranches().get('TCHQ');
        
        fsCore__User_Preferences__c userPreferences = new fsCore__User_Preferences__c();
        userPreferences.fsCore__Default_Branch_Code__c = testBranch.fsCore__Branch_Code__c;
        userPreferences.fsCore__Default_Branch_Name__c = testBranch.Name;
        userPreferences.SetupOwnerId = UserInfo.getUserId();
        insert userPreferences;
        
        testBranch.fsCore__Business_Date__c = testBranch.fsCore__Business_Date__c.addDays(30);
        update testBranch;
        fsCore__Company_Setup__c testCompany = [SELECT Id, fsCore__Company_Logo_File_Id__c , fsCore__Company_Code__c FROM fsCore__Company_Setup__c WHERE Id = :testBranch.fsCore__Company_Name__c];
        //update testCompany;
        System.assert(testBranch.Id != null, 'Test branch created assert'); 
        
        //Create Product
        fsCore__Product_Setup__c testProduct2 = fsCore.TestHelperProduct.getTestProductSetup('Test Product'
                                                                                             , 'VCL'
                                                                                             , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                                             , fsCore.Constants.CYCLE_MONTHLY
                                                                                             , 1);
        testProduct2.Credit_Pull_Report_Record_Type_Name__c ='VCL';
        testProduct2.fsCore__Customer_Type__c = 'Person Account'; 
        testProduct2.fsCore__Active_Application_Record_Type__c = 'VCL_Loan';
        
        insert testProduct2;
        System.assert(testProduct2.Id != null, 'Test product2 created assert');
        
        
        //create product
        fsCore__Product_Setup__c testProduct = [select id, name
                                                ,fsCore__Customer_Type__c
                                                ,fsCore__Is_Funding_In_Tranches_Allowed__c
                                                ,fsCore__Is_Billing_Cycle_Flexible__c
                                                ,fsCore__Billing_Cycle__c
                                                ,Credit_Pull_Report_Record_Type_Name__c 
                                                ,fsCore__Is_Secured__c
                                                ,fsCore__Collateral_Family__c
                                                , fsCore__Collateral_Sub_Family__c
                                                , fsCore__Is_Syndication_Allowed__c
                                                , fsCore__Product_Family__c
                                                from fsCore__Product_Setup__c limit 1]; 
        
        
        System.assert(testCompany.Id != null, 'Test company created assert');
        testProduct.fsCore__PRODUCT_code__c = 'DNL'; 
        testProduct.fsCore__Customer_Type__c = 'Person Account';
        testProduct.Credit_Pull_Report_Record_Type_Name__c = 'DNL'; //VCL-111
        Database.upsert(testProduct);
        System.assert(testProduct.Id != null, 'Test product created assert');
        
        //create payment allocation
        fsCore__Payment_Allocation_Method_Setup__c testPaymentAlloc  = [Select id from fsCore__Payment_Allocation_Method_Setup__c limit 1];
        
        
        //create Contract Template
        fsCore__Contract_Template_Setup__c testContractTemplate = fsCore.TestHelperProduct.getTestContractTemplateSetup
            ('Test Contract Template'
             , fsCore.Constants.PRODUCT_FAMILY_LOAN
             , testPaymentAlloc.Id
             , 1);
        Database.upsert(testContractTemplate);    
        System.assert(testContractTemplate.Id != null, 'Test contract template created assert');        
        
        //create SFS System Settings
        SFS_System_Settings__c sysSetting = TestHelperData.createSFSSystemSettings();
        sysSetting.Default_Branch_ID_DNL__c = testBranch.Id;
        sysSetting.Default_Product_ID_DNL__c = testProduct.Id;
        sysSetting.Default_Company_Code_DNL__c = testCompany.fsCore__Company_Code__c;
        sysSetting.Default_Company_ID_DNL__c = testCompany.Id;
        sysSetting.Default_Pull_Type_DNL__c = 'Soft';
        Database.upsert(sysSetting);
        System.assert(sysSetting.Id != null, 'Test SFS System Settings created assert');
        
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
        
        //Create Lending Application
        List<fsCore__Lending_Application__c> testAppsList = fsCore.TestHelperLendingApplication.getTestApplicationBulk(testCompany
                                                                                                                       , testBranch
                                                                                                                       , testProduct
                                                                                                                       , testContractTemplate
                                                                                                                       , 5);
        
        fsCore__Lending_Application__c testApp = testAppsList[0];
        testApp.fsCore__Primary_Customer_Account__c = testAccount.Id;
        
        
        
        Database.insert(testApp);
        System.assert(testApp.Id != null, 'Test Lending Application created assert');
        fsCore.LendingApplicationTriggerWrapper.getInstance().reset();
        //Create Lending Application
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                                            , testBranch
                                                                                                                            , testProduct2
                                                                                                                            , testContractTemplate
                                                                                                                            , 'Test Application');
        insert testApplication;
        System.assert(testApplication.Id != null, 'Test Lending Application created assert'); 
        
        //Create Lending Contract
        
        List<fsServ__Lending_Contract__c> contractList = fsServ.TestQueryHelper.getTestLendingContracts().values();                                                                                                     
        fsServ__Lending_Contract__c testContract = contractList[0];
        testContract.fsServ__Primary_Customer_Account__c = testAccount.Id;
        //testContract.fsServ__Lending_Application_Number__c = testApp.id;
        Database.upsert(testContract);
        
        System.assert(testContract.Id != null, 'Test Lending Contract created assert');
        
        //create Opportunity
        List<Opportunity> opplist = new List<Opportunity>();
        Opportunity testOpportunity = TestHelperData.createDNLOpportunity(testAccount.Id);
        testOpportunity.Co_Applicant_Name__c = testCoAccount.Id;
        testOpportunity.Related_Lending_Application__c = testApp.Id;
        testOpportunity.Import_Id__c = testApp.Id;
        
        Opportunity testOpportunity1= TestHelperData.createDNLOpportunity(testAccount.Id);
        testOpportunity1.Name = 'Test Opportunity1';
        testOpportunity1.Co_Applicant_Name__c = null;
        testOpportunity1.Program_Id__c = 'test1';
        testOpportunity1.Program_Type__c = 'test1';
        testOpportunity1.DRP_Name__c = 'DRP1211';
        testOpportunity1.DRP_Account_Number__c = '23763761';
        testOpportunity1.Related_Lending_Application__c = testApp.Id;
        testOpportunity1.Import_Id__c = '12761726';
        
        opplist.add(testOpportunity);
        opplist.add(testOpportunity1);
        
        
        Database.insert(opplist);
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
        testEmployment.fsCore__End_Date__c = null;
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
                                                                                                                        ,testCoAccount.Id
                                                                                                                        ,testCoAccount.PersonContactId
                                                                                                                        ,'Secondary');
        insert testAppCustomer2;
        System.assert(testAppCustomer2.Id != null, 'Test Lending Application Customer2 created assert');
        
        TestHelperData.createDocusignDocumentSettings();  
        
    } 
    @isTest
    private static void testServiceHandlerGetMethod(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId;
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    } 
    
    
    @isTest
    private static void testServiceHandlerGet_Error(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications'+(String)appId;
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    } 
    @isTest
    private static void testServiceHandlerGet_Investment(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investments';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    } 
    
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    } 
    
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsServ__Lending_Contract__c contract = [Select id from fsServ__Lending_Contract__c limit 1];
        contract.fsServ__Lending_Application_Number__c = testApplication.id;
        update contract;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    } 
    
    
    @isTest
    private static void testServiceHandlerGet_InvestorApplicationStatus(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_application_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    } 
    
    @isTest
    private static void testServiceHandlerPostMethod(){
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications';
        req.httpMethod = 'POST'; 
        RestResponse res = new RestResponse();      
        String jsonStr = '{"requested_payment_cycle" : "Monthly", "requested_loan_term" : 12, "requested_loan_amount" : 15000, "reference_number" : "12345", "product_code" : "PL", "phone_number" : null, "mobile_number" : null, "mailing_street" : "711 Third Avenue", "mailing_state" : "New York", "mailing_postal_code" : "10017", "mailing_country" : "United States", "mailing_city" : "New York", "loan_purpose" : "Travel", "last_name" : "Smith", "first_name" : "John", "email" : null, "date_of_birth" : null,  "application_date" : "2019-04-28"}';
        req.requestBody = blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doPost();       
        Test.stopTest(); 
    } 
    @isTest
    private static void testServiceHandlerPutMethod_Withdraw(){
        //handleApplicationWithdraw
        fsCore__Lending_Application__c testApplication =[SELECT Id, Withdraw_Reason__c
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        String reqPath='/services/apexrest/versara/v1/applications/'+(String)appId+'/withdraw';
        
        RestRequest req = new RestRequest();
        req.requestURI = reqPath;
        req.httpMethod = 'PUT'; 
        RestResponse res = new RestResponse();      
        //  String jsonStr = '{ "withdraw_reason" : "Client not interested to proceed", "application_id" : "a1kL0000001dwFfIAI" }';
        String jsonStr = '{ "withdraw_reason" : "Not Interested", "application_id" : "a1kL0000001dwFfIAI" }';
        
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
        jsonMap.Remove('application_id');
        jsonMap.put('application_id', appId);
        System.debug(loggingLevel.ERROR,'jsonMap'+jsonMap);
        jsonStr=JSON.serialize(jsonMap);
        
        req.requestBody = blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doPut(); 
        Test.stopTest(); 
        
    }
    @isTest
    private static void testServiceHandlerPutMethod_HardPullGrade(){
        //handleApplicationWithdraw
        fsCore__Lending_Application__c testApplication =[SELECT Id, Model_Hard_Pull_Score__c
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        String reqPath='/services/apexrest/versara/v1/applications/'+(String)appId+'/hard_pull_grade';
        
        RestRequest req = new RestRequest();
        req.requestURI = reqPath;
        req.httpMethod = 'PUT'; 
        RestResponse res = new RestResponse();      
        String jsonStr = '{ "model_hard_pull_score" : "3", "application_id" : "a1kL0000001dwFfIAI" }';
        
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
        jsonMap.Remove('application_id');
        jsonMap.put('application_id', appId);
        System.debug(loggingLevel.ERROR,'jsonMap'+jsonMap);
        jsonStr=JSON.serialize(jsonMap);
        
        req.requestBody = blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doPut(); 
        Test.stopTest(); 
        
    }
    @isTest
    private static void testServiceHandlerPutMethod_Update(){
        //handleApplicationUpdate
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         , Loan_Type__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        
        Id appId=testApplication.Id;
        String reqPath='/services/apexrest/versara/v1/applications/'+(String)appId;
        
        RestRequest req = new RestRequest();
        req.requestURI = reqPath;
        req.httpMethod = 'PUT'; 
        RestResponse res = new RestResponse();      
        // String jsonStr = '{ "status" : "Approved For Funding", "application_id" : "a1kL0000001dwGFIAY" }';
        String jsonStr = '{ "status" : "Negotiations Review", "application_id" : "a1kL0000001dwGFIAY" }';	
        
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
        jsonMap.Remove('application_id');
        jsonMap.put('application_id', appId);
        System.debug(loggingLevel.ERROR,'jsonMap'+jsonMap);
        jsonStr=JSON.serialize(jsonMap);
        
        System.debug(loggingLevel.ERROR,'json'+jsonStr);
        req.requestBody = blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doPut(); 
        Test.stopTest(); 
        
    }
    
    @isTest
    private static void testServiceHandlerPutMethod_Decline(){
        //handleApplicationDecline
        fsCore__Lending_Application__c testApplication =[SELECT Id, fsCore__Product_Name__c
                                                         , Previous_Status__c 
                                                         , fsCore__Application_Status__c 
                                                         , Rejection_Causes__c
                                                         , Rejection_Comments__c
                                                         , Credit_Bureau_Used__c
                                                         , Rejection_Reasons__c
                                                         , Internal_Rejection_Reasons__c 
                                                         , Internal_Rejection_Reason_Codes__c 
                                                         , External_Rejection_Reasons__c
                                                         , External_Rejection_Reason_Codes__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        
        Id appId=testApplication.Id;
        
        RestRequest req = new RestRequest();
        String reqPath='/services/apexrest/versara/v1/applications/'+(String)appId+'/decline';
        System.debug(loggingLevel.ERROR, 'reqPAth'+reqPath);
        
        req.requestURI = reqPath ;
        req.httpMethod = 'PUT'; 
        RestResponse res = new RestResponse();      
        String jsonStr = '{ "application_id" : "a1k8A000001nml8QAA", "decline_cause" : "Credit Report" ,"decline_comments" : "Declined","credit_bureau_used" : "Equifax", "internal_reasons":[{"reason_code":"TEST_Int_R1" , "reason_description":"Test Internal Reason1"},{"reason_code":"TEST_Int_R2" , "reason_description":"Test Internal Reason2"}],"external_reasons":[{"reason_code":"TEST_Ext_R1" , "reason_description":"Test External Reason1"},{"reason_code":"TEST_Int_R2" , "reason_description":"Test External Reason2"}]}';
        
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
        jsonMap.Remove('application_id');
        jsonMap.put('application_id', appId);
        System.debug(loggingLevel.ERROR,'jsonMap'+jsonMap);
        jsonStr=JSON.serialize(jsonMap);
        
        System.debug(loggingLevel.ERROR,'json'+jsonStr);
        req.requestBody = blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doPut(); 
        Test.stopTest(); 
        
    }
    
    ///*********************************///    
    @isTest
    private static void testServiceHandlerPostMethod_NegScenario(){
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications';
        req.httpMethod = 'POST'; 
        RestResponse res = new RestResponse();      
        String jsonStr = '{"requested_payment_cycle" : "Monthly", "requested_loan_term" : 12, "requested_loan_amount" : 0, "reference_number" : "12345", "product_code" : "PL", "phone_number" : null, "mobile_number" : null, "mailing_street" : "711 Third Avenue", "mailing_state" : "New York", "mailing_postal_code" : "10017", "mailing_country" : "United States", "mailing_city" : "New York", "loan_purpose" : "Travel", "last_name" : "Smith", "first_name" : "John", "email" : null, "date_of_birth" : null,  "application_date" : "2019-04-28"}';
        req.requestBody = blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doPost();       
        Test.stopTest(); 
    } 
    
    @isTest
    private static void testServiceHandlerPutMethod_Withdraw_NegScenario(){
        //handleApplicationWithdraw
        fsCore__Lending_Application__c testApplication =[SELECT Id, Withdraw_Reason__c
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        
        String reqPath='/services/apexrest/versara/v1/applications/'+'a1k8A000001nml8QAA'+'/withdraw';
        
        RestRequest req = new RestRequest();
        req.requestURI = reqPath;
        req.httpMethod = 'PUT'; 
        RestResponse res = new RestResponse();      
        String jsonStr = '';
        
        req.requestBody = blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doPut(); 
        Test.stopTest(); 
        
    }
    
    
    @isTest
    private static void testServiceHandlerPutMethod_Update_NegScenario(){
        //handleApplicationUpdate
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/a1kL0000001dwGFIAY' ;
        req.httpMethod = 'PUT'; 
        RestResponse res = new RestResponse();      
        //  String jsonStr = '{ "status" : "Approved For Funding", "application_id" : "a1k8A000001nml8QAA" }';
        String jsonStr = '{ "status" : "Negotiations Review", "application_id" : "a1k8A000001nml8QAA" }';	
        req.requestBody = blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doPut(); 
        Test.stopTest(); 
        
    }
    
    
    @isTest
    private static void testServiceHandlerPutMethod_Decline_NegScenario(){
        //handleApplicationDecline
        fsCore__Lending_Application__c testApplication =[SELECT Id, fsCore__Product_Name__c
                                                         , Previous_Status__c 
                                                         , fsCore__Application_Status__c 
                                                         , Rejection_Causes__c
                                                         , Rejection_Comments__c
                                                         , Credit_Bureau_Used__c
                                                         , Rejection_Reasons__c
                                                         , Internal_Rejection_Reasons__c 
                                                         , Internal_Rejection_Reason_Codes__c 
                                                         , External_Rejection_Reasons__c
                                                         , External_Rejection_Reason_Codes__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/a1k8A000001nml8QAA/decline' ;
        req.httpMethod = 'PUT'; 
        RestResponse res = new RestResponse();      
        String jsonStr = '{ }';
        req.requestBody = blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doPut(); 
        Test.stopTest(); 
        
    }
    @isTest
    private static void testServiceHandlerPutMethod_Decline_NegScenarioApplicationNull(){
        //handleApplicationDecline
        fsCore__Lending_Application__c testApplication =[SELECT Id, fsCore__Product_Name__c
                                                         , Previous_Status__c 
                                                         , fsCore__Application_Status__c 
                                                         , Rejection_Causes__c
                                                         , Rejection_Comments__c
                                                         , Credit_Bureau_Used__c
                                                         , Rejection_Reasons__c
                                                         , Internal_Rejection_Reasons__c 
                                                         , Internal_Rejection_Reason_Codes__c 
                                                         , External_Rejection_Reasons__c
                                                         , External_Rejection_Reason_Codes__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/a1k8A000001nml3458QAA/decline' ;
        req.httpMethod = 'PUT'; 
        RestResponse res = new RestResponse();      
        String jsonStr = '{ }';
        req.requestBody = blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doPut(); 
        Test.stopTest(); 
        
    }
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario1(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsServ__Lending_Contract__c contract = [Select id from fsServ__Lending_Contract__c limit 1];
        contract.fsServ__Lending_Application_Number__c = testApplication.id;
        contract.fsServ__Is_Delinquent__c = true;
        contract.fsServ__Contract_Status__c = 'Active';
        contract.fsServ__Delinquent_Days__c = 10;
        update contract;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    } 
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario2(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsServ__Lending_Contract__c contract = [Select id from fsServ__Lending_Contract__c limit 1];
        contract.fsServ__Lending_Application_Number__c = testApplication.id;
        contract.fsServ__Is_Delinquent__c = true;
        contract.fsServ__Contract_Status__c = 'Active';
        contract.fsServ__Delinquent_Days__c = 20;
        update contract;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    } 
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario3(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsServ__Lending_Contract__c contract = [Select id from fsServ__Lending_Contract__c limit 1];
        contract.fsServ__Lending_Application_Number__c = testApplication.id;
        contract.fsServ__Is_Delinquent__c = true;
        contract.fsServ__Contract_Status__c = 'Active';
        contract.fsServ__Delinquent_Days__c = 30;
        update contract;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    } 
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario4(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsServ__Lending_Contract__c contract = [Select id from fsServ__Lending_Contract__c limit 1];
        contract.fsServ__Lending_Application_Number__c = testApplication.id;
        contract.fsServ__Is_Delinquent__c = true;
        contract.fsServ__Contract_Status__c = 'Active';
        contract.fsServ__Delinquent_Days__c = 40;
        update contract;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    } 
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario5(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsServ__Lending_Contract__c contract = [Select id from fsServ__Lending_Contract__c limit 1];
        contract.fsServ__Lending_Application_Number__c = testApplication.id;
        contract.fsServ__Is_Delinquent__c = true;
        contract.fsServ__Contract_Status__c = 'Active';
        contract.fsServ__Delinquent_Days__c = 50;
        update contract;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    } 
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario6(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsServ__Lending_Contract__c contract = [Select id from fsServ__Lending_Contract__c limit 1];
        contract.fsServ__Lending_Application_Number__c = testApplication.id;
        contract.fsServ__Is_Delinquent__c = true;
        contract.fsServ__Contract_Status__c = 'Active';
        contract.fsServ__Delinquent_Days__c = 70;
        update contract;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    } 
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario7(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsServ__Lending_Contract__c contract = [Select id from fsServ__Lending_Contract__c limit 1];
        contract.fsServ__Lending_Application_Number__c = testApplication.id;
        contract.fsServ__Is_Delinquent__c = true;
        contract.fsServ__Contract_Status__c = 'Active';
        contract.fsServ__Delinquent_Days__c = 100;
        update contract;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    } 
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario8(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsServ__Lending_Contract__c contract = [Select id from fsServ__Lending_Contract__c limit 1];
        contract.fsServ__Lending_Application_Number__c = testApplication.id;
        contract.fsServ__Is_Delinquent__c = true;
        contract.fsServ__Contract_Status__c = 'Active';
        contract.fsServ__Delinquent_Days__c = 130;
        update contract;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    } 
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario9(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsServ__Lending_Contract__c contract = [Select id from fsServ__Lending_Contract__c limit 1];
        contract.fsServ__Lending_Application_Number__c = testApplication.id;
        contract.fsServ__Is_Delinquent__c = true;
        contract.fsServ__Contract_Status__c = 'Charged Off';
        contract.fsServ__Delinquent_Days__c = 100;
        update contract;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    } 
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario10(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsServ__Lending_Contract__c contract = [Select id from fsServ__Lending_Contract__c limit 1];
        contract.fsServ__Lending_Application_Number__c = testApplication.id;
        contract.fsServ__Contract_Status__c = 'Charged Off';
        update contract;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    } 
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario11(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsServ__Lending_Contract__c contract = [Select id from fsServ__Lending_Contract__c limit 1];
        contract.fsServ__Lending_Application_Number__c = testApplication.id;
        contract.fsServ__Contract_Status__c = 'Closed';
        update contract;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    } 
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario12(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsServ__Lending_Contract__c contract = [Select id from fsServ__Lending_Contract__c limit 1];
        contract.fsServ__Lending_Application_Number__c = testApplication.id;
        contract.fsServ__Contract_Status__c = 'Paid In Full';
        update contract;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    } 
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario13(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsServ__Lending_Contract__c contract = [Select id from fsServ__Lending_Contract__c limit 1];
        contract.fsServ__Lending_Application_Number__c = testApplication.id;
        contract.fsServ__Contract_Status__c = 'Void';
        update contract;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    } 
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario14(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsServ__Lending_Contract__c contract = [Select id from fsServ__Lending_Contract__c limit 1];
        contract.fsServ__Lending_Application_Number__c = testApplication.id;
        contract.fsServ__Contract_Status__c = 'Pending';
        update contract;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    } 
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario15(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                                  , 3);
        testStage.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage.fsCore__Stage_Code__c ='PL_PRE_SCREEN';
        testStage.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage;
        System.assert(testStage.Id != null, 'Test stage  created assert');
        testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        update testApplication;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    } 
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario16(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c where Loan_Type__c = 'VCL' 
                                                         LIMIT 1];
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                                  , 3);
        testStage.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage.fsCore__Stage_Code__c ='PL_PRE_SCREEN';
        testStage.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage;
        System.assert(testStage.Id != null, 'Test stage  created assert');
        testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        testApplication.fsCore__Application_Status__c = 'Offer Accepted';
        update testApplication;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    } 
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario17(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c where Loan_Type__c = 'VCL'
                                                         LIMIT 1];
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                                  , 3);
        testStage.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage.fsCore__Stage_Code__c ='PL_PRE_SCREEN';
        testStage.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage;
        System.assert(testStage.Id != null, 'Test stage  created assert');
        testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        testApplication.fsCore__Application_Status__c = 'Registration in Progress';
        update testApplication;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    } 
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario18(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c where Loan_Type__c = 'VCL'
                                                         LIMIT 1];
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                                  , 3);
        testStage.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage.fsCore__Stage_Code__c ='PL_PRE_SCREEN';
        testStage.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage;
        System.assert(testStage.Id != null, 'Test stage  created assert');
        testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        testApplication.fsCore__Application_Status__c = 'Application in Progress';
        update testApplication;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    } 
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario19(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                                  , 3);
        testStage.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage.fsCore__Stage_Code__c ='PL_PRE_SCREEN';
        testStage.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage;
        System.assert(testStage.Id != null, 'Test stage  created assert');
        testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        testApplication.fsCore__Application_Status__c = 'Withdrawn';
        update testApplication;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    } 
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario20(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                                  , 3);
        testStage.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage.fsCore__Stage_Code__c ='PL_PRE_SCREEN';
        testStage.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage;
        System.assert(testStage.Id != null, 'Test stage  created assert');
        testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        testApplication.fsCore__Application_Status__c = 'Declined';
        update testApplication;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    }
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario21(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c where Loan_Type__c = 'VCL'
                                                         LIMIT 1];
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                                  , 3);
        testStage.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage.fsCore__Stage_Code__c ='PL_DOC_PROCESSING';
        testStage.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage;
        System.assert(testStage.Id != null, 'Test stage  created assert');
        testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        testApplication.fsCore__Application_Status__c = 'In Progress';
        update testApplication;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    }
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario22(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                                  , 3);
        testStage.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage.fsCore__Stage_Code__c ='PL_DOC_PROCESSING';
        testStage.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage;
        System.assert(testStage.Id != null, 'Test stage  created assert');
        testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        testApplication.fsCore__Application_Status__c = 'Withdrawal Requested';
        update testApplication;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    }
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario23(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                                  , 3);
        testStage.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage.fsCore__Stage_Code__c ='PL_DOC_PROCESSING';
        testStage.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage;
        System.assert(testStage.Id != null, 'Test stage  created assert');
        testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        testApplication.fsCore__Application_Status__c = 'Withdrawn';
        update testApplication;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    }
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario24(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                                  , 3);
        testStage.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage.fsCore__Stage_Code__c ='PL_DOC_PROCESSING';
        testStage.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage;
        System.assert(testStage.Id != null, 'Test stage  created assert');
        testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        testApplication.fsCore__Application_Status__c = 'Declined';
        update testApplication;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    }
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario25(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                                  , 3);
        testStage.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage.fsCore__Stage_Code__c ='PL_DOC_PROCESSING';
        testStage.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage;
        System.assert(testStage.Id != null, 'Test stage  created assert');
        testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        testApplication.fsCore__Application_Status__c = 'Pending Decline';
        update testApplication;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    }
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario26(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c where Loan_Type__c = 'VCL'
                                                         LIMIT 1];
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                                  , 3);
        testStage.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage.fsCore__Stage_Code__c ='  PL_UND_WRT';
        testStage.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage;
        System.assert(testStage.Id != null, 'Test stage  created assert');
        testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        testApplication.fsCore__Application_Status__c = 'Pending Submission';
        update testApplication;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    }
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario27(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                                  , 3);
        testStage.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage.fsCore__Stage_Code__c ='  PL_UND_WRT';
        testStage.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage;
        System.assert(testStage.Id != null, 'Test stage  created assert');
        testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        testApplication.fsCore__Application_Status__c = 'Pending Approval';
        update testApplication;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    }
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario28(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c where Loan_Type__c = 'VCL'
                                                         LIMIT 1];
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                                  , 3);
        testStage.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage.fsCore__Stage_Code__c ='  PL_UND_WRT';
        testStage.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage;
        System.assert(testStage.Id != null, 'Test stage  created assert');
        testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        testApplication.fsCore__Application_Status__c = 'Approved for Funding';
        update testApplication;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    }
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario29(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                                  , 3);
        testStage.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage.fsCore__Stage_Code__c ='  PL_UND_WRT';
        testStage.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage;
        System.assert(testStage.Id != null, 'Test stage  created assert');
        testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        testApplication.fsCore__Application_Status__c = 'QA Issue';
        update testApplication;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    }
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario30(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                                  , 3);
        testStage.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage.fsCore__Stage_Code__c ='  PL_UND_WRT';
        testStage.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage;
        System.assert(testStage.Id != null, 'Test stage  created assert');
        testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        testApplication.fsCore__Application_Status__c = 'Withdrawn';
        update testApplication;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    }
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario31(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                                  , 3);
        testStage.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage.fsCore__Stage_Code__c ='  PL_UND_WRT';
        testStage.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage;
        System.assert(testStage.Id != null, 'Test stage  created assert');
        testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        testApplication.fsCore__Application_Status__c = 'Pending Decline';
        update testApplication;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    }
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario32(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                                  , 3);
        testStage.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage.fsCore__Stage_Code__c ='  PL_UND_WRT';
        testStage.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage;
        System.assert(testStage.Id != null, 'Test stage  created assert');
        testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        testApplication.fsCore__Application_Status__c = 'Declined';
        update testApplication;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    }
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario33(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c where Loan_Type__c = 'VCL' 
                                                         LIMIT 1];
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                                  , 3);
        testStage.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage.fsCore__Stage_Code__c ='  PL_FUNDING';
        testStage.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage;
        System.assert(testStage.Id != null, 'Test stage  created assert');
        testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        testApplication.fsCore__Application_Status__c = 'Lead Underwriter Approved';
        update testApplication;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    }
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario34(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c where Loan_Type__c = 'VCL'
                                                         LIMIT 1];
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                                  , 3);
        testStage.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage.fsCore__Stage_Code__c ='  PL_FUNDING';
        testStage.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage;
        System.assert(testStage.Id != null, 'Test stage  created assert');
        testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        testApplication.fsCore__Application_Status__c = 'BAV In Progress';
        update testApplication;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    }
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario35(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c where Loan_Type__c = 'VCL'
                                                         LIMIT 1];
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                                  , 3);
        testStage.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage.fsCore__Stage_Code__c ='  PL_FUNDING';
        testStage.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage;
        System.assert(testStage.Id != null, 'Test stage  created assert');
        testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        testApplication.fsCore__Application_Status__c = 'BAV Completed';
        update testApplication;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    }
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario36(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c where Loan_Type__c = 'VCL'
                                                         LIMIT 1];
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                                  , 3);
        testStage.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage.fsCore__Stage_Code__c ='  PL_FUNDING';
        testStage.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage;
        System.assert(testStage.Id != null, 'Test stage  created assert');
        testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        testApplication.fsCore__Application_Status__c = 'BAV Failed';
        update testApplication;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    }
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario37(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c where Loan_Type__c = 'VCL'
                                                         LIMIT 1];
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                                  , 3);
        testStage.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage.fsCore__Stage_Code__c ='  PL_FUNDING';
        testStage.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage;
        System.assert(testStage.Id != null, 'Test stage  created assert');
        testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        testApplication.fsCore__Application_Status__c = 'Approved for Funding';
        update testApplication;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    }
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario38(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                                  , 3);
        testStage.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage.fsCore__Stage_Code__c ='  PL_FUNDING';
        testStage.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage;
        System.assert(testStage.Id != null, 'Test stage  created assert');
        testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        testApplication.fsCore__Application_Status__c = 'Pending Decline';
        update testApplication;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    }
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario39(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                                  , 3);
        testStage.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage.fsCore__Stage_Code__c ='  PL_FUNDING';
        testStage.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage;
        System.assert(testStage.Id != null, 'Test stage  created assert');
        testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        testApplication.fsCore__Application_Status__c = 'Declined';
        update testApplication;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    }
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario40(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c where Loan_Type__c = 'VCL'
                                                         LIMIT 1];
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                                  , 3);
        testStage.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage.fsCore__Stage_Code__c ='  PL_FUNDING';
        testStage.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage;
        System.assert(testStage.Id != null, 'Test stage  created assert');
        testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        testApplication.fsCore__Application_Status__c = 'Funding In Progress';
        update testApplication;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    }
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario41(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                                  , 3);
        testStage.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage.fsCore__Stage_Code__c ='  PL_FUNDING';
        testStage.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage;
        System.assert(testStage.Id != null, 'Test stage  created assert');
        testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        testApplication.fsCore__Application_Status__c = 'Funded';
        update testApplication;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    }
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario42(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                                  , 3);
        testStage.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage.fsCore__Stage_Code__c ='  PL_FUNDING';
        testStage.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage;
        System.assert(testStage.Id != null, 'Test stage  created assert');
        testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        testApplication.fsCore__Application_Status__c = 'Withdrawn';
        update testApplication;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    }
    @isTest
    private static void testServiceHandlerGet_InvestorLoanStatus_NegScenario42ApplicationNull(){
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                                  , 3);
        testStage.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage.fsCore__Stage_Code__c ='  PL_FUNDING';
        testStage.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage;
        System.assert(testStage.Id != null, 'Test stage  created assert');
        testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        testApplication.fsCore__Application_Status__c = 'Withdrawn';
        update testApplication;
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications/'+(String)appId+'0/investor_loan_status';
        req.httpMethod = 'GET'; 
        RestResponse res = new RestResponse();      
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doGet();       
        Test.stopTest(); 
    }
    @isTest
    public static void testSanitizedSSN(){
        RESTApplicationHandler_V1 handlerObj = new RESTApplicationHandler_V1();
        String ssn = handlerObj.getSanitizedSSN('1234567');
        String ssn2 = handlerObj.getSanitizedSSN(null);
    }
    @isTest
    private static void testServiceHandlerPostMethodError(){
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications';
        req.httpMethod = 'POST'; 
        RestResponse res = new RestResponse();      
        String jsonStr = '{"requested_payment_cycle" : "Monthly", "requested_loan_term" : 12, "requested_loan_amount" : 15000, "reference_number" : "12345", "product_code" : "", "phone_number" : null, "mobile_number" : null, "mailing_street" : "711 Third Avenue", "mailing_state" : "New York", "mailing_postal_code" : "10017", "mailing_country" : "United States", "mailing_city" : "New York", "loan_purpose" : "Travel", "last_name" : "Smith", "first_name" : "John", "email" : null, "date_of_birth" : null,  "application_date" : "2019-04-28"}';
        req.requestBody = blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doPost();       
        Test.stopTest(); 
    }
    @isTest
    private static void testServiceHandlerPostMethodwithApplicantsError(){
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications';
        req.httpMethod = 'POST'; 
        RestResponse res = new RestResponse();      
        String jsonStr = '{"requested_payment_cycle":"Monthly","requested_loan_term":12,"requested_loan_amount":15000,"reference_number":"12345","product_code":"VCL","loan_purpose":"Other","application_date":"2019-04-03","velocify_id":"112212","applicants":[{"relationship":"Primary12","phone_number":null,"mobile_number":null,"mailing_street":null,"mailing_state":null,"mailing_postal_code":null,"mailing_country":null,"mailing_city":null,"home_street":null,"home_state":null,"home_postal_code":null,"home_country":null,"home_city":null,"last_name":"Smith","first_name":"John","email":null,"date_of_birth":null,"annual_stated_Income" : 100000,"transunion_ssn" : "661-22-22898","social_security_number" : "661-22-22988"},{"relationship":"","phone_number":null,"mobile_number":null,"mailing_street":null,"mailing_state":null,"mailing_postal_code":null,"mailing_country":null,"mailing_city":null,"home_street":null,"home_state":null,"home_postal_code":null,"home_country":null,"home_city":null,"last_name":"Smith","first_name":"George","email":null,"date_of_birth":null,"annual_stated_Income" : 50000,"transunion_ssn" : "661-21-2288","social_security_number" : "661-21-2288"}]}';
        req.requestBody = blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doPost();       
        Test.stopTest(); 
    }
    
    @isTest
    private static void testServiceHandlerPostMethodwithApplicants(){
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications';
        req.httpMethod = 'POST'; 
        RestResponse res = new RestResponse();      
        String jsonStr = '{"requested_payment_cycle":"Monthly","requested_loan_term":12,"requested_loan_amount":15000,"reference_number":"12345","product_code":"VCL","loan_purpose":"Other","application_date":"2019-04-03","velocify_id":"112212","applicants":[{"relationship":"Primary","phone_number":null,"mobile_number":null,"mailing_street":null,"mailing_state":null,"mailing_postal_code":null,"mailing_country":null,"mailing_city":null,"home_street":null,"home_state":null,"home_postal_code":null,"home_country":null,"home_city":null,"last_name":"Smith","first_name":"John","email":null,"date_of_birth":null,"annual_stated_Income" : 100000,"transunion_ssn" : "661-22-2298","social_security_number" : "661-22-2288"},{"relationship":"Secondary","phone_number":null,"mobile_number":null,"mailing_street":null,"mailing_state":null,"mailing_postal_code":null,"mailing_country":null,"mailing_city":null,"home_street":null,"home_state":null,"home_postal_code":null,"home_country":null,"home_city":null,"last_name":"Smith","first_name":"George","email":null,"date_of_birth":null,"annual_stated_Income" : 50000,"transunion_ssn" : "661-21-2288","social_security_number" : "661-21-2288"}]}';
        req.requestBody = blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doPost();       
        Test.stopTest(); 
    }
    @isTest
    private static void testServiceHandlerPostMethodwithApplicants2(){
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications';
        req.httpMethod = 'POST'; 
        RestResponse res = new RestResponse();      
        String jsonStr = '{"requested_payment_cycle":"Monthly","requested_loan_term":12,"requested_loan_amount":15000,"reference_number":"12345","product_code":"VCL","loan_purpose":"Other","application_date":"2019-04-03","velocify_id":"112212","applicants":[{"relationship":"Primary","phone_number":null,"mobile_number":null,"mailing_street":null,"mailing_state":null,"mailing_postal_code":null,"mailing_country":null,"mailing_city":null,"home_street":null,"home_state":null,"home_postal_code":null,"home_country":null,"home_city":null,"last_name":"Smith","first_name":"John","email":"aniket.singh@financialspectra.com","date_of_birth":"2009-04-03","annual_stated_Income" : 100000,"transunion_ssn" : "661-22-2298","social_security_number" : "661-22-2288"},{"relationship":"Secondary","phone_number":null,"mobile_number":null,"mailing_street":null,"mailing_state":null,"mailing_postal_code":null,"mailing_country":null,"mailing_city":null,"home_street":null,"home_state":null,"home_postal_code":null,"home_country":null,"home_city":null,"last_name":"Smith","first_name":"George","email":null,"date_of_birth":null,"annual_stated_Income" : 50000,"transunion_ssn" : "661-21-2288","social_security_number" : "661-21-2288"}]}';
        req.requestBody = blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doPost();       
        Test.stopTest(); 
    }
    
    @isTest
    private static void testServiceHandlerPostMethodCoverAccountMatch(){
        RESTApplicant.Request pApplicant = new RESTApplicant.Request();
        Account acc = [Select id,FirstName, LastName , PersonMobilePhone,PersonMailingStreet,PersonMailingCity,PersonMailingState,PersonMailingCountry,PersonMailingPostalCode,fsCore__National_Identification_Number__pc from Account limit 1];
        RESTApplicationHandler_V1 obj = new RESTApplicationHandler_V1();
        Boolean isMatch = obj.isAccountMatching(acc,pApplicant);
        
        
    }  
    @isTest
    private static void testServiceHandlerPutMethod_DeclineError(){
        //handleApplicationDecline
        fsCore__Lending_Application__c testApplication =[SELECT Id, fsCore__Product_Name__c
                                                         , Previous_Status__c 
                                                         , fsCore__Application_Status__c 
                                                         , Rejection_Causes__c
                                                         , Rejection_Comments__c
                                                         , Credit_Bureau_Used__c
                                                         , Rejection_Reasons__c
                                                         , Internal_Rejection_Reasons__c 
                                                         , Internal_Rejection_Reason_Codes__c 
                                                         , External_Rejection_Reasons__c
                                                         , External_Rejection_Reason_Codes__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        
        Id appId=testApplication.Id;
        
        RestRequest req = new RestRequest();
        String reqPath='/services/apexrest/versara/v1/applications/'+(String)appId+'/decline';
        System.debug(loggingLevel.ERROR, 'reqPAth'+reqPath);
        
        req.requestURI = reqPath ;
        req.httpMethod = 'PUT'; 
        RestResponse res = new RestResponse();      
        String jsonStr = '{ "application_id" : "a1k8A000001nml8QAA", "decline_cause "Credit Report" ,"decline_comments" : "Declined","credit_bureau_used" : "Equifax", "internal_reasons":[{"reason_code":"TEST_Int_R1" , "reason_description":"Test Internal Reason1"},{"reason_code":"TEST_Int_R2" , "reason_description":"Test Internal Reason2"}],"external_reasons":[{"reason_code":"TEST_Ext_R1" , "reason_description":"Test External Reason1"},{"reason_code":"TEST_Int_R2" , "reason_description":"Test External Reason2"}]}';
        try{
            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
            jsonMap.Remove('application_id');
            jsonMap.put('application_id', appId);
            System.debug(loggingLevel.ERROR,'jsonMap'+jsonMap);
            
            jsonStr=JSON.serialize(jsonMap);  
        }
        catch(Exception e){
            
        }        
        
        System.debug(loggingLevel.ERROR,'json'+jsonStr);
        req.requestBody = blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doPut(); 
        Test.stopTest(); 
        
    }
    @isTest
    private static void testServiceHandlerPutMethod_HardPullGradeError(){
        //handleApplicationWithdraw
        fsCore__Lending_Application__c testApplication =[SELECT Id, Model_Hard_Pull_Score__c
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        String reqPath='/services/apexrest/versara/v1/applications/'+(String)appId+'/hard_pull_grade';
        
        RestRequest req = new RestRequest();
        req.requestURI = reqPath;
        req.httpMethod = 'PUT'; 
        RestResponse res = new RestResponse();      
        String jsonStr = '{ "model_hard_pull_score "3", "application_id" : "a1kL0000001dwFfIAI" }';
        try{
            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
            jsonMap.Remove('application_id');
            jsonMap.put('application_id', appId);
            System.debug(loggingLevel.ERROR,'jsonMap'+jsonMap);
            jsonStr=JSON.serialize(jsonMap);
        }
        catch(Exception e){
            
        }
        
        req.requestBody = blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doPut(); 
        Test.stopTest(); 
        
    }
    @isTest
    private static void testServiceHandlerPutMethod_UpdateError(){
        //handleApplicationUpdate
        fsCore__Lending_Application__c testApplication =[SELECT Id
                                                         , fsCore__Application_Status__c
                                                         , Loan_Type__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        
        Id appId=testApplication.Id;
        String reqPath='/services/apexrest/versara/v1/applications/'+(String)appId;
        
        RestRequest req = new RestRequest();
        req.requestURI = reqPath;
        req.httpMethod = 'PUT'; 
        RestResponse res = new RestResponse();      
        
        String jsonStr = '{ "status "Negotiations Review", "application_id" : "a1kL0000001dwGFIAY" }';	
        try{
            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
            jsonMap.Remove('application_id');
            jsonMap.put('application_id', appId);
            System.debug(loggingLevel.ERROR,'jsonMap'+jsonMap);
            jsonStr=JSON.serialize(jsonMap);
        }
        catch(Exception e){
            
        }
        
        System.debug(loggingLevel.ERROR,'json'+jsonStr);
        req.requestBody = blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doPut(); 
        Test.stopTest(); 
        
    }
     @isTest
    private static void testServiceHandlerPutMethod_WithdrawError(){
        //handleApplicationWithdraw
        fsCore__Lending_Application__c testApplication =[SELECT Id, Withdraw_Reason__c
                                                         , fsCore__Application_Status__c
                                                         FROM fsCore__Lending_Application__c 
                                                         LIMIT 1];
        
        Id appId=testApplication.Id;
        System.debug(loggingLevel.ERROR, 'AppID:--'+appId);
        String reqPath='/services/apexrest/versara/v1/applications/'+(String)appId+'/withdraw';
        
        RestRequest req = new RestRequest();
        req.requestURI = reqPath;
        req.httpMethod = 'PUT'; 
        RestResponse res = new RestResponse();      
        //  String jsonStr = '{ "withdraw_reason" : "Client not interested to proceed", "application_id" : "a1kL0000001dwFfIAI" }';
        String jsonStr = '{ "withdraw_reason "Not Interested", "application_id" : "a1kL0000001dwFfIAI" }';
        try{
                  Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
        jsonMap.Remove('application_id');
        jsonMap.put('application_id', appId);
        System.debug(loggingLevel.ERROR,'jsonMap'+jsonMap);
        jsonStr=JSON.serialize(jsonMap);  
        }
        catch(Exception e){
            
        }

        
        req.requestBody = blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doPut(); 
        Test.stopTest(); 
        
    }
     @isTest
    private static void testServiceHandlerPostMethodwithApplicantsError2(){
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/versara/v1/applications';
        req.httpMethod = 'POST'; 
        RestResponse res = new RestResponse();      
        String jsonStr = '{"requested_payment_cycle Monthly","requested_loan_term":12,"requested_loan_amount":15000,"reference_number":"12345","product_code":"VCL","loan_purpose":"Other","application_date":"2019-04-03","velocify_id":"112212","applicants":[{"relationship":"Primary","phone_number":null,"mobile_number":null,"mailing_street":null,"mailing_state":null,"mailing_postal_code":null,"mailing_country":null,"mailing_city":null,"home_street":null,"home_state":null,"home_postal_code":null,"home_country":null,"home_city":null,"last_name":"Smith","first_name":"John","email":"aniket.singh@financialspectra.com","date_of_birth":"2009-04-03","annual_stated_Income" : 100000,"transunion_ssn" : "661-22-2298","social_security_number" : "661-22-2288"},{"relationship":"Secondary","phone_number":null,"mobile_number":null,"mailing_street":null,"mailing_state":null,"mailing_postal_code":null,"mailing_country":null,"mailing_city":null,"home_street":null,"home_state":null,"home_postal_code":null,"home_country":null,"home_city":null,"last_name":"Smith","first_name":"George","email":null,"date_of_birth":null,"annual_stated_Income" : 50000,"transunion_ssn" : "661-21-2288","social_security_number" : "661-21-2288"}]}';
        req.requestBody = blob.valueOf(jsonStr);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTRouter.doPost();       
        Test.stopTest(); 
    }
}