/*
 * FinancialSpectra Pty Ltd
 * 
 * Class Name   - ApplicationCustomTriggerManagerTest
 *
 * Description  - Test class for ApplicationCustomTriggerManager
 *
 *
 */
@isTest
private class ApplicationCustomTriggerManagerTest{

    @testSetup
    static void createTestData(){

        TestHelperData.createTriggerExecutionTestData();

        //create custom settings
        fsCore.SeedCustomSettings.createCustomSettings(new Set<String>{fsCore.Constants.CUSTOM_SETTING_CUSTOM_NUMBER_FORMAT
                                                              , fsCore.Constants.CUSTOM_SETTING_CALCULATOR_PREFERENCE});
        
       
        //Create Company and Branch
        fscore__Company_Setup__c testCompany = fsCore.TestHelperCompany.getTestCompanySetup('Test Company', 'TESTCO', '123456789');
        insert testCompany;
        System.assert(testCompany.Id != null, 'Test company created assert');  
        
        fsCore__Branch_Setup__c testBranch = fsCore.TestHelperCompany.getTestBranchSetup('Test Branch', 'TBRCH', testCompany.Id, null, null);
        insert testBranch;
        System.assert(testBranch.Id != null, 'Test branch created assert');
        
        
        //Create Product
        fsCore__Product_Setup__c testProduct = fsCore.TestHelperProduct.getTestProductSetup('Test Product'
                                                                                            , 'VCL'
                                                                                            , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                                            , fsCore.Constants.CYCLE_MONTHLY
                                                                                            , 1);
        testProduct.Credit_Pull_Report_Record_Type_Name__c ='VCL';
        testProduct.fsCore__Active_Application_Record_Type__c = 'VCL_Loan';

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
        
        fsCore__Stage_Setup__c testStage3 = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                  , 3);
        testStage3.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage3.fsCore__Stage_Code__c ='PL_PRE_SCREEN';
        testStage3.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage3;
        System.assert(testStage3.Id != null, 'Test stage 2 created assert');
        
