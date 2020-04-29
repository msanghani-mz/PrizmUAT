@isTest
public class ApplicationStageCustomTriggerManagerTest {

    @testSetup
    static void createTestData(){
        
        TestHelperData.createTriggerExecutionTestData();
        
        fsServ.TestHelperGlobal.createSetupData();
        
        fsCore__Branch_Setup__c testBranch = fsServ.TestQueryHelper.getTestBranches().get('TCHQ');
        testBranch.fsCore__Business_Date__c = testBranch.fsCore__Business_Date__c.addDays(30);
        update testBranch;
        fsCore__Company_Setup__c testCompany = [SELECT Id, fsCore__Company_Logo_File_Id__c , fsCore__Company_Code__c FROM fsCore__Company_Setup__c WHERE Id = :testBranch.fsCore__Company_Name__c];
        //update testCompany;
        System.assert(testBranch.Id != null, 'Test branch created assert'); 
        
        //create product
        fsCore__Product_Setup__c testProduct = [select id, name
                                                ,fsCore__Customer_Type__c
                                                ,fsCore__Is_Funding_In_Tranches_Allowed__c
                                                ,fsCore__Is_Billing_Cycle_Flexible__c
                                                ,fsCore__Billing_Cycle__c
                                                ,Credit_Pull_Report_Record_Type_Name__c 
                                                ,fsCore__Is_Secured__c
                                                ,fsCore__Collateral_Family__c
                                                , fsCore__Collateral_Sub_Family__c
                                                , fsCore__Is_Syndication_Allowed__c
                                                , fsCore__Product_Family__c
                                                from fsCore__Product_Setup__c limit 1]; 
        
        
        System.assert(testCompany.Id != null, 'Test company created assert');
        
        testProduct.fsCore__Customer_Type__c = 'Person Account';
        testProduct.Credit_Pull_Report_Record_Type_Name__c = 'DNL'; //VCL-111
        testProduct.fsCore__product_code__c = 'DNL';
        Database.upsert(testProduct);
        System.assert(testProduct.Id != null, 'Test product created assert');
        
        //create payment allocation
        fsCore__Payment_Allocation_Method_Setup__c testPaymentAlloc  = [Select id from fsCore__Payment_Allocation_Method_Setup__c limit 1];
  
        
        //create Contract Template
        fsCore__Contract_Template_Setup__c testContractTemplate = fsCore.TestHelperProduct.getTestContractTemplateSetup
            ('Test Contract Template'
             , fsCore.Constants.PRODUCT_FAMILY_LOAN
             , testPaymentAlloc.Id
             , 1);
         Database.upsert(testContractTemplate);    
        System.assert(testContractTemplate.Id != null, 'Test contract template created assert');        

        //create SFS System Settings
        SFS_System_Settings__c sysSetting = TestHelperData.createSFSSystemSettings();
        sysSetting.Default_Branch_ID_DNL__c = testBranch.Id;
        sysSetting.Default_Product_ID_DNL__c = testProduct.Id;
        sysSetting.Default_Company_Code_DNL__c = testCompany.fsCore__Company_Code__c;
        sysSetting.Default_Company_ID_DNL__c = testCompany.Id;
        sysSetting.Default_Pull_Type_DNL__c = 'Soft';
        Database.upsert(sysSetting);
        System.assert(sysSetting.Id != null, 'Test SFS System Settings created assert');
        
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
        
        
        
        
        
        
        //Create Rule Setup
        fsCore__Rule_Setup__c testRule = fsCore.TestHelperProduct.getTestRuleSetup('Test Rule Name'
                                                                                   ,'Business_Rule'
                                                                                   , 'Origination');
        insert testRule;
        
        
        //Create Stage
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Pre-Settlement'
                                                                                  , fsCore.Constants.STAGE_TYPE_APPLICATION
                                                                                  , 'Origination'
                                                                                  , 12);
        testStage.fsCore__Stage_Code__c = 'DNL_PRE_SETTLEMENT';
        insert testStage;
        
        //Create Stage Validation Rule Setup
        fsCore__Stage_Validation_Rule_Setup__c testStageValidationRule = fsCore.TestHelperWorkflow.getTestStageValidationRule(testStage.id
                                                                                                                              , testRule.id
                                                                                                                              , 1);
        insert testStageValidationRule;
        
        
        //Create Lending Application
        List<fsCore__Lending_Application__c> testAppsList = fsCore.TestHelperLendingApplication.getTestApplicationBulk(testCompany
                                                                                                                       , testBranch
                                                                                                                       , testProduct
                                                                                                                       , testContractTemplate
                                                                                                                       , 5);
        
        fsCore__Lending_Application__c testApp = testAppsList[0];
        testApp.fsCore__Primary_Customer_Account__c = testAccount.Id;
        Database.insert(testApp);
        System.assert(testApp.Id != null, 'Test Lending Application created assert');
        
        fsCore__Trigger_Execution_Settings__c trigExecutionSettings = new fsCore__Trigger_Execution_Settings__c();
        trigExecutionSettings.fsCore__Custom_Trigger_Manager_Class__c = 'ApplicationStageCustomTriggerManager';
        trigExecutionSettings.fsCore__Number_Of_Trigger_Executions__c = 1;
        trigExecutionSettings.name = 'LendingApplicationStageTrigger';
        
        Insert trigExecutionSettings;
    }   
    
    @isTest static void test() {
        Test.startTest();
        fsCore__Stage_Setup__c stageTest = [SELECT ID, fsCore__Stage_Code__c from fsCore__Stage_Setup__c];
        List<fsCore__Lending_Application_Stage__c> app = [SELECT ID, fsCore__Stage_Status__c, Stage_Code_Formula__c from fsCore__Lending_Application_Stage__c];
        system.debug('=='+app);
        for(fsCore__Lending_Application_Stage__c appTest : app){
            appTest.fsCore__Stage_Status__c = 'Failed';
        }
        system.debug('app'+app);
        update app;
        Test.stopTest();
    }
}