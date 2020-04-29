@isTest
public class VCLLobRequestTest{
    
    @isTest
    public static void createTestData(){
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
        nAccount.PersonHomePhone = '9087654321';
        Account coAppAccount = TestHelperData.createAccount('TEST','LASTNAME');
         coAppAccount.PersonHomePhone = '9087654321';
        accountlist.add(nAccount);
        accountlist.add(coAppAccount);
        Database.insert(accountlist);
        
        System.assert(nAccount.Id != null, 'Test Account created assert');
        
        List<Account> testAccountList = [select id, personcontactId from Account where id in (:nAccount.id,:coAppAccount.Id) ];
        
        Account testAccount = testAccountList[0];
        Account testCoAccount = testAccountList[1];
        system.debug(logginglevel.error,'testAccount.personcontactId :'+testAccount.personcontactId);
        

        fsCore__Stage_Setup__c testStage = fsCore.TestHelperWorkflow.getTestStage('PL_PRE_SCREEN', 'Lending_Application_Stage', 'Origination', 12);
		insert testStage;
        
        //Create Lending Application
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplicationWithContract(testCompany
                                                                                                                            , testBranch
                                                                                                                            , testProduct
                                                                                                                            , testContractTemplate
                                                                                                                            , 'Test Application');
         testApplication.Loan_Type__c = 'VCL';
         testApplication.fsCore__Application_Status__c = 'Declined';
         testApplication.fsCore__Current_Stage_Name__c = testStage.id;
        
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
     
      // fsCore__Stage_Setup__c testStage = [select id,fsCore__Stage_Code__c from fsCore__Stage_Setup__c where fsCore__Stage_Code__c='PL_PRE_SCREEN'];
      //  system.debug('Test Stage'+testStage.id);
       fsCore__Lending_Application__c testApp = [select id
                                                          ,Loan_Type__c
                                                          ,fsCore__Application_Status__c
                                                          ,fsCore__Current_Stage_Name__c
                                                           FROM fsCore__Lending_Application__c 
                                                    	   WHERE ID =: testApplication.Id];
      //   testApp.Loan_Type__c = 'VCL';
        // testApp.fsCore__Application_Status__c = 'Declined';
        // testApp.fsCore__Current_Stage_Name__c = testStage.id;
         //insert testApp;
        // HttpResponse response = new HttpResponse(); 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    	test.startTest();
        VCLLobRequest srvc = new VCLLobRequest(testApp.id);
        srvc.invoke();
        HttpResponse response = srvc.getResponse();
        test.stopTest();  
    }   
}