        //Create Lending Application
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                                            , testBranch
                                                                                                                            , testProduct
                                                                                                                            , testContractTemplate
                                                                                                                            , 'Test Application');
        testApplication.fsCore__Current_Stage_Name__c = testStage3.id;
        insert testApplication;
        System.assert(testApplication.Id != null, 'Test Lending Application created assert'); 
        
        //create Lending Application Customer Secondary
        fsCore__Lending_Application_Customer__c  testAppCustomer1 = fsCore.TestHelperLendingApplication.getTestCustomer(testApplication
                                                                                                                        ,testAccount.Id
                                                                                                                        ,testAccount.PersonContactId
                                                                                                                        ,'Primary');
        insert testAppCustomer1;
        System.assert(testAppCustomer1.Id != null, 'Test Lending Application Customer1 created assert');
        
        fsCore__Lending_Application_Customer__c  testAppCustomer2 = fsCore.TestHelperLendingApplication.getTestCustomer(testApplication                                                                                                                        ,testCoAccount.Id
                                                                                                                        ,testCoAccount.PersonContactId
                                                                                                                        ,'Secondary');
        insert testAppCustomer2;
        System.assert(testAppCustomer2.Id != null, 'Test Lending Application Customer2 created assert');
       
        //create stage
        fsCore__Stage_Setup__c testStage1 = fsCore.TestHelperWorkflow.createTestStageWithValidationRules('Application Entry'
                                                                                        , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                        , fsCore.Constants.LOB_ORIGINATION
                                                                                        , 1);
        System.assert(testStage1.Id != null, 'Test stage 1 created assert');
        
        fsCore__Stage_Setup__c testStage2 = fsCore.TestHelperWorkflow.getTestStage('Underwriting'
                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                  , fsCore.Constants.LOB_ORIGINATION
                                                                  , 2);
        testStage2.fsCore__Is_Set_Status_On_Entry__c = true;
        testStage2.fsCore__Stage_Code__c ='DNL_DOC_PROCESSING';
        testStage2.fsCore__Application_Status_Value__c = 'In Progress';
        insert testStage2;
        System.assert(testStage2.Id != null, 'Test stage 2 created assert');
        
        //Assignment setup
        /*fsCore__Queue_Assignment_Setup__c testAssignSetup = fsCore.TestHelperWorkflow.getTestQueueAssignment(
                                                                       'Process Funding'
                                                                      , UserInfo.getUserId()
                                                                      , 'User or Queue'
                                                                      , fsCore.Constants.LOB_ORIGINATION
                                                                      , 1);
        system.debug(logginglevel.error,' **** testAssignSetup  ****  :'+testAssignSetup);
        insert testAssignSetup;
        System.assert(testAssignSetup.Id != null, 'Test assignment setup created assert');

        fsCore__Stage_Queue_Assignment_Setup__c testStageAssignment1 = fsCore.TestHelperWorkflow.getTestStageQueueAssignment(
                                                                                    testStage1.Id
                                                                                   ,testAssignSetup.Id
                                                                                   ,1);
        fsCore__Stage_Queue_Assignment_Setup__c testStageAssignment2 = fsCore.TestHelperWorkflow.getTestStageQueueAssignment(
                                                                                    testStage2.Id
                                                                                   ,testAssignSetup.Id
                                                                                   ,1);
        
        List<fsCore__Stage_Queue_Assignment_Setup__c> stageAssignments = new List<fsCore__Stage_Queue_Assignment_Setup__c>();
        stageAssignments.add(testStageAssignment1);
        stageAssignments.add(testStageAssignment2);
        insert stageAssignments;
        System.assert(testStageAssignment1.Id != null);
        System.assert(testStageAssignment2.Id != null);
        */
    
        //stage process actions
        fsCore__Process_Action_Setup__c testProcessAction = fsCore.TestHelperWorkflow.getTestProcessAction('Validate', fsCore.Constants.LOB_ORIGINATION
                                                                                          , Schema.SObjectType.fsCore__Lending_Application__c.getName()
                                                                                          , 'ExecuteApex'
                                                                                          , 'ApplicationValidateStageActionProcessor');
        insert testProcessAction;
        System.assert(testProcessAction.Id != null);
        
        fsCore__Stage_Process_Action_Setup__c testStageProcessAction = fsCore.TestHelperWorkflow.getTestStageProcessAction(
                                                                                  testStage2.Id
                                                                                , testProcessAction.Id
                                                                                , 1);
        testStageProcessAction.fsCore__Is_Auto_Execute_On_Stage_Entry__c = true;
        insert testStageProcessAction;

        

        List<User> userList = new List<User>();
        userList.add(TestHelperUserUtil.getTestUser('TESTFIRSTNAME','TESTLASTNAME'));
        userList.add(TestHelperUserUtil.getTestUser('TESTFIRSTNAME2','TESTLASTNAME2'));
        insert userList;
        System.assert(userList[0].Id != null, 'Test application created assert');

        List<Stage_Member_Setup__c> stageMemberList = new List<Stage_Member_Setup__c>();
        Stage_Member_Setup__c stageMemberSetup = new Stage_Member_Setup__c();
        stageMemberSetup.User__c = userList[0].Id;
        stageMemberSetup.Stage_Name__c = testStage1.id;
        stageMemberSetup.Is_Active__c = true;
        stageMemberList.add(stageMemberSetup);


        Stage_Member_Setup__c stageMemberSetup2 = new Stage_Member_Setup__c();
        stageMemberSetup2.User__c = userList[0].Id;
        stageMemberSetup2.Stage_Name__c = testStage2.id;
        stageMemberSetup2.Is_Active__c = true;
        stageMemberList.add(stageMemberSetup2);

        Stage_Member_Setup__c stageMemberSetup3 = new Stage_Member_Setup__c();
        stageMemberSetup3.User__c = userList[1].Id;
        stageMemberSetup3.Stage_Name__c = testStage2.id;
        stageMemberSetup3.Is_Active__c = true;
        stageMemberList.add(stageMemberSetup3);


        insert stageMemberList;

    }


    @isTest
    private static void testClientNotInterested(){
        fsCore__Lending_Application__c testApplication = [Select id from fsCore__Lending_Application__c];
                
        Test.startTest();


        Test.stopTest();
    }
    @isTest
    private static void testRestoreApplicationStatus(){
        fsCore__Lending_Application__c testApplication = [Select id from fsCore__Lending_Application__c];
                
        Test.startTest();


        Test.stopTest();
    }
    @isTest
    private static void testCustomerDoNotCall(){
       fsCore__Lending_Application__c testApplication = [Select id from fsCore__Lending_Application__c];
                
        Test.startTest();


        Test.stopTest();
    }    
    @isTest
    private static void testSocureCall(){
        fsCore__Lending_Application__c testApplication = [Select id , Loan_Type__c ,fsCore__Record_Type_Formula__c , Is_User_Registration_Completed__c from fsCore__Lending_Application__c];
        Id recTypeId = Schema.SObjectType.fsCore__Lending_Application__c.getRecordTypeInfosByDeveloperName().get('VCL_Loan').getRecordTypeId();
        testApplication.RecordTypeId = recTypeId;
        update testApplication;
        System.debug(loggingLEVEL.ERROR ,testApplication );
        fsCore.LendingApplicationTriggerWrapper.getInstance().reset();
        Test.startTest();
        testApplication.Is_User_Registration_Completed__c = true;
        update testApplication;
        Test.stopTest();
    }     
     @isTest
    private static void testStageCompletion(){
        fsCore__Lending_Application__c testApplication = [Select id , Loan_Type__c ,fsCore__Record_Type_Formula__c , Current_Stage_Code_Formula__c,Is_Doc_Processing__c from fsCore__Lending_Application__c];
        Id recTypeId = Schema.SObjectType.fsCore__Lending_Application__c.getRecordTypeInfosByDeveloperName().get('VCL_Loan').getRecordTypeId();
        testApplication.RecordTypeId = recTypeId;
        update testApplication;
        System.debug(loggingLEVEL.ERROR ,testApplication );
        fsCore.LendingApplicationTriggerWrapper.getInstance().reset();
        Test.startTest();
        testApplication.Is_Doc_Processing__c = true;
        update testApplication;
        Test.stopTest();
    }    

}