/*
* Class   : GenerateCreditReportActionTest
* Purpose : Action class to Generate credit Repot records
* Author  : Financial Spectra
*/
@isTest
public class GenerateCreditReportActionTest {
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
    static void createTestData(){
        TestHelperData.createTriggerExecutionTestData();
        fsServ.TestHelperGlobal.createSetupData();
        createLendingContracts(true, true);
        fsCore__Branch_Setup__c testBranch = fsServ.TestQueryHelper.getTestBranches().get('TCHQ');
        testBranch.fsCore__Business_Date__c = testBranch.fsCore__Business_Date__c.addDays(30);
        update testBranch;
        fsCore__Company_Setup__c testCompany = [SELECT Id, fsCore__Company_Logo_File_Id__c , fsCore__Company_Code__c FROM fsCore__Company_Setup__c WHERE Id = :testBranch.fsCore__Company_Name__c];
        //update testCompany;
        System.assert(testBranch.Id != null, 'Test branch created assert'); 
        
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
        
        testProduct.fsCore__Customer_Type__c = 'Person Account';
        testProduct.Credit_Pull_Report_Record_Type_Name__c = 'DNL'; //VCL-111
        testProduct.fsCore__Product_Code__c = 'DNL'; 
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
        
        //create Account
        List<Account> accountlist = new List<Account>();
        
        Account nAccount = TestHelperData.createAccount();
        nAccount.PersonOtherStreet  = '124 TT St';
        nAccount.PersonOtherCity  = 'Jersey City';
        nAccount.PersonOtherStateCode  = 'NJ';
        nAccount.PersonOtherPostalCode  = '12212';
        nAccount.PersonBirthdate  =  Date.parse('10/10/1990');


        Account coAppAccount = TestHelperData.createAccount('CoApplicant','LASTNAME');
        coAppAccount.PersonOtherStreet  = '124 TT St';
        coAppAccount.PersonOtherCity  = 'Jersey City';
        coAppAccount.PersonOtherStateCode  = 'NJ';
        coAppAccount.PersonOtherPostalCode  = '12212';
        coAppAccount.PersonBirthdate  = Date.parse('10/10/1990');

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
                                                                                                                       , 1);
        
        fsCore__Lending_Application__c testApp = testAppsList[0];
        testApp.fsCore__Primary_Customer_Account__c = testAccount.Id;
        Database.insert(testApp);
        System.assert(testApp.Id != null, 'Test Lending Application created assert');
        
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
        List<fsCore__Financial__c> testFinancialSetUp =	TestHelperData.createFinancials(testAccount.Id, testAccount.PersonContactId, testEmployment.Id);
        insert testFinancialSetUp;
        System.assert(testFinancialSetUp[0].Id != null, 'Test Financials  created assert');
        
        //create Lending Application Customer Secondary
        list<fsCore__Lending_Application_Customer__c> lcustomer = new list<fsCore__Lending_Application_Customer__c>();
        fsCore__Lending_Application_Customer__c  testAppCustomer1 = fsCore.TestHelperLendingApplication.getTestCustomer(testApp
                                                                                                                        ,testAccount.Id
                                                                                                                        ,testAccount.PersonContactId
                                                                                                                        ,'Primary');
        lcustomer.add(testAppCustomer1);

        
        fsCore__Lending_Application_Customer__c  testAppCustomer2 = fsCore.TestHelperLendingApplication.getTestCustomer(testApp
                                                                                                                        ,testCoAccount.Id
                                                                                                                        ,testCoAccount.PersonContactId
                                                                                                                        ,'Secondary');
        lcustomer.add(testAppCustomer2);

