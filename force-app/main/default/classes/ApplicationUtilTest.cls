/**
 * Class Name  : ApplicationUtilTest
 * Description : This class has test method for ApplicationUtil
 * Author      : Financial Spectra
 *
 */
@isTest
private class ApplicationUtilTest{
    @testSetup
    static void createTestData(){
        //create layouts
        //createCustomLayouts();

        TestHelperData.createTriggerExecutionTestData();

        //create custom settings
        fsCore.SeedCustomSettings.createCustomSettings(new Set<String>{fsCore.Constants.CUSTOM_SETTING_CUSTOM_NUMBER_FORMAT
                                                              , fsCore.Constants.CUSTOM_SETTING_CALCULATOR_PREFERENCE});
        
        //create company and branch
        fscore__Company_Setup__c testCompany = fsCore.TestHelperCompany.getTestCompanySetup('Test Company', 'TESTCO', '123456789');
        insert testCompany;
        System.assert(testCompany.Id != null, 'Test company created assert');        
            
        fsCore__Branch_Setup__c testBranch = fsCore.TestHelperCompany.getTestBranchSetup('Test Branch', 'TBRCH', testCompany.Id, null, null);
        insert testBranch;
        System.assert(testBranch.Id != null, 'Test branch created assert');        
        
        //
        //create balance, transaction and itemization setup
        //
        Map<String, fsCore__Balance_Setup__c> testBalanceSetupMap = fsCore.TestHelperFinancial.getTestBalanceSetupMap();
        System.assert(testBalanceSetupMap.size() > 0, 'Test Balance setup created assert');        

        Map<String, fsCore__Transaction_Setup__c> testTxnSetupMap = fsCore.TestHelperFinancial.getTestTransactionSetupMap();
        System.assert(testTxnSetupMap.size() > 0, 'Test Transaction setup created assert');        

        Map<String, fsCore__Itemization_Setup__c> testItmzSetupMap = fsCore.TestHelperFinancial.getTestItemizationSetupMap();
        System.assert(testItmzSetupMap.size() > 0, 'Test Itemization setup created assert');        

        //create Checklist Setup
        List<fsCore__Checklist_Setup__c> testCheckList = TestHelperData.createcheckList();
        insert testCheckList;

        //create Checklist Detail Setup
        List<fsCore__Checklist_Detail_Setup__c> testChecklistDetailSetUp = TestHelperData.createcheckListDetail(testCheckList);
        insert testChecklistDetailSetUp;

        //
        //create product
        //
        fsCore__Product_Setup__c testProduct = fsCore.TestHelperProduct.getTestProductSetup('Test Product'
                                                                            , 'DNL'
                                                                            , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                            , fsCore.Constants.CYCLE_MONTHLY
                                                                            , 1);
        testProduct.Credit_Pull_Report_Record_Type_Name__c='DNL';
        testProduct.fsCore__Customer_Type__c = 'Person Account';
        testProduct.fsCore__Active_Application_Record_Type__c = 'DNL_Loan';
        testProduct.fsServ__Active_Contract_Record_Type__c = 'DNL_Active_Contract';        
        
        insert testProduct;
        System.assert(testProduct.Id != null, 'Test product created assert');        
 
        //
        //create product itemizations
        // 1 + Funds to Customer
        // 2 - Down Payment
        //
        List<fsCore__Product_Itemization_Setup__c> testProductItzms = new List<fsCore__Product_Itemization_Setup__c>();
        testProductItzms.add(fsCore.TestHelperProduct.getTestProductItemizationSetup(testProduct.Id
                                                                            , testItmzSetupMap.get('Funds to Customer')
                                                                            , 'Yes'
                                                                            , 1, fsCore.Constants.PLUS));
        testProductItzms.add(fsCore.TestHelperProduct.getTestProductItemizationSetup(testProduct.Id
                                                                            , testItmzSetupMap.get('Down Payment')
                                                                            , 'No'
                                                                            , 2, fsCore.Constants.MINUS));
        insert testProductItzms;
        System.assert(testProductItzms.size() > 0, 'Test product itemizations created assert');        

        //
        //create contract template
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
        //
        //create Lending Application by populating company, branch, product
        //
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                              , testBranch
                                                                              , testProduct
                                                                              , testContractTemplate
                                                                              , 'Test Application');
        insert testApplication;
        System.assert(testApplication.Id != null, 'Test Lending Application created assert');        

        //create Lending Application Customer Secondary
        fsCore__Lending_Application_Customer__c  testAppCustomer1 = fsCore.TestHelperLendingApplication.getTestCustomer(testApplication
                                                                                            ,testAccount.Id
                                                                                            ,testAccount.PersonContactId
                                                                                            ,'Primary');
        insert testAppCustomer1;
        System.assert(testAppCustomer1.Id != null, 'Test Lending Application Customer1 created assert');

        fsCore__Lending_Application_Customer__c  testAppCustomer2 = fsCore.TestHelperLendingApplication.getTestCustomer(testApplication
                                                                                            ,testAccount.Id
                                                                                            ,testAccount.PersonContactId
                                                                                            ,'Secondary');
        insert testAppCustomer2;
        System.assert(testAppCustomer2.Id != null, 'Test Lending Application Customer2 created assert');


        //create application checklist
        List<fsCore__Lending_Application_Checklist__c> testAppChklistItems = fsCore.TestHelperLendingApplication.getTestApplicationChecklists(testApplication, testChecklistDetailSetUp);
        insert testAppChklistItems;


        //
        //create Lending Application itemizations
        //
        List<fsCore__Lending_Application_Itemization__c> testAppItemizations = fsCore.TestHelperLendingApplication.getTestApplicationItemizations(
                                                                                                      testApplication
                                                                                                    , testProductItzms);
        integer counter = 1;
        for (fsCore__Lending_Application_Itemization__c itm :testAppItemizations){
            if (counter == 1){
                itm.Current_Creditor__c = 'TTE';
                itm.Original_Creditor__c = 'TTE';
            }
        }
        
        insert testAppItemizations;
        System.assert(testAppItemizations.size() > 0, 'Test Lending Application itemizations created assert');        

    }
     @isTest
     private static void testApplicationUtil(){
        List<fsCore__Lending_Application__c> testApp = [select Id from fsCore__Lending_Application__c] ;
          Set<Id> lendingAppIdSet = new Set<Id>();
        for (fsCore__Lending_Application__c lendingAppId: testApp){
            lendingAppIdSet.add(lendingAppId.Id);
        }
        Test.startTest();
        ApplicationUtil.generateApplicationRecordTitle(lendingAppIdSet);
        Test.stopTest();
        
         }

}