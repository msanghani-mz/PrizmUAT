@isTest
public class ApplicationVoidControllerTest {
    

  @isTest
    public static void test1(){
        TestHelperData.createTriggerExecutionTestData();
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
        
        //Create Lending Application
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                                            , testBranch
                                                                                                                            , testProduct
                                                                                                                            , testContractTemplate
                                                                                                                            , 'Test Application');
        insert testApplication;
        System.assert(testApplication.Id != null, 'Test Lending Application created assert'); 
        
        //create Lending Application Customers
        fsCore__Lending_Application_Customer__c  testAppCustomer1 = fsCore.TestHelperLendingApplication.getTestCustomer(testApplication
                                                                                                                        ,testAccount.Id
                                                                                                                        ,testAccount.PersonContactId
                                                                                                                        ,'Primary');
        insert testAppCustomer1;
        System.assert(testAppCustomer1.Id != null, 'Test Lending Application Customer1 created assert');
        
        fsCore__Lending_Application_Customer__c  testAppCustomer2 = fsCore.TestHelperLendingApplication.getTestCustomer(testApplication
                                                                                                                        ,testCoAccount.Id
                                                                                                                        ,testCoAccount.PersonContactId
                                                                                                                        ,'Secondary');
        insert testAppCustomer2;
        System.assert(testAppCustomer2.Id != null, 'Test Lending Application Customer2 created assert');
       
        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('Test Stage Name', 'Lending_Application_Stage', 'Origination', 12);
        insert testStage;
        fsCore__Process_Action_Setup__c testProcessAction = fsCore.TestHelperWorkflow.getTestProcessAction('VALIDATE_APP_STAGE', 'Origination', 'fscore__lending_application__c', 'ExecuteApex', 'ApplicationValidateStageActionProcessor');
        insert testProcessAction;
        fsCore__Rule_Setup__c testRule = fsCore.TestHelperProduct.getTestRuleSetup('Test Rule Name','Business_Rule', 'Origination');
        insert testRule;
        fsCore__Stage_Validation_Rule_Setup__c testStageValidationRule = fsCore.TestHelperWorkflow.getTestStageValidationRule(testStage.id, testRule.id, 1);
        insert testStageValidationRule;
        fsCore__Stage_Process_Action_Setup__c testStageProcessAction = fsCore.TestHelperWorkflow.getTestStageProcessAction(testStage.id, testProcessAction.id, 1);
        insert testStageProcessAction;
        fsCore__Lending_Application_Stage__c appStage = new fsCore__Lending_Application_Stage__c();
        appStage.fsCore__Lending_Application_Number__c = testApplication.id;
        appStage.fsCore__Stage_Name__c = testStage.id;
        appStage.fsCore__Direction__c = 'Forward';
        insert appStage;
        
        String comment = 'Void Application' ;
        String returnValue = ApplicationVoidController.voidApplication(testApplication.id, comment);
        System.debug(returnValue);
        fsCore__Lending_Application__c app = [Select id , fsCore__Is_Voided__c , fsCore__Comments__c from fsCore__Lending_Application__c where id =:testApplication.id];
        
        System.assertEquals(true,app.fsCore__Is_Voided__c);
        System.assertEquals(comment,app.fsCore__Comments__c);

        
    }
}