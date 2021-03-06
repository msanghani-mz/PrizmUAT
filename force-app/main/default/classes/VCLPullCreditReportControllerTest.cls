/*
 * Class   : VCLPullCreditReportControllerTest
 * Purpose : This is a test class for VCLPullCreditReportControllerTest and GetCreditReportAction
 * Author  : Financial Spectra
 */
@isTest
private class VCLPullCreditReportControllerTest {
 
    @testSetup
    private static void createTestData(){
        fsCore.SeedCustomSettings.createCustomSettings(new Set<String>{fsCore.Constants.CUSTOM_SETTING_CUSTOM_NUMBER_FORMAT});
        
        //Create Company and Branch
        fscore__Company_Setup__c testCompany = fsCore.TestHelperCompany.getTestCompanySetup('Test Company', 'TESTCO', '123456789');
        insert testCompany;
        System.assert(testCompany.Id != null, 'Test company created assert');  
        
        fsCore__Branch_Setup__c testBranch = fsCore.TestHelperCompany.getTestBranchSetup('Test Branch', 'TBRCH', testCompany.Id, null, null);
        insert testBranch;
        System.assert(testBranch.Id != null, 'Test branch created assert');
  
        //Create Product
        fsCore__Product_Setup__c testProduct = fsCore.TestHelperProduct.getTestProductSetup('Test Product'
                                                                                            , 'PL'
                                                                                            , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                                            , fsCore.Constants.CYCLE_MONTHLY
                                                                                            , 1);
        testProduct.fsCore__Customer_Name_Format__c='Account Only';
        testProduct.fsCore__Customer_Type__c= 'Account';
        testProduct.Credit_Pull_Report_Record_Type_Name__c ='VCL';
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

        
        //Create Lending Application
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                                            , testBranch
                                                                                                                            , testProduct
                                                                                                                            , testContractTemplate
                                                                                                                            , 'Test Application');
       
        Id recTypeId = Schema.SObjectType.fsCore__Lending_Application__c.getRecordTypeInfosByDeveloperName().get('VCL_Loan').getRecordTypeId();
        testApplication.RecordTypeId = recTypeId;
        testApplication.Velocify_ID__c = '1773';
        testApplication.BoxFolderId__c = '1235';
        insert testApplication;
        System.assert(testApplication.Id != null, 'Test Lending Application created assert');
        
        // create account
        List<Account> accountlist = new List<Account>();
        Account nAccount = TestHelperData.createAccount();
       // Account coAppAccount = TestHelperData.createAccount('TEST','LASTNAME');
        accountlist.add(nAccount);
      //  accountlist.add(coAppAccount);
        Database.insert(accountlist);
        
        System.assert(nAccount.Id != null, 'Test Account created assert');
        
        List<Account> testAccountList = [select id, personcontactId from Account where id in (:nAccount.id)];//,:coAppAccount.Id) ];
        
        Account testAccount = testAccountList[0];
       // Account testCoAccount = testAccountList[1];
        system.debug(logginglevel.error,'testAccount.personcontactId :'+testAccount.personcontactId);
     
      
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
        
        
        

    } 
    @isTest
    private static void testVCLPullCreditReport(){
        fsCore__Lending_Application__c testApp = [Select Id from fsCore__Lending_Application__c Limit 1];
        Test.startTest();
       // VCLPullCreditReportController vclController = new VCLPullCreditReportController();
        String creditReport = VCLPullCreditReportController.fetchCreditReport(testApp.Id);
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(creditReport);
        String creditReportId = String.ValueOf(jsonMap.get('recordId'));
        String creditReportPDF = VCLPullCreditReportController.generateReportPDF(creditReportId);
        Test.stopTest();
        System.assertNotEquals(null, creditReport);
        System.assertNotEquals(null, creditReportPDF);
    }
}