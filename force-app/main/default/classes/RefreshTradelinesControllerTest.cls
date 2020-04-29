/*
 * Class Name   - RefreshTradelinesControllerTest 
 * Description  - Test class for RefreshTradelinesController
 */
@isTest(seeAllData=false)
public class RefreshTradelinesControllerTest {
    @testSetup
    static void createTestData(){
        
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

        //Account and Contact for customer
        Account testAccount = TestHelperData.createAccount();
        insert testAccount;
        System.assert(testAccount.Id != null, 'Test Account created assert');



        fsCore__Financial__c finn_2 = fsCore.TestHelperMaster.getTestFinancial(testAccount.Id, null, 'Income', 'Rental', 500);
        fsCore__Financial__c finn_3 = fsCore.TestHelperMaster.getTestFinancial(testAccount.Id, null, 'Income', 'Investment', 5000);
        fsCore__Financial__c finn_4 = fsCore.TestHelperMaster.getTestFinancial(testAccount.Id, null, 'Income', 'Social Security', 250);
        finn_4.start_date__c = Date.Today().addDays(-100);
        fsCore__Financial__c finn_5 = fsCore.TestHelperMaster.getTestFinancial(testAccount.Id, null, 'Income', 'Disability', 250);
        List<fsCore__Financial__c> financialList = new List<fsCore__Financial__c>{finn_2,finn_3,finn_4,finn_5};
        fsCore.DMLResult finnSaveRslt = fsCore.FinancialDMLWrapper.getInstance().insertData(financialList);
        
        System.assert(!finnSaveRslt.hasErrors());



        //
        //create Lending Application by populating company, branch, product
        //
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplication(testCompany
                                                                              , testBranch
                                                                              , testProduct
                                                                              , 'Test Application');
        testApplication.fsCore__Primary_Customer_Account__c = testAccount.Id;
        
        insert testApplication;
        System.assert(testApplication.Id != null, 'Test Lending Application created assert');      

        //create applications checklists
        List<fsCore__Lending_Application_Checklist__c> testAppChklistItems = fsCore.TestHelperLendingApplication.getTestApplicationChecklists(testApplication, testChecklistItems);
        fsCore.DMLResult chkItemsSaveRslt = fsCore.LendingApplicationChecklistDMLWrapper.getInstance().insertData(testAppChklistItems);
        System.assert(!chkItemsSaveRslt.hasErrors(), 'Test application checklist created assert');
        System.assertEquals(2, chkItemsSaveRslt.getSuccessRecordSet().size(), '2 application checklist created');


    } @isTest
     private static void testUpdateRefreashTradelines(){

        List<fsCore__Lending_Application__c> applicationList = TestHelperData.getTestLendingApplications().values();
     
        fsCore.DMLResult saveRslt = fsCore.LendingApplicationDMLWrapper.getInstance().upsertData(applicationList);
        Set<Id> applicationIds = saveRslt.getSuccessRecordSet();
       
        List<Id> appIdList = new List<Id>(applicationIds);
        Test.startTest();
         RefreshTradelinesController.refreshDataFromNuDebt(appIdList[0]);
          Test.stopTest();
         }  
 
}