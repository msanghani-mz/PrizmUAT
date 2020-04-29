/*
 * Class Name   - VCLChangeStatusServiceTest
 * Description  - Test class for VCLChangeStatusService
 * Developer(s) - Financial Spectra
 */
@isTest
private class VCLChangeStatusServiceTest{

    @testSetup static void createTestData(){
        //Create Company and Branch
        fscore__Company_Setup__c testCompany = fsCore.TestHelperCompany.getTestCompanySetup('Test Company', 'TESTCO', '123456789');
        insert testCompany;
        System.assert(testCompany.Id != null, 'Test company created assert');  
        
        fsCore__Branch_Setup__c testBranch = fsCore.TestHelperCompany.getTestBranchSetup('Test Branch', 'TBRCH', testCompany.Id, null, null);
        insert testBranch;
        System.assert(testBranch.Id != null, 'Test branch created assert');
        
        //Create Product
        fsCore__Product_Setup__c testProduct = fsCore.TestHelperProduct.getTestProductSetup('VCL', 'VCL'
                                                                                            , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                                            , fsCore.Constants.CYCLE_MONTHLY
                                                                                            , 1);
        testProduct.Credit_Pull_Report_Record_Type_Name__c ='VCL';
        testProduct.fsCore__Active_Application_Record_Type__c = 'VCL_Loan';
        insert testProduct;
        System.assert(testProduct.Id != null, 'Test product created assert');   
        
        //Create Lending Application
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplication(testCompany
                                                                                                              , testBranch
                                                                                                              , testProduct
                                                                                                              , 'Test Application');
        testApplication.Loan_Type__c = 'VCL'; 
        insert testApplication;
        System.assert(testApplication.Id != null, 'Test Lending Application created assert'); 
    }
    
    @isTest
    private static void testDeclinedStatusChange(){
        fsCore__Lending_Application__c app = [SELECT Id, fsCore__Application_Status__c 
                                                FROM fsCore__Lending_Application__c
                                               WHERE fsCore__Title__c = 'Test Application'
                                               LIMIT 1];
        Test.startTest();
        
        Test.stopTest();
    }

    @isTest
    private static void testWithdrawnStatusChange(){
        fsCore__Lending_Application__c app = [SELECT Id, fsCore__Application_Status__c 
                                                FROM fsCore__Lending_Application__c
                                               WHERE fsCore__Title__c = 'Test Application'
                                               LIMIT 1];
        Test.startTest();
        
        Test.stopTest();
    }

    @isTest
    private static void testIssuedStatusChange(){
        fsCore__Lending_Application__c app = [SELECT Id, fsCore__Application_Status__c 
                                                FROM fsCore__Lending_Application__c
                                               WHERE fsCore__Title__c = 'Test Application'
                                               LIMIT 1];
        Test.startTest();
        VCLChangeStatusService srvc = new VCLChangeStatusService(app.Id);
        srvc.invoke();
        Test.stopTest();
        
        System.assertNotEquals(null, srvc.getResponse());
        System.assertEquals(200, srvc.getResponse().getStatusCode());
    }

}