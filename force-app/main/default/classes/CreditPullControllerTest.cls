/**
 * @File Name          : CreditPullControllerTest.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 8/26/2019, 9:50:02 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    8/26/2019, 9:47:58 PM   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
private class CreditPullControllerTest {
    
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
    
    @isTest static void test_method_pullCreditAttribs() {
        Test.startTest();
        CreditPullAttributes pullAttribs = CreditPullController.getPullTypeAttributes();
        Test.stopTest();
        System.assertNotEquals(null, pullAttribs);
        System.assertEquals('Soft', pullAttribs.defaultPullType);
    }

    @isTest static void test_method_pullCredit() {
        List<fsCore__Lending_Application__c> testAppsList = [select id from fsCore__Lending_Application__c];
        System.debug(loggingLevel.ERROR, testAppsList);
        List<CreditPullCustomer>  customer = CreditPullController.getCustomers(testAppsList[0].Id);
        
        String jsonstr = JSON.serialize(customer);
        
        String report =  CreditPullController.pullCreditReport(jsonstr, true,CreditPullAction.PULL_SOURCE_EFXHART);
        CreditAnalysisController.analyzeCreditReport(testAppsList[0].Id);
        CreditAnalysisController.getCreditReportInfo(testAppsList[0].Id);
    }

    @isTest static void test_method_nullPersonStreet() {
        List<fsCore__Lending_Application__c> testAppsList = [select id from fsCore__Lending_Application__c];
        System.debug(loggingLevel.ERROR, testAppsList);
        
        try{
        List<CreditPullCustomer>  customer = CreditPullController.getCustomers(testAppsList[0].Id);
        
        Account acc = new Account();
        acc.id = customer[0].customer_account_id;
        acc.PersonOtherStreet = null;

        update acc;


        String jsonstr = JSON.serialize(customer);
        
        String report =  CreditPullController.pullCreditReport(jsonstr, true,CreditPullAction.PULL_SOURCE_EFXHART);
        
        }catch(Exception e){
            //DO NOTHING
        }
    }

    @isTest static void test_method_nullPersonCity() {
        List<fsCore__Lending_Application__c> testAppsList = [select id from fsCore__Lending_Application__c];
        System.debug(loggingLevel.ERROR, testAppsList);
        
        try{
        List<CreditPullCustomer>  customer = CreditPullController.getCustomers(testAppsList[0].Id);
        
        Account acc = new Account();
        acc.id = customer[0].customer_account_id;
        acc.PersonOtherCity = null;

        update acc;


        String jsonstr = JSON.serialize(customer);
        
        String report =  CreditPullController.pullCreditReport(jsonstr, true,CreditPullAction.PULL_SOURCE_EFXHART);
        
        }catch(Exception e){
            //DO NOTHING
        }
    }   

    @isTest static void test_method_nullPersonStateCode() {
        List<fsCore__Lending_Application__c> testAppsList = [select id from fsCore__Lending_Application__c];
        System.debug(loggingLevel.ERROR, testAppsList);
        
        try{
        List<CreditPullCustomer>  customer = CreditPullController.getCustomers(testAppsList[0].Id);
        
        Account acc = new Account();
        acc.id = customer[0].customer_account_id;
        acc.PersonOtherStateCode = null;

        update acc;


        String jsonstr = JSON.serialize(customer);
        
        String report =  CreditPullController.pullCreditReport(jsonstr, true,CreditPullAction.PULL_SOURCE_EFXHART);
        
        }catch(Exception e){
            //DO NOTHING
        }
    }  


    @isTest static void test_method_nullPersonPostalCode() {
        List<fsCore__Lending_Application__c> testAppsList = [select id from fsCore__Lending_Application__c];
        System.debug(loggingLevel.ERROR, testAppsList);
        
        try{
        List<CreditPullCustomer>  customer = CreditPullController.getCustomers(testAppsList[0].Id);
        
        Account acc = new Account();
        acc.id = customer[0].customer_account_id;
        acc.PersonOtherPostalCode = null;

        update acc;


        String jsonstr = JSON.serialize(customer);
        
        String report =  CreditPullController.pullCreditReport(jsonstr, true,CreditPullAction.PULL_SOURCE_EFXHART);
        
        }catch(Exception e){
            //DO NOTHING
        }
    }  

    @isTest static void test_method_nullPersonBirthDate() {
        List<fsCore__Lending_Application__c> testAppsList = [select id from fsCore__Lending_Application__c];
        System.debug(loggingLevel.ERROR, testAppsList);
        
        try{
        List<CreditPullCustomer>  customer = CreditPullController.getCustomers(testAppsList[0].Id);
        
        Account acc = new Account();
        acc.id = customer[0].customer_account_id;
        acc.PersonBirthdate = null;

        update acc;


        String jsonstr = JSON.serialize(customer);
        
        String report =  CreditPullController.pullCreditReport(jsonstr, true,CreditPullAction.PULL_SOURCE_EFXHART);
        
        }catch(Exception e){
            //DO NOTHING
        }
    }                    
    
    @isTest static void test_method_two() {
        List<fsCore__Lending_Application__c> testAppsList = [select id from fsCore__Lending_Application__c];
        List<CreditPullCustomer>  customer = CreditPullController.getCustomers(testAppsList[0].Id);
        
        String jsonstr = JSON.serialize(customer);
        //List<Credit_Pull_Report__c> testreport = CreditPullController.pullCreditReport(jsonstr, true);

        
        String testreport =  CreditPullController.pullCreditReport(jsonstr, true,CreditPullAction.PULL_SOURCE_EFXHART);
        GenerateCreditReportActionTest.CreditResponse crResp =(GenerateCreditReportActionTest.CreditResponse)  System.JSON.deserialize(testreport, GenerateCreditReportActionTest.CreditResponse.class);

        //string jsonstrrep=JSON.serialize(testreport);

        String report = CreditPullController.generateReportPDF(crResp.recordId);
        
    }
    
        
    
    @isTest static void test_method_pullCreditForContract() {
        List<fsServ__Lending_Contract__c> testContractsList = [select id from fsServ__Lending_Contract__c];
        System.debug(loggingLevel.ERROR, testContractsList);
        List<CreditPullCustomer>  customer = CreditPullController.getCustomers(testContractsList[0].Id);
        
        String jsonstr = JSON.serialize(customer);
        
        //List<Credit_Pull_Report__c> report = CreditPullController.pullCreditReport(jsonstr, true);
        String testreport =  CreditPullController.pullCreditReport(jsonstr, true,CreditPullAction.PULL_SOURCE_EFXHART);
        CreditAnalysisController.analyzeCreditReport(testContractsList[0].Id);
        CreditAnalysisController.getCreditReportInfo(testContractsList[0].Id);
    }

    @isTest static void test_method_nullPersonStreetForContract() {
       List<fsServ__Lending_Contract__c> testContractsList = [select id from fsServ__Lending_Contract__c];
        System.debug(loggingLevel.ERROR, testContractsList);
        
        try{
        List<CreditPullCustomer>  customer = CreditPullController.getCustomers(testContractsList[0].Id);
        
        Account acc = new Account();
        acc.id = customer[0].customer_account_id;
        acc.PersonOtherStreet = null;

        update acc;


        String jsonstr = JSON.serialize(customer);
        
        //List<Credit_Pull_Report__c> report = CreditPullController.pullCreditReport(jsonstr, true);
        String testreport =  CreditPullController.pullCreditReport(jsonstr, true,CreditPullAction.PULL_SOURCE_EFXHART);
        
        }catch(Exception e){
            //DO NOTHING
        }
    }

    @isTest static void test_method_nullPersonCityForContract() {
        List<fsServ__Lending_Contract__c> testContractsList = [select id from fsServ__Lending_Contract__c];
        System.debug(loggingLevel.ERROR, testContractsList);
        
        try{
        List<CreditPullCustomer>  customer = CreditPullController.getCustomers(testContractsList[0].Id);
        
        Account acc = new Account();
        acc.id = customer[0].customer_account_id;
        acc.PersonOtherCity = null;

        update acc;


        String jsonstr = JSON.serialize(customer);
        
        //List<Credit_Pull_Report__c> report = CreditPullController.pullCreditReport(jsonstr, true);
        String testreport =  CreditPullController.pullCreditReport(jsonstr, true,CreditPullAction.PULL_SOURCE_EFXHART);
        
        }catch(Exception e){
            //DO NOTHING
        }
    }   

    @isTest static void test_method_nullPersonStateCodeForContract() {
        List<fsServ__Lending_Contract__c> testContractsList = [select id from fsServ__Lending_Contract__c];
        System.debug(loggingLevel.ERROR, testContractsList);
        
        try{
        List<CreditPullCustomer>  customer = CreditPullController.getCustomers(testContractsList[0].Id);
        
        Account acc = new Account();
        acc.id = customer[0].customer_account_id;
        acc.PersonOtherStateCode = null;

        update acc;


        String jsonstr = JSON.serialize(customer);
        
        //List<Credit_Pull_Report__c> report = CreditPullController.pullCreditReport(jsonstr, true);
        String testreport =  CreditPullController.pullCreditReport(jsonstr, true,CreditPullAction.PULL_SOURCE_EFXHART);
        
        }catch(Exception e){
            //DO NOTHING
        }
    }  


    @isTest static void test_method_nullPersonPostalCodeForContract() {
        List<fsServ__Lending_Contract__c> testContractsList = [select id from fsServ__Lending_Contract__c];
        System.debug(loggingLevel.ERROR, testContractsList);
        
        try{
        List<CreditPullCustomer>  customer = CreditPullController.getCustomers(testContractsList[0].Id);
        
        Account acc = new Account();
        acc.id = customer[0].customer_account_id;
        acc.PersonOtherPostalCode = null;

        update acc;


        String jsonstr = JSON.serialize(customer);
        
        //List<Credit_Pull_Report__c> report = CreditPullController.pullCreditReport(jsonstr, true);
        String testreport =  CreditPullController.pullCreditReport(jsonstr, true,CreditPullAction.PULL_SOURCE_EFXHART);
        
        }catch(Exception e){
            //DO NOTHING
        }
    }  

    @isTest static void test_method_nullPersonBirthDateForContract() {
        List<fsServ__Lending_Contract__c> testContractsList = [select id from fsServ__Lending_Contract__c];
        System.debug(loggingLevel.ERROR, testContractsList);
        try{
        List<CreditPullCustomer>  customer = CreditPullController.getCustomers(testContractsList[0].Id);
        
        Account acc = new Account();
        acc.id = customer[0].customer_account_id;
        acc.PersonBirthdate = null;

        update acc;


        String jsonstr = JSON.serialize(customer);
        
        //List<Credit_Pull_Report__c> report = CreditPullController.pullCreditReport(jsonstr, true);
        String testreport =  CreditPullController.pullCreditReport(jsonstr, true,CreditPullAction.PULL_SOURCE_EFXHART);
        
        }catch(Exception e){
            //DO NOTHING
        }
    }                    
    
    @isTest static void test_method_twoForContract() {
       List<fsServ__Lending_Contract__c> testContractsList = [select id from fsServ__Lending_Contract__c];
        List<CreditPullCustomer>  customer = CreditPullController.getCustomers(testContractsList[0].Id);
        
        String jsonstr = JSON.serialize(customer);
        //List<Credit_Pull_Report__c> testreport = CreditPullController.pullCreditReport(jsonstr, true);
        String testreport =  CreditPullController.pullCreditReport(jsonstr, true,CreditPullAction.PULL_SOURCE_EFXHART);
        GenerateCreditReportActionTest.CreditResponse crResp =(GenerateCreditReportActionTest.CreditResponse)  System.JSON.deserialize(testreport, GenerateCreditReportActionTest.CreditResponse.class);
        //string jsonstrrep=JSON.serialize(testreport);

        String report = CreditPullController.generateReportPDF(crResp.recordId);
        
    }
    
    
    
    
    
    
}