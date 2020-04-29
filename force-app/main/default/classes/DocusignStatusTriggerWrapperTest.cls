/*
 * FinancialSpectra Pty Ltd
 * 
 * Class Name   - DocusignStatusTriggerWrapperTest
 *
 * Description  - Test class for DocusignStatusTriggerWrapper
 *
 *
 */
@isTest(seeAllData=false)
private class DocusignStatusTriggerWrapperTest{

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

        testAccount = [select id,personContactId from Account where id = :testAccount.Id];


        
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
    
        //create custom settings
        fsCore.SeedCustomSettings.createCustomSettings(new Set<String>{fsCore.Constants.CUSTOM_SETTING_CUSTOM_NUMBER_FORMAT
                                                              , fsCore.Constants.CUSTOM_SETTING_CALCULATOR_PREFERENCE});
        
        //
        //create contract template (required for PricingOfferAcceptAction)
        //
        fsCore__Payment_Allocation_Method_Setup__c testPaymentAlloc  = [Select id from fsCore__Payment_Allocation_Method_Setup__c limit 1];

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


        //
        //create Lending Application by populating company, branch, product
        //
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplication(testCompany
                                                                              , testBranch
                                                                              , testProduct
                                                                              , 'Test Application');
        testApplication.fsCore__Primary_Customer_Account__c = testAccount.Id;
        testApplication.fsCore__Primary_Customer_Contact__c = testAccount.PersonContactId;
        
        insert testApplication;
        System.assert(testApplication.Id != null, 'Test Lending Application created assert');    
        
        //Create Lending Contract
        
        List<fsServ__Lending_Contract__c> contractList = fsServ.TestQueryHelper.getTestLendingContracts().values();                                                                                                     
        fsServ__Lending_Contract__c testContract = contractList[0];
        testContract.fsServ__Primary_Customer_Account__c = testAccount.Id;
        //testContract.fsServ__Lending_Application_Number__c = testApp.id;
        Database.upsert(testContract);
        
