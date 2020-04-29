@isTest
public class EmailNotificationActionControllerTest {
    
    @isTest
    static void TestData(){
        TestHelperData.createTriggerExecutionTestData();
        
        //create custom settings
        fsCore.SeedCustomSettings.createCustomSettings(new Set<String>{fsCore.Constants.CUSTOM_SETTING_CUSTOM_NUMBER_FORMAT
            , fsCore.Constants.CUSTOM_SETTING_CALCULATOR_PREFERENCE});
        
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
        
        //TODO PLEASE CREATE ONE MORE PRODUCT. THIS TEST NEEDS TO WORK ON BOTH PL & DNL
        //testProduct.fsCore__Customer_Type__c = 'Person Account';
        //testProduct.fsCore__Active_Application_Record_Type__c = 'VCL_Loan';
        //testProduct.fsServ__Active_Contract_Record_Type__c = 'VCL_Active_Contract';        
        //testProduct.Credit_Pull_Report_Record_Type_Name__c ='VCL';        
        
        insert testProduct;
        System.assert(testProduct.Id != null, 'Test product created assert');        
        
        
        //create checklist
        fsCore__Checklist_Setup__c  testChecklist = fsCore.TestHelperProduct.getTestChecklistSetup('Test Checklist'
                                                                                                   , fsCore.Constants.LOB_ORIGINATION
                                                                                                   , UserInfo.getUserId()
                                                                                                   , 1);
        insert testChecklist;
        System.assert(testChecklist.Id != null, 'Test checklist created assert');
        
        List<fsCore__Checklist_Detail_Setup__c> testChecklistItems = new List<fsCore__Checklist_Detail_Setup__c>();
        
        testChecklistItems.add(fsCore.TestHelperProduct.getTestDocumentChecklistItem(testChecklist.Id,'Text','Bank Statement'));
        testChecklistItems.add(fsCore.TestHelperProduct.getTestDocumentChecklistItem(testChecklist.Id,'Text','Tax Document'));
        insert testChecklistItems;        
        
        //
        //create contract template (required for PricingOfferAcceptAction)
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
        
        //Account and Contact for customer
        Account testAccount = TestHelperData.createAccount();
        insert testAccount;
        System.assert(testAccount.Id != null, 'Test Account created assert');
        
        
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplication(testCompany
                                                                                                                , testBranch
                                                                                                                , testProduct
                                                                                                                , 'Test Application');
        testApplication.fsCore__Primary_Customer_Account__c = testAccount.Id;
        insert testApplication;
        System.assert(testApplication.Id != null, 'Test Lending Application created assert');      
        
        
        Email_Notification_Log__c email = new Email_Notification_Log__c(Lending_Application_Number__c = testApplication.id);
        insert email;
        EmailNotificationActionController.reSendEmail(email.id);
    }
}