/**
 * Class Name  : SampleApplicantGeneratorTest
 * Description : This class has test method for SendToDocuSignController
 * Author      : Financial Spectra
 *
 */
@isTest
private class SendToDocuSignControllerTest{
	@testSetup
    static void createTestData(){
        TestHelperData.createTriggerExecutionTestData();
        
        List<fsCore__Lending_Application__c> appList = new List<fsCore__Lending_Application__c>();
        //create company and branch
        fsCore__Company_Setup__c testCompany = fsCore.TestHelperCompany.getTestCompanySetup('Test Company'
                                                                                            , 'TESTCO'
                                                                                            , '123456789');
        insert testCompany;
        System.assert(testCompany.Id != null, 'Test company created assert');
        
        fsCore__Branch_Setup__c testBranch = fsCore.TestHelperCompany.getTestBranchSetup('Test Branch'
                                                                                         , 'VLB'
                                                                                         , testCompany.Id
                                                                                         , null
                                                                                         , null);
        insert testBranch;
        System.assert(testBranch.Id != null, 'Test branch created assert'); 
        
        //create product
        fsCore__Product_Setup__c testProduct = fsCore.TestHelperProduct.getTestProductSetup('Test Product'
                                                                                            , 'DNL'
                                                                                            , fsCore.Constants.PRODUCT_FAMILY_LOAN
                                                                                            , fsCore.Constants.CYCLE_MONTHLY
                                                                                            , 1);
        testProduct.fsCore__Customer_Type__c = 'Person Account';
        testProduct.Credit_Pull_Report_Record_Type_Name__c ='DNL';
        testProduct.fsCore__Active_Application_Record_Type__c = 'DNL_Loan';
        
        insert testProduct;
        System.assert(testProduct.Id != null, 'Test product created assert');
         
        //create contract template
        fsCore__Payment_Allocation_Method_Setup__c testPaymentAlloc = fsCore.TestHelperFinancial.getTestPaymentAllocMethod('Test Payment Allocation');
        insert testPaymentAlloc;

        //create Contract Template
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
        List<fsCore__Lending_Application__c> testAppsList = fsCore.TestHelperLendingApplication.getTestApplicationBulk(testCompany
                                                                              , testBranch
                                                                              , testProduct
                                                                              , testContractTemplate
                                                                              , 200);
        
        fsCore__Lending_Application__c testApp = testAppsList[0];
        testApp.fsCore__Primary_Customer_Account__c = testAccount.Id;

        appList.add(testApp);
        //Database.insert(testApp);
        //System.assert(testApp.Id != null, 'Test Lending Application created assert');
        //
        //create Lending Application by populating company, branch, product
        //
        fsCore__Lending_Application__c testApplication = fsCore.TestHelperLendingApplication.getTestApplication(testCompany
                                                                              , testBranch
                                                                              , testProduct
                                                                              , 'Test Application');
        testApplication.fsCore__Primary_Customer_Account__c = testAccount.Id;
        
        appList.add(testApplication);
        insert appList;
        //System.assert(testApplication.Id != null, 'Test Lending Application created assert');

        //create Opportunity
        List<Opportunity> opplist = new List<Opportunity>();
        Opportunity testOpportunity = TestHelperData.createDNLOpportunity(testAccount.Id);
        testOpportunity.Co_Applicant_Name__c = testCoAccount.Id;
        testOpportunity.Related_Lending_Application__c = testApp.Id;
        testOpportunity.Import_Id__c = testApp.Id;

        Opportunity testOpportunity1= TestHelperData.createDNLOpportunity(testAccount.Id);
        testOpportunity1.Name = 'Test Opportunity1';
        testOpportunity1.Co_Applicant_Name__c = null;
        testOpportunity1.Program_Id__c = 'test1';
        testOpportunity1.Program_Type__c = 'test1';
        testOpportunity1.DRP_Name__c = 'DRP1211';
        testOpportunity1.DRP_Account_Number__c = '23763761';
        testOpportunity1.Related_Lending_Application__c = testApp.Id;
        testOpportunity1.Import_Id__c = '12761726';

        opplist.add(testOpportunity);
        opplist.add(testOpportunity1);


        Database.insert(opplist);
        System.assert(testOpportunity.Id != null, 'Test Opportunity created assert');

        testApp.Opp_Import_Id__c = testOpportunity.Id;
        Database.update(testApp);

  		//create Checklist Setup
		List<fsCore__Checklist_Setup__c> testCheckList = TestHelperData.createcheckList();
		insert testCheckList;

        //create Checklist Detail Setup
        List<fsCore__Checklist_Detail_Setup__c> testChecklistDetailSetUp = TestHelperData.createcheckListDetail(testCheckList);
		insert testChecklistDetailSetUp;
		
		//create Employment
        fsCore__Employment__c   testEmployment = fsCore.TestHelperMaster.getTestEmployment(testAccount.PersonContactId
                                                                                            ,'Test Employment'
                                                                                            , Date.today()
                                                                                            ,100000);
        testEmployment.fsCore__End_Date__c = null;
        insert testEmployment;
        System.assert(testEmployment.Id != null, 'Test Employment  created assert');

        //create Financials
        List<fsCore__Financial__c> testFinancialSetUp =	TestHelperData.createFinancials(testAccount.Id, testAccount.PersonContactId, testEmployment.Id);
        insert testFinancialSetUp;
        System.assert(testFinancialSetUp[0].Id != null, 'Test Financials  created assert');

        //create Lending Application Customer Secondary
        fsCore__Lending_Application_Customer__c  testAppCustomer1 = fsCore.TestHelperLendingApplication.getTestCustomer(testApp
                                                                                            ,testAccount.Id
                                                                                            ,testAccount.PersonContactId
                                                                                            ,'Primary');
        insert testAppCustomer1;
        System.assert(testAppCustomer1.Id != null, 'Test Lending Application Customer1 created assert');

        fsCore__Lending_Application_Customer__c  testAppCustomer2 = fsCore.TestHelperLendingApplication.getTestCustomer(testApp
                                                                                            ,testCoAccount.Id
                                                                                            ,testCoAccount.PersonContactId
                                                                                            ,'Secondary');
        insert testAppCustomer2;
        System.assert(testAppCustomer2.Id != null, 'Test Lending Application Customer2 created assert');

        TestHelperData.createDocusignDocumentSettings();


              


        
    }

