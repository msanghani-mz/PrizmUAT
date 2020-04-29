/*
 * Class Name   - ApplicationNotificationActionTest
 * Description  - Test class for ApplicationNotificationAction and ApplicationNotificationUtil
 */
@isTest(seeAllData=false)
private class ApplicationNotificationActionTest{

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
        
        
        //TODO PLEASE CREATE ONE MORE PRODUCT. THIS TEST NEEDS TO WORK ON BOTH PL & DNL
        //testProduct.fsCore__Customer_Type__c = 'Person Account';
        //testProduct.fsCore__Active_Application_Record_Type__c = 'VCL_Loan';
        //testProduct.fsServ__Active_Contract_Record_Type__c = 'VCL_Active_Contract';        
        //testProduct.Credit_Pull_Report_Record_Type_Name__c ='VCL';        
        
        insert testProduct;
        System.assert(testProduct.Id != null, 'Test product created assert');   
        
        fsCore__Product_Setup__c testProduct1 = fsCore.TestHelperProduct.getTestProductSetup('Test Product1'
                                                                            , 'VCL'
                                                                            , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                            , fsCore.Constants.CYCLE_MONTHLY
                                                                            , 1);
        testProduct1.fsCore__Customer_Type__c = 'Person Account';
        testProduct1.fsCore__Active_Application_Record_Type__c = 'VCL_Loan';
        testProduct1.fsServ__Active_Contract_Record_Type__c = 'VCL_Active_Contract';  
        testProduct.Credit_Pull_Report_Record_Type_Name__c ='VCL';    
        insert testProduct1;
        System.assert(testProduct1.Id != null, 'Test product created assert');        


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
        system.debug(logginglevel.error,'testAccount.PersonContactId :'+ testAccount.PersonContactId);
        //Contact testContact = TestHelperData.createContact(testAccount.id);
        //insert testContact;
        //System.assert(testContact.Id != null, 'Test Account created assert');
        fsCore__Financial__c finn_2 = fsCore.TestHelperMaster.getTestFinancial(testAccount.Id,testAccount.PersonContactId,'Income', 'Rental', 500);
        fsCore__Financial__c finn_3 = fsCore.TestHelperMaster.getTestFinancial(testAccount.Id,testAccount.PersonContactId, 'Income', 'Investment', 5000);
        fsCore__Financial__c finn_4 = fsCore.TestHelperMaster.getTestFinancial(testAccount.Id,testAccount.PersonContactId, 'Income', 'Social Security', 250);
        finn_4.start_Date__c = Date.Today().addDays(-100);
        fsCore__Financial__c finn_5 = fsCore.TestHelperMaster.getTestFinancial(testAccount.Id, testAccount.PersonContactId, 'Income', 'Disability', 250);
        List<fsCore__Financial__c> financialList = new List<fsCore__Financial__c>{finn_2,finn_3,finn_4,finn_5};
        fsCore.DMLResult finnSaveRslt = fsCore.FinancialDMLWrapper.getInstance().insertData(financialList);
        
        System.assert(!finnSaveRslt.hasErrors());



        //
        //create Lending Application by populating company, branch, product
        //
       List<fsCore__Lending_Application__c> testAppList = new List<fsCore__Lending_Application__c>();
       fsCore__Lending_Application__c testApplication1 = fsCore.TestHelperLendingApplication.getTestApplication(testCompany
                                                                              , testBranch
                                                                              , testProduct1
                                                                              , 'Test Application1');
        testApplication1.fsCore__Primary_Customer_Account__c = testAccount.Id;
        testApplication1.fsCore__Pricing_Name__c = testPricing.Id ;
        System.debug('testApplication1:---'+testApplication1);    
        
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplication(testCompany
                                                                              , testBranch
                                                                              , testProduct
                                                                              , 'Test Application');
        testApplication.fsCore__Primary_Customer_Account__c = testAccount.Id;
        testApplication.fsCore__Pricing_Name__c = testPricing.Id ;
        System.debug('testApplication:---'+testApplication);
        testAppList.add(testApplication);
        testAppList.add(testApplication1);
        insert testAppList;
        System.assert(testAppList.size()>0, 'Test Lending Applications created assert');      
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
        