        insert lcustomer;
        System.assert(lcustomer[0].Id != null, 'Test Lending Application Customer1 created assert');
        System.assert(lcustomer[1].Id != null, 'Test Lending Application Customer2 created assert');
        
        
        
    }	
    
    @isTest static void test_method_App_EFX() {
        List<fsCore__Lending_Application__c> testAppsList = [select id from fsCore__Lending_Application__c limit 1 ];
        testAppsList[0].BoxFolderId__c = '88239497883';
        update testAppsList[0];
        System.debug(loggingLevel.ERROR, testAppsList);
        List<CreditPullCustomer>  customer = CreditPullController.getCustomers(testAppsList[0].Id);
        system.debug(logginglevel.error,'customer :'+customer);
        String jsonstr = JSON.serialize(customer);
        system.debug(logginglevel.error,'jsonstr :'+jsonstr);
        String report =  CreditPullController.pullCreditReport(jsonstr, true,CreditPullAction.PULL_SOURCE_EFXHART);
        system.debug(logginglevel.error,'report :'+report);

        CreditResponse crResp =(CreditResponse)  System.JSON.deserialize(report, CreditResponse.class);
        Set<Id> appIdSet = new Set<Id>();
        
        appIdSet.add(crResp.recordId);

        
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(appIdSet);
        Test.startTest();
        GenerateCreditReportAction creditAction = new GenerateCreditReportAction();
        creditAction.setInput(acInput);
        creditAction.process();
        Test.stopTest();
        
    }
     @isTest static void test_method_contract_EFX() {
        List<fsServ__Lending_Contract__c> testContractsList = [select id from fsServ__Lending_Contract__c limit 1 ];
        System.debug(loggingLevel.ERROR, testContractsList);
        List<CreditPullCustomer>  customer = CreditPullController.getCustomers(testContractsList[0].Id);
        String jsonstr = JSON.serialize(customer);
        String report = CreditPullController.pullCreditReport(jsonstr, true,CreditPullAction.PULL_SOURCE_EFXHART);
        system.debug(logginglevel.error,'report :'+report);
        
        CreditResponse crResp =(CreditResponse)  System.JSON.deserialize(report, CreditResponse.class);
        Set<Id> appIdSet = new Set<Id>();
        
        appIdSet.add(crResp.recordId);
        
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(appIdSet);
        Test.startTest();
        GenerateCreditReportAction creditAction = new GenerateCreditReportAction();
        creditAction.setInput(acInput);
        creditAction.process();
        Test.stopTest();
        
    }

    @isTest static void test_method_App_TU() {
        List<fsCore__Lending_Application__c> testAppsList = [select id from fsCore__Lending_Application__c limit 1 ];
        System.debug(loggingLevel.ERROR, testAppsList);
        List<CreditPullCustomer>  customer = CreditPullController.getCustomers(testAppsList[0].Id);
        String jsonstr = JSON.serialize(customer);
        String report =  CreditPullController.pullCreditReport(jsonstr, true,CreditPullAction.PULL_SOURCE_TUHART);
        system.debug(logginglevel.error,'report :'+report);

        CreditResponse crResp =(CreditResponse)  System.JSON.deserialize(report, CreditResponse.class);
        Set<Id> appIdSet = new Set<Id>();
        
        appIdSet.add(crResp.recordId);

        
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(appIdSet);
        Test.startTest();
        GenerateCreditReportAction creditAction = new GenerateCreditReportAction();
        creditAction.setInput(acInput);
        creditAction.process();
        Test.stopTest();
        
    }
     @isTest static void test_method_contract_TU() {
        List<fsServ__Lending_Contract__c> testContractsList = [select id from fsServ__Lending_Contract__c limit 1 ];
        System.debug(loggingLevel.ERROR, testContractsList);
        List<CreditPullCustomer>  customer = CreditPullController.getCustomers(testContractsList[0].Id);
        String jsonstr = JSON.serialize(customer);
        String report = CreditPullController.pullCreditReport(jsonstr, true,CreditPullAction.PULL_SOURCE_TUHART);
        system.debug(logginglevel.error,'report :'+report);
        
        CreditResponse crResp =(CreditResponse)  System.JSON.deserialize(report, CreditResponse.class);
        Set<Id> appIdSet = new Set<Id>();
        
        appIdSet.add(crResp.recordId);
        
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(appIdSet);
        Test.startTest();
        GenerateCreditReportAction creditAction = new GenerateCreditReportAction();
        creditAction.setInput(acInput);
        creditAction.process();
        Test.stopTest();
        
    }    
    public class CreditResponse{
        public boolean isSuccess;
        public String message;	//The action has been processed successfully.
        public String recordId;
    }

}