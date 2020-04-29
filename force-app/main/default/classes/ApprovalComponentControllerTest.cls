@isTest
private class ApprovalComponentControllerTest{
    @testSetup
    static void createTestData(){
        TestHelperData.createTriggerExecutionTestData();
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
        
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
        testProduct.Credit_Pull_Report_Record_Type_Name__c='DNL';
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
        System.assert(testAccount.Id != null, 'Test Account created assert');
        
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
        
        
        
        
        // Create an approval request for the account
        /*Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(testApplication.id);

        // Submit on behalf of a specific submitter
        req1.setSubmitterId(thisUser.Id); 

        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId('Example_Process');
        req1.setSkipEntryCriteria(true);

        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);*/

        
    }
    }

    @isTest
    static void test1(){
        
        Opportunity testOpportunity = [SELECT Id, name
                                       ,Is_Application_Submitted__c
                                       ,Related_Lending_Application__c
                                       FROM Opportunity
                                       LIMIT 1];
        
        List<Id> opportunityIds = new List<Id>();
        opportunityIds.add(testOpportunity.ID);
        
        Test.startTest();
        //System.assertEquals(false, testOpportunity.Is_Application_Submitted__c, 'Unsubmitted Opportunity assert'); 
        //System.assertEquals(null, testOpportunity.Related_Lending_Application__c, 'Lending Application Blank assert');
        
        List<fsCore__Lending_Application__c> applicationList = [SELECT id
                                                                , name 
                                                                , Is_Do_Not_Call__c
                                                                , Opportunity_Name__r.Name
                                                                FROM fsCore__Lending_Application__c];


        fsCore__Lending_Application__c app = [SELECT Id FROM fsCore__Lending_Application__c limit 1];
        
      // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(app.id);

        // Submit on behalf of a specific submitter
        req1.setSubmitterId(UserInfo.getUserId()); 

        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId('Underwriter_Final_Approval');
        req1.setSkipEntryCriteria(true);

        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);        
        
        ProcessInstance process = [Select Id from ProcessInstance limit 1];
        

        ApprovalComponentController.getProcessHistory(process.Id);
        ApprovalComponentController.getApprovalData(process.Id);
        

        Test.stopTest();

    }



}