/**
 * @File Name          : RejectionActionControllerTest.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 4/7/2020, 9:59:27 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/7/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
public class RejectionActionControllerTest {
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
        finn_4.start_Date__c = Date.Today().addDays(-100);
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
        
        
    }
    @isTest
    private static void testRejectionActionController(){
        
        list<fsCore__Lending_Application__c> applicationList = TestHelperData.getTestLendingApplications().values();
        
        
        for(fsCore__Lending_Application__c application : applicationList){
            application.Rejection_Causes__c = 'Credit Report';
            application.Credit_Bureau_Used__c = 'Equifax';
            application.External_Rejection_Reasons__c = 'TEST';
            application.fsCore__Application_Status__c = 'Declined';
        }
        
        fsCore.DMLResult saveRslt = fsCore.LendingApplicationDMLWrapper.getInstance().upsertData(applicationList);
        set<Id> applicationId = saveRslt.getSuccessRecordSet();
        List<Id> appIdList = new List<Id>(applicationId);
        Test.startTest();
        RejectionActionController.getRejectionWrapper(appIdList[0]);
        RejectionActionController.rejectApplication(appIdList[0],'Test');
        Test.stopTest();
        
        // System.assertEquals(0, errors.size());
    }  
    
    @isTest
    private static void testRejectionActionController2(){
        
        list<fsCore__Lending_Application__c> applicationList = TestHelperData.getTestLendingApplications().values();
        
        
        for(fsCore__Lending_Application__c application : applicationList){
            application.Rejection_Causes__c = 'Credit Report';
            application.Credit_Bureau_Used__c = 'Equifax';
            application.External_Rejection_Reasons__c = 'TEST';
            application.fsCore__Application_Status__c = 'Declined';
        }
        
        fsCore.DMLResult saveRslt = fsCore.LendingApplicationDMLWrapper.getInstance().upsertData(applicationList);
        set<Id> applicationId = saveRslt.getSuccessRecordSet();
        List<Id> appIdList = new List<Id>(applicationId);
        Test.startTest();
        RejectionActionController.refreshRejectionWrapper(appIdList[0],'{"comments":{"label":"Decline Comments","value":""},"creditBureau":{},"creditBureauValueSet":[],"externalReasonCodes":[],"externalReasonsLabel":"External Reason(s)","externalReasonValueSet":[],"hasExternalReasons":false,"hasInternalReasons":false,"internalReasonCodes":[],"internalReasonsLabel":"Internal Reason(s)","internalReasonValueSet":[],"isShowCreditBureau":false,"rejectionCause":{"label":"Decline Cause","value":"Credit Report"},"rejectionCauseValueSet":[{"label":"-- None --","value":""},{"label":"Credit Report","value":"Credit Report"},{"label":"Non-Sufficient Funds","value":"Non-Sufficient Funds"},{"label":"Wrong State","value":"Wrong State"}]}');
        RejectionActionController.rejectApplication(appIdList[0],'{"comments":{"label":"Decline Comments","value":""},"creditBureau":{"label":"Credit Bureau Used","value":"TransUnion"},"creditBureauValueSet":[{"label":"Equifax","value":"Equifax"},{"label":"Experian","value":"Experian"},{"label":"TransUnion","value":"TransUnion"}],"externalReasonCodes":["BANKRUPTCY","DELINQUENT_CREDIT_OBLIGATIONS_WITH_OTHERS","NO_CREDIT_FILE"],"externalReasonsLabel":"External Reason(s)","externalReasonValueSet":[{"label":"Bankruptcy","value":"BANKRUPTCY"},{"label":"Delinquent past or present credit obligations with others","value":"DELINQUENT_CREDIT_OBLIGATIONS_WITH_OTHERS"},{"label":"Excessive Obligations in relation to income","value":"EXCESSIVE_OBLIGATIONS"},{"label":"Foreclosure or repossession","value":"FORECLOSURE_OR_REPOSSESSION"},{"label":"Income insufficient for amount of credit requested","value":"INCOME_INSUFFICIENT"},{"label":"Limited credit experience","value":"LIMITED_CREDIT_EXPERIENCE"},{"label":"No credit file","value":"NO_CREDIT_FILE"},{"label":"Number of recent inquiries on credit bureau report","value":"NUMBER_OF_RECENT_INQUIRIES"},{"label":"Other: New/active automobile loan tradeline(s) first reported within the last 12 months","value":"NEW_OR_ACTIVE_AUTOMOBILE_LOAN_TRADELINES"},{"label":"Other: New/active mortgage tradeline(s) first reported in the last 6 month","value":"NEW_OR_ACTIVE_MORTGAGE_TRADELINES"},{"label":"Other: New/active retail tradeline(s) first reported within the last 6 months","value":"NEW_OR_ACTIVE_RETAIL_TRADELINES"},{"label":"Other: New/active student loan tradeline(s) first reported within the last 12 months","value":"NEW_OR_ACTIVE_STUDENT_LOAN_TRADELINES"},{"label":"Unable to verify employment","value":"UNABLE_TO_VERIFY_EMPLOYMENT"}],"hasExternalReasons":true,"hasInternalReasons":true,"internalReasonCodes":["LOW_ANNUAL_INCOME","AUTO_LOAN_30+","MORE_THAN_2_CREDIT_INQUIRIES","DTI_MORE_THAN_80"],"internalReasonsLabel":"Internal Reason(s)","internalReasonValueSet":[{"label":"Annual income < $10,000","value":"LOW_ANNUAL_INCOME"},{"label":"Auto Loan 30+ in 6 months","value":"AUTO_LOAN_30+"},{"label":"Credit inquiries > 2 in 6 months","value":"MORE_THAN_2_CREDIT_INQUIRIES"},{"label":"DTI > 80%","value":"DTI_MORE_THAN_80"},{"label":"Employment <= 12 months","value":"EMPLOYMENT_LESS_THAN_12_MONTHS"},{"label":"Enrollment length < 6 months in DRP","value":"ENROLLMENT_LESS_THAN_6_MONTHS"},{"label":"Insufficient credit on file","value":"INSUFFICIENT_CREDIT_ON_FILE"},{"label":"Loan Amount Falls Outside of Established Credit Policy","value":"LOAN_AMOUNT_OUTSIDE_CREDIT_POLICY"},{"label":"Loan Repayment Term Exceeds 60 Months","value":"LOAN_REPAYMENT_TERM_EXCEEDS_60"},{"label":"Mortgage 30+ in 6 Months","value":"MORTGAGE_30+"},{"label":"New auto loan in the last 6 months","value":"NEW_AUTO_LOAN"},{"label":"New mortgage in the last 12 months","value":"NEW_MORTGAGE"},{"label":"New student loan in the last 12 months","value":"NEW_STUDENT_LOAN"},{"label":"No tradelines >$100 in 6 months","value":"NO_TRADELINES_MORE_THAN_100"},{"label":"Outstanding Obligations on Non-Enrolled Debts","value":"OUTSTANDING_OBLIGATIONS"},{"label":"Payment Extension > 12 months","value":"PAYMENT_EXTENSION_MORE_THAN_12_MONTHS"},{"label":"Recent bankruptcy","value":"RECENT_BANKRUPTCY"},{"label":"Repo trades","value":"REPO_TRADES"},{"label":"Retail tradelines > 1 in the last 6 months","value":"MORE_THAN_1_RETAIL_TRADELINE"},{"label":"Revolving tradeline > 1 in the last 6 months","value":"MORE_THAN_1_REVOLVING_TRADELINE"},{"label":"Unresponsive","value":"UNRESPONSIVE"}],"isShowCreditBureau":true,"rejectionCause":{"label":"Decline Cause","value":"Credit Report"},"rejectionCauseValueSet":[{"label":"-- None --","value":""},{"label":"Credit Report","value":"Credit Report"},{"label":"Non-Sufficient Funds","value":"Non-Sufficient Funds"},{"label":"Wrong State","value":"Wrong State"}]}');
        
        Test.stopTest();
        
        // System.assertEquals(0, errors.size());
    }  
   }