            //create applications checklists
        List<fsCore__Lending_Application_Checklist__c> testAppChklistItems = fsCore.TestHelperLendingApplication.getTestApplicationChecklists(testApplication, testChecklistItems);
        fsCore.DMLResult chkItemsSaveRslt = fsCore.LendingApplicationChecklistDMLWrapper.getInstance().insertData(testAppChklistItems);
        System.assert(!chkItemsSaveRslt.hasErrors(), 'Test application checklist created assert');
        System.assertEquals(2, chkItemsSaveRslt.getSuccessRecordSet().size(), '2 application checklist created');

        Map<String, Schema.RecordTypeInfo> lookupRecTypeMap = Schema.SObjectType.fsCore__Lookup_Value__c.getRecordTypeInfosByDeveloperName();
        List<fsCore__Lookup_Value__c> incomeDocumentList = new List<fsCore__Lookup_Value__c>();
        
        fsCore__Lookup_Value__c incDoc1 = new fsCore__Lookup_Value__c();
        incDoc1.fsCore__Default_Product_Availability__c = 'Available';
        incDoc1.fsCore__Is_Active__c = true;
        incDoc1.fsCore__Is_Lease__c = false;
        incDoc1.fsCore__Is_Line__c = false;
        incDoc1.fsCore__Is_Loan__c = true;
        incDoc1.fsCore__Line_Of_Business__c = 'Origination';
        incDoc1.fsCore__Lookup_Name__c = 'Rental Income';
        incDoc1.Income_Document__c = '<ul><li>Two (2) complete personal tax returns with Schedule E, covering the last 2 years and verifying the annual income of ${0}{1}.</li></ul>';
        incDoc1.Name = 'RENTAL';
        incDoc1.RecordTypeId = lookupRecTypeMap.get('Income_Document_Type').getRecordTypeId();

        incomeDocumentList.add(incDoc1);
        
        fsCore__Lookup_Value__c incDoc2 = incDoc1.clone(false, false, true, false);
        incDoc2.Name = 'SELF-EMPLOYED';
        incomeDocumentList.add(incDoc2);

        fsCore__Lookup_Value__c incDoc3 = incDoc1.clone(false, false, true, false);
        incDoc3.Name = 'SALARY_60';
        incomeDocumentList.add(incDoc3);

        fsCore__Lookup_Value__c incDoc4 = incDoc1.clone(false, false, true, false);
        incDoc4.Name = 'PENSION';
        incomeDocumentList.add(incDoc4);

        fsCore__Lookup_Value__c incDoc5 = incDoc1.clone(false, false, true, false);
        incDoc5.Name = 'SALARY';
        incomeDocumentList.add(incDoc5);

        fsCore__Lookup_Value__c incDoc6 = incDoc1.clone(false, false, true, false);
        incDoc6.Name = 'SOCIAL_SECURITY';
        incomeDocumentList.add(incDoc6);

        fsCore__Lookup_Value__c incDoc7 = incDoc1.clone(false, false, true, false);
        incDoc7.Name = 'ALIMONY';
        incomeDocumentList.add(incDoc7);

        fsCore__Lookup_Value__c incDoc8 = incDoc1.clone(false, false, true, false);
        incDoc8.Name = 'DISABILITY';
        incomeDocumentList.add(incDoc8);

        fsCore__Lookup_Value__c incDoc9 = incDoc1.clone(false, false, true, false);
        incDoc9.Name = 'CHILD_SUPPORT';
        incomeDocumentList.add(incDoc9);                

        fsCore__Lookup_Value__c incDoc10 = incDoc1.clone(false, false, true, false);
        incDoc10.Name = 'INDEPENDENT_CONTRACTOR';
        incomeDocumentList.add(incDoc10);   