        System.assert(testContract.Id != null, 'Test Lending Contract created assert');
        
        

    
    }
    

    private static dsfs__DocuSign_Status__c createDocusignRecord(String pEnvelopeId, String pDocumentType){

            dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c();
            dsStatus.dsfs__DocuSign_Envelope_ID__c = pEnvelopeId;
            dsStatus.Document_Type__c = pDocumentType;
            dsStatus.dsfs__Envelope_Status__c = 'Sent';

            return  dsStatus;

    }    
    
    @isTest
    private static void testCreateOpportunityApplication(){
        fsCore__Lending_Application__c testApplication = [select id from fsCore__Lending_Application__c limit 1];
        Opportunity opp = [select id from Opportunity limit 1];
        dsfs__DocuSign_Status__c dsStatus = createDocusignRecord('066D6D6B-41ED-49DC-B12A-6870E04B7617',DocusignAPIUtil.mDocumentTypeOppLoanApplication);
        dsStatus.Lending_Application_Name__c = testApplication.id;
        dsStatus.dsfs__Opportunity__c = opp.id;

        insert dsStatus;

    }

    @isTest
    private static void testCreateOpportunityApplicationCompleted(){
        Account testAccount = [select id,personContactId from Account limit 1];
        fsCore__Lending_Application__c testApplication = [select id from fsCore__Lending_Application__c limit 1];
        Opportunity opp = [select id from Opportunity limit 1];
        dsfs__DocuSign_Status__c dsStatus = createDocusignRecord('066D6D6B-41ED-49DC-B12A-6870E04B7617',DocusignAPIUtil.mDocumentTypeOppLoanApplication);
        dsStatus.Lending_Application_Name__c = testApplication.id;
        dsStatus.dsfs__Envelope_Status__c = dsStatus.dsfs__Envelope_Status__c = DocusignAPIUtil.mDocusignEnvelopeCompleted;
        dsStatus.dsfs__Opportunity__c = opp.id;
        dsStatus.dsfs__Completed_Date_Time__c = Date.Today();
        dsStatus.dsfs__Company__c = testAccount.Id;

        insert dsStatus;

    }    

    @isTest
    private static void testUpdateOpportunityApplication(){
        Account testAccount = [select id,personContactId from Account limit 1];
        fsCore__Lending_Application__c testApplication = [select id from fsCore__Lending_Application__c limit 1];
        Opportunity opp = [select id from Opportunity limit 1];
        dsfs__DocuSign_Status__c dsStatus = createDocusignRecord('066D6D6B-41ED-49DC-B12A-6870E04B7617',DocusignAPIUtil.mDocumentTypeOppLoanApplication);
        dsStatus.Lending_Application_Name__c = testApplication.id;
        dsStatus.dsfs__Opportunity__c = opp.id;
        dsStatus.dsfs__Company__c = testAccount.Id;

        insert dsStatus;

        dsStatus.dsfs__Envelope_Status__c = dsStatus.dsfs__Envelope_Status__c = DocusignAPIUtil.mDocusignEnvelopeCompleted;
        dsStatus.dsfs__Completed_Date_Time__c = Date.Today();

        update dsStatus;




    }

    @isTest
    private static void testCreatePreTila(){
        fsCore__Lending_Application__c testApplication = [select id from fsCore__Lending_Application__c limit 1];
        dsfs__DocuSign_Status__c dsStatus = createDocusignRecord('066D6D6B-41ED-49DC-B12A-6870E04B7617',DocusignAPIUtil.mDocumentTypePreTila);
        dsStatus.Lending_Application_Name__c = testApplication.id;

        insert dsStatus;

    }

    @isTest
    private static void testUpdatePreTila(){
        fsCore__Lending_Application__c testApplication = [select id from fsCore__Lending_Application__c limit 1];
        dsfs__DocuSign_Status__c dsStatus = createDocusignRecord('066D6D6B-41ED-49DC-B12A-6870E04B7617',DocusignAPIUtil.mDocumentTypePreTila);
        dsStatus.Lending_Application_Name__c = testApplication.id;

        insert dsStatus;

        dsStatus.dsfs__Envelope_Status__c = dsStatus.dsfs__Envelope_Status__c = DocusignAPIUtil.mDocusignEnvelopeCompleted;

        update dsStatus;
    }

     @isTest
    private static void testBankAccountChange(){
       
        fsCore__Assignment_Template_Setup__c templateSetup = new fsCore__Assignment_Template_Setup__c();
        templateSetup.fsCore__Assignment_Template_Code__c = 'DNL_CONTRACT_BANK_ACCOUNT_CHANGE_REQUEST';
        templateSetup.fsCore__Line_Of_Business__c = 'Servicing';
        templateSetup.fsCore__Parent_Object__c = 'fsServ__Lending_Contract__c'; 
        insert templateSetup;
        fsServ__Lending_Contract__c testContract = [select id , fsServ__Primary_Customer_Account__c, fsServ__Primary_Customer_Contact__c, fsServ__Primary_Customer_Contact__r.AccountId from fsServ__Lending_Contract__c limit 1];
        Account acc = [Select id from Account where id =:testContract.fsServ__Primary_Customer_Account__c];
        Contact cont = [Select AccountId from Contact where id=:testContract.fsServ__Primary_Customer_Contact__c];
        cont.AccountId = testContract.fsServ__Primary_Customer_Contact__r.AccountId;
        update cont;
        
        
        System.debug(loggingLevel.ERROR, testContract.fsServ__Primary_Customer_Contact__r.AccountId);
        System.debug(loggingLevel.ERROR, cont.AccountId);
        System.debug(loggingLevel.ERROR, testContract.fsServ__Primary_Customer_Contact__c);
        
        fsCore__Assignment__c assignment = new fsCore__Assignment__c();
        assignment.Bank_Account_Name__c = 'Bank account Name';
        assignment.Bank_Account_Number__c = '123456';
        assignment.Bank_Name__c = 'Bank Name';
        assignment.Account_Holder_Name__c = 'Account Holder Name';
        assignment.Routing_number__c = '56789';
        assignment.Account_type__c = 'Saving';
        assignment.Address_Street__c = 'street';
        assignment.Address_City__c = 'city';
        assignment.Address_State__c = 'state';
        assignment.Address_Zip_Code__c = 'code';
        assignment.fsCore__Assignment_Template_Code__c = 'DNL_CONTRACT_BANK_ACCOUNT_CHANGE_REQUEST';
        assignment.fsCore__Status__c = 'Completed';
        assignment.fsServ__Lending_Contract_Number__c = testContract.id;
        assignment.fsCore__Account_Name__c = testContract.fsServ__Primary_Customer_Contact__r.AccountId;
        assignment.fsCore__Contact_Name__c = testContract.fsServ__Primary_Customer_Contact__c;
        
        insert assignment;
        dsfs__DocuSign_Status__c dsStatus = createDocusignRecord('066D6D6B-41ED-49DC-B12A-6870E04B7617',DocusignAPIUtil.mDocumentTypeBankAccountChange);
        dsStatus.Assignment_Name__c = assignment.id;
        insert dsStatus;

        dsStatus.dsfs__Envelope_Status__c = dsStatus.dsfs__Envelope_Status__c = DocusignAPIUtil.mDocusignEnvelopeCompleted;

        update dsStatus;
    }
         @isTest
    private static void testBankAccountChange2(){
       
        fsCore__Assignment_Template_Setup__c templateSetup = new fsCore__Assignment_Template_Setup__c();
        templateSetup.fsCore__Assignment_Template_Code__c = 'DNL_CONTRACT_BANK_ACCOUNT_CHANGE_REQUEST';
        templateSetup.fsCore__Line_Of_Business__c = 'Servicing';
        templateSetup.fsCore__Parent_Object__c = 'fsServ__Lending_Contract__c'; 
        insert templateSetup;
        fsServ__Lending_Contract__c testContract = [select id from fsServ__Lending_Contract__c limit 1];
        fsCore__Assignment__c assignment = new fsCore__Assignment__c();
        assignment.Bank_Account_Name__c = 'Bank account Name';
        assignment.Bank_Account_Number__c = '123456';
        assignment.Bank_Name__c = 'Bank Name';
        assignment.Account_Holder_Name__c = 'Account Holder Name';
        assignment.Routing_number__c = '56789';
        assignment.Account_type__c = 'Saving';
        assignment.Address_Street__c = 'street';
        assignment.Address_City__c = 'city';
        assignment.Address_State__c = 'state';
        assignment.Address_Zip_Code__c = 'code';
        assignment.fsCore__Assignment_Template_Code__c = 'DNL_CONTRACT_BANK_ACCOUNT_CHANGE_REQUEST';
        assignment.fsServ__Lending_Contract_Number__c = testContract.id;
        insert assignment;
        dsfs__DocuSign_Status__c dsStatus = createDocusignRecord('066D6D6B-41ED-49DC-B12A-6870E04B7617',DocusignAPIUtil.mDocumentTypeBankAccountChange);
        dsStatus.Assignment_Name__c = assignment.id;
        insert dsStatus;

        dsStatus.dsfs__Envelope_Status__c = dsStatus.dsfs__Envelope_Status__c = DocusignAPIUtil.mDocusignEnvelopeSent;

        update dsStatus;
    }
 }