    @isTest
    static void completeDocusignDocWCoApplicantTest() {
        List<Opportunity> testOpportunityList = [select id from Opportunity where Co_Applicant_Name__c != null];
        Opportunity testOpportunity = testOpportunityList[0];
        PageReference pageRef = Page.opportunityAppPage;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.StandardController(testOpportunity);
        SendToDocuSignController controller = new SendToDocuSignController(stdController);        



    } 

    @isTest
    static void completeDocusignLoanAppTest() {
        Opportunity testOpportunity = [select id from Opportunity limit 1];
        Account testAccount  = [select id from Account limit 1];
        dsfs__DocuSign_Status__c docusignDocLoanApp = new dsfs__DocuSign_Status__c();
        docusignDocLoanApp.Document_Type__c = 'Opportunity Loan Application';
        docusignDocLoanApp.dsfs__Company__c = testAccount.Id;
        docusignDocLoanApp.dsfs__DocuSign_Envelope_ID__c  = 'DE73BB17-72BB-4673-B2D5-E1F3D3E56724';
        docusignDocLoanApp.dsfs__Envelope_Status__c = 'Sent';
        docusignDocLoanApp.dsfs__Opportunity__c = testOpportunity.Id;
        docusignDocLoanApp.dsfs__Sender_Email__c  = 'aaa@xx.com';
        docusignDocLoanApp.dsfs__Sender__c  = 'Support';
        docusignDocLoanApp.dsfs__Subject__c = 'Please Sign this Loan Application';

        

        insert docusignDocLoanApp;

        docusignDocLoanApp.dsfs__Envelope_Status__c = 'Completed';
        update docusignDocLoanApp;

    }       

    @isTest
    static void completeDocusignPreTilaTest() {
        fsCore__Lending_Application__c testApplication = [select id from fsCore__Lending_Application__c limit 1];
        Opportunity testOpportunity = [select id from Opportunity limit 1];
        dsfs__DocuSign_Status__c docusignDocPreTila = new dsfs__DocuSign_Status__c();
        docusignDocPreTila.Document_Type__c = 'Pre-Tila';
        docusignDocPreTila.Lending_Application_Name__c = testApplication.Id;
        docusignDocPreTila.dsfs__DocuSign_Envelope_ID__c  = 'DE73BB17-72BB-4673-B2D5-E1F3D3E56724';
        docusignDocPreTila.dsfs__Envelope_Status__c = 'Sent';
        docusignDocPreTila.dsfs__Opportunity__c = testOpportunity.Id;
        docusignDocPreTila.dsfs__Sender_Email__c  = 'aaa@xx.com';
        docusignDocPreTila.dsfs__Sender__c  = 'Support';
        docusignDocPreTila.dsfs__Subject__c = 'Please Sign this PreTila';

        insert docusignDocPreTila;

        docusignDocPreTila.dsfs__Envelope_Status__c = 'Completed';
        update docusignDocPreTila;

    }  

    @isTest
    static void moveCompletedDocumentFromFilesToBoxTest() {
        fsCore__Lending_Application__c testApplication = [select id from fsCore__Lending_Application__c limit 1];
        Opportunity testOpportunity = [select id from Opportunity limit 1];
        Set<Id> oppIds = new Set<Id>();
        oppIds.add(testOpportunity.id);
        Map<Id,String> oppToFolderMap = new Map<Id,String>();
        oppToFolderMap.put(testOpportunity.id,'211212');
        SendToDocuSignController.moveCompletedDocumentFromFilesToBox(oppIds,oppToFolderMap);
        
    }             
    @isTest
    static void completeDocusignDocWOCoApplicantTest() {
        List<Opportunity> testOpportunityList = [select id from Opportunity where Co_Applicant_Name__c = null];
        Opportunity testOpportunity = testOpportunityList[0];
        PageReference pageRef = Page.opportunityAppPage;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.StandardController(testOpportunity);
        SendToDocuSignController controller = new SendToDocuSignController(stdController);        

    }     
    @isTest
    static void coverageForDateFormat() {
        SendToDocuSignController.getDateFromMMYYYYString('05/19');
        SendToDocuSignController.getDateFromMMYYYYString('05/75');
        SendToDocuSignController.getDateFromMMYYYYString('05/2019');
    }            


}