        fsCore__Lookup_Value__c incDoc11 = incDoc1.clone(false, false, true, false);
        incDoc11.Name = 'GREEN_CARD';
        incomeDocumentList.add(incDoc11);            

        
        insert incomeDocumentList;
    }

     @isTest
     private static void testApplicationAdverseActionNotification(){

        List<fsCore__Lending_Application__c> applicationList = TestHelperData.getTestLendingApplications().values();

       
        for(fsCore__Lending_Application__c application : applicationList){
            application.Rejection_Causes__c = 'Credit Report';
            application.Credit_Bureau_Used__c = 'TransUnion';
            application.External_Rejection_Reasons__c = 'TEST';
            application.fsCore__Application_Status__c = 'Declined';
        }
        
        fsCore.DMLResult saveRslt = fsCore.LendingApplicationDMLWrapper.getInstance().upsertData(applicationList);
        Set<Id> applicationIds = saveRslt.getSuccessRecordSet();
        
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(applicationIds);

        Test.startTest();
        ApplicationNotificationAction notifyAction = new ApplicationNotificationAction();
        notifyAction.setInput(acInput);
        notifyAction.setNotificationType(ApplicationNotificationUtil.ADVERSE_ACTION_NOTICE);
        notifyAction.process();
        
        List<fsCore.ErrorObject> errors = notifyAction.getOutput().getErrors();
        Test.stopTest();
        
        System.assertEquals(0, errors.size());
    }  
