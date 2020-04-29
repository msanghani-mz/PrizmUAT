/**
 * Class Name  : AppCreationTest
 * Description : This class has test method for opportunity
 * Author      : Financial Spectra
 *
 */

 /*
     * Method to create a 1000 Lending Application with all related data
     * in following objects
     */ 
@isTest
private class AppCreationTest {
    
    @testSetup
    private static void testBulkAppCreation(){
        //create custom settings
        fsCore.SeedCustomSettings.createCustomSettings(new Set<String>{fsCore.Constants.CUSTOM_SETTING_CUSTOM_NUMBER_FORMAT});
        TestHelperData.createTriggerExecutionTestData();
        //create company and branch
        fsCore__Company_Setup__c testCompany = fsCore.TestHelperCompany.getTestCompanySetup('Test Company', 'TESTCO', '123456789');
        insert testCompany;
        System.assert(testCompany.Id != null, 'Test company created assert');        
            
        fsCore__Branch_Setup__c testBranch = fsCore.TestHelperCompany.getTestBranchSetup('Test Branch', 'TBRCH', testCompany.Id, null, null);
        insert testBranch;
        System.assert(testBranch.Id != null, 'Test branch created assert');        

        //
        //create product
        //
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
    
        //create Account
        Account testAccount = TestHelperData.createAccount();
        Database.insert(testAccount);
        System.assert(testAccount.Id != null, 'Test Account created assert');


        //
        //create Lending Applications by populating company, branch, product, contract template
        //
        Test.startTest();
        integer numberofApp  = 10;
        List<fsCore__Lending_Application__c> testAppsList = fsCore.TestHelperLendingApplication.getTestApplicationBulk(testCompany
                                                                              , testBranch
                                                                              , testProduct
                                                                              , testContractTemplate
                                                                              , numberofApp);
        for (fsCore__Lending_Application__c apps: testAppsList){
            apps.fsCore__Primary_Customer_Account__c = testAccount.Id;
        }

        fsCore.DMLResult saveRslt = fsCore.LendingApplicationDMLWrapper.getInstance().insertData(testAppsList);
        Test.stopTest();
        if (saveRslt.hasErrors()) { 
            system.debug(logginglevel.error,saveRslt.getErrorList());
        }
        
        System.assertEquals(numberofApp, saveRslt.getSuccessRecordList().size());
    }

    @isTest
    static void testApplicationCreation(){
    }
    
}