@isTest
     private static void testApplicationAdverseActionNotificationEquifax(){

        List<fsCore__Lending_Application__c> applicationList = TestHelperData.getTestLendingApplications().values();

       
        for(fsCore__Lending_Application__c application : applicationList){
            application.Rejection_Causes__c = 'Credit Report';
            application.Credit_Bureau_Used__c = 'Equifax';
            application.External_Rejection_Reasons__c = 'TEST';
            application.fsCore__Application_Status__c = 'Declined';
        }
        
        fsCore.DMLResult saveRslt = fsCore.LendingApplicationDMLWrapper.getInstance().upsertData(applicationList);
        Set<Id> applicationIds = saveRslt.getSuccessRecordSet();
        
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(applicationIds);

        Test.startTest();
        ApplicationNotificationAction notifyAction = new ApplicationNotificationAction();
        notifyAction.setInput(acInput);
        notifyAction.setNotificationType(ApplicationNotificationUtil.ADVERSE_ACTION_NOTICE);
        notifyAction.process();
        
        List<fsCore.ErrorObject> errors = notifyAction.getOutput().getErrors();
        Test.stopTest();
        
        System.assertEquals(0, errors.size());
    }  
    @isTest
     private static void testApplicationAdverseActionNotificationNSF(){

        List<fsCore__Lending_Application__c> applicationList = TestHelperData.getTestLendingApplications().values();

       
        for(fsCore__Lending_Application__c application : applicationList){
            application.Rejection_Causes__c = 'Non-Sufficient Funds';
            application.External_Rejection_Reasons__c = 'TEST';
            application.fsCore__Application_Status__c = 'Declined';
        }
        
        fsCore.DMLResult saveRslt = fsCore.LendingApplicationDMLWrapper.getInstance().upsertData(applicationList);
        Set<Id> applicationIds = saveRslt.getSuccessRecordSet();
        
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(applicationIds);

        Test.startTest();
        ApplicationNotificationAction notifyAction = new ApplicationNotificationAction();
        notifyAction.setInput(acInput);
        notifyAction.setNotificationType(ApplicationNotificationUtil.ADVERSE_ACTION_NOTICE);
        notifyAction.process();
        
        List<fsCore.ErrorObject> errors = notifyAction.getOutput().getErrors();
        Test.stopTest();
        
        System.assertEquals(0, errors.size());
    }  


     @isTest
     private static void testApplicationLoanProcessingLetterNotification(){

        List<fsCore__Lending_Application__c> applicationList = TestHelperData.getTestLendingApplications().values();

       
        for(fsCore__Lending_Application__c application : applicationList){
            application.Is_Loan_Processing_Letter_Sent__c = false;
        }
        
        fsCore.DMLResult saveRslt = fsCore.LendingApplicationDMLWrapper.getInstance().upsertData(applicationList);
        Set<Id> applicationIds = saveRslt.getSuccessRecordSet();
        
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(applicationIds);

        Test.startTest();
        ApplicationNotificationAction notifyAction = new ApplicationNotificationAction();
        notifyAction.setInput(acInput);
        notifyAction.setNotificationType(ApplicationNotificationUtil.LOAN_PROCESSING_LETTER);
        notifyAction.process();
        
        List<fsCore.ErrorObject> errors = notifyAction.getOutput().getErrors();
        Test.stopTest();
        
        System.assertEquals(0, errors.size());
    }  
    @isTest
     private static void testApplicationChecklistDocRejectionNotification(){

        List<fsCore__Lending_Application__c> applicationList = TestHelperData.getTestLendingApplications().values();

       Set<Id> appIds = new Set<Id>();
        for(fsCore__Lending_Application__c application : applicationList){
            application.Is_Document_Rejection_Email_Sent__c= false;
            appIds.add(application.Id);
            
        }

        List<fsCore__Lending_Application_Checklist__c> checklistUpdateList = new List<fsCore__Lending_Application_Checklist__c>();
        Map<Id, List<fsCore__Lending_Application_Checklist__c>>  checkListMap = fsCOre.LendingApplicationChecklistUtil.getChecklistsMap(appIds);
        for(Id appId : checkListMap.keySet()){
            for (fsCore__Lending_Application_Checklist__c  checklist : checkListMap.get(appId)){
                checklist.fsCore__Status__c = 'Rejected';
                checklist.Rejection_Reason__c = 'We received a copy of this document however it was illegible/unclear and will need to be resubmitted for review.';
                checklistUpdateList.add(checklist);
            }
        }

        update checklistUpdateList;        
        
        fsCore.DMLResult saveRslt = fsCore.LendingApplicationDMLWrapper.getInstance().upsertData(applicationList);
        Set<Id> applicationIds = saveRslt.getSuccessRecordSet();
        
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(applicationIds);

        Test.startTest();
        ApplicationNotificationAction notifyAction = new ApplicationNotificationAction();
        notifyAction.setInput(acInput);
        notifyAction.setNotificationType(ApplicationNotificationUtil.CHECKLIST_DOCUMENT_REJECTION);
        notifyAction.process();
        
        List<fsCore.ErrorObject> errors = notifyAction.getOutput().getErrors();
        Test.stopTest();
        
        System.assertEquals(0, errors.size());
    }  
 @isTest
     private static void testApplicationDocumentRejectionNOINotification(){

        List<fsCore__Lending_Application__c> applicationList = TestHelperData.getTestLendingApplications().values();

        for(fsCore__Lending_Application__c application : applicationList){
             application.Document_Submission_Due_Date__c= System.today().addDays(-5);
    
        }

        fsCore.DMLResult saveRslt = fsCore.LendingApplicationDMLWrapper.getInstance().upsertData(applicationList);
        Set<Id> applicationIds = saveRslt.getSuccessRecordSet();
        
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(applicationIds);

        Test.startTest();
        ApplicationNotificationAction notifyAction = new ApplicationNotificationAction();
        notifyAction.setInput(acInput);
        notifyAction.setNotificationType(ApplicationNotificationUtil.DOCUMENT_SUBMISSION_NOI);
        notifyAction.process();
        
        List<fsCore.ErrorObject> errors = notifyAction.getOutput().getErrors();
        Test.stopTest();
        
        System.assertEquals(0, errors.size());
    }  

    @isTest
     private static void testApplicationPreTilaNoiNotification(){

        List<fsCore__Lending_Application__c> applicationList = TestHelperData.getTestLendingApplications().values();

       
        for(fsCore__Lending_Application__c application : applicationList){
            application.Pre_TILA_Sent_Date__c = System.today().addDays(-20);
            application.Pre_TILA_Sign_Due_Date__c = System.today().addDays(5);
            application.Is_PreTILA_Signed__c = false;
        }
        
        fsCore.DMLResult saveRslt = fsCore.LendingApplicationDMLWrapper.getInstance().upsertData(applicationList);
        Set<Id> applicationIds = saveRslt.getSuccessRecordSet();
        
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(applicationIds);

        Test.startTest();
        ApplicationNotificationAction notifyAction = new ApplicationNotificationAction();
        notifyAction.setInput(acInput);
        notifyAction.setNotificationType(ApplicationNotificationUtil.PRE_TILA_NOI);
        notifyAction.process();
        
        List<fsCore.ErrorObject> errors = notifyAction.getOutput().getErrors();
        Test.stopTest();
        
        System.assertEquals(0, errors.size());
    } 
    @isTest
    private static void testApplicationDisclosureDocNotification(){
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Test Stage ', fsCore.Constants.STAGE_TYPE_APPLICATION, 'Origination', 12);
        testStage.fsCore__Stage_Code__c = 'PL_PRE_SCREEN';
		insert testStage;
        fsCore__Stage_Setup__c testStage1 = [select id, fsCore__Stage_Code__c,Name from fsCore__Stage_Setup__c testStage1 limit 1];
        System.debug(loggingLevel.ERROR, '-- test Stage Name ... ' + testStage1.Name);
        System.debug(testStage.id +'test Stage Id');
        System.assert(testStage.Id != null, 'Test stage created');     
        List<fsCore__Lending_Application__c> applicationList = TestHelperData.getTestLendingApplications().values();
        for(fsCore__Lending_Application__c application : applicationList){
            application.Is_Disclosure_Document_Sent__c = false;
            application.Is_PreTILA_Signed__c = true;
            application.fsCore__Current_Stage_Name__c = testStage.Id;
        }
        fsCore.DMLResult saveRslt = fsCore.LendingApplicationDMLWrapper.getInstance().upsertData(applicationList);
        Set<Id> applicationIds = saveRslt.getSuccessRecordSet();
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(applicationIds);
        Test.startTest();
        ApplicationNotificationAction notifyAction = new ApplicationNotificationAction();
        notifyAction.setInput(acInput);
        notifyAction.setNotificationType(ApplicationNotificationUtil.DISCLOSURE_DOCUMENT_NOTIFICATION);
        notifyAction.process();
        List<fsCore.ErrorObject> errors = notifyAction.getOutput().getErrors();
        Test.stopTest();
        System.assertEquals(0, errors.size());
    } 
     @isTest
    private static void testApplicationWithdrawnNotification(){
        List<fsCore__Lending_Application__c> applicationList = TestHelperData.getTestLendingApplications().values();
        for(fsCore__Lending_Application__c application : applicationList){
            application.fsCore__Application_Status__c = 'Withdrawn';
            application.fsCore__Is_Application_Read_Only__c = true;
            application.RecordTypeId = Schema.SObjectType.fsCore__Lending_Application__c.getRecordTypeInfosByDeveloperName().get('Read_Only').getRecordTypeId();
        }
        fsCore.DMLResult saveRslt = fsCore.LendingApplicationDMLWrapper.getInstance().upsertData(applicationList);
        Set<Id> applicationIds = saveRslt.getSuccessRecordSet();
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(applicationIds);
        Test.startTest();
        ApplicationNotificationAction notifyAction = new ApplicationNotificationAction();
        notifyAction.setInput(acInput);
        notifyAction.setNotificationType(ApplicationNotificationUtil.APPLICATION_WITHDRAWN_NOTIFICATION);
        notifyAction.process();
        List<fsCore.ErrorObject> errors = notifyAction.getOutput().getErrors();
        Test.stopTest();
        System.assertEquals(0, errors.size());
    } 
    
        @isTest
    private static void testApplicationVCLUserRegNotification(){
        List<fsCore__Lending_Application__c> applicationList = TestHelperData.getTestLendingApplications().values();
        for(fsCore__Lending_Application__c application : applicationList){
           // application.Account_Registered__c = false ;
            application.Welcome_Letter_Sent_Date__c = date.Today();
            application.VCL_User_Registration_Reminder_Sent__c = '3';
        }
        fsCore.DMLResult saveRslt = fsCore.LendingApplicationDMLWrapper.getInstance().upsertData(applicationList);
        Set<Id> applicationIds = saveRslt.getSuccessRecordSet();
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(applicationIds);
        Test.startTest();
        ApplicationNotificationAction notifyAction = new ApplicationNotificationAction();
        notifyAction.setInput(acInput);
        notifyAction.setNotificationType(ApplicationNotificationUtil.VCL_USER_REGISTRATION_REMINDER);
        notifyAction.process();
        List<fsCore.ErrorObject> errors = notifyAction.getOutput().getErrors();
        Test.stopTest();
        System.assertEquals(0, errors.size());
    } 
    
    @isTest
     private static void testApplicationWelcomeLetterNotification(){

        List<fsCore__Lending_Application__c> applicationList = TestHelperData.getTestLendingApplications().values();

        for(fsCore__Lending_Application__c application : applicationList){
            application.Welcome_Letter_Sent_Date__c = null;
            application.fsServ__Is_Contracted__c = true;
            application.fsCore__Is_Funded__c = true;
            application.fsCore__Is_Test__c = true;
            application.recordTypeId = Schema.SObjectType.fsCore__Lending_Application__c.getRecordTypeInfosByDeveloperName().get('Read_Only').getRecordTypeId();
        }
        
        fsCore.DMLResult saveRslt = fsCore.LendingApplicationDMLWrapper.getInstance().upsertData(applicationList);
        Set<Id> applicationIds = saveRslt.getSuccessRecordSet();
        
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(applicationIds);

        Test.startTest();
        ApplicationNotificationAction notifyAction = new ApplicationNotificationAction();
        notifyAction.setInput(acInput);
        notifyAction.setNotificationType(ApplicationNotificationUtil.WELCOME_LETTER);
        notifyAction.process();
        
        List<fsCore.ErrorObject> errors = notifyAction.getOutput().getErrors();
        Test.stopTest();
        
        System.assertEquals(0, errors.size());
    }                
        @isTest
     private static void testApplicationVCLWelcomeLetterNotification(){

        List<fsCore__Lending_Application__c> applicationList = TestHelperData.getTestLendingApplications().values();

        for(fsCore__Lending_Application__c application : applicationList){
            application.Welcome_Letter_Sent_Date__c = null;
            application.fsServ__Is_Contracted__c = true;
            application.fsCore__Is_Funded__c = true;
            application.fsCore__Is_Test__c = true;
            application.recordTypeId = Schema.SObjectType.fsCore__Lending_Application__c.getRecordTypeInfosByDeveloperName().get('Read_Only').getRecordTypeId();
        }
        
        fsCore.DMLResult saveRslt = fsCore.LendingApplicationDMLWrapper.getInstance().upsertData(applicationList);
        Set<Id> applicationIds = saveRslt.getSuccessRecordSet();
        
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(applicationIds);

        Test.startTest();
        ApplicationNotificationAction notifyAction = new ApplicationNotificationAction();
        notifyAction.setInput(acInput);
        notifyAction.setNotificationType(ApplicationNotificationUtil.VCL_WELCOME_LETTER);
        notifyAction.process();
        
        List<fsCore.ErrorObject> errors = notifyAction.getOutput().getErrors();
        Test.stopTest();
        
        System.assertEquals(0, errors.size());
    }                
    
      @isTest
     private static void testApplicationVCLBankAccountNotification(){

        List<fsCore__Lending_Application__c> applicationList = TestHelperData.getTestLendingApplications().values();

        for(fsCore__Lending_Application__c application : applicationList){
            application.fsCore__Is_Application_Read_Only__c = true;
            application.recordTypeId = Schema.SObjectType.fsCore__Lending_Application__c.getRecordTypeInfosByDeveloperName().get('Read_Only').getRecordTypeId();
        }
        
        fsCore.DMLResult saveRslt = fsCore.LendingApplicationDMLWrapper.getInstance().upsertData(applicationList);
        Set<Id> applicationIds = saveRslt.getSuccessRecordSet();
        
        fsCore.ActionInput acInput = new fsCore.ActionInput();
        acInput.addRecords(applicationIds);

        Test.startTest();
        ApplicationNotificationAction notifyAction = new ApplicationNotificationAction();
        notifyAction.setInput(acInput);
        notifyAction.setNotificationType(ApplicationNotificationUtil.VCL_BANK_ACCOUNT_REMINDER);
        notifyAction.process();
        
        List<fsCore.ErrorObject> errors = notifyAction.getOutput().getErrors();
        Test.stopTest();
        
        System.assertEquals(0, errors.size());
    }                
    @isTest
    private static void testLoanProcessingAction(){
        Test.startTest();
        LoanProcessingLetterAction action = new LoanProcessingLetterAction();
        Test.stopTest();